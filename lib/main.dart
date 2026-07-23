import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'config/storage_keys.dart';
import 'models/app_models.dart';
import 'providers/achievement_state.dart';
import 'providers/app_state.dart';
import 'providers/sync_state.dart';
import 'services/cloud_service.dart';
import 'theme/app_theme.dart';
import 'views/dashboard_view.dart';
import 'views/learning_hub_view.dart';
import 'views/passport_view.dart';
import 'views/snap_grade_view.dart';
import 'views/writing_canvas_view.dart';
import 'views/account_view.dart';
import 'views/welcome_journey_view.dart';
import 'widgets/leo_sprite.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final userBox = await Hive.openBox<dynamic>(StorageKeys.userData);
  final legacyBox = await Hive.openBox<dynamic>(StorageKeys.legacyUserData);
  if (userBox.isEmpty && legacyBox.isNotEmpty) {
    await userBox.putAll(legacyBox.toMap());
  }
  await CloudBootstrap.initialize();
  runApp(const ProviderScope(child: LinguaTomoApp()));
}

class LinguaTomoApp extends ConsumerStatefulWidget {
  const LinguaTomoApp({super.key});

  @override
  ConsumerState<LinguaTomoApp> createState() => _LinguaTomoAppState();
}

class _LinguaTomoAppState extends ConsumerState<LinguaTomoApp> {
  var _ready = false;
  var _showLoading = true;
  var _prepared = false;
  DifficultyTier? _loadingTier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prepared) return;
    _prepared = true;
    _prepare();
  }

  /// The loading screen stays up until the app is genuinely ready: core
  /// artwork is cached, the first frames have rendered, and a short minimum
  /// dwell has passed so Leo's butterfly chase never feels cut short.
  Future<void> _prepare() async {
    final minimum = Future<void>.delayed(const Duration(milliseconds: 2400));
    final artwork = _precacheArtwork();
    await Future.wait(<Future<void>>[minimum, artwork]);
    if (mounted) setState(() => _ready = true);
  }

  Future<void> _precacheArtwork() async {
    try {
      await Future.wait(<Future<void>>[
        for (final environment in NestEnvironment.values)
          precacheImage(AssetImage(environment.asset), context),
        precacheImage(
          const AssetImage('assets/branding/leo-face-icon.png'),
          context,
        ),
      ]).timeout(const Duration(milliseconds: 1200), onTimeout: () => <void>[]);
    } catch (_) {
      // Artwork caching is best-effort; the app must always open.
    }
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(experienceProvider);
    final scale = switch (mode) {
      ExperienceMode.visualExplorer => 1.10,
      ExperienceMode.standard => 1.0,
      ExperienceMode.comfort => 1.18,
    };
    return MaterialApp(
      title: 'LinguaTomo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightFor(mode),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: _showLoading
          ? LeoLoadingScreen(
              reduceMotion: mode == ExperienceMode.comfort,
              ready: _ready,
              onTierSelected: (tier) {
                _loadingTier = tier;
                final box = Hive.isBoxOpen(StorageKeys.userData)
                    ? Hive.box<dynamic>(StorageKeys.userData)
                    : null;
                box?.put('level_prefs_v1', tier.name);
                box?.put(
                  'word_progress_v1',
                  {
                    'completedWords': <String>[],
                    'currentTier': tier.name,
                    'wordLessonHistory': <String>[],
                    'perfectLessonCount': 0,
                    'wordActivityDates': <String>[],
                  },
                );
              },
              onFinished: () {
                if (!mounted) return;
                if (_loadingTier != null) {
                  final box = Hive.isBoxOpen(StorageKeys.userData)
                      ? Hive.box<dynamic>(StorageKeys.userData)
                      : null;
                  box?.put(
                    'learner_profile_v1',
                    {
                      'start': _loadingTier!.name,
                      'onboardingComplete': true,
                    },
                  );
                }
                setState(() => _showLoading = false);
              },
            )
          : ref.watch(learnerProfileProvider).onboardingComplete
          ? const AppShell()
          : const WelcomeJourneyView(),
    );
  }
}

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _selectedIndex = 0;
  Timer? _syncDebounce;
  Timer? _boardDebounce;

  @override
  void initState() {
    super.initState();
    AppNavigation.goTo = _selectPage;
    ref.listenManual(progressProvider, (_, _) => _scheduleSync());
    ref.listenManual(handwritingHistoryProvider, (_, _) => _scheduleSync());
    ref.listenManual(unlockedAchievementsProvider, (previous, next) {
      if (previous?.length == next.length) return;
      _scheduleBoardSync(next.length);
    });
  }

  @override
  void dispose() {
    _syncDebounce?.cancel();
    _boardDebounce?.cancel();
    if (AppNavigation.goTo == _selectPage) AppNavigation.goTo = null;
    super.dispose();
  }

  void _selectPage(int value) => setState(() => _selectedIndex = value);

  void _scheduleSync() {
    _syncDebounce?.cancel();
    _syncDebounce = Timer(const Duration(seconds: 3), () {
      ref.read(syncProvider.notifier).syncNow();
    });
  }

  /// Quietly refreshes the learner's public achievement count whenever it
  /// changes — only for adults who explicitly joined the cosy board. The
  /// board shows nickname, count and XP; email is never shared.
  void _scheduleBoardSync(int achievementCount) {
    final prefs = ref.read(leaderboardPrefsProvider);
    const cloud = CloudService();
    if (!prefs.optIn ||
        prefs.nickname.trim().length < 2 ||
        !cloud.isConfigured ||
        cloud.currentUser == null) {
      return;
    }
    _boardDebounce?.cancel();
    _boardDebounce = Timer(const Duration(seconds: 5), () async {
      try {
        await cloud.updatePublicProfile(
          displayName: prefs.nickname,
          leaderboardOptIn: true,
          achievementCount: achievementCount,
          xp: ref.read(progressProvider).xp,
        );
      } catch (_) {
        // The board is a gentle extra; learning is never blocked by it.
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(experienceProvider);
    final pages = <Widget>[
      const DashboardView(),
      const LearningHubView(),
      const SnapGradeView(),
      const WritingCanvasView(),
      const PassportView(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Image.asset(
                'assets/branding/leo-face-icon.png',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                semanticLabel: 'Leo',
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LinguaTomo',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  'Japanese, with a friend',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Account and sync',
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const AccountView())),
            icon: Icon(
              ref.watch(syncProvider).status == SyncStatus.synced
                  ? Icons.cloud_done_rounded
                  : Icons.cloud_outlined,
            ),
          ),
          IconButton(
            tooltip: 'Experience: ${mode.label}',
            onPressed: () => _showExperienceSettings(context),
            icon: const Icon(Icons.accessibility_new_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            // Hidden tabs keep their state but pause their animations, so
            // the Nest's gentle weather never drains the battery elsewhere.
            for (var index = 0; index < pages.length; index++)
              TickerMode(
                enabled: index == _selectedIndex,
                child: pages[index],
              ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectPage,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Nest',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school_rounded),
            label: 'Learn',
          ),
          NavigationDestination(
            icon: Icon(Icons.camera_alt_outlined),
            selectedIcon: Icon(Icons.camera_alt_rounded),
            label: 'Snap',
          ),
          NavigationDestination(
            icon: Icon(Icons.draw_outlined),
            selectedIcon: Icon(Icons.draw_rounded),
            label: 'Write',
          ),
          NavigationDestination(
            icon: Icon(Icons.badge_outlined),
            selectedIcon: Icon(Icons.badge_rounded),
            label: 'Passport',
          ),
        ],
      ),
    );
  }

  void _showExperienceSettings(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 600),
      builder: (context) {
        final selected = ref.read(experienceProvider);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Choose your experience',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Text(
                  'This changes presentation, never access to learning.',
                ),
                const SizedBox(height: 12),
                for (final mode in ExperienceMode.values)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: RadioListTile<ExperienceMode>(
                      value: mode,
                      // ignore: deprecated_member_use
                      groupValue: selected,
                      // ignore: deprecated_member_use
                      onChanged: (value) {
                        if (value == null) return;
                        ref.read(experienceProvider.notifier).setMode(value);
                        Navigator.pop(context);
                      },
                      title: Text(
                        mode.label,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(mode.description),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
