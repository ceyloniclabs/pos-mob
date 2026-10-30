import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';

/// Standardized card tile for entity management lists (brands, categories, staff, etc.).
/// Styled according to flutter-uiux-design:
/// - Tonal surface + 1px outlineVariant border.
/// - Minimum touch target (≥ 48dp) for the trailing action.
/// - Clear M3 typography hierarchy.
/// - Uses Material directly with shape and color so ListTile ink splashes render correctly.
class CrudListItemCard extends StatelessWidget {
  final String title;
  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  final Widget? subtitle;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? margin;

  final bool showView;
  final bool showEdit;
  final bool showDelete;

  const CrudListItemCard({
    super.key,
    required this.title,
    this.onView,
    this.onEdit,
    this.onDelete,
    this.subtitle,
    this.contentPadding,
    this.margin,
    this.showView = true,
    this.showEdit = true,
    this.showDelete = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Material(
        color: theme.colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdAll,
          side: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: onView,
          contentPadding: contentPadding ??
              const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
          title: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: subtitle,
          trailing: PopupMenuButton<String>(
            position: PopupMenuPosition.under,
            tooltip: 'Options',
            icon: Icon(
              Icons.more_vert_rounded,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.mdAll,
            ),
            onSelected: (value) {
              if (value == 'view') {
                onView?.call();
              } else if (value == 'edit') {
                onEdit?.call();
              } else if (value == 'delete') {
                onDelete?.call();
              }
            },
            itemBuilder: (context) {
              final items = <PopupMenuEntry<String>>[];
              if (showView && onView != null) {
                items.add(
                  PopupMenuItem(
                    value: 'view',
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Iconsax.eye, size: 18, color: theme.colorScheme.onSurface),
                        AppSpacing.gapSm,
                        Text('View Details', style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                );
              }
              if (showEdit && onEdit != null) {
                items.add(
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Iconsax.edit, size: 18, color: theme.colorScheme.onSurface),
                        AppSpacing.gapSm,
                        Text('Edit Details', style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                );
              }
              if (showDelete && onDelete != null) {
                items.add(
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Iconsax.trash, size: 18, color: theme.colorScheme.error),
                        AppSpacing.gapSm,
                        Text(
                          'Delete',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return items;
            },
          ),
        ),
      ),
    );
  }
}
