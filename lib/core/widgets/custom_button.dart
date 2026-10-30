import 'package:flutter/material.dart';
import 'package:pos/core/theme/app_durations.dart';
import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';

enum AppButtonType {
  primary,
  secondary,
  tertiary,
  destructive,
}

/// Unified, accessible button conforming to Material 3 and flutter-uiux-design skill.
/// - Guarantees minimum touch targets (≥ 48dp).
/// - Loading state disables button without causing layout jump.
/// - Clear hierarchy with filled, outlined, text, and destructive variants.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final IconData? icon;
  final bool isLoading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = onPressed != null && !isLoading;
    final VoidCallback? handler = enabled ? onPressed : null;

    final child = AnimatedSwitcher(
      duration: AppDurations.fast,
      child: isLoading
          ? SizedBox(
              key: const ValueKey('loading'),
              height: 20,
              width: 20,
              child: CircularProgressIndicator.adaptive(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  type == AppButtonType.primary || type == AppButtonType.destructive
                      ? scheme.onPrimary
                      : scheme.primary,
                ),
              ),
            )
          : Row(
              key: const ValueKey('label'),
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  AppSpacing.gapXs,
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
    );

    final Widget button = switch (type) {
      AppButtonType.primary => FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          ),
          onPressed: handler,
          child: child,
        ),
      AppButtonType.secondary => OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
            side: BorderSide(color: scheme.outlineVariant),
          ),
          onPressed: handler,
          child: child,
        ),
      AppButtonType.tertiary => TextButton(
          style: TextButton.styleFrom(
            minimumSize: const Size(48, 48),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          ),
          onPressed: handler,
          child: child,
        ),
      AppButtonType.destructive => FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          ),
          onPressed: handler,
          child: child,
        ),
    };

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: expand ? SizedBox(width: double.infinity, child: button) : button,
    );
  }
}
