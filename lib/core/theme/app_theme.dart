import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pos/core/controllers/persistent_data_controller.dart';
import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_semantic_colors.dart';
import 'package:pos/core/theme/app_spacing.dart';

// =============================================================================
// 1. RAW COLORS (Palette & Constants)
// =============================================================================
class AColors {
  AColors._();

  // -- Main Backgrounds & Surfaces --
  static const Color bgDark = Color(0xFF101F22);
  static const Color cardDark = Color(0xFF182C30);
  static const Color surfaceContainerDark = Color(0xFF1D353A);
  static const Color chipDark = Color(0xFF2A3B42);

  // -- Light Surfaces --
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color surfaceContainerLight = Color(0xFFF1F5F9);

  // -- Primary Brand Colors --
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color primaryTeal = Color(0xFF00A79D);

  // -- Text Colors --
  static const Color textWhite = Color(0xFFF0F4F4);
  static const Color textGrey = Color(0xFF94A3B8);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textDarkMuted = Color(0xFF64748B);

  // -- Borders & Dividers --
  static const Color borderDark = Color(0xFF334155);
  static const Color borderLight = Color(0xFFE2E8F0);

  // -- Status Colors --
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFF59E0B);
  static const Color repair = Color(0xFFFFC107);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF4A90E2);

  // -- Functional Specifics --
  static const Color paperWhite = Color(0xFFF5F5F5);
}

class AppColors {
  static const Color primary = AColors.primaryBlue;
  static const Color primaryLight = AColors.primaryTeal;
  static const Color primaryDark = AColors.bgDark;

  static const Color surfaceLight = AColors.bgLight;
  static const Color surfaceDark = AColors.bgDark;
  static const Color cardLight = AColors.cardLight;
  static const Color cardDark = AColors.cardDark;

  static const Color accent = AColors.primaryTeal;
  static const Color warning = AColors.warning;
  static const Color error = AColors.error;
  static const Color success = AColors.success;
}

// =============================================================================
// 2. BACKWARD COMPATIBLE STATUSCOLORS EXTENSION
// =============================================================================
@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  final Color? success;
  final Color? warning;
  final Color? repair;
  final Color? paperWhite;
  final Color? info;
  final Color? error;

  const StatusColors({
    required this.success,
    required this.warning,
    required this.repair,
    required this.paperWhite,
    required this.info,
    required this.error,
  });

  static const dark = StatusColors(
    success: AColors.success,
    warning: AColors.warning,
    repair: AColors.repair,
    paperWhite: AColors.paperWhite,
    info: AColors.info,
    error: AColors.error,
  );

  static const light = StatusColors(
    success: Color(0xFF2E7D32),
    warning: Color(0xFFEF6C00),
    repair: Color(0xFFF9A825),
    paperWhite: Colors.white,
    info: Color(0xFF1976D2),
    error: Color(0xFFC62828),
  );

  @override
  StatusColors copyWith({
    Color? success,
    Color? warning,
    Color? repair,
    Color? paperWhite,
    Color? info,
    Color? error,
  }) {
    return StatusColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      repair: repair ?? this.repair,
      paperWhite: paperWhite ?? this.paperWhite,
      info: info ?? this.info,
      error: error ?? this.error,
    );
  }

  @override
  StatusColors lerp(ThemeExtension<StatusColors>? other, double t) {
    if (other is! StatusColors) return this;
    return StatusColors(
      success: Color.lerp(success, other.success, t),
      warning: Color.lerp(warning, other.warning, t),
      repair: Color.lerp(repair, other.repair, t),
      paperWhite: Color.lerp(paperWhite, other.paperWhite, t),
      info: Color.lerp(info, other.info, t),
      error: Color.lerp(error, other.error, t),
    );
  }
}

// =============================================================================
// 3. TEXT THEME BUILDER (Strict Material 3 roles)
// =============================================================================
TextTheme _buildTextTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final textPrimary = isDark ? AColors.textWhite : AColors.textDark;
  final textSecondary = isDark ? AColors.textGrey : AColors.textDarkMuted;

  return GoogleFonts.interTextTheme(
    TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: textPrimary,
        height: 1.25,
      ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.25,
      color: textPrimary,
      height: 1.3,
    ),
    titleLarge: TextStyle(
      fontSize: 19,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
      color: textPrimary,
      height: 1.3,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: textPrimary,
      height: 1.35,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: textPrimary,
      height: 1.4,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: textPrimary,
      height: 1.45,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: textPrimary,
      height: 1.45,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: textSecondary,
      height: 1.4,
    ),
    labelLarge: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: textPrimary,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: textPrimary,
      letterSpacing: 0.2,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: textSecondary,
      letterSpacing: 0.4,
    ),
  ),
  );
}

// =============================================================================
// 4. THEME FACTORY
// =============================================================================
ThemeData _buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;

  final colorScheme = ColorScheme.fromSeed(
    seedColor: AColors.primaryBlue,
    brightness: brightness,
  ).copyWith(
    primary: AColors.primaryBlue,
    onPrimary: Colors.white,
    secondary: AColors.primaryTeal,
    onSecondary: Colors.white,
    tertiary: AColors.repair,
    error: AColors.error,
    surface: isDark ? AColors.bgDark : AColors.bgLight,
    surfaceContainerLow: isDark ? AColors.cardDark : AColors.cardLight,
    surfaceContainer: isDark ? AColors.surfaceContainerDark : AColors.surfaceContainerLight,
    surfaceContainerHighest: isDark ? AColors.chipDark : const Color(0xFFE2E8F0),
    outline: isDark ? AColors.borderDark : const Color(0xFFCBD5E1),
    outlineVariant: isDark ? AColors.borderDark.withValues(alpha: 0.6) : AColors.borderLight,
    onSurfaceVariant: isDark ? AColors.textGrey : AColors.textDarkMuted,
  );

  final textTheme = _buildTextTheme(brightness);

  return ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.inter().fontFamily,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
    textTheme: textTheme,
    visualDensity: VisualDensity.standard,
    materialTapTargetSize: MaterialTapTargetSize.padded, // ≥48dp touch targets

    extensions: <ThemeExtension<dynamic>>[
      isDark ? StatusColors.dark : StatusColors.light,
      isDark ? AppSemanticColors.dark : AppSemanticColors.light,
    ],

    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: colorScheme.surface,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18.5,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: colorScheme.onSurface,
      ),
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.mdAll,
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: colorScheme.surfaceContainerHighest,
      labelStyle: textTheme.labelMedium?.copyWith(color: colorScheme.onSurface),
      side: BorderSide.none,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.fullAll),
    ),

    dividerTheme: DividerThemeData(
      color: colorScheme.outlineVariant,
      thickness: 1,
      space: 1,
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 48),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        textStyle: textTheme.labelLarge,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 48),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        side: BorderSide(color: colorScheme.outlineVariant),
        textStyle: textTheme.labelLarge,
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerLow,
      hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: AppRadius.mdAll,
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.mdAll,
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.mdAll,
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.mdAll,
        borderSide: BorderSide(color: colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppRadius.mdAll,
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: isDark ? AColors.cardDark : AColors.textDark,
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: isDark ? AColors.textWhite : Colors.white,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.mdAll,
        side: BorderSide(color: AColors.borderDark),
      ),
      behavior: SnackBarBehavior.floating,
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      showDragHandle: true,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.sheetTop),
    ),

    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      elevation: 0,
      backgroundColor: colorScheme.surface,
      indicatorColor: colorScheme.secondaryContainer,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: isDark ? AColors.cardDark : AColors.cardLight,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lgAll,
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
      ),
      contentTextStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: colorScheme.onSurfaceVariant,
      ),
    ),

    datePickerTheme: DatePickerThemeData(
      backgroundColor: isDark ? AColors.cardDark : AColors.cardLight,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.25),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lgAll,
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      headerBackgroundColor:
          isDark ? AColors.surfaceContainerDark : AColors.surfaceContainerLight,
      headerForegroundColor: colorScheme.primary,
      headerHeadlineStyle: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: colorScheme.primary,
      ),
      headerHelpStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurfaceVariant,
        letterSpacing: 0.5,
      ),
      weekdayStyle: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurfaceVariant,
      ),
      dayStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      dayForegroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.disabled)) {
          return colorScheme.onSurface.withValues(alpha: 0.35);
        }
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return colorScheme.onSurface;
      }),
      dayBackgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }
        return null;
      }),
      dayOverlayColor:
          WidgetStateProperty.all(colorScheme.primary.withValues(alpha: 0.12)),
      todayForegroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return colorScheme.primary;
      }),
      todayBackgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }
        return colorScheme.primary.withValues(alpha: 0.12);
      }),
      todayBorder: BorderSide(color: colorScheme.primary, width: 1.5),
      yearStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
      yearForegroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.disabled)) {
          return colorScheme.onSurface.withValues(alpha: 0.35);
        }
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return colorScheme.onSurface;
      }),
      yearBackgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }
        return null;
      }),
      rangePickerBackgroundColor:
          isDark ? AColors.cardDark : AColors.cardLight,
      rangePickerElevation: 0,
      rangePickerShadowColor: Colors.black.withValues(alpha: 0.25),
      rangePickerSurfaceTintColor: Colors.transparent,
      rangePickerShape: RoundedRectangleBorder(
        borderRadius: AppRadius.lgAll,
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      rangePickerHeaderBackgroundColor:
          isDark ? AColors.surfaceContainerDark : AColors.surfaceContainerLight,
      rangePickerHeaderForegroundColor: colorScheme.primary,
      rangePickerHeaderHeadlineStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: colorScheme.primary,
      ),
      rangePickerHeaderHelpStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurfaceVariant,
      ),
      rangeSelectionBackgroundColor:
          colorScheme.primary.withValues(alpha: 0.18),
      rangeSelectionOverlayColor:
          WidgetStateProperty.all(colorScheme.primary.withValues(alpha: 0.12)),
      dividerColor: colorScheme.outlineVariant,
      cancelButtonStyle: TextButton.styleFrom(
        foregroundColor: colorScheme.onSurfaceVariant,
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
      confirmButtonStyle: FilledButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
    ),

    timePickerTheme: TimePickerThemeData(
      backgroundColor: isDark ? AColors.cardDark : AColors.cardLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lgAll,
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      hourMinuteShape: RoundedRectangleBorder(
        borderRadius: AppRadius.mdAll,
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      dayPeriodShape: RoundedRectangleBorder(
        borderRadius: AppRadius.smAll,
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      hourMinuteColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary.withValues(alpha: 0.16);
        }
        return isDark
            ? AColors.surfaceContainerDark
            : AColors.surfaceContainerLight;
      }),
      hourMinuteTextColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }
        return colorScheme.onSurface;
      }),
      dayPeriodColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }
        return isDark
            ? AColors.surfaceContainerDark
            : AColors.surfaceContainerLight;
      }),
      dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return colorScheme.onSurfaceVariant;
      }),
      dialBackgroundColor:
          isDark ? AColors.surfaceContainerDark : AColors.surfaceContainerLight,
      dialHandColor: colorScheme.primary,
      dialTextColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return colorScheme.onSurface;
      }),
      dialTextStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      entryModeIconColor: colorScheme.primary,
      helpTextStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurfaceVariant,
        letterSpacing: 0.5,
      ),
      cancelButtonStyle: TextButton.styleFrom(
        foregroundColor: colorScheme.onSurfaceVariant,
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
      confirmButtonStyle: FilledButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
    ),
  );
}

final ThemeData appDarkTheme = _buildTheme(Brightness.dark);
final ThemeData appLightTheme = _buildTheme(Brightness.light);

class AppTheme {
  AppTheme._();
  static ThemeData get lightTheme => appLightTheme;
  static ThemeData get darkTheme => appDarkTheme;
}

/// Formatting helpers following flutter-uiux-design output-widgets specification.
abstract final class Fmt {
  static String currency(BuildContext context, num value, {String? customCurrency}) {
    String curr = customCurrency ?? '';
    if (curr.isEmpty) {
      if (Get.isRegistered<PersistentDataController>()) {
        curr = PersistentDataController.to.currency;
      }
    }
    if (curr.isEmpty) {
      curr = 'USD';
    }

    return NumberFormat.currency(
      locale: Localizations.localeOf(context).toString(),
      name: curr,
      symbol: '$curr ',
      decimalDigits: 2,
    ).format(value);
  }

  static String date(BuildContext context, DateTime date) {
    return DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(date);
  }

  static String time(BuildContext context, DateTime time) {
    return DateFormat.jm(Localizations.localeOf(context).toString()).format(time);
  }

  static String percent(num value) => '${(value * 100).toStringAsFixed(0)}%';
}
