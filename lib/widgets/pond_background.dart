import 'package:flutter/material.dart';

/// Blue pond water with a few soft ripples, drawn behind every screen.
class PondBackground extends StatelessWidget {
  const PondBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF7FD3E8), Color(0xFF2E8FB8)],
        ),
      ),
      child: CustomPaint(painter: _RipplePainter(), child: child),
    );
  }
}

class _RipplePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withValues(alpha: 0.18);
    const spots = [
      Offset(0.15, 0.2),
      Offset(0.8, 0.35),
      Offset(0.3, 0.7),
      Offset(0.85, 0.85),
    ];
    for (final spot in spots) {
      final center = Offset(spot.dx * size.width, spot.dy * size.height);
      for (var r = 1; r <= 3; r++) {
        canvas.drawOval(
          Rect.fromCenter(center: center, width: r * 36.0, height: r * 16.0),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_RipplePainter oldDelegate) => false;
}
