import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_audio/core/routes/route_paths.dart';
import 'package:quran_audio/core/themes/app_colors.dart';
import 'package:quran_audio/core/utils/arabic_number_utils.dart';
import 'package:quran_audio/core/widgets/entrance.dart';
import 'package:quran_audio/core/widgets/night_scaffold.dart';
import 'package:quran_audio/core/widgets/search_field.dart';
import 'package:quran_audio/core/widgets/state_views.dart';
import 'package:quran_audio/core/widgets/surface_card.dart';
import 'package:quran_audio/features/hadith/domain/entities/hadith_entity.dart';
import 'package:quran_audio/features/hadith/presentation/bloc/hadith_bloc.dart';
import 'package:quran_audio/features/hadith/presentation/widgets/narrator_bottom_sheet.dart';

class HadithPage extends StatefulWidget {
  const HadithPage({super.key});

  @override
  State<HadithPage> createState() => _HadithPageState();
}

class _HadithPageState extends State<HadithPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final bloc = context.read<HadithBloc>();
    if (bloc.state.status == HadithStatus.initial) {
      bloc.add(const HadithsRequested());
    }
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    // start the next chunk before the user reaches the bottom
    if (position.pixels >= position.maxScrollExtent - 600) {
      context.read<HadithBloc>().add(const HadithNextPageRequested());
    }
  }

  Future<void> _pickNarrator(HadithState state) async {
    final chosen = await NarratorBottomSheet.show(
      context,
      collections: state.collections,
      current: state.selected,
    );
    if (chosen == null || !mounted) return;
    context.read<HadithBloc>().add(HadithCollectionSelected(chosen));
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    return NightScaffold(
      title: 'Hadith',
      body: BlocBuilder<HadithBloc, HadithState>(
        builder: (context, state) {
          if (state.status == HadithStatus.error && state.hadiths.isEmpty) {
            return MessageView(
              message: state.message ?? 'Unable to load hadith',
              actionLabel: 'Try again',
              onAction: () =>
                  context.read<HadithBloc>().add(const HadithsRequested()),
            );
          }

          final selected = state.selected;
          if (selected == null) return const LoadingView();

          final visible = state.visible;

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _NarratorSelector(
                        collection: selected,
                        onTap: () => _pickNarrator(state),
                      ),
                      const SizedBox(height: 12),
                      SearchField(
                        hintText: 'Search loaded hadith…',
                        onChanged: (query) => context.read<HadithBloc>().add(
                          HadithSearchChanged(query),
                        ),
                      ),
                      if (state.query.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Searching the ${thousands(state.hadiths.length)} '
                          'hadith loaded so far, not the full collection.',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              if (state.status == HadithStatus.loading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: LoadingView(),
                )
              else if (visible.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: MessageView(message: 'No hadith found.'),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  sliver: SliverList.separated(
                    itemCount: visible.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) => StaggeredEntrance(
                      index: index,
                      child: HadithTile(hadith: visible[index]),
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: _ListFooter(
                  state: state,
                  onRetry: () => context.read<HadithBloc>().add(
                    const HadithNextPageRequested(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NarratorSelector extends StatelessWidget {
  final HadithCollectionEntity collection;
  final VoidCallback onTap;

  const _NarratorSelector({required this.collection, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NARRATOR',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  collection.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${thousands(collection.total)} hadith · '
                  '${collection.narrator}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.unfold_more_rounded,
            size: 20,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

/// Progress through a long collection, plus a retry when a chunk fails.
class _ListFooter extends StatelessWidget {
  final HadithState state;
  final VoidCallback onRetry;

  const _ListFooter({required this.state, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    if (state.status != HadithStatus.loaded) return const SizedBox(height: 32);

    if (state.loadingMore) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: LoadingView(size: 26),
      );
    }

    if (state.message != null && state.hasMore) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        child: Column(
          children: [
            Text(
              state.message!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            TextButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      );
    }

    if (!state.hasMore && state.query.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Text(
          'All ${thousands(state.hadiths.length)} hadith loaded',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
      );
    }

    return const SizedBox(height: 40);
  }
}

class HadithTile extends StatelessWidget {
  final HadithEntity hadith;

  const HadithTile({super.key, required this.hadith});

  @override
  Widget build(BuildContext context) {
    // hosted collections carry no titles, so lead with the translation
    final heading = hadith.title;

    return SurfaceCard(
      onTap: () => context.push(RoutePaths.hadithDetail, extra: hadith),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
            child: Text(
              ArabicNumberUtils.convert(hadith.number),
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 16,
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (heading != null) ...[
                  Text(
                    heading,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                Text(
                  hadith.translation,
                  maxLines: heading == null ? 3 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: heading == null ? 14 : 13,
                    height: 1.45,
                    color: heading == null
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
