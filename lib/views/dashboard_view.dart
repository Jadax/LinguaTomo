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
import '../providers/leo_mood_state.dart';
import '../providers/seasonal_state.dart';
import '../providers/weekly_challenge_state.dart';
import '../services/speech_service.dart';
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
          _DailyXpGoal(wordProgress: wordProgress),
          const SizedBox(height: 10),
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
          const SizedBox(height: 6),
          _LeoMoodGreeting(),
          const SizedBox(height: 10),
          _TrophyShelf(unlocked: unlockedTrophies, total: trophies.length),
          const SizedBox(height: 14),
          _ContinueLearningCard(wordProgress: wordProgress),
          const SizedBox(height: 12),
          if (wordProgress.wordsLearned > 0) ...[
            _WordGardenSummary(wordProgress: wordProgress),
            const SizedBox(height: 12),
            _WordReviewSummary(wordProgress: wordProgress),
            const SizedBox(height: 12),
            const _SeasonalCard(),
            const SizedBox(height: 12),
            const _WeeklyChallengeCard(),
            const SizedBox(height: 12),
          ],
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
          _ConversationCard(wordProgress: wordProgress),
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
                  onTap: () => AppNavigation.goTo?.call(3),
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
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ReviewView())),
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
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConversationCard extends StatelessWidget {
  const _ConversationCard({required this.wordProgress});
  final WordProgress wordProgress;

  void _showConversation(BuildContext context, ConversationPair pair) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Text(pair.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            const Text('Daily conversation'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pair.question,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                pair.questionRomaji,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.muted,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              Text(pair.answer, style: const TextStyle(fontSize: 16)),
              Text(
                pair.answerRomaji,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.muted,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: () {
                      final s = SpeechService();
                      s.speakJapanese(pair.question);
                    },
                    icon: const Icon(Icons.volume_up_rounded, size: 18),
                    label: const Text('Hear question'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      final s = SpeechService();
                      s.speakJapanese(pair.answer);
                    },
                    icon: const Icon(Icons.volume_up_rounded, size: 18),
                    label: const Text('Hear answer'),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

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
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showConversation(context, pair),
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
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
                style: const TextStyle(fontSize: 15, color: AppColors.muted),
              ),
              Text(
                pair.answerRomaji,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.muted,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tap to listen & practise →',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF7B1FA2),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
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
              const Icon(Icons.swap_horiz_rounded, color: AppColors.muted),
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
                const SizedBox(height: 4),
                const Text(
                  'This changes which words you practise. You can switch at any time.',
                ),
                const SizedBox(height: 16),
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
                        ref.read(levelPrefsProvider.notifier).setLevel(value);
                        ref.read(wordProgressProvider.notifier).setTier(value);
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
                    tween: Tween(
                      begin: 1.0,
                      end: _reaction != null ? 1.08 : 1.0,
                    ),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) =>
                        Transform.scale(scale: value, child: child),
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

class _WeeklyChallengeCard extends ConsumerWidget {
  const _WeeklyChallengeCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challenge = ref.watch(weeklyChallengeProvider);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${challenge.challengeType.emoji} Weekly Challenge',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const Spacer(),
                if (challenge.completed)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.matcha.withValues(alpha: .15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Complete',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.matcha,
                      ),
                    ),
                  )
                else
                  Text(
                    '${challenge.daysRemaining}d left',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.persimmon,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              challenge.challengeType.label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              challenge.challengeType.description,
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.local_fire_department_rounded,
                  size: 16,
                  color: AppColors.persimmon,
                ),
                const SizedBox(width: 4),
                Text(
                  '${challenge.streakWeeks} week streak',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.emoji_events_rounded,
                  size: 16,
                  color: AppColors.persimmon,
                ),
                const SizedBox(width: 4),
                Text(
                  'Best: ${challenge.bestScore}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
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
    Future.microtask(
      () => ref.read(festivalMemoryProvider.notifier).markToday(),
    );
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
    final categories = WordCategory.values.where((cat) {
      return wordBank.any((w) => w.category == cat && w.tier == wp.currentTier);
    }).toList();
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 500),
      builder: (ctx) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.8,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${wp.currentTier.label} themes',
                  style: Theme.of(
                    ctx,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  'Words at your level. Pick what you want to learn today.',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (var i = 0; i < categories.length; i++)
                          _buildThemeChip(
                            context: ctx,
                            cat: categories[i],
                            colour: _colours[i % _colours.length],
                            done: wp.categoryProgress(
                              categories[i],
                              wp.currentTier,
                            ),
                            total: wordsForCategoryAndTier(
                              categories[i],
                              wp.currentTier,
                            ).length,
                            onTap: () {
                              Navigator.pop(ctx);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => WordLessonView(
                                    filterCategory: categories[i],
                                    filterTier: wp.currentTier,
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeChip({
    required BuildContext context,
    required WordCategory cat,
    required Color colour,
    required int done,
    required int total,
    required VoidCallback onTap,
  }) {
    final pct = total > 0 ? done / total : 0.0;
    return SizedBox(
      width: ((MediaQuery.of(context).size.width.clamp(280, 500) - 40) / 2),
      child: Card(
        color: colour,
        margin: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Text(cat.emoji, style: const TextStyle(fontSize: 26)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cat.label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 5,
                          valueColor: const AlwaysStoppedAnimation(
                            AppColors.matcha,
                          ),
                          backgroundColor: const Color(0xFFE0E0E0),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const _colours = [
    Color(0xFFFFF0E8),
    Color(0xFFF0F4FF),
    Color(0xFFE8F5E9),
    Color(0xFFFFF3E0),
    Color(0xFFF3E5F5),
    Color(0xFFFFFDE7),
    Color(0xFFE0F7FA),
    Color(0xFFFFE0E0),
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

class _LeoMoodGreeting extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mood = ref.watch(leoMoodProvider);
    final color = switch (mood) {
      LeoMood.excited => AppColors.persimmon,
      LeoMood.proud => AppColors.matcha,
      LeoMood.sleepy => AppColors.muted,
      LeoMood.curious => AppColors.teal,
      LeoMood.playful => AppColors.persimmon,
      LeoMood.encouraging => AppColors.matcha,
      LeoMood.cozy => AppColors.charcoal,
    };
    return Card(
      margin: EdgeInsets.zero,
      color: color.withValues(alpha: .08),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            LeoSprite(
              pose: switch (mood) {
                LeoMood.excited => LeoPose.celebrate,
                LeoMood.proud => LeoPose.celebrate,
                LeoMood.sleepy => LeoPose.sit,
                LeoMood.curious => LeoPose.smile,
                LeoMood.playful => LeoPose.butterfly,
                LeoMood.encouraging => LeoPose.smile,
                LeoMood.cozy => LeoPose.smile,
              },
              size: 44,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Leo is ${mood.label.toLowerCase()}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(mood.greeting, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WordGardenSummary extends StatelessWidget {
  const _WordGardenSummary({required this.wordProgress});
  final WordProgress wordProgress;

  @override
  Widget build(BuildContext context) {
    final counts = <WordGrowthStage, int>{};
    for (final stage in WordGrowthStage.values) {
      counts[stage] = 0;
    }
    for (final entry in wordProgress.wordCorrectCounts.entries) {
      final count = entry.value;
      final stage = count >= 5
          ? WordGrowthStage.bloom
          : count >= 3
          ? WordGrowthStage.bud
          : count >= 1
          ? WordGrowthStage.sprout
          : WordGrowthStage.seed;
      counts[stage] = (counts[stage] ?? 0) + 1;
    }
    final learned = wordProgress.wordsLearned;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Word Garden',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const Spacer(),
                Text(
                  '$learned word${learned == 1 ? '' : 's'} planted',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (final stage in WordGrowthStage.values)
                  _GrowthPill(
                    emoji: stage.emoji,
                    label: stage.label,
                    count: counts[stage] ?? 0,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WordReviewSummary extends StatelessWidget {
  const _WordReviewSummary({required this.wordProgress});
  final WordProgress wordProgress;

  @override
  Widget build(BuildContext context) {
    final seedCount = wordProgress.wordCorrectCounts.values
        .where((c) => c == 0)
        .length;
    final sproutCount = wordProgress.wordCorrectCounts.values
        .where((c) => c == 1)
        .length;
    final budCount = wordProgress.wordCorrectCounts.values
        .where((c) => c >= 2 && c < 5)
        .length;
    final bloomCount = wordProgress.wordCorrectCounts.values
        .where((c) => c >= 5)
        .length;
    final total = wordProgress.wordsLearned;
    if (total == 0) return const SizedBox.shrink();
    final needsReview = seedCount + sproutCount;
    return Card(
      margin: EdgeInsets.zero,
      color: needsReview > 5
          ? const Color(0xFFFFF3E0)
          : AppColors.bambooMist.withValues(alpha: .4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  needsReview > 5 ? '📖 Review needed' : '✨ Word mastery',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const Spacer(),
                if (needsReview > 0)
                  Text(
                    '$needsReview need${needsReview == 1 ? 's' : ''} review',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.persimmon,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _MiniPill(
                  emoji: '🌱',
                  count: seedCount,
                  label: 'New',
                  color: AppColors.muted,
                ),
                const SizedBox(width: 10),
                _MiniPill(
                  emoji: '🌿',
                  count: sproutCount,
                  label: 'Learning',
                  color: AppColors.persimmon,
                ),
                const SizedBox(width: 10),
                _MiniPill(
                  emoji: '🌸',
                  count: budCount,
                  label: 'Growing',
                  color: AppColors.teal,
                ),
                const SizedBox(width: 10),
                _MiniPill(
                  emoji: '🌺',
                  count: bloomCount,
                  label: 'Mastered',
                  color: AppColors.matcha,
                ),
              ],
            ),
            if (needsReview > 0) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const ReviewView())),
                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                  label: Text(
                    'Review $needsReview word${needsReview == 1 ? '' : 's'}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.persimmon,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({
    required this.emoji,
    required this.count,
    required this.label,
    required this.color,
  });
  final String emoji;
  final int count;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 2),
        Text(
          '$count',
          style: TextStyle(fontWeight: FontWeight.w900, color: color),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: color.withValues(alpha: .8)),
        ),
      ],
    ),
  );
}

class _GrowthPill extends StatelessWidget {
  const _GrowthPill({
    required this.emoji,
    required this.label,
    required this.count,
  });
  final String emoji;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(emoji, style: const TextStyle(fontSize: 24)),
      const SizedBox(height: 4),
      Text('$count', style: const TextStyle(fontWeight: FontWeight.w900)),
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
    ],
  );
}

/// Daily XP goal tracker — motivates consistent practice.
/// Shows progress toward a soft daily target based on word activity.
class _DailyXpGoal extends StatelessWidget {
  const _DailyXpGoal({required this.wordProgress});
  final WordProgress wordProgress;

  static const _dailyGoal = 50;

  @override
  Widget build(BuildContext context) {
    final today = dateKey(DateTime.now());
    final isTodayActive = wordProgress.wordActivityDates.contains(today);
    final lessonsToday = wordProgress.wordLessonHistory
        .where((entry) => entry.split(',').isNotEmpty)
        .length;
    // Rough estimate: 5 words per lesson × 10 XP per word = ~50 per lesson.
    final estimatedTodayXp = isTodayActive
        ? (lessonsToday * 50).clamp(0, _dailyGoal)
        : 0;
    final progress = (estimatedTodayXp / _dailyGoal).clamp(0.0, 1.0);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.flag_rounded,
              size: 20,
              color: progress >= 1.0 ? AppColors.matcha : AppColors.persimmon,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    progress >= 1.0
                        ? 'Daily goal reached!'
                        : 'Daily goal: $_dailyGoal XP',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: AppColors.bambooMist,
                    color: progress >= 1.0
                        ? AppColors.matcha
                        : AppColors.persimmon,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '$estimatedTodayXp/$_dailyGoal',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: progress >= 1.0 ? AppColors.matcha : AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class _SeasonalCard extends ConsumerWidget {
  const _SeasonalCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final season = ref.watch(seasonalProgressProvider);
    final seasonEmoji = switch (season.seasonName) {
      'Winter' => '❄️',
      'Spring' => '🌸',
      'Summer' => '☀️',
      'Autumn' => '🍂',
      _ => '🌱',
    };
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '$seasonEmoji ${season.seasonName} — ${season.monthName}',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const Spacer(),
                if (season.completedSeason)
                  const Icon(
                    Icons.emoji_events_rounded,
                    color: AppColors.persimmon,
                    size: 22,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: season.lessonProgress,
                minHeight: 8,
                backgroundColor: AppColors.bambooMist,
                color: season.completedSeason
                    ? AppColors.persimmon
                    : AppColors.teal,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              season.completedSeason
                  ? 'Season complete! You earned your badge.'
                  : '${season.lessonsCompleted}/${season.targetLessons} active days — $seasonEmoji keep going!',
              style: const TextStyle(fontSize: 12),
            ),
            if (season.activeFestivals.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final festival in season.activeFestivals.take(3))
                    Chip(
                      avatar: Text(festival.emoji),
                      label: Text(
                        festival.englishName,
                        style: const TextStyle(fontSize: 11),
                      ),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
