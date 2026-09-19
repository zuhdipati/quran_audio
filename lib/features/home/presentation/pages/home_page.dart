import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_audio/core/locale/l10n.dart';
import 'package:quran_audio/core/routes/route_paths.dart';
import 'package:quran_audio/core/themes/app_colors.dart';
import 'package:quran_audio/core/utils/date_time_utils.dart';
import 'package:quran_audio/core/utils/toast_utils.dart';
import 'package:quran_audio/core/widgets/night_scaffold.dart';
import 'package:quran_audio/core/widgets/state_views.dart';
import 'package:quran_audio/core/widgets/surface_card.dart';
import 'package:quran_audio/features/dua/presentation/bloc/daily_dua/daily_dua_bloc.dart';
import 'package:quran_audio/features/home/presentation/widgets/daily_dua_card.dart';
import 'package:quran_audio/features/home/presentation/widgets/feature_menu.dart';
import 'package:quran_audio/features/prayer_time/presentation/bloc/prayer_time/prayer_time_bloc.dart';
import 'package:quran_audio/features/prayer_time/presentation/prayer_l10n.dart';
import 'package:quran_audio/features/prayer_time/presentation/widgets/location_chip.dart';
import 'package:quran_audio/features/prayer_time/presentation/widgets/prayer_times_strip.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    final prayerBloc = context.read<PrayerTimeBloc>();
    if (prayerBloc.state.status == PrayerTimeStatus.initial) {
      prayerBloc.add(const PrayerTimesRequested());
    }
    final duaBloc = context.read<DailyDuaBloc>();
    if (duaBloc.state is DailyDuaInitial) {
      duaBloc.add(DailyDuaRequested(DateTime.now()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PrayerTimeBloc, PrayerTimeState>(
      listenWhen: (previous, current) =>
          current.message != null && previous.message != current.message,
      listener: (context, state) =>
          ToastUtils.showError(context.l10n.errorMessage(state.message!)),
      child: NightScaffold(
        showAppBar: false,
        body: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: () async {
            context.read<PrayerTimeBloc>().add(const PrayerTimesRequested());
            context.read<DailyDuaBloc>().add(DailyDuaRequested(DateTime.now()));
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            children: const [
              _Header(),
              SizedBox(height: 28),
              _PrayerOverview(),
              SizedBox(height: 28),
              FeatureMenu(),
              SizedBox(height: 32),
              DailyDuaSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  // the buckets line up with pagi / siang / sore / malam
  String _greeting(DateTime now, AppLocalizations l10n) {
    final hour = now.hour;
    if (hour < 4) return l10n.greetingNight;
    if (hour < 11) return l10n.greetingMorning;
    if (hour < 15) return l10n.greetingAfternoon;
    if (hour < 18) return l10n.greetingEvening;
    return l10n.greetingNight;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerTimeBloc, PrayerTimeState>(
      buildWhen: (p, c) => p.today != c.today,
      builder: (context, state) {
        final now = DateTime.now();
        final l10n = context.l10n;
        final hijri = state.today?.hijri;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Assalamu'alaikum",
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _greeting(now, l10n),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hijri == null
                        ? DateTimeUtils.fullDate(now)
                        : '${DateTimeUtils.fullDate(now)}\n'
                              '${l10n.hijriDate(hijri.day, hijri.month, hijri.year)}',
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: l10n.settingsTitle,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(
                    Icons.settings_outlined,
                    size: 22,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => context.push(RoutePaths.settings),
                ),
                const LocationChip(),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _PrayerOverview extends StatelessWidget {
  const _PrayerOverview();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerTimeBloc, PrayerTimeState>(
      builder: (context, state) {
        final today = state.today;
        if (today == null) {
          return SurfaceCard(
            child: SizedBox(
              height: 150,
              child: Center(
                child: state.status == PrayerTimeStatus.error
                    ? Text(
                        state.message == null
                            ? context.l10n.unableToLoadPrayerTimes
                            : context.l10n.errorMessage(state.message!),
                        style: const TextStyle(color: AppColors.textSecondary),
                      )
                    : const LoadingView(),
              ),
            ),
          );
        }

        final next = state.nextPrayer;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (next != null) _NextPrayer(next: next, now: state.now!),
            const SizedBox(height: 18),
            PrayerTimesStrip(schedule: today, highlighted: next?.prayer),
          ],
        );
      },
    );
  }
}

class _NextPrayer extends StatelessWidget {
  final UpcomingPrayer next;
  final DateTime now;

  const _NextPrayer({required this.next, required this.now});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.nextPrayer,
                style: const TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                next.prayer.localized(context.l10n),
                style: const TextStyle(
                  fontSize: 30,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              DateTimeUtils.time(next.time),
              style: const TextStyle(
                fontSize: 30,
                height: 1.1,
                fontWeight: FontWeight.w300,
                color: AppColors.primary,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              DateTimeUtils.countdown(next.time.difference(now), context.l10n),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
