import 'package:flutter/material.dart';
import 'package:quran_audio/core/themes/app_colors.dart';
import 'package:quran_audio/core/utils/haptics.dart';

/// Flat card with a hairline border, used across the app.
///
/// Tappable cards dip slightly while held and give a selection haptic, so a
/// press is acknowledged before the next screen has a chance to build.
class SurfaceCard extends StatefulWidget {
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
  State<SurfaceCard> createState() => _SurfaceCardState();
}

class _SurfaceCardState extends State<SurfaceCard> {
  bool _held = false;

  void _setHeld(bool value) {
    if (_held != value) setState(() => _held = value);
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(widget.radius);
    final onTap = widget.onTap;
    final dipped = _held && !MediaQuery.disableAnimationsOf(context);

    return AnimatedScale(
      scale: dipped ? 0.97 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Material(
        color: widget.color.withValues(alpha: 0.82),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(color: widget.borderColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap == null
              ? null
              : () {
                  Haptics.select();
                  onTap();
                },
          onTapDown: onTap == null ? null : (_) => _setHeld(true),
          onTapUp: onTap == null ? null : (_) => _setHeld(false),
          onTapCancel: onTap == null ? null : () => _setHeld(false),
          borderRadius: borderRadius,
          child: Padding(padding: widget.padding, child: widget.child),
        ),
      ),
    );
  }
}
