import 'package:flutter/material.dart';

import '../services/cloud_service.dart';
import '../theme/app_theme.dart';

class LeaderboardView extends StatefulWidget {
  const LeaderboardView({super.key});

  @override
  State<LeaderboardView> createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends State<LeaderboardView> {
  final CloudService _cloud = const CloudService();
  late Future<List<LeaderboardEntry>> _entries;

  @override
  void initState() {
    super.initState();
    _entries = _cloud.loadLeaderboard();
  }

  Future<void> _refresh() async {
    setState(() => _entries = _cloud.loadLeaderboard());
    await _entries;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Cosy Achievement Board'),
      actions: [
        IconButton(
          tooltip: 'Refresh board',
          onPressed: _refresh,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
    ),
    body: ResponsiveContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Cheer, never pressure',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 5),
          const Text(
            'This optional board ranks collected achievement memories. It shows nicknames only, never email addresses. There are no prizes and you can leave at any time.',
          ),
          const SizedBox(height: 14),
          FutureBuilder<List<LeaderboardEntry>>(
            future: _entries,
            builder: (context, snapshot) {
              if (_cloud.currentUser == null) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text(
                      'Sign in from Account & Sync, choose a nickname, then opt in if you want to join.',
                    ),
                  ),
                );
              }
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(28),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (snapshot.hasError) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text(
                      'The cosy board is not available yet. Your private progress is unaffected.',
                    ),
                  ),
                );
              }
              final entries = snapshot.data ?? const [];
              if (entries.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text(
                      'The board is quiet. Be the first learner to opt in from Account & Sync.',
                    ),
                  ),
                );
              }
              final ownId = _cloud.currentUser?.id;
              final ownRank = entries.indexWhere((entry) => entry.id == ownId);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    color: ownRank >= 0
                        ? AppColors.bambooMist
                        : AppColors.peach,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text(
                        ownRank >= 0
                            ? 'Your place: #${ownRank + 1}. Every achievement is a little story Leo can celebrate.'
                            : 'Save a nickname and join the board from Account & Sync to see your place here.',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text('Refresh ${entries.length} learners'),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(
                      children: [
                        for (var index = 0; index < entries.length; index++)
                          ListTile(
                            tileColor: entries[index].id == ownId
                                ? AppColors.bambooMist.withValues(alpha: .45)
                                : null,
                            leading: CircleAvatar(
                              backgroundColor: index < 3
                                  ? AppColors.sakura
                                  : AppColors.bambooMist,
                              child: Text(
                                index < 3
                                    ? ['🥇', '🥈', '🥉'][index]
                                    : '${index + 1}',
                              ),
                            ),
                            title: Text(
                              entries[index].nickname,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            subtitle: Text(
                              entries[index].id == ownId
                                  ? '${entries[index].achievements} achievement memories · That is you!'
                                  : '${entries[index].achievements} achievement memories',
                            ),
                            trailing: Text(
                              '${entries[index].xp} XP',
                              style: const TextStyle(
                                color: AppColors.matcha,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    ),
  );
}
