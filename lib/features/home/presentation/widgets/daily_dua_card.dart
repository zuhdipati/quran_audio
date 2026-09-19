import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_audio/core/routes/route_paths.dart';
import 'package:quran_audio/core/themes/app_colors.dart';
import 'package:quran_audio/core/widgets/reading_block.dart';
import 'package:quran_audio/core/widgets/section_header.dart';
import 'package:quran_audio/core/widgets/surface_card.dart';
import 'package:quran_audio/features/dua/presentation/bloc/daily_dua/daily_dua_bloc.dart';
import 'package:quran_audio/core/locale/l10n.dart';

class DailyDuaSection extends StatelessWidget {
  const DailyDuaSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: context.l10n.dailyDua,
          actionLabel: context.l10n.seeAll,
          onAction: () => context.push(RoutePaths.dua),
        ),
        const SizedBox(height: 12),
        BlocBuilder<DailyDuaBloc, DailyDuaState>(
          builder: (context, state) {
            return switch (state) {
              DailyDuaLoaded(:final dua) => SurfaceCard(
                padding: const EdgeInsets.all(18),
                onTap: () => context.push(RoutePaths.duaDetail, extra: dua),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            dua.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ReadingBlock(
                      arabic: dua.arabic,
                      latin: dua.latin,
                      translation: dua.translation,
                      arabicSize: 24,
                      translationMaxLines: 4,
                    ),
                  ],
                ),
              ),
              DailyDuaError(:final message) => SurfaceCard(
                child: Text(
                  message,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
              _ => const SizedBox(height: 160),
            };
          },
        ),
      ],
    );
  }
}
