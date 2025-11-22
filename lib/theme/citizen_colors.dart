import 'package:flutter/material.dart';

/// Centralized color palette for citizen-facing screens.
///
/// Use the helpers in this class instead of hard-coding `Colors.white` or
/// `Colors.black` for consistent styling.
class CitizenColors {
  CitizenColors._();

  /// Base light color for surfaces.
  static const Color light = Colors.white;

  /// Background color for screens.
  static Color background(BuildContext context) => light;

  /// Surface color for cards, sheets, and other raised elements.
  static Color surface(BuildContext context) => light;

  /// Primary text color.
  static Color textPrimary(BuildContext context) => const Color(0xFF111827);

  /// Secondary text color for supporting copy.
  static Color textSecondary(BuildContext context) => const Color(0xFF6B7280);
}

