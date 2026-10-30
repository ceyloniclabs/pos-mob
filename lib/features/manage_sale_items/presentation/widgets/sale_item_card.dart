import 'package:cached_network_image/cached_network_image.dart';
import 'package:pos/core/utils/app_data_formatter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/routes/app_pages.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../domain/entities/sale_item.dart';

class SaleItemCard extends StatelessWidget {
  const SaleItemCard({
    super.key,
    required this.item,
    this.onTap,
  });

  final SaleItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final semantics = context.semanticColors;

    // Resolve photo url if available
    String? photoUrl;
    if (item.photos.isNotEmpty && item.photos.first.trim().isNotEmpty) {
      final p = item.photos.first.trim();
      photoUrl = p.startsWith('http')
          ? p
          : '${EndPoints.baseUrl.replaceAll('/api/', '')}$p';
    }

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 10),
      onTap: onTap ??
          () => Get.toNamed(Routes.SALE_ITEM_DETAIL, arguments: item),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // â”€â”€ Photo Thumbnail / Fallback Box â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: AppRadius.mdAll,
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: AppRadius.mdAll,
              child: photoUrl != null
                  ? CachedNetworkImage(
                      imageUrl: photoUrl,
                      memCacheWidth: 180,
                      memCacheHeight: 180,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          _buildFallbackIcon(theme),
                    )
                  : _buildFallbackIcon(theme),
            ),
          ),
          AppSpacing.gapSm,

          // â”€â”€ Item Information â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Item Name (Full name, multi-line if needed)
                Text(
                  item.name,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if ((item.categoryName != null &&
                        item.categoryName!.trim().isNotEmpty) ||
                    (item.brandName != null &&
                        item.brandName!.trim().isNotEmpty)) ...[
                  const SizedBox(height: 2),
                  Text(
                    [
                      if (item.categoryName != null &&
                          item.categoryName!.trim().isNotEmpty)
                        item.categoryName!,
                      if (item.brandName != null &&
                          item.brandName!.trim().isNotEmpty)
                        item.brandName!,
                    ].join(' â€¢ '),
                    style: textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                  ),
                ],
                const SizedBox(height: 6),

                // Price and Compact Status Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      AppDataFormatter.formatCurrency(item.sellingPrice),
                      style: textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    _buildCompactStatusBadge(theme, textTheme, semantics),
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.hGapXs,

          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackIcon(ThemeData theme) {
    return Center(
      child: Icon(
        Iconsax.box,
        size: 24,
        color: theme.colorScheme.primary.withValues(alpha: 0.8),
      ),
    );
  }

  Widget _buildCompactStatusBadge(
    ThemeData theme,
    TextTheme textTheme,
    AppSemanticColors semantics,
  ) {
    if (!item.isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: theme.colorScheme.error.withValues(alpha: 0.12),
          borderRadius: AppRadius.smAll,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'Inactive',
              style: textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
    }

    final qty = item.stockQuantity;
    final (Color color, Color bg, String label) = qty <= 0
        ? (
            theme.colorScheme.error,
            theme.colorScheme.error.withValues(alpha: 0.12),
            'Out of Stock',
          )
        : (qty <= 3
            ? (
                semantics.warning,
                semantics.warning.withValues(alpha: 0.14),
                'Stock: $qty',
              )
            : (
                semantics.success,
                semantics.success.withValues(alpha: 0.12),
                'Stock: $qty',
              ));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.smAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
class SaleItemCardSkeleton extends StatelessWidget {
  const SaleItemCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLoader(
            width: 56,
            height: 56,
            borderRadius: AppRadius.mdAll,
          ),
          AppSpacing.gapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Expanded(
                      child: SkeletonLoader(width: double.infinity, height: 16),
                    ),
                    SizedBox(width: 8),
                    SkeletonLoader(
                      width: 54,
                      height: 18,
                      borderRadius: AppRadius.smAll,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const SkeletonLoader(
                  width: 90,
                  height: 14,
                  borderRadius: AppRadius.smAll,
                ),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    Expanded(
                      child: SkeletonLoader(width: double.infinity, height: 16),
                    ),
                    SizedBox(width: 8),
                    SkeletonLoader(width: 54, height: 14),
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.hGapXs,
          const SkeletonLoader(width: 16, height: 16),
        ],
      ),
    );
  }
}

/// List of SaleItemCardSkeleton items used in PagedListView during initial fetch.
class SaleItemListSkeleton extends StatelessWidget {
  const SaleItemListSkeleton({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm),
          child: SaleItemCardSkeleton(),
        ),
      ),
    );
  }
}