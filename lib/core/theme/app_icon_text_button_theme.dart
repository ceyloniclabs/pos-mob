import 'package:flutter/material.dart';

/// A utility class for holding custom TextButton themes.
/// This class provides styles that remove the default padding from TextButtons,
/// making them more compact.
class AppIconTextButtonTheme {
  // Private constructor to prevent instantiation.
  AppIconTextButtonTheme._();

  /// A compact button style for the light theme.
  static final ButtonStyle lightIconTextButtonStyle = TextButton.styleFrom(
    padding: EdgeInsets.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    // You can add other light-theme-specific properties here.
    // For example:
    // foregroundColor: Colors.black,
  );

  /// A compact button style for the dark theme.
  static final ButtonStyle darkIconTextButtonStyle = TextButton.styleFrom(
    padding: EdgeInsets.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    // You can add other dark-theme-specific properties here.
    // For example:
    // foregroundColor: Colors.white,
  );
}
