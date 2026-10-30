import 'package:flutter/widgets.dart';

/// Design tokens for corner radius.
/// Defined according to .agent/skills/flutter-uiux-design/references/design-tokens-and-theme.md
abstract final class AppRadius {
  static const double xs = 4.0;    // Tiny pills, small icon boxes
  static const double sm = 8.0;    // Chips, small inputs, badges
  static const double md = 12.0;   // Dominant radius: buttons, text fields, cards
  static const double lg = 16.0;   // Large cards, modal dialogs
  static const double xl = 24.0;   // Hero cards, bottom sheets
  static const double full = 999.0; // Circular, capsules, avatars

  // BorderRadius presets
  static const BorderRadius xsAll = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius fullAll = BorderRadius.all(Radius.circular(full));

  // Specialized sheet / header radiuses
  static const BorderRadius sheetTop = BorderRadius.vertical(top: Radius.circular(xl));
  static const BorderRadius dialogAll = BorderRadius.all(Radius.circular(lg));
}
