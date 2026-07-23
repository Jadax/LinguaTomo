import 'package:flutter/material.dart';

import '../models/course_section.dart';
import '../theme/app_theme.dart';

class CefrGuideView extends StatelessWidget {
  const CefrGuideView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Course Levels')),
    body: ResponsiveContent(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'What do the levels mean?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          const Text(
            'LinguaTomo maps vocabulary to internationally recognised frameworks so you always know where you stand. These are approximate references, not certificates.',
          ),
          const SizedBox(height: 18),
          ...cefrDescriptions.entries.map((e) => _LevelCard(
            title: 'CEFR ${e.key}',
            description: e.value,
            color: _colorForCefr(e.key),
          )),
          const SizedBox(height: 18),
          Text(
            'JLPT Reference',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          const Text(
            'The Japanese Language Proficiency Test (JLPT) is the standard measure of Japanese ability. Levels shown are for reference — the real JLPT does not publish official word lists.',
          ),
          const SizedBox(height: 12),
          ...jlptDescriptions.entries.map((e) => _LevelCard(
            title: 'JLPT ${e.key}',
            description: e.value,
            color: _colorForJlpt(e.key),
          )),
          const SizedBox(height: 24),
          Card(
            color: AppColors.bambooMist,
            child: const Padding(
              padding: EdgeInsets.all(18),
              child: Text(
                'Real abilities are tracked separately and never flattened into a single fluency score. Use the Memory Garden for spaced review and Can-Do missions for real-world conversation practice.',
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Color _colorForCefr(String level) => switch (level) {
    'Pre-A1' => const Color(0xFFE8F5E9),
    'A1' => const Color(0xFFE3F2FD),
    'A2' => const Color(0xFFFFF3E0),
    'B1' => const Color(0xFFF3E5F5),
    'B2' => const Color(0xFFFFEBEE),
    _ => const Color(0xFFF5F5F5),
  };

  Color _colorForJlpt(String level) => switch (level) {
    'N5' => const Color(0xFFE8F5E9),
    'N4' => const Color(0xFFE3F2FD),
    'N3' => const Color(0xFFFFF3E0),
    'N2' => const Color(0xFFF3E5F5),
    'N1' => const Color(0xFFFFEBEE),
    _ => const Color(0xFFF5F5F5),
  };
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.title, required this.description, required this.color});
  final String title, description;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(
    color: color,
    margin: const EdgeInsets.only(bottom: 10),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 6),
          Text(description, style: const TextStyle(fontSize: 13, height: 1.4)),
        ],
      ),
    ),
  );
}
