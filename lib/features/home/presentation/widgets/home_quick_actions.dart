import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/routes/app_pages.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = context.semanticColors;

    final actions = [
      _QuickActionItem(
        icon: Iconsax.shop,
        label: 'Quick Sale',
        color: theme.colorScheme.primary,
        isPrimary: true,
        onTap: () => Get.toNamed(Routes.SALE_ADD),
      ),
      _QuickActionItem(
        icon: Iconsax.scan_barcode,
        label: 'Scan Item',
        color: semantics.success,
        isPrimary: false,
        onTap: () => Get.toNamed(Routes.SALE_QR_SCANNER),
      ),
      _QuickActionItem(
        icon: Iconsax.box_add,
        label: 'New Product',
        color: semantics.info,
        isPrimary: false,
        onTap: () => Get.toNamed(Routes.SALE_ITEM_ADD),
      ),
      _QuickActionItem(
        icon: Iconsax.user_add,
        label: 'Add Customer',
        color: semantics.warning,
        isPrimary: false,
        onTap: () => Get.toNamed(Routes.CUSTOMER_ADD),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 480;
        final crossAxisCount = isCompact ? 2 : actions.length;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: isCompact ? 2.3 : 1.15,
          ),
          itemBuilder: (context, index) {
            final item = actions[index];
            return _QuickActionButton(
              item: item,
              isCompact: isCompact,
            );
          },
        );
      },
    );
  }
}

class _QuickActionItem {
  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.isPrimary,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool isPrimary;
  final VoidCallback onTap;
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.item,
    required this.isCompact,
  });

  final _QuickActionItem item;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: AppRadius.mdAll,
        child: Ink(
          decoration: BoxDecoration(
            color: item.isPrimary
                ? item.color
                : (isDark
                    ? theme.colorScheme.surfaceContainerHighest
                    : item.color.withValues(alpha: 0.08)),
            borderRadius: AppRadius.mdAll,
            border: item.isPrimary
                ? null
                : Border.all(
                    color: item.color.withValues(alpha: 0.2),
                    width: 1,
                  ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? AppSpacing.md : AppSpacing.sm,
              vertical: isCompact ? AppSpacing.sm : AppSpacing.md,
            ),
            child: isCompact
                ? Row(
                    children: [
                      Icon(
                        item.icon,
                        color: item.isPrimary ? Colors.white : item.color,
                        size: 22,
                      ),
                      AppSpacing.gapSm,
                      Expanded(
                        child: Text(
                          item.label,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: item.isPrimary
                                ? Colors.white
                                : theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.icon,
                        color: item.isPrimary ? Colors.white : item.color,
                        size: 26,
                      ),
                      AppSpacing.gapXs,
                      Text(
                        item.label,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: item.isPrimary
                              ? Colors.white
                              : theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
