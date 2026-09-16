import 'package:flutter/services.dart';

/// Single entry point for haptic feedback.
///
/// Keeping the intensities behind named intents means the whole app speaks
/// one vocabulary, and muting or re-tuning feedback later is a one-file job.
class Haptics {
  Haptics._();

  /// Moving between things: list rows, chips, toggles.
  static void select() => HapticFeedback.selectionClick();

  /// Committing to something: play/pause, primary buttons.
  static void tap() => HapticFeedback.lightImpact();

  /// A counted milestone, such as completing a dzikir round.
  static void success() => HapticFeedback.heavyImpact();

  /// Something the app refused to do.
  static void error() => HapticFeedback.vibrate();
}
