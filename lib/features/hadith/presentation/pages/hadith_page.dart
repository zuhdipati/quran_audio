import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_audio/core/routes/route_paths.dart';
import 'package:quran_audio/core/themes/app_colors.dart';
import 'package:quran_audio/core/utils/arabic_number_utils.dart';
import 'package:quran_audio/core/widgets/night_scaffold.dart';
import 'package:quran_audio/core/widgets/search_field.dart';
import 'package:quran_audio/core/widgets/state_views.dart';
import 'package:quran_audio/core/widgets/surface_card.dart';
import 'package:quran_audio/features/hadith/domain/entities/hadith_entity.dart';
import 'package:quran_audio/features/hadith/presentation/bloc/hadith_bloc.dart';

class HadithPage extends StatefulWidget {
  const HadithPage({super.key});

  @override
  State<HadithPage> createState() => _HadithPageState();
}

class _HadithPageState extends State<HadithPage> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<HadithBloc>();
    if (bloc.state is HadithInitial) bloc.add(HadithsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return NightScaffold(
      title: 'Hadith',
      body: BlocBuilder<HadithBloc, HadithState>(
        builder: (context, state) {
          return switch (state) {
            HadithInitial() || HadithLoading() => const LoadingView(),
            HadithError(:final message) => MessageView(message: message),
            HadithLoaded() => _HadithList(state: state),
          };
        },
      ),
    );
  }
}

class _HadithList extends StatelessWidget {
  final HadithLoaded state;

  const _HadithList({required this.state});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.collection.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${state.collection.hadiths.length} hadith compiled by ${state.collection.compiler}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                SearchField(
                  hintText: 'Search hadith…',
                  onChanged: (query) => context.read<HadithBloc>().add(
                    HadithSearchChanged(query),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        if (state.filtered.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: MessageView(message: 'No hadith found.'),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            sliver: SliverList.separated(
              itemCount: state.filtered.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) =>
                  HadithTile(hadith: state.filtered[index]),
            ),
          ),
      ],
    );
  }
}

class HadithTile extends StatelessWidget {
  final HadithEntity hadith;

  const HadithTile({super.key, required this.hadith});

  @override
  Widget build(BuildContext context) {
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
                Text(
                  hadith.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  hadith.translation,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: AppColors.textSecondary,
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
