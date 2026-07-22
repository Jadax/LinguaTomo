import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'leo_sprite.dart';

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
  Timer? _meowTimer;
  var _isMeowing = false;

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
    _meowTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _meow() {
    if (_isMeowing) return;
    setState(() => _isMeowing = true);
    _meowTimer = Timer(const Duration(milliseconds: 520), () {
      if (mounted) setState(() => _isMeowing = false);
    });
  }

  String get _defaultMessage => switch (widget.mood) {
    LeoMood.welcome =>
      'Hello, friend. We can take this one cosy step at a time.',
    LeoMood.cheer => 'Lovely work! That answer is settling into your memory.',
    LeoMood.proud => 'Look how far you have come. I am proud of you.',
    LeoMood.thinking => 'No hurry. Try the sound, shape and meaning together.',
    LeoMood.gentle => 'Mistakes are safe here. Let us have another calm try.',
  };

  LeoPose get _pose => _isMeowing
      ? LeoPose.meow
      : switch (widget.mood) {
          LeoMood.welcome => LeoPose.smile,
          LeoMood.cheer => LeoPose.celebrate,
          LeoMood.proud => LeoPose.sit,
          LeoMood.thinking => LeoPose.butterfly,
          LeoMood.gentle => LeoPose.smile,
        };

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final breathe = widget.reduceMotion
              ? 1.0
              : 1 + math.sin(_controller.value * math.pi) * .012;
          return Transform.scale(scale: breathe, child: child);
        },
        child: SizedBox(
          width: widget.size * 1.25,
          height: widget.size,
          child: InkWell(
            borderRadius: BorderRadius.circular(widget.size * .22),
            onTap: _meow,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                LeoSprite(pose: _pose, size: widget.size),
                if (_isMeowing)
                  const Positioned(right: -4, top: 0, child: _MeowBubble()),
              ],
            ),
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

class _MeowBubble extends StatelessWidget {
  const _MeowBubble();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: .08), blurRadius: 8),
      ],
    ),
    child: const Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Text('Mrrp!', style: TextStyle(fontWeight: FontWeight.w900)),
    ),
  );
}
