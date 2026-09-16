import 'package:flutter/material.dart';
import 'package:quran_audio/core/themes/app_colors.dart';
import 'package:quran_audio/core/widgets/night_scaffold.dart';
import 'package:quran_audio/core/widgets/reading_block.dart';
import 'package:quran_audio/core/widgets/surface_card.dart';
import 'package:quran_audio/features/hadith/domain/entities/hadith_entity.dart';

class HadithDetailPage extends StatelessWidget {
  final HadithEntity hadith;

  const HadithDetailPage({super.key, required this.hadith});

  @override
  Widget build(BuildContext context) {
    return NightScaffold(
      title: 'Hadith ${hadith.number}',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            hadith.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Hadits Arbain An-Nawawi',
            style: TextStyle(color: AppColors.primary, fontSize: 13),
          ),
          const SizedBox(height: 20),
          SurfaceCard(
            padding: const EdgeInsets.all(20),
            child: ReadingBlock(arabic: hadith.arabic, arabicSize: 24),
          ),
          const SizedBox(height: 16),
          SurfaceCard(
            padding: const EdgeInsets.all(20),
            child: Text(
              hadith.translation,
              style: const TextStyle(
                fontSize: 15,
                height: 1.65,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
