import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/word_bank.dart';
import '../models/app_models.dart';
import '../providers/app_state.dart';
import '../providers/word_progress_state.dart';
import '../services/speech_service.dart';
import '../theme/app_theme.dart';
import '../widgets/achievement_banner.dart';
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
  var _phase = _LessonPhase.intro;
  var _correctCount = 0;
  var _answered = false;
  var _selectedOption = -1;
  late List<String> _options;
  late List<bool> _answerResults;
  var _isRetry = false;
  final _speech = SpeechService();
  final _rng = math.Random();
  late final bool _showIntro;
  late final bool _isFirstLesson;

  // Two steps per word: introduce + quiz. Total steps = words.length * 2.
  int get _totalSteps => _words.length * 2;
  int get _currentStep => _currentIndex * 2 + (_phase == _LessonPhase.quiz ? 1 : 0);

  @override
  void initState() {
    super.initState();
    if (widget.words != null) {
      _words = widget.words!;
      _showIntro = false;
    } else if (widget.filterCategory != null && widget.filterTier != null) {
      _words = _generateFilteredLesson(
        category: widget.filterCategory!,
        tier: widget.filterTier!,
      );
      _showIntro = false;
    } else {
      _words = ref.read(wordProgressProvider.notifier).generateLesson();
      _showIntro = true;
    }
    final wp = ref.read(wordProgressProvider);
    _isFirstLesson = wp.wordsLearned == 0;
    if (_showIntro) {
      _phase = _LessonPhase.intro;
    } else {
      _phase = _LessonPhase.introduce;
    }
    _answerResults = List.filled(_words.length, false);
    _prepareQuiz();
  }

  List<Word> _generateFilteredLesson({
    required WordCategory category,
    required DifficultyTier tier,
  }) {
    final allWords = wordBank
        .where((w) => w.category == category && w.tier == tier)
        .toList();
    final completed = ref.read(wordProgressProvider).completedWords;
    final incomplete =
        allWords.where((w) => !completed.contains(w.id)).toList();
    if (incomplete.length >= 5) {
      incomplete.shuffle(_rng);
      return incomplete.take(5).toList();
    }
    final alreadyLearned =
        allWords.where((w) => completed.contains(w.id)).toList();
    final pool = [...incomplete, ...alreadyLearned]..shuffle(_rng);
    return pool.take(5).toList();
  }

  @override
  void dispose() {
    _speech.dispose();
    super.dispose();
  }

  void _prepareQuiz() {
    if (_currentIndex >= _words.length) return;
    final current = _words[_currentIndex];
    _answered = false;
    _selectedOption = -1;
    final correctAnswer = current.english;
    final otherWords =
        wordBank.where((w) => w.id != current.id).toList()..shuffle(_rng);
    final distractors = otherWords.take(2).map((w) => w.english).toList();
    _options = [correctAnswer, ...distractors]..shuffle(_rng);
  }

  void _startQuizPhase() {
    setState(() => _phase = _LessonPhase.quiz);
  }

  void _checkAnswer(int index) {
    if (_answered) return;
    setState(() {
      _answered = true;
      _selectedOption = index;
    });
    final current = _words[_currentIndex];
    final isCorrect = _options[index] == current.english;
    if (isCorrect) _correctCount++;
    _answerResults[_currentIndex] = isCorrect;
  }

  void _nextWord() {
    setState(() {
      _currentIndex++;
      _phase = _LessonPhase.introduce;
      if (_currentIndex < _words.length) {
        _prepareQuiz();
      }
    });
  }

  void _retryFailed() {
    final retryWords = <Word>[];
    for (var i = 0; i < _words.length; i++) {
      if (!_answerResults[i]) retryWords.add(_words[i]);
    }
    setState(() {
      _words = retryWords;
      _currentIndex = 0;
      _correctCount = 0;
      _answered = false;
      _selectedOption = -1;
      _answerResults = List.filled(retryWords.length, false);
      _isRetry = true;
      _phase = _LessonPhase.introduce;
      _prepareQuiz();
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
    if (mounted) {
      AchievementBanner.show(
        context,
        title: _correctCount == _words.length
            ? 'Perfect! +$xpEarned XP'
            : 'Well done! +$xpEarned XP',
        emoji: _correctCount == _words.length ? '\u{1F4AF}' : '\u{2B50}',
      );
      Navigator.of(context).pop(
        LessonResult(
          totalWords: _words.length,
          correctCount: _correctCount,
          xpEarned: xpEarned,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_words.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Word Lesson')),
        body: const Center(
          child: Text('No words available. Try a different tier.'),
        ),
      );
    }
    if (_phase == _LessonPhase.intro) return _buildIntro();
    if (_currentIndex >= _words.length) return _buildResults();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Step ${_currentStep + 1} of $_totalSteps',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: _currentStep / _totalSteps,
            minHeight: 4,
            backgroundColor: AppColors.bambooMist,
          ),
        ),
      ),
      body: _phase == _LessonPhase.introduce
          ? _buildIntroduce()
          : _buildQuiz(),
    );
  }

  // ── INTRO PHASE ──────────────────────────────────────────────────
  // Friendly start screen before the lesson begins.
  Widget _buildIntro() {
    final tier = ref.read(wordProgressProvider).currentTier;
    return Scaffold(
      body: SafeArea(
        child: ResponsiveContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              Center(
                child: LeoSprite(
                  pose: _isFirstLesson ? LeoPose.celebrate : LeoPose.smile,
                  size: 160,
                ),
              ),
              const SizedBox(height: 28),
              if (_isFirstLesson) ...[
                Text(
                  'Your first lesson!',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '5 ${tier.label} words coming your way!',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Leo shows you each word, then quizzes you.\nTap the speaker to hear it aloud.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.muted,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                Text(
                  'Next: 5 ${tier.label} words',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'See the word, learn it, then quiz.',
                  style: TextStyle(fontSize: 15, color: AppColors.muted),
                  textAlign: TextAlign.center,
                ),
              ],
              const Spacer(flex: 3),
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: FilledButton(
                  onPressed: () => setState(() {
                    _phase = _LessonPhase.introduce;
                  }),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                  ),
                  child: const Text(
                    "Let's go!",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── INTRODUCE PHASE ────────────────────────────────────────────────
  // Show the word with emoji, reading, meaning and audio.
  // User taps "Got it" to confirm they've seen it.
  Widget _buildIntroduce() {
    final word = _words[_currentIndex];
    return ResponsiveContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(flex: 2),
          Center(
            child: GestureDetector(
              onTap: () => _speech.speakJapanese(word.japanese),
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.sakura.withValues(alpha: .25),
                  shape: BoxShape.circle,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(word.emoji, style: const TextStyle(fontSize: 64)),
                    const SizedBox(height: 4),
                    const Icon(
                      Icons.volume_up_rounded,
                      color: AppColors.persimmon,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Center(
            child: Text(
              word.japanese,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              word.romaji,
              style: const TextStyle(
                fontSize: 20,
                color: AppColors.muted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.matcha.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                word.english,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.matcha,
                ),
              ),
            ),
          ),
          if (_isFirstLesson) ...[
            const SizedBox(height: 16),
            _TutorialBubble(text: 'Tap the speaker to hear it!'),
          ],
          const Spacer(flex: 3),
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: FilledButton(
              onPressed: _startQuizPhase,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
              child: const Text(
                'Got it!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── QUIZ PHASE ─────────────────────────────────────────────────────
  // Ask "What does this mean?" with 3 options.
  Widget _buildQuiz() {
    final word = _words[_currentIndex];
    return ResponsiveContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Center(
            child: GestureDetector(
              onTap: () => _speech.speakJapanese(word.japanese),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.sakura.withValues(alpha: .25),
                  shape: BoxShape.circle,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(word.emoji, style: const TextStyle(fontSize: 44)),
                    const SizedBox(height: 2),
                    const Icon(
                      Icons.volume_up_rounded,
                      color: AppColors.persimmon,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              word.japanese,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              word.romaji,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.muted,
              ),
            ),
          ),
          const SizedBox(height: 28),
          if (_isFirstLesson) ...[
            _TutorialBubble(text: 'Pick the right meaning!'),
            const SizedBox(height: 12),
          ],
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
                correct: _answered && _options[i] == word.english,
                wrong: _answered &&
                    _selectedOption == i &&
                    _options[i] != word.english,
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
    );
  }

  // ── RESULTS ────────────────────────────────────────────────────────
  Widget _buildResults() {
    final percentage =
        _words.isEmpty ? 0 : ((_correctCount / _words.length) * 100).round();
    final passed = _isRetry || _correctCount >= 3;
    final failedWords = <Word>[];
    if (!passed) {
      for (var i = 0; i < _words.length; i++) {
        if (!_answerResults[i]) failedWords.add(_words[i]);
      }
    }
    return Scaffold(
      body: SafeArea(
        child: ResponsiveContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: LeoSprite(
                  pose: passed
                      ? (percentage >= 80 ? LeoPose.celebrate : LeoPose.smile)
                      : LeoPose.meow,
                  size: 160,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                passed
                    ? (percentage >= 80
                        ? 'Brilliant!'
                        : percentage >= 50
                            ? 'Good work!'
                            : 'Well done!')
                    : 'Keep going!',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              if (!passed) ...[
                const SizedBox(height: 8),
                Text(
                  'Let\'s try the tricky ones again!',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '${_correctCount} of ${_words.length} correct',
                  style: const TextStyle(fontSize: 15, color: AppColors.muted),
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                const SizedBox(height: 8),
                Text(
                  '$_correctCount of ${_words.length} correct',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
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
                    'Perfect lesson!',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
              const Spacer(),
              if (!passed) ...[
                FilledButton(
                  onPressed: _retryFailed,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                  ),
                  child: const Text(
                    'Try again',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ] else ...[
                FilledButton(
                  onPressed: _finish,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

enum _LessonPhase { intro, introduce, quiz }

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
                  fontWeight:
                      correct || wrong ? FontWeight.w800 : FontWeight.w600,
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

class _TutorialBubble extends StatelessWidget {
  const _TutorialBubble({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7E8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.persimmon.withValues(alpha: .2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🐱', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
