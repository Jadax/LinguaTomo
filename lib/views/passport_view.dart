import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../models/app_models.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/leo_sprite.dart';

class PassportView extends ConsumerWidget {
  const PassportView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final stage = progress.stage;
    return ResponsiveContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Proficiency Passport',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          const Text(
            'Real abilities are tracked separately and never flattened into one “fluency” score.',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.persimmon, Color(0xFFE77862)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 34,
                  backgroundColor: Colors.white,
                  child: LeoSprite(pose: LeoPose.smile, size: 62),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'LINGUATOMO PASSPORT',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.3,
                        ),
                      ),
                      Text(
                        stage.label,
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(color: Colors.white),
                      ),
                      Text(
                        '${progress.verifiedCanDos} verified Can-Dos',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _LevelCard(
                  label: 'JLPT readiness',
                  value: stage.jlpt,
                  note: 'Knowledge, reading, listening',
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _LevelCard(
                  label: 'CEFR / JF',
                  value: stage.cefr,
                  note: 'Can-Do performance',
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _LevelCard(
                  label: 'ILR-oriented',
                  value: stage.ilr,
                  note: 'Separate functional target',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Skill evidence',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: SkillArea.values
                    .map(
                      (skill) => _SkillRow(
                        skill: skill,
                        evidence: progress.skillEvidence[skill] ?? 0,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () => SharePlus.instance.share(
              ShareParams(
                title: 'My LinguaTomo Passport',
                text:
                    'I have verified ${progress.verifiedCanDos} real-world Japanese Can-Dos and reached ${stage.label} (${stage.cefr}) in LinguaTomo. 🐾🇯🇵',
              ),
            ),
            icon: const Icon(Icons.ios_share_rounded),
            label: const Text('Share a privacy-safe milestone'),
          ),
          const SizedBox(height: 14),
          const Card(
            color: AppColors.bambooMist,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: AppColors.matcha),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'JLPT, CEFR, and ILR measure different abilities. These labels are learning targets, not official certificates. Speaking and writing evidence remain separate from JLPT readiness.',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.label,
    required this.value,
    required this.note,
  });
  final String label;
  final String value;
  final String note;
  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: AppColors.muted),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.matcha),
          ),
          const SizedBox(height: 3),
          Text(
            note,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(fontSize: 9, color: AppColors.muted),
          ),
        ],
      ),
    ),
  );
}

class _SkillRow extends StatelessWidget {
  const _SkillRow({required this.skill, required this.evidence});
  final SkillArea skill;
  final int evidence;
  @override
  Widget build(BuildContext context) {
    final value = (evidence / 6).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(skill.icon, color: AppColors.matcha),
          const SizedBox(width: 10),
          SizedBox(width: 82, child: Text(skill.label)),
          Expanded(
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$evidence',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
