import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class PlacementView extends ConsumerStatefulWidget {
  const PlacementView({super.key});

  @override
  ConsumerState<PlacementView> createState() => _PlacementViewState();
}

class _PlacementViewState extends ConsumerState<PlacementView> {
  static const _questions = [
    ('Which sound does あ represent?', ['a', 'i', 'ka'], 0),
    ('What does 駅 mean?', ['restaurant', 'station', 'company'], 1),
    ('Choose “Where is the station?”', ['駅はどこですか。', '駅はいくらですか。', '駅で食べます。'], 0),
    (
      'What is the function of お願いします in an order?',
      ['A polite request', 'A past-tense marker', 'A greeting only'],
      0,
    ),
    (
      'Choose the polite emergency request.',
      ['救急車が好きです。', '救急車を呼んでください。', '救急車はどこでした。'],
      1,
    ),
  ];

  int _index = 0;
  int _correct = 0;
  bool _finished = false;

  void _answer(int value) {
    if (value == _questions[_index].$3) _correct++;
    if (_index == _questions.length - 1) {
      setState(() => _finished = true);
    } else {
      setState(() => _index++);
    }
  }

  Future<void> _apply() async {
    final skip = switch (_correct) {
      >= 5 => 6,
      >= 4 => 4,
      >= 3 => 2,
      _ => 0,
    };
    await ref.read(progressProvider.notifier).applyPlacement(skip);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gentle placement check')),
      body: ResponsiveContent(
        child: _finished
            ? _Result(correct: _correct, onApply: _apply)
            : _Question(
                index: _index,
                question: _questions[_index],
                onAnswer: _answer,
              ),
      ),
    );
  }
}

class _Question extends StatelessWidget {
  const _Question({
    required this.index,
    required this.question,
    required this.onAnswer,
  });
  final int index;
  final (String, List<String>, int) question;
  final ValueChanged<int> onAnswer;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      LinearProgressIndicator(
        value: (index + 1) / 5,
        minHeight: 8,
        borderRadius: BorderRadius.circular(8),
      ),
      const SizedBox(height: 22),
      const Text(
        'NO TIMER · TAKE YOUR TIME',
        style: TextStyle(
          color: AppColors.matcha,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.1,
        ),
      ),
      const SizedBox(height: 10),
      Text(question.$1, style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 18),
      for (var i = 0; i < question.$2.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: OutlinedButton(
            onPressed: () => onAnswer(i),
            style: OutlinedButton.styleFrom(
              alignment: Alignment.centerLeft,
              minimumSize: const Size.fromHeight(58),
            ),
            child: Text(question.$2[i]),
          ),
        ),
      const SizedBox(height: 10),
      const Text(
        'This check only recommends a starting point. You can revisit every mission later.',
        style: TextStyle(color: AppColors.muted),
      ),
    ],
  );
}

class _Result extends StatelessWidget {
  const _Result({required this.correct, required this.onApply});
  final int correct;
  final VoidCallback onApply;
  @override
  Widget build(BuildContext context) {
    final recommendation = switch (correct) {
      >= 5 => 'Daily Life',
      >= 4 => 'Getting Directions',
      >= 3 => 'First Encounters',
      _ => 'Kitten Steps',
    };
    return Column(
      children: [
        const Text('🐾', style: TextStyle(fontSize: 64)),
        Text(
          'Start at $recommendation',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'You answered $correct of 5 correctly. Earlier missions will be marked “placed out,” not counted as verified Can-Dos.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 22),
        FilledButton(
          onPressed: onApply,
          child: const Text('Use this starting point'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Keep my current path'),
        ),
      ],
    );
  }
}
