import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_models.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../services/speech_service.dart';
import '../widgets/leo_companion.dart';

class MissionView extends ConsumerStatefulWidget {
  const MissionView({required this.mission, super.key});

  final Mission mission;

  @override
  ConsumerState<MissionView> createState() => _MissionViewState();
}

class _MissionViewState extends ConsumerState<MissionView> {
  final SpeechService _speech = SpeechService();
  int _step = 0;
  int? _answer;
  bool _playing = false;

  @override
  void dispose() {
    _speech.dispose();
    super.dispose();
  }

  Future<void> _play() async {
    setState(() => _playing = true);
    try {
      await _speech.speakJapanese(widget.mission.phrase);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Audio is unavailable. You can still complete the mission.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _playing = false);
    }
  }

  Future<void> _finish() async {
    await ref.read(progressProvider.notifier).completeMission(widget.mission);
    if (!mounted) return;
    setState(() => _step = 3);
  }

  @override
  Widget build(BuildContext context) {
    final mission = widget.mission;
    return Scaffold(
      appBar: AppBar(title: Text(mission.district)),
      body: ResponsiveContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: (_step + 1) / 4,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 18),
            if (_step == 0)
              _CanDoStep(
                mission: mission,
                onContinue: () => setState(() => _step = 1),
              ),
            if (_step == 1)
              _NoticeStep(
                mission: mission,
                playing: _playing,
                onPlay: _play,
                onContinue: () => setState(() => _step = 2),
              ),
            if (_step == 2)
              _CheckStep(
                mission: mission,
                answer: _answer,
                onAnswer: (value) => setState(() => _answer = value),
                onFinish: _answer == mission.correctOption ? _finish : null,
              ),
            if (_step == 3)
              _CompleteStep(
                mission: mission,
                onClose: () => Navigator.of(context).pop(),
              ),
          ],
        ),
      ),
    );
  }
}

class _CanDoStep extends StatelessWidget {
  const _CanDoStep({required this.mission, required this.onContinue});
  final Mission mission;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Text(
        'TODAY’S CAN-DO',
        style: TextStyle(
          color: AppColors.matcha,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
      const SizedBox(height: 10),
      Text(mission.canDo, style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 18),
      Card(
        color: AppColors.sakura,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Text(mission.rewardEmoji, style: const TextStyle(fontSize: 48)),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Complete this mission to add a ${mission.reward.toLowerCase()} to your Nest.',
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 18),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: mission.skills
            .map(
              (skill) => Chip(
                avatar: Icon(skill.icon, size: 18),
                label: Text(skill.label),
              ),
            )
            .toList(),
      ),
      const SizedBox(height: 24),
      FilledButton(onPressed: onContinue, child: const Text('Enter the scene')),
    ],
  );
}

class _NoticeStep extends StatelessWidget {
  const _NoticeStep({
    required this.mission,
    required this.playing,
    required this.onPlay,
    required this.onContinue,
  });
  final Mission mission;
  final bool playing;
  final VoidCallback onPlay;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        'Listen and notice',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: 14),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              Text(
                mission.phrase,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                mission.reading,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 6),
              Text(mission.translation, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: playing ? null : onPlay,
                icon: playing
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.volume_up_rounded),
                label: const Text('Listen again'),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 14),
      Card(
        color: AppColors.bambooMist,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.temple_buddhist_rounded,
                color: AppColors.matcha,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(mission.cultureNote)),
            ],
          ),
        ),
      ),
      const SizedBox(height: 20),
      FilledButton(
        onPressed: onContinue,
        child: const Text('I’m ready to try'),
      ),
    ],
  );
}

class _CheckStep extends StatelessWidget {
  const _CheckStep({
    required this.mission,
    required this.answer,
    required this.onAnswer,
    required this.onFinish,
  });
  final Mission mission;
  final int? answer;
  final ValueChanged<int> onAnswer;
  final VoidCallback? onFinish;

  @override
  Widget build(BuildContext context) {
    final attempted = answer != null;
    final correct = answer == mission.correctOption;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Prove the Can-Do',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 6),
        Text('What does “${mission.phrase}” accomplish?'),
        const SizedBox(height: 14),
        for (var index = 0; index < mission.options.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Semantics(
              selected: answer == index,
              child: OutlinedButton(
                onPressed: () => onAnswer(index),
                style: OutlinedButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  minimumSize: const Size.fromHeight(56),
                  backgroundColor: answer == index
                      ? (correct ? AppColors.bambooMist : AppColors.sakura)
                      : Colors.white,
                ),
                child: Text(mission.options[index]),
              ),
            ),
          ),
        if (attempted)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              correct
                  ? 'That’s it. You used the phrase for its real purpose.'
                  : 'Not quite. Listen to the situation and try once more.',
              style: TextStyle(
                color: correct ? AppColors.matcha : AppColors.persimmon,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        FilledButton(
          onPressed: onFinish,
          child: const Text('Verify my Can-Do'),
        ),
      ],
    );
  }
}

class _CompleteStep extends StatelessWidget {
  const _CompleteStep({required this.mission, required this.onClose});
  final Mission mission;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const LeoCompanion(
        mood: LeoMood.cheer,
        size: 104,
        message: 'You did it! I saved this memory in our cosy Nest.',
      ),
      const SizedBox(height: 14),
      Text(
        'Can-Do verified!',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: 8),
      Text(mission.canDo, textAlign: TextAlign.center),
      const SizedBox(height: 18),
      Card(
        color: AppColors.bambooMist,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(mission.rewardEmoji, style: const TextStyle(fontSize: 44)),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  '${mission.reward} unlocked',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 22),
      FilledButton(onPressed: onClose, child: const Text('Return to my Nest')),
    ],
  );
}
