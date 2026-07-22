import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/cloud_config.dart';

abstract final class CloudBootstrap {
  static bool _isInitialised = false;

  static bool get isInitialised => _isInitialised;

  static Future<void> initialize() async {
    if (!CloudConfig.isConfigured) {
      return;
    }
    await Supabase.initialize(
      url: CloudConfig.supabaseUrl,
      publishableKey: CloudConfig.supabasePublishableKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
    _isInitialised = true;
  }
}

class CloudService {
  const CloudService();

  bool get isConfigured => CloudConfig.isConfigured;

  SupabaseClient? get _client => isConfigured && CloudBootstrap.isInitialised
      ? Supabase.instance.client
      : null;

  User? get currentUser => _client?.auth.currentUser;

  Stream<AuthState> get authChanges =>
      _client?.auth.onAuthStateChange ?? const Stream<AuthState>.empty();

  Future<void> sendMagicLink(String email) async {
    final client = _client;
    if (client == null) {
      throw StateError('Cloud sync is not configured.');
    }
    await client.auth.signInWithOtp(
      email: email.trim(),
      emailRedirectTo: kIsWeb
          ? Uri.base.resolve('.').toString()
          : 'com.astraiva.linguatomo://login-callback/',
    );
  }

  Future<void> signOut() async => _client?.auth.signOut();

  Future<void> uploadProgress(Map<String, dynamic> snapshot) async {
    final client = _client;
    final user = currentUser;
    if (client == null || user == null) {
      throw StateError('Sign in before syncing.');
    }
    await client.from('learner_progress').upsert({
      'user_id': user.id,
      'snapshot': snapshot,
      'client_updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'user_id');
  }

  Future<Map<String, dynamic>?> downloadProgress() async {
    final client = _client;
    final user = currentUser;
    if (client == null || user == null) {
      return null;
    }
    final response = await client
        .from('learner_progress')
        .select('snapshot')
        .eq('user_id', user.id)
        .maybeSingle();
    final snapshot = response?['snapshot'];
    return snapshot is Map ? Map<String, dynamic>.from(snapshot) : null;
  }

  Future<Map<String, dynamic>?> loadOwnProfile() async {
    final client = _client;
    final user = currentUser;
    if (client == null || user == null) return null;
    final response = await client
        .from('profiles')
        .select('display_name, leaderboard_opt_in, achievement_count, xp')
        .eq('id', user.id)
        .maybeSingle();
    return response == null ? null : Map<String, dynamic>.from(response);
  }

  Future<void> updatePublicProfile({
    required String displayName,
    required bool leaderboardOptIn,
    required int achievementCount,
    required int xp,
  }) async {
    final client = _client;
    final user = currentUser;
    if (client == null || user == null) throw StateError('Sign in first.');
    await client
        .from('profiles')
        .update({
          'display_name': displayName.trim(),
          'leaderboard_opt_in': leaderboardOptIn,
          'achievement_count': achievementCount,
          'xp': xp,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', user.id);
  }

  Future<List<LeaderboardEntry>> loadLeaderboard() async {
    final client = _client;
    if (client == null || currentUser == null) return const [];
    final response = await client
        .from('profiles')
        .select('id, display_name, achievement_count, xp')
        .eq('leaderboard_opt_in', true)
        .order('achievement_count', ascending: false)
        .order('xp', ascending: false)
        .limit(100);
    return (response as List)
        .map(
          (item) =>
              LeaderboardEntry.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }
}

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.id,
    required this.nickname,
    required this.achievements,
    required this.xp,
  });

  final String id;
  final String nickname;
  final int achievements;
  final int xp;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      LeaderboardEntry(
        id: '${json['id'] ?? ''}',
        nickname: '${json['display_name'] ?? 'Learner'}',
        achievements: (json['achievement_count'] as num?)?.toInt() ?? 0,
        xp: (json['xp'] as num?)?.toInt() ?? 0,
      );
}
