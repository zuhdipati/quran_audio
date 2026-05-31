import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_audio/core/themes/app_colors.dart';
import 'package:quran_audio/features/quran/domain/entities/edition_entity.dart';
import 'package:quran_audio/features/quran/presentation/bloc/edition/edition_bloc.dart';
import 'package:quran_audio/core/utils/qori_name_formatter.dart';

class EditionBottomSheet extends StatelessWidget {
  final EditionEntity? currentEdition;

  const EditionBottomSheet({super.key, this.currentEdition});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Select Edition / Qori',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search edition...',
              prefixIcon: const Icon(Icons.search, color: AppColors.textGrey),
              filled: true,
              fillColor: AppColors.lightGrey.withValues(alpha: 0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (query) {
              context.read<EditionBloc>().add(SearchEditions(query));
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<EditionBloc, EditionState>(
              builder: (context, state) {
                if (state is EditionLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                } else if (state is EditionLoaded) {
                  if (state.filteredEditions.isEmpty) {
                    return const Center(child: Text('No editions found.'));
                  }

                  return ListView.separated(
                    itemCount: state.filteredEditions.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1, color: AppColors.lightGrey),
                    itemBuilder: (context, index) {
                      final edition = state.filteredEditions[index];
                      final isSelected =
                          currentEdition?.identifier == edition.identifier;

                      return Container(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : Colors.transparent,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          title: Text(
                            edition.englishName.formatQoriName,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.black,
                            ),
                          ),
                          subtitle: Text(
                            '${edition.name.formatQoriName} • ${edition.language}',
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.7)
                                  : AppColors.textGrey,
                              fontSize: 12,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_circle,
                                  color: AppColors.primary,
                                )
                              : null,
                          onTap: () {
                            Navigator.pop(context, edition);
                          },
                        ),
                      );
                    },
                  );
                } else if (state is EditionError) {
                  return Center(child: Text(state.message));
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
