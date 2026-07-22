import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_models.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/leo_companion.dart';

class WelcomeJourneyView extends ConsumerStatefulWidget {
  const WelcomeJourneyView({super.key});

  @override
  ConsumerState<WelcomeJourneyView> createState() => _WelcomeJourneyViewState();
}

class _WelcomeJourneyViewState extends ConsumerState<WelcomeJourneyView> {
  JourneyStart? _selected;
  bool _saving = false;

  Future<void> _continue() async {
    final start = _selected;
    if (start == null) return;
    setState(() => _saving = true);
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
                'Where would you like to begin?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              const Text(
                'Choose what feels closest. You can take the untimed placement check later and change your route at any time.',
              ),
              const SizedBox(height: 10),
              const Card(
                color: AppColors.bambooMist,
                child: Padding(
                  padding: EdgeInsets.all(14),
                  child: Text(
                    'New to Japanese? Starter begins with pronunciation and hiragana, while Leo teaches a few useful spoken phrases from day one. Katakana follows, then kanji is introduced through real words. You do not have to perfect the alphabet before communicating.',
                  ),
                ),
              ),
              const SizedBox(height: 14),
              for (final start in JourneyStart.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Card(
                    margin: EdgeInsets.zero,
                    color: _selected == start
                        ? AppColors.bambooMist
                        : Colors.white,
                    child: RadioListTile<JourneyStart>(
                      value: start,
                      // ignore: deprecated_member_use
                      groupValue: _selected,
                      // ignore: deprecated_member_use
                      onChanged: (value) => setState(() => _selected = value),
                      title: Text(
                        start.label,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: Text(start.guide),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _selected == null || _saving ? null : _continue,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text(
                  _saving ? 'Preparing your route...' : 'Show my route',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your route links practical Can-Do skills with JLPT, CEFR and ILR reference points. These frameworks measure different things, so we show them side by side rather than pretending they are identical.',
                style: TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
