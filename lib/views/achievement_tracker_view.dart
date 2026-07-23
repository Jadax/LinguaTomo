import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/achievement_data.dart';
import '../providers/achievement_state.dart';
import '../theme/app_theme.dart';

class AchievementTrackerView extends ConsumerWidget {
  const AchievementTrackerView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(achievementSnapshotProvider);
    final total = achievements.length;
    final unlocked = achievements.where((a) => a.unlocked(snapshot)).length;
    return Scaffold(
      appBar: AppBar(
        title: Text('Achievements · $unlocked of $total'),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: total > 0 ? unlocked / total : 0,
            minHeight: 8,
            backgroundColor: AppColors.bambooMist,
          ),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  itemCount: achievements.length,
                  itemBuilder: (context, index) {
                    final a = achievements[index];
                    final earned = a.unlocked(snapshot);
                    final progress = a.progress(snapshot);
                    final pct = a.target > 0 ? (progress / a.target).clamp(0.0, 1.0) : 0.0;
                    return Opacity(
                      opacity: earned ? 1.0 : 0.45,
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: earned
                                      ? AppColors.bambooMist
                                      : AppColors.muted.withValues(alpha: .15),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  earned ? a.emoji : '🔒',
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      a.secret && !earned ? '???' : a.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                        color: earned ? null : AppColors.muted,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      a.secret && !earned
                                          ? 'Keep exploring to unlock this.'
                                          : a.requirement,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                    if (!earned) ...[
                                      const SizedBox(height: 6),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(3),
                                        child: LinearProgressIndicator(
                                          value: pct,
                                          minHeight: 4,
                                          backgroundColor:
                                              AppColors.bambooMist.withValues(alpha: .3),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '$progress / ${a.target}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.muted,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (earned)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.matcha.withValues(alpha: .12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    a.reward,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.matcha,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
