import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:quran_audio/core/themes/app_colors.dart';

/// Predawn sky: deep navy fading into a faint warm horizon, with a
/// deterministic star field so the sky looks the same on every screen.
class NightSkyBackground extends StatelessWidget {
  final int starCount;
  final double horizonGlow;

  const NightSkyBackground({
    super.key,
    this.starCount = 150,
    this.horizonGlow = 0.16,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _NightSkyPainter(starCount: starCount, glow: horizonGlow),
        size: Size.infinite,
      ),
    );
  }
}

class _NightSkyPainter extends CustomPainter {
  final int starCount;
  final double glow;

  _NightSkyPainter({required this.starCount, required this.glow});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.skyTop,
            AppColors.skyMiddle,
            AppColors.skyLow,
            AppColors.horizon,
          ],
          stops: [0.0, 0.45, 0.8, 1.0],
        ).createShader(rect),
    );

    // warm light just below the horizon, the first sign of subuh
    final glowRect = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 1.08),
      width: size.width * 1.8,
      height: size.height * 0.7,
    );
    canvas.drawOval(
      glowRect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.dawnGlow.withValues(alpha: glow),
            AppColors.dawnGlow.withValues(alpha: 0),
          ],
        ).createShader(glowRect),
    );

    final random = math.Random(1447);
    final starPaint = Paint();
    for (var i = 0; i < starCount; i++) {
      // bias stars towards the top of the sky
      final dy = math.pow(random.nextDouble(), 1.6).toDouble();
      final position = Offset(
        random.nextDouble() * size.width,
        dy * size.height * 0.85,
      );
      final fade = 1 - dy;
      final radius = 0.35 + random.nextDouble() * 0.9;
      final alpha = (0.2 + random.nextDouble() * 0.7) * fade;
      starPaint.color = AppColors.starlight.withValues(alpha: alpha);
      canvas.drawCircle(position, radius, starPaint);
    }

    // a handful of brighter stars with a soft halo
    for (var i = 0; i < 6; i++) {
      final position = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height * 0.4,
      );
      canvas.drawCircle(
        position,
        4,
        Paint()
          ..color = AppColors.starlight.withValues(alpha: 0.08)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      canvas.drawCircle(
        position,
        1.3,
        Paint()..color = AppColors.starlight.withValues(alpha: 0.9),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NightSkyPainter oldDelegate) =>
      oldDelegate.starCount != starCount || oldDelegate.glow != glow;
}
