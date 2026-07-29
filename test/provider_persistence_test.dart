import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fsrs/fsrs.dart';
import 'package:hive/hive.dart';
import 'package:linguatomo/config/storage_keys.dart';
import 'package:linguatomo/data/curriculum_data.dart';
import 'package:linguatomo/data/word_bank.dart';
import 'package:linguatomo/providers/app_state.dart';
import 'package:linguatomo/providers/review_state.dart';
import 'package:linguatomo/providers/weekly_challenge_state.dart';
import 'package:linguatomo/providers/word_progress_state.dart';

void main() {
  late Directory hiveDirectory;
  late Box<dynamic> userBox;

  setUp(() async {
    hiveDirectory = Directory.systemTemp.createTempSync(
      'linguatomo_provider_test_',
    );
    Hive.init(hiveDirectory.path);
    userBox = await Hive.openBox<dynamic>(StorageKeys.userData);
  });

  tearDown(() async {
    await Hive.close();
    if (hiveDirectory.existsSync()) {
      hiveDirectory.deleteSync(recursive: true);
    }
  });

  test('learner progress survives a provider-container restart', () async {
    var container = ProviderContainer();
    final mission = missions.first;

    await container.read(progressProvider.notifier).completeMission(mission);
    final saved = container.read(progressProvider);
    expect(saved.completedMissions, contains(mission.id));
    expect(saved.unlockedRewards, contains(mission.reward));
    expect(saved.xp, mission.xp);
    for (final skill in mission.skills) {
      expect(saved.skillEvidence[skill], 1);
    }

    container.dispose();
    container = ProviderContainer();
    final restored = container.read(progressProvider);

    expect(restored.completedMissions, saved.completedMissions);
    expect(restored.unlockedRewards, saved.unlockedRewards);
    expect(restored.skillEvidence, saved.skillEvidence);
    expect(restored.activityDates, saved.activityDates);
    expect(restored.xp, saved.xp);
    container.dispose();
  });

  test(
    'placement clamps safely and restores every placed-out mission',
    () async {
      var container = ProviderContainer();
      final notifier = container.read(progressProvider.notifier);

      await notifier.applyPlacement(-10);
      expect(container.read(progressProvider).placedOutMissions, isEmpty);

      await notifier.applyPlacement(missions.length + 10);
      expect(
        container.read(progressProvider).placedOutMissions,
        missions.map((mission) => mission.id).toSet(),
      );
      expect(container.read(nextMissionProvider), isNull);

      container.dispose();
      container = ProviderContainer();
      expect(
        container.read(progressProvider).placedOutMissions.length,
        missions.length,
      );
      expect(container.read(nextMissionProvider), isNull);
      container.dispose();
    },
  );

  test('word growth and lesson history survive restoration', () async {
    var container = ProviderContainer();
    final words = wordsForTierInOrder(
      container.read(wordProgressProvider).currentTier,
    ).take(3).toList();

    await container
        .read(wordProgressProvider.notifier)
        .completeLesson(
          wordIds: words.map((word) => word.id).toList(),
          correctCount: 2,
          correctWordIds: words.take(2).map((word) => word.id).toList(),
        );
    final saved = container.read(wordProgressProvider);
    expect(saved.completedWords, containsAll(words.map((word) => word.id)));
    expect(saved.growthStage(words.first.id), WordGrowthStage.sprout);
    expect(saved.growthStage(words.last.id), WordGrowthStage.seed);

    container.dispose();
    container = ProviderContainer();
    final restored = container.read(wordProgressProvider);

    expect(restored.completedWords, saved.completedWords);
    expect(restored.wordLessonHistory, saved.wordLessonHistory);
    expect(restored.wordCorrectCounts, saved.wordCorrectCounts);
    expect(restored.growthStage(words.first.id), WordGrowthStage.sprout);
    container.dispose();
  });

  test('FSRS cards survive rating and provider restoration', () async {
    var container = ProviderContainer();
    final mission = missions.first;
    await container.read(progressProvider.notifier).completeMission(mission);

    final initialDeck = container.read(reviewDeckProvider);
    expect(initialDeck.cards, contains(mission.id));
    await container
        .read(reviewDeckProvider.notifier)
        .rate(mission.id, Rating.good);
    final ratedCard = container.read(reviewDeckProvider).cards[mission.id]!;
    final ratedMap = ratedCard.toMap();

    container.dispose();
    container = ProviderContainer();
    final restoredCard = container.read(reviewDeckProvider).cards[mission.id]!;

    expect(restoredCard.toMap(), ratedMap);
    container.dispose();
  });

  test('weekly challenge rolls over after a missed week', () async {
    final now = DateTime.now();
    final currentMonday = DateTime(
      now.subtract(Duration(days: now.weekday - 1)).year,
      now.subtract(Duration(days: now.weekday - 1)).month,
      now.subtract(Duration(days: now.weekday - 1)).day,
    );
    await userBox.put('weekly_challenge_v1', {
      'challengeType': ChallengeType.speed.name,
      'weekStart': currentMonday
          .subtract(const Duration(days: 14))
          .toIso8601String(),
      'completed': true,
      'streakWeeks': 5,
      'bestScore': 90,
    });

    var container = ProviderContainer();
    final rolledOver = container.read(weeklyChallengeProvider);
    expect(rolledOver.weekStart, currentMonday);
    expect(rolledOver.completed, isFalse);
    expect(rolledOver.streakWeeks, 0);
    expect(rolledOver.bestScore, 90);

    await container
        .read(weeklyChallengeProvider.notifier)
        .completeChallenge(80);
    container.dispose();
    container = ProviderContainer();
    final restored = container.read(weeklyChallengeProvider);

    expect(restored.completed, isTrue);
    expect(restored.streakWeeks, 1);
    expect(restored.bestScore, 90);
    container.dispose();
  });

  test('malformed Hive payloads fall back without blocking learning', () async {
    await userBox.put('learner_progress_v2', {
      'completedMissions': 'not-a-list',
      'skillEvidence': {'reading': 'not-a-number'},
      'xp': 'not-a-number',
      'streakFreezes': <String>[],
    });
    await userBox.put('word_progress_v1', {
      'currentTier': 'unknown',
      'perfectLessonCount': 'not-a-number',
      'wordCorrectCounts': {'s_001': 'not-a-number'},
    });
    await userBox.put('fsrs_cards_v1', {
      'broken': {'unexpected': true},
    });
    await userBox.put('weekly_challenge_v1', {
      'challengeType': ChallengeType.vocabulary.name,
      'weekStart': DateTime.now().toIso8601String(),
      'completed': false,
      'streakWeeks': 'not-a-number',
      'bestScore': <String>[],
    });

    final container = ProviderContainer();

    expect(container.read(progressProvider).xp, 0);
    expect(container.read(progressProvider).streakFreezes, 2);
    expect(container.read(wordProgressProvider).perfectLessonCount, 0);
    expect(container.read(wordProgressProvider).wordCorrectCounts, isEmpty);
    expect(container.read(reviewDeckProvider).cards, isEmpty);
    expect(container.read(weeklyChallengeProvider).streakWeeks, 0);
    expect(container.read(weeklyChallengeProvider).bestScore, 0);
    container.dispose();
  });
}
