import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../config/storage_keys.dart';
import '../data/curriculum_data.dart';
import '../models/app_models.dart';

const _boxName = StorageKeys.userData;

Box<dynamic>? get _box =>
    Hive.isBoxOpen(_boxName) ? Hive.box<dynamic>(_boxName) : null;

class ExperienceNotifier extends Notifier<ExperienceMode> {
  static const _key = 'experience_mode';

  @override
  ExperienceMode build() {
    final stored = _box?.get(_key) as String?;
    return ExperienceMode.values
            .where((mode) => mode.name == stored)
            .firstOrNull ??
        ExperienceMode.standard;
  }

  Future<void> setMode(ExperienceMode mode) async {
    state = mode;
    await _box?.put(_key, mode.name);
  }
}

final experienceProvider = NotifierProvider<ExperienceNotifier, ExperienceMode>(
  ExperienceNotifier.new,
);

class LearnerProfileNotifier extends Notifier<LearnerProfile> {
  static const _key = 'learner_profile_v1';

  @override
  LearnerProfile build() {
    final raw = _box?.get(_key);
    if (raw is! Map) return const LearnerProfile();
    final storedStart = '${raw['start'] ?? ''}';
    return LearnerProfile(
      start: JourneyStart.values
          .where((value) => value.name == storedStart)
          .firstOrNull,
      onboardingComplete: raw['onboardingComplete'] == true,
    );
  }

  Future<void> chooseStart(JourneyStart start) async {
    state = LearnerProfile(start: start, onboardingComplete: true);
    await _box?.put(_key, {'start': start.name, 'onboardingComplete': true});
  }

  Future<void> reset() async {
    state = const LearnerProfile();
    await _box?.delete(_key);
  }
}

final learnerProfileProvider =
    NotifierProvider<LearnerProfileNotifier, LearnerProfile>(
      LearnerProfileNotifier.new,
    );

class ProgressNotifier extends Notifier<LearnerProgress> {
  static const _key = 'learner_progress_v2';

  @override
  LearnerProgress build() {
    final raw = _box?.get(_key);
    if (raw is! Map) return const LearnerProgress();
    final skills = <SkillArea, int>{};
    final rawSkills = raw['skillEvidence'];
    if (rawSkills is Map) {
      for (final entry in rawSkills.entries) {
        final skill = SkillArea.values
            .where((value) => value.name == entry.key)
            .firstOrNull;
        if (skill != null && entry.value is num) {
          skills[skill] = (entry.value as num).toInt();
        }
      }
    }
    return LearnerProgress(
      completedMissions: _stringSet(raw['completedMissions']),
      placedOutMissions: _stringSet(raw['placedOutMissions']),
      completedPostcards: _stringSet(raw['completedPostcards']),
      unlockedRewards: _stringSet(raw['unlockedRewards']).isEmpty
          ? const {'Welcome cushion'}
          : _stringSet(raw['unlockedRewards']),
      skillEvidence: skills,
      activityDates: _stringSet(raw['activityDates']),
      xp: (raw['xp'] as num?)?.toInt() ?? 0,
      streakFreezes: (raw['streakFreezes'] as num?)?.toInt() ?? 2,
    );
  }

  Future<void> completeMission(Mission mission) async {
    if (state.completedMissions.contains(mission.id)) return;
    final evidence = {...state.skillEvidence};
    for (final skill in mission.skills) {
      evidence[skill] = (evidence[skill] ?? 0) + 1;
    }
    state = LearnerProgress(
      completedMissions: {...state.completedMissions, mission.id},
      placedOutMissions: state.placedOutMissions,
      completedPostcards: state.completedPostcards,
      unlockedRewards: {...state.unlockedRewards, mission.reward},
      skillEvidence: evidence,
      activityDates: {...state.activityDates, dateKey(DateTime.now())},
      xp: state.xp + mission.xp,
      streakFreezes: state.streakFreezes,
    );
    await _persist();
  }

  Future<void> completePostcard(String id) async {
    if (state.completedPostcards.contains(id)) return;
    state = LearnerProgress(
      completedMissions: state.completedMissions,
      placedOutMissions: state.placedOutMissions,
      completedPostcards: {...state.completedPostcards, id},
      unlockedRewards: state.unlockedRewards,
      skillEvidence: state.skillEvidence,
      activityDates: {...state.activityDates, dateKey(DateTime.now())},
      xp: state.xp + 10,
      streakFreezes: state.streakFreezes,
    );
    await _persist();
  }

  Future<void> _persist() async {
    await _box?.put(_key, {
      'completedMissions': state.completedMissions.toList(),
      'placedOutMissions': state.placedOutMissions.toList(),
      'completedPostcards': state.completedPostcards.toList(),
      'unlockedRewards': state.unlockedRewards.toList(),
      'skillEvidence': {
        for (final entry in state.skillEvidence.entries)
          entry.key.name: entry.value,
      },
      'activityDates': state.activityDates.toList(),
      'xp': state.xp,
      'streakFreezes': state.streakFreezes,
    });
  }

  Future<void> applyPlacement(int missionsToSkip) async {
    final skipped = missions
        .take(missionsToSkip.clamp(0, missions.length))
        .map((mission) => mission.id)
        .toSet();
    state = LearnerProgress(
      completedMissions: state.completedMissions,
      placedOutMissions: skipped,
      completedPostcards: state.completedPostcards,
      unlockedRewards: state.unlockedRewards,
      skillEvidence: state.skillEvidence,
      activityDates: state.activityDates,
      xp: state.xp,
      streakFreezes: state.streakFreezes,
    );
    await _persist();
  }
}

Set<String> _stringSet(dynamic value) =>
    value is Iterable ? value.map((item) => '$item').toSet() : <String>{};

final progressProvider = NotifierProvider<ProgressNotifier, LearnerProgress>(
  ProgressNotifier.new,
);

class HandwritingHistoryNotifier extends Notifier<List<HandwritingRecord>> {
  static const _key = 'handwriting_photo_history_v1';

  @override
  List<HandwritingRecord> build() {
    final raw = _box?.get(_key);
    if (raw is! Iterable) return const [];
    return raw.whereType<Map>().map((item) {
      return HandwritingRecord(
        character: '${item['character'] ?? ''}',
        score: (item['score'] as num?)?.toInt() ?? 0,
        accuracy: (item['accuracy'] as num?)?.toInt() ?? 0,
        balance: (item['balance'] as num?)?.toInt() ?? 0,
        createdAt: DateTime.tryParse('${item['createdAt']}') ?? DateTime.now(),
        evidenceMode: '${item['evidenceMode'] ?? 'photo'}',
      );
    }).toList();
  }

  Future<void> add(HandwritingRecord record) async {
    state = [record, ...state].take(100).toList();
    await _box?.put(
      _key,
      state
          .map(
            (item) => {
              'character': item.character,
              'score': item.score,
              'accuracy': item.accuracy,
              'balance': item.balance,
              'createdAt': item.createdAt.toIso8601String(),
              'evidenceMode': item.evidenceMode,
            },
          )
          .toList(),
    );
  }
}

final handwritingHistoryProvider =
    NotifierProvider<HandwritingHistoryNotifier, List<HandwritingRecord>>(
      HandwritingHistoryNotifier.new,
    );

final nextMissionProvider = Provider<Mission?>((ref) {
  final progress = ref.watch(progressProvider);
  for (final mission in missions) {
    if (progress.completedMissions.contains(mission.id) ||
        progress.placedOutMissions.contains(mission.id)) {
      continue;
    }
    if (mission.prerequisite == null ||
        progress.completedMissions.contains(mission.prerequisite) ||
        progress.placedOutMissions.contains(mission.prerequisite)) {
      return mission;
    }
  }
  return null;
});
