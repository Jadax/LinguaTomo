import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../data/character_data.dart';
import '../models/character_entry.dart';
import '../models/app_models.dart';
import '../providers/app_state.dart';
import '../services/ocr_result.dart';
import '../services/ocr_service.dart';
import '../theme/app_theme.dart';
import '../widgets/leo_sprite.dart';

final _photoTargets = CharacterSet.values
    .expand((set) => characterLibrary[set]!)
    .toList(growable: false);

enum _PhotoScope { today, myLevel, all }

class SnapGradeView extends ConsumerStatefulWidget {
  const SnapGradeView({super.key});

  @override
  ConsumerState<SnapGradeView> createState() => _SnapGradeViewState();
}

class _SnapGradeViewState extends ConsumerState<SnapGradeView> {
  final ImagePicker _picker = ImagePicker();
  final JapaneseOcrService _ocr = JapaneseOcrService();
  String _target = _photoTargets.first.symbol;
  _PhotoScope _scope = _PhotoScope.today;
  Uint8List? _bytes;
  OcrAnalysis? _analysis;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _ocr.dispose();
    super.dispose();
  }

  Future<void> _capture(ImageSource source) async {
    final photo = await _picker.pickImage(
      source: source,
      imageQuality: 90,
      maxWidth: 1800,
    );
    if (photo == null) return;
    setState(() {
      _analysis = null;
      _busy = true;
      _error = null;
    });
    final bytes = await photo.readAsBytes();
    if (!mounted) return;
    setState(() => _bytes = bytes);
    if (!_ocr.isSupported) {
      setState(() {
        _busy = false;
        _error =
            'Character OCR is available in the Android and iOS apps. This browser keeps your photo private, but cannot yet recognise it. Use Live Writing for browser-based grading.';
      });
      return;
    }
    try {
      final result = await _ocr.analyze(photo);
      if (!mounted) return;
      setState(() {
        _analysis = result;
        _busy = false;
      });
      final grade = _grade(result, _target);
      await ref
          .read(handwritingHistoryProvider.notifier)
          .add(
            HandwritingRecord(
              character: _target,
              score: grade.total,
              accuracy: grade.accuracy,
              balance: grade.balance,
              createdAt: DateTime.now(),
              evidenceMode: 'photo',
            ),
          );
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error =
              'Leo could not read this photo. Try brighter, even lighting and keep the page flat.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final learner = ref.watch(progressProvider);
    final targets = _photoTargetsFor(_scope, learner.stage);
    if (!targets.any((item) => item.symbol == _target)) {
      _target = targets.first.symbol;
    }
    final grade = _analysis == null ? null : _grade(_analysis!, _target);
    final history = ref.watch(handwritingHistoryProvider);
    return ResponsiveContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Snap & Grade',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          const Text(
            'Write on paper, take a clear photo, and check recognition and page balance. Pick today’s set, your route, or all available characters.',
          ),
          const SizedBox(height: 10),
          SegmentedButton<_PhotoScope>(
            segments: const [
              ButtonSegment(value: _PhotoScope.today, label: Text('Today')),
              ButtonSegment(
                value: _PhotoScope.myLevel,
                label: Text('My level'),
              ),
              ButtonSegment(value: _PhotoScope.all, label: Text('All')),
            ],
            selected: {_scope},
            onSelectionChanged: (value) => setState(() {
              _scope = value.first;
              _target = _photoTargetsFor(_scope, learner.stage).first.symbol;
              _analysis = null;
            }),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Text(
                    'Target character',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _target,
                        isExpanded: true,
                        items: targets
                            .map(
                              (entry) => DropdownMenuItem(
                                value: entry.symbol,
                                child: Text(
                                  '${entry.symbol}  ${entry.reading} · ${entry.meaning}',
                                  style: const TextStyle(fontSize: 26),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _target = value;
                              _analysis = null;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: _bytes == null
                  ? const _CameraPrompt()
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.memory(_bytes!, fit: BoxFit.contain),
                        if (_analysis != null)
                          CustomPaint(
                            painter: _EvidenceOverlay(_analysis!, _target),
                          ),
                        if (_busy)
                          Container(
                            color: Colors.white70,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _busy ? null : () => _capture(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: const Text('Take photo'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : () => _capture(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Choose photo'),
                ),
              ),
            ],
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                _error!,
                style: const TextStyle(color: AppColors.persimmon),
              ),
            ),
          if (grade != null) ...[
            const SizedBox(height: 14),
            _GradeResult(
              target: _target,
              recognized: _analysis!.text,
              grade: grade,
            ),
          ],
          const SizedBox(height: 14),
          const Card(
            color: AppColors.bambooMist,
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.fact_check_outlined, color: AppColors.matcha),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Photo evidence can assess recognition and page balance. It cannot prove stroke order, pressure, or rhythm. Use Live Writing for those technique checks.',
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (history.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              'Recent improvement',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 82,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: math.min(history.length, 8),
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, index) => Container(
                  width: 76,
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        history[index].character,
                        style: const TextStyle(fontSize: 25),
                      ),
                      Text(
                        '${history[index].score}%',
                        style: const TextStyle(
                          color: AppColors.matcha,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PhotoGrade {
  const _PhotoGrade({
    required this.total,
    required this.accuracy,
    required this.balance,
  });
  final int total;
  final int accuracy;
  final int balance;
}

List<CharacterEntry> _photoTargetsFor(
  _PhotoScope scope,
  ProficiencyStage stage,
) {
  final unlockedCount = switch (stage) {
    ProficiencyStage.kittenSteps => 46,
    ProficiencyStage.firstEncounters => 92,
    _ => _photoTargets.length,
  };
  final unlocked = _photoTargets.take(unlockedCount).toList();
  if (scope == _PhotoScope.all) return _photoTargets;
  if (scope == _PhotoScope.myLevel) return unlocked;
  final japanNow = DateTime.now().toUtc().add(const Duration(hours: 9));
  final start =
      japanNow.difference(DateTime(japanNow.year)).inDays % unlocked.length;
  return List.generate(
    8,
    (index) => unlocked[(start + index) % unlocked.length],
  );
}

_PhotoGrade _grade(OcrAnalysis analysis, String target) {
  final normalized = analysis.text.replaceAll(RegExp(r'\s'), '');
  final accuracy = normalized.contains(target)
      ? 100
      : (normalized.isEmpty ? 0 : 35);
  var balance = 0;
  if (analysis.boxes.isNotEmpty &&
      analysis.imageSize.width > 0 &&
      analysis.imageSize.height > 0) {
    final combined = analysis.boxes.reduce((a, b) => a.expandToInclude(b));
    final dx = ((combined.center.dx / analysis.imageSize.width) - .5).abs() * 2;
    final dy =
        ((combined.center.dy / analysis.imageSize.height) - .5).abs() * 2;
    balance = (100 * (1 - ((dx + dy) / 2).clamp(0.0, 1.0))).round();
  }
  return _PhotoGrade(
    total: (accuracy * .7 + balance * .3).round(),
    accuracy: accuracy,
    balance: balance,
  );
}

class _CameraPrompt extends StatelessWidget {
  const _CameraPrompt();
  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.document_scanner_outlined,
            size: 54,
            color: AppColors.matcha,
          ),
          SizedBox(height: 12),
          Text(
            'Place one character near the centre of plain paper',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 5),
          Text(
            'Use soft, even lighting and avoid shadows.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class _GradeResult extends StatelessWidget {
  const _GradeResult({
    required this.target,
    required this.recognized,
    required this.grade,
  });
  final String target;
  final String recognized;
  final _PhotoGrade grade;
  @override
  Widget build(BuildContext context) => Card(
    color: grade.accuracy == 100 ? AppColors.bambooMist : AppColors.sakura,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              LeoSprite(
                pose: grade.accuracy == 100 ? LeoPose.celebrate : LeoPose.smile,
                size: 62,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Leo’s photo check: ${grade.total}%',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      grade.accuracy == 100
                          ? 'I recognized $target clearly!'
                          : 'I read “${recognized.trim().isEmpty ? 'no character' : recognized.trim()}”. Try a darker pen and flatter photo.',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ScoreBar(label: 'Character recognition', value: grade.accuracy),
          const SizedBox(height: 8),
          _ScoreBar(label: 'Page balance', value: grade.balance),
        ],
      ),
    ),
  );
}

class _ScoreBar extends StatelessWidget {
  const _ScoreBar({required this.label, required this.value});
  final String label;
  final int value;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      SizedBox(width: 140, child: Text(label)),
      Expanded(
        child: LinearProgressIndicator(
          value: value / 100,
          minHeight: 8,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      const SizedBox(width: 8),
      SizedBox(
        width: 38,
        child: Text(
          '$value%',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    ],
  );
}

class _EvidenceOverlay extends CustomPainter {
  const _EvidenceOverlay(this.analysis, this.target);
  final OcrAnalysis analysis;
  final String target;
  @override
  void paint(Canvas canvas, Size size) {
    if (analysis.imageSize.isEmpty) return;
    final scale = math.min(
      size.width / analysis.imageSize.width,
      size.height / analysis.imageSize.height,
    );
    final rendered = Size(
      analysis.imageSize.width * scale,
      analysis.imageSize.height * scale,
    );
    final offset = Offset(
      (size.width - rendered.width) / 2,
      (size.height - rendered.height) / 2,
    );
    final paint = Paint()
      ..color =
          (analysis.text.contains(target)
                  ? AppColors.matcha
                  : AppColors.persimmon)
              .withValues(alpha: .75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    for (final box in analysis.boxes) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            offset.dx + box.left * scale,
            offset.dy + box.top * scale,
            box.width * scale,
            box.height * scale,
          ),
          const Radius.circular(8),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _EvidenceOverlay oldDelegate) =>
      oldDelegate.analysis != analysis || oldDelegate.target != target;
}
