import 'package:flutter/material.dart';
import 'package:quran_audio/core/themes/app_colors.dart';
import 'package:quran_audio/core/widgets/night_scaffold.dart';
import 'package:quran_audio/core/widgets/reading_block.dart';
import 'package:quran_audio/core/widgets/surface_card.dart';
import 'package:quran_audio/features/hadith/domain/entities/hadith_entity.dart';
import 'package:quran_audio/core/locale/l10n.dart';
import 'package:quran_audio/core/widgets/translation_language_note.dart';

class HadithDetailPage extends StatelessWidget {
  final HadithEntity hadith;

  const HadithDetailPage({super.key, required this.hadith});

  @override
  Widget build(BuildContext context) {
    return NightScaffold(
      title: context.l10n.hadithNumbered(hadith.number),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            // only Arbain has titles
            hadith.title ?? context.l10n.hadithNumberedLong(hadith.number),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          if (hadith.source != null) ...[
            const SizedBox(height: 4),
            Text(
              hadith.source!,
              style: const TextStyle(color: AppColors.primary, fontSize: 13),
            ),
          ],
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
          const TranslationLanguageNote(padding: EdgeInsets.only(top: 10)),
        ],
      ),
    );
  }
}
