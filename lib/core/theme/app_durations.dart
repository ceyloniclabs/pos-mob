import 'package:flutter/animation.dart';

/// Design tokens for animation durations and easing curves.
/// Defined according to .agent/skills/flutter-uiux-design/references/design-tokens-and-theme.md
abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 350);

  // Material 3 easing curves
  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve move = Curves.easeInOutCubic;
}
