import 'package:flutter/material.dart';

/// Semantic colors theme extension supporting dynamic Light/Dark mode.
/// Ensures consistent success, warning, info, and repair colors adhering to WCAG contrast standards.
/// Defined according to .agent/skills/flutter-uiux-design/references/design-tokens-and-theme.md
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color info;
  final Color onInfo;
  final Color repair;
  final Color onRepair;

  // Icon semantic brand tokens (used across menus and status representations)
  final Color iconSky;
  final Color iconViolet;
  final Color iconIndigo;
  final Color iconPink;
  final Color iconAmber;
  final Color iconEmerald;
  final Color iconTeal;
  final Color iconRed;

  const AppSemanticColors({
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.info,
    required this.onInfo,
    required this.repair,
    required this.onRepair,
    required this.iconSky,
    required this.iconViolet,
    required this.iconIndigo,
    required this.iconPink,
    required this.iconAmber,
    required this.iconEmerald,
    required this.iconTeal,
    required this.iconRed,
  });

  static const light = AppSemanticColors(
    success: Color(0xFF15803D), // Green 700
    onSuccess: Colors.white,
    warning: Color(0xFFB45309), // Amber 700
    onWarning: Colors.white,
    info: Color(0xFF2563EB),    // Blue 600
    onInfo: Colors.white,
    repair: Color(0xFFD97706),  // Amber 600
    onRepair: Colors.white,
    iconSky: Color(0xFF0EA5E9),
    iconViolet: Color(0xFF8B5CF6),
    iconIndigo: Color(0xFF6366F1),
    iconPink: Color(0xFFEC4899),
    iconAmber: Color(0xFFF59E0B),
    iconEmerald: Color(0xFF10B981),
    iconTeal: Color(0xFF14B8A6),
    iconRed: Color(0xFFEF4444),
  );

  static const dark = AppSemanticColors(
    success: Color(0xFF4ADE80), // Green 400
    onSuccess: Color(0xFF052E16),
    warning: Color(0xFFFBBF24), // Amber 400
    onWarning: Color(0xFF451A03),
    info: Color(0xFF60A5FA),    // Blue 400
    onInfo: Color(0xFF172554),
    repair: Color(0xFFFFC107),  // Amber
    onRepair: Color(0xFF332000),
    iconSky: Color(0xFF38BDF8),
    iconViolet: Color(0xFFA78BFA),
    iconIndigo: Color(0xFF818CF8),
    iconPink: Color(0xFFF472B6),
    iconAmber: Color(0xFFFBBF24),
    iconEmerald: Color(0xFF34D399),
    iconTeal: Color(0xFF2DD4BF),
    iconRed: Color(0xFFF87171),
  );

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? info,
    Color? onInfo,
    Color? repair,
    Color? onRepair,
    Color? iconSky,
    Color? iconViolet,
    Color? iconIndigo,
    Color? iconPink,
    Color? iconAmber,
    Color? iconEmerald,
    Color? iconTeal,
    Color? iconRed,
  }) {
    return AppSemanticColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      repair: repair ?? this.repair,
      onRepair: onRepair ?? this.onRepair,
      iconSky: iconSky ?? this.iconSky,
      iconViolet: iconViolet ?? this.iconViolet,
      iconIndigo: iconIndigo ?? this.iconIndigo,
      iconPink: iconPink ?? this.iconPink,
      iconAmber: iconAmber ?? this.iconAmber,
      iconEmerald: iconEmerald ?? this.iconEmerald,
      iconTeal: iconTeal ?? this.iconTeal,
      iconRed: iconRed ?? this.iconRed,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t) ?? success,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t) ?? onSuccess,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      onWarning: Color.lerp(onWarning, other.onWarning, t) ?? onWarning,
      info: Color.lerp(info, other.info, t) ?? info,
      onInfo: Color.lerp(onInfo, other.onInfo, t) ?? onInfo,
      repair: Color.lerp(repair, other.repair, t) ?? repair,
      onRepair: Color.lerp(onRepair, other.onRepair, t) ?? onRepair,
      iconSky: Color.lerp(iconSky, other.iconSky, t) ?? iconSky,
      iconViolet: Color.lerp(iconViolet, other.iconViolet, t) ?? iconViolet,
      iconIndigo: Color.lerp(iconIndigo, other.iconIndigo, t) ?? iconIndigo,
      iconPink: Color.lerp(iconPink, other.iconPink, t) ?? iconPink,
      iconAmber: Color.lerp(iconAmber, other.iconAmber, t) ?? iconAmber,
      iconEmerald: Color.lerp(iconEmerald, other.iconEmerald, t) ?? iconEmerald,
      iconTeal: Color.lerp(iconTeal, other.iconTeal, t) ?? iconTeal,
      iconRed: Color.lerp(iconRed, other.iconRed, t) ?? iconRed,
    );
  }
}

/// Helper extension on BuildContext to quickly access semantic colors.
extension AppSemanticColorsContext on BuildContext {
  AppSemanticColors get semanticColors =>
      Theme.of(this).extension<AppSemanticColors>() ?? AppSemanticColors.light;
}
