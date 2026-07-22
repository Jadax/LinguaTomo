import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/achievement_data.dart';
import '../models/app_models.dart';
import 'app_state.dart';
import 'festival_state.dart';
import 'grammar_state.dart';

/// The single place where an [AchievementSnapshot] is assembled. Views must
/// use this provider rather than rebuilding the snapshot locally, so new
/// metrics only ever need one wiring point.
final achievementSnapshotProvider = Provider<AchievementSnapshot>((ref) {
  final progress = ref.watch(progressProvider);
  final grammar = ref.watch(grammarGardenProvider);
  final handwriting = ref.watch(handwritingHistoryProvider);
  final festivals = ref.watch(festivalMemoryProvider);
  final placed = ref.watch(nestDisplayProvider);
  return AchievementSnapshot(
    missions: progress.completedMissions.length,
    postcards: progress.completedPostcards.length,
    streak: progress.streak,
    handwritingAttempts: handwriting.length,
    bestHandwriting: handwriting.fold(
      0,
      (best, item) => item.score > best ? item.score : best,
    ),
    grammarPlanted: grammar.cards.length,
    grammarReviews: grammar.reviewCount,
    cultureEvidence: progress.skillEvidence[SkillArea.culture] ?? 0,
    interactionEvidence: progress.skillEvidence[SkillArea.interaction] ?? 0,
    xp: progress.xp,
    festivalsCelebrated: celebratedFestivalIds(festivals).length,
    seasonsCelebrated: celebratedSeasons(festivals).length,
    summerFestivals: summerFestivalCount(festivals),
    winterFestivals: winterFestivalCount(festivals),
    nestItemsPlaced: placed.length,
  );
});

/// Every achievement currently unlocked, in catalogue order.
final unlockedAchievementsProvider = Provider<List<AchievementDefinition>>((
  ref,
) {
  final snapshot = ref.watch(achievementSnapshotProvider);
  return achievements.where((item) => item.unlocked(snapshot)).toList();
});
