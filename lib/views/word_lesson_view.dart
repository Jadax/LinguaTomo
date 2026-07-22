import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/word_bank.dart';
import '../models/app_models.dart';
import '../providers/app_state.dart';
import '../providers/word_progress_state.dart';
import '../services/speech_service.dart';
import '../theme/app_theme.dart';
import '../widgets/leo_sprite.dart';

class WordLessonView extends ConsumerStatefulWidget {
  const WordLessonView({
    super.key,
    this.words,
    this.filterCategory,
    this.filterTier,
  });

  final List<Word>? words;
  final WordCategory? filterCategory;
  final DifficultyTier? filterTier;

  @override
  ConsumerState<WordLessonView> createState() => _WordLessonViewState();
}

class _WordLessonViewState extends ConsumerState<WordLessonView> {
  late final List<Word> _words;
  var _currentIndex = 0;
  var _correctCount = 0;
  var _answered = false;
  var _selectedOption = -1;
  late List<String> _options;
  final _speech = SpeechService();
  final _rng = math.Random();

  @override
  void initState() {
    super.initState();
    if (widget.words != null) {
      _words = widget.words!;
    } else if (widget.filterCategory != null && widget.filterTier != null) {
      _words = _generateFilteredLesson(
        category: widget.filterCategory!,
        tier: widget.filterTier!,
      );
    } else {
      _words = ref.read(wordProgressProvider.notifier).generateLesson();
    }
    _prepareQuestion();
  }

  List<Word> _generateFilteredLesson({
    required WordCategory category,
    required DifficultyTier tier,
  }) {
    final allWords = wordBank
        .where((w) => w.category == category && w.tier == tier)
        .toList();
    final completed = ref.read(wordProgressProvider).completedWords;
    final incomplete = allWords.where((w) => !completed.contains(w.id)).toList();
    if (incomplete.length >= 5) {
      incomplete.shuffle(_rng);
      return incomplete.take(5).toList();
    }
    // If fewer than 5 incomplete, fill with already-learned for review
    final alreadyLearned = allWords.where((w) => completed.contains(w.id)).toList();
    final pool = [...incomplete, ...alreadyLearned]..shuffle(_rng);
    return pool.take(5).toList();
  }

  @override
  void dispose() {
    _speech.dispose();
    super.dispose();
  }

  void _prepareQuestion() {
    if (_currentIndex >= _words.length) return;
    final current = _words[_currentIndex];
    _answered = false;
    _selectedOption = -1;

    final correctAnswer = current.english;
    final otherWords = wordBank
        .where((w) => w.id != current.id)
        .toList()
      ..shuffle(_rng);
    final distractors = otherWords.take(2).map((w) => w.english).toList();
    _options = [correctAnswer, ...distractors]..shuffle(_rng);
  }

  void _checkAnswer(int index) {
    if (_answered) return;
    setState(() {
      _answered = true;
      _selectedOption = index;
    });
    final current = _words[_currentIndex];
    final isCorrect = _options[index] == current.english;
    if (isCorrect) {
      _correctCount++;
    }
    _speech.speakJapanese(current.japanese);
  }

  void _nextWord() {
    setState(() {
      _currentIndex++;
      if (_currentIndex < _words.length) {
        _prepareQuestion();
      }
    });
  }

  void _finish() {
    final wordIds = _words.map((w) => w.id).toList();
    ref.read(wordProgressProvider.notifier).completeLesson(
          wordIds: wordIds,
          correctCount: _correctCount,
        );
    final xpEarned = _correctCount * 10;
    ref.read(progressProvider.notifier).addXp(xpEarned);
    Navigator.of(context).pop(
      LessonResult(
        totalWords: _words.length,
        correctCount: _correctCount,
        xpEarned: xpEarned,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_words.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Word Lesson')),
        body: const Center(child: Text('No words available. Try a different tier.')),
      );
    }
    if (_currentIndex >= _words.length) {
      return _buildResults();
    }
    final current = _words[_currentIndex];
    final progress = _currentIndex / _words.length;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Word ${_currentIndex + 1} of ${_words.length}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: AppColors.bambooMist,
          ),
        ),
      ),
      body: ResponsiveContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: () => _speech.speakJapanese(current.japanese),
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppColors.sakura.withValues(alpha: .3),
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        current.emoji,
                        style: const TextStyle(fontSize: 48),
                      ),
                      const SizedBox(height: 4),
                      const Icon(
                        Icons.volume_up_rounded,
                        color: AppColors.persimmon,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                current.japanese,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                current.romaji,
                style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'What does this mean?',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            for (var i = 0; i < _options.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _AnswerOption(
                  text: _options[i],
                  selected: _selectedOption == i,
                  correct: _answered && _options[i] == current.english,
                  wrong: _answered &&
                      _selectedOption == i &&
                      _options[i] != current.english,
                  enabled: !_answered,
                  onTap: () => _checkAnswer(i),
                ),
              ),
            const Spacer(),
            if (_answered)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: FilledButton(
                  onPressed: _nextWord,
                  child: Text(
                    _currentIndex < _words.length - 1 ? 'Next word' : 'See results',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    final percentage = _words.isEmpty
        ? 0
        : ((_correctCount / _words.length) * 100).round();
    return Scaffold(
      body: SafeArea(
        child: ResponsiveContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: LeoSprite(
                  pose: percentage >= 80
                      ? LeoPose.celebrate
                      : percentage >= 50
                          ? LeoPose.smile
                          : LeoPose.meow,
                  size: 160,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                percentage >= 80
                    ? 'Brilliant!'
                    : percentage >= 50
                        ? 'Good work!'
                        : 'Keep practising!',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '$_correctCount of ${_words.length} correct',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                '$_correctCount × 10 XP = ${_correctCount * 10} XP',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.persimmon,
                ),
                textAlign: TextAlign.center,
              ),
              if (percentage == 100) ...[
                const SizedBox(height: 12),
                const Text(
                  '🌟 Perfect lesson!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center,
                ),
              ],
              const Spacer(),
              FilledButton(
                onPressed: _finish,
                child: const Text(
                  'Continue',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnswerOption extends StatelessWidget {
  const _AnswerOption({
    required this.text,
    required this.selected,
    required this.correct,
    required this.wrong,
    required this.enabled,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final bool correct;
  final bool wrong;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    if (correct) {
      bgColor = AppColors.matcha.withValues(alpha: .15);
      borderColor = AppColors.matcha;
    } else if (wrong) {
      bgColor = AppColors.persimmon.withValues(alpha: .1);
      borderColor = AppColors.persimmon;
    } else if (selected) {
      bgColor = AppColors.sakura.withValues(alpha: .2);
      borderColor = AppColors.sakura;
    } else {
      bgColor = Colors.white;
      borderColor = AppColors.charcoal.withValues(alpha: .12);
    }
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: correct || wrong ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
            if (correct)
              const Icon(Icons.check_circle_rounded, color: AppColors.matcha),
            if (wrong)
              const Icon(Icons.cancel_rounded, color: AppColors.persimmon),
          ],
        ),
      ),
    );
  }
}

class LessonResult {
  const LessonResult({
    required this.totalWords,
    required this.correctCount,
    required this.xpEarned,
  });

  final int totalWords;
  final int correctCount;
  final int xpEarned;
}
