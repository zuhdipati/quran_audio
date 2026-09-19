import 'package:flutter/material.dart';
import 'package:quran_audio/core/locale/l10n.dart';
import 'package:quran_audio/core/themes/app_colors.dart';

/// Marks Indonesian-only translations when the app is not in Indonesian.
///
/// Hadith, dua, dzikir and the salah guide have no English source, and
/// machine-translating religious text is not an option. Saying so plainly
/// makes the untranslated text read as a deliberate choice, not a bug.
/// Renders nothing in Indonesian, where the note would be noise.
class TranslationLanguageNote extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final MainAxisAlignment alignment;

  const TranslationLanguageNote({
    super.key,
    this.padding = EdgeInsets.zero,
    this.alignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (l10n.localeName == 'id') return const SizedBox.shrink();

    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: alignment,
        children: [
          const Icon(
            Icons.translate_rounded,
            size: 13,
            color: AppColors.textMuted,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              l10n.indonesianTranslationNote,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
