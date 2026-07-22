import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/achievement_data.dart';
import '../data/curriculum_data.dart';
import '../models/app_models.dart';
import '../providers/achievement_state.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class CollectionView extends ConsumerWidget {
  const CollectionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final selectedEnvironment = ref.watch(nestEnvironmentProvider);
    final placedIds = ref.watch(nestDisplayProvider);
    final snapshot = ref.watch(achievementSnapshotProvider);
    final unlockedCount = achievements
        .where((item) => item.unlocked(snapshot))
        .length;
    final placeableItems = <({String id, String emoji, String label})>[
      for (final mission in missions)
        if (progress.unlockedRewards.contains(mission.reward))
          (
            id: 'mission:${mission.id}',
            emoji: mission.rewardEmoji,
            label: mission.reward,
          ),
      for (final achievement in achievements)
        if (achievement.rewardType == AchievementRewardType.nestItem &&
            achievement.unlocked(snapshot))
          (
            id: 'achievement:${achievement.id}',
            emoji: achievement.emoji,
            label: achievement.reward,
          ),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Nest Collection')),
      body: ResponsiveContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Your cosy world',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              '$unlockedCount of ${achievements.length} memories found. Every reward comes from learning, never spending.',
            ),
            const SizedBox(height: 18),
            Text(
              'Choose Leo’s Nest',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            const Text(
              'Rooms provide space. Achievements add small objects, reactions, stamps and profile styles without making the Nest cluttered.',
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 154,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: NestEnvironment.values.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final environment = NestEnvironment.values[index];
                  final unlocked = _environmentUnlocked(
                    environment,
                    progress,
                    unlockedCount,
                  );
                  return _EnvironmentCard(
                    environment: environment,
                    unlocked: unlocked,
                    selected: environment == selectedEnvironment,
                    onTap: unlocked
                        ? () => ref
                              .read(nestEnvironmentProvider.notifier)
                              .choose(environment)
                        : null,
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Placeable memories',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  '${placedIds.length}/${NestDisplayNotifier.maxItems} placed',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.matcha,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Choose up to twelve small objects. Everything else stays safely in your collection, and trophies sit on their own shelf.',
            ),
            const SizedBox(height: 9),
            if (placeableItems.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Text(
                    'Complete your first Can-Do to unlock a placeable Nest memory.',
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final item in placeableItems)
                    FilterChip(
                      selected: placedIds.contains(item.id),
                      avatar: Text(item.emoji),
                      label: Text(item.label),
                      onSelected: (_) async {
                        final changed = await ref
                            .read(nestDisplayProvider.notifier)
                            .toggle(item.id);
                        if (!changed && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Your Nest has twelve display spaces. Remove one item before adding another.',
                              ),
                            ),
                          );
                        }
                      },
                    ),
                ],
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Achievement memories',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  '$unlockedCount/${achievements.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.matcha,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Some memories stay mysterious until you are close. Tap any card to see its reward type.',
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: achievements.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 180,
                mainAxisExtent: 168,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) => _AchievementCard(
                achievement: achievements[index],
                snapshot: snapshot,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

bool _environmentUnlocked(
  NestEnvironment environment,
  LearnerProgress progress,
  int unlockedAchievements,
) {
  final japanMonth = DateTime.now().toUtc().add(const Duration(hours: 9)).month;
  return switch (environment) {
    NestEnvironment.fireside => true,
    NestEnvironment.springVeranda =>
      progress.completedPostcards.length >= 3 ||
          japanMonth >= 3 && japanMonth <= 5,
    NestEnvironment.nightTrain =>
      progress.stage.index >= ProficiencyStage.dailyLife.index,
    NestEnvironment.snowLodge =>
      progress.streak >= 7 || japanMonth == 12 || japanMonth <= 2,
    NestEnvironment.japanHome =>
      progress.stage.index >= ProficiencyStage.connected.index,
    NestEnvironment.rainyLibrary =>
      unlockedAchievements >= 5 || japanMonth == 6,
  };
}

class _EnvironmentCard extends StatelessWidget {
  const _EnvironmentCard({
    required this.environment,
    required this.unlocked,
    required this.selected,
    required this.onTap,
  });

  final NestEnvironment environment;
  final bool unlocked;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 205,
    child: Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      color: selected ? AppColors.bambooMist : Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    environment.asset,
                    fit: BoxFit.cover,
                    color: unlocked ? null : Colors.grey,
                    colorBlendMode: unlocked ? null : BlendMode.saturation,
                  ),
                  if (!unlocked)
                    Container(color: Colors.white.withValues(alpha: .38)),
                  if (!unlocked)
                    const Center(
                      child: Icon(
                        Icons.lock_rounded,
                        color: AppColors.charcoal,
                      ),
                    ),
                  if (selected)
                    const Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        radius: 13,
                        backgroundColor: AppColors.matcha,
                        child: Icon(
                          Icons.check_rounded,
                          size: 17,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Text(
                environment.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.achievement, required this.snapshot});

  final AchievementDefinition achievement;
  final AchievementSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.unlocked(snapshot);
    final current = achievement.progress(snapshot).clamp(0, achievement.target);
    final hidden = achievement.secret && !unlocked;
    final fraction = achievement.target == 0
        ? 0.0
        : current / achievement.target;
    // Locked memories blur away: untouched goals are only a soft shadow,
    // and the picture clears as the learner gets closer.
    final undiscovered = !unlocked && !hidden && fraction == 0;
    final blur = unlocked
        ? 0.0
        : hidden
        ? 3.0
        : (4.5 * (1 - fraction) + 1.5).clamp(1.5, 6.0);
    return Semantics(
      button: true,
      label:
          '${hidden || undiscovered ? 'Hidden achievement' : achievement.title}, ${unlocked ? 'unlocked' : 'locked'}',
      child: Card(
        margin: EdgeInsets.zero,
        color: unlocked ? AppColors.bambooMist : const Color(0xFFE8E6E2),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showAchievement(context, unlocked, hidden, fraction),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                SizedBox(
                  height: 40,
                  child: Center(
                    child: ImageFiltered(
                      imageFilter: ui.ImageFilter.blur(
                        sigmaX: blur,
                        sigmaY: blur,
                      ),
                      child: Opacity(
                        opacity: unlocked ? 1 : .72,
                        child: Text(
                          hidden ? '🌙' : achievement.emoji,
                          style: const TextStyle(fontSize: 30),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 36,
                  child: Center(
                    child: Text(
                      hidden
                          ? 'Secret memory'
                          : undiscovered
                          ? 'Hidden memory'
                          : achievement.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                LinearProgressIndicator(
                  value: fraction,
                  minHeight: 6,
                ),
                const SizedBox(height: 5),
                Text(
                  unlocked
                      ? rewardTypeLabel(achievement.rewardType)
                      : hidden
                      ? 'Keep exploring'
                      : undiscovered
                      ? 'Not yet discovered'
                      : '$current / ${achievement.target}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAchievement(
    BuildContext context,
    bool unlocked,
    bool hidden,
    double fraction,
  ) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              unlocked || (!hidden && fraction > 0)
                  ? achievement.emoji
                  : hidden
                  ? '🌙'
                  : '✨',
              style: const TextStyle(fontSize: 52),
            ),
            const SizedBox(height: 8),
            Text(
              hidden
                  ? 'A secret memory'
                  : !unlocked && fraction == 0
                  ? 'A hidden memory'
                  : achievement.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              hidden
                  ? 'Leo will reveal this when your learning path reaches the right moment.'
                  : !unlocked && fraction == 0
                  ? 'Something cosy is waiting here. Keep learning and it will slowly come into focus.'
                  : achievement.requirement,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Chip(
              label: Text('${rewardTypeLabel(achievement.rewardType)} reward'),
            ),
            const SizedBox(height: 6),
            Text(
              unlocked
                  ? achievement.reward
                  : 'The exact reward is revealed when unlocked.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    ),
  );
}
