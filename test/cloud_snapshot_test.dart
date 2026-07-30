import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:linguatomo/config/storage_keys.dart';
import 'package:linguatomo/models/app_models.dart';
import 'package:linguatomo/providers/app_state.dart';
import 'package:linguatomo/providers/word_progress_state.dart';

/// The cloud snapshot is the learner's only backup. These tests pin the two
/// properties that matter: nothing they have earned may be dropped from it,
/// and folding an unchanged snapshot back in must be a no-op — otherwise the
/// sync debounce re-arms itself and the app syncs in a loop forever.
void main() {
  late Directory hiveDirectory;

  setUp(() async {
    hiveDirectory = Directory.systemTemp.createTempSync(
      'linguatomo_snapshot_test_',
    );
    Hive.init(hiveDirectory.path);
    await Hive.openBox<dynamic>(StorageKeys.userData);
  });

  tearDown(() async {
    await Hive.close();
    if (hiveDirectory.existsSync()) {
      hiveDirectory.deleteSync(recursive: true);
    }
  });

  test('word progress round-trips through a cloud snapshot', () async {
    final source = ProviderContainer();
    await source.read(wordProgressProvider.notifier).completeLesson(
      wordIds: const ['s_01', 's_02', 's_03'],
      correctCount: 3,
      correctWordIds: const ['s_01', 's_02', 's_03'],
    );
    final saved = source.read(wordProgressProvider);
    final snapshot = source
        .read(wordProgressProvider.notifier)
        .toCloudSnapshot();
    source.dispose();

    // A fresh device: empty local store, snapshot arrives from the cloud.
    await Hive.box<dynamic>(StorageKeys.userData).clear();
    final restored = ProviderContainer();
    expect(restored.read(wordProgressProvider).completedWords, isEmpty);

    final changed = await restored
        .read(wordProgressProvider.notifier)
        .mergeCloudSnapshot(snapshot);
    final merged = restored.read(wordProgressProvider);

    expect(changed, isTrue);
    expect(merged.completedWords, saved.completedWords);
    expect(merged.wordCorrectCounts, saved.wordCorrectCounts);
    expect(merged.wordLessonHistory, saved.wordLessonHistory);
    expect(merged.perfectLessonCount, saved.perfectLessonCount);
    expect(merged.wordActivityDates, saved.wordActivityDates);
    restored.dispose();
  });

  test('merging an unchanged snapshot reports no change', () async {
    final container = ProviderContainer();
    await container.read(wordProgressProvider.notifier).completeWord('s_01');
    await container.read(progressProvider.notifier).addXp(40);

    final wordSnapshot = container
        .read(wordProgressProvider.notifier)
        .toCloudSnapshot();
    final progress = container.read(progressProvider);
    final progressSnapshot = {
      'completed_missions': progress.completedMissions.toList(),
      'placed_out_missions': progress.placedOutMissions.toList(),
      'completed_postcards': progress.completedPostcards.toList(),
      'unlocked_rewards': progress.unlockedRewards.toList(),
      'activity_dates': progress.activityDates.toList(),
      'xp': progress.xp,
      'streak_freezes': progress.streakFreezes,
    };

    expect(
      await container
          .read(wordProgressProvider.notifier)
          .mergeCloudSnapshot(wordSnapshot),
      isFalse,
    );
    expect(
      await container
          .read(progressProvider.notifier)
          .mergeCloudSnapshot(progressSnapshot),
      isFalse,
    );
    expect(
      await container
          .read(handwritingHistoryProvider.notifier)
          .mergeCloudSnapshot(const {'handwriting': <dynamic>[]}),
      isFalse,
    );
    container.dispose();
  });

  test('an older schema-1 snapshot never erases local word progress', () async {
    final container = ProviderContainer();
    await container.read(wordProgressProvider.notifier).completeWord('s_01');

    // Schema 1 carried no word keys at all.
    final changed = await container
        .read(wordProgressProvider.notifier)
        .mergeCloudSnapshot(const {'schema_version': 1, 'xp': 10});

    expect(changed, isFalse);
    expect(
      container.read(wordProgressProvider).completedWords,
      contains('s_01'),
    );
    container.dispose();
  });

  test('progress states with equal content compare equal', () {
    const a = LearnerProgress(
      completedMissions: {'m1', 'm2'},
      activityDates: {'2026-07-30'},
      xp: 120,
    );
    const b = LearnerProgress(
      completedMissions: {'m2', 'm1'},
      activityDates: {'2026-07-30'},
      xp: 120,
    );
    const different = LearnerProgress(
      completedMissions: {'m1', 'm2'},
      activityDates: {'2026-07-30'},
      xp: 121,
    );

    expect(a, equals(b));
    expect(a.hashCode, equals(b.hashCode));
    expect(a, isNot(equals(different)));
  });
}
