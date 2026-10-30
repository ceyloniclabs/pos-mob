import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pos/core/theme/app_radius.dart';

/// Centralized dialog and confirmation modal utility providing cohesive, modern,
/// and beautifully styled dialogs & bottom sheets across the surf-mobapp application.
/// 
/// Strictly adheres to Material 3 tokens, active theme color schemes, and senior UI/UX guidelines.
class CommonDialog {
  CommonDialog._();

  /// Exit confirmation dialog confirming user intent before closing the application.
  /// Shows clean, simple dialog conforming strictly to the app's theme colors.
  static Future<bool> showExitDialog() async {
    final context = Get.context;
    if (context == null) return false;

    final result = await showConfirmationDialog(
      title: 'Exit App',
      message: 'Are you sure you want to exit the application?',
      confirmLabel: 'Exit',
      cancelLabel: 'Cancel',
      isDestructive: true,
      onConfirm: () {
        SystemNavigator.pop();
      },
    );

    return result;
  }

  /// Logout confirmation dialog with clear destructive action styling
  /// adhering to the active theme colors and Material 3 design standards.
  static Future<bool> showLogoutDialog() async {
    final context = Get.context;
    if (context == null) return false;

    final result = await showConfirmationDialog(
      title: 'Log Out',
      message: 'Are you sure you want to log out of your account?',
      confirmLabel: 'Log Out',
      cancelLabel: 'Cancel',
      isDestructive: true,
    );

    return result;
  }

  /// Modern confirmation bottom sheet styled strictly using the app's theme tokens.
  /// Designed for mobile ergonomic thumb-reachability and high-polish feel.
  static Future<bool?> showConfirmationBottomSheet({
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
    IconData? icon,
    Color? iconColor,
    VoidCallback? onConfirm,
    bool isDismissible = true,
  }) async {
    HapticFeedback.lightImpact();

    return await Get.bottomSheet<bool>(
      _AppConfirmationBottomSheet(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
        icon: icon ?? (isDestructive ? Iconsax.logout : Iconsax.info_circle),
        iconColor: iconColor,
        onConfirm: onConfirm,
      ),
      isDismissible: isDismissible,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  /// Success dialog (e.g., Payment Successful, Operation Completed)
  /// Featuring a modern glowing emerald badge and a single confirmation action.
  static Future<void> showSuccessDialog({
    required String title,
    required String message,
    String buttonText = 'Done',
    VoidCallback? onConfirm,
    bool barrierDismissible = false,
  }) async {
    final context = Get.context;
    if (context == null) return;

    final theme = Theme.of(context);

    await _showBaseDialog<void>(
      icon: Iconsax.tick_circle,
      iconColor: theme.colorScheme.primary,
      title: title,
      message: message,
      confirmLabel: buttonText,
      isSingleAction: true,
      onConfirm: onConfirm,
      barrierDismissible: barrierDismissible,
    );
  }

  /// General confirmation dialog for generic or destructive prompts.
  static Future<bool> showConfirmationDialog({
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
    IconData? icon,
    Color? iconColor,
    VoidCallback? onConfirm,
    bool barrierDismissible = true,
  }) async {
    final context = Get.context;
    if (context == null) return false;

    final theme = Theme.of(context);
    final fallbackColor = isDestructive ? theme.colorScheme.error : theme.colorScheme.primary;

    final result = await _showBaseDialog<bool>(
      icon: icon,
      iconColor: iconColor ?? fallbackColor,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      isDestructive: isDestructive,
      onConfirm: onConfirm,
      barrierDismissible: barrierDismissible,
    );

    return result ?? false;
  }

  /// Internal builder for the unified dialog structure
  static Future<T?> _showBaseDialog<T>({
    IconData? icon,
    Color? iconColor,
    required String title,
    required String message,
    required String confirmLabel,
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
    bool isSingleAction = false,
    VoidCallback? onConfirm,
    bool barrierDismissible = true,
  }) async {
    HapticFeedback.lightImpact();

    return await Get.dialog<T>(
      _AppCustomDialog(
        icon: icon,
        iconColor: iconColor,
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
        isSingleAction: isSingleAction,
        onConfirm: onConfirm,
      ),
      barrierDismissible: barrierDismissible,
    );
  }
}

/// Modern confirmation bottom sheet widget built strictly with theme tokens.
class _AppConfirmationBottomSheet extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onConfirm;

  const _AppConfirmationBottomSheet({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.isDestructive,
    required this.icon,
    this.iconColor,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectiveColor = iconColor ??
        (isDestructive ? colorScheme.error : colorScheme.primary);
    final effectiveOnColor =
        isDestructive ? colorScheme.onError : colorScheme.onPrimary;

    return Center(
      heightFactor: 1.0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: AppRadius.sheetTop,
            border: Border(
              top: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Drag Handle ──
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant,
                      borderRadius: AppRadius.fullAll,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Glowing Icon Container ──
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: effectiveColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: effectiveColor.withValues(alpha: 0.25),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        size: 28,
                        color: effectiveColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Title ──
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Message ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Action Buttons ──
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            side: BorderSide(
                              color: colorScheme.outlineVariant,
                              width: 1.2,
                            ),
                            shape: const RoundedRectangleBorder(
                              borderRadius: AppRadius.mdAll,
                            ),
                            foregroundColor: colorScheme.onSurface,
                          ),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Get.back(result: false);
                          },
                          child: Text(
                            cancelLabel,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            backgroundColor: effectiveColor,
                            foregroundColor: effectiveOnColor,
                            elevation: 0,
                            shape: const RoundedRectangleBorder(
                              borderRadius: AppRadius.mdAll,
                            ),
                          ),
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            Get.back(result: true);
                            onConfirm?.call();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(icon, size: 18),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  confirmLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Clean, classic Material confirmation dialog modeled after standard Android/Material design,
/// strictly adhering to active theme tokens (light & dark).
class _AppCustomDialog extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;
  final bool isSingleAction;
  final VoidCallback? onConfirm;

  const _AppCustomDialog({
    this.icon,
    this.iconColor,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    this.isDestructive = false,
    this.isSingleAction = false,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final confirmColor =
        isDestructive ? colorScheme.error : colorScheme.primary;

    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF182C30) : Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lgAll,
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      actionsAlignment: MainAxisAlignment.end,
      title: icon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: iconColor ?? colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            )
          : Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
                letterSpacing: -0.2,
              ),
            ),
      content: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontSize: 14,
          color: colorScheme.onSurfaceVariant,
          height: 1.45,
        ),
      ),
      actions: [
        if (!isSingleAction)
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Get.back(result: false);
            },
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: const Size(60, 36),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.smAll,
              ),
            ),
            child: Text(
              cancelLabel.toUpperCase(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: colorScheme.primary,
              ),
            ),
          ),
        TextButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            Get.back(result: true);
            onConfirm?.call();
          },
          style: TextButton.styleFrom(
            foregroundColor: confirmColor,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            minimumSize: const Size(60, 36),
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.smAll,
            ),
          ),
          child: Text(
            confirmLabel.toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: confirmColor,
            ),
          ),
        ),
      ],
    );
  }
}

