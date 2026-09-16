import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:quran_audio/core/routes/route_paths.dart';
import 'package:quran_audio/core/themes/app_colors.dart';
import 'package:quran_audio/core/utils/toast_utils.dart';
import 'package:quran_audio/core/widgets/night_scaffold.dart';
import 'package:quran_audio/core/widgets/search_field.dart';
import 'package:quran_audio/core/widgets/state_views.dart';
import 'package:quran_audio/core/widgets/surface_card.dart';
import 'package:quran_audio/features/quran/domain/entities/edition_entity.dart';
import 'package:quran_audio/features/quran/presentation/bloc/edition/edition_bloc.dart';
import 'package:quran_audio/features/quran/presentation/bloc/surah_list/surah_list_bloc.dart';
import 'package:quran_audio/features/quran/presentation/widgets/edition_bottom_sheet.dart';
import 'package:quran_audio/features/quran/presentation/widgets/qori_avatar.dart';
import 'package:quran_audio/features/quran/presentation/widgets/surah_tile.dart';

class SurahPage extends StatelessWidget {
  const SurahPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SurahPageView();
  }
}

class SurahPageView extends StatefulWidget {
  const SurahPageView({super.key});

  @override
  State<SurahPageView> createState() => _SurahPageViewState();
}

class _SurahPageViewState extends State<SurahPageView> {
  static const _defaultEdition = EditionEntity(
    identifier: 'ar.alafasy',
    language: 'ar',
    name: 'مشاري العفاسي',
    englishName: 'Mishary Rashid Alafasy',
  );

  @override
  void initState() {
    super.initState();
    final editionBloc = context.read<EditionBloc>();
    if (editionBloc.state is! EditionLoaded) editionBloc.add(GetEditions());

    final surahBloc = context.read<SurahListBloc>();
    if (surahBloc.state is SurahListInitial ||
        surahBloc.state is SurahListError) {
      surahBloc.add(const FetchSurahs(_defaultEdition));
    }
  }

  EditionEntity? _currentEdition(SurahListState state) {
    if (state is SurahListLoaded) return state.currentEdition;
    if (state is SurahListLoading) return state.currentEdition;
    return null;
  }

  // prefers the fully loaded edition (with photo) over the stored one
  EditionEntity? _resolveEdition(
    EditionState editionState,
    EditionEntity? edition,
  ) {
    if (edition == null) return null;
    if (editionState is EditionLoaded) {
      for (final loaded in editionState.allEditions) {
        if (loaded.identifier == edition.identifier) return loaded;
      }
    }
    return edition;
  }

  void _showEditionSelector(BuildContext context) async {
    bool hasConnection = await InternetConnection().hasInternetAccess;

    if (!hasConnection) {
      ToastUtils.showError('Qori selection is disabled while offline');
      return;
    }

    if (!context.mounted) return;

    final EditionBloc qoriBloc = context.read<EditionBloc>();
    qoriBloc.add(const SearchEditions(''));

    final currentEdition = _currentEdition(context.read<SurahListBloc>().state);

    final selectedEdition = await showModalBottomSheet<EditionEntity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: qoriBloc,
        child: EditionBottomSheet(currentEdition: currentEdition),
      ),
    );

    if (selectedEdition != null && context.mounted) {
      context.read<SurahListBloc>().add(FetchSurahs(selectedEdition));
    }
  }

  @override
  Widget build(BuildContext context) {
    return NightScaffold(
      title: "Al-Qur'an",
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: BlocBuilder<SurahListBloc, SurahListState>(
              builder: (context, state) {
                final edition = _resolveEdition(
                  context.watch<EditionBloc>().state,
                  _currentEdition(state),
                );
                return _QoriSelector(
                  edition: edition,
                  onTap: () => _showEditionSelector(context),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: SearchField(
              hintText: 'Search surah…',
              onChanged: (query) {
                context.read<SurahListBloc>().add(SearchSurahs(query));
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<SurahListBloc, SurahListState>(
              builder: (context, state) {
                if (state is SurahListLoading) {
                  return const LoadingView();
                } else if (state is SurahListLoaded) {
                  if (state.filteredSurahs.isEmpty) {
                    return const MessageView(message: 'No surahs found.');
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.only(bottom: 32),
                    itemCount: state.filteredSurahs.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      indent: 78,
                      endIndent: 20,
                      color: AppColors.border,
                    ),
                    itemBuilder: (context, index) {
                      final surah = state.filteredSurahs[index];
                      return SurahTile(
                        surah: surah,
                        onTap: () async {
                          bool hasConnection =
                              await InternetConnection().hasInternetAccess;
                          if (!hasConnection) {
                            ToastUtils.showError(
                              'Audio playback is disabled while offline',
                            );
                            return;
                          }
                          if (context.mounted) {
                            context.push(
                              RoutePaths.player,
                              extra: {
                                'surah': surah,
                                'editionIdentifier':
                                    state.currentEdition.identifier,
                                'edition': _resolveEdition(
                                  context.read<EditionBloc>().state,
                                  state.currentEdition,
                                ),
                                'surahList': state.allSurahs,
                              },
                            );
                          }
                        },
                      );
                    },
                  );
                } else if (state is SurahListError) {
                  return MessageView(
                    message: state.message,
                    actionLabel: 'Try again',
                    onAction: () => context.read<SurahListBloc>().add(
                      const FetchSurahs(_defaultEdition),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _QoriSelector extends StatelessWidget {
  final EditionEntity? edition;
  final VoidCallback onTap;

  const _QoriSelector({required this.edition, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = edition?.englishName ?? 'Select qori';
    return SurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          QoriAvatar(name: name, photoUrl: edition?.photoUrl, size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RECITED BY',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Text(
            'Change',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const Icon(Icons.expand_more_rounded, color: AppColors.primary),
        ],
      ),
    );
  }
}
