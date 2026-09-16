import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_audio/core/themes/app_colors.dart';

class AppTheme {
  static final appTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.skyTop,
    textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme)
        .apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.textSecondary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
    ),
    dividerColor: AppColors.border,
    splashFactory: InkSparkle.splashFactory,
    sliderTheme: const SliderThemeData(
      activeTrackColor: AppColors.primary,
      inactiveTrackColor: AppColors.border,
      thumbColor: AppColors.primary,
      overlayColor: AppColors.primarySoft,
      trackHeight: 3,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      hintStyle: const TextStyle(color: AppColors.textMuted),
      prefixIconColor: AppColors.textMuted,
      contentPadding: EdgeInsets.zero,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.transparent,
      modalBackgroundColor: Colors.transparent,
    ),
  );

  /// Arabic script style. Amiri is bundled so harakat render offline.
  static TextStyle arabic({
    double fontSize = 24,
    Color color = AppColors.textPrimary,
    FontWeight fontWeight = FontWeight.w400,
    double height = 2.0,
  }) {
    return TextStyle(
      fontFamily: 'Amiri',
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      height: height,
    );
  }
}
