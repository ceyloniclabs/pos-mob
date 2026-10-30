import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Centralized utility for showing themed date and time pickers across the app.
/// Ensures consistent Material 3 branding, haptics, and color palette.
class AppDatePickerUtils {
  AppDatePickerUtils._();

  /// Displays the app's themed Date Picker.
  static Future<DateTime?> showThemedDatePicker({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    String? helpText,
    String? cancelText,
    String? confirmText,
    DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
  }) async {
    HapticFeedback.selectionClick();

    // Ensure initialDate is strictly within [firstDate, lastDate]
    final safeInitial = initialDate.isBefore(firstDate)
        ? firstDate
        : (initialDate.isAfter(lastDate) ? lastDate : initialDate);

    final picked = await showDatePicker(
      context: context,
      initialDate: safeInitial,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: helpText,
      cancelText: cancelText,
      confirmText: confirmText,
      initialEntryMode: initialEntryMode,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked != null) {
      HapticFeedback.selectionClick();
    }

    return picked;
  }

  /// Displays the app's themed Time Picker.
  static Future<TimeOfDay?> showThemedTimePicker({
    required BuildContext context,
    required TimeOfDay initialTime,
    String? helpText,
    String? cancelText,
    String? confirmText,
    TimePickerEntryMode initialEntryMode = TimePickerEntryMode.dial,
  }) async {
    HapticFeedback.selectionClick();

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: helpText,
      cancelText: cancelText,
      confirmText: confirmText,
      initialEntryMode: initialEntryMode,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked != null) {
      HapticFeedback.selectionClick();
    }

    return picked;
  }

  /// Displays the app's themed Date Range Picker.
  static Future<DateTimeRange?> showThemedDateRangePicker({
    required BuildContext context,
    DateTimeRange? initialDateRange,
    required DateTime firstDate,
    required DateTime lastDate,
    String? helpText,
    String? cancelText,
    String? confirmText,
    String? saveText,
  }) async {
    HapticFeedback.selectionClick();

    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: helpText,
      cancelText: cancelText,
      confirmText: confirmText,
      saveText: saveText,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked != null) {
      HapticFeedback.selectionClick();
    }

    return picked;
  }
}
