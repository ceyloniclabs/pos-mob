import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../domain/entities/sale_category.dart';

class SaleCategoryCard extends StatelessWidget {
  const SaleCategoryCard({
    super.key,
    required this.category,
    this.onTap,
  });

  final SaleCategory category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Leading Category Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: AppRadius.mdAll,
            ),
            child: Icon(
              Iconsax.category_2,
              size: 22,
              color: theme.colorScheme.primary,
            ),
          ),
          AppSpacing.gapMd,

          // Name and Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  category.name,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  category.description.trim().isNotEmpty
                      ? category.description
                      : 'No description provided',
                  style: textTheme.bodySmall?.copyWith(
                    color: category.description.trim().isNotEmpty
                        ? theme.colorScheme.onSurfaceVariant
                        : theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.6,
                          ),
                    fontStyle: category.description.trim().isNotEmpty
                        ? FontStyle.normal
                        : FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          if (onTap != null)
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
        ],
      ),
    );
  }
}

/// Exact skeleton component matching SaleCategoryCard layout during loading states.
class SaleCategoryCardSkeleton extends StatelessWidget {
  const SaleCategoryCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          const SkeletonLoader(
            width: 44,
            height: 44,
            borderRadius: AppRadius.mdAll,
          ),
          AppSpacing.gapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonLoader(
                  width: 140,
                  height: 16,
                ),
                SizedBox(height: 6),
                SkeletonLoader(
                  width: double.infinity,
                  height: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// List of SaleCategoryCardSkeleton items used during initial fetch / loading.
class SaleCategoryListSkeleton extends StatelessWidget {
  const SaleCategoryListSkeleton({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm),
          child: SaleCategoryCardSkeleton(),
        ),
      ),
    );
  }
}
