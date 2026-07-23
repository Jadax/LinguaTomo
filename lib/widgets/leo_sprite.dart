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

  // ── Warm storybook palette ────────────────────────────────────────────
  static const _skyTop = Color(0xFFB3DAF1);
  static const _skyMid = Color(0xFFCEE4F8);
  static const _skyLow = Color(0xFFE4F0FC);
  static const _skyHorizon = Color(0xFFF2E8D5);
  static const _sunCore = Color(0xFFFFF176);
  static const _sunGlow = Color(0x55FFE082);
  static const _sunOuter = Color(0x22FFECB3);
  static const _cloudWarm = Color(0xCCFFFFF0);
  static const _cloudSoft = Color(0x99FFFFF6);
  static const _hillFar = Color(0xFFA8C9A5);
  static const _hillMid = Color(0xFF8BBC87);
  static const _grass1 = Color(0xFF6BAF5B);
  static const _grass2 = Color(0xFF7CBD5D);
  static const _grass3 = Color(0xFF5A9E4A);
  static const _grass4 = Color(0xFF8CC96A);
  static const _pathColor = Color(0xFFDDBF8A);
  static const _pathEdge = Color(0xFFC8A56A);
  static const _waterColor = Color(0xFF7CB8D4);
  static const _waterShimmer = Color(0x4490CAE9);
  static const _cottageWall = Color(0xFFF5E6CA);
  static const _cottageRoof = Color(0xFFBA6843);
  static const _cottageRoofDark = Color(0xFFA0522D);
  static const _cottageDoor = Color(0xFF8B5E3C);
  static const _cottageChimney = Color(0xFFC49B7A);
  static const _windowGlow = Color(0xFFFFF3CD);
  static const _treeTrunk = Color(0xFF8D6E63);
  static const _treeTrunkDark = Color(0xFF6D4C41);
  static const _leaf1 = Color(0xFF66BB6A);
  static const _leaf2 = Color(0xFF4CAF50);
  static const _leaf3 = Color(0xFF43A047);
  static const _leaf4 = Color(0xFF2E7D32);
  static const _leaf5 = Color(0xFF81C784);
  static const _fencePost = Color(0xFFE8D5B7);
  static const _fenceRail = Color(0xFFDCC7A8);

  // ── Bird animation wing-flap ──────────────────────────────────────────
  double get _birdWing => (math.sin(phase * math.pi * 6) * 2.5).abs();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── Sky gradient with warm horizon ──────────────────────────────────
    _drawRect(canvas, 0, 0, w, h * .20, _skyTop);
    _drawRect(canvas, 0, h * .20, w, h * .16, _skyMid);
    _drawRect(canvas, 0, h * .36, w, h * .14, _skyLow);
    _drawRect(canvas, 0, h * .50, w, h * .10, _skyHorizon);

    // ── Sun with soft multilayered glow ─────────────────────────────────
    final sunX = 50.0;
    final sunY = h * .10;
    final sunPulse = 1.0 + 0.04 * math.sin(phase * math.pi * 1.8);
    _drawSoftGlow(canvas, sunX, sunY, 32 * sunPulse, _sunOuter);
    _drawSoftGlow(canvas, sunX, sunY, 20 * sunPulse, _sunGlow);
    _drawPixelCircle(canvas, sunX, sunY, 9, _sunCore);
    _drawPixelCircle(canvas, sunX - 2, sunY - 2, 5, const Color(0xFFFFECB3));

    // ── Distant background hill ─────────────────────────────────────────
    final farHill = Path()
      ..moveTo(-10, h * .72)
      ..quadraticBezierTo(w * .15, h * .60, w * .35, h * .66)
      ..quadraticBezierTo(w * .55, h * .58, w * .70, h * .64)
      ..quadraticBezierTo(w * .90, h * .59, w + 10, h * .68)
      ..lineTo(w + 10, h + 10)
      ..lineTo(-10, h + 10)
      ..close();
    canvas.drawPath(farHill, Paint()..color = _hillFar);

    // ── Small pond in the distance ──────────────────────────────────────
    _drawPond(canvas, w * .38, h * .655, 22, 8);

    // ── Animated fluffy clouds ──────────────────────────────────────────
    final dx = 10 * math.sin(phase * math.pi * 1.3);
    _drawFluffyCloud(canvas, w * .52 + dx, h * .06, 44, 22, _cloudWarm);
    _drawFluffyCloud(canvas, w * .76 + dx * .55, h * .16, 32, 16, _cloudSoft);
    _drawFluffyCloud(canvas, w * .12 + dx * .35, h * .22, 28, 13, _cloudSoft);

    // ── Birds ───────────────────────────────────────────────────────────
    _drawBird(canvas, w * .30 + dx * .8, h * .14, 1.0);
    _drawBird(canvas, w * .35 + dx * .7, h * .11, 0.7);

    // ── Main rolling hill ───────────────────────────────────────────────
    final mainHill = Path()
      ..moveTo(-10, h * .82)
      ..quadraticBezierTo(w * .08, h * .63, w * .28, h * .61)
      ..quadraticBezierTo(w * .42, h * .56, w * .55, h * .62)
      ..quadraticBezierTo(w * .72, h * .58, w * .88, h * .64)
      ..quadraticBezierTo(w * .98, h * .58, w + 10, h * .68)
      ..lineTo(w + 10, h + 10)
      ..lineTo(-10, h + 10)
      ..close();
    canvas.drawPath(mainHill, Paint()..color = _hillMid);

    // ── Foreground grass strip ──────────────────────────────────────────
    _drawRect(canvas, 0, h * .80, w, h * .20, _grass1);

    // ── Varied grass texture ────────────────────────────────────────────
    _drawGrassTufts(canvas, w, h);

    // ── Winding path ────────────────────────────────────────────────────
    _drawWindingPath(canvas, w, h);

    // ── Cottage on the hill ─────────────────────────────────────────────
    _drawCottage(canvas, w, h);

    // ── Large detailed tree ─────────────────────────────────────────────
    _drawDetailedTree(canvas, w * .19, h * .63, 1.0);

    // ── Picket fence along path ─────────────────────────────────────────
    _drawPicketFence(canvas, w, h);

    // ── Flowers of various types ────────────────────────────────────────
    _drawFlowerPatch(canvas, 16, h * .79, const Color(0xFFFFB7C5), 1);
    _drawFlowerPatch(canvas, 56, h * .78, const Color(0xFFFFE066), 1);
    _drawTulipFlower(canvas, 120, h * .79, const Color(0xFFFF8A80));
    _drawTulipFlower(canvas, 148, h * .78, const Color(0xFFCE93D8));
    _drawFlowerPatch(canvas, 175, h * .79, const Color(0xFFFFB7C5), 1);
    _drawFlowerPatch(canvas, w - 42, h * .78, const Color(0xFFFF8A80), 1);
    _drawTulipFlower(canvas, w - 72, h * .79, const Color(0xFFFFB7C5));
    _drawTulipFlower(canvas, 210, h * .77, const Color(0xFF64B5F6));
    _drawDaisyFlower(canvas, 40, h * .76, const Color(0xFFFFF9C4));
    _drawDaisyFlower(canvas, w - 30, h * .79, const Color(0xFFFFFFFF));
    _drawFlowerPatch(canvas, w * .44, h * .75, const Color(0xFFF48FB1), 0);
    _drawTulipFlower(canvas, 280, h * .78, const Color(0xFFFFE066));

    // ── Leo shadow on the path ──────────────────────────────────────────
    _drawLeoShadow(canvas, w, h);
  }

  // ═══════════════════════════════════════════════════════════════════
  // Drawing helpers
  // ═══════════════════════════════════════════════════════════════════

  void _drawRect(Canvas c, double x, double y, double w, double h, Color color) {
    c.drawRect(Rect.fromLTWH(x, y, w, h), Paint()..color = color);
  }

  void _drawSoftGlow(Canvas c, double cx, double cy, double r, Color color) {
    final paint = Paint()
      ..color = color
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    c.drawCircle(Offset(cx, cy), r, paint);
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

  void _drawPixelOval(Canvas c, double cx, double cy, double rx, double ry, Color color) {
    final paint = Paint()..color = color;
    final step = 3.0;
    for (var x = -rx; x <= rx; x += step) {
      for (var y = -ry; y <= ry; y += step) {
        if ((x * x) / (rx * rx) + (y * y) / (ry * ry) <= 1) {
          c.drawRect(Rect.fromLTWH(cx + x, cy + y, step, step), paint);
        }
      }
    }
  }

  void _drawFluffyCloud(Canvas c, double cx, double cy, double w, double h, Color color) {
    final paint = Paint()..color = color;
    // Larger puffy shapes
    c.drawOval(Rect.fromCenter(center: Offset(cx - w * .2, cy + h * .15), width: w * .55, height: h * .7), paint);
    c.drawOval(Rect.fromCenter(center: Offset(cx + w * .08, cy + h * .05), width: w * .5, height: h * .75), paint);
    c.drawOval(Rect.fromCenter(center: Offset(cx - w * .08, cy - h * .15), width: w * .42, height: h * .65), paint);
    c.drawOval(Rect.fromCenter(center: Offset(cx + w * .22, cy + h * .1), width: w * .38, height: h * .55), paint);
    c.drawOval(Rect.fromCenter(center: Offset(cx - w * .25, cy + h * .05), width: w * .4, height: h * .5), paint);
    // Flat bottom
    _drawRect(c, cx - w * .3, cy + h * .12, w * .7, h * .45, color);
  }

  void _drawBird(Canvas c, double x, double y, double scale) {
    final paint = Paint()
      ..color = const Color(0xFF5D4E37)
      ..strokeWidth = 1.8 * scale
      ..strokeCap = StrokeCap.round;
    final w = _birdWing;
    // Body
    c.drawLine(Offset(x - 2 * scale, y + 1 * scale), Offset(x + 2 * scale, y + 1 * scale), paint);
    // Left wing
    c.drawLine(Offset(x - 2 * scale, y + 1 * scale), Offset(x - 7 * scale, y - w), paint);
    // Right wing
    c.drawLine(Offset(x - 2 * scale, y + 1 * scale), Offset(x + 5 * scale, y - w), paint);
  }

  void _drawWindingPath(Canvas c, double w, double h) {
    final pathPaint = Paint()
      ..color = _pathColor
      ..style = PaintingStyle.fill;
    final edgePaint = Paint()
      ..color = _pathEdge
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path()
      ..moveTo(w * .58, h * .82)
      ..cubicTo(w * .52, h * .80, w * .44, h * .78, w * .36, h * .76)
      ..cubicTo(w * .28, h * .74, w * .20, h * .73, w * .08, h * .74)
      ..lineTo(w * .08, h * .88)
      ..cubicTo(w * .20, h * .87, w * .28, h * .88, w * .36, h * .89)
      ..cubicTo(w * .44, h * .90, w * .52, h * .92, w * .58, h * .94)
      ..lineTo(w * .70, h * .94)
      ..cubicTo(w * .72, h * .90, w * .74, h * .86, w * .76, h * .84)
      ..cubicTo(w * .78, h * .86, w * .80, h * .90, w * .82, h * .94)
      ..lineTo(w + 10, h * .94)
      ..lineTo(w + 10, h + 10)
      ..lineTo(-10, h + 10)
      ..lineTo(-10, h * .88)
      ..lineTo(w * .08, h * .88)
      ..close();
    c.drawPath(path, pathPaint);
    c.drawPath(path, edgePaint);

    // Path stepping stones / dots
    final dotPaint = Paint()..color = _pathEdge.withAlpha(100);
    for (var x = w * .10; x < w * .56; x += 12) {
      c.drawCircle(Offset(x, h * .85 + (x - w * .08) * 0.015), 1.5, dotPaint);
    }
  }

  void _drawCottage(Canvas c, double w, double h) {
    final cx = w * .68;
    final baseY = h * .58;
    final cottageW = 52.0;
    final cottageH = 38.0;

    // Wall
    _drawRect(c, cx - cottageW / 2, baseY - cottageH, cottageW, cottageH, _cottageWall);

    // Wall outline
    final wallOutline = Paint()
      ..color = const Color(0xFFD4B896)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    c.drawRect(Rect.fromLTWH(cx - cottageW / 2, baseY - cottageH, cottageW, cottageH), wallOutline);

    // Roof - triangular with pixel aesthetic
    final roofPaint = Paint()..color = _cottageRoof;
    final roofPath = Path()
      ..moveTo(cx - cottageW / 2 - 6, baseY - cottageH)
      ..lineTo(cx, baseY - cottageH - 22)
      ..lineTo(cx + cottageW / 2 + 6, baseY - cottageH)
      ..close();
    c.drawPath(roofPath, roofPaint);

    // Roof edge highlights
    final roofEdge = Paint()
      ..color = _cottageRoofDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    c.drawLine(
      Offset(cx - cottageW / 2 - 6, baseY - cottageH),
      Offset(cx, baseY - cottageH - 22),
      roofEdge,
    );
    c.drawLine(
      Offset(cx - cottageW / 2 - 6, baseY - cottageH),
      Offset(cx + cottageW / 2 + 6, baseY - cottageH),
      roofEdge,
    );

    // Chimney
    final chimneyX = cx + cottageW * .25;
    final chimneyW = 10.0;
    _drawRect(c, chimneyX - chimneyW / 2, baseY - cottageH - 16, chimneyW, 22, _cottageChimney);

    // Smoke from chimney
    final smokePaint = Paint()..color = const Color(0x55CCCCCC);
    final smokeOffset = 4 * math.sin(phase * math.pi * 2.2);
    c.drawOval(Rect.fromCenter(
      center: Offset(chimneyX + smokeOffset - 1, baseY - cottageH - 24),
      width: 8,
      height: 6,
    ), smokePaint);
    c.drawOval(Rect.fromCenter(
      center: Offset(chimneyX + smokeOffset * 1.5 - 3, baseY - cottageH - 30),
      width: 10,
      height: 7,
    ), smokePaint);
    c.drawOval(Rect.fromCenter(
      center: Offset(chimneyX + smokeOffset * 2.2 - 5, baseY - cottageH - 38),
      width: 11,
      height: 8,
    ), smokePaint);

    // Door
    _drawRect(c, cx - 7, baseY - 16, 13, 16, _cottageDoor);
    // Door knob
    c.drawCircle(Offset(cx + 4, baseY - 8), 1.5, Paint()..color = const Color(0xFFFFD54F));

    // Windows with warm glow
    final winW = 9.0;
    final winH = 8.0;
    _drawRect(c, cx - cottageW * .32, baseY - cottageH + 12, winW, winH, _windowGlow);
    _drawRect(c, cx + cottageW * .15, baseY - cottageH + 12, winW, winH, _windowGlow);
    // Window cross bars
    final winBar = Paint()..color = const Color(0xFFD4B896)..strokeWidth = 1;
    for (final wx in [cx - cottageW * .32, cx + cottageW * .15]) {
      c.drawLine(Offset(wx + winW / 2, baseY - cottageH + 12), Offset(wx + winW / 2, baseY - cottageH + 12 + winH), winBar);
      c.drawLine(Offset(wx, baseY - cottageH + 16), Offset(wx + winW, baseY - cottageH + 16), winBar);
    }

    // Flower box under window
    _drawRect(c, cx - cottageW * .32 - 2, baseY - cottageH + 21, 13, 4, const Color(0xFFA0522D));
    _drawRect(c, cx + cottageW * .15 - 2, baseY - cottageH + 21, 13, 4, const Color(0xFFA0522D));
    // Tiny flowers in box
    _drawPixelFlower(c, cx - cottageW * .32 + 3, baseY - cottageH + 20, const Color(0xFFFFB7C5));
    _drawPixelFlower(c, cx + cottageW * .15 + 3, baseY - cottageH + 20, const Color(0xFFCE93D8));
  }

  void _drawDetailedTree(Canvas c, double baseX, double baseY, double scale) {
    // Trunk with texture
    final trunkW = 8.0 * scale;
    final trunkH = 28.0 * scale;
    _drawRect(c, baseX - trunkW / 2, baseY - trunkH, trunkW, trunkH, _treeTrunk);

    // Trunk texture lines
    final trunkTex = Paint()..color = _treeTrunkDark..strokeWidth = 1;
    c.drawLine(Offset(baseX - 1, baseY - trunkH + 4), Offset(baseX - 1, baseY - 6), trunkTex);
    c.drawLine(Offset(baseX + 2, baseY - trunkH + 8), Offset(baseX + 2, baseY - 2), trunkTex);

    // Root flares
    final rootPaint = Paint()..color = _treeTrunk..style = PaintingStyle.fill;
    final rootPath = Path()
      ..moveTo(baseX - trunkW / 2, baseY)
      ..lineTo(baseX - trunkW * .8, baseY + 4)
      ..lineTo(baseX - trunkW / 4, baseY)
      ..close();
    c.drawPath(rootPath, rootPaint);
    final rootPath2 = Path()
      ..moveTo(baseX + trunkW / 2, baseY)
      ..lineTo(baseX + trunkW * .8, baseY + 4)
      ..lineTo(baseX + trunkW / 4, baseY)
      ..close();
    c.drawPath(rootPath2, rootPaint);

    // Leaf canopy - multiple overlapping circles
    final canopyCenter = baseY - trunkH - 4;
    _drawPixelCircle(c, baseX, canopyCenter - 6, 16, _leaf2);
    _drawPixelCircle(c, baseX - 10, canopyCenter, 12, _leaf1);
    _drawPixelCircle(c, baseX + 10, canopyCenter, 12, _leaf3);
    _drawPixelCircle(c, baseX - 6, canopyCenter - 10, 11, _leaf5);
    _drawPixelCircle(c, baseX + 7, canopyCenter - 8, 10, _leaf1);
    _drawPixelCircle(c, baseX, canopyCenter + 4, 12, _leaf4);
    _drawPixelCircle(c, baseX - 8, canopyCenter + 4, 10, _leaf1);
    _drawPixelCircle(c, baseX + 8, canopyCenter + 4, 10, _leaf2);
    _drawPixelCircle(c, baseX - 14, canopyCenter - 4, 9, _leaf5);
    _drawPixelCircle(c, baseX + 13, canopyCenter - 5, 9, _leaf3);

    // Leaf highlight dots
    final highlightPaint = Paint()..color = const Color(0x44FFFFFF);
    for (final offset in [Offset(-4, -14), Offset(2, -10), Offset(8, -6), Offset(-8, -2)]) {
      c.drawRect(
        Rect.fromLTWH(baseX + offset.dx, canopyCenter + offset.dy, 3, 3),
        highlightPaint,
      );
    }
  }

  void _drawGrassTufts(Canvas c, double w, double h) {
    final grassBase = h * .80;
    final rng = math.Random(42); // Fixed seed for determinism

    final shades = [_grass1, _grass2, _grass3, _grass4];
    for (var patch = 0; patch < 5; patch++) {
      final patchX = patch * w * .22 + 5;
      final patchW = w * .18;
      for (var x = patchX; x < patchX + patchW; x += rng.nextDouble() * 6 + 4) {
        final shade = shades[rng.nextInt(shades.length)];
        final paint = Paint()..color = shade..strokeWidth = 1.5;
        final tuftH = rng.nextDouble() * 8 + 3;
        final lean = rng.nextDouble() * 4 - 2;
        c.drawLine(Offset(x, grassBase), Offset(x + lean, grassBase - tuftH), paint);
        if (rng.nextDouble() > 0.5) {
          c.drawLine(Offset(x, grassBase), Offset(x + lean + 2, grassBase - tuftH * .7), paint);
        }
      }
    }
  }

  void _drawPicketFence(Canvas c, double w, double h) {
    final fenceBase = h * .76;
    final postPaint = Paint()..color = _fencePost..strokeWidth = 4..strokeCap = StrokeCap.round;
    final railPaint = Paint()..color = _fenceRail..strokeWidth = 2.5..strokeCap = StrokeCap.round;

    // Two rail lines
    final startX = w * .05;
    final endX = w * .54;
    c.drawLine(Offset(startX, fenceBase - 3), Offset(endX, fenceBase - 3), railPaint);
    c.drawLine(Offset(startX, fenceBase - 10), Offset(endX, fenceBase - 10), railPaint);

    // Picket posts with pointed tops
    for (var i = 0.0; i < endX - startX - 8; i += 12) {
      final fx = startX + i;
      // Post body
      c.drawLine(Offset(fx, fenceBase + 2), Offset(fx, fenceBase - 14), postPaint);
      // Pointed top
      final tipPaint = Paint()..color = _fencePost;
      final tip = Path()
        ..moveTo(fx - 2, fenceBase - 14)
        ..lineTo(fx, fenceBase - 18)
        ..lineTo(fx + 2, fenceBase - 14)
        ..close();
      c.drawPath(tip, tipPaint);
    }
  }

  void _drawPond(Canvas c, double cx, double cy, double rx, double ry) {
    // Water
    _drawPixelOval(c, cx, cy, rx, ry, _waterColor);

    // Shimmer
    final shimmerPaint = Paint()..color = _waterShimmer;
    c.drawOval(Rect.fromCenter(
      center: Offset(cx - 3, cy - 1),
      width: rx * 1.2,
      height: ry * .7,
    ), shimmerPaint);

    // Tiny ripples
    final ripplePaint = Paint()
      ..color = _waterShimmer
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    c.drawOval(Rect.fromCenter(center: Offset(cx + 4, cy), width: 8, height: 4), ripplePaint);
    c.drawOval(Rect.fromCenter(center: Offset(cx - 2, cy + 1), width: 5, height: 2.5), ripplePaint);
  }

  void _drawLeoShadow(Canvas c, double w, double h) {
    // Draw a subtle shadow where Leo walks on the path
    _drawPixelOval(c, 26, h * .86, 14, 3, const Color(0x18000000));
  }

  void _drawPixelFlower(Canvas c, double x, double y, Color petal) {
    final stem = Paint()..color = const Color(0xFF66BB6A)..strokeWidth = 2;
    c.drawLine(Offset(x, y + 6), Offset(x, y - 2), stem);
    c.drawRect(Rect.fromCenter(center: Offset(x, y - 6), width: 5, height: 5), Paint()..color = petal);
    c.drawRect(Rect.fromCenter(center: Offset(x + 4, y - 4), width: 5, height: 5), Paint()..color = petal);
    c.drawRect(Rect.fromCenter(center: Offset(x - 4, y - 4), width: 5, height: 5), Paint()..color = petal);
    c.drawRect(Rect.fromCenter(center: Offset(x, y - 2), width: 4, height: 4), Paint()..color = const Color(0xFFFFEB3B));
  }

  void _drawFlowerPatch(Canvas c, double x, double y, Color petal, int extras) {
    _drawPixelFlower(c, x, y, petal);
    if (extras > 0) {
      _drawPixelFlower(c, x + 12, y + 1, Color.lerp(petal, const Color(0xFFFFFFFF), 0.3)!);
      _drawPixelFlower(c, x + 24, y, petal);
    }
  }

  void _drawTulipFlower(Canvas c, double x, double y, Color petal) {
    final stem = Paint()..color = const Color(0xFF66BB6A)..strokeWidth = 2;
    c.drawLine(Offset(x, y + 6), Offset(x, y - 3), stem);

    // Tulip bell shape
    final tulipPaint = Paint()..color = petal;
    c.drawOval(Rect.fromCenter(center: Offset(x, y - 6), width: 7, height: 9), tulipPaint);
    // Lighter inner
    c.drawOval(Rect.fromCenter(center: Offset(x, y - 7), width: 4, height: 5),
        Paint()..color = Color.lerp(petal, const Color(0xFFFFFFFF), 0.4)!);
  }

  void _drawDaisyFlower(Canvas c, double x, double y, Color petal) {
    final stem = Paint()..color = const Color(0xFF66BB6A)..strokeWidth = 2;
    c.drawLine(Offset(x, y + 6), Offset(x, y - 1), stem);

    final daisyPaint = Paint()..color = petal;
    // Petals around center
    for (var angle = 0.0; angle < math.pi * 2; angle += math.pi / 4) {
      final px = x + math.cos(angle) * 4.5;
      final py = y - 5 + math.sin(angle) * 4.5;
      c.drawRect(Rect.fromCenter(center: Offset(px, py), width: 4, height: 4), daisyPaint);
    }
    // Center
    c.drawRect(Rect.fromCenter(center: Offset(x, y - 5), width: 4, height: 4),
        Paint()..color = const Color(0xFFFFD54F));
  }

  @override
  bool shouldRepaint(covariant _LoadingScenePainter old) => phase != old.phase;
}
