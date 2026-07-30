import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/local_store.dart';
import '../data/word_bank.dart';
import '../models/app_models.dart';

enum WordGrowthStage { seed, sprout, bud, bloom }

extension WordGrowthStageX on WordGrowthStage {
  String get label => switch (this) {
    WordGrowthStage.seed => 'Seed',
    WordGrowthStage.sprout => 'Sprout',
    WordGrowthStage.bud => 'Bud',
    WordGrowthStage.bloom => 'Bloom',
  };

  String get emoji => switch (this) {
    WordGrowthStage.seed => '🌱',
    WordGrowthStage.sprout => '🌿',
    WordGrowthStage.bud => '🌸',
    WordGrowthStage.bloom => '🌺',
  };
}

class WordProgress {
  const WordProgress({
    this.completedWords = const {},
    this.currentTier = DifficultyTier.starter,
    this.wordLessonHistory = const [],
    this.perfectLessonCount = 0,
    this.wordActivityDates = const {},
    this.wordCorrectCounts = const {},
  });

  final Set<String> completedWords;
  final DifficultyTier currentTier;
  final List<String> wordLessonHistory;
  final int perfectLessonCount;
  final Set<String> wordActivityDates;
  final Map<String, int> wordCorrectCounts;

  WordGrowthStage growthStage(String wordId) {
    final count = wordCorrectCounts[wordId] ?? 0;
    if (count >= 5) return WordGrowthStage.bloom;
    if (count >= 3) return WordGrowthStage.bud;
    if (count >= 1) return WordGrowthStage.sprout;
    return WordGrowthStage.seed;
  }

  WordProgress copyWith({
    Set<String>? completedWords,
    DifficultyTier? currentTier,
    List<String>? wordLessonHistory,
    int? perfectLessonCount,
    Set<String>? wordActivityDates,
    Map<String, int>? wordCorrectCounts,
  }) => WordProgress(
    completedWords: completedWords ?? this.completedWords,
    currentTier: currentTier ?? this.currentTier,
    wordLessonHistory: wordLessonHistory ?? this.wordLessonHistory,
    perfectLessonCount: perfectLessonCount ?? this.perfectLessonCount,
    wordActivityDates: wordActivityDates ?? this.wordActivityDates,
    wordCorrectCounts: wordCorrectCounts ?? this.wordCorrectCounts,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WordProgress &&
          setEquals(completedWords, other.completedWords) &&
          currentTier == other.currentTier &&
          listEquals(wordLessonHistory, other.wordLessonHistory) &&
          perfectLessonCount == other.perfectLessonCount &&
          setEquals(wordActivityDates, other.wordActivityDates) &&
          mapEquals(wordCorrectCounts, other.wordCorrectCounts);

  @override
  int get hashCode => Object.hash(
    completedWords.length,
    currentTier,
    wordLessonHistory.length,
    perfectLessonCount,
    wordActivityDates.length,
    wordCorrectCounts.length,
  );

  int get wordsLearned => completedWords.length;

  int get wordStreak => consecutiveDayStreak(wordActivityDates);

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

  int categoryProgress(WordCategory category, DifficultyTier tier) =>
      wordsForCategoryAndTier(
        category,
        tier,
      ).where((w) => completedWords.contains(w.id)).length;
}

class WordProgressNotifier extends Notifier<WordProgress> {
  static const _key = 'word_progress_v1';

  @override
  WordProgress build() {
    final raw = localStore?.get(_key);
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
    final counts = <String, int>{};
    if (raw['wordCorrectCounts'] is Map) {
      for (final entry in (raw['wordCorrectCounts'] as Map).entries) {
        if (entry.value is num) {
          counts['${entry.key}'] = (entry.value as num).toInt();
        }
      }
    }
    final storedTier = '${raw['currentTier'] ?? ''}';
    final tier =
        DifficultyTier.values.where((t) => t.name == storedTier).firstOrNull ??
        DifficultyTier.starter;
    return WordProgress(
      completedWords: completed,
      currentTier: tier,
      wordLessonHistory: history,
      perfectLessonCount: raw['perfectLessonCount'] is num
          ? (raw['perfectLessonCount'] as num).toInt()
          : 0,
      wordActivityDates: activityDates,
      wordCorrectCounts: counts,
    );
  }

  Future<void> completeWord(String wordId) async {
    if (state.completedWords.contains(wordId)) return;
    final updatedCounts = {
      ...state.wordCorrectCounts,
      wordId: (state.wordCorrectCounts[wordId] ?? 0) + 1,
    };
    state = state.copyWith(
      completedWords: {...state.completedWords, wordId},
      wordActivityDates: {...state.wordActivityDates, dateKey(DateTime.now())},
      wordCorrectCounts: updatedCounts,
    );
    _maybeUnlockTier();
    await _persist();
  }

  Future<void> completeLesson({
    required List<String> wordIds,
    required int correctCount,
    List<String>? correctWordIds,
  }) async {
    final isPerfect = correctCount == wordIds.length;
    final history = [...state.wordLessonHistory, wordIds.join(',')];
    final updatedCounts = {...state.wordCorrectCounts};
    for (final id in (correctWordIds ?? wordIds)) {
      if (wordIds.contains(id)) {
        updatedCounts[id] = (updatedCounts[id] ?? 0) + 1;
      }
    }
    state = state.copyWith(
      completedWords: {...state.completedWords, ...wordIds},
      wordLessonHistory: history,
      perfectLessonCount: state.perfectLessonCount + (isPerfect ? 1 : 0),
      wordActivityDates: {...state.wordActivityDates, dateKey(DateTime.now())},
      wordCorrectCounts: updatedCounts,
    );
    _maybeUnlockTier();
    await _persist();
  }

  Future<void> setTier(DifficultyTier tier) async {
    if (tier == state.currentTier) return;
    state = state.copyWith(currentTier: tier);
    await _persist();
  }

  void _maybeUnlockTier() {
    final highest = state.highestUnlockedTier;
    if (highest.index > state.currentTier.index) {
      state = state.copyWith(currentTier: highest);
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

  List<Word> generateThemedLesson(List<String> wordIds, {int wordCount = 5}) {
    final themedWords = wordIds
        .map((id) => wordBankById[id])
        .whereType<Word>()
        .toList();
    final uncompleted = themedWords
        .where((w) => !state.completedWords.contains(w.id))
        .toList();
    if (uncompleted.length >= wordCount) {
      return uncompleted.take(wordCount).toList();
    }
    final completed = themedWords
        .where((w) => state.completedWords.contains(w.id))
        .toList();
    final pool = [...uncompleted, ...completed];
    return pool.take(wordCount).toList();
  }

  /// Folds a downloaded snapshot into local word progress, keeping the union
  /// of everything learned on either device. Returns `false` when the remote
  /// adds nothing, so an unchanged snapshot is never re-persisted or re-sent.
  Future<bool> mergeCloudSnapshot(Map<String, dynamic> remote) async {
    final counts = {...state.wordCorrectCounts};
    final rawCounts = remote['word_correct_counts'];
    if (rawCounts is Map) {
      for (final entry in rawCounts.entries) {
        if (entry.value is num) {
          final id = '${entry.key}';
          final incoming = (entry.value as num).toInt();
          if (incoming > (counts[id] ?? 0)) counts[id] = incoming;
        }
      }
    }
    final remoteHistory = _stringList(remote['word_lesson_history']);
    final merged = state.copyWith(
      completedWords: {
        ...state.completedWords,
        ..._stringList(remote['completed_words']),
      },
      // Lesson history is an append-only log; the longer record wins rather
      // than concatenating and double-counting lessons already held locally.
      wordLessonHistory: remoteHistory.length > state.wordLessonHistory.length
          ? remoteHistory
          : state.wordLessonHistory,
      perfectLessonCount: remote['perfect_lesson_count'] is num
          ? (remote['perfect_lesson_count'] as num).toInt().clamp(
              state.perfectLessonCount,
              1 << 30,
            )
          : state.perfectLessonCount,
      wordActivityDates: {
        ...state.wordActivityDates,
        ..._stringList(remote['word_activity_dates']),
      },
      wordCorrectCounts: counts,
    );
    if (merged == state) return false;
    state = merged;
    _maybeUnlockTier();
    await _persist();
    return true;
  }

  Map<String, dynamic> toCloudSnapshot() => {
    'completed_words': state.completedWords.toList(),
    'current_tier': state.currentTier.name,
    'word_lesson_history': state.wordLessonHistory,
    'perfect_lesson_count': state.perfectLessonCount,
    'word_activity_dates': state.wordActivityDates.toList(),
    'word_correct_counts': state.wordCorrectCounts,
  };

  Future<void> _persist() async {
    await localStore?.put(_key, {
      'completedWords': state.completedWords.toList(),
      'currentTier': state.currentTier.name,
      'wordLessonHistory': state.wordLessonHistory,
      'perfectLessonCount': state.perfectLessonCount,
      'wordActivityDates': state.wordActivityDates.toList(),
      'wordCorrectCounts': state.wordCorrectCounts,
    });
  }
}

List<String> _stringList(dynamic value) =>
    value is Iterable ? value.map((item) => '$item').toList() : const [];

final wordProgressProvider =
    NotifierProvider<WordProgressNotifier, WordProgress>(
      WordProgressNotifier.new,
    );

final currentLessonProvider = Provider<List<Word>>((ref) {
  final notifier = ref.read(wordProgressProvider.notifier);
  return notifier.generateLesson();
});
