import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:quran_audio/features/prayer_time/domain/entities/prayer_schedule_entity.dart';

/// Small circular landscape showing the sky at each prayer time.
class PrayerScene extends StatelessWidget {
  final PrayerName prayer;
  final double size;

  const PrayerScene({super.key, required this.prayer, this.size = 60});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: ClipOval(
        child: CustomPaint(painter: _PrayerScenePainter(_palettes[prayer]!)),
      ),
    );
  }
}

class _ScenePalette {
  final List<Color> sky;
  final Color body;
  final Offset bodyPosition; // relative 0..1
  final double bodyRadius;
  final bool isMoon;
  final bool stars;
  final Color farHill;
  final Color nearHill;

  const _ScenePalette({
    required this.sky,
    required this.body,
    required this.bodyPosition,
    required this.bodyRadius,
    required this.farHill,
    required this.nearHill,
    this.isMoon = false,
    this.stars = false,
  });
}

const _palettes = <PrayerName, _ScenePalette>{
  PrayerName.fajr: _ScenePalette(
    sky: [Color(0XFF1E2150), Color(0XFF5D4A80), Color(0XFFE8A07E)],
    body: Color(0XFFF3D2B3),
    bodyPosition: Offset(0.5, 0.78),
    bodyRadius: 0.16,
    farHill: Color(0XFF4A3B69),
    nearHill: Color(0XFF2A2346),
    stars: true,
  ),
  PrayerName.sunrise: _ScenePalette(
    sky: [Color(0XFF4A6FA8), Color(0XFFE7B08A), Color(0XFFF6D39B)],
    body: Color(0XFFFFE3A6),
    bodyPosition: Offset(0.5, 0.66),
    bodyRadius: 0.14,
    farHill: Color(0XFF7A6A8E),
    nearHill: Color(0XFF3F3A5E),
  ),
  PrayerName.dhuhr: _ScenePalette(
    sky: [Color(0XFF2D66AD), Color(0XFF6FA7DA), Color(0XFFBCDDF2)],
    body: Color(0XFFFFF6DA),
    bodyPosition: Offset(0.5, 0.3),
    bodyRadius: 0.15,
    farHill: Color(0XFF5B8DB5),
    nearHill: Color(0XFF2F5D83),
  ),
  PrayerName.asr: _ScenePalette(
    sky: [Color(0XFF4E78AE), Color(0XFFC9A57E), Color(0XFFF0C07A)],
    body: Color(0XFFFFE0A0),
    bodyPosition: Offset(0.3, 0.46),
    bodyRadius: 0.13,
    farHill: Color(0XFF8A6A5A),
    nearHill: Color(0XFF4B3A3E),
  ),
  PrayerName.maghrib: _ScenePalette(
    sky: [Color(0XFF3A2A5E), Color(0XFFB9566C), Color(0XFFF3A35C)],
    body: Color(0XFFFFD08A),
    bodyPosition: Offset(0.5, 0.72),
    bodyRadius: 0.17,
    farHill: Color(0XFF6B3452),
    nearHill: Color(0XFF2E1B38),
  ),
  PrayerName.isha: _ScenePalette(
    sky: [Color(0XFF050817), Color(0XFF0E1636), Color(0XFF1C2654)],
    body: Color(0XFFEDE6CF),
    bodyPosition: Offset(0.66, 0.3),
    bodyRadius: 0.12,
    farHill: Color(0XFF1B2450),
    nearHill: Color(0XFF0B1030),
    isMoon: true,
    stars: true,
  ),
  PrayerName.imsak: _ScenePalette(
    sky: [Color(0XFF070B1F), Color(0XFF1A1F4A), Color(0XFF3A3264)],
    body: Color(0XFFEDE6CF),
    bodyPosition: Offset(0.7, 0.28),
    bodyRadius: 0.1,
    farHill: Color(0XFF252552),
    nearHill: Color(0XFF10132F),
    isMoon: true,
    stars: true,
  ),
};

class _PrayerScenePainter extends CustomPainter {
  final _ScenePalette palette;

  _PrayerScenePainter(this.palette);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final w = size.width;
    final h = size.height;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: palette.sky,
        ).createShader(rect),
    );

    if (palette.stars) {
      final random = math.Random(palette.sky.first.toARGB32());
      final starPaint = Paint();
      for (var i = 0; i < 14; i++) {
        starPaint.color = Colors.white.withValues(
          alpha: 0.35 + random.nextDouble() * 0.5,
        );
        canvas.drawCircle(
          Offset(random.nextDouble() * w, random.nextDouble() * h * 0.5),
          0.4 + random.nextDouble() * 0.6,
          starPaint,
        );
      }
    }

    final center = Offset(
      palette.bodyPosition.dx * w,
      palette.bodyPosition.dy * h,
    );
    final radius = palette.bodyRadius * w;

    canvas.drawCircle(
      center,
      radius * 2.4,
      Paint()
        ..color = palette.body.withValues(alpha: 0.18)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius),
    );

    if (palette.isMoon) {
      canvas.saveLayer(rect, Paint());
      canvas.drawCircle(center, radius, Paint()..color = palette.body);
      canvas.drawCircle(
        center.translate(radius * 0.45, -radius * 0.25),
        radius * 0.85,
        Paint()..blendMode = BlendMode.clear,
      );
      canvas.restore();
    } else {
      canvas.drawCircle(center, radius, Paint()..color = palette.body);
    }

    canvas.drawPath(
      _hill(size, base: 0.68, amplitude: 0.07, phase: 0.8, frequency: 1.4),
      Paint()..color = palette.farHill,
    );
    canvas.drawPath(
      _hill(size, base: 0.8, amplitude: 0.06, phase: 2.6, frequency: 1.1),
      Paint()..color = palette.nearHill,
    );
  }

  Path _hill(
    Size size, {
    required double base,
    required double amplitude,
    required double phase,
    required double frequency,
  }) {
    final path = Path()..moveTo(0, size.height);
    const steps = 24;
    for (var i = 0; i <= steps; i++) {
      final x = size.width * i / steps;
      final y =
          size.height *
          (base +
              amplitude *
                  math.sin(phase + frequency * math.pi * 2 * i / steps));
      path.lineTo(x, y);
    }
    path
      ..lineTo(size.width, size.height)
      ..close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _PrayerScenePainter oldDelegate) =>
      oldDelegate.palette != palette;
}
