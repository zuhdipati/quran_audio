import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:quran_audio/core/themes/app_colors.dart';

class Star {
  final double x;
  final double y;
  final double radius;
  final double depth;
  final double baseAlpha;

  final int driftWidthsPerCycle;

  final int twinkleHarmonic;

  final double twinklePhase;

  const Star({
    required this.x,
    required this.y,
    required this.radius,
    required this.depth,
    required this.baseAlpha,
    required this.driftWidthsPerCycle,
    required this.twinkleHarmonic,
    required this.twinklePhase,
  });

  double alphaAt(double progress) {
    final wave = math.sin(
      2 * math.pi * (twinkleHarmonic * progress + twinklePhase),
    );
    return (baseAlpha * (0.8 + 0.2 * wave)).clamp(0.0, 1.0);
  }

  double xAt(double progress) => (x + driftWidthsPerCycle * progress) % 1.0;
}

class StarField {
  static const beaconCount = 6;

  final List<Star> stars;
  final List<Star> beacons;

  const StarField({required this.stars, required this.beacons});

  factory StarField.generate({required int count, required int seed}) {
    final random = math.Random(seed);

    Star make({required double y, required double depth, required double radius, required double alpha}) {
      return Star(
        x: random.nextDouble(),
        y: y,
        radius: radius,
        depth: depth,
        baseAlpha: alpha,
        // 1..3 widths per cycle, so nearer stars visibly outpace far ones
        driftWidthsPerCycle: 1 + (depth * 2).round(),
        twinkleHarmonic: 60 + random.nextInt(120),
        twinklePhase: random.nextDouble(),
      );
    }

    final stars = <Star>[];
    for (var i = 0; i < count; i++) {
      // bias stars towards the top of the sky
      final y = math.pow(random.nextDouble(), 1.6).toDouble();
      final depth = random.nextDouble();
      stars.add(
        make(
          y: y * 0.85,
          depth: depth,
          radius: 0.35 + depth * 0.9,
          alpha: (0.2 + random.nextDouble() * 0.7) * (1 - y),
        ),
      );
    }

    final beacons = [
      for (var i = 0; i < beaconCount; i++)
        make(
          y: random.nextDouble() * 0.4,
          depth: 1,
          radius: 1.3,
          alpha: 0.9,
        ),
    ];

    return StarField(stars: stars, beacons: beacons);
  }
}

/// Predawn sky: deep navy fading into a faint warm horizon, with a
/// deterministic star field that drifts slowly across it.
///
/// The gradient and horizon glow are painted in a separate, never-repainting
/// layer — only the stars are redrawn per frame.
class NightSkyBackground extends StatefulWidget {
  /// One full drift cycle. Far stars cross the screen once in this time,
  /// near stars three times.
  static const cycle = Duration(seconds: 420);

  final int starCount;
  final double horizonGlow;

  const NightSkyBackground({
    super.key,
    this.starCount = 150,
    this.horizonGlow = 0.16,
  });

  @override
  State<NightSkyBackground> createState() => _NightSkyBackgroundState();
}

class _NightSkyBackgroundState extends State<NightSkyBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: NightSkyBackground.cycle,
  );

  late final StarField _field = StarField.generate(
    count: widget.starCount,
    seed: 1447,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller
        ..stop()
        ..value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: _SkyPainter(glow: widget.horizonGlow),
            size: Size.infinite,
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => CustomPaint(
              painter: _StarPainter(field: _field, progress: _controller.value),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );
  }
}

/// Gradient and horizon glow. Never repaints — nothing about it moves.
class _SkyPainter extends CustomPainter {
  final double glow;

  const _SkyPainter({required this.glow});

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
  }

  @override
  bool shouldRepaint(_SkyPainter oldDelegate) => oldDelegate.glow != glow;
}

class _StarPainter extends CustomPainter {
  final StarField field;
  final double progress;

  const _StarPainter({required this.field, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (final star in field.stars) {
      paint.color = AppColors.starlight.withValues(alpha: star.alphaAt(progress));
      canvas.drawCircle(
        Offset(star.xAt(progress) * size.width, star.y * size.height),
        star.radius,
        paint,
      );
    }

    for (final beacon in field.beacons) {
      final centre = Offset(
        beacon.xAt(progress) * size.width,
        beacon.y * size.height,
      );
      final alpha = beacon.alphaAt(progress);

      canvas.drawCircle(
        centre,
        4,
        Paint()
          ..color = AppColors.starlight.withValues(alpha: alpha * 0.09)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      canvas.drawCircle(
        centre,
        beacon.radius,
        Paint()..color = AppColors.starlight.withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(_StarPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.field != field;
}
