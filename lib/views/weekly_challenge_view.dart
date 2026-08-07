import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/festival_calendar_data.dart';
import '../data/word_bank.dart';
import '../models/app_models.dart';
import '../providers/app_state.dart';
import '../providers/weekly_challenge_state.dart';
import '../providers/word_progress_state.dart';
import '../theme/app_theme.dart';

class WeeklyChallengeView extends ConsumerStatefulWidget {
  const WeeklyChallengeView({super.key});

  @override
  ConsumerState<WeeklyChallengeView> createState() =>
      _WeeklyChallengeViewState();
}

class _WeeklyChallengeViewState extends ConsumerState<WeeklyChallengeView> {
  final _rng = math.Random();
  late List<_ChallengeQuestion> _questions;
  int _index = 0;
  int _correct = 0;
  int? _selected;
  bool _answered = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    final challenge = ref.read(weeklyChallengeProvider);
    final progress = ref.read(wordProgressProvider);
    _questions = _buildQuestions(challenge.challengeType, progress);
  }

  List<_ChallengeQuestion> _buildQuestions(
    ChallengeType type,
    WordProgress progress,
  ) {
    if (type == ChallengeType.culture) {
      final events = [...festivalCalendar]..shuffle(_rng);
      return events.take(10).map((event) {
        final distractors =
            festivalCalendar
                .where((other) => other.id != event.id)
                .map((other) => other.englishName)
                .toList()
              ..shuffle(_rng);
        return _ChallengeQuestion(
          prompt: event.japaneseName,
          hint: '${event.emoji} Japanese festival',
          correct: event.englishName,
          options: [event.englishName, ...distractors.take(3)]..shuffle(_rng),
        );
      }).toList();
    }
    final words =
        ref
            .read(weeklyChallengeProvider.notifier)
            .generateChallengeWords(progress)
          ..shuffle(_rng);
    final reverse = type == ChallengeType.speed;
    return words.map((word) {
      final sameTheme =
          wordBank
              .where(
                (other) =>
                    other.id != word.id &&
                    other.category == word.category &&
                    other.tier == word.tier,
              )
              .toList()
            ..shuffle(_rng);
      final fallback = wordBank.where((other) => other.id != word.id).toList()
        ..shuffle(_rng);
      final pool = [...sameTheme, ...fallback];
      final answer = reverse ? word.japanese : word.english;
      final distractors = <String>[];
      for (final other in pool) {
        final value = reverse ? other.japanese : other.english;
        if (value != answer && !distractors.contains(value)) {
          distractors.add(value);
        }
        if (distractors.length == 3) {
          break;
        }
      }
      return _ChallengeQuestion(
        prompt: reverse ? word.english : word.japanese,
        hint: '${word.emoji} ${word.category.label}',
        correct: answer,
        options: [answer, ...distractors]..shuffle(_rng),
      );
    }).toList();
  }

  Future<void> _next() async {
    if (!_answered) return;
    if (_index < _questions.length - 1) {
      setState(() {
        _index++;
        _selected = null;
        _answered = false;
      });
      return;
    }
    final score = ((_correct / _questions.length) * 100).round();
    final challenge = ref.read(weeklyChallengeProvider);
    if (!challenge.completed) {
      await ref.read(weeklyChallengeProvider.notifier).completeChallenge(score);
      await ref.read(progressProvider.notifier).addXp(150);
    }
    if (mounted) setState(() => _finished = true);
  }

  @override
  Widget build(BuildContext context) {
    final challenge = ref.watch(weeklyChallengeProvider);
    if (challenge.completed || _finished) {
      return Scaffold(
        appBar: AppBar(title: const Text('Weekly Challenge')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🏆', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 12),
                const Text(
                  'This week is complete!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
                Text(
                  'Best score: ${challenge.bestScore}% · Come back next week for a new challenge.',
                ),
              ],
            ),
          ),
        ),
      );
    }
    final question = _questions[_index];
    return Scaffold(
      appBar: AppBar(
        title: Text('Weekly Challenge · ${_index + 1}/${_questions.length}'),
      ),
      body: SafeArea(
        child: ResponsiveContent(
          fillHeight: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                challenge.challengeType.label,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'A gentle weekly check-in using what you have been learning.',
              ),
              const SizedBox(height: 22),
              Card(
                color: AppColors.sakura.withValues(alpha: .4),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        question.hint,
                        style: const TextStyle(color: AppColors.muted),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        question.prompt,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              for (var i = 0; i < question.options.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: OutlinedButton(
                    onPressed: _answered
                        ? null
                        : () => setState(() {
                            _selected = i;
                            _answered = true;
                            if (question.options[i] == question.correct) {
                              _correct++;
                            }
                          }),
                    style: OutlinedButton.styleFrom(
                      alignment: Alignment.centerLeft,
                    ),
                    child: Text(question.options[i]),
                  ),
                ),
              if (_answered) ...[
                Text(
                  _selected != null &&
                          question.options[_selected!] == question.correct
                      ? 'Correct!'
                      : 'The answer is ${question.correct}.',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _next,
                  child: Text(
                    _index == _questions.length - 1
                        ? 'Finish challenge'
                        : 'Next question',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ChallengeQuestion {
  const _ChallengeQuestion({
    required this.prompt,
    required this.hint,
    required this.correct,
    required this.options,
  });

  final String prompt;
  final String hint;
  final String correct;
  final List<String> options;
}
