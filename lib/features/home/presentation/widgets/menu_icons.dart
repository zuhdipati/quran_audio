import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Prayer beads, drawn because Material has no tasbeeh glyph.
class TasbeehGlyph extends StatelessWidget {
  final Color color;
  final double size;

  const TasbeehGlyph({super.key, required this.color, this.size = 26});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _TasbeehPainter(color),
    );
  }
}

class _TasbeehPainter extends CustomPainter {
  final Color color;

  _TasbeehPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final center = Offset(size.width / 2, size.height * 0.4);
    final radius = size.width * 0.3;
    const beads = 11;
    for (var i = 0; i < beads; i++) {
      // leave a gap at the bottom for the tassel
      final angle = math.pi / 2 + 0.5 + i * (math.pi * 2 - 1.0) / (beads - 1);
      canvas.drawCircle(
        center + Offset(math.cos(angle), math.sin(angle)) * radius,
        size.width * 0.06,
        paint,
      );
    }
    final tasselTop = Offset(
      size.width / 2,
      center.dy + radius + size.width * 0.04,
    );
    canvas.drawCircle(tasselTop, size.width * 0.08, paint);
    final tassel = Path()
      ..moveTo(
        tasselTop.dx - size.width * 0.05,
        tasselTop.dy + size.width * 0.06,
      )
      ..lineTo(
        tasselTop.dx + size.width * 0.05,
        tasselTop.dy + size.width * 0.06,
      )
      ..lineTo(tasselTop.dx + size.width * 0.09, size.height)
      ..lineTo(tasselTop.dx - size.width * 0.09, size.height)
      ..close();
    canvas.drawPath(tassel, paint);
  }

  @override
  bool shouldRepaint(covariant _TasbeehPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Two open palms raised in supplication.
class DuaGlyph extends StatelessWidget {
  final Color color;
  final double size;

  const DuaGlyph({super.key, required this.color, this.size = 26});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _DuaPainter(color));
  }
}

class _DuaPainter extends CustomPainter {
  final Color color;

  _DuaPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..color = color;
    final clear = Paint()
      ..blendMode = BlendMode.clear
      ..strokeWidth = w * 0.035
      ..strokeCap = StrokeCap.round;

    canvas.saveLayer(Offset.zero & size, Paint());
    for (final side in [-1.0, 1.0]) {
      canvas.save();
      canvas.translate(w / 2 + side * w * 0.2, h * 0.55);
      // fingertips lean slightly towards each other
      canvas.rotate(-side * 0.16);

      final palmWidth = w * 0.26;
      final palmHeight = h * 0.66;
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromCenter(
            center: Offset.zero,
            width: palmWidth,
            height: palmHeight,
          ),
          topLeft: Radius.circular(palmWidth * 0.45),
          topRight: Radius.circular(palmWidth * 0.45),
          bottomLeft: Radius.circular(palmWidth * 0.3),
          bottomRight: Radius.circular(palmWidth * 0.3),
        ),
        paint,
      );

      // gaps between the fingers
      for (final dx in [-1.0, 0.0, 1.0]) {
        final x = dx * palmWidth * 0.24;
        canvas.drawLine(
          Offset(x, -palmHeight * 0.5 + h * 0.03),
          Offset(x, -palmHeight * 0.12),
          clear,
        );
      }

      // thumb on the outer edge
      canvas.save();
      canvas.translate(side * palmWidth * 0.55, h * 0.04);
      canvas.rotate(side * 0.5);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: w * 0.1,
            height: h * 0.26,
          ),
          Radius.circular(w * 0.05),
        ),
        paint,
      );
      canvas.restore();
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DuaPainter oldDelegate) =>
      oldDelegate.color != color;
}
