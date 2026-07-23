import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/app_models.dart';

enum LeoPose { idle, walkA, walkB, sit, smile, meow, celebrate, butterfly }

class LeoSprite extends StatefulWidget {
  const LeoSprite({
    super.key,
    required this.pose,
    this.size = 120,
    this.semanticLabel = 'Leo, your Norwegian Forest Cat learning companion',
  });

  final LeoPose pose;
  final double size;
  final String semanticLabel;

  @override
  State<LeoSprite> createState() => _LeoSpriteState();
}

class _LeoSpriteState extends State<LeoSprite> {
  static Future<ui.Image>? _sheet;

  static Future<ui.Image> _loadSheet() async {
    final data = await rootBundle.load('assets/branding/leo-sprites.png');
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    return (await codec.getNextFrame()).image;
  }

  @override
  Widget build(BuildContext context) {
    _sheet ??= _loadSheet();
    return Semantics(
      image: true,
      label: widget.semanticLabel,
      child: SizedBox.square(
        dimension: widget.size,
        child: FutureBuilder<ui.Image>(
          future: _sheet,
          builder: (context, snapshot) => snapshot.hasData
              ? CustomPaint(
                  painter: _LeoSpritePainter(snapshot.data!, widget.pose.index),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _LeoSpritePainter extends CustomPainter {
  const _LeoSpritePainter(this.sheet, this.frame);

  final ui.Image sheet;
  final int frame;

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = sheet.width / 4;
    final cellHeight = sheet.height / 2;
    final source = Rect.fromLTWH(
      (frame % 4) * cellWidth,
      (frame ~/ 4) * cellHeight,
      cellWidth,
      cellHeight,
    );
    canvas.drawImageRect(
      sheet,
      source,
      Offset.zero & size,
      Paint()..filterQuality = FilterQuality.none,
    );
  }

  @override
  bool shouldRepaint(covariant _LeoSpritePainter oldDelegate) =>
      frame != oldDelegate.frame || sheet != oldDelegate.sheet;
}

class LeoLoadingScreen extends StatefulWidget {
  const LeoLoadingScreen({
    super.key,
    required this.reduceMotion,
    required this.ready,
    required this.onFinished,
    this.onTierSelected,
  });

  final bool reduceMotion;

  /// True once the app has genuinely finished preparing. Leo keeps chasing
  /// the butterfly until this moment, then plays a short catch finale.
  final bool ready;
  final VoidCallback onFinished;
  final ValueChanged<DifficultyTier>? onTierSelected;

  @override
  State<LeoLoadingScreen> createState() => _LeoLoadingScreenState();
}

class _LeoLoadingScreenState extends State<LeoLoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _stepTimer;
  var _walkFrame = false;
  var _caught = false;
  DifficultyTier? _selectedTier;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    if (widget.reduceMotion) {
      _controller.value = 1;
    } else {
      _controller.repeat();
      _stepTimer = Timer.periodic(const Duration(milliseconds: 180), (_) {
        if (mounted) setState(() => _walkFrame = !_walkFrame);
      });
    }
    if (widget.ready) _playFinale();
  }

  @override
  void didUpdateWidget(covariant LeoLoadingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ready && !oldWidget.ready) _playFinale();
  }

  void _playFinale() {
    if (_caught) return;
    if (widget.reduceMotion) {
      setState(() => _caught = true);
      return;
    }
    _stepTimer?.cancel();
    _controller.stop();
    setState(() => _caught = true);
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFFFF7E8),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                AspectRatio(
                  aspectRatio: 2.2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) {
                        final phase = _controller.value;
                        final journey = phase < .5
                            ? phase * 2
                            : (1 - phase) * 2;
                        final t = Curves.easeInOut.transform(journey);
                        final chasing = t > .76;
                        return LayoutBuilder(
                          builder: (context, bounds) {
                            final leoLeft = _caught
                                ? (bounds.maxWidth - 160)
                                : 8 + t * (bounds.maxWidth - 160);
                            final grassHeight = 30.0;
                            final leoSize = 120.0;
                            final leoGroundTop =
                                bounds.maxHeight - grassHeight - leoSize + 4;
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Background scene
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: _LoadingScenePainter(
                                      phase: phase,
                                      bounds: bounds,
                                    ),
                                  ),
                                ),
                                // Leo
                                Positioned(
                                  left: leoLeft,
                                  top: _caught
                                      ? leoGroundTop - 8
                                      : chasing
                                          ? leoGroundTop -
                                              28 +
                                              8 *
                                                  math
                                                      .sin(
                                                        phase * math.pi * 4,
                                                      )
                                                      .abs()
                                          : leoGroundTop +
                                              3 *
                                                  math
                                                      .sin(
                                                        phase * math.pi * 4,
                                                      )
                                                      .abs(),
                                  child: Transform.flip(
                                    flipX: !_caught && phase >= .5,
                                    child: LeoSprite(
                                      pose: _caught
                                          ? LeoPose.celebrate
                                          : chasing
                                          ? LeoPose.butterfly
                                          : (_walkFrame
                                                ? LeoPose.walkA
                                                : LeoPose.walkB),
                                      size: leoSize,
                                    ),
                                  ),
                                ),
                                // Butterfly
                                Positioned(
                                  left: _caught
                                      ? bounds.maxWidth - 80
                                      : 60 + t * (bounds.maxWidth - 110),
                                  top: _caught
                                      ? leoGroundTop - 50
                                      : leoGroundTop -
                                          30 +
                                          14 *
                                              math
                                                  .sin(phase * math.pi * 2)
                                                  .abs(),
                                  child: const Text(
                                    '🦋',
                                    style: TextStyle(fontSize: 26),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'LinguaTomo',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _caught
                      ? 'Pick your level to begin!'
                      : 'Leo is warming up your next Japanese adventure...',
                ),
                const SizedBox(height: 14),
                SizedBox(
                    height: 260,
                    child: SingleChildScrollView(
                      child: RadioGroup<DifficultyTier>(
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _selectedTier = value);
                          widget.onTierSelected?.call(value);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Choose your level',
                              style: Theme.of(context).textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            for (final tier in DifficultyTier.values)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Card(
                                  color: _selectedTier == tier
                                      ? const Color(0xFFD4EDDA)
                                      : Colors.white,
                                  child: RadioListTile<DifficultyTier>(
                                    value: tier,
                                    title: Text(
                                      tier.label,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    subtitle: Text(tier.description),
                                    dense: true,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                if (_caught)
                  FilledButton(
                    onPressed: _selectedTier == null
                        ? null
                        : () => widget.onFinished(),
                    child: const Text('Start learning'),
                  ),
              ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _LoadingScenePainter extends CustomPainter {
  _LoadingScenePainter({required this.phase, required this.bounds});

  final double phase;
  final BoxConstraints bounds;

  @override
  void paint(Canvas canvas, Size size) {
    final grassHeight = 30.0;

    // Sky gradient
    final skyPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(0, size.height - grassHeight),
        [
          const Color(0xFFB8DAF0),
          const Color(0xFFD6ECFF),
          const Color(0xFFE8F4FF),
          const Color(0xFFF0F8E8),
        ],
        [0.0, 0.3, 0.6, 1.0],
      );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height - grassHeight),
      skyPaint,
    );

    // Sun
    final sunCenter = Offset(36, 28);
    final sunGlowPaint = Paint()
      ..color = const Color(0xFFFFF3C4).withValues(alpha: .35);
    canvas.drawCircle(sunCenter, 26, sunGlowPaint);
    final sunPaint = Paint()..color = const Color(0xFFFFD93D);
    canvas.drawCircle(sunCenter, 16, sunPaint);
    // Sun rays
    final rayPaint = Paint()
      ..color = const Color(0xFFFFD93D).withValues(alpha: .5)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4 + phase * 0.3;
      canvas.drawLine(
        sunCenter + Offset(20 * math.cos(angle), 20 * math.sin(angle)),
        sunCenter + Offset(28 * math.cos(angle), 28 * math.sin(angle)),
        rayPaint,
      );
    }

    // Clouds
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: .7);
    final cloudPaintFaint = Paint()..color = Colors.white.withValues(alpha: .45);
    final drift1 = 8 * math.sin(phase * math.pi * 2);
    final drift2 = 6 * math.cos(phase * math.pi * 1.5);
    // Cloud 1
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.58 + drift1, 22),
        width: 48,
        height: 18,
      ),
      cloudPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.58 + 14 + drift1, 17),
        width: 30,
        height: 16,
      ),
      cloudPaint,
    );
    // Cloud 2
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.82 + drift2, 34),
        width: 36,
        height: 14,
      ),
      cloudPaintFaint,
    );

    // Grass
    final grassTop = size.height - grassHeight;
    final grassPaint = Paint()..color = const Color(0xFF7BBF66);
    canvas.drawRect(
      Rect.fromLTWH(0, grassTop, size.width, grassHeight),
      grassPaint,
    );
    // Grass texture bumps
    final bumpPaint = Paint()..color = const Color(0xFF6BAF5B);
    final darkBumpPaint = Paint()..color = const Color(0xFF5A9E4A);
    for (var x = 0.0; x < size.width; x += 10) {
      final h = 4.0 + 2.0 * math.sin(x * 0.15);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, grassTop), width: 10, height: h),
        bumpPaint,
      );
    }
    for (var x = 5.0; x < size.width; x += 14) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, grassTop + 4), width: 7, height: 3),
        darkBumpPaint,
      );
    }
    // Grass edge highlight
    final grassEdgePaint = Paint()..color = const Color(0xFF90C67C);
    canvas.drawRect(
      Rect.fromLTWH(0, grassTop, size.width, 3),
      grassEdgePaint,
    );

    // Flowers
    _drawFlower(canvas, Offset(26, grassTop + 14), const Color(0xFFFFB7C5), 4);
    _drawFlower(canvas, Offset(72, grassTop + 16), const Color(0xFFFFE066), 3.5);
    _drawFlower(canvas, Offset(130, grassTop + 12), const Color(0xFFFF8A80), 3);
    _drawFlower(canvas, Offset(size.width - 55, grassTop + 14), const Color(0xFFFFB7C5), 3.5);
    _drawFlower(canvas, Offset(size.width - 100, grassTop + 16), const Color(0xFFFFE066), 3);
    _drawFlower(canvas, Offset(size.width - 145, grassTop + 13), const Color(0xFFCE93D8), 3.5);

    // Small bush
    final bushPaint = Paint()..color = const Color(0xFF5A9E4A);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width * 0.32, grassTop - 2), width: 22, height: 12),
      bushPaint,
    );
    final bushPaint2 = Paint()..color = const Color(0xFF6BAF5B);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width * 0.32 + 8, grassTop - 4), width: 16, height: 10),
      bushPaint2,
    );
  }

  void _drawFlower(Canvas canvas, Offset center, Color petalColor, double size) {
    // Stem
    final stemPaint = Paint()..color = const Color(0xFF4CAF50)..strokeWidth = 1.5;
    canvas.drawLine(center, center + Offset(0, 6), stemPaint);
    // Petals
    final petalPaint = Paint()..color = petalColor;
    for (var i = 0; i < 5; i++) {
      final angle = i * math.pi * 2 / 5;
      canvas.drawCircle(
        center + Offset(size * 0.6 * math.cos(angle), size * 0.6 * math.sin(angle)),
        size * 0.45,
        petalPaint,
      );
    }
    // Centre
    canvas.drawCircle(center, size * 0.3, Paint()..color = const Color(0xFFFFEB3B));
  }

  @override
  bool shouldRepaint(covariant _LoadingScenePainter old) =>
      phase != old.phase || bounds != old.bounds;
}
