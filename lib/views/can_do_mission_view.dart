import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_models.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

/// A short, forgiving practice for one real-world Can-Do mission.
class CanDoMissionView extends ConsumerStatefulWidget {
  const CanDoMissionView({super.key, required this.mission});

  final Mission mission;

  @override
  ConsumerState<CanDoMissionView> createState() => _CanDoMissionViewState();
}

class _CanDoMissionViewState extends ConsumerState<CanDoMissionView> {
  int? _selected;
  bool _checked = false;
  bool _complete = false;

  Future<void> _check() async {
    final selected = _selected;
    if (selected == null) return;
    if (selected != widget.mission.correctOption) {
      setState(() => _checked = true);
      return;
    }
    await ref.read(progressProvider.notifier).completeMission(widget.mission);
    if (mounted) {
      setState(() {
        _checked = true;
        _complete = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mission = widget.mission;
    return Scaffold(
      appBar: AppBar(title: const Text('Can-Do practice')),
      body: SafeArea(
        child: ResponsiveContent(
          fillHeight: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Chip(label: Text('${mission.stage.label} · ${mission.district}')),
              const SizedBox(height: 12),
              Text(
                mission.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              Text(mission.canDo),
              const SizedBox(height: 20),
              Card(
                color: AppColors.sakura.withValues(alpha: .45),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      Text(
                        mission.phrase,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        mission.reading,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.muted),
                      ),
                      const SizedBox(height: 8),
                      Text(mission.translation, textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Choose the best meaning:',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              for (var index = 0; index < mission.options.length; index++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OutlinedButton(
                    onPressed: _complete
                        ? null
                        : () => setState(() {
                            _selected = index;
                            _checked = false;
                          }),
                    style: OutlinedButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      side: BorderSide(
                        color: _selected == index
                            ? AppColors.persimmon
                            : AppColors.bambooMist,
                        width: _selected == index ? 2 : 1,
                      ),
                    ),
                    child: Text(mission.options[index]),
                  ),
                ),
              if (_checked && !_complete)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'Nearly. Try another meaning — practice is for learning.',
                    style: TextStyle(color: AppColors.persimmon),
                  ),
                ),
              if (_complete) ...[
                const SizedBox(height: 8),
                Text(
                  'Can-Do complete! +${mission.xp} XP · ${mission.reward}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.matcha,
                  ),
                ),
                const SizedBox(height: 8),
                Text(mission.cultureNote),
              ],
              const Spacer(),
              FilledButton(
                onPressed: _complete
                    ? () => Navigator.of(context).pop()
                    : _check,
                child: Text(_complete ? 'Back to my route' : 'Check answer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
