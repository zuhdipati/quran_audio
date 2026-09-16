import 'package:flutter/material.dart';
import 'package:quran_audio/core/themes/app_colors.dart';
import 'package:quran_audio/core/widgets/celestial_loader.dart';

class LoadingView extends StatelessWidget {
  final double size;

  const LoadingView({super.key, this.size = 34});

  @override
  Widget build(BuildContext context) => CelestialLoader(size: size);
}

class MessageView extends StatelessWidget {
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const MessageView({
    super.key,
    required this.message,
    this.icon = Icons.nights_stay_outlined,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _FadeIn(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.textMuted, size: 32),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 16),
                TextButton(onPressed: onAction, child: Text(actionLabel!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Eases an empty or error state in so it does not snap into place the
/// instant a request fails.
class _FadeIn extends StatelessWidget {
  final Widget child;

  const _FadeIn({required this.child});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      child: child,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.scale(scale: 0.96 + 0.04 * value, child: child),
      ),
    );
  }
}
