import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import 'app_floating_bottom_sheet.dart';
import 'custom_button.dart';

/// A standardized, reusable Filter Bottom Sheet conforming to Material 3 & flutter-uiux-design guidelines.
///
/// Features:
/// - Docked bottom sheet attached to screen bottom by default ([isFloating] = false) or floating ([isFloating] = true).
/// - Interactive drag handle for drag-to-expand / drag-to-dismiss.
/// - Standardized header with leading icon / gradient, title, subtitle, live active filter count badge, and close button.
/// - Scrollable content body with clamping physics.
/// - Standardized pinned footer with "Reset" and "Apply" / "Generate" buttons with reactive loading spinner.
/// - Responsive max-width constraint for tablet/foldable viewports.
/// - Full keyboard awareness and system navigation bar / safe-area handling.
class AppFilterBottomSheet extends StatelessWidget {
  const AppFilterBottomSheet({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.activeFilterCount = 0,
    this.onReset,
    this.onApply,
    this.resetLabel = 'Reset',
    this.applyLabel = 'Apply Filters',
    this.applyIcon = Icons.check_rounded,
    this.isLoading = false,
    this.isFloating = false,
    this.showCloseButton = true,
    this.showDragHandle = true,
    this.maxHeightFactor = 0.90,
    this.maxWidth = 600.0,
    this.contentPadding,
    this.customFooter,
    required this.child,
  });

  /// Sheet title.
  final String title;

  /// Optional descriptive subtitle.
  final String? subtitle;

  /// Optional leading widget (e.g. icon container or gradient badge).
  final Widget? leading;

  /// Number of currently active/customized filters.
  /// When greater than 0, displays an active count badge in the header and enables the Reset button.
  final int activeFilterCount;

  /// Callback when Reset is tapped.
  final VoidCallback? onReset;

  /// Callback when Apply / CTA is tapped.
  final VoidCallback? onApply;

  /// Text label for the reset button. Default is 'Reset'.
  final String resetLabel;

  /// Text label for the primary apply button. Default is 'Apply Filters'.
  final String applyLabel;

  /// Icon on the primary apply button.
  final IconData? applyIcon;

  /// Whether the primary action is currently processing/loading.
  final bool isLoading;

  /// Whether the sheet docks to the bottom edge ([isFloating] = false) or floats as a card ([isFloating] = true).
  /// Defaults to `false` for standard docked bottom sheet presentation.
  final bool isFloating;

  /// Whether to display the close button in the header. Default is `true`.
  final bool showCloseButton;

  /// Whether to display the top drag handle. Default is `true`.
  final bool showDragHandle;

  /// Maximum height fraction of available screen height. Default is `0.90`.
  final double maxHeightFactor;

  /// Maximum horizontal constraint for tablet/desktop responsiveness. Default is `600.0`.
  final double maxWidth;

  /// Padding around the scrollable [child].
  final EdgeInsetsGeometry? contentPadding;

  /// Optional custom footer widget replacing the standard Reset + Apply bar.
  final Widget? customFooter;

  /// The scrollable filter controls and sections.
  final Widget child;

  /// Convenience modal launcher for standard filter bottom sheets.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      isDismissible: isDismissible,
      enableDrag: false,
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasActiveFilters = activeFilterCount > 0;

    final Widget? trailingBadge = hasActiveFilters
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
              borderRadius: AppRadius.fullAll,
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  '$activeFilterCount active',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        : null;

    final Widget footer = customFooter ??
        Row(
          children: [
            Expanded(
              flex: 2,
              child: OutlinedButton.icon(
                onPressed:
                    (!isLoading && hasActiveFilters && onReset != null)
                        ? onReset
                        : null,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.mdAll,
                  ),
                  side: BorderSide(
                    color: (hasActiveFilters && onReset != null)
                        ? theme.colorScheme.outlineVariant
                        : theme.colorScheme.outlineVariant
                            .withValues(alpha: 0.3),
                  ),
                ),
                icon: const Icon(Iconsax.rotate_left, size: 16),
                label: Text(
                  resetLabel,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            AppSpacing.gapSm,
            Expanded(
              flex: 3,
              child: AppButton(
                label: applyLabel,
                icon: applyIcon,
                isLoading: isLoading,
                onPressed: isLoading ? null : onApply,
              ),
            ),
          ],
        );

    return AppFloatingBottomSheet(
      isFloating: isFloating,
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: trailingBadge,
      showCloseButton: showCloseButton,
      showDragHandle: showDragHandle,
      maxHeightFactor: maxHeightFactor,
      maxWidth: maxWidth,
      contentPadding: contentPadding,
      footer: footer,
      child: child,
    );
  }
}
