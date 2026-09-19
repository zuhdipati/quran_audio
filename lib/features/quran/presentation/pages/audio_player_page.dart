import 'dart:math' as math;

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_audio/core/themes/app_colors.dart';
import 'package:quran_audio/core/utils/haptics.dart';
import 'package:quran_audio/core/utils/toast_utils.dart';
import 'package:quran_audio/core/widgets/celestial_loader.dart';
import 'package:quran_audio/core/themes/app_themes.dart';
import 'package:quran_audio/core/widgets/night_scaffold.dart';
import 'package:quran_audio/features/quran/domain/entities/edition_entity.dart';
import 'package:quran_audio/features/quran/domain/entities/surah_entity.dart';
import 'package:quran_audio/features/quran/presentation/bloc/ambient/ambient_bloc.dart';
import 'package:quran_audio/features/quran/presentation/bloc/player/player_bloc.dart';
import 'package:quran_audio/features/quran/presentation/bloc/player/player_event.dart';
import 'package:quran_audio/features/quran/presentation/bloc/player/player_state.dart';
import 'package:quran_audio/features/quran/presentation/widgets/ambient_mixer_sheet.dart';
import 'package:quran_audio/features/quran/presentation/widgets/qori_avatar.dart';
import 'package:quran_audio/core/locale/l10n.dart';
import 'package:quran_audio/features/quran/presentation/ambient_l10n.dart';

class AudioPlayerPage extends StatefulWidget {
  final SurahEntity surah;
  final String editionIdentifier;
  final List<SurahEntity> surahList;
  final EditionEntity? edition;

  const AudioPlayerPage({
    super.key,
    required this.surah,
    required this.editionIdentifier,
    required this.surahList,
    this.edition,
  });

  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  late final AmbientBloc _ambientBloc;
  bool _stopped = false;

  @override
  void initState() {
    super.initState();
    context.read<PlayerBloc>().add(
      LoadSurah(
        widget.surah,
        editionIdentifier: widget.editionIdentifier,
        surahList: widget.surahList,
      ),
    );
    _ambientBloc = context.read<AmbientBloc>()..add(AmbientSoundsRequested());
  }

  void _stopEverything() {
    if (_stopped) return;
    _stopped = true;
    context.read<PlayerBloc>().add(StopAudio());
    _ambientBloc.add(AmbientStopped());
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _stopEverything();
      },
      child: NightScaffold(
        title: context.l10n.nowPlaying,
        onBack: () {
          _stopEverything();
          Navigator.of(context).pop();
        },
        body: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 640;
            return Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                0,
                24,
                16 + MediaQuery.paddingOf(context).bottom,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: BlocBuilder<PlayerBloc, PlayerState>(
                      buildWhen: (p, c) =>
                          p.currentSurah != c.currentSurah ||
                          p.position != c.position ||
                          p.duration != c.duration,
                      builder: (context, state) => _Artwork(
                        surah: state.currentSurah ?? widget.surah,
                        position: state.position,
                        duration: state.duration,
                      ),
                    ),
                  ),
                  SizedBox(height: compact ? 8 : 20),
                  _TrackInfo(fallback: widget.surah, edition: widget.edition),
                  SizedBox(height: compact ? 8 : 20),
                  const _ProgressSection(),
                  const _Controls(),
                  SizedBox(height: compact ? 8 : 16),
                  const _AmbienceStrip(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TrackInfo extends StatelessWidget {
  final SurahEntity fallback;
  final EditionEntity? edition;

  const _TrackInfo({required this.fallback, required this.edition});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      buildWhen: (p, c) => p.currentSurah != c.currentSurah,
      builder: (context, state) {
        final l10n = context.l10n;
        final surah = state.currentSurah;
        final title = surah == null
            ? l10n.loading
            : l10n.surahNamed(surah.englishName);
        final display = surah ?? fallback;
        return Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              '${display.englishNameTranslation} · '
              '${l10n.ayahCount(display.numberOfAyahs)} · '
              '${l10n.revelationType(display.revelationType)}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            if (edition != null) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  QoriAvatar(
                    name: edition!.englishName,
                    photoUrl: edition!.photoUrl,
                    size: 26,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      edition!.englishName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      buildWhen: (p, c) => p.position != c.position || p.duration != c.duration,
      builder: (context, state) {
        return ProgressBar(
          progress: state.position,
          total: state.duration,
          progressBarColor: AppColors.primary,
          baseBarColor: AppColors.border,
          bufferedBarColor: AppColors.border,
          thumbColor: AppColors.starlight,
          thumbGlowColor: AppColors.primarySoft,
          thumbRadius: 6,
          barHeight: 3,
          timeLabelPadding: 6,
          timeLabelTextStyle: const TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
          onSeek: (duration) {
            context.read<PlayerBloc>().add(SeekAudio(duration));
          },
        );
      },
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(
                Icons.replay_10,
                size: 28,
                color: AppColors.textSecondary,
              ),
              onPressed: () {
                Haptics.select();
                final newPos = state.position - const Duration(seconds: 10);
                context.read<PlayerBloc>().add(
                  SeekAudio(newPos < Duration.zero ? Duration.zero : newPos),
                );
              },
            ),
            IconButton(
              icon: Icon(
                Icons.skip_previous,
                size: 36,
                color: state.hasPreviousSurah
                    ? AppColors.textPrimary
                    : AppColors.textMuted.withValues(alpha: 0.5),
              ),
              onPressed: state.hasPreviousSurah
                  ? () {
                      Haptics.select();
                      context.read<PlayerBloc>().add(PreviousSurah());
                    }
                  : null,
            ),
            _PressableScale(
              onTap: () {
                Haptics.tap();
                if (state.status == PlayerStatus.playing) {
                  context.read<PlayerBloc>().add(PauseAudio());
                } else if (state.status == PlayerStatus.paused ||
                    state.status == PlayerStatus.completed) {
                  context.read<PlayerBloc>().add(ResumeAudio());
                } else if (state.status == PlayerStatus.initial) {
                  context.read<PlayerBloc>().add(PlayAudio());
                }
              },
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: Center(child: _buildPlayPauseIcon(state.status)),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.skip_next,
                size: 36,
                color: state.hasNextSurah
                    ? AppColors.textPrimary
                    : AppColors.textMuted.withValues(alpha: 0.5),
              ),
              onPressed: state.hasNextSurah
                  ? () {
                      Haptics.select();
                      context.read<PlayerBloc>().add(NextSurah());
                    }
                  : null,
            ),
            IconButton(
              icon: const Icon(
                Icons.forward_10,
                size: 28,
                color: AppColors.textSecondary,
              ),
              onPressed: () {
                Haptics.select();
                final newPos = state.position + const Duration(seconds: 10);
                context.read<PlayerBloc>().add(
                  SeekAudio(newPos > state.duration ? state.duration : newPos),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

Widget _buildPlayPauseIcon(PlayerStatus status) {
  if (status == PlayerStatus.loading) {
    return const CelestialLoader(
      size: 26,
      color: AppColors.onPrimary,
      starColor: AppColors.onPrimary,
    );
  } else if (status == PlayerStatus.playing) {
    return const Icon(Icons.pause, size: 34, color: AppColors.onPrimary);
  } else {
    return const Icon(Icons.play_arrow, size: 36, color: AppColors.onPrimary);
  }
}

class _AmbienceStrip extends StatelessWidget {
  const _AmbienceStrip();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AmbientBloc, AmbientState>(
      // a sound that could not start, e.g. its first download failed
      // offline; this page sits under the mixer sheet, so it covers both
      listenWhen: (previous, current) =>
          current.status == AmbientStatus.loaded &&
          current.message != null &&
          current.message != previous.message,
      listener: (context, state) =>
          ToastUtils.showError(context.l10n.errorMessage(state.message!)),
      builder: (context, state) {
        final active = state.activeSounds;
        return Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      active.isEmpty
                          ? context.l10n.natureSounds
                          : active
                                .map((s) => s.localizedName(context.l10n))
                                .join(' + '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => AmbientMixerSheet.show(context),
                    icon: const Icon(Icons.tune_rounded, size: 18),
                    label: Text(context.l10n.mixer),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 78,
                child: state.sounds.isEmpty
                    ? const SizedBox.shrink()
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.sounds.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final sound = state.sounds[index];
                          return SizedBox(
                            width: 58,
                            child: AmbientSoundButton(
                              sound: sound,
                              isActive: state.isActive(sound.id),
                              isLoading: state.isLoading(sound.id),
                              size: 40,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Night-sky disc: the ring of stars turns and the gold arc fills as the
/// recitation plays.
class _Artwork extends StatelessWidget {
  final SurahEntity surah;
  final Duration position;
  final Duration duration;

  const _Artwork({
    required this.surah,
    required this.position,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final progress = duration.inMilliseconds == 0
        ? 0.0
        : (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(
          math.min(constraints.maxWidth, constraints.maxHeight),
          320.0,
        );
        if (size < 80) return const SizedBox.shrink();
        return Center(
          child: SizedBox.square(
            dimension: size,
            child: CustomPaint(
              painter: _ArtworkPainter(
                progress: progress,
                rotation: position.inMilliseconds / 120000 * math.pi * 2,
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(size * 0.2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        child: Text(
                          surah.name,
                          textDirection: TextDirection.rtl,
                          style: AppTheme.arabic(
                            fontSize: size * 0.13,
                            height: 1.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        context.l10n.surahNumberLabel(surah.number),
                        style: TextStyle(
                          fontSize: math.max(9, size * 0.035),
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ArtworkPainter extends CustomPainter {
  final double progress;
  final double rotation;

  _ArtworkPainter({required this.progress, required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    // soft moonlight behind the disc
    canvas.drawCircle(
      center,
      radius * 0.78,
      Paint()
        ..color = AppColors.primary.withValues(alpha: 0.07)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.2),
    );

    final discRect = Rect.fromCircle(center: center, radius: radius * 0.7);
    canvas.drawCircle(
      center,
      radius * 0.7,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.4),
          colors: [AppColors.surfaceHigh, AppColors.skyTop],
        ).createShader(discRect),
    );
    canvas.drawCircle(
      center,
      radius * 0.7,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = AppColors.border,
    );
    canvas.drawCircle(
      center,
      radius * 0.6,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6
        ..color = AppColors.primary.withValues(alpha: 0.25),
    );

    // rotating ring of stars
    final random = math.Random(19);
    for (var i = 0; i < 36; i++) {
      final angle = rotation + i * math.pi * 2 / 36;
      final distance = radius * (0.8 + random.nextDouble() * 0.08);
      canvas.drawCircle(
        center + Offset(math.cos(angle), math.sin(angle)) * distance,
        0.6 + random.nextDouble() * 1.1,
        Paint()
          ..color = AppColors.starlight.withValues(
            alpha: 0.25 + random.nextDouble() * 0.6,
          ),
      );
    }

    // progress arc
    final arcRect = Rect.fromCircle(center: center, radius: radius * 0.96);
    canvas.drawCircle(
      center,
      radius * 0.96,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AppColors.border,
    );
    if (progress > 0) {
      canvas.drawArc(
        arcRect,
        -math.pi / 2,
        math.pi * 2 * progress,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round
          ..color = AppColors.primary,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ArtworkPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.rotation != rotation;
}

/// Dips its child while held. Used for the play button, which is the most
/// tapped control in the app and previously gave no feedback at all.
class _PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PressableScale({required this.child, required this.onTap});

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  bool _held = false;

  void _setHeld(bool value) {
    if (_held != value) setState(() => _held = value);
  }

  @override
  Widget build(BuildContext context) {
    final dipped = _held && !MediaQuery.disableAnimationsOf(context);

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _setHeld(true),
      onTapUp: (_) => _setHeld(false),
      onTapCancel: () => _setHeld(false),
      child: AnimatedScale(
        scale: dipped ? 0.92 : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
