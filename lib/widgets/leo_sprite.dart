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
                  aspectRatio: 2.0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x33000000),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, _) {
                          final phase = _controller.value;
                          final journey = phase < .5
                              ? phase * 2
                              : (1 - phase) * 2;
                          final t = Curves.easeInOut.transform(journey);
                          final chasing = t > .76;
                          return Stack(
                            children: [
                              // Background scene
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: _LoadingScenePainter(
                                    phase: phase,
                                  ),
                                ),
                              ),
                              // Vignette overlay
                              Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(28),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color(0x08000000),
                                        Colors.transparent,
                                        Color(0x30000000),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Leo + butterfly
                              LayoutBuilder(
                                builder: (context, bounds) {
                                  final leoSize = 110.0;
                                  final groundY =
                                      bounds.maxHeight - leoSize - 18;
                                  final leoLeft = _caught
                                      ? (bounds.maxWidth -
                                          leoSize -
                                          44)
                                      : 8 +
                                          t *
                                              (bounds.maxWidth -
                                                  leoSize -
                                                  44);
                                  return Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned(
                                        left: leoLeft,
                                        top: _caught
                                            ? groundY - 6
                                            : chasing
                                                ? groundY -
                                                    24 +
                                                    8 *
                                                        math.sin(phase *
                                                            math.pi *
                                                            4)
                                                        .abs()
                                                : groundY +
                                                    3 *
                                                        math.sin(phase *
                                                            math.pi *
                                                            4)
                                                        .abs(),
                                        child: Transform.flip(
                                          flipX:
                                              !_caught && phase >= .5,
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
                                      Positioned(
                                        left: _caught
                                            ? bounds.maxWidth - 72
                                            : 52 +
                                                t *
                                                    (bounds.maxWidth -
                                                        100),
                                        top: _caught
                                            ? groundY - 46
                                            : groundY -
                                                26 +
                                                14 *
                                                    math.sin(phase *
                                                            math.pi *
                                                            2)
                                                        .abs(),
                                        child: const Text(
                                          '🦋',
                                          style:
                                              TextStyle(fontSize: 24),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
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
  _LoadingScenePainter({required this.phase});
  final double phase;

  static const _sky1 = Color(0xFFC8E6F5);
  static const _sky2 = Color(0xFFD4ECFA);
  static const _sky3 = Color(0xFFE0F2FF);
  static const _sun = Color(0xFFFFE082);
  static const _hill = Color(0xFF8BC78B);
  static const _grass = Color(0xFF6BAF5B);
  static const _grassDark = Color(0xFF5A9E4A);
  static const _cloud = Color(0x88FFFFFF);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sky bands
    _drawRect(canvas, 0, 0, w, h * .3, _sky1);
    _drawRect(canvas, 0, h * .3, w, h * .15, _sky2);
    _drawRect(canvas, 0, h * .45, w, h * .55, _sky3);

    // Sun with pixel glow
    final sunX = 42.0;
    final sunY = h * .12;
    _drawPixelCircle(canvas, sunX, sunY, 16, _sun);
    _drawPixelCircle(canvas, sunX, sunY, 10, const Color(0xFFFFF176));

    // Drifting clouds
    final dx = 10 * math.sin(phase * math.pi * 1.3);
    _drawPixelCloud(canvas, w * .55 + dx, h * .08, 36, 14, _cloud);
    _drawPixelCloud(canvas, w * .78 + dx * .6, h * .18, 28, 10, const Color(0x66FFFFFF));

    // Rolling hill
    final hillPath = Path()
      ..moveTo(-10, h * .78)
      ..quadraticBezierTo(w * .3, h * .55, w * .55, h * .68)
      ..quadraticBezierTo(w * .8, h * .60, w + 10, h * .72)
      ..lineTo(w + 10, h * .80)
      ..lineTo(-10, h * .80)
      ..close();
    canvas.drawPath(hillPath, Paint()..color = _hill);

    // Grass strip
    _drawRect(canvas, 0, h * .80, w, h * .20, _grass);
    // Grass texture lines
    final grassPaint = Paint()..color = _grassDark..strokeWidth = 1.5;
    for (var x = 0.0; x < w; x += 7) {
      canvas.drawLine(Offset(x, h * .80), Offset(x - 3, h * .80 + 6), grassPaint);
      canvas.drawLine(Offset(x, h * .80), Offset(x + 3, h * .80 + 8), grassPaint);
    }

    // Small tree on the hill
    final treeX = w * .22;
    final treeBase = h * .72;
    _drawRect(canvas, treeX - 3, treeBase - 18, 6, 18, const Color(0xFF8D6E63));
    _drawPixelCircle(canvas, treeX, treeBase - 24, 14, const Color(0xFF66BB6A));
    _drawPixelCircle(canvas, treeX - 8, treeBase - 18, 10, const Color(0xFF4CAF50));
    _drawPixelCircle(canvas, treeX + 8, treeBase - 18, 10, const Color(0xFF43A047));

    // Flowers
    _drawPixelFlower(canvas, 24, h * .78, const Color(0xFFFFB7C5));
    _drawPixelFlower(canvas, 68, h * .79, const Color(0xFFFFE066));
    _drawPixelFlower(canvas, w * .48, h * .77, const Color(0xFFCE93D8));
    _drawPixelFlower(canvas, w - 48, h * .78, const Color(0xFFFF8A80));
    _drawPixelFlower(canvas, w - 86, h * .79, const Color(0xFFFFB7C5));

    // Little fence
    final fenceY = h * .74;
    final fencePaint = Paint()..color = const Color(0xFFD7CCC8)..strokeWidth = 3..strokeCap = StrokeCap.round;
    for (var i = 0; i < 6; i++) {
      final fx = w * .58 + i * 18;
      canvas.drawLine(Offset(fx, fenceY), Offset(fx, fenceY - 14), fencePaint);
    }
    canvas.drawLine(Offset(w * .58, fenceY - 4), Offset(w * .58 + 90, fenceY - 4), fencePaint);
    canvas.drawLine(Offset(w * .58, fenceY - 11), Offset(w * .58 + 90, fenceY - 11), fencePaint);
  }

  void _drawRect(Canvas c, double x, double y, double w, double h, Color color) {
    c.drawRect(Rect.fromLTWH(x, y, w, h), Paint()..color = color);
  }

  void _drawPixelCircle(Canvas c, double cx, double cy, double r, Color color) {
    final paint = Paint()..color = color;
    final step = r > 12 ? 4.0 : 3.0;
    for (var x = -r; x <= r; x += step) {
      for (var y = -r; y <= r; y += step) {
        if (x * x + y * y <= r * r) {
          c.drawRect(Rect.fromLTWH(cx + x, cy + y, step, step), paint);
        }
      }
    }
  }

  void _drawPixelCloud(Canvas c, double cx, double cy, double w, double h, Color color) {
    final paint = Paint()..color = color;
    _drawRect(c, cx - w * .3, cy, w * .6, h, color);
    _drawRect(c, cx - w * .15, cy - h * .4, w * .5, h * .8, color);
    _drawRect(c, cx + w * .1, cy + h * .1, w * .35, h * .65, color);
  }

  void _drawPixelFlower(Canvas c, double x, double y, Color petal) {
    final stem = Paint()..color = const Color(0xFF66BB6A)..strokeWidth = 2;
    c.drawLine(Offset(x, y + 6), Offset(x, y - 2), stem);
    c.drawRect(Rect.fromCenter(center: Offset(x, y - 6), width: 5, height: 5), Paint()..color = petal);
    c.drawRect(Rect.fromCenter(center: Offset(x + 4, y - 4), width: 5, height: 5), Paint()..color = petal);
    c.drawRect(Rect.fromCenter(center: Offset(x - 4, y - 4), width: 5, height: 5), Paint()..color = petal);
    c.drawRect(Rect.fromCenter(center: Offset(x, y - 2), width: 4, height: 4), Paint()..color = const Color(0xFFFFEB3B));
  }

  @override
  bool shouldRepaint(covariant _LoadingScenePainter old) => phase != old.phase;
}
