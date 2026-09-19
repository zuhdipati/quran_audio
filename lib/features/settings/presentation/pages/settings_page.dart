import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_audio/core/locale/l10n.dart';
import 'package:quran_audio/core/locale/locale_cubit.dart';
import 'package:quran_audio/core/themes/app_colors.dart';
import 'package:quran_audio/core/utils/haptics.dart';
import 'package:quran_audio/core/widgets/night_scaffold.dart';
import 'package:quran_audio/core/widgets/surface_card.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return NightScaffold(
      title: l10n.settingsTitle,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              l10n.language.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
              ),
            ),
          ),
          BlocBuilder<LocaleCubit, Locale?>(
            builder: (context, selected) => SurfaceCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _LanguageOption(
                    label: l10n.languageSystem,
                    selected: selected == null,
                    onTap: () => _choose(context, null),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  _LanguageOption(
                    label: l10n.languageIndonesian,
                    selected: selected?.languageCode == 'id',
                    onTap: () => _choose(context, const Locale('id')),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  _LanguageOption(
                    label: l10n.languageEnglish,
                    selected: selected?.languageCode == 'en',
                    onTap: () => _choose(context, const Locale('en')),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 12, 4, 0),
            child: Text(
              l10n.languageContentHint,
              style: const TextStyle(
                fontSize: 12,
                height: 1.5,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _choose(BuildContext context, Locale? locale) {
    Haptics.select();
    context.read<LocaleCubit>().select(locale);
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: selected ? 1 : 0,
              duration: const Duration(milliseconds: 150),
              child: const Icon(
                Icons.check_rounded,
                size: 20,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
