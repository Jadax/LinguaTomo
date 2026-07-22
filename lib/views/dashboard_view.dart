import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/curriculum_data.dart';
import '../models/app_models.dart';
import '../providers/app_state.dart';
import '../providers/review_state.dart';
import '../providers/grammar_state.dart';
import '../theme/app_theme.dart';
import 'mission_view.dart';
import 'collection_view.dart';
import 'postcards_view.dart';
import 'placement_view.dart';
import 'review_view.dart';
import 'journey_view.dart';
import 'seasonal_stories_view.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final next = ref.watch(nextMissionProvider);
    final mode = ref.watch(experienceProvider);
    final dueReviews =
        ref.watch(reviewDeckProvider).dueMissions.length +
        ref.watch(grammarGardenProvider).dueCount;
    return ResponsiveContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome home',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      '${progress.stage.label} · ${progress.stage.cefr} · ${progress.stage.jlpt}',
                    ),
                  ],
                ),
              ),
              _StatPill(
                icon: Icons.local_fire_department_rounded,
                value: '${progress.streak}',
                label: 'days',
              ),
              const SizedBox(width: 8),
              _StatPill(
                icon: Icons.auto_awesome_rounded,
                value: '${progress.xp}',
                label: 'XP',
              ),
            ],
          ),
          const SizedBox(height: 14),
          _NestRoom(
            progress: progress,
            reduceMotion: mode == ExperienceMode.comfort,
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const CollectionView())),
          ),
          const SizedBox(height: 14),
          Card(
            color: const Color(0xFFFFF0E8),
            child: ListTile(
              minTileHeight: 76,
              leading: const CircleAvatar(
                backgroundColor: AppColors.sakura,
                child: Icon(Icons.route_rounded, color: AppColors.persimmon),
              ),
              title: Text(
                'Your route • ${progress.verifiedCanDos}/${missions.length} Can-Dos',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: LinearProgressIndicator(
                value: progress.verifiedCanDos / missions.length,
                minHeight: 8,
              ),
              trailing: const Icon(Icons.arrow_forward_rounded),
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const JourneyView())),
            ),
          ),
          const SizedBox(height: 12),
          if (progress.completedMissions.isEmpty &&
              progress.placedOutMissions.isEmpty) ...[
            Card(
              color: AppColors.bambooMist,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PlacementView()),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.explore_rounded, color: AppColors.matcha),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Already know some Japanese?',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                            Text('Take a gentle, untimed placement check.'),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_rounded),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                minTileHeight: 68,
                leading: const CircleAvatar(
                  backgroundColor: AppColors.bambooMist,
                  child: Icon(Icons.eco_rounded, color: AppColors.matcha),
                ),
                title: const Text(
                  'Memory Garden',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(
                  dueReviews == 0
                      ? 'Nothing due. Your garden is tidy.'
                      : '$dueReviews FSRS review${dueReviews == 1 ? '' : 's'} ready',
                ),
                trailing: const Icon(Icons.arrow_forward_rounded),
                onTap: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const ReviewView())),
              ),
            ),
            const SizedBox(height: 12),
            const _SeasonalEventCard(),
            const SizedBox(height: 12),
          ],
          if (progress.completedMissions.isNotEmpty ||
              progress.placedOutMissions.isNotEmpty) ...[
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                minTileHeight: 68,
                leading: const CircleAvatar(
                  backgroundColor: AppColors.bambooMist,
                  child: Icon(Icons.eco_rounded, color: AppColors.matcha),
                ),
                title: const Text(
                  'Memory Garden',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(
                  dueReviews == 0
                      ? 'Nothing due. Your memory garden is tidy.'
                      : '$dueReviews gentle review${dueReviews == 1 ? '' : 's'} ready',
                ),
                trailing: IconButton(
                  tooltip: 'How the Memory Garden works',
                  icon: const Icon(Icons.info_outline_rounded),
                  onPressed: () => _showMemoryGardenHelp(context),
                ),
                onTap: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const ReviewView())),
              ),
            ),
            const SizedBox(height: 12),
            const _SeasonalEventCard(),
            const SizedBox(height: 12),
          ],
          if (next != null)
            _NextMissionCard(mission: next)
          else
            const _JourneyCompleteCard(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionCard(
                  icon: Icons.camera_alt_rounded,
                  title: 'Snap & Grade',
                  subtitle: 'Check paper writing',
                  color: AppColors.sakura,
                  onTap: () => AppNavigation.goTo?.call(2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionCard(
                  icon: Icons.mark_email_unread_rounded,
                  title: 'Postcard',
                  subtitle:
                      '${progress.completedPostcards.length}/${postcards.length} collected',
                  color: AppColors.bambooMist,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PostcardsView()),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Your learning evidence',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _Evidence(
                    value: '${progress.verifiedCanDos}',
                    label: 'Can-Dos',
                  ),
                  _Evidence(
                    value: '${progress.unlockedRewards.length}',
                    label: 'Nest items',
                  ),
                  _Evidence(
                    value: '${progress.streakFreezes}',
                    label: 'Freezes',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMemoryGardenHelp(BuildContext context) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('How the Memory Garden works'),
      content: const Text(
        'Each learned phrase or grammar pattern becomes a plant. FSRS estimates when that memory is likely to become difficult, then brings it back just before it fades. Again shortens the interval; Hard, Good and Easy lengthen it by different amounts. There is no penalty for returning late, and the garden never dies.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Got it'),
        ),
      ],
    ),
  );
}

abstract final class AppNavigation {
  static ValueChanged<int>? goTo;
}

class _NestRoom extends StatelessWidget {
  const _NestRoom({
    required this.progress,
    required this.reduceMotion,
    required this.onTap,
  });
  final LearnerProgress progress;
  final bool reduceMotion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rewards = missions
        .where((mission) => progress.unlockedRewards.contains(mission.reward))
        .toList();
    return Semantics(
      label: 'Your Nest with ${progress.unlockedRewards.length} unlocked items',
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          height: 260,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/branding/leo-nest-fireplace.png'),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.charcoal.withValues(alpha: .08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: .05),
                        Colors.transparent,
                        Colors.black.withValues(alpha: .24),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              for (var index = 0; index < rewards.length; index++)
                Positioned(
                  left: 24 + (index % 5) * 48,
                  top: 62 + (index ~/ 5) * 48,
                  child: Tooltip(
                    message: rewards[index].reward,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .84),
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(
                          rewards[index].rewardEmoji,
                          style: const TextStyle(fontSize: 25),
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 12,
                left: 14,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7E8).withValues(alpha: .92),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                    child: Text(
                      'Leo’s fireside Nest',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 14,
                bottom: 12,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.charcoal.withValues(alpha: .70),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                    child: Text(
                      'Tap to arrange your memories',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeasonalEventCard extends StatelessWidget {
  const _SeasonalEventCard();

  @override
  Widget build(BuildContext context) => Card(
    color: const Color(0xFFFFEAF0),
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          const Text('🌸', style: TextStyle(fontSize: 38)),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seasonal story: Hanami',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                Text('Learn a picnic invitation and collect a sakura stamp.'),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SeasonalStoriesView()),
            ),
            child: const Text('Explore'),
          ),
        ],
      ),
    ),
  );
}

class _NextMissionCard extends StatelessWidget {
  const _NextMissionCard({required this.mission});
  final Mission mission;
  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => MissionView(mission: mission))),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.persimmon,
                borderRadius: BorderRadius.circular(18),
              ),
              alignment: Alignment.center,
              child: Text(
                mission.rewardEmoji,
                style: const TextStyle(fontSize: 28),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'NEXT CAN-DO',
                    style: TextStyle(
                      color: AppColors.persimmon,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    mission.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    mission.canDo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded),
          ],
        ),
      ),
    ),
  );
}

class _JourneyCompleteCard extends StatelessWidget {
  const _JourneyCompleteCard();
  @override
  Widget build(BuildContext context) => const Card(
    child: Padding(
      padding: EdgeInsets.all(20),
      child: Text(
        'You completed every available mission. Leo is celebrating your full route!',
      ),
    ),
  );
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    color: color,
    margin: EdgeInsets.zero,
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            Text(subtitle, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    ),
  );
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Icon(icon, size: 18, color: AppColors.persimmon),
        const SizedBox(width: 4),
        Text(
          '$value $label',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
        ),
      ],
    ),
  );
}

class _Evidence extends StatelessWidget {
  const _Evidence({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(color: AppColors.matcha),
      ),
      Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
    ],
  );
}
