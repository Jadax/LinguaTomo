import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/cloud_config.dart';
import '../config/local_store.dart';
import '../services/cloud_service.dart';
import 'app_state.dart';
import 'word_progress_state.dart';

enum SyncStatus { localOnly, signedOut, ready, syncing, synced, offline, error }

class SyncState {
  const SyncState({required this.status, this.lastSync, this.message});
  final SyncStatus status;
  final DateTime? lastSync;
  final String? message;
}

class SyncNotifier extends Notifier<SyncState> {
  static const _lastSyncKey = 'cloud_last_sync';
  static const _outboxKey = 'cloud_sync_outbox';
  final CloudService _cloud = const CloudService();

  @override
  SyncState build() {
    if (!CloudConfig.isConfigured) {
      return const SyncState(status: SyncStatus.localOnly);
    }
    final lastSync = DateTime.tryParse('${localStore?.get(_lastSyncKey) ?? ''}');
    return SyncState(
      status: _cloud.currentUser == null
          ? SyncStatus.signedOut
          : SyncStatus.ready,
      lastSync: lastSync,
    );
  }

  void refreshAuth() {
    if (!CloudConfig.isConfigured) return;
    state = SyncState(
      status: _cloud.currentUser == null
          ? SyncStatus.signedOut
          : SyncStatus.ready,
      lastSync: state.lastSync,
    );
  }

  Future<void> syncNow() async {
    if (!CloudConfig.isConfigured || _cloud.currentUser == null) return;
    if (state.status == SyncStatus.syncing) return;
    var snapshot = _buildSnapshot();
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.every((result) => result == ConnectivityResult.none)) {
      await _queue(snapshot);
      state = SyncState(
        status: SyncStatus.offline,
        lastSync: state.lastSync,
        message: 'Saved safely. Sync will be available when you reconnect.',
      );
      return;
    }
    state = SyncState(status: SyncStatus.syncing, lastSync: state.lastSync);
    try {
      final remote = await _cloud.downloadProgress();
      if (remote != null) {
        // Each merge reports whether the remote actually contributed
        // anything. Rebuilding the snapshot only when it did keeps an
        // unchanged download from looking like fresh local work, which
        // would otherwise re-arm the debounce and sync in a loop.
        var changed = await ref
            .read(progressProvider.notifier)
            .mergeCloudSnapshot(remote);
        changed =
            await ref
                .read(handwritingHistoryProvider.notifier)
                .mergeCloudSnapshot(remote) ||
            changed;
        changed =
            await ref
                .read(wordProgressProvider.notifier)
                .mergeCloudSnapshot(remote) ||
            changed;
        if (changed) snapshot = _buildSnapshot();
      }
      // A queued snapshot is always older than the one just built, and the
      // upload is a whole-row upsert, so replaying the outbox would only
      // overwrite newer data with older. Local merging has already folded
      // that work in; the outbox exists to prove nothing was lost offline.
      await _cloud.uploadProgress(snapshot);
      await localStore?.delete(_outboxKey);
      final now = DateTime.now().toUtc();
      await localStore?.put(_lastSyncKey, now.toIso8601String());
      state = SyncState(status: SyncStatus.synced, lastSync: now);
    } catch (error) {
      await _queue(snapshot);
      state = SyncState(
        status: SyncStatus.error,
        lastSync: state.lastSync,
        message: 'Sync paused. Your local progress is safe.',
      );
    }
  }

  /// Everything a learner would grieve losing on a reinstall.
  ///
  /// Schema 2 added word progress, which schema 1 omitted — a snapshot
  /// written by an older build simply lacks those keys and the merge leaves
  /// local word progress untouched, so the upgrade needs no migration.
  Map<String, dynamic> _buildSnapshot() {
    final progress = ref.read(progressProvider);
    final handwriting = ref.read(handwritingHistoryProvider);
    return {
      'schema_version': 2,
      ...ref.read(wordProgressProvider.notifier).toCloudSnapshot(),
      'completed_missions': progress.completedMissions.toList(),
      'placed_out_missions': progress.placedOutMissions.toList(),
      'completed_postcards': progress.completedPostcards.toList(),
      'unlocked_rewards': progress.unlockedRewards.toList(),
      'skill_evidence': {
        for (final entry in progress.skillEvidence.entries)
          entry.key.name: entry.value,
      },
      'activity_dates': progress.activityDates.toList(),
      'xp': progress.xp,
      'streak_freezes': progress.streakFreezes,
      'handwriting': handwriting
          .map(
            (record) => {
              'character': record.character,
              'score': record.score,
              'accuracy': record.accuracy,
              'balance': record.balance,
              'created_at': record.createdAt.toUtc().toIso8601String(),
              'evidence_mode': record.evidenceMode,
            },
          )
          .toList(),
      'exported_at': DateTime.now().toUtc().toIso8601String(),
    };
  }

  /// Records the most recent snapshot that could not be sent. Only the latest
  /// is kept: every snapshot is complete, so an older one carries nothing the
  /// newer one lacks.
  Future<void> _queue(Map<String, dynamic> snapshot) async {
    await localStore?.put(_outboxKey, snapshot);
  }
}

final syncProvider = NotifierProvider<SyncNotifier, SyncState>(
  SyncNotifier.new,
);
