import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_audio/core/themes/app_colors.dart';
import 'package:quran_audio/core/widgets/night_scaffold.dart';
import 'package:quran_audio/core/widgets/reading_block.dart';
import 'package:quran_audio/core/widgets/state_views.dart';
import 'package:quran_audio/core/widgets/surface_card.dart';
import 'package:quran_audio/features/salah/domain/entities/salah_guide_entity.dart';
import 'package:quran_audio/features/salah/presentation/bloc/salah_bloc.dart';

class SalahPage extends StatefulWidget {
  const SalahPage({super.key});

  @override
  State<SalahPage> createState() => _SalahPageState();
}

class _SalahPageState extends State<SalahPage> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<SalahBloc>();
    if (bloc.state is SalahInitial) bloc.add(SalahGuideRequested());
  }

  @override
  Widget build(BuildContext context) {
    return NightScaffold(
      title: 'Salah Guide',
      body: BlocBuilder<SalahBloc, SalahState>(
        builder: (context, state) {
          return switch (state) {
            SalahInitial() || SalahLoading() => const LoadingView(),
            SalahError(:final message) => MessageView(message: message),
            SalahLoaded(:final guide) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: _SegmentedTabs(
                    labels: const ['Readings', 'Niat'],
                    selected: _tab,
                    onChanged: (index) => setState(() => _tab = index),
                  ),
                ),
                Expanded(
                  child: _tab == 0
                      ? _StepsList(steps: guide.steps)
                      : _NiatList(niat: guide.niat),
                ),
              ],
            ),
          };
        },
      ),
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  const _SegmentedTabs({
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: i == selected
                        ? AppColors.surfaceHigh
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: i == selected
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StepsList extends StatelessWidget {
  final List<SalahStepEntity> steps;

  const _StepsList({required this.steps});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 32,
                child: Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primarySoft,
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 1,
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SurfaceCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                step.step,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (step.repeat > 1)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: AppColors.primarySoft,
                                ),
                                child: Text(
                                  '${step.repeat}×',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ReadingBlock(
                          arabic: step.arabic,
                          latin: step.latin,
                          translation: step.translation,
                          arabicSize: 23,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NiatList extends StatelessWidget {
  final List<NiatEntity> niat;

  const _NiatList({required this.niat});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      itemCount: niat.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = niat[index];
        return SurfaceCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '${item.rakaat} rakaat',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ReadingBlock(
                arabic: item.arabic,
                latin: item.latin,
                translation: item.translation,
                arabicSize: 23,
              ),
            ],
          ),
        );
      },
    );
  }
}
