import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../config/storage_keys.dart';
import '../data/character_data.dart';
import '../models/character_entry.dart';
import '../models/app_models.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/leo_sprite.dart';

@immutable
class WritingProgress {
  const WritingProgress({this.bestScores = const {}});

  final Map<String, int> bestScores;
}

class WritingProgressNotifier extends Notifier<WritingProgress> {
  static const _storageKey = 'writing_best_scores';

  @override
  WritingProgress build() {
    final box = Hive.isBoxOpen(StorageKeys.userData)
        ? Hive.box<dynamic>(StorageKeys.userData)
        : null;
    final raw = box?.get(_storageKey);
    if (raw is Map) {
      return WritingProgress(
        bestScores: raw.map(
          (key, value) => MapEntry('$key', (value as num).toInt()),
        ),
      );
    }
    return const WritingProgress();
  }

  Future<void> record(String character, int score) async {
    final previous = state.bestScores[character] ?? 0;
    if (score <= previous) return;
    final updated = {...state.bestScores, character: score};
    state = WritingProgress(bestScores: updated);
    if (Hive.isBoxOpen(StorageKeys.userData)) {
      await Hive.box<dynamic>(StorageKeys.userData).put(_storageKey, updated);
    }
  }
}

final writingProgressProvider =
    NotifierProvider<WritingProgressNotifier, WritingProgress>(
      WritingProgressNotifier.new,
    );

class _PracticeCharacter {
  const _PracticeCharacter(this.symbol, this.reading, this.strokes);

  final String symbol;
  final String reading;
  final List<List<Offset>> strokes;
}

const _guidedCharacters = <_PracticeCharacter>[
  _PracticeCharacter('一', 'ichi · one', [
    [Offset(.18, .51), Offset(.82, .49)],
  ]),
  _PracticeCharacter('川', 'kawa · river', [
    [Offset(.28, .20), Offset(.27, .78)],
    [Offset(.50, .16), Offset(.49, .81)],
    [Offset(.71, .19), Offset(.72, .78)],
  ]),
  _PracticeCharacter('山', 'yama · mountain', [
    [Offset(.50, .18), Offset(.50, .78)],
    [Offset(.22, .42), Offset(.22, .78), Offset(.78, .78)],
    [Offset(.78, .39), Offset(.78, .78)],
  ]),
  _PracticeCharacter('木', 'ki · tree', [
    [Offset(.50, .15), Offset(.50, .84)],
    [Offset(.20, .42), Offset(.80, .42)],
    [Offset(.49, .43), Offset(.25, .76)],
    [Offset(.51, .43), Offset(.78, .76)],
  ]),
  _PracticeCharacter('あ', 'a · hiragana', [
    [Offset(.23, .34), Offset(.70, .29)],
    [Offset(.47, .18), Offset(.39, .74)],
    [
      Offset(.61, .40),
      Offset(.76, .48),
      Offset(.72, .68),
      Offset(.51, .78),
      Offset(.29, .67),
      Offset(.34, .49),
      Offset(.58, .38),
    ],
  ]),
];

final _practiceCharacters = CharacterSet.values
    .expand(
      (set) => characterLibrary[set]!.map((entry) {
        final guided = _guidedCharacters
            .where((item) => item.symbol == entry.symbol)
            .firstOrNull;
        return guided ??
            _PracticeCharacter(
              entry.symbol,
              '${entry.reading} · ${switch (set) {
                CharacterSet.hiragana => 'hiragana',
                CharacterSet.katakana => 'katakana',
                CharacterSet.kanjiN5 => 'N5 kanji',
              }}',
              const [],
            );
      }),
    )
    .toList(growable: false);

enum _LibraryScope { today, myLevel, all }

class WritingCanvasView extends ConsumerStatefulWidget {
  const WritingCanvasView({super.key, this.initialCharacter});
  final String? initialCharacter;

  @override
  ConsumerState<WritingCanvasView> createState() => _WritingCanvasViewState();
}

class _WritingCanvasViewState extends ConsumerState<WritingCanvasView> {
  _PracticeCharacter _character = _practiceCharacters.first;
  _LibraryScope _scope = _LibraryScope.today;
  final List<List<Offset>> _strokes = [];
  int? _score;

  @override
  void initState() {
    super.initState();
    if (widget.initialCharacter != null) {
      final match = _practiceCharacters
          .where((c) => c.symbol == widget.initialCharacter)
          .firstOrNull;
      if (match != null) _character = match;
    }
  }

  void _startStroke(Offset point, Size size) {
    setState(() {
      _score = null;
      _strokes.add([_normalize(point, size)]);
    });
  }

  void _continueStroke(Offset point, Size size) {
    if (_strokes.isEmpty) return;
    setState(() => _strokes.last.add(_normalize(point, size)));
  }

  Offset _normalize(Offset point, Size size) => Offset(
    (point.dx / size.width).clamp(0.0, 1.0),
    (point.dy / size.height).clamp(0.0, 1.0),
  );

  void _undo() {
    if (_strokes.isEmpty) return;
    setState(() {
      _strokes.removeLast();
      _score = null;
    });
  }

  void _clear() => setState(() {
    _strokes.clear();
    _score = null;
  });

  void _checkWriting() {
    final score = _character.strokes.isEmpty
        ? _calculateLayoutScore(_strokes)
        : _calculateScore(_strokes, _character.strokes);
    setState(() => _score = score);
    ref.read(writingProgressProvider.notifier).record(_character.symbol, score);
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(writingProgressProvider);
    final learner = ref.watch(progressProvider);
    final available = _targetsFor(_scope, learner.stage);
    final selected = available.contains(_character)
        ? _character
        : available.first;
    if (selected != _character) _character = selected;
    final best = progress.bestScores[_character.symbol] ?? 0;

    return ResponsiveContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Practice writing',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          const Text(
            'Choose today’s set, your current route, or the complete character library.',
          ),
          const SizedBox(height: 10),
          SegmentedButton<_LibraryScope>(
            segments: const [
              ButtonSegment(value: _LibraryScope.today, label: Text('Today')),
              ButtonSegment(
                value: _LibraryScope.myLevel,
                label: Text('My level'),
              ),
              ButtonSegment(value: _LibraryScope.all, label: Text('All')),
            ],
            selected: {_scope},
            onSelectionChanged: (value) => setState(() {
              _scope = value.first;
              _character = _targetsFor(_scope, learner.stage).first;
              _strokes.clear();
              _score = null;
            }),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.peach,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _character.symbol,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<_PracticeCharacter>(
                        isExpanded: true,
                        value: _character,
                        borderRadius: BorderRadius.circular(16),
                        items: available
                            .map(
                              (item) => DropdownMenuItem(
                                value: item,
                                child: Text('${item.symbol}  ${item.reading}'),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _character = value;
                            _strokes.clear();
                            _score = null;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      const Text(
                        'BEST',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.muted,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '$best%',
                        style: const TextStyle(
                          color: AppColors.teal,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 1,
            child: Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                  return MouseRegion(
                    cursor: SystemMouseCursors.precise,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanStart: (details) =>
                          _startStroke(details.localPosition, size),
                      onPanUpdate: (details) =>
                          _continueStroke(details.localPosition, size),
                      child: CustomPaint(
                        painter: _WritingPainter(
                          targetSymbol: _character.symbol,
                          guideStrokes: _character.strokes,
                          userStrokes: _strokes,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  onPressed: _strokes.isEmpty ? null : _undo,
                  icon: const Icon(Icons.undo_rounded),
                  label: const Text('Undo'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  onPressed: _strokes.isEmpty ? null : _clear,
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Clear'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: _strokes.isEmpty ? null : _checkWriting,
                  icon: const Icon(Icons.auto_awesome_rounded),
                  label: const Text('Check'),
                ),
              ),
            ],
          ),
          if (_score case final score?) ...[
            const SizedBox(height: 12),
            _LeoFeedback(score: score, guided: _character.strokes.isNotEmpty),
          ],
          const SizedBox(height: 16),
          const _WritingTips(),
        ],
      ),
    );
  }
}

class _WritingPainter extends CustomPainter {
  const _WritingPainter({
    required this.targetSymbol,
    required this.guideStrokes,
    required this.userStrokes,
  });

  final String targetSymbol;
  final List<List<Offset>> guideStrokes;
  final List<List<Offset>> userStrokes;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.coral.withValues(alpha: .11)
      ..strokeWidth = 1;
    final dashPaint = Paint()
      ..color = AppColors.coral.withValues(alpha: .16)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      gridPaint,
    );
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      gridPaint,
    );
    _drawDashedLine(
      canvas,
      Offset.zero,
      Offset(size.width, size.height),
      dashPaint,
    );
    _drawDashedLine(
      canvas,
      Offset(size.width, 0),
      Offset(0, size.height),
      dashPaint,
    );

    final guidePaint = Paint()
      ..color = AppColors.charcoal.withValues(alpha: .16)
      ..strokeWidth = math.max(15, size.width * .055)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    if (guideStrokes.isEmpty) {
      final painter = TextPainter(
        text: TextSpan(
          text: targetSymbol,
          style: TextStyle(
            color: AppColors.charcoal.withValues(alpha: .13),
            fontSize: size.width * .68,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        Offset(
          (size.width - painter.width) / 2,
          (size.height - painter.height) / 2,
        ),
      );
    } else {
      for (final stroke in guideStrokes) {
        _drawStroke(canvas, stroke, size, guidePaint);
      }
    }

    final userPaint = Paint()
      ..color = AppColors.teal
      ..strokeWidth = math.max(7, size.width * .025)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final stroke in userStrokes) {
      _drawStroke(canvas, stroke, size, userPaint);
    }
  }

  void _drawStroke(Canvas canvas, List<Offset> points, Size size, Paint paint) {
    if (points.isEmpty) return;
    final scaled = points
        .map((point) => Offset(point.dx * size.width, point.dy * size.height))
        .toList();
    if (scaled.length == 1) {
      canvas.drawCircle(
        scaled.first,
        paint.strokeWidth / 2,
        paint..style = PaintingStyle.fill,
      );
      paint.style = PaintingStyle.stroke;
      return;
    }
    final path = Path()..moveTo(scaled.first.dx, scaled.first.dy);
    for (var i = 1; i < scaled.length; i++) {
      final previous = scaled[i - 1];
      final current = scaled[i];
      path.quadraticBezierTo(
        previous.dx,
        previous.dy,
        (previous.dx + current.dx) / 2,
        (previous.dy + current.dy) / 2,
      );
    }
    path.lineTo(scaled.last.dx, scaled.last.dy);
    canvas.drawPath(path, paint);
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dash = 7.0;
    const gap = 7.0;
    final delta = end - start;
    final distance = delta.distance;
    final direction = delta / distance;
    for (var traveled = 0.0; traveled < distance; traveled += dash + gap) {
      canvas.drawLine(
        start + direction * traveled,
        start + direction * math.min(traveled + dash, distance),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WritingPainter oldDelegate) => true;
}

int _calculateScore(List<List<Offset>> drawn, List<List<Offset>> guide) {
  final userPoints = drawn.expand((stroke) => _resample(stroke, 12)).toList();
  final guideByStroke = guide.map((stroke) => _resample(stroke, 28)).toList();
  final guidePoints = guideByStroke.expand((stroke) => stroke).toList();
  if (userPoints.isEmpty || guidePoints.isEmpty) return 0;

  double nearest(Offset point, List<Offset> candidates) => candidates
      .map((candidate) => (candidate - point).distance)
      .reduce(math.min);

  final proximity =
      userPoints
          .map(
            (point) => (1 - nearest(point, guidePoints) / .18).clamp(0.0, 1.0),
          )
          .reduce((a, b) => a + b) /
      userPoints.length;
  final coverage =
      guidePoints
          .map((point) => nearest(point, userPoints) <= .10 ? 1.0 : 0.0)
          .reduce((a, b) => a + b) /
      guidePoints.length;
  final strokeCount =
      1 -
      ((drawn.length - guide.length).abs() /
              math.max(drawn.length, guide.length))
          .clamp(0.0, 1.0);
  return (100 * (proximity * .45 + coverage * .40 + strokeCount * .15))
      .round()
      .clamp(0, 100);
}

int _calculateLayoutScore(List<List<Offset>> drawn) {
  final points = drawn.expand((stroke) => stroke).toList();
  if (points.length < 3) return 10;
  final minX = points.map((p) => p.dx).reduce(math.min);
  final maxX = points.map((p) => p.dx).reduce(math.max);
  final minY = points.map((p) => p.dy).reduce(math.min);
  final maxY = points.map((p) => p.dy).reduce(math.max);
  final centre = Offset((minX + maxX) / 2, (minY + maxY) / 2);
  final centred = (1 - (centre - const Offset(.5, .5)).distance / .7).clamp(
    0.0,
    1.0,
  );
  final coverage = (((maxX - minX) * (maxY - minY)) / .42).clamp(0.0, 1.0);
  final effort = (points.length / 35).clamp(0.0, 1.0);
  return (100 * (centred * .45 + coverage * .35 + effort * .20)).round();
}

List<_PracticeCharacter> _targetsFor(
  _LibraryScope scope,
  ProficiencyStage stage,
) {
  final unlockedCount = switch (stage) {
    ProficiencyStage.kittenSteps => 46,
    ProficiencyStage.firstEncounters => 92,
    _ => _practiceCharacters.length,
  };
  final unlocked = _practiceCharacters.take(unlockedCount).toList();
  if (scope == _LibraryScope.all) return _practiceCharacters;
  if (scope == _LibraryScope.myLevel) return unlocked;
  final start = japanDayIndex() % unlocked.length;
  return List.generate(
    8,
    (index) => unlocked[(start + index) % unlocked.length],
  );
}

int japanDayIndex() {
  final now = DateTime.now().toUtc().add(const Duration(hours: 9));
  return now.difference(DateTime(now.year)).inDays;
}

List<Offset> _resample(List<Offset> points, int samplesPerSegment) {
  if (points.length < 2) return points;
  final result = <Offset>[];
  for (var i = 1; i < points.length; i++) {
    for (var sample = 0; sample < samplesPerSegment; sample++) {
      final t = sample / samplesPerSegment;
      result.add(Offset.lerp(points[i - 1], points[i], t)!);
    }
  }
  result.add(points.last);
  return result;
}

class _LeoFeedback extends StatelessWidget {
  const _LeoFeedback({required this.score, required this.guided});

  final int score;
  final bool guided;

  @override
  Widget build(BuildContext context) {
    final message = switch (score) {
      >= 90 => 'Purr-fect! Your shape and coverage are excellent.',
      >= 75 => 'Lovely work! One more careful trace will make it shine.',
      >= 55 => 'Good start! Follow the pale guide a little more closely.',
      _ => 'Keep going! Slow strokes are strong strokes.',
    };
    return Card(
      color: score >= 75
          ? AppColors.teal.withValues(alpha: .12)
          : AppColors.peach,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            LeoSprite(
              pose: score >= 75 ? LeoPose.celebrate : LeoPose.smile,
              size: 58,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Leo says: $score%',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    guided
                        ? message
                        : '$message This is a layout score; choose a guided character for stroke-order scoring.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WritingTips extends StatelessWidget {
  const _WritingTips();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lightbulb_outline_rounded, color: AppColors.coral),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Writing tip: match the stroke count and cover the full guide. Accuracy matters more than speed.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
