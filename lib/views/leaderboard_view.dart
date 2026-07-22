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

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Cosy Achievement Board')),
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
              return Card(
                child: Column(
                  children: [
                    for (var index = 0; index < entries.length; index++)
                      ListTile(
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
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        subtitle: Text(
                          '${entries[index].achievements} achievement memories',
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
              );
            },
          ),
        ],
      ),
    ),
  );
}
