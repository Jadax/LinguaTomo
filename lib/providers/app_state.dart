import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/local_store.dart';
import '../data/curriculum_data.dart';
import '../models/app_models.dart';

class ExperienceNotifier extends Notifier<ExperienceMode> {
  static const _key = 'experience_mode';

  @override
  ExperienceMode build() {
    final stored = localStore?.get(_key) as String?;
    return ExperienceMode.values
            .where((mode) => mode.name == stored)
            .firstOrNull ??
        ExperienceMode.standard;
  }

  Future<void> setMode(ExperienceMode mode) async {
    state = mode;
    await localStore?.put(_key, mode.name);
  }
}

final experienceProvider = NotifierProvider<ExperienceNotifier, ExperienceMode>(
  ExperienceNotifier.new,
);

class NestEnvironmentNotifier extends Notifier<NestEnvironment> {
  static const _key = 'nest_environment_v1';

  @override
  NestEnvironment build() {
    final stored = '${localStore?.get(_key) ?? ''}';
    return NestEnvironment.values
            .where((environment) => environment.name == stored)
            .firstOrNull ??
        NestEnvironment.fireside;
  }

  Future<void> choose(NestEnvironment environment) async {
    state = environment;
    await localStore?.put(_key, environment.name);
  }
}

final nestEnvironmentProvider =
    NotifierProvider<NestEnvironmentNotifier, NestEnvironment>(
      NestEnvironmentNotifier.new,
    );

class NestDisplayNotifier extends Notifier<List<String>> {
  static const _key = 'nest_display_items_v1';
  static const maxItems = 12;

  @override
  List<String> build() {
    final raw = localStore?.get(_key);
    return raw is Iterable
        ? raw.map((item) => '$item').take(maxItems).toList()
        : const [];
  }

  Future<bool> toggle(String id) async {
    if (state.contains(id)) {
      state = state.where((item) => item != id).toList();
      await localStore?.put(_key, state);
      return true;
    }
    if (state.length >= maxItems) return false;
    state = [...state, id];
    await localStore?.put(_key, state);
    return true;
  }
}

final nestDisplayProvider = NotifierProvider<NestDisplayNotifier, List<String>>(
  NestDisplayNotifier.new,
);

/// Local copy of the learner's cosy-board choice, so achievement counts can
/// be refreshed quietly in the background without opening the account page.
class LeaderboardPrefs {
  const LeaderboardPrefs({this.nickname = '', this.optIn = false});

  final String nickname;
  final bool optIn;
}

class LeaderboardPrefsNotifier extends Notifier<LeaderboardPrefs> {
  static const _key = 'leaderboard_prefs_v1';

  @override
  LeaderboardPrefs build() {
    final raw = localStore?.get(_key);
    if (raw is! Map) return const LeaderboardPrefs();
    return LeaderboardPrefs(
      nickname: '${raw['nickname'] ?? ''}',
      optIn: raw['optIn'] == true,
    );
  }

  Future<void> save(String nickname, bool optIn) async {
    state = LeaderboardPrefs(nickname: nickname, optIn: optIn);
    await localStore?.put(_key, {'nickname': nickname, 'optIn': optIn});
  }
}

final leaderboardPrefsProvider =
    NotifierProvider<LeaderboardPrefsNotifier, LeaderboardPrefs>(
      LeaderboardPrefsNotifier.new,
    );

class LearnerProfileNotifier extends Notifier<LearnerProfile> {
  static const _key = 'learner_profile_v1';

  @override
  LearnerProfile build() {
    final raw = localStore?.get(_key);
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
    await localStore?.put(_key, {'start': start.name, 'onboardingComplete': true});
  }

  Future<void> reset() async {
    state = const LearnerProfile();
    await localStore?.delete(_key);
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
    final raw = localStore?.get(_key);
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
      xp: _storedInt(raw['xp'], 0),
      streakFreezes: _storedInt(raw['streakFreezes'], 2),
    );
  }

  Future<void> completeMission(Mission mission) async {
    if (state.completedMissions.contains(mission.id)) return;
    final evidence = {...state.skillEvidence};
    for (final skill in mission.skills) {
      evidence[skill] = (evidence[skill] ?? 0) + 1;
    }
    state = state.copyWith(
      completedMissions: {...state.completedMissions, mission.id},
      unlockedRewards: {...state.unlockedRewards, mission.reward},
      skillEvidence: evidence,
      activityDates: {...state.activityDates, dateKey(DateTime.now())},
      xp: state.xp + mission.xp,
    );
    await _persist();
  }

  Future<void> completePostcard(String id) async {
    if (state.completedPostcards.contains(id)) return;
    state = state.copyWith(
      completedPostcards: {...state.completedPostcards, id},
      activityDates: {...state.activityDates, dateKey(DateTime.now())},
      xp: state.xp + 10,
    );
    await _persist();
  }

  Future<void> addXp(int amount) async {
    if (amount <= 0) return;
    state = state.copyWith(
      activityDates: {...state.activityDates, dateKey(DateTime.now())},
      xp: state.xp + amount,
    );
    await _persist();
  }

  Future<void> _persist() async {
    await localStore?.put(_key, {
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
    state = state.copyWith(placedOutMissions: skipped);
    await _persist();
  }

  /// Folds a downloaded snapshot into local progress, keeping the larger of
  /// every value. Returns `false` when the remote adds nothing, so the caller
  /// can avoid persisting and re-uploading an unchanged snapshot.
  Future<bool> mergeCloudSnapshot(Map<String, dynamic> remote) async {
    final remoteSkills = remote['skill_evidence'];
    final mergedSkills = {...state.skillEvidence};
    if (remoteSkills is Map) {
      for (final entry in remoteSkills.entries) {
        final skill = SkillArea.values
            .where((item) => item.name == '${entry.key}')
            .firstOrNull;
        if (skill != null && entry.value is num) {
          mergedSkills[skill] = _maxInt(mergedSkills[skill] ?? 0, entry.value);
        }
      }
    }
    final merged = state.copyWith(
      completedMissions: {
        ...state.completedMissions,
        ..._stringSet(remote['completed_missions']),
      },
      placedOutMissions: {
        ...state.placedOutMissions,
        ..._stringSet(remote['placed_out_missions']),
      },
      completedPostcards: {
        ...state.completedPostcards,
        ..._stringSet(remote['completed_postcards']),
      },
      unlockedRewards: {
        ...state.unlockedRewards,
        ..._stringSet(remote['unlocked_rewards']),
      },
      skillEvidence: mergedSkills,
      activityDates: {
        ...state.activityDates,
        ..._stringSet(remote['activity_dates']),
      },
      xp: _maxInt(state.xp, remote['xp']),
      streakFreezes: _maxInt(state.streakFreezes, remote['streak_freezes']),
    );
    if (merged == state) return false;
    state = merged;
    await _persist();
    return true;
  }
}

int _maxInt(int local, dynamic remote) =>
    remote is num && remote.toInt() > local ? remote.toInt() : local;

int _storedInt(dynamic value, int fallback) =>
    value is num ? value.toInt() : fallback;

Set<String> _stringSet(dynamic value) =>
    value is Iterable ? value.map((item) => '$item').toSet() : <String>{};

final progressProvider = NotifierProvider<ProgressNotifier, LearnerProgress>(
  ProgressNotifier.new,
);

class HandwritingHistoryNotifier extends Notifier<List<HandwritingRecord>> {
  static const _key = 'handwriting_photo_history_v1';

  static const _maxRecords = 100;

  @override
  List<HandwritingRecord> build() {
    final raw = localStore?.get(_key);
    if (raw is! Iterable) return const [];
    return raw.whereType<Map>().map(handwritingFromMap).toList();
  }

  Future<void> add(HandwritingRecord record) async {
    state = [record, ...state].take(_maxRecords).toList();
    await _persist();
  }

  /// Folds cloud handwriting evidence into the local history, keyed by
  /// character and timestamp so a record synced twice is stored once.
  /// Returns `false` when nothing new arrived.
  Future<bool> mergeCloudSnapshot(Map<String, dynamic> remote) async {
    final raw = remote['handwriting'];
    if (raw is! Iterable) return false;
    String keyFor(HandwritingRecord record) =>
        '${record.character}|${record.createdAt.toUtc().toIso8601String()}';
    final merged = <String, HandwritingRecord>{
      for (final item in state) keyFor(item): item,
    };
    for (final item in raw.whereType<Map>()) {
      final record = handwritingFromMap(item, cloudKeys: true);
      merged[keyFor(record)] = record;
    }
    final next =
        (merged.values.toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt)))
            .take(_maxRecords)
            .toList();
    if (listEquals(next, state)) return false;
    state = next;
    await _persist();
    return true;
  }

  Future<void> _persist() async {
    await localStore?.put(_key, state.map(handwritingToMap).toList());
  }
}

/// Local Hive uses camelCase keys; the cloud snapshot uses snake_case. One
/// reader handles both so the two shapes can never drift apart.
HandwritingRecord handwritingFromMap(Map<dynamic, dynamic> item, {
  bool cloudKeys = false,
}) => HandwritingRecord(
  character: '${item['character'] ?? ''}',
  score: (item['score'] as num?)?.toInt() ?? 0,
  accuracy: (item['accuracy'] as num?)?.toInt() ?? 0,
  balance: (item['balance'] as num?)?.toInt() ?? 0,
  createdAt:
      DateTime.tryParse('${item[cloudKeys ? 'created_at' : 'createdAt']}') ??
      DateTime.now(),
  evidenceMode: '${item[cloudKeys ? 'evidence_mode' : 'evidenceMode'] ?? 'photo'}',
);

Map<String, dynamic> handwritingToMap(HandwritingRecord record) => {
  'character': record.character,
  'score': record.score,
  'accuracy': record.accuracy,
  'balance': record.balance,
  'createdAt': record.createdAt.toIso8601String(),
  'evidenceMode': record.evidenceMode,
};

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
