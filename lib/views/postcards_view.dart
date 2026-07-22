import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/curriculum_data.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class PostcardsView extends ConsumerWidget {
  const PostcardsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Living Postcards')),
      body: ResponsiveContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'A tiny piece of Japan each day',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            const Text(
              'Three words, one useful phrase, and a cultural detail. Nothing expires.',
            ),
            const SizedBox(height: 16),
            for (var index = 0; index < postcards.length; index++)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _Postcard(
                  index: index,
                  completed: progress.completedPostcards.contains(
                    postcards[index].id,
                  ),
                  onComplete: () => ref
                      .read(progressProvider.notifier)
                      .completePostcard(postcards[index].id),
                ),
              ),
            const Card(
              color: AppColors.bambooMist,
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Row(
                  children: [
                    Text('🎁', style: TextStyle(fontSize: 34)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Collect seven postcards to unlock a virtual souvenir. Missed days remain waiting for you.',
                      ),
                    ),
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

class _Postcard extends StatelessWidget {
  const _Postcard({
    required this.index,
    required this.completed,
    required this.onComplete,
  });
  final int index;
  final bool completed;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final card = postcards[index];
    return Card(
      margin: EdgeInsets.zero,
      color: index.isEven ? const Color(0xFFFFF2E2) : const Color(0xFFF1F4E8),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(card.emoji, style: const TextStyle(fontSize: 42)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'POSTCARD ${index + 1}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                          color: AppColors.persimmon,
                        ),
                      ),
                      Text(
                        card.location,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                if (completed)
                  const Icon(Icons.verified_rounded, color: AppColors.matcha),
              ],
            ),
            const Divider(height: 26),
            ...card.words.map(
              (word) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  word,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              card.phrase,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            Text(card.translation),
            const SizedBox(height: 12),
            Text(
              card.cultureNote,
              style: const TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 14),
            FilledButton.tonalIcon(
              onPressed: completed ? null : onComplete,
              icon: Icon(
                completed
                    ? Icons.check_rounded
                    : Icons.local_post_office_rounded,
              ),
              label: Text(completed ? 'Collected' : 'Stamp this postcard'),
            ),
          ],
        ),
      ),
    );
  }
}
