import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_audio/core/routes/route_paths.dart';
import 'package:quran_audio/core/themes/app_colors.dart';
import 'package:quran_audio/features/home/presentation/widgets/menu_icons.dart';

class _MenuItem {
  final String label;
  final String route;
  final Widget Function(Color color) icon;

  const _MenuItem(this.label, this.route, this.icon);
}

final _items = <_MenuItem>[
  _MenuItem(
    'Quran',
    RoutePaths.quran,
    (c) => Icon(Icons.menu_book_rounded, color: c, size: 26),
  ),
  _MenuItem(
    'Hijri',
    RoutePaths.hijri,
    (c) => Icon(Icons.brightness_3_rounded, color: c, size: 24),
  ),
  _MenuItem(
    'Qibla',
    RoutePaths.qibla,
    (c) => Icon(Icons.explore_rounded, color: c, size: 26),
  ),
  _MenuItem('Tasbeeh', RoutePaths.tasbeeh, (c) => TasbeehGlyph(color: c)),
  _MenuItem(
    'Calendar',
    RoutePaths.calendar,
    (c) => Icon(Icons.calendar_month_rounded, color: c, size: 26),
  ),
  _MenuItem('Dua', RoutePaths.dua, (c) => DuaGlyph(color: c, size: 30)),
  _MenuItem(
    'Hadith',
    RoutePaths.hadith,
    (c) => Icon(Icons.auto_stories_rounded, color: c, size: 25),
  ),
  _MenuItem(
    'Salah',
    RoutePaths.salah,
    (c) => Icon(Icons.mosque_rounded, color: c, size: 26),
  ),
];

class FeatureMenu extends StatelessWidget {
  const FeatureMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const columns = 5;
        const spacing = 10.0;
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: 16,
          children: [
            for (final item in _items)
              SizedBox(
                width: itemWidth,
                child: _MenuTile(item: item),
              ),
          ],
        );
      },
    );
  }
}

class _MenuTile extends StatelessWidget {
  final _MenuItem item;

  const _MenuTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: item.label,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.push(item.route),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                alignment: Alignment.center,
                child: item.icon(AppColors.primary),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
