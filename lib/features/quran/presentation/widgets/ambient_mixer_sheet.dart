import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_audio/core/themes/app_colors.dart';
import 'package:quran_audio/core/widgets/state_views.dart';
import 'package:quran_audio/features/quran/domain/entities/ambient_sound_entity.dart';
import 'package:quran_audio/features/quran/presentation/bloc/ambient/ambient_bloc.dart';
import 'package:quran_audio/features/quran/presentation/bloc/player/player_bloc.dart';
import 'package:quran_audio/features/quran/presentation/bloc/player/player_event.dart';
import 'package:quran_audio/features/quran/presentation/bloc/player/player_state.dart';
import 'package:quran_audio/features/quran/presentation/widgets/ambient_sound_icon.dart';

/// Pick nature sounds and balance their volume against the recitation.
class AmbientMixerSheet extends StatelessWidget {
  const AmbientMixerSheet({super.key});

  static Future<void> show(BuildContext context) {
    final ambientBloc = context.read<AmbientBloc>()
      ..add(AmbientSoundsRequested());
    final playerBloc = context.read<PlayerBloc>();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: ambientBloc),
          BlocProvider.value(value: playerBloc),
        ],
        child: const AmbientMixerSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.skyMiddle,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: BlocBuilder<AmbientBloc, AmbientState>(
          builder: (context, state) {
            if (state.status == AmbientStatus.initial) {
              return const SizedBox(height: 240, child: LoadingView());
            }
            if (state.status == AmbientStatus.error) {
              return SizedBox(
                height: 240,
                child: MessageView(message: state.message ?? 'Error'),
              );
            }

            return ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Sound mixer',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (state.activeIds.isNotEmpty)
                      TextButton(
                        onPressed: () =>
                            context.read<AmbientBloc>().add(AmbientStopped()),
                        child: const Text('Turn off all'),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Layer nature sounds under the recitation.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 18),
                GridView.count(
                  crossAxisCount: 5,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.72,
                  children: [
                    for (final sound in state.sounds)
                      AmbientSoundButton(
                        sound: sound,
                        isActive: state.isActive(sound.id),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: AppColors.border),
                const SizedBox(height: 8),
                BlocBuilder<PlayerBloc, PlayerState>(
                  buildWhen: (p, c) => p.volume != c.volume,
                  builder: (context, playerState) => _VolumeRow(
                    icon: Icons.menu_book_rounded,
                    label: 'Recitation',
                    value: playerState.volume,
                    onChanged: (value) =>
                        context.read<PlayerBloc>().add(SetQuranVolume(value)),
                  ),
                ),
                for (final sound in state.activeSounds)
                  _VolumeRow(
                    icon: ambientSoundIcon(sound.id),
                    label: sound.name,
                    value: state.volumeOf(sound.id),
                    onChanged: (value) => context.read<AmbientBloc>().add(
                      AmbientVolumeChanged(sound.id, value),
                    ),
                  ),
                if (state.activeSounds.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Select a sound above to adjust its level.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  'Recordings from Wikimedia Commons: '
                  '${state.sounds.map((s) => '${s.name} (${s.attribution})').join(', ')}.',
                  style: const TextStyle(
                    fontSize: 10,
                    height: 1.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class AmbientSoundButton extends StatelessWidget {
  final AmbientSoundEntity sound;
  final bool isActive;
  final double size;

  const AmbientSoundButton({
    super.key,
    required this.sound,
    required this.isActive,
    this.size = 52,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          context.read<AmbientBloc>().add(AmbientSoundToggled(sound.id)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? AppColors.primary : AppColors.surface,
              border: Border.all(
                color: isActive ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Icon(
              ambientSoundIcon(sound.id),
              size: size * 0.42,
              color: isActive ? AppColors.onPrimary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            sound.name,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              height: 1.2,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _VolumeRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const _VolumeRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          SizedBox(
            width: 96,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Expanded(
            child: Slider(value: value, onChanged: onChanged),
          ),
          SizedBox(
            width: 34,
            child: Text(
              '${(value * 100).round()}',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
