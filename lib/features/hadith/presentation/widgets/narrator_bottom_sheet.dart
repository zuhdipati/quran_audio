import 'package:flutter/material.dart';
import 'package:quran_audio/core/themes/app_colors.dart';
import 'package:quran_audio/core/utils/haptics.dart';
import 'package:quran_audio/features/hadith/domain/entities/hadith_entity.dart';
import 'package:quran_audio/core/locale/l10n.dart';

/// Picks which narrator's collection to read.
class NarratorBottomSheet extends StatelessWidget {
  final List<HadithCollectionEntity> collections;
  final HadithCollectionEntity? current;

  const NarratorBottomSheet({
    super.key,
    required this.collections,
    this.current,
  });

  static Future<HadithCollectionEntity?> show(
    BuildContext context, {
    required List<HadithCollectionEntity> collections,
    HadithCollectionEntity? current,
  }) {
    return showModalBottomSheet<HadithCollectionEntity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          NarratorBottomSheet(collections: collections, current: current),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      height: MediaQuery.of(context).size.height * 0.7,
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
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              context.l10n.chooseNarrator,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: collections.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final collection = collections[index];
                return _NarratorTile(
                  collection: collection,
                  selected: collection.id == current?.id,
                  onTap: () {
                    Haptics.select();
                    Navigator.of(context).pop(collection);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NarratorTile extends StatelessWidget {
  final HadithCollectionEntity collection;
  final bool selected;
  final VoidCallback onTap;

  const _NarratorTile({
    required this.collection,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primarySoft : AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      collection.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${collection.narrator} · '
                      '${context.l10n.hadithCount(thousands(collection.total))}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.check_circle,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 26363 -> "26,363". intl is already a dependency but pulling a full
/// NumberFormat in for one label is heavier than this.
String thousands(int value) {
  final digits = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}
