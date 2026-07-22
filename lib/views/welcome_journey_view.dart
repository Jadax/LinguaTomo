import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_models.dart';
import '../providers/app_state.dart';
import '../providers/level_prefs_state.dart';
import '../providers/word_progress_state.dart';
import '../theme/app_theme.dart';
import '../widgets/leo_companion.dart';

class WelcomeJourneyView extends ConsumerStatefulWidget {
  const WelcomeJourneyView({super.key});

  @override
  ConsumerState<WelcomeJourneyView> createState() =>
      _WelcomeJourneyViewState();
}

class _WelcomeJourneyViewState extends ConsumerState<WelcomeJourneyView> {
  DifficultyTier? _selected;
  bool _saving = false;

  Future<void> _continue() async {
    final tier = _selected;
    if (tier == null) return;
    setState(() => _saving = true);

    // Set the word tier.
    await ref.read(wordProgressProvider.notifier).setTier(tier);
    await ref.read(levelPrefsProvider.notifier).setLevel(tier);

    // Map tier to JourneyStart for mission placement.
    final start = JourneyStart.values[tier.index];
    await ref.read(learnerProfileProvider.notifier).chooseStart(start);
    if (start != JourneyStart.starter) {
      await ref
          .read(progressProvider.notifier)
          .applyPlacement(start.suggestedPlacementSkip);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        ref.watch(experienceProvider) == ExperienceMode.comfort;
    return Scaffold(
      body: SafeArea(
        child: ResponsiveContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 18),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to LinguaTomo',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const Text('Japanese, with a friend beside you.'),
                ],
              ),
              const SizedBox(height: 18),
              LeoCompanion(reduceMotion: reduceMotion),
              const SizedBox(height: 22),
              Text(
                'Choose your level',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              const Text(
                'Pick where you feel comfortable. You can change this later from the dashboard.',
              ),
              const SizedBox(height: 10),
              const Card(
                color: AppColors.bambooMist,
                child: Padding(
                  padding: EdgeInsets.all(14),
                  child: Text(
                    'Start by learning Japanese words. Each lesson teaches 5 words with pictures, audio and romaji. No alphabet knowledge needed — just tap and learn. Leo walks beside you the whole way.',
                  ),
                ),
              ),
              const SizedBox(height: 14),
              for (final tier in DifficultyTier.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Card(
                    margin: EdgeInsets.zero,
                    color: _selected == tier
                        ? AppColors.bambooMist
                        : Colors.white,
                    child: RadioListTile<DifficultyTier>(
                      value: tier,
                      // ignore: deprecated_member_use
                      groupValue: _selected,
                      // ignore: deprecated_member_use
                      onChanged: (value) =>
                          setState(() => _selected = value),
                      title: Text(
                        tier.label,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: Text(tier.description),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _selected == null || _saving ? null : _continue,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text(
                  _saving ? 'Preparing your route...' : 'Start learning',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Beginner? Pick Starter — you do not need to know any Japanese to start. Leo teaches you words from your very first lesson.',
                style: TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
