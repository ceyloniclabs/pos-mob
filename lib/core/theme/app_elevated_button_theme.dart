import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A utility class for holding custom ElevatedButton styles.
class AppElevatedButtonTheme {
  // Private constructor to prevent instantiation.
  AppElevatedButtonTheme._();

  /// A custom button style that sets a minimum height, making it suitable
  /// for prominent call-to-action buttons.
  static final ButtonStyle fullWidthButtonStyle = ElevatedButton.styleFrom(
    minimumSize: Size.fromHeight(50.h),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.r),
    ),
  );
}
