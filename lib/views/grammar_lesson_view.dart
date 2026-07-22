import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fsrs/fsrs.dart' show Rating;

import '../models/grammar_models.dart';
import '../providers/grammar_state.dart';
import '../services/speech_service.dart';
import '../theme/app_theme.dart';

class GrammarLessonView extends ConsumerStatefulWidget {
  const GrammarLessonView({required this.point, super.key});

  final GrammarPoint point;

  @override
  ConsumerState<GrammarLessonView> createState() => _GrammarLessonViewState();
}

class _GrammarLessonViewState extends ConsumerState<GrammarLessonView> {
  final SpeechService _speech = SpeechService();
  bool _showRecall = false;

  @override
  void dispose() {
    _speech.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final garden = ref.watch(grammarGardenProvider);
    final planted = garden.isPlanted(widget.point.id);
    final bookmarked = garden.bookmarks.contains(widget.point.id);
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.point.level} grammar'),
        actions: [
          IconButton(
            tooltip: bookmarked ? 'Remove bookmark' : 'Bookmark lesson',
            onPressed: () => ref
                .read(grammarGardenProvider.notifier)
                .toggleBookmark(widget.point.id),
            icon: Icon(
              bookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
            ),
          ),
        ],
      ),
      body: ResponsiveContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text('${widget.point.level} reference')),
                Chip(label: Text('Lesson ${widget.point.order}')),
                if (planted)
                  const Chip(
                    avatar: Text('🌱'),
                    label: Text('In Memory Garden'),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              widget.point.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 7),
            Text(
              widget.point.summary,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 14),
            _Section(
              title: 'How it works',
              child: Text(widget.point.explanation),
            ),
            _Section(
              title: 'Build the pattern',
              colour: const Color(0xFFFFF0E7),
              child: SelectableText(
                widget.point.formation,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            Text(
              'Examples in context',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (final example in widget.point.examples)
              Card(
                margin: const EdgeInsets.only(bottom: 9),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 13, 8, 13),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SelectableText(
                              example.japanese,
                              style: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              example.romaji,
                              style: const TextStyle(color: AppColors.muted),
                            ),
                            Text(example.english),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Hear warm Japanese playback',
                        onPressed: () =>
                            _speech.speakJapanese(example.japanese),
                        icon: const Icon(Icons.volume_up_rounded),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 6),
            if (!planted)
              FilledButton.icon(
                onPressed: () async {
                  await ref
                      .read(grammarGardenProvider.notifier)
                      .plant(widget.point.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Planted. Leo will bring this back before it fades.',
                        ),
                      ),
                    );
                  }
                },
                icon: const Text('🌱'),
                label: const Text('Plant in Memory Garden'),
              )
            else
              _RecallCheck(
                revealed: _showRecall,
                onReveal: () => setState(() => _showRecall = true),
                onRate: (rating) async {
                  await ref
                      .read(grammarGardenProvider.notifier)
                      .rate(widget.point.id, rating);
                  if (context.mounted) {
                    setState(() => _showRecall = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Saved. Your next visit has been scheduled.',
                        ),
                      ),
                    );
                  }
                },
              ),
            const SizedBox(height: 14),
            const Card(
              color: AppColors.bambooMist,
              child: Padding(
                padding: EdgeInsets.all(14),
                child: Text(
                  'Source: Hanabira Japanese grammar, CC BY-SA 3.0. Community-reviewed learning material, not an official JLPT question.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.colour});

  final String title;
  final Widget child;
  final Color? colour;

  @override
  Widget build(BuildContext context) => Card(
    color: colour,
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 7),
          child,
        ],
      ),
    ),
  );
}

class _RecallCheck extends StatelessWidget {
  const _RecallCheck({
    required this.revealed,
    required this.onReveal,
    required this.onRate,
  });

  final bool revealed;
  final VoidCallback onReveal;
  final ValueChanged<Rating> onRate;

  @override
  Widget build(BuildContext context) => Card(
    color: const Color(0xFFF2F5E9),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'A tiny recall check',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Text('Look away, recall the pattern, then answer honestly.'),
          const SizedBox(height: 10),
          if (!revealed)
            FilledButton.tonal(
              onPressed: onReveal,
              child: const Text('I have recalled it'),
            )
          else
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 7,
              runSpacing: 7,
              children: [
                _Rate(label: 'Again', onTap: () => onRate(Rating.again)),
                _Rate(label: 'Hard', onTap: () => onRate(Rating.hard)),
                _Rate(label: 'Good', onTap: () => onRate(Rating.good)),
                _Rate(label: 'Easy', onTap: () => onRate(Rating.easy)),
              ],
            ),
        ],
      ),
    ),
  );
}

class _Rate extends StatelessWidget {
  const _Rate({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) =>
      OutlinedButton(onPressed: onTap, child: Text(label));
}
