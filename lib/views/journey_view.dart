import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/curriculum_data.dart';
import '../models/app_models.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class JourneyView extends ConsumerWidget {
  const JourneyView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final done = {...progress.completedMissions, ...progress.placedOutMissions};
    final completedCount = done.length;
    final percentage = missions.isEmpty
        ? 0.0
        : completedCount / missions.length;
    return Scaffold(
      appBar: AppBar(title: const Text('My Japanese Route')),
      body: ResponsiveContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'You are here',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              '${progress.stage.label} • ${progress.stage.jlpt} • ${progress.stage.cefr} • ${progress.stage.ilr}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: percentage, minHeight: 12),
            const SizedBox(height: 6),
            Text(
              '$completedCount of ${missions.length} core Can-Do missions evidenced',
            ),
            const SizedBox(height: 18),
            const _FrameworkNote(),
            const SizedBox(height: 16),
            for (final stage in ProficiencyStage.values)
              _StageCard(stage: stage, completedIds: done),
            const SizedBox(height: 12),
            const Card(
              color: AppColors.bambooMist,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'The full professional route is a long-term programme. FSI describes Japanese as requiring intensive study, and ILR 3 is broader than passing JLPT N1. LinguaTomo therefore tracks listening, speaking, reading, writing, interaction and culture separately.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FrameworkNote extends StatelessWidget {
  const _FrameworkNote();

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How the route is organised',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          const Text(
            'Practical situations follow the conversation-management logic used by FSI FAST. Can-Do evidence follows CEFR and JF Standard principles. JLPT remains an exam-readiness reference, while ILR is shown as a separate functional target.',
          ),
        ],
      ),
    ),
  );
}

class _StageCard extends StatelessWidget {
  const _StageCard({required this.stage, required this.completedIds});

  final ProficiencyStage stage;
  final Set<String> completedIds;

  static const _focus = {
    ProficiencyStage.kittenSteps:
        'Kana, sound system, greetings and learning routines',
    ProficiencyStage.firstEncounters:
        'Introductions, directions and essential interaction',
    ProficiencyStage.dailyLife:
        'Transport, shopping, food, telephone and emergencies',
    ProficiencyStage.independent:
        'Health, work processes, narration and supported opinions',
    ProficiencyStage.connected: 'News, formal requests and negotiation',
    ProficiencyStage.professional:
        'Complex texts, briefings, mediation and sustained discussion',
  };

  static const _checkpoint = {
    ProficiencyStage.kittenSteps: 'Kana readiness check',
    ProficiencyStage.firstEncounters: 'Foundation exam • JLPT N5 preparation',
    ProficiencyStage.dailyLife: 'Elementary exam • JLPT N4 preparation',
    ProficiencyStage.independent: 'Independent exam • JLPT N3 preparation',
    ProficiencyStage.connected: 'Advanced exam • JLPT N2 preparation',
    ProficiencyStage.professional:
        'Expert exam • JLPT N1 plus ILR-style performance tasks',
  };

  @override
  Widget build(BuildContext context) {
    final stageMissions = missions
        .where((item) => item.stage == stage)
        .toList();
    final complete = stageMissions
        .where((item) => completedIds.contains(item.id))
        .length;
    final isComplete =
        stageMissions.isNotEmpty && complete == stageMissions.length;
    final isCurrent = complete > 0 && !isComplete;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: isCurrent ? const Color(0xFFFFF0E8) : null,
      child: ExpansionTile(
        initiallyExpanded: isCurrent || stage == ProficiencyStage.kittenSteps,
        leading: CircleAvatar(
          backgroundColor: isComplete ? AppColors.matcha : AppColors.bambooMist,
          child: Icon(
            isComplete ? Icons.check_rounded : Icons.route_rounded,
            color: isComplete ? Colors.white : AppColors.matcha,
          ),
        ),
        title: Text(
          stage.label,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          '${stage.jlpt} • ${stage.cefr} • ${stage.ilr}   $complete/${stageMissions.length}',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Align(alignment: Alignment.centerLeft, child: Text(_focus[stage]!)),
          const SizedBox(height: 10),
          for (final mission in stageMissions)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                completedIds.contains(mission.id)
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: completedIds.contains(mission.id)
                    ? AppColors.matcha
                    : AppColors.muted,
              ),
              title: Text(mission.title),
              subtitle: Text(mission.canDo),
            ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.workspace_premium_rounded,
              color: AppColors.persimmon,
            ),
            title: Text(
              _checkpoint[stage]!,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: const Text(
              'Unlocks after the stage evidence is complete. Untimed practice remains available.',
            ),
          ),
        ],
      ),
    );
  }
}
