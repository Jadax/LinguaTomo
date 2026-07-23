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
                      image: DecorationImage(
                        image: AssetImage(_loadingEnv.asset),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x33000000),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Vignette overlay (same as nest)
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
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
                        // Animated Leo + butterfly
                        AnimatedBuilder(
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
                                final leoSize = 110.0;
                                final groundY = bounds.maxHeight - leoSize - 18;
                                final leoLeft = _caught
                                    ? (bounds.maxWidth - leoSize - 44)
                                    : 8 + t * (bounds.maxWidth - leoSize - 44);
                                return Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    // Leo
                                    Positioned(
                                      left: leoLeft,
                                      top: _caught
                                          ? groundY - 6
                                          : chasing
                                              ? groundY -
                                                  24 +
                                                  8 *
                                                      math
                                                          .sin(
                                                            phase * math.pi * 4,
                                                          )
                                                          .abs()
                                              : groundY +
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
                                          ? bounds.maxWidth - 72
                                          : 52 + t * (bounds.maxWidth - 100),
                                      top: _caught
                                          ? groundY - 46
                                          : groundY -
                                              26 +
                                              14 *
                                                  math
                                                      .sin(
                                                        phase * math.pi * 2,
                                                      )
                                                      .abs(),
                                      child: const Text(
                                        '🦋',
                                        style: TextStyle(fontSize: 24),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
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

final _loadingEnv = NestEnvironment.springVeranda;
