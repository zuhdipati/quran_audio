import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_audio/core/themes/app_colors.dart';
import 'package:quran_audio/core/themes/app_themes.dart';
import 'package:quran_audio/core/widgets/night_scaffold.dart';
import 'package:quran_audio/core/widgets/state_views.dart';
import 'package:quran_audio/features/tasbeeh/presentation/bloc/tasbeeh_bloc.dart';

class TasbeehPage extends StatefulWidget {
  const TasbeehPage({super.key});

  @override
  State<TasbeehPage> createState() => _TasbeehPageState();
}

class _TasbeehPageState extends State<TasbeehPage> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<TasbeehBloc>();
    if (bloc.state.status == TasbeehStatus.initial) bloc.add(TasbeehStarted());
  }

  void _count(TasbeehState state) {
    final target = state.current?.target ?? 33;
    final isRoundComplete = (state.count + 1) % target == 0;
    if (isRoundComplete) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.selectionClick();
    }
    context.read<TasbeehBloc>().add(TasbeehIncremented());
  }

  @override
  Widget build(BuildContext context) {
    return NightScaffold(
      title: 'Tasbeeh',
      actions: [
        BlocBuilder<TasbeehBloc, TasbeehState>(
          builder: (context, state) => IconButton(
            tooltip: 'Reset',
            icon: const Icon(Icons.restart_alt_rounded),
            onPressed: state.count == 0
                ? null
                : () => context.read<TasbeehBloc>().add(TasbeehReset()),
          ),
        ),
      ],
      body: BlocBuilder<TasbeehBloc, TasbeehState>(
        builder: (context, state) {
          if (state.status == TasbeehStatus.error) {
            return MessageView(message: state.message ?? 'Error');
          }
          final dzikir = state.current;
          if (state.status != TasbeehStatus.loaded || dzikir == null) {
            return const LoadingView();
          }

          return Column(
            children: [
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: state.dzikirList.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final item = state.dzikirList[index];
                    final isSelected = index == state.selectedIndex;
                    return ChoiceChip(
                      label: Text(item.latin),
                      selected: isSelected,
                      showCheckmark: false,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.onPrimary
                            : AppColors.textSecondary,
                      ),
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                      shape: const StadiumBorder(),
                      onSelected: (_) => context.read<TasbeehBloc>().add(
                        TasbeehDzikirSelected(index),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  child: Column(
                    children: [
                      Text(
                        dzikir.arabic,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: AppTheme.arabic(fontSize: 30, height: 1.8),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        dzikir.latin,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dzikir.translation,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 28),
                      _BeadCounter(state: state, onTap: () => _count(state)),
                      const SizedBox(height: 20),
                      Text(
                        state.completedRounds == 0
                            ? 'Tap the circle to count'
                            : '${state.completedRounds} × ${dzikir.target} completed',
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BeadCounter extends StatelessWidget {
  final TasbeehState state;
  final VoidCallback onTap;

  const _BeadCounter({required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final target = state.current!.target;
    final size = math.min(MediaQuery.sizeOf(context).width - 72, 300.0);

    return Semantics(
      button: true,
      label: 'Count, ${state.count}',
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox.square(
          dimension: size,
          child: CustomPaint(
            painter: _BeadRingPainter(
              total: target,
              filled: state.roundProgress,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${state.count}',
                    style: const TextStyle(
                      fontSize: 64,
                      height: 1,
                      fontWeight: FontWeight.w300,
                      letterSpacing: -2,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${state.roundProgress} / $target',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A string of prayer beads around the counter; counted beads glow gold.
class _BeadRingPainter extends CustomPainter {
  final int total;
  final int filled;

  _BeadRingPainter({required this.total, required this.filled});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 14;
    final beads = total > 60 ? 50 : total;
    final litBeads = total > 60 ? (filled * beads / total).round() : filled;

    canvas.drawCircle(
      center,
      radius - 26,
      Paint()..color = AppColors.surface.withValues(alpha: 0.7),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = AppColors.border,
    );

    final beadRadius = math.min(8.0, math.pi * radius / beads * 0.36);
    for (var i = 0; i < beads; i++) {
      final angle = -math.pi / 2 + 2 * math.pi * i / beads;
      final position =
          center + Offset(math.cos(angle), math.sin(angle)) * radius;
      final isLit = i < litBeads;
      if (isLit) {
        canvas.drawCircle(
          position,
          beadRadius * 1.8,
          Paint()
            ..color = AppColors.primary.withValues(alpha: 0.18)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
      }
      canvas.drawCircle(
        position,
        beadRadius,
        Paint()..color = isLit ? AppColors.primary : AppColors.surfaceHigh,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BeadRingPainter oldDelegate) =>
      oldDelegate.total != total || oldDelegate.filled != filled;
}
