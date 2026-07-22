import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/curriculum_data.dart';
import '../data/word_bank.dart';
import '../models/app_models.dart';
import '../providers/app_state.dart';
import '../providers/word_progress_state.dart';
import '../theme/app_theme.dart';
import 'kana_grid_view.dart';
import 'mission_view.dart';
import 'word_lesson_view.dart';

class JourneyView extends ConsumerWidget {
  const JourneyView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final wordProgress = ref.watch(wordProgressProvider);
    final done = {...progress.completedMissions, ...progress.placedOutMissions};
    return Scaffold(
      appBar: AppBar(title: const Text('My Japanese Route')),
      body: ResponsiveContent(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            if (wordProgress.wordsLearned == 0) ...[
              _BeginnerStartCard(),
              const SizedBox(height: 18),
            ],
            Text(
              'Your Word Route',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              '${wordProgress.wordsLearned}/200 words learned · ${wordProgress.completedWords.isNotEmpty ? '${(wordProgress.completedWords.length / 200 * 100).round()}%' : '0%'}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: wordProgress.wordsLearned / 200,
              minHeight: 12,
            ),
            const SizedBox(height: 18),
            for (final tier in DifficultyTier.values)
              _TierCard(tier: tier, wordProgress: wordProgress),
            const SizedBox(height: 24),
            Text(
              'Can-Do Missions',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            const Text(
              'Real-world situations once you have some vocabulary under your belt.',
            ),
            const SizedBox(height: 12),
            Text(
              '${done.length}/${missions.length} missions completed',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            for (final stage in ProficiencyStage.values)
              _StageCard(stage: stage, completedIds: done),
          ],
        ),
      ),
    );
  }
}

class _BeginnerStartCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => Card(
    color: AppColors.bambooMist,
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Start with words',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Learn Japanese words first — no need to know the alphabet yet. '
            'Each lesson teaches 5 words with pictures, romaji and audio.',
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const WordLessonView())),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Start your first word lesson'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const KanaGridView())),
            icon: const Icon(Icons.grid_view_rounded),
            label: const Text('Or explore the kana studio'),
          ),
        ],
      ),
    ),
  );
}

class _TierCard extends ConsumerWidget {
  const _TierCard({required this.tier, required this.wordProgress});

  final DifficultyTier tier;
  final WordProgress wordProgress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tierWords = wordsForTier(tier);
    final completed = wordProgress.tierProgress(tier);
    final total = tierWords.length;
    final isUnlocked = tier.index <= wordProgress.currentTier.index;
    final isCurrent = tier == wordProgress.currentTier;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: isCurrent ? const Color(0xFFFFF0E8) : null,
      child: ExpansionTile(
        initiallyExpanded: isCurrent,
        leading: CircleAvatar(
          backgroundColor: isUnlocked ? AppColors.matcha : AppColors.bambooMist,
          child: Icon(
            isUnlocked ? Icons.lock_open_rounded : Icons.lock_rounded,
            color: isUnlocked ? Colors.white : AppColors.muted,
          ),
        ),
        title: Text(
          tier.label,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text('$completed/$total words · ${tier.description}'),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          for (final category in WordCategory.values)
            _CategoryRow(
              category: category,
              tier: tier,
              words: tierWords.where((w) => w.category == category).toList(),
              wordProgress: wordProgress,
              isUnlocked: isUnlocked,
            ),
          if (isUnlocked) ...[
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const WordLessonView()),
              ),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Start a word lesson'),
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.tier,
    required this.words,
    required this.wordProgress,
    required this.isUnlocked,
  });

  final WordCategory category;
  final DifficultyTier tier;
  final List<Word> words;
  final WordProgress wordProgress;
  final bool isUnlocked;

  @override
  Widget build(BuildContext context) {
    final completed = words.where((w) => wordProgress.completedWords.contains(w.id)).length;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Text(category.emoji, style: const TextStyle(fontSize: 24)),
      title: Text(
        category.label,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: Text('$completed/${words.length} words'),
      trailing: isUnlocked
          ? Icon(
              completed == words.length
                  ? Icons.check_circle_rounded
                  : Icons.arrow_forward_ios_rounded,
              size: 18,
              color: completed == words.length ? AppColors.matcha : AppColors.muted,
            )
          : const Icon(Icons.lock_rounded, size: 18, color: AppColors.muted),
    );
  }
}

class _StageCard extends StatelessWidget {
  const _StageCard({required this.stage, required this.completedIds});

  final ProficiencyStage stage;
  final Set<String> completedIds;

  static const _focus = {
    ProficiencyStage.kittenSteps: 'Kana, sound system and learning routines',
    ProficiencyStage.firstEncounters: 'Introductions and directions',
    ProficiencyStage.dailyLife: 'Transport, shopping, food and emergencies',
    ProficiencyStage.independent: 'Health, work and opinions',
    ProficiencyStage.connected: 'News, formal requests and negotiation',
    ProficiencyStage.professional: 'Complex texts and mediation',
  };

  @override
  Widget build(BuildContext context) {
    final stageMissions = missions.where((item) => item.stage == stage).toList();
    final complete = stageMissions.where((item) => completedIds.contains(item.id)).length;
    final isComplete = stageMissions.isNotEmpty && complete == stageMissions.length;
    if (stageMissions.isEmpty) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: isComplete ? AppColors.matcha : AppColors.bambooMist,
          child: Icon(
            isComplete ? Icons.check_rounded : Icons.route_rounded,
            color: isComplete ? Colors.white : AppColors.matcha,
          ),
        ),
        title: Text(stage.label, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text('$complete/${stageMissions.length} · ${_focus[stage]}'),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          for (final mission in stageMissions)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                completedIds.contains(mission.id)
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: completedIds.contains(mission.id) ? AppColors.matcha : AppColors.muted,
              ),
              title: Text(mission.title),
              subtitle: Text(mission.canDo),
              trailing: completedIds.contains(mission.id)
                  ? null
                  : const Icon(Icons.play_arrow_rounded),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => MissionView(mission: mission)),
              ),
            ),
        ],
      ),
    );
  }
}
