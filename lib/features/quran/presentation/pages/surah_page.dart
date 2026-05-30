import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:quran_audio/core/themes/app_colors.dart';
import 'package:quran_audio/features/quran/domain/entities/edition_entity.dart';
import 'package:quran_audio/features/quran/presentation/bloc/edition/edition_bloc.dart';
import 'package:quran_audio/features/quran/presentation/bloc/surah_list/surah_list_bloc.dart';
import 'package:quran_audio/features/quran/presentation/widgets/edition_bottom_sheet.dart';
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
  @override
  void initState() {
    super.initState();
    context.read<EditionBloc>().add(GetEditions());
    context.read<SurahListBloc>().add(
      FetchSurahs(
        EditionEntity(
          identifier: 'ar.alafasy',
          language: 'ar',
          name: 'Alafasy',
          englishName: 'Alafasy',
        ),
      ),
    );
  }

  void _showEditionSelector(BuildContext context) async {
    final EditionBloc qoriBloc = context.read<EditionBloc>();

    qoriBloc.add(const SearchEditions(''));

    final selectedEdition = await showModalBottomSheet<EditionEntity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: qoriBloc,
        child: const EditionBottomSheet(),
      ),
    );

    if (selectedEdition != null && context.mounted) {
      context.read<SurahListBloc>().add(FetchSurahs(selectedEdition));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Quran',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Surah',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showEditionSelector(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary),
                        ),
                        child: BlocBuilder<SurahListBloc, SurahListState>(
                          builder: (context, state) {
                            String editionName = 'Default';
                            if (state is SurahListLoading &&
                                state.currentEdition != null) {
                              editionName = state.currentEdition!.englishName;
                            } else if (state is SurahListLoaded) {
                              editionName = state.currentEdition.englishName;
                            }
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.person_outline,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'Qori: $editionName',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: AppColors.primary,
                                  size: 16,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search surah...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textGrey,
                    ),
                    filled: true,
                    fillColor: AppColors.lightGrey.withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (query) {
                    context.read<SurahListBloc>().add(SearchSurahs(query));
                  },
                ),
              ),
              Expanded(
                child: BlocBuilder<SurahListBloc, SurahListState>(
                  builder: (context, state) {
                    if (state is SurahListLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    } else if (state is SurahListLoaded) {
                      if (state.filteredSurahs.isEmpty) {
                        return const Center(child: Text('No surahs found.'));
                      }
                      return ListView.separated(
                        itemCount: state.filteredSurahs.length,
                        separatorBuilder: (context, index) => const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Divider(height: 1, color: AppColors.lightGrey),
                        ),
                        itemBuilder: (context, index) {
                          final surah = state.filteredSurahs[index];
                          return SurahTile(
                            surah: surah,
                            onTap: () {
                              // TODO: Navigate to Player / Detail Surah
                            },
                          );
                        },
                      );
                    } else if (state is SurahListError) {
                      return Center(child: Text(state.message));
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
          // Positioned(bottom: 0, left: 10, right: 10, child: PlayerBottom()),
        ],
      ),
    );
  } 
}
