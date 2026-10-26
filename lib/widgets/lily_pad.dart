import 'dart:math';

import 'package:flutter/material.dart';

/// A round green lily pad with the classic notch, drawn with code so the
/// app needs no image files.
class LilyPadPainter extends CustomPainter {
  const LilyPadPainter({this.dimmed = false, this.glow = false});

  final bool dimmed;
  final bool glow;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    if (glow) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = const Color(0xFFFFF59D)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
      );
    }

    // Leave a wedge-shaped notch pointing down-right.
    const notch = 0.5;
    const start = pi / 4 + notch / 2;
    final pad = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(rect, start, 2 * pi - notch, false)
      ..close();

    canvas.drawPath(
      pad.shift(const Offset(0, 4)),
      Paint()..color = Colors.black.withValues(alpha: 0.15),
    );
    final base = dimmed ? const Color(0xFF9DBF9F) : const Color(0xFF4CAF50);
    final light = dimmed ? const Color(0xFFC5DCC6) : const Color(0xFF8BD48E);
    canvas.drawPath(
      pad,
      Paint()
        ..shader = RadialGradient(colors: [light, base]).createShader(rect),
    );

    final vein = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..strokeWidth = 2;
    for (var i = 1; i < 8; i++) {
      final angle = start + i * (2 * pi - notch) / 8;
      canvas.drawLine(
        center,
        center + Offset(cos(angle), sin(angle)) * radius * 0.85,
        vein,
      );
    }
  }

  @override
  bool shouldRepaint(LilyPadPainter oldDelegate) =>
      dimmed != oldDelegate.dimmed || glow != oldDelegate.glow;
}

/// A tappable lily pad showing a picture, which shakes when [shakeCount]
/// increases and shows a jumping frog when [hasFrog] is true.
class LilyPadTile extends StatefulWidget {
  const LilyPadTile({
    super.key,
    required this.size,
    required this.picture,
    required this.onTap,
    this.label,
    this.dimmed = false,
    this.hasFrog = false,
    this.shakeCount = 0,
  });

  final double size;
  final String picture;
  final String? label;
  final VoidCallback onTap;
  final bool dimmed;
  final bool hasFrog;
  final int shakeCount;

  @override
  State<LilyPadTile> createState() => _LilyPadTileState();
}

class _LilyPadTileState extends State<LilyPadTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  @override
  void didUpdateWidget(LilyPadTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shakeCount > oldWidget.shakeCount) _shake.forward(from: 0);
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    return AnimatedBuilder(
      animation: _shake,
      builder: (context, child) => Transform.translate(
        offset: Offset(sin(_shake.value * pi * 6) * 10 * (1 - _shake.value), 0),
        child: child,
      ),
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox.square(
          dimension: size,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size.square(size),
                painter: LilyPadPainter(
                  dimmed: widget.dimmed,
                  glow: widget.hasFrog,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.picture,
                    style: TextStyle(
                      fontSize: size * 0.34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: const [Shadow(blurRadius: 4)],
                    ),
                  ),
                  if (widget.label != null) _Label(widget.label!, size),
                ],
              ),
              Positioned(
                top: -size * 0.2,
                child: AnimatedScale(
                  scale: widget.hasFrog ? 1 : 0,
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.elasticOut,
                  child: Text('🐸', style: TextStyle(fontSize: size * 0.45)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text, this.padSize);

  final String text;
  final double padSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: max(12, padSize * 0.12),
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1B5E20),
        ),
      ),
    );
  }
}
