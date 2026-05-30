import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:quran_audio/core/themes/app_colors.dart';
import 'package:quran_audio/features/quran/domain/entities/surah_entity.dart';
import 'package:quran_audio/features/quran/presentation/bloc/player/player_bloc.dart';
import 'package:quran_audio/features/quran/presentation/bloc/player/player_event.dart';
import 'package:quran_audio/features/quran/presentation/bloc/player/player_state.dart';

class AudioPlayerPage extends StatefulWidget {
  final SurahEntity surah;
  final String editionIdentifier;
  final List<SurahEntity> surahList;

  const AudioPlayerPage({
    super.key,
    required this.surah,
    required this.editionIdentifier,
    required this.surahList,
  });

  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () {
            context.read<PlayerBloc>().add(StopAudio());
            Navigator.of(context).pop();
          },
        ),
        title: BlocBuilder<PlayerBloc, PlayerState>(
          builder: (context, state) {
            final surahName = state.currentSurah?.englishName ?? 'Loading...';
            return Text(
              'Surah $surahName',
              style: const TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.menu_book_rounded,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            BlocBuilder<PlayerBloc, PlayerState>(
              builder: (context, state) {
                return ProgressBar(
                  progress: state.position,
                  total: state.duration,
                  progressBarColor: AppColors.primary,
                  baseBarColor: AppColors.lightGrey,
                  thumbColor: AppColors.primary,
                  timeLabelTextStyle: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  onSeek: (duration) {
                    context.read<PlayerBloc>().add(SeekAudio(duration));
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            BlocBuilder<PlayerBloc, PlayerState>(
              builder: (context, state) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.replay_10,
                        size: 32,
                        color: AppColors.textGrey,
                      ),
                      onPressed: () {
                        final newPos =
                            state.position - const Duration(seconds: 10);
                        context.read<PlayerBloc>().add(
                          SeekAudio(
                            newPos < Duration.zero ? Duration.zero : newPos,
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.skip_previous,
                        size: 40,
                        color: state.hasPreviousSurah
                            ? AppColors.textGrey
                            : AppColors.lightGrey,
                      ),
                      onPressed: state.hasPreviousSurah
                          ? () =>
                                context.read<PlayerBloc>().add(PreviousSurah())
                          : null,
                    ),
                    GestureDetector(
                      onTap: () {
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
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: _buildPlayPauseIcon(state.status),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.skip_next,
                        size: 40,
                        color: state.hasNextSurah
                            ? AppColors.textGrey
                            : AppColors.lightGrey,
                      ),
                      onPressed: state.hasNextSurah
                          ? () => context.read<PlayerBloc>().add(NextSurah())
                          : null,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.forward_10,
                        size: 32,
                        color: AppColors.textGrey,
                      ),
                      onPressed: () {
                        final newPos =
                            state.position + const Duration(seconds: 10);
                        context.read<PlayerBloc>().add(
                          SeekAudio(
                            newPos > state.duration ? state.duration : newPos,
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 30),
            BlocBuilder<PlayerBloc, PlayerState>(
              builder: (context, state) {
                final surah = state.currentSurah;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        surah?.englishName ?? 'Loading...',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        surah?.name ?? '',
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildPlayPauseIcon(PlayerStatus status) {
  if (status == PlayerStatus.loading) {
    return const SizedBox(
      width: 32,
      height: 32,
      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
    );
  } else if (status == PlayerStatus.playing) {
    return const Icon(Icons.pause, size: 32, color: Colors.white);
  } else {
    return const Icon(Icons.play_arrow, size: 32, color: Colors.white);
  }
}
