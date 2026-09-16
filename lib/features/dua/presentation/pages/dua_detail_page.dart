import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quran_audio/core/themes/app_colors.dart';
import 'package:quran_audio/core/utils/toast_utils.dart';
import 'package:quran_audio/core/widgets/night_scaffold.dart';
import 'package:quran_audio/core/widgets/reading_block.dart';
import 'package:quran_audio/core/widgets/surface_card.dart';
import 'package:quran_audio/features/dua/domain/entities/dua_entity.dart';

class DuaDetailPage extends StatelessWidget {
  final DuaEntity dua;

  const DuaDetailPage({super.key, required this.dua});

  @override
  Widget build(BuildContext context) {
    return NightScaffold(
      title: dua.group,
      actions: [
        IconButton(
          tooltip: 'Copy',
          icon: const Icon(Icons.copy_rounded, size: 20),
          onPressed: () async {
            await Clipboard.setData(
              ClipboardData(
                text:
                    '${dua.title}\n\n${dua.arabic}\n\n${dua.latin}\n\n${dua.translation}\n\n${dua.source}',
              ),
            );
            ToastUtils.showSuccess('Dua copied');
          },
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            dua.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 20),
          SurfaceCard(
            padding: const EdgeInsets.all(20),
            child: ReadingBlock(
              arabic: dua.arabic,
              latin: dua.latin,
              translation: dua.translation,
              note: dua.note,
              arabicSize: 28,
            ),
          ),
          if (dua.source.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              'Source',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              dua.source,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
