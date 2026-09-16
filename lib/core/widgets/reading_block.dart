import 'package:flutter/material.dart';
import 'package:quran_audio/core/themes/app_colors.dart';
import 'package:quran_audio/core/themes/app_themes.dart';

/// Arabic text with its transliteration and translation.
class ReadingBlock extends StatelessWidget {
  final String arabic;
  final String? latin;
  final String? translation;
  final String? note;
  final String? source;
  final double arabicSize;
  final int? translationMaxLines;

  const ReadingBlock({
    super.key,
    required this.arabic,
    this.latin,
    this.translation,
    this.note,
    this.source,
    this.arabicSize = 26,
    this.translationMaxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (note != null && note!.isNotEmpty) ...[
          Text(
            note!,
            style: const TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Text(
          arabic,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          style: AppTheme.arabic(fontSize: arabicSize),
        ),
        if (latin != null && latin!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            latin!,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              fontStyle: FontStyle.italic,
              color: AppColors.primary,
            ),
          ),
        ],
        if (translation != null && translation!.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            translation!,
            maxLines: translationMaxLines,
            overflow: translationMaxLines == null
                ? TextOverflow.visible
                : TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              height: 1.55,
              color: AppColors.textSecondary,
            ),
          ),
        ],
        if (source != null && source!.isNotEmpty) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.skyTop.withValues(alpha: 0.5),
            ),
            child: Text(
              source!,
              style: const TextStyle(
                fontSize: 12,
                height: 1.5,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
