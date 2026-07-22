import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/curriculum_data.dart';
import '../models/app_models.dart';
import '../providers/app_state.dart';
import '../providers/grammar_state.dart';
import '../theme/app_theme.dart';

class CollectionView extends ConsumerWidget {
  const CollectionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final handwriting = ref.watch(handwritingHistoryProvider);
    final grammar = ref.watch(grammarGardenProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Nest Collection')),
      body: ResponsiveContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Every object holds a memory',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            const Text(
              'Nest items come from abilities you demonstrated, not random purchases.',
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: missions.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.2,
              ),
              itemBuilder: (context, index) {
                final mission = missions[index];
                final unlocked = progress.unlockedRewards.contains(
                  mission.reward,
                );
                return Card(
                  margin: EdgeInsets.zero,
                  color: unlocked ? Colors.white : const Color(0xFFE8E6E2),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          unlocked ? mission.rewardEmoji : '🔒',
                          style: const TextStyle(fontSize: 38),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          mission.reward,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        Text(
                          unlocked
                              ? mission.district
                              : 'Complete “${mission.title}”',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 18),
            Text(
              'Milestone badges',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _Badge(
                  emoji: '🐾',
                  title: 'First Steps',
                  unlocked: progress.completedMissions.isNotEmpty,
                ),
                _Badge(
                  emoji: '🏡',
                  title: 'Nest Builder',
                  unlocked: progress.unlockedRewards.length >= 5,
                ),
                _Badge(
                  emoji: '✍️',
                  title: 'Paper Practice',
                  unlocked: handwriting.isNotEmpty,
                ),
                _Badge(
                  emoji: '🗾',
                  title: 'Postcard Friend',
                  unlocked: progress.completedPostcards.length >= 3,
                ),
                _Badge(
                  emoji: '🗺️',
                  title: 'Seven Stops',
                  unlocked: progress.completedPostcards.length >= 7,
                ),
                _Badge(
                  emoji: '🎒',
                  title: 'Postcard Traveller',
                  unlocked: progress.completedPostcards.length >= 12,
                ),
                _Badge(
                  emoji: '🌱',
                  title: 'Memory Seedling',
                  unlocked: progress.completedMissions.length >= 3,
                ),
                _Badge(
                  emoji: '🌳',
                  title: 'Memory Grove',
                  unlocked: progress.completedMissions.length >= 10,
                ),
                _Badge(
                  emoji: '🖌️',
                  title: 'Steady Hand',
                  unlocked: handwriting.any((item) => item.score >= 80),
                ),
                _Badge(
                  emoji: '💯',
                  title: 'Hundred Marks',
                  unlocked: handwriting.length >= 100,
                ),
                _Badge(
                  emoji: '🔥',
                  title: 'Cosy Week',
                  unlocked: progress.streak >= 7,
                ),
                _Badge(
                  emoji: '🏮',
                  title: 'Culture Friend',
                  unlocked:
                      (progress.skillEvidence[SkillArea.culture] ?? 0) >= 3,
                ),
                _Badge(
                  emoji: '💬',
                  title: 'Conversation Keeper',
                  unlocked:
                      (progress.skillEvidence[SkillArea.interaction] ?? 0) >= 6,
                ),
                _Badge(
                  emoji: '🎓',
                  title: 'Professional Route',
                  unlocked: progress.stage == ProficiencyStage.professional,
                ),
                _Badge(
                  emoji: '🔖',
                  title: 'Curious Reader',
                  unlocked: grammar.bookmarks.isNotEmpty,
                ),
                _Badge(
                  emoji: '🌿',
                  title: 'Grammar Patch',
                  unlocked: grammar.cards.length >= 10,
                ),
                _Badge(
                  emoji: '🪴',
                  title: 'Grammar Keeper',
                  unlocked: grammar.cards.length >= 50,
                ),
                _Badge(
                  emoji: '🌺',
                  title: 'Pattern Garden',
                  unlocked: grammar.cards.length >= 100,
                ),
                _Badge(
                  emoji: '🌲',
                  title: 'Grammar Forest',
                  unlocked: grammar.cards.length >= 250,
                ),
                _Badge(
                  emoji: '🏞️',
                  title: 'Living Language',
                  unlocked: grammar.cards.length >= 500,
                ),
                _Badge(
                  emoji: '🗻',
                  title: 'All 828',
                  unlocked: grammar.cards.length >= 828,
                ),
                _Badge(
                  emoji: '🐈',
                  title: 'Leo’s Study Pal',
                  unlocked: grammar.reviewCount >= 25,
                ),
                _Badge(
                  emoji: '🍵',
                  title: 'Calm Reviewer',
                  unlocked: grammar.reviewCount >= 100,
                ),
                _Badge(
                  emoji: '✨',
                  title: 'Memory Glow',
                  unlocked: grammar.reviewCount >= 500,
                ),
                _Badge(
                  emoji: '🌟',
                  title: 'Memory Master',
                  unlocked: grammar.reviewCount >= 2000,
                ),
                _Badge(
                  emoji: '🧭',
                  title: 'Thirty Postcards',
                  unlocked: progress.completedPostcards.length >= 30,
                ),
                _Badge(
                  emoji: '🧶',
                  title: 'Cosy Month',
                  unlocked: progress.streak >= 30,
                ),
                _Badge(
                  emoji: '🛋️',
                  title: 'Full Nest',
                  unlocked: progress.unlockedRewards.length >= missions.length,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.emoji,
    required this.title,
    required this.unlocked,
  });
  final String emoji;
  final String title;
  final bool unlocked;
  @override
  Widget build(BuildContext context) => Container(
    width: 122,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: unlocked ? AppColors.bambooMist : const Color(0xFFE8E6E2),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      children: [
        Text(unlocked ? emoji : '🔒', style: const TextStyle(fontSize: 28)),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
}
