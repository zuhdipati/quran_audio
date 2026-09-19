import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_audio/core/themes/app_colors.dart';
import 'package:quran_audio/core/widgets/night_scaffold.dart';
import 'package:quran_audio/core/widgets/state_views.dart';
import 'package:quran_audio/features/prayer_time/domain/entities/location_entity.dart';
import 'package:quran_audio/features/prayer_time/presentation/bloc/prayer_time/prayer_time_bloc.dart';
import 'package:quran_audio/features/prayer_time/presentation/widgets/location_chip.dart';
import 'package:quran_audio/features/qibla/presentation/bloc/qibla_bloc.dart';
import 'package:quran_audio/core/locale/l10n.dart';

class QiblaPage extends StatefulWidget {
  const QiblaPage({super.key});

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> {
  @override
  void initState() {
    super.initState();
    _start(context.read<PrayerTimeBloc>().state.location);
  }

  void _start(LocationEntity? location) {
    if (location == null) return;
    context.read<QiblaBloc>().add(QiblaStarted(location));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PrayerTimeBloc, PrayerTimeState>(
      listenWhen: (previous, current) => previous.location != current.location,
      listener: (context, state) => _start(state.location),
      child: NightScaffold(
        title: context.l10n.qiblaTitle,
        body: BlocBuilder<QiblaBloc, QiblaState>(
          builder: (context, state) {
            if (state.status == QiblaStatus.initial) return const LoadingView();

            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: Column(
                children: [
                  const LocationChip(),
                  const Spacer(),
                  _Compass(state: state),
                  const SizedBox(height: 36),
                  _Instruction(state: state),
                  const Spacer(),
                  Text(
                    context.l10n.qiblaFromTrueNorth(
                      state.qiblaDirection.toStringAsFixed(1),
                    ),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Instruction extends StatelessWidget {
  final QiblaState state;

  const _Instruction({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    String title;
    String subtitle;
    switch (state.status) {
      case QiblaStatus.noSensor:
        title = l10n.degreesFromNorth(state.qiblaDirection.round());
        subtitle = l10n.noCompassHint;
      case QiblaStatus.waiting:
      case QiblaStatus.initial:
        title = l10n.calibrating;
        subtitle = l10n.calibrateHint;
      case QiblaStatus.tracking:
        final angle = state.turnAngle;
        if (state.isFacingQibla) {
          title = l10n.facingQibla;
          subtitle = l10n.holdSteadyHint;
        } else {
          // whole sentences per direction: word order differs by language
          final degrees = angle.abs().round();
          title = angle > 0 ? l10n.turnRight(degrees) : l10n.turnLeft(degrees);
          subtitle = l10n.keepFlatHint;
        }
    }

    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: state.isFacingQibla
                ? AppColors.primary
                : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
        ),
      ],
    );
  }
}

class _Compass extends StatelessWidget {
  final QiblaState state;

  const _Compass({required this.state});

  @override
  Widget build(BuildContext context) {
    final heading = state.status == QiblaStatus.tracking ? state.heading : 0.0;
    final size = math.min(MediaQuery.sizeOf(context).width - 64, 320.0);

    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // the dial turns against the heading so N stays on true north
          Transform.rotate(
            angle: -heading * math.pi / 180,
            child: CustomPaint(
              size: Size.square(size),
              painter: _DialPainter(
                qiblaDirection: state.qiblaDirection,
                highlight: state.isFacingQibla,
              ),
            ),
          ),
          // fixed pointer showing where the phone faces
          Positioned(
            top: 0,
            child: CustomPaint(
              size: const Size(18, 14),
              painter: _PointerPainter(
                color: state.isFacingQibla
                    ? AppColors.primary
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PointerPainter extends CustomPainter {
  final Color color;

  _PointerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _PointerPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _DialPainter extends CustomPainter {
  final double qiblaDirection;
  final bool highlight;

  _DialPainter({required this.qiblaDirection, required this.highlight});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 20;

    canvas.drawCircle(
      center,
      radius,
      Paint()..color = AppColors.surface.withValues(alpha: 0.7),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = AppColors.border,
    );

    // ticks
    for (var degree = 0; degree < 360; degree += 5) {
      final isMajor = degree % 30 == 0;
      final angle = (degree - 90) * math.pi / 180;
      final outer = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      final inner =
          center +
          Offset(math.cos(angle), math.sin(angle)) *
              (radius - (isMajor ? 12 : 6));
      canvas.drawLine(
        inner,
        outer,
        Paint()
          ..strokeWidth = isMajor ? 1.6 : 1
          ..color = isMajor ? AppColors.textSecondary : AppColors.textMuted,
      );
    }

    // cardinal letters
    const cardinals = {'N': 0, 'E': 90, 'S': 180, 'W': 270};
    cardinals.forEach((label, degree) {
      final angle = (degree - 90) * math.pi / 180;
      final position =
          center + Offset(math.cos(angle), math.sin(angle)) * (radius - 30);
      final painter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: label == 'N' ? AppColors.error : AppColors.textPrimary,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        position - Offset(painter.width / 2, painter.height / 2),
      );
    });

    // qibla line and kaaba marker
    final qiblaAngle = (qiblaDirection - 90) * math.pi / 180;
    final direction = Offset(math.cos(qiblaAngle), math.sin(qiblaAngle));
    const accent = AppColors.primary;
    canvas.drawLine(
      center,
      center + direction * (radius - 46),
      Paint()
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..color = accent,
    );
    canvas.drawCircle(center, 5, Paint()..color = accent);

    final marker = center + direction * (radius + 2);
    canvas.drawCircle(
      marker,
      17,
      Paint()..color = highlight ? AppColors.primary : AppColors.surfaceHigh,
    );
    canvas.drawCircle(
      marker,
      17,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = AppColors.primary,
    );
    _drawKaaba(canvas, marker, highlight);
  }

  void _drawKaaba(Canvas canvas, Offset center, bool highlight) {
    final body = Rect.fromCenter(center: center, width: 16, height: 16);
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(2)),
      Paint()
        ..color = highlight ? AppColors.onPrimary : const Color(0XFF0B0B12),
    );
    canvas.drawRect(
      Rect.fromLTWH(body.left, body.top + 4, body.width, 2.5),
      Paint()..color = const Color(0XFFD9B66A),
    );
  }

  @override
  bool shouldRepaint(covariant _DialPainter oldDelegate) =>
      oldDelegate.qiblaDirection != qiblaDirection ||
      oldDelegate.highlight != highlight;
}
