import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../config/cloud_config.dart';
import '../config/storage_keys.dart';
import '../services/cloud_service.dart';
import 'app_state.dart';

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

  Box<dynamic>? get _box => Hive.isBoxOpen(StorageKeys.userData)
      ? Hive.box<dynamic>(StorageKeys.userData)
      : null;

  @override
  SyncState build() {
    if (!CloudConfig.isConfigured) {
      return const SyncState(status: SyncStatus.localOnly);
    }
    final lastSync = DateTime.tryParse('${_box?.get(_lastSyncKey) ?? ''}');
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
    final snapshot = _buildSnapshot();
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
      final queued = _readOutbox();
      for (final item in queued) {
        await _cloud.uploadProgress(item);
      }
      await _cloud.uploadProgress(snapshot);
      await _box?.delete(_outboxKey);
      final now = DateTime.now().toUtc();
      await _box?.put(_lastSyncKey, now.toIso8601String());
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

  Map<String, dynamic> _buildSnapshot() {
    final progress = ref.read(progressProvider);
    final handwriting = ref.read(handwritingHistoryProvider);
    return {
      'schema_version': 1,
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

  List<Map<String, dynamic>> _readOutbox() {
    final raw = _box?.get(_outboxKey);
    if (raw is! Iterable) return [];
    return raw
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<void> _queue(Map<String, dynamic> snapshot) async {
    final items = _readOutbox()..add(snapshot);
    final newest = items.reversed.take(5).toList().reversed.toList();
    await _box?.put(_outboxKey, newest);
  }
}

final syncProvider = NotifierProvider<SyncNotifier, SyncState>(
  SyncNotifier.new,
);
