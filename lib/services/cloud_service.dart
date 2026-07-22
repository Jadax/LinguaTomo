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
}
