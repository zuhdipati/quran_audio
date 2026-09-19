import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:quran_audio/core/themes/app_colors.dart';
import 'package:quran_audio/core/themes/app_themes.dart';
import 'package:quran_audio/core/utils/haptics.dart';
import 'package:quran_audio/core/utils/arabic_number_utils.dart';
import 'package:quran_audio/features/quran/domain/entities/surah_entity.dart';
import 'package:quran_audio/core/locale/l10n.dart';

class SurahTile extends StatelessWidget {
  final SurahEntity surah;
  final VoidCallback onTap;

  const SurahTile({super.key, required this.surah, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Haptics.select();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 42,
              child: CustomPaint(
                painter: const _EightPointStarPainter(),
                child: Center(
                  child: Text(
                    ArabicNumberUtils.convert(surah.number),
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 15,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    surah.englishName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${surah.englishNameTranslation} · '
                    '${context.l10n.ayahCount(surah.numberOfAyahs)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              surah.name,
              textDirection: TextDirection.rtl,
              style: AppTheme.arabic(
                fontSize: 20,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rub el hizb outline used as the surah number badge.
class _EightPointStarPainter extends CustomPainter {
  const _EightPointStarPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final half = size.width * 0.34;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = AppColors.primary.withValues(alpha: 0.6);

    for (final rotation in [0.0, math.pi / 4]) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rotation);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: half * 2,
            height: half * 2,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
