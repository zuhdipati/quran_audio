import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_audio/core/routes/route_paths.dart';
import 'package:quran_audio/core/themes/app_colors.dart';
import 'package:quran_audio/core/widgets/night_scaffold.dart';
import 'package:quran_audio/core/widgets/search_field.dart';
import 'package:quran_audio/core/widgets/entrance.dart';
import 'package:quran_audio/core/widgets/state_views.dart';
import 'package:quran_audio/features/dua/presentation/bloc/dua/dua_bloc.dart';
import 'package:quran_audio/features/dua/presentation/widgets/dua_tile.dart';

class DuaPage extends StatefulWidget {
  const DuaPage({super.key});

  @override
  State<DuaPage> createState() => _DuaPageState();
}

class _DuaPageState extends State<DuaPage> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<DuaBloc>();
    if (bloc.state.status == DuaStatus.initial) bloc.add(DuasRequested());
  }

  @override
  Widget build(BuildContext context) {
    return NightScaffold(
      title: 'Dua',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: SearchField(
              hintText: 'Search dua…',
              onChanged: (query) =>
                  context.read<DuaBloc>().add(DuaSearchChanged(query)),
            ),
          ),
          const _GroupChips(),
          const SizedBox(height: 8),
          Expanded(
            child: BlocBuilder<DuaBloc, DuaState>(
              builder: (context, state) {
                switch (state.status) {
                  case DuaStatus.initial:
                  case DuaStatus.loading:
                    return const LoadingView();
                  case DuaStatus.error:
                    return MessageView(message: state.message ?? 'Error');
                  case DuaStatus.loaded:
                    if (state.filteredDuas.isEmpty) {
                      return const MessageView(message: 'No duas found.');
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                      itemCount: state.filteredDuas.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final dua = state.filteredDuas[index];
                        return StaggeredEntrance(
                          index: index,
                          child: DuaTile(
                            dua: dua,
                            onTap: () =>
                                context.push(RoutePaths.duaDetail, extra: dua),
                          ),
                        );
                      },
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupChips extends StatelessWidget {
  const _GroupChips();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DuaBloc, DuaState>(
      buildWhen: (previous, current) =>
          previous.groups != current.groups ||
          previous.selectedGroup != current.selectedGroup,
      builder: (context, state) {
        if (state.groups.isEmpty) return const SizedBox.shrink();
        final groups = <String?>[null, ...state.groups];
        return SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: groups.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final group = groups[index];
              final isSelected = group == state.selectedGroup;
              return ChoiceChip(
                label: Text(group ?? 'All'),
                selected: isSelected,
                showCheckmark: false,
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppColors.onPrimary
                      : AppColors.textSecondary,
                ),
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surface,
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
                shape: const StadiumBorder(),
                onSelected: (_) =>
                    context.read<DuaBloc>().add(DuaGroupSelected(group)),
              );
            },
          ),
        );
      },
    );
  }
}
