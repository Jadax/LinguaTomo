import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/curriculum_data.dart';
import '../data/achievement_data.dart';
import '../data/festival_calendar_data.dart';
import '../data/word_bank.dart';
import '../data/conversation_data.dart';
import '../models/app_models.dart';
import '../providers/achievement_state.dart';
import '../providers/app_state.dart';
import '../providers/festival_state.dart';
import '../providers/review_state.dart';
import '../providers/grammar_state.dart';
import '../providers/word_progress_state.dart';
import '../providers/level_prefs_state.dart';
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
                      _greetingForTier(wordProgress),
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
          if (!wordProgress.postcardsUnlocked) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Wrap(
                spacing: 12,
                children: [
                  const Text(
                    '💌 10 words to unlock postcards',
                    style: TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                  Text(
                    '📖 20 for stories',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.muted.withValues(alpha: .7),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          _LevelPickerCard(wordProgress: wordProgress),
          const SizedBox(height: 12),
          if (wordProgress.wordsLearned >= 10) ...[
            _NextCanDoCard(),
            const SizedBox(height: 12),
          ],
          if (wordProgress.memoryGardenUnlocked) ...[
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
          ] else ...[
            Card(
              margin: EdgeInsets.zero,
              color: AppColors.bambooMist.withValues(alpha: .4),
              child: const ListTile(
                minTileHeight: 68,
                leading: CircleAvatar(
                  backgroundColor: AppColors.bambooMist,
                  child: Icon(Icons.lock_rounded, color: AppColors.muted),
                ),
                title: Text(
                  'Memory Garden',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(
                  'Unlocks after 5 words learned',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
                enabled: false,
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (wordProgress.wordsLearned >= 20) ...[
            const _SeasonalEventCard(),
            const SizedBox(height: 12),
          ],
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

class _NextCanDoCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mission = ref.watch(nextMissionProvider);
    if (mission == null) return const SizedBox.shrink();
    return Card(
      color: const Color(0xFFE8F5E9),
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ReviewView()),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Text('🎯', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NEXT CAN-DO',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    Text(
                      mission.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      mission.phrase,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.muted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 16, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryBuckets extends StatelessWidget {
  const _CategoryBuckets({required this.wordProgress});
  final WordProgress wordProgress;

  static const _colours = [
    Color(0xFFFFF0E8), // persimmon tint
    Color(0xFFF0F4FF), // blue tint
    Color(0xFFE8F5E9), // green tint
    Color(0xFFFFF3E0), // amber tint
    Color(0xFFF3E5F5), // purple tint
    Color(0xFFFFFDE7), // yellow tint
    Color(0xFFE0F7FA), // cyan tint
    Color(0xFFFFE0E0), // pink tint
  ];

  @override
  Widget build(BuildContext context) {
    final cats = WordCategory.values;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.55,
      ),
      itemCount: cats.length,
      itemBuilder: (context, index) {
        final cat = cats[index];
        final completed =
            wordProgress.categoryProgress(cat, wordProgress.currentTier);
        final total = wordBank
            .where((w) =>
                w.category == cat && w.tier == wordProgress.currentTier)
            .length;
        final pct = total > 0 ? completed / total : 0.0;
        final colour = _colours[index % _colours.length];
        return Card(
          color: colour,
          margin: EdgeInsets.zero,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => WordLessonView(
                  filterCategory: cat,
                  filterTier: wordProgress.currentTier,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(cat.emoji, style: const TextStyle(fontSize: 34)),
                  const SizedBox(height: 6),
                  Text(
                    cat.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 8,
                      backgroundColor: colour.withValues(alpha: .6),
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.matcha,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$completed of $total words',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ConversationCard extends StatelessWidget {
  const _ConversationCard({required this.wordProgress});
  final WordProgress wordProgress;

  @override
  Widget build(BuildContext context) {
    final tier = wordProgress.currentTier;
    final available = conversationPairs
        .where((c) => c.tier.index <= tier.index)
        .toList();
    if (available.isEmpty) return const SizedBox.shrink();
    final pair = available[DateTime.now().day % available.length];
    return Card(
      color: const Color(0xFFF3E5F5),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('💬', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'DAILY CONVERSATION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      color: Color(0xFF7B1FA2),
                    ),
                  ),
                ),
                Text(
                  tier.label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              pair.question,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            Text(
              pair.questionRomaji,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.muted,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              pair.answer,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.muted,
              ),
            ),
            Text(
              pair.answerRomaji,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.muted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

abstract final class AppNavigation {
  static ValueChanged<int>? goTo;
}

String _greetingForTier(WordProgress wp) {
  if (wp.wordsLearned == 0) return 'Welcome home';
  if (wp.wordsLearned < 20) return 'Nice start!';
  if (wp.wordsLearned < 50) return 'Great progress!';
  if (wp.wordsLearned < 100) return 'You are on a roll!';
  if (wp.wordsLearned < 150) return 'Impressive work!';
  return 'Word master!';
}

class _LevelPickerCard extends ConsumerWidget {
  const _LevelPickerCard({required this.wordProgress});
  final WordProgress wordProgress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(levelPrefsProvider);
    return Card(
      margin: EdgeInsets.zero,
      color: const Color(0xFFF0F4FF),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showLevelPicker(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6E4FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.signal_cellular_alt_rounded,
                  color: Color(0xFF4A6FA5),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'YOUR LEVEL',
                      style: TextStyle(
                        color: Color(0xFF4A6FA5),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      '${current.label} tier',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      current.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.swap_horiz_rounded,
                color: AppColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLevelPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 600),
      builder: (context) {
        final selected = ref.read(levelPrefsProvider);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Choose your level',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Text(
                  'This changes which words you practise. You can switch at any time.',
          ),
          const SizedBox(height: 12),
          _CategoryBuckets(wordProgress: wordProgress),
          const SizedBox(height: 12),
          _ConversationCard(wordProgress: wordProgress),
          const SizedBox(height: 12),
                for (final tier in DifficultyTier.values)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: RadioListTile<DifficultyTier>(
                      value: tier,
                      // ignore: deprecated_member_use
                      groupValue: selected,
                      // ignore: deprecated_member_use
                      onChanged: (value) {
                        if (value == null) return;
                        ref
                            .read(levelPrefsProvider.notifier)
                            .setLevel(value);
                        ref
                            .read(wordProgressProvider.notifier)
                            .setTier(value);
                        Navigator.pop(context);
                      },
                      title: Text(
                        tier.label,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(tier.description),
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
    // Leo shows little personality bursts every so often.
    _reactionTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (!mounted || widget.reduceMotion || _walking) return;
      setState(() {
        _reaction = _reactionPoses[_reactionIndex % _reactionPoses.length];
        _reactionIndex++;
      });
      Timer(const Duration(milliseconds: 2000), () {
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
    // Brief greeting before walking
    setState(() {
      _reaction = LeoPose.smile;
      _walking = false;
    });
    Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _reaction = null;
        _walking = true;
        _step = !_step;
        _atChair = !_atChair;
      });
      _timer = Timer.periodic(const Duration(milliseconds: 180), (timer) {
        if (!mounted || timer.tick >= 5) {
          timer.cancel();
          if (mounted) setState(() => _walking = false);
          return;
        }
        setState(() => _step = !_step);
      });
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
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 1.0, end: _reaction != null ? 1.08 : 1.0),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) => Transform.scale(
                      scale: value,
                      child: child,
                    ),
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
        onTap: () => _showThemePicker(context, wordProgress),
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
                      'PICK A THEME',
                      style: TextStyle(
                        color: AppColors.persimmon,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      '$tierProgress of $tierTotal words learned',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
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

  void _showThemePicker(BuildContext context, WordProgress wp) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 600),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Choose a theme', style: Theme.of(ctx).textTheme.headlineSmall),
              const SizedBox(height: 2),
              Text('Pick what you want to learn about today.',
                  style: const TextStyle(color: AppColors.muted)),
              const SizedBox(height: 14),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.7,
                ),
                itemCount: WordCategory.values.length,
                itemBuilder: (ctx, i) {
                  final cat = WordCategory.values[i];
                  final done = wp.categoryProgress(cat, wp.currentTier);
                  final tot = wordBank
                      .where((w) => w.category == cat && w.tier == wp.currentTier)
                      .length;
                  final pct = tot > 0 ? done / tot : 0.0;
                  return Card(
                    color: _colours[i % _colours.length],
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => WordLessonView(
                            filterCategory: cat,
                            filterTier: wp.currentTier,
                          ),
                        ));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(cat.emoji, style: const TextStyle(fontSize: 32)),
                            const SizedBox(height: 4),
                            Text(cat.label, textAlign: TextAlign.center,
                                maxLines: 2, overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, height: 1.15)),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: pct, minHeight: 6,
                                valueColor: const AlwaysStoppedAnimation(AppColors.matcha),
                                backgroundColor: const Color(0xFFE0E0E0),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text('$done of $tot', style: const TextStyle(fontSize: 10, color: AppColors.muted)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const _colours = [
    Color(0xFFFFF0E8), Color(0xFFF0F4FF), Color(0xFFE8F5E9),
    Color(0xFFFFF3E0), Color(0xFFF3E5F5), Color(0xFFFFFDE7),
    Color(0xFFE0F7FA), Color(0xFFFFE0E0),
  ];
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
