import 'package:flutter/material.dart';
import 'package:quran_audio/core/themes/app_colors.dart';
import 'package:quran_audio/core/widgets/night_sky_background.dart';

/// Scaffold with the shared night sky behind a transparent app bar.
class NightScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? leading;
  final VoidCallback? onBack;
  final bool showAppBar;

  const NightScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.leading,
    this.onBack,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: AppColors.skyTop,
      extendBodyBehindAppBar: true,
      appBar: showAppBar
          ? AppBar(
              automaticallyImplyLeading: false,
              leading:
                  leading ??
                  (canPop || onBack != null
                      ? IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 20,
                          ),
                          onPressed:
                              onBack ?? () => Navigator.of(context).maybePop(),
                        )
                      : null),
              title: title == null
                  ? null
                  : Text(
                      title!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
              actions: actions,
            )
          : null,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(child: NightSkyBackground()),
          SafeArea(bottom: false, child: body),
        ],
      ),
    );
  }
}
