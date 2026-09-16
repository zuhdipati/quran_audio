import 'package:flutter/material.dart';
import 'package:quran_audio/core/themes/app_colors.dart';
import 'package:quran_audio/core/themes/app_themes.dart';
import 'package:quran_audio/core/widgets/surface_card.dart';
import 'package:quran_audio/features/dua/domain/entities/dua_entity.dart';

class DuaTile extends StatelessWidget {
  final DuaEntity dua;
  final VoidCallback onTap;

  const DuaTile({super.key, required this.dua, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            dua.group.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dua.title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Text(
            dua.arabic,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: AppTheme.arabic(
              fontSize: 20,
              height: 1.7,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
