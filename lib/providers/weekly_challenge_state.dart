import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../config/storage_keys.dart';
import '../data/word_bank.dart';
import '../models/app_models.dart';
import 'word_progress_state.dart';

const _boxName = StorageKeys.userData;

Box<dynamic>? get _box =>
    Hive.isBoxOpen(_boxName) ? Hive.box<dynamic>(_boxName) : null;

enum ChallengeType { vocabulary, speed, memory, culture }

extension ChallengeTypeX on ChallengeType {
  String get label => switch (this) {
    ChallengeType.vocabulary => 'Vocabulary Sprint',
    ChallengeType.speed => 'Speed Round',
    ChallengeType.memory => 'Memory Test',
    ChallengeType.culture => 'Culture Quiz',
  };

  String get description => switch (this) {
    ChallengeType.vocabulary =>
      'Match 10 words to their meanings as fast as you can.',
    ChallengeType.speed =>
      'Answer 15 questions in 60 seconds. Quick thinking wins!',
    ChallengeType.memory =>
      'Recall 8 words from your recent lessons without hints.',
    ChallengeType.culture =>
      'Test your knowledge of Japanese customs and traditions.',
  };

  String get emoji => switch (this) {
    ChallengeType.vocabulary => '📝',
    ChallengeType.speed => '⚡',
    ChallengeType.memory => '🧠',
    ChallengeType.culture => '🎌',
  };
}

class WeeklyChallenge {
  const WeeklyChallenge({
    required this.challengeType,
    required this.weekStart,
    required this.completed,
    required this.streakWeeks,
    required this.bestScore,
  });

  final ChallengeType challengeType;
  final DateTime weekStart;
  final bool completed;
  final int streakWeeks;
  final int bestScore;

  bool get isAvailable {
    final now = DateTime.now();
    return !completed && now.difference(weekStart).inDays < 7;
  }

  int get daysRemaining =>
      (7 - DateTime.now().difference(weekStart).inDays).clamp(0, 7);

  String get xpReward => completed ? '150 XP' : '150 XP';
}

class WeeklyChallengeNotifier extends Notifier<WeeklyChallenge> {
  static const _key = 'weekly_challenge_v1';

  @override
  WeeklyChallenge build() {
    final raw = _box?.get(_key);
    if (raw is! Map) return _generateNewChallenge();

    final storedType = '${raw['challengeType'] ?? ''}';
    final type =
        ChallengeType.values.where((t) => t.name == storedType).firstOrNull ??
        ChallengeType.vocabulary;

    final weekStartStr = '${raw['weekStart'] ?? ''}';
    final weekStart = DateTime.tryParse(weekStartStr) ?? DateTime.now();
    final currentWeekStart = _weekStartFor(DateTime.now());
    final storedWeekStart = _weekStartFor(weekStart);
    final weeksElapsed =
        currentWeekStart.difference(storedWeekStart).inDays ~/ 7;

    if (weeksElapsed != 0) {
      final previousCompleted = raw['completed'] == true;
      final previousStreak = _storedInt(raw['streakWeeks']);
      return _generateNewChallenge(
        weekStart: currentWeekStart,
        streakWeeks: weeksElapsed == 1 && previousCompleted
            ? previousStreak
            : 0,
        bestScore: _storedInt(raw['bestScore']),
      );
    }

    return WeeklyChallenge(
      challengeType: type,
      weekStart: storedWeekStart,
      completed: raw['completed'] == true,
      streakWeeks: _storedInt(raw['streakWeeks']),
      bestScore: _storedInt(raw['bestScore']),
    );
  }

  WeeklyChallenge _generateNewChallenge({
    DateTime? weekStart,
    int streakWeeks = 0,
    int bestScore = 0,
  }) {
    final monday = weekStart ?? _weekStartFor(DateTime.now());
    final rng = math.Random(monday.millisecondsSinceEpoch);
    final type = ChallengeType.values[rng.nextInt(ChallengeType.values.length)];
    return WeeklyChallenge(
      challengeType: type,
      weekStart: monday,
      completed: false,
      streakWeeks: streakWeeks,
      bestScore: bestScore,
    );
  }

  DateTime _weekStartFor(DateTime value) {
    final monday = value.subtract(Duration(days: value.weekday - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }

  int _storedInt(dynamic value) => value is num ? value.toInt() : 0;

  List<Word> generateChallengeWords(WordProgress wordProgress) {
    final rng = math.Random();
    final available = wordBank
        .where((w) => wordProgress.completedWords.contains(w.id))
        .toList();
    if (available.length >= 10) {
      available.shuffle(rng);
      return available.take(10).toList();
    }
    final pool = wordBank
        .where((w) => w.tier.index <= wordProgress.currentTier.index)
        .toList();
    pool.shuffle(rng);
    return pool.take(10).toList();
  }

  Future<void> completeChallenge(int score) async {
    final newStreak = score >= 70 ? state.streakWeeks + 1 : 0;
    state = WeeklyChallenge(
      challengeType: state.challengeType,
      weekStart: state.weekStart,
      completed: true,
      streakWeeks: newStreak,
      bestScore: score > state.bestScore ? score : state.bestScore,
    );
    await _persist();
  }

  Future<void> _persist() async {
    await _box?.put(_key, {
      'challengeType': state.challengeType.name,
      'weekStart': state.weekStart.toIso8601String(),
      'completed': state.completed,
      'streakWeeks': state.streakWeeks,
      'bestScore': state.bestScore,
    });
  }
}

final weeklyChallengeProvider =
    NotifierProvider<WeeklyChallengeNotifier, WeeklyChallenge>(
      WeeklyChallengeNotifier.new,
    );
