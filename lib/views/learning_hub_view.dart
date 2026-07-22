import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/curriculum_data.dart';
import '../data/word_bank.dart';
import '../models/app_models.dart';
import '../providers/app_state.dart';
import '../providers/grammar_state.dart';
import '../providers/word_progress_state.dart';
import '../theme/app_theme.dart';
import 'grammar_library_view.dart';
import 'journey_view.dart';
import 'kana_grid_view.dart';
import 'postcards_view.dart';
import 'seasonal_stories_view.dart';
import 'word_lesson_view.dart';

class LearningHubView extends ConsumerWidget {
  const LearningHubView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final garden = ref.watch(grammarGardenProvider);
    final catalogue = ref.watch(grammarCatalogueProvider);
    final wordProgress = ref.watch(wordProgressProvider);
    return ResponsiveContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Your learning library',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 5),
          Text(
            '${wordProgress.wordsLearned}/200 words · ${wordProgress.currentTier.label} tier',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          Card(
            color: const Color(0xFFFFEEE5),
            child: Padding(
              padding: const EdgeInsets.all(17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.menu_book_rounded,
                        color: AppColors.persimmon,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Word Route · ${wordProgress.currentTier.label}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Text('${wordProgress.wordsLearned}/200'),
                    ],
                  ),
                  const SizedBox(height: 9),
                  LinearProgressIndicator(
                    value: wordProgress.wordsLearned / 200,
                    minHeight: 10,
                  ),
                  const SizedBox(height: 9),
                  Text(
                    '${wordProgress.tierProgress(wordProgress.currentTier)}/${wordsForTier(wordProgress.currentTier).length} words in current tier',
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const WordLessonView(),
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Start a word lesson'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          _LearningTile(
            icon: Icons.route_rounded,
            colour: AppColors.sakura,
            title: 'See my complete route',
            subtitle: 'Word tiers and Can-Do missions',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const JourneyView()),
            ),
          ),
          _LearningTile(
            icon: Icons.auto_stories_rounded,
            colour: AppColors.bambooMist,
            title: 'Grammar course atlas',
            subtitle: catalogue.when(
              data: (value) =>
                  '${value.points.length} lessons from N5 to N1 · ${garden.cards.length} planted',
              loading: () => 'Loading 828 lessons from N5 to N1',
              error: (_, _) => 'Tap to retry the course library',
            ),
            badge: garden.dueCount == 0 ? null : '${garden.dueCount} due',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const GrammarLibraryView()),
            ),
          ),
          _LearningTile(
            icon: Icons.grid_view_rounded,
            colour: const Color(0xFFFFE7ED),
            title: 'Kana and kanji studio',
            subtitle: 'Character grid, examples and stroke practice',
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const KanaGridView())),
          ),
          _LearningTile(
            icon: Icons.local_post_office_rounded,
            colour: wordProgress.postcardsUnlocked
                ? const Color(0xFFFFF1D8)
                : AppColors.bambooMist.withValues(alpha: .4),
            title: 'Living postcards',
            subtitle: wordProgress.postcardsUnlocked
                ? '${progress.completedPostcards.length}/${postcards.length} collected'
                : 'Learn 10 words to unlock',
            onTap: wordProgress.postcardsUnlocked
                ? () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PostcardsView()),
                  )
                : null,
          ),
          _LearningTile(
            icon: Icons.celebration_rounded,
            colour: const Color(0xFFE6F3F1),
            title: 'Seasonal stories',
            subtitle: 'Gentle cultural adventures',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SeasonalStoriesView()),
            ),
          ),
        ],
      ),
    );
  }
}

class _LearningTile extends StatelessWidget {
  const _LearningTile({
    required this.icon,
    required this.colour,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final Color colour;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: colour,
                borderRadius: BorderRadius.circular(17),
              ),
              child: Icon(icon, color: AppColors.charcoal),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                      if (badge != null)
                        Chip(
                          visualDensity: VisualDensity.compact,
                          label: Text(badge!),
                        ),
                    ],
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: AppColors.muted),
                  ),
                ],
              ),
            ),
            if (onTap != null) const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    ),
  );
}
