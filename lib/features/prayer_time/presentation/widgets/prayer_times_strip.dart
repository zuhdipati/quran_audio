import 'package:flutter/material.dart';
import 'package:quran_audio/core/themes/app_colors.dart';
import 'package:quran_audio/core/utils/date_time_utils.dart';
import 'package:quran_audio/features/prayer_time/domain/entities/prayer_schedule_entity.dart';
import 'package:quran_audio/features/prayer_time/presentation/widgets/prayer_scene.dart';
import 'package:quran_audio/core/locale/l10n.dart';
import 'package:quran_audio/features/prayer_time/presentation/prayer_l10n.dart';

/// Five daily prayers side by side, the upcoming one ringed in gold.
class PrayerTimesStrip extends StatelessWidget {
  final PrayerScheduleEntity schedule;
  final PrayerName? highlighted;

  const PrayerTimesStrip({super.key, required this.schedule, this.highlighted});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final prayer in PrayerNameX.obligatory)
          Expanded(
            child: _PrayerColumn(
              prayer: prayer,
              time: schedule.timeOf(prayer),
              isHighlighted: prayer == highlighted,
            ),
          ),
      ],
    );
  }
}

class _PrayerColumn extends StatelessWidget {
  final PrayerName prayer;
  final DateTime time;
  final bool isHighlighted;

  const _PrayerColumn({
    required this.prayer,
    required this.time,
    required this.isHighlighted,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sceneSize = (constraints.maxWidth - 10).clamp(40.0, 62.0);
        return Column(
          children: [
            Text(
              prayer.localized(context.l10n),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isHighlighted
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isHighlighted ? AppColors.primary : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: PrayerScene(prayer: prayer, size: sceneSize),
            ),
            const SizedBox(height: 8),
            Text(
              DateTimeUtils.time(time),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
                color: isHighlighted
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        );
      },
    );
  }
}
