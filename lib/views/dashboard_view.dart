import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/curriculum_data.dart';
import '../data/achievement_data.dart';
import '../data/festival_calendar_data.dart';
import '../data/word_bank.dart';
import '../models/app_models.dart';
import '../providers/achievement_state.dart';
import '../providers/app_state.dart';
import '../providers/festival_state.dart';
import '../providers/review_state.dart';
import '../providers/grammar_state.dart';
import '../providers/word_progress_state.dart';
import '../theme/app_theme.dart';
import '../widgets/leo_sprite.dart';
import '../widgets/nest_ambience.dart';
import 'collection_view.dart';
import 'postcards_view.dart';
import 'review_view.dart';
import 'seasonal_stories_view.dart';
import 'word_lesson_view.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final environment = ref.watch(nestEnvironmentProvider);
    final mode = ref.watch(experienceProvider);
    final grammar = ref.watch(grammarGardenProvider);
    final dueReviews =
        ref.watch(reviewDeckProvider).dueMissions.length + grammar.dueCount;
    final achievementSnapshot = ref.watch(achievementSnapshotProvider);
    final unlockedNestAchievementIds = achievements
        .where(
          (item) =>
              item.rewardType == AchievementRewardType.nestItem &&
              item.unlocked(achievementSnapshot),
        )
        .map((item) => item.id)
        .toSet();
    final trophies = achievements
        .where((item) => item.rewardType == AchievementRewardType.trophy)
        .toList();
    final unlockedTrophies = trophies
        .where((item) => item.unlocked(achievementSnapshot))
        .toList();
    final reactionsUnlocked = achievements.any(
      (item) =>
          item.rewardType == AchievementRewardType.leoReaction &&
          item.unlocked(achievementSnapshot),
    );
    final placedIds = ref.watch(nestDisplayProvider);
    final wordProgress = ref.watch(wordProgressProvider);
    final placedItems = <String>[
      for (final id in placedIds)
        if (id.startsWith('mission:'))
          ...missions
              .where((mission) => 'mission:${mission.id}' == id)
              .map((mission) => mission.rewardEmoji)
        else if (id.startsWith('achievement:'))
          ...achievements
              .where(
                (item) =>
                    'achievement:${item.id}' == id &&
                    unlockedNestAchievementIds.contains(item.id),
              )
              .map((item) => item.emoji),
    ];
    return ResponsiveContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome home',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      '${wordProgress.wordsLearned} words learned · ${wordProgress.currentTier.label}',
                    ),
                  ],
                ),
              ),
              _StatPill(
                icon: Icons.local_fire_department_rounded,
                value: '${progress.streak}',
                label: 'days',
              ),
              const SizedBox(width: 8),
              _StatPill(
                icon: Icons.auto_awesome_rounded,
                value: '${progress.xp}',
                label: 'XP',
              ),
            ],
          ),
          const SizedBox(height: 14),
          _NestRoom(
            progress: progress,
            environment: environment,
            achievementItems: placedItems,
            reduceMotion: mode == ExperienceMode.comfort,
            reactionsUnlocked: reactionsUnlocked,
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const CollectionView())),
          ),
          const SizedBox(height: 10),
          _TrophyShelf(
            unlocked: unlockedTrophies,
            total: trophies.length,
          ),
          const SizedBox(height: 14),
          _ContinueLearningCard(wordProgress: wordProgress),
          const SizedBox(height: 12),
          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              minTileHeight: 68,
              leading: const CircleAvatar(
                backgroundColor: AppColors.bambooMist,
                child: Icon(Icons.eco_rounded, color: AppColors.matcha),
              ),
              title: const Text(
                'Memory Garden',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text(
                dueReviews == 0
                    ? 'Nothing due. Your memory garden is tidy.'
                    : '$dueReviews gentle review${dueReviews == 1 ? '' : 's'} ready',
              ),
              trailing: IconButton(
                tooltip: 'How the Memory Garden works',
                icon: const Icon(Icons.info_outline_rounded),
                onPressed: () => _showMemoryGardenHelp(context),
              ),
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ReviewView())),
            ),
          ),
          const SizedBox(height: 12),
          const _SeasonalEventCard(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionCard(
                  icon: Icons.camera_alt_rounded,
                  title: 'Snap & Grade',
                  subtitle: 'Check paper writing',
                  color: AppColors.sakura,
                  onTap: () => AppNavigation.goTo?.call(2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionCard(
                  icon: Icons.mark_email_unread_rounded,
                  title: 'Postcard',
                  subtitle: wordProgress.postcardsUnlocked
                      ? '${progress.completedPostcards.length}/${postcards.length} collected'
                      : 'Learn 10 words to unlock',
                  color: wordProgress.postcardsUnlocked
                      ? AppColors.bambooMist
                      : AppColors.bambooMist.withValues(alpha: .5),
                  onTap: wordProgress.postcardsUnlocked
                      ? () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const PostcardsView(),
                          ),
                        )
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Your learning evidence',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _Evidence(
                    value: '${wordProgress.wordsLearned}',
                    label: 'Words',
                  ),
                  _Evidence(
                    value: '${progress.verifiedCanDos}',
                    label: 'Can-Dos',
                  ),
                  _Evidence(
                    value: '${progress.unlockedRewards.length}',
                    label: 'Nest items',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMemoryGardenHelp(BuildContext context) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('How the Memory Garden works'),
      content: const Text(
        'Each learned phrase or grammar pattern becomes a plant. FSRS estimates when that memory is likely to become difficult, then brings it back just before it fades. Again shortens the interval; Hard, Good and Easy lengthen it by different amounts. There is no penalty for returning late, and the garden never dies.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Got it'),
        ),
      ],
    ),
  );
}

abstract final class AppNavigation {
  static ValueChanged<int>? goTo;
}

class _NestRoom extends StatefulWidget {
  const _NestRoom({
    required this.progress,
    required this.environment,
    required this.achievementItems,
    required this.reduceMotion,
    required this.reactionsUnlocked,
    required this.onTap,
  });
  final LearnerProgress progress;
  final NestEnvironment environment;
  final List<String> achievementItems;
  final bool reduceMotion;
  final bool reactionsUnlocked;
  final VoidCallback onTap;

  @override
  State<_NestRoom> createState() => _NestRoomState();
}

class _NestRoomState extends State<_NestRoom> {
  static const _reactionPoses = [
    LeoPose.celebrate,
    LeoPose.meow,
    LeoPose.smile,
    LeoPose.butterfly,
  ];

  Timer? _timer;
  Timer? _reactionTimer;
  var _atChair = false;
  var _walking = false;
  var _step = false;
  LeoPose? _reaction;
  var _reactionIndex = 0;

  @override
  void initState() {
    super.initState();
    // Once the learner has earned a Leo reaction, Leo occasionally shows a
    // little burst of personality while resting in the Nest.
    _reactionTimer = Timer.periodic(const Duration(seconds: 24), (_) {
      if (!mounted ||
          !widget.reactionsUnlocked ||
          widget.reduceMotion ||
          _walking) {
        return;
      }
      setState(() {
        _reaction = _reactionPoses[_reactionIndex % _reactionPoses.length];
        _reactionIndex++;
      });
      Timer(const Duration(milliseconds: 1500), () {
        if (mounted) setState(() => _reaction = null);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _reactionTimer?.cancel();
    super.dispose();
  }

  void _moveLeo() {
    _timer?.cancel();
    if (widget.reduceMotion) {
      setState(() => _atChair = !_atChair);
      return;
    }
    setState(() {
      _walking = true;
      _step = !_step;
      _atChair = !_atChair;
      _reaction = null;
    });
    _timer = Timer.periodic(const Duration(milliseconds: 180), (timer) {
      if (!mounted || timer.tick >= 5) {
        timer.cancel();
        if (mounted) setState(() => _walking = false);
        return;
      }
      setState(() => _step = !_step);
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = 'Leo’s ${widget.environment.label}';
    return Semantics(
      label:
          'Your Nest with ${widget.achievementItems.length} placed memory items',
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: widget.onTap,
        child: Container(
          height: 320,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(widget.environment.asset),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.charcoal.withValues(alpha: .08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: .05),
                        Colors.transparent,
                        Colors.black.withValues(alpha: .24),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: NestAmbience(
                  kind: nestAmbienceFor(japanToday()),
                  reduceMotion: widget.reduceMotion,
                ),
              ),
              for (
                var index = 0;
                index <
                    math.min(
                      widget.achievementItems.length,
                      NestDisplayNotifier.maxItems,
                    );
                index++
              )
                Positioned(
                  left: 16 + (index % 6) * 42,
                  top: 52 + (index ~/ 6) * 42,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .82),
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Text(
                        widget.achievementItems[index],
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ),
              AnimatedAlign(
                duration: widget.reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 900),
                curve: Curves.easeInOut,
                alignment: _atChair
                    ? const Alignment(.64, .48)
                    : const Alignment(-.62, .58),
                child: GestureDetector(
                  onTap: _moveLeo,
                  child: LeoSprite(
                    pose: _walking
                        ? (_step ? LeoPose.walkA : LeoPose.walkB)
                        : (_reaction ??
                              (_atChair ? LeoPose.sit : LeoPose.idle)),
                    size: _atChair ? 158 : 142,
                    semanticLabel:
                        'Leo. Tap him to walk between the fireside and his chair.',
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 14,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7E8).withValues(alpha: .92),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 6,
                    ),
                    child: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrophyShelf extends StatelessWidget {
  const _TrophyShelf({required this.unlocked, required this.total});

  final List<AchievementDefinition> unlocked;
  final int total;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    color: const Color(0xFFF6EBDD),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          const Icon(
            Icons.emoji_events_rounded,
            color: Color(0xFFB08945),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Trophy shelf · ${unlocked.length} of $total',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 30,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: total,
                separatorBuilder: (_, _) => const SizedBox(width: 6),
                itemBuilder: (context, index) {
                  if (index < unlocked.length) {
                    return Text(
                      unlocked[index].emoji,
                      style: const TextStyle(fontSize: 22),
                    );
                  }
                  return Icon(
                    Icons.emoji_events_outlined,
                    size: 22,
                    color: AppColors.charcoal.withValues(alpha: .18),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _SeasonalEventCard extends ConsumerStatefulWidget {
  const _SeasonalEventCard();

  @override
  ConsumerState<_SeasonalEventCard> createState() => _SeasonalEventCardState();
}

class _SeasonalEventCardState extends ConsumerState<_SeasonalEventCard> {
  @override
  void initState() {
    super.initState();
    // Quietly remember that the learner experienced today's festival windows.
    Future.microtask(() => ref.read(festivalMemoryProvider.notifier).markToday());
  }

  @override
  Widget build(BuildContext context) {
    final today = japanToday();
    final festivals = festivalCalendar
        .where((event) => event.isCurrent(today))
        .toList();
    final story = SeasonalStoriesView.featured();
    final festival = festivals.isEmpty
        ? null
        : festivals[today.day % festivals.length];
    return Card(
      color: const Color(0xFFFFEAF0),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Text(
              festival?.emoji ?? story.emoji,
              style: const TextStyle(fontSize: 38),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    festival == null
                        ? 'Now in Japan: ${story.title}'
                        : 'Festival season: ${festival.englishName}',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  Text(
                    festival == null
                        ? story.description
                        : '${festival.japaneseName} · ${festival.dateWindow}. Being here during a festival adds to your festival memories.',
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SeasonalStoriesView()),
              ),
              child: const Text('Explore'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContinueLearningCard extends StatelessWidget {
  const _ContinueLearningCard({required this.wordProgress});
  final WordProgress wordProgress;

  @override
  Widget build(BuildContext context) {
    final tierProgress = wordProgress.tierProgress(wordProgress.currentTier);
    final tierTotal = wordsForTier(wordProgress.currentTier).length;
    return Card(
      color: const Color(0xFFFFF0E8),
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const WordLessonView())),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.persimmon,
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: Text(
                  wordProgress.currentTier == DifficultyTier.starter
                      ? '📖'
                      : wordProgress.currentTier == DifficultyTier.elementary
                          ? '📚'
                          : wordProgress.currentTier == DifficultyTier.intermediate
                              ? '🎓'
                              : wordProgress.currentTier == DifficultyTier.advanced
                                  ? '🌟'
                                  : '🏆',
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CONTINUE LEARNING',
                      style: TextStyle(
                        color: AppColors.persimmon,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      '${wordProgress.currentTier.label} tier · $tierProgress/$tierTotal words',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: tierTotal > 0 ? tierProgress / tierTotal : 0,
                      minHeight: 6,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Card(
    color: color,
    margin: EdgeInsets.zero,
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            Text(subtitle, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    ),
  );
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Icon(icon, size: 18, color: AppColors.persimmon),
        const SizedBox(width: 4),
        Text(
          '$value $label',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
        ),
      ],
    ),
  );
}

class _Evidence extends StatelessWidget {
  const _Evidence({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(color: AppColors.matcha),
      ),
      Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
    ],
  );
}
