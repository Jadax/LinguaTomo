import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fsrs/fsrs.dart' show Rating;

import '../models/app_models.dart';
import '../providers/review_state.dart';
import '../theme/app_theme.dart';

class ReviewView extends ConsumerStatefulWidget {
  const ReviewView({super.key});

  @override
  ConsumerState<ReviewView> createState() => _ReviewViewState();
}

class _ReviewViewState extends ConsumerState<ReviewView> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final due = ref.watch(reviewDeckProvider).dueMissions;
    return Scaffold(
      appBar: AppBar(title: const Text('Memory Garden')),
      body: ResponsiveContent(
        child: due.isEmpty
            ? const _EmptyReview()
            : _ReviewCard(
                mission: due.first,
                remaining: due.length,
                revealed: _revealed,
                onReveal: () => setState(() => _revealed = true),
                onRate: (rating) async {
                  await ref
                      .read(reviewDeckProvider.notifier)
                      .rate(due.first.id, rating);
                  if (mounted) setState(() => _revealed = false);
                },
              ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.mission,
    required this.remaining,
    required this.revealed,
    required this.onReveal,
    required this.onRate,
  });
  final Mission mission;
  final int remaining;
  final bool revealed;
  final VoidCallback onReveal;
  final ValueChanged<Rating> onRate;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              'A calm review',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Text(
            '$remaining due',
            style: const TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      const SizedBox(height: 6),
      const Text(
        'FSRS schedules each phrase for approximately 90% desired retention.',
      ),
      const SizedBox(height: 18),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                mission.phrase,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              if (revealed) ...[
                Text(
                  mission.reading,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 6),
                Text(
                  mission.translation,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ] else
                FilledButton.tonal(
                  onPressed: onReveal,
                  child: const Text('Show meaning'),
                ),
            ],
          ),
        ),
      ),
      if (revealed) ...[
        const SizedBox(height: 14),
        const Text(
          'How well did you remember?',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 9),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            _RateButton(
              label: 'Again',
              color: AppColors.persimmon,
              onTap: () => onRate(Rating.again),
            ),
            _RateButton(
              label: 'Hard',
              color: const Color(0xFFB5792F),
              onTap: () => onRate(Rating.hard),
            ),
            _RateButton(
              label: 'Good',
              color: AppColors.matcha,
              onTap: () => onRate(Rating.good),
            ),
            _RateButton(
              label: 'Easy',
              color: AppColors.teal,
              onTap: () => onRate(Rating.easy),
            ),
          ],
        ),
      ],
    ],
  );
}

class _RateButton extends StatelessWidget {
  const _RateButton({
    required this.label,
    required this.color,
    required this.onTap,
  });
  final String label;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onTap,
    style: OutlinedButton.styleFrom(
      foregroundColor: color,
      side: BorderSide(color: color),
    ),
    child: Text(label),
  );
}

class _EmptyReview extends StatelessWidget {
  const _EmptyReview();
  @override
  Widget build(BuildContext context) => Column(
    children: [
      const Text('🌱', style: TextStyle(fontSize: 68)),
      Text(
        'Your memory garden is tidy',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: 8),
      const Text(
        'No phrases are due right now. FSRS will bring them back when the timing is useful.',
        textAlign: TextAlign.center,
      ),
    ],
  );
}
