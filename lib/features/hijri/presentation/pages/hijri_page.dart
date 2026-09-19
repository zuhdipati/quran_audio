import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_audio/core/themes/app_colors.dart';
import 'package:quran_audio/core/themes/app_themes.dart';
import 'package:quran_audio/core/utils/date_time_utils.dart';
import 'package:quran_audio/core/widgets/night_scaffold.dart';
import 'package:quran_audio/core/widgets/section_header.dart';
import 'package:quran_audio/core/widgets/state_views.dart';
import 'package:quran_audio/core/widgets/surface_card.dart';
import 'package:quran_audio/features/hijri/domain/entities/hijri_month_entity.dart';
import 'package:quran_audio/features/hijri/domain/entities/islamic_event_entity.dart';
import 'package:quran_audio/features/hijri/presentation/bloc/hijri_bloc.dart';
import 'package:quran_audio/core/error/error_keys.dart';
import 'package:quran_audio/core/locale/l10n.dart';
import 'package:quran_audio/features/hijri/presentation/hijri_l10n.dart';

class HijriPage extends StatefulWidget {
  const HijriPage({super.key});

  @override
  State<HijriPage> createState() => _HijriPageState();
}

class _HijriPageState extends State<HijriPage> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<HijriBloc>();
    if (bloc.state.status == HijriStatus.initial) {
      bloc.add(HijriStarted(DateTime.now()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return NightScaffold(
      title: context.l10n.hijriCalendarTitle,
      body: BlocBuilder<HijriBloc, HijriState>(
        builder: (context, state) {
          if (state.status == HijriStatus.error) {
            return MessageView(
              message: context.l10n.errorMessage(
                state.message ?? ErrorKeys.unexpected,
              ),
            );
          }
          if (state.status != HijriStatus.loaded) return const LoadingView();

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              _TodayHero(state: state),
              const SizedBox(height: 24),
              _HijriMonthCard(state: state),
              const SizedBox(height: 24),
              SectionHeader(title: context.l10n.upcomingIslamicDays),
              const SizedBox(height: 12),
              for (final event in state.upcomingEvents)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _EventTile(event: event, today: state.todayGregorian!),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _TodayHero extends StatelessWidget {
  final HijriState state;

  const _TodayHero({required this.state});

  @override
  Widget build(BuildContext context) {
    final today = state.today!;
    return Column(
      children: [
        const SizedBox(height: 8),
        Text(
          today.monthNameArabic,
          style: AppTheme.arabic(fontSize: 30, color: AppColors.primary),
        ),
        Text(
          '${today.day}',
          style: const TextStyle(
            fontSize: 64,
            height: 1,
            fontWeight: FontWeight.w300,
            letterSpacing: -2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${context.l10n.hijriMonthName(today.month)} ${today.year} H',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          DateTimeUtils.fullDate(state.todayGregorian!),
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _HijriMonthCard extends StatelessWidget {
  final HijriState state;

  const _HijriMonthCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final month = state.month!;
    final today = state.today!;
    final leadingBlanks = month.days.first.gregorian.weekday - 1;
    final eventDays = month.events.map((e) => e.hijriDay).toSet();

    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: () =>
                    context.read<HijriBloc>().add(const HijriMonthChanged(-1)),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${context.l10n.hijriMonthName(month.month)} '
                      '${month.year} H',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _gregorianRange(month),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: () =>
                    context.read<HijriBloc>().add(const HijriMonthChanged(1)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: leadingBlanks + month.days.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.95,
            ),
            itemBuilder: (context, index) {
              if (index < leadingBlanks) return const SizedBox.shrink();
              final day = month.days[index - leadingBlanks];
              final isToday =
                  day.hijri.day == today.day &&
                  day.hijri.month == today.month &&
                  day.hijri.year == today.year;
              return _HijriDayCell(
                day: day,
                isToday: isToday,
                hasEvent: eventDays.contains(day.hijri.day),
              );
            },
          ),
          if (month.events.isNotEmpty) ...[
            const Divider(height: 20),
            for (final event in month.events)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 6, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(child: Text(event.localizedName(context.l10n))),
                    Text(
                      '${event.hijriDay} '
                      '${context.l10n.hijriMonthName(month.month)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  String _gregorianRange(HijriMonthEntity month) {
    final first = month.days.first.gregorian;
    final last = month.days.last.gregorian;
    return '${DateTimeUtils.shortDate(first)} – ${DateTimeUtils.shortDate(last)}';
  }
}

class _HijriDayCell extends StatelessWidget {
  final HijriDayEntity day;
  final bool isToday;
  final bool hasEvent;

  const _HijriDayCell({
    required this.day,
    required this.isToday,
    required this.hasEvent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isToday ? AppColors.primary : Colors.transparent,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${day.hijri.day}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isToday ? AppColors.onPrimary : AppColors.textPrimary,
            ),
          ),
          Text(
            '${day.gregorian.day}',
            style: TextStyle(
              fontSize: 10,
              color: isToday
                  ? AppColors.onPrimary.withValues(alpha: 0.7)
                  : AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: hasEvent
                  ? (isToday ? AppColors.onPrimary : AppColors.primary)
                  : Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  final IslamicEventEntity event;
  final DateTime today;

  const _EventTile({required this.event, required this.today});

  @override
  Widget build(BuildContext context) {
    final start = DateTime(today.year, today.month, today.day);
    final daysLeft = event.gregorian.difference(start).inDays;
    final l10n = context.l10n;
    final countdown = daysLeft == 0
        ? l10n.today
        : daysLeft == 1
        ? l10n.tomorrow
        : l10n.inDays(daysLeft);

    return SurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Column(
              children: [
                Text(
                  '${event.hijriDay}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  l10n.hijriMonthShort('m${event.hijriMonth}'),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.localizedName(l10n),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '${DateTimeUtils.fullDate(event.gregorian)} · '
                  '${event.localizedDescription(l10n)}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            countdown,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
