import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/cloud_config.dart';
import '../providers/sync_state.dart';
import '../services/cloud_service.dart';
import '../theme/app_theme.dart';

class AccountView extends ConsumerStatefulWidget {
  const AccountView({super.key});

  @override
  ConsumerState<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends ConsumerState<AccountView> {
  final _emailController = TextEditingController();
  final CloudService _cloud = const CloudService();
  bool _sending = false;
  String? _message;
  StreamSubscription<dynamic>? _authSubscription;

  @override
  void initState() {
    super.initState();
    if (_cloud.isConfigured) {
      _authSubscription = _cloud.authChanges.listen((event) async {
        if (!mounted) return;
        ref.read(syncProvider.notifier).refreshAuth();
        if (event.session != null) {
          await ref.read(syncProvider.notifier).syncNow();
        }
      });
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendLink() async {
    if (!_emailController.text.contains('@')) {
      setState(() => _message = 'Enter a valid email address.');
      return;
    }
    setState(() {
      _sending = true;
      _message = null;
    });
    try {
      await _cloud.sendMagicLink(_emailController.text);
      if (mounted) {
        setState(
          () => _message = 'Check your email for a secure sign-in link.',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _message =
              'The sign-in link could not be sent. Your local progress is unaffected.',
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sync = ref.watch(syncProvider);
    final user = _cloud.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Account & Sync')),
      body: ResponsiveContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Local first, cloud optional',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            const Text(
              'LinguaTomo works fully without an account. Signing in only adds backup and cross-device continuity.',
            ),
            const SizedBox(height: 16),
            if (!CloudConfig.isConfigured)
              const _CloudSetupCard()
            else if (user == null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Sign in without a password',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        decoration: const InputDecoration(
                          labelText: 'Email address',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 10),
                      FilledButton.icon(
                        onPressed: _sending ? null : _sendLink,
                        icon: const Icon(Icons.mark_email_read_outlined),
                        label: Text(
                          _sending ? 'Sending…' : 'Email me a sign-in link',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Card(
                color: AppColors.bambooMist,
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person_rounded),
                  ),
                  title: Text(user.email ?? 'LinguaTomo learner'),
                  subtitle: const Text(
                    'Your local learning remains the source of truth.',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: sync.status == SyncStatus.syncing
                    ? null
                    : ref.read(syncProvider.notifier).syncNow,
                icon: const Icon(Icons.cloud_sync_rounded),
                label: Text(
                  sync.status == SyncStatus.syncing
                      ? 'Syncing…'
                      : 'Back up progress now',
                ),
              ),
              TextButton(
                onPressed: () async {
                  await ref.read(syncProvider.notifier).syncNow();
                  await _cloud.signOut();
                  ref.read(syncProvider.notifier).refreshAuth();
                },
                child: const Text('Sign out'),
              ),
            ],
            if (_message != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_message!),
              ),
            if (sync.message != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(sync.message!),
              ),
            const SizedBox(height: 16),
            const _PrivacyCard(),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LinguaTomo 1.6.0',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    SizedBox(height: 4),
                    Text('Created with ♥ by Tushant Sharma'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CloudSetupCard extends StatelessWidget {
  const _CloudSetupCard();
  @override
  Widget build(BuildContext context) => Card(
    color: AppColors.bambooMist,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.cloud_off_rounded, color: AppColors.matcha),
              SizedBox(width: 10),
              Text(
                'Running in private local mode',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'To enable Supabase sync, provide the public project URL and anonymous key at build time:',
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.charcoal,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const SelectableText(
              'flutter run --dart-define=SUPABASE_URL=https://… --dart-define=SUPABASE_PUBLISHABLE_KEY=…',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'monospace',
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard();
  @override
  Widget build(BuildContext context) => const Card(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, color: AppColors.matcha),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Handwriting photos stay on this device by default. Public profiles, direct messages, and community posting are disabled for child-mode accounts in the cloud security policy.',
            ),
          ),
        ],
      ),
    ),
  );
}
