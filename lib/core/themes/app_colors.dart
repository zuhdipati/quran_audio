import 'package:flutter/material.dart';

/// Predawn palette: a deep night sky that warms towards the horizon,
/// with the morning star as the single accent colour.
class AppColors {
  AppColors._();

  // sky
  static const skyTop = Color(0XFF060A1C);
  static const skyMiddle = Color(0XFF0E1634);
  static const skyLow = Color(0XFF1B2150);
  static const horizon = Color(0XFF3B2D5C);
  static const dawnGlow = Color(0XFFD39A74);

  // surfaces
  static const surface = Color(0XFF10183A);
  static const surfaceHigh = Color(0XFF18214A);
  static const border = Color(0X1AFFFFFF);

  // text
  static const textPrimary = Color(0XFFEDEBF5);
  static const textSecondary = Color(0XFFA2A8CC);
  static const textMuted = Color(0XFF6D7399);

  // accents
  static const primary = Color(0XFFE9C47E);
  static const onPrimary = Color(0XFF1A1530);
  static const primarySoft = Color(0X26E9C47E);
  static const starlight = Color(0XFFF6F1FF);
  static const error = Color(0XFFE58C8C);
  static const success = Color(0XFF8DCCA9);
}
