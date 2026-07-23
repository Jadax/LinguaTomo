import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/word_bank.dart';
import '../models/app_models.dart';
import '../providers/word_progress_state.dart';
import '../theme/app_theme.dart';
import 'word_lesson_view.dart';

class JourneyView extends ConsumerWidget {
  const JourneyView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordProgress = ref.watch(wordProgressProvider);
    final overallProgress = wordProgress.wordsLearned / 400;
    return Scaffold(
      appBar: AppBar(title: const Text('My Japanese Route')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // ── Overall progress banner ─────────────────────────────────
          Card(
            color: const Color(0xFFFFF0E8),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.trending_up_rounded,
                          color: AppColors.persimmon),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${wordProgress.wordsLearned} of 500 words',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Text(
                        '${(overallProgress * 100).round()}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: AppColors.persimmon,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: overallProgress,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Snake path per tier ─────────────────────────────────────
          for (final tier in DifficultyTier.values) ...[
            _TierHeader(tier: tier, wordProgress: wordProgress),
            const SizedBox(height: 8),
            _SnakeTier(
              tier: tier,
              wordProgress: wordProgress,
            ),
            const SizedBox(height: 28),
          ],
        ],
      ),
    );
  }
}

/// Tier header showing tier name, description and progress.
class _TierHeader extends StatelessWidget {
  const _TierHeader({required this.tier, required this.wordProgress});
  final DifficultyTier tier;
  final WordProgress wordProgress;

  @override
  Widget build(BuildContext context) {
    final completed = wordProgress.tierProgress(tier);
    final total = wordsForTier(tier).length;
    final isUnlocked = tier.index <= wordProgress.currentTier.index;
    final isCurrent = tier == wordProgress.currentTier;
    return Card(
      color: isCurrent
          ? const Color(0xFFFFF0E8)
          : isUnlocked
              ? null
              : Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isUnlocked ? AppColors.matcha : AppColors.muted,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${tier.index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tier.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '$completed/$total words · ~${_jlptLabel(tier)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (!isUnlocked)
              const Icon(Icons.lock_rounded, color: AppColors.muted)
            else if (completed == total)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.matcha, size: 28)
            else
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: isCurrent ? AppColors.persimmon : AppColors.muted,
              ),
          ],
        ),
      ),
    );
  }
}

/// The zigzag snake path for one tier's categories.
class _SnakeTier extends StatelessWidget {
  const _SnakeTier({required this.tier, required this.wordProgress});
  final DifficultyTier tier;
  final WordProgress wordProgress;

  @override
  Widget build(BuildContext context) {
    final categories = WordCategory.values;
    final isUnlocked = tier.index <= wordProgress.currentTier.index;
    final tierWords = wordsForTier(tier);

    return Column(
      children: List.generate(categories.length, (index) {
        final category = categories[index];
        final categoryWords =
            tierWords.where((w) => w.category == category).toList();
        final completedCount = categoryWords
            .where((w) => wordProgress.completedWords.contains(w.id))
            .length;
        final allDone = completedCount == categoryWords.length;
        final isLeft = index.isEven;

        // Category is "active" if this tier is unlocked and user hasn't
        // completed all words in this category yet.
        final isActive = isUnlocked && !allDone;

        return _SnakeNode(
          category: category,
          emoji: category.emoji,
          label: category.label,
          completed: completedCount,
          total: categoryWords.length,
          isLeft: isLeft,
          isActive: isActive,
          isCompleted: allDone,
          isFirst: index == 0,
          isLast: index == categories.length - 1,
          onTap: isActive
              ? () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => WordLessonView(
                        filterCategory: category,
                        filterTier: tier,
                      ),
                    ),
                  )
              : null,
        );
      }),
    );
  }
}

/// A single node in the snake path with connecting lines.
class _SnakeNode extends StatelessWidget {
  const _SnakeNode({
    required this.category,
    required this.emoji,
    required this.label,
    required this.completed,
    required this.total,
    required this.isLeft,
    required this.isActive,
    required this.isCompleted,
    required this.isFirst,
    required this.isLast,
    this.onTap,
  });

  final WordCategory category;
  final String emoji;
  final String label;
  final int completed;
  final int total;
  final bool isLeft;
  final bool isActive;
  final bool isCompleted;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onTap;

  Color get _nodeColor {
    if (isCompleted) return AppColors.matcha;
    if (isActive) return AppColors.persimmon;
    return AppColors.muted;
  }

  @override
  Widget build(BuildContext context) {
    final nodeSize = 62.0;
    final centerFraction = isLeft ? 0.28 : 0.72;
    final textAlign = isLeft ? TextAlign.left : TextAlign.right;

    return IntrinsicHeight(
      child: Stack(
        children: [
          // ── Vertical connecting line (behind everything) ───────
          Positioned(
            left: MediaQuery.of(context).size.width * centerFraction,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                color: _nodeColor.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Top connector (skip for first node) ───────────────
          if (!isFirst)
            Positioned(
              left: MediaQuery.of(context).size.width * centerFraction - 1,
              top: 0,
              child: SizedBox(width: 6, height: nodeSize * 0.42),
            ),

          // ── Bottom connector ──────────────────────────────────
          if (!isLast)
            Positioned(
              left: MediaQuery.of(context).size.width * centerFraction - 1,
              bottom: 0,
              child: SizedBox(width: 6, height: nodeSize * 0.42),
            ),

          // ── Category node ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                if (isLeft) ...[
                  // Label on left
                  Expanded(
                    flex: 3,
                    child: _NodeLabel(
                      label: label,
                      completed: completed,
                      total: total,
                      color: _nodeColor,
                      textAlign: textAlign,
                    ),
                  ),
                  const Spacer(flex: 2),
                  // Node circle
                  _NodeCircle(
                    emoji: emoji,
                    size: nodeSize,
                    color: _nodeColor,
                    isActive: isActive,
                    onTap: onTap,
                  ),
                  const Spacer(flex: 3),
                ] else ...[
                  // Node circle
                  const Spacer(flex: 3),
                  _NodeCircle(
                    emoji: emoji,
                    size: nodeSize,
                    color: _nodeColor,
                    isActive: isActive,
                    onTap: onTap,
                  ),
                  const Spacer(flex: 2),
                  // Label on right
                  Expanded(
                    flex: 3,
                    child: _NodeLabel(
                      label: label,
                      completed: completed,
                      total: total,
                      color: _nodeColor,
                      textAlign: textAlign,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The circular node with emoji.
class _NodeCircle extends StatelessWidget {
  const _NodeCircle({
    required this.emoji,
    required this.size,
    required this.color,
    required this.isActive,
    this.onTap,
  });

  final String emoji;
  final double size;
  final Color color;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 3),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(emoji, style: TextStyle(fontSize: size * 0.42)),
      ),
    );
  }
}

/// Text label beside a node.
class _NodeLabel extends StatelessWidget {
  const _NodeLabel({
    required this.label,
    required this.completed,
    required this.total,
    required this.color,
    required this.textAlign,
  });

  final String label;
  final int completed;
  final int total;
  final Color color;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: textAlign == TextAlign.left
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          textAlign: textAlign,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$completed/$total',
          textAlign: textAlign,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

String _jlptLabel(DifficultyTier tier) => switch (tier) {
  DifficultyTier.starter => 'Pre-N5 / Pre-A1',
  DifficultyTier.elementary => 'N5 / A1',
  DifficultyTier.intermediate => 'N4 / A2',
  DifficultyTier.advanced => 'N3 / B1',
  DifficultyTier.expert => 'N2 / B2',
};
