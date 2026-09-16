import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_audio/core/themes/app_colors.dart';
import 'package:quran_audio/core/utils/date_time_utils.dart';
import 'package:quran_audio/core/widgets/night_scaffold.dart';
import 'package:quran_audio/core/widgets/state_views.dart';
import 'package:quran_audio/core/widgets/surface_card.dart';
import 'package:quran_audio/features/prayer_time/domain/entities/location_entity.dart';
import 'package:quran_audio/features/prayer_time/domain/entities/prayer_schedule_entity.dart';
import 'package:quran_audio/features/prayer_time/presentation/bloc/calendar/calendar_bloc.dart';
import 'package:quran_audio/features/prayer_time/presentation/bloc/prayer_time/prayer_time_bloc.dart';
import 'package:quran_audio/features/prayer_time/presentation/widgets/location_chip.dart';
import 'package:quran_audio/features/prayer_time/presentation/widgets/prayer_scene.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  LocationEntity? _startedWith;

  @override
  void initState() {
    super.initState();
    _startIfReady(context.read<PrayerTimeBloc>().state.location);
  }

  void _startIfReady(LocationEntity? location) {
    if (location == null || location == _startedWith) return;
    final selected = context.read<CalendarBloc>().state.selectedDate;
    _startedWith = location;
    context.read<CalendarBloc>().add(
      CalendarStarted(
        location: location,
        initialDate: selected ?? DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PrayerTimeBloc, PrayerTimeState>(
      listenWhen: (previous, current) => previous.location != current.location,
      listener: (context, state) => _startIfReady(state.location),
      child: NightScaffold(
        title: 'Prayer Calendar',
        body: BlocBuilder<CalendarBloc, CalendarState>(
          builder: (context, state) {
            if (state.status == CalendarStatus.initial) {
              return const LoadingView();
            }
            if (state.status == CalendarStatus.error) {
              return MessageView(message: state.message ?? 'Error');
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: LocationChip(),
                ),
                const SizedBox(height: 16),
                _MonthHeader(state: state),
                const SizedBox(height: 12),
                _MonthGrid(state: state),
                const SizedBox(height: 20),
                if (state.selectedSchedule != null)
                  _DaySchedule(schedule: state.selectedSchedule!),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  final CalendarState state;

  const _MonthHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    final schedules = state.schedules;
    String hijriRange = '';
    if (schedules.isNotEmpty) {
      final first = schedules.first.hijri;
      final last = schedules.last.hijri;
      hijriRange = first.month == last.month
          ? '${first.monthName} ${first.year} H'
          : '${first.monthName} – ${last.monthName} ${last.year} H';
    }

    return Row(
      children: [
        _RoundIconButton(
          icon: Icons.chevron_left_rounded,
          onTap: () =>
              context.read<CalendarBloc>().add(const CalendarMonthChanged(-1)),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                DateTimeUtils.monthYear(state.month!),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                hijriRange,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        _RoundIconButton(
          icon: Icons.chevron_right_rounded,
          onTap: () =>
              context.read<CalendarBloc>().add(const CalendarMonthChanged(1)),
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface.withValues(alpha: 0.7),
      shape: const CircleBorder(side: BorderSide(color: AppColors.border)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  final CalendarState state;

  const _MonthGrid({required this.state});

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final month = state.month!;
    final leadingBlanks = DateTime(month.year, month.month).weekday - 1;
    final today = DateTime.now();

    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
      child: Column(
        children: [
          Row(
            children: [
              for (final day in _weekdays)
                Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: day == 'Fri'
                            ? AppColors.primary
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: leadingBlanks + state.schedules.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) {
              if (index < leadingBlanks) return const SizedBox.shrink();
              final schedule = state.schedules[index - leadingBlanks];
              return _DayCell(
                schedule: schedule,
                isSelected: schedule.date == state.selectedDate,
                isToday: DateTimeUtils.isSameDay(schedule.date, today),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final PrayerScheduleEntity schedule;
  final bool isSelected;
  final bool isToday;

  const _DayCell({
    required this.schedule,
    required this.isSelected,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = isSelected ? AppColors.onPrimary : AppColors.textPrimary;
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: isSelected ? AppColors.primary : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isToday && !isSelected
                ? AppColors.primary.withValues(alpha: 0.6)
                : Colors.transparent,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.read<CalendarBloc>().add(
            CalendarDaySelected(schedule.date),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${schedule.date.day}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: foreground,
                ),
              ),
              Text(
                '${schedule.hijri.day}',
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected
                      ? AppColors.onPrimary.withValues(alpha: 0.7)
                      : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DaySchedule extends StatelessWidget {
  final PrayerScheduleEntity schedule;

  const _DaySchedule({required this.schedule});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday = DateTimeUtils.isSameDay(schedule.date, now);
    PrayerName? upcoming;
    if (isToday) {
      for (final prayer in PrayerName.values) {
        if (schedule.timeOf(prayer).isAfter(now)) {
          upcoming = prayer;
          break;
        }
      }
    }

    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateTimeUtils.fullDate(schedule.date),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            schedule.hijri.formatted,
            style: const TextStyle(fontSize: 13, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          for (final prayer in PrayerName.values)
            _TimeRow(
              prayer: prayer,
              time: schedule.timeOf(prayer),
              isUpcoming: prayer == upcoming,
            ),
        ],
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  final PrayerName prayer;
  final DateTime time;
  final bool isUpcoming;

  const _TimeRow({
    required this.prayer,
    required this.time,
    required this.isUpcoming,
  });

  @override
  Widget build(BuildContext context) {
    final isMinor = prayer == PrayerName.imsak || prayer == PrayerName.sunrise;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isUpcoming ? AppColors.primarySoft : Colors.transparent,
      ),
      child: Row(
        children: [
          PrayerScene(prayer: prayer, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              prayer.label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isMinor ? FontWeight.w500 : FontWeight.w600,
                color: isMinor
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
              ),
            ),
          ),
          if (isUpcoming)
            const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Text(
                'Next',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          Text(
            DateTimeUtils.time(time),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: isUpcoming ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
