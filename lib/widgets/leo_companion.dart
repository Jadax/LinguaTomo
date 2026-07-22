import 'dart:math' as math;

import 'package:flutter/material.dart';

enum LeoMood { welcome, cheer, proud, thinking, gentle }

class LeoCompanion extends StatefulWidget {
  const LeoCompanion({
    super.key,
    this.mood = LeoMood.welcome,
    this.size = 116,
    this.message,
    this.reduceMotion = false,
  });

  final LeoMood mood;
  final double size;
  final String? message;
  final bool reduceMotion;

  @override
  State<LeoCompanion> createState() => _LeoCompanionState();
}

class _LeoCompanionState extends State<LeoCompanion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    if (!widget.reduceMotion) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant LeoCompanion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reduceMotion) {
      _controller.stop();
      _controller.value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _defaultMessage => switch (widget.mood) {
    LeoMood.welcome =>
      'Hello, friend. We can take this one cosy step at a time.',
    LeoMood.cheer => 'Lovely work! That answer is settling into your memory.',
    LeoMood.proud => 'Look how far you have come. I am proud of you.',
    LeoMood.thinking => 'No hurry. Try the sound, shape and meaning together.',
    LeoMood.gentle => 'Mistakes are safe here. Let us have another calm try.',
  };

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final lift = widget.reduceMotion
              ? 0.0
              : math.sin(_controller.value * math.pi) * -4;
          final tilt = widget.reduceMotion
              ? 0.0
              : math.sin(_controller.value * math.pi) * .015;
          return Transform.translate(
            offset: Offset(0, lift),
            child: Transform.rotate(angle: tilt, child: child),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.size * .28),
          child: Image.asset(
            'assets/branding/leo-cheer.png',
            width: widget.size,
            height: widget.size,
            fit: BoxFit.cover,
            semanticLabel: 'Leo, the Norwegian Forest Cat learning companion',
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Text(
              widget.message ?? _defaultMessage,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    ],
  );
}
