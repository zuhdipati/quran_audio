import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_audio/core/themes/app_colors.dart';
import 'package:quran_audio/core/widgets/celestial_loader.dart';
import 'package:quran_audio/features/prayer_time/presentation/bloc/prayer_time/prayer_time_bloc.dart';

/// Shows the city used for prayer times; tap to use the device location.
class LocationChip extends StatelessWidget {
  const LocationChip({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerTimeBloc, PrayerTimeState>(
      builder: (context, state) {
        final location = state.location;
        final isLoading = state.status == PrayerTimeStatus.loading;
        final label = location == null
            ? 'Locating…'
            : location.isFallback
            ? '${location.city} · set location'
            : location.city;

        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: isLoading
              ? null
              : () => context.read<PrayerTimeBloc>().add(
                  const PrayerTimesRequested(refreshLocation: true),
                ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
              color: AppColors.surface.withValues(alpha: 0.6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                isLoading
                    ? const CelestialLoader(size: 16)
                    : const Icon(
                        Icons.place_outlined,
                        size: 14,
                        color: AppColors.primary,
                      ),
                const SizedBox(width: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 160),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
