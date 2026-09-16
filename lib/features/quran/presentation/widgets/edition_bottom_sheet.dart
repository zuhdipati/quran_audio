import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_audio/core/themes/app_colors.dart';
import 'package:quran_audio/core/themes/app_themes.dart';
import 'package:quran_audio/core/widgets/search_field.dart';
import 'package:quran_audio/core/widgets/state_views.dart';
import 'package:quran_audio/features/quran/domain/entities/edition_entity.dart';
import 'package:quran_audio/features/quran/presentation/bloc/edition/edition_bloc.dart';
import 'package:quran_audio/features/quran/presentation/widgets/qori_avatar.dart';

class EditionBottomSheet extends StatelessWidget {
  final EditionEntity? currentEdition;

  const EditionBottomSheet({super.key, this.currentEdition});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: const BoxDecoration(
        color: AppColors.skyMiddle,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Choose a Qori',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 14),
          SearchField(
            hintText: 'Search qori…',
            onChanged: (query) {
              context.read<EditionBloc>().add(SearchEditions(query));
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BlocBuilder<EditionBloc, EditionState>(
              builder: (context, state) {
                if (state is EditionLoading) {
                  return const LoadingView();
                } else if (state is EditionLoaded) {
                  if (state.filteredEditions.isEmpty) {
                    return const MessageView(message: 'No qori found.');
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: state.filteredEditions.length,
                    itemBuilder: (context, index) {
                      final edition = state.filteredEditions[index];
                      final isSelected =
                          currentEdition?.identifier == edition.identifier;
                      return _QoriTile(
                        edition: edition,
                        isSelected: isSelected,
                      );
                    },
                  );
                } else if (state is EditionError) {
                  return MessageView(message: state.message);
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

class _QoriTile extends StatelessWidget {
  final EditionEntity edition;
  final bool isSelected;

  const _QoriTile({required this.edition, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final style = edition.style;
    final showArabic =
        edition.name.isNotEmpty && edition.name != edition.englishName;

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Material(
        color: isSelected ? AppColors.primarySoft : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          leading: QoriAvatar(
            name: edition.englishName,
            photoUrl: edition.photoUrl,
            size: 46,
          ),
          title: Text(
            edition.displayName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
          subtitle: Row(
            children: [
              if (style != null) ...[
                Text(
                  style,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (showArabic)
                  const Text(
                    '  ·  ',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
              ],
              if (showArabic)
                Flexible(
                  child: Text(
                    edition.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.rtl,
                    style: AppTheme.arabic(
                      fontSize: 14,
                      height: 1.4,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
            ],
          ),
          trailing: isSelected
              ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
              : null,
          onTap: () => Navigator.pop(context, edition),
        ),
      ),
    );
  }
}
