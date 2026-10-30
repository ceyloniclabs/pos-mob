import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../domain/entities/sale_sub_category.dart';

class SaleSubCategoryCard extends StatelessWidget {
  const SaleSubCategoryCard({
    super.key,
    required this.subCategory,
    this.onTap,
  });

  final SaleSubCategory subCategory;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final hasCategory = subCategory.saleCategory != null;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Leading Sub-Category Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: AppRadius.mdAll,
            ),
            child: Icon(
              Iconsax.element_3,
              size: 22,
              color: theme.colorScheme.primary,
            ),
          ),
          AppSpacing.gapMd,

          // Name, Parent Category Tag & Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Subcategory Name - full width so long names don't get truncated!
                Text(
                  subCategory.name,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // Parent Category Tag
                if (hasCategory) ...[
                  AppSpacing.vGapXxs,
                  Row(
                    children: [
                      Icon(
                        Iconsax.category_2,
                        size: 13,
                        color: theme.colorScheme.primary,
                      ),
                      AppSpacing.gapXxs,
                      Expanded(
                        child: Text(
                          subCategory.saleCategory!.name,
                          style: textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                // Description if present
                if (subCategory.description.trim().isNotEmpty) ...[
                  AppSpacing.vGapXxs,
                  Text(
                    subCategory.description,
                    style: textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          if (onTap != null) ...[
            AppSpacing.gapXs,
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ],
        ],
      ),
    );
  }
}

/// Exact skeleton component matching SaleSubCategoryCard layout during loading states.
class SaleSubCategoryCardSkeleton extends StatelessWidget {
  const SaleSubCategoryCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              children: [
                const SkeletonLoader(
                  width: double.infinity,
                  height: 16,
                  borderRadius: AppRadius.xsAll,
                ),
                AppSpacing.vGapXxs,
                Row(
                  children: const [
                    SkeletonLoader(
                      width: 13,
                      height: 13,
                      borderRadius: AppRadius.xsAll,
                    ),
                    AppSpacing.gapXxs,
                    SkeletonLoader(
                      width: 140,
                      height: 12,
                      borderRadius: AppRadius.xsAll,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// List of SaleSubCategoryCardSkeleton items used during initial fetch / loading.
class SaleSubCategoryListSkeleton extends StatelessWidget {
  const SaleSubCategoryListSkeleton({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm),
          child: SaleSubCategoryCardSkeleton(),
        ),
      ),
    );
  }
}
