import 'package:flutter/material.dart';
import 'package:quran_audio/core/themes/app_colors.dart';

/// Flat card with a hairline border, used across the app.
class SurfaceCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color borderColor;
  final double radius;

  const SurfaceCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.color = AppColors.surface,
    this.borderColor = AppColors.border,
    this.radius = 18,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    return Material(
      color: color.withValues(alpha: 0.82),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
