import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/app_models.dart';

/// Leo's original eight illustrated frames plus expressive, composed poses.
/// The latter deliberately reuse the same owned sprite sheet so his colouring
/// and silhouette stay consistent everywhere in the app.
enum LeoPose {
  idle,
  walkA,
  walkB,
  sit,
  smile,
  meow,
  celebrate,
  butterfly,
  wave,
  read,
  nap,
  stretch,
  love,
  curious,
  highFive,
}

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
    final data = await rootBundle.load('assets/branding/leo-sprites.webp');
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
              ? _LeoPoseArt(
                  sheet: snapshot.data!,
                  pose: widget.pose,
                  size: widget.size,
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _LeoPoseArt extends StatelessWidget {
  const _LeoPoseArt({
    required this.sheet,
    required this.pose,
    required this.size,
  });

  final ui.Image sheet;
  final LeoPose pose;
  final double size;

  int get _frame => switch (pose) {
    LeoPose.idle || LeoPose.stretch => 0,
    LeoPose.walkA || LeoPose.wave || LeoPose.highFive => 1,
    LeoPose.walkB || LeoPose.curious => 2,
    LeoPose.sit || LeoPose.nap || LeoPose.read => 3,
    LeoPose.smile || LeoPose.love => 4,
    LeoPose.meow => 5,
    LeoPose.celebrate => 6,
    LeoPose.butterfly => 7,
  };

  String? get _badge => switch (pose) {
    LeoPose.wave => '✦',
    LeoPose.read => 'あ',
    LeoPose.nap => 'z',
    LeoPose.stretch => '↔',
    LeoPose.love => '♥',
    LeoPose.curious => '?',
    LeoPose.highFive => '✋',
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final transform = switch (pose) {
      LeoPose.stretch => Matrix4.diagonal3Values(1.11, .90, 1),
      LeoPose.nap => Matrix4.identity()..rotateZ(-.07),
      LeoPose.curious => Matrix4.identity()..rotateZ(.10),
      _ => Matrix4.identity(),
    };
    return Transform(
      alignment: Alignment.bottomCenter,
      transform: transform,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          CustomPaint(
            painter: _LeoSpritePainter(sheet, _frame),
            size: Size.square(size),
          ),
          if (pose == LeoPose.read)
            Positioned(
              bottom: size * .11,
              child: _LeoProp(label: 'あ い', colour: const Color(0xFFD94F45)),
            ),
          if (_badge case final badge?)
            Positioned(
              right: size * .03,
              top: size * .02,
              child: _LeoBadge(text: badge, pose: pose),
            ),
        ],
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
      Paint()..filterQuality = FilterQuality.high,
    );
  }

  @override
  bool shouldRepaint(covariant _LeoSpritePainter oldDelegate) =>
      frame != oldDelegate.frame || sheet != oldDelegate.sheet;
}

class _LeoBadge extends StatelessWidget {
  const _LeoBadge({required this.text, required this.pose});
  final String text;
  final LeoPose pose;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: pose == LeoPose.love
          ? const Color(0xFFFFE0E4)
          : Colors.white.withValues(alpha: .92),
      boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 5)],
    ),
    child: Padding(
      padding: const EdgeInsets.all(5),
      child: Text(
        text,
        style: TextStyle(
          color: pose == LeoPose.love
              ? const Color(0xFFD94F45)
              : const Color(0xFF2D3436),
          fontWeight: FontWeight.w900,
        ),
      ),
    ),
  );
}

class _LeoProp extends StatelessWidget {
  const _LeoProp({required this.label, required this.colour});
  final String label;
  final Color colour;

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: -.10,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: colour, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: colour,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    ),
  );
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
  bool _walkFrame = false;
  bool _caught = false;
  bool _finished = false;
  DifficultyTier? _selectedTier;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    );
    if (widget.reduceMotion) {
      _controller.value = 1;
    } else {
      _controller.repeat();
      _stepTimer = Timer.periodic(const Duration(milliseconds: 220), (_) {
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
    _stepTimer?.cancel();
    _controller.stop();
    setState(() => _caught = true);
    _finishIfReady();
  }

  void _finishIfReady() {
    if (!_caught || _selectedTier == null || _finished) return;
    _finished = true;
    widget.onFinished();
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
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _LoadingGarden(
                    controller: _controller,
                    caught: _caught,
                    walkFrame: _walkFrame,
                    reduceMotion: widget.reduceMotion,
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
                        : 'Leo is taking a gentle garden walk while we get ready...',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  _TierPicker(
                    selectedTier: _selectedTier,
                    onChanged: (tier) {
                      setState(() => _selectedTier = tier);
                      widget.onTierSelected?.call(tier);
                      _finishIfReady();
                    },
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

class _LoadingGarden extends StatelessWidget {
  const _LoadingGarden({
    required this.controller,
    required this.caught,
    required this.walkFrame,
    required this.reduceMotion,
  });
  final AnimationController controller;
  final bool caught;
  final bool walkFrame;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 16 / 9,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/branding/leo-loading-garden.webp',
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x0A000000), Color(0x26000000)],
              ),
            ),
          ),
          AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              final phase = controller.value;
              final returnWalk = phase > .5;
              final journey = returnWalk ? 2 - phase * 2 : phase * 2;
              final travel = caught
                  ? .78
                  : Curves.easeInOutCubic.transform(journey);
              final inspecting = !caught && phase > .38 && phase < .52;
              final leoSize = 86.0;
              return LayoutBuilder(
                builder: (context, bounds) {
                  // The painted stepping stones travel from the lower-left
                  // foreground toward the central clearing. Keep Leo on that
                  // route rather than sliding over the flower beds.
                  final left =
                      bounds.maxWidth * (.24 + .20 * travel) - leoSize / 2;
                  final bottom = bounds.maxHeight * (.02 + .27 * travel);
                  final walking = !caught && !inspecting;
                  final pose = caught
                      ? LeoPose.sit
                      : inspecting
                      ? LeoPose.curious
                      : (walkFrame ? LeoPose.walkA : LeoPose.walkB);
                  final bob = walking && !reduceMotion
                      ? (walkFrame ? 2.0 : 0.0)
                      : 0.0;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: left + leoSize * .19,
                        bottom: bottom - 1,
                        child: Container(
                          width: leoSize * .62,
                          height: 11,
                          decoration: BoxDecoration(
                            color: const Color(0x33000000),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x22000000),
                                blurRadius: 7,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: left,
                        bottom: bottom + bob,
                        child: Transform.flip(
                          flipX: returnWalk,
                          child: LeoSprite(
                            pose: pose,
                            size: leoSize,
                            semanticLabel: inspecting
                                ? 'Leo pauses to smell the garden flowers'
                                : caught
                                ? 'Leo is resting in the garden'
                                : 'Leo is walking through the garden',
                          ),
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
  );
}

class _TierPicker extends StatelessWidget {
  const _TierPicker({required this.selectedTier, required this.onChanged});
  final DifficultyTier? selectedTier;
  final ValueChanged<DifficultyTier> onChanged;

  @override
  Widget build(BuildContext context) => RadioGroup<DifficultyTier>(
    groupValue: selectedTier,
    onChanged: (value) {
      if (value != null) onChanged(value);
    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Choose your level',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        for (final tier in DifficultyTier.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Card(
              color: selectedTier == tier
                  ? const Color(0xFFD4EDDA)
                  : Colors.white,
              child: RadioListTile<DifficultyTier>(
                value: tier,
                title: Text(
                  tier.label,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(tier.description),
              ),
            ),
          ),
      ],
    ),
  );
}
