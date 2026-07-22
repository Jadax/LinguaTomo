import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The kind of gentle weather drifting through Leo's Nest.
enum NestAmbienceKind { none, petals, rain, fireflies, fireworks, leaves, snow }

/// Chooses the ambience from the current month in Japan, so the Nest quietly
/// follows the real Japanese season and festival calendar.
NestAmbienceKind nestAmbienceFor(DateTime japanDate) => switch (japanDate
    .month) {
  3 || 4 || 5 => NestAmbienceKind.petals,
  6 => NestAmbienceKind.rain,
  7 || 8 => NestAmbienceKind.fireworks,
  9 => NestAmbienceKind.fireflies,
  10 || 11 => NestAmbienceKind.leaves,
  _ => NestAmbienceKind.snow,
};

/// A slow, minimal particle layer drawn above the Nest artwork. It never
/// blocks taps and disappears entirely when reduced motion is requested.
class NestAmbience extends StatefulWidget {
  const NestAmbience({
    super.key,
    required this.kind,
    required this.reduceMotion,
  });

  final NestAmbienceKind kind;
  final bool reduceMotion;

  @override
  State<NestAmbience> createState() => _NestAmbienceState();
}

class _NestAmbienceState extends State<NestAmbience>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
    if (!widget.reduceMotion && widget.kind != NestAmbienceKind.none) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant NestAmbience oldWidget) {
    super.didUpdateWidget(oldWidget);
    final active = !widget.reduceMotion && widget.kind != NestAmbienceKind.none;
    if (active && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!active && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reduceMotion || widget.kind == NestAmbienceKind.none) {
      return const SizedBox.shrink();
    }
    return ExcludeSemantics(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            painter: _AmbiencePainter(widget.kind, _controller.value),
          ),
        ),
      ),
    );
  }
}

class _AmbiencePainter extends CustomPainter {
  _AmbiencePainter(this.kind, this.phase);

  final NestAmbienceKind kind;

  /// 0..1 progress through a slow, seamless loop.
  final double phase;

  static const _petalColors = [
    Color(0xFFF7C8CE),
    Color(0xFFF5D8D5),
    Color(0xFFEFB7C0),
  ];
  static const _leafColors = [
    Color(0xFFD94F45),
    Color(0xFFE78A52),
    Color(0xFFC96A3B),
  ];
  static const _fireworkColors = [
    Color(0xFFFF6B6B),
    Color(0xFF4ECDC4),
    Color(0xFFFFC65C),
    Color(0xFFF5D8D5),
  ];

  double _fraction(double speed, int index, double spread) =>
      (phase * speed + index * spread) % 1.0;

  double _sway(int index, double amount) =>
      math.sin(phase * 2 * math.pi * 2 + index * 1.7) * amount;

  @override
  void paint(Canvas canvas, Size size) {
    switch (kind) {
      case NestAmbienceKind.petals:
        _paintFalling(
          canvas,
          size,
          count: 14,
          speed: .55,
          colors: _petalColors,
          radius: 4.5,
          sway: .05,
          oval: true,
        );
      case NestAmbienceKind.leaves:
        _paintFalling(
          canvas,
          size,
          count: 12,
          speed: .6,
          colors: _leafColors,
          radius: 5,
          sway: .07,
          oval: true,
        );
      case NestAmbienceKind.snow:
        _paintFalling(
          canvas,
          size,
          count: 26,
          speed: .5,
          colors: const [Color(0xFFFFFFFF)],
          radius: 2.6,
          sway: .03,
          alpha: .85,
        );
      case NestAmbienceKind.rain:
        _paintRain(canvas, size);
      case NestAmbienceKind.fireflies:
        _paintFireflies(canvas, size);
      case NestAmbienceKind.fireworks:
        _paintFireworks(canvas, size);
      case NestAmbienceKind.none:
        break;
    }
  }

  void _paintFalling(
    Canvas canvas,
    Size size, {
    required int count,
    required double speed,
    required List<Color> colors,
    required double radius,
    required double sway,
    bool oval = false,
    double alpha = .75,
  }) {
    for (var index = 0; index < count; index++) {
      final paint = Paint()
        ..color = colors[index % colors.length].withValues(alpha: alpha);
      final x =
          (((index * .618) % 1.0) + _sway(index, sway)) * size.width;
      final y = _fraction(speed, index, .37) * (size.height + 40) - 20;
      final tilt = phase * 2 * math.pi + index;
      if (oval) {
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(tilt);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset.zero,
            width: radius * 2,
            height: radius * 1.2,
          ),
          paint,
        );
        canvas.restore();
      } else {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  void _paintRain(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF9FB8C4).withValues(alpha: .5)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    for (var index = 0; index < 30; index++) {
      final x = ((index * .377) % 1.0) * size.width;
      final y = _fraction(1.6, index, .29) * (size.height + 30) - 15;
      canvas.drawLine(Offset(x, y), Offset(x - 3, y + 12), paint);
    }
  }

  void _paintFireflies(Canvas canvas, Size size) {
    for (var index = 0; index < 10; index++) {
      final pulse = (math.sin(phase * 2 * math.pi * 2 + index * 2.1) + 1) / 2;
      final paint = Paint()
        ..color = const Color(0xFFFFF3A6).withValues(alpha: .25 + pulse * .6);
      final x =
          (((index * .531) % 1.0) + _sway(index, .04)) * size.width;
      final y =
          (.35 + ((index * .29) % .55)) * size.height +
          math.sin(phase * 2 * math.pi + index) * 8;
      canvas.drawCircle(Offset(x, y), 2.4, paint);
    }
  }

  void _paintFireworks(Canvas canvas, Size size) {
    // Three gentle bursts per loop, each fading as it expands.
    for (var burst = 0; burst < 3; burst++) {
      final progress = (phase * 3 + burst / 3) % 1.0;
      if (progress > .6) continue;
      final centre = Offset(
        ((burst * .37 + .22) % 1.0) * size.width,
        size.height * (.18 + burst * .09),
      );
      final color = _fireworkColors[burst % _fireworkColors.length];
      final radius = 12 + progress * size.shortestSide * .35;
      final fade = (1 - progress / .6).clamp(0.0, 1.0);
      for (var spark = 0; spark < 16; spark++) {
        final angle = spark / 16 * 2 * math.pi + burst;
        final paint = Paint()
          ..color = color.withValues(alpha: .75 * fade);
        canvas.drawCircle(
          centre + Offset(math.cos(angle), math.sin(angle)) * radius,
          2.2,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AmbiencePainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.kind != kind;
}
