import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:quran_audio/core/themes/app_colors.dart';

/// Loading indicator in the app's night-sky language: a ring of stars whose
/// brightness sweeps around a crescent moon.
///
/// Holds a static frame when the platform asks for reduced motion — a
/// perpetual spinner is the worst offender for motion sensitivity.
class CelestialLoader extends StatefulWidget {
  final double size;

  const CelestialLoader({super.key, this.size = 34});

  @override
  State<CelestialLoader> createState() => _CelestialLoaderState();
}

class _CelestialLoaderState extends State<CelestialLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
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
    return Center(
      child: SizedBox.square(
        dimension: widget.size,
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) =>
                CustomPaint(painter: _CelestialPainter(_controller.value)),
          ),
        ),
      ),
    );
  }
}

class _CelestialPainter extends CustomPainter {
  static const _starCount = 8;

  final double progress;

  const _CelestialPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final extent = size.shortestSide;
    final center = size.center(Offset.zero);

    _paintCrescent(canvas, center, extent * 0.2);

    final orbit = extent * 0.41;
    final baseRadius = extent * 0.055;

    for (var i = 0; i < _starCount; i++) {
      final turn = i / _starCount;
      // how far this star sits behind the sweeping head, wrapped to 0..1
      final trail = (progress - turn) % 1.0;
      final intensity = math.pow(1 - trail, 2.4).toDouble();

      final angle = turn * 2 * math.pi - math.pi / 2;
      final position =
          center + Offset(math.cos(angle), math.sin(angle)) * orbit;

      canvas.drawCircle(
        position,
        baseRadius * (0.55 + 0.45 * intensity),
        Paint()
          ..color = AppColors.starlight.withValues(
            alpha: 0.18 + 0.82 * intensity,
          ),
      );
    }
  }

  void _paintCrescent(Canvas canvas, Offset center, double radius) {
    final disc = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    final bite = Path()
      ..addOval(
        Rect.fromCircle(
          center: center.translate(radius * 0.5, -radius * 0.14),
          radius: radius * 0.92,
        ),
      );

    canvas.drawPath(
      Path.combine(PathOperation.difference, disc, bite),
      Paint()..color = AppColors.primary,
    );
  }

  @override
  bool shouldRepaint(_CelestialPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
