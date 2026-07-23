import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../config/storage_keys.dart';
import '../data/word_bank.dart';
import '../models/app_models.dart';

const _boxName = StorageKeys.userData;

Box<dynamic>? get _box =>
    Hive.isBoxOpen(_boxName) ? Hive.box<dynamic>(_boxName) : null;

class WordProgress {
  const WordProgress({
    this.completedWords = const {},
    this.currentTier = DifficultyTier.starter,
    this.wordLessonHistory = const [],
    this.perfectLessonCount = 0,
    this.wordActivityDates = const {},
  });

  final Set<String> completedWords;
  final DifficultyTier currentTier;
  final List<String> wordLessonHistory;
  final int perfectLessonCount;
  final Set<String> wordActivityDates;

  int get wordsLearned => completedWords.length;

  int get wordStreak {
    if (wordActivityDates.isEmpty) return 0;
    var cursor = DateTime.now();
    var count = 0;
    while (wordActivityDates.contains(_dateKey(cursor))) {
      count++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    if (count == 0) {
      cursor = DateTime.now().subtract(const Duration(days: 1));
      while (wordActivityDates.contains(_dateKey(cursor))) {
        count++;
        cursor = cursor.subtract(const Duration(days: 1));
      }
    }
    return count;
  }

  int get categoriesCompleted {
    var count = 0;
    for (final category in WordCategory.values) {
      final wordsInCategory = wordsForCategory(category);
      if (wordsInCategory.every((w) => completedWords.contains(w.id))) {
        count++;
      }
    }
    return count;
  }

  bool get postcardsUnlocked => wordsLearned >= 10;

  int get availablePostcardCount {
    if (wordsLearned < 10) return 0;
    if (wordsLearned < 20) return 2;
    if (wordsLearned < 30) return 5;
    if (wordsLearned < 50) return 9;
    if (wordsLearned < 75) return 15;
    if (wordsLearned < 100) return 23;
    return 30;
  }

  bool get memoryGardenUnlocked =>
      wordsLearned >= 5 || wordLessonHistory.isNotEmpty;

  DifficultyTier get highestUnlockedTier {
    final levels = DifficultyTier.values;
    for (var i = levels.length - 1; i >= 0; i--) {
      final tierWords = wordsForTier(levels[i]);
      final completedInTier = tierWords
          .where((w) => completedWords.contains(w.id))
          .length;
      if (completedInTier >= (tierWords.length * 0.40).ceil()) {
        if (i + 1 < levels.length) return levels[i + 1];
        return levels[i];
      }
    }
    return DifficultyTier.starter;
  }

  List<Word> get currentTierWords => wordsForTier(currentTier);

  List<Word> get availableWords {
    final available = <Word>[];
    for (final tier in DifficultyTier.values) {
      if (tier.index <= currentTier.index) {
        available.addAll(wordsForTier(tier));
      }
    }
    return available;
  }

  int tierProgress(DifficultyTier tier) {
    final tierWords = wordsForTier(tier);
    return tierWords.where((w) => completedWords.contains(w.id)).length;
  }

  int categoryProgress(WordCategory category, DifficultyTier tier) {
    return wordBank
        .where((w) => w.category == category && w.tier == tier)
        .where((w) => completedWords.contains(w.id))
        .length;
  }

  String _dateKey(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}

class WordProgressNotifier extends Notifier<WordProgress> {
  static const _key = 'word_progress_v1';

  @override
  WordProgress build() {
    final raw = _box?.get(_key);
    if (raw is! Map) return const WordProgress();
    final completed = <String>{};
    if (raw['completedWords'] is Iterable) {
      for (final item in (raw['completedWords'] as Iterable)) {
        completed.add('$item');
      }
    }
    final history = <String>[];
    if (raw['wordLessonHistory'] is Iterable) {
      for (final item in (raw['wordLessonHistory'] as Iterable)) {
        history.add('$item');
      }
    }
    final activityDates = <String>{};
    if (raw['wordActivityDates'] is Iterable) {
      for (final item in (raw['wordActivityDates'] as Iterable)) {
        activityDates.add('$item');
      }
    }
    final storedTier = '${raw['currentTier'] ?? ''}';
    final tier = DifficultyTier.values
            .where((t) => t.name == storedTier)
            .firstOrNull ??
        DifficultyTier.starter;
    return WordProgress(
      completedWords: completed,
      currentTier: tier,
      wordLessonHistory: history,
      perfectLessonCount: (raw['perfectLessonCount'] as num?)?.toInt() ?? 0,
      wordActivityDates: activityDates,
    );
  }

  Future<void> completeWord(String wordId) async {
    if (state.completedWords.contains(wordId)) return;
    state = WordProgress(
      completedWords: {...state.completedWords, wordId},
      currentTier: state.currentTier,
      wordLessonHistory: state.wordLessonHistory,
      perfectLessonCount: state.perfectLessonCount,
      wordActivityDates: {
        ...state.wordActivityDates,
        _dateKey(DateTime.now()),
      },
    );
    _maybeUnlockTier();
    await _persist();
  }

  Future<void> completeLesson({
    required List<String> wordIds,
    required int correctCount,
  }) async {
    final isPerfect = correctCount == wordIds.length;
    final history = [...state.wordLessonHistory, wordIds.join(',')];
    state = WordProgress(
      completedWords: {...state.completedWords, ...wordIds},
      currentTier: state.currentTier,
      wordLessonHistory: history,
      perfectLessonCount: state.perfectLessonCount + (isPerfect ? 1 : 0),
      wordActivityDates: {
        ...state.wordActivityDates,
        _dateKey(DateTime.now()),
      },
    );
    _maybeUnlockTier();
    await _persist();
  }

  Future<void> setTier(DifficultyTier tier) async {
    if (tier == state.currentTier) return;
    state = WordProgress(
      completedWords: state.completedWords,
      currentTier: tier,
      wordLessonHistory: state.wordLessonHistory,
      perfectLessonCount: state.perfectLessonCount,
      wordActivityDates: state.wordActivityDates,
    );
    await _persist();
  }

  void _maybeUnlockTier() {
    final highest = state.highestUnlockedTier;
    if (highest.index > state.currentTier.index) {
      state = WordProgress(
        completedWords: state.completedWords,
        currentTier: highest,
        wordLessonHistory: state.wordLessonHistory,
        perfectLessonCount: state.perfectLessonCount,
        wordActivityDates: state.wordActivityDates,
      );
    }
  }

  List<Word> generateLesson({int wordCount = 5}) {
    final ordered = wordsForTierInOrder(state.currentTier);
    final uncompleted = ordered
        .where((w) => !state.completedWords.contains(w.id))
        .toList();
    if (uncompleted.isNotEmpty) {
      return uncompleted.take(wordCount).toList();
    }
    // All words in current tier done — review from path order.
    return ordered.take(wordCount).toList();
  }

  Future<void> _persist() async {
    await _box?.put(_key, {
      'completedWords': state.completedWords.toList(),
      'currentTier': state.currentTier.name,
      'wordLessonHistory': state.wordLessonHistory,
      'perfectLessonCount': state.perfectLessonCount,
      'wordActivityDates': state.wordActivityDates.toList(),
    });
  }

  String _dateKey(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}

final wordProgressProvider =
    NotifierProvider<WordProgressNotifier, WordProgress>(
      WordProgressNotifier.new,
    );

final currentLessonProvider = Provider<List<Word>>((ref) {
  final notifier = ref.read(wordProgressProvider.notifier);
  return notifier.generateLesson();
});
