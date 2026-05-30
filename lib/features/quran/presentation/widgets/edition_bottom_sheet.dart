import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_audio/core/themes/app_colors.dart';
import 'package:quran_audio/features/quran/presentation/bloc/edition/edition_bloc.dart';

class EditionBottomSheet extends StatelessWidget {
  const EditionBottomSheet({super.key});

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
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      color: AppColors.lightGrey,
                    ),
                    itemBuilder: (context, index) {
                      final edition = state.filteredEditions[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          edition.englishName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          '${edition.name} • ${edition.language}',
                          style: const TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 12,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context, edition);
                        },
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
