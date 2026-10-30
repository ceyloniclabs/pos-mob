import 'package:pos/core/utils/app_data_formatter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/routes/app_pages.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/sale.dart';

class SaleCard extends StatelessWidget {
  const SaleCard({
    super.key,
    required this.sale,
    this.onTap,
  });

  final Sale sale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final formattedDate =
        AppDataFormatter.formatDateTimeDisplay(sale.saleDate, pattern: 'yyyy-MM-dd', fallback: 'N/A');
    final customerName = (sale.customer?.name != null && sale.customer!.name.trim().isNotEmpty)
        ? sale.customer!.name
        : 'Walk-in Customer';
    final isWalkIn = sale.customer == null || (sale.customer?.name.trim().isEmpty ?? true);
    final isCard = sale.paymentMethod.trim().toLowerCase() == 'card';
    final hasCardRef = sale.transactionId != null && sale.transactionId!.trim().isNotEmpty;
    final totalQty = sale.saleItemEntries.fold<int>(0, (sum, e) => sum + e.quantity);
    final displayQty = totalQty > 0 ? totalQty : sale.saleItemEntries.length;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: onTap ??
          () => Get.toNamed(Routes.SALE_DETAILS, arguments: sale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Row: Icon, Transaction ID + Date, StatusBadge ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Receipt Avatar / Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    isCard ? Iconsax.card : Iconsax.receipt_2,
                    size: 22,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              AppSpacing.gapMd,

              // Sale ID & Date & Card Ref
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sale #${sale.id}',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSpacing.vGapXxs,
                    Row(
                      children: [
                        Icon(
                          Iconsax.calendar_1,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        AppSpacing.gapXxs,
                        Expanded(
                          child: Text(
                            formattedDate,
                            style: textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (isCard) ...[
                      AppSpacing.vGapXxs,
                      Row(
                        children: [
                          Icon(
                            Iconsax.card,
                            size: 13,
                            color: hasCardRef
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline,
                          ),
                          AppSpacing.gapXxs,
                          Expanded(
                            child: Text(
                              hasCardRef
                                  ? 'Ref: ${sale.transactionId}'
                                  : 'Card (No Ref)',
                              style: textTheme.bodySmall?.copyWith(
                                color: hasCardRef
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant,
                                fontWeight: hasCardRef
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Status Badge
              StatusBadge.fromStatus(sale.saleStatus),
            ],
          ),
          AppSpacing.gapSm,

          // ── Divider line ──
          Divider(
            height: 1,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
          AppSpacing.gapSm,

          // ── Bottom Details: Customer & Amount Row ──
          Row(
            children: [
              // Customer
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      isWalkIn ? Iconsax.user : Iconsax.user_tick,
                      size: 15,
                      color: isWalkIn
                          ? theme.colorScheme.onSurfaceVariant
                          : theme.colorScheme.primary,
                    ),
                    AppSpacing.gapXxs,
                    Expanded(
                      child: Text(
                        customerName,
                        style: textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          fontStyle: isWalkIn ? FontStyle.italic : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.gapSm,

              // Amount
              Text(
                AppDataFormatter.formatCurrency(sale.totalAmount),
                style: textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              AppSpacing.gapXxs,

              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          AppSpacing.vGapXs,

          // ── Badges / Pills Wrap (Zero overflow) ──
          Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Items pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: AppRadius.smAll,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Iconsax.box,
                      size: 11,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '$displayQty ${displayQty == 1 ? 'item' : 'items'}',
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Payment method / Card Ref pill
              if (isCard)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: hasCardRef
                        ? theme.colorScheme.primary.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.12),
                    borderRadius: AppRadius.smAll,
                    border: Border.all(
                      color: hasCardRef
                          ? theme.colorScheme.primary.withValues(alpha: 0.3)
                          : Colors.orange.withValues(alpha: 0.4),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Iconsax.card,
                        size: 11,
                        color: hasCardRef ? theme.colorScheme.primary : Colors.orange.shade800,
                      ),
                      const SizedBox(width: 3),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 140),
                        child: Text(
                          hasCardRef ? 'Ref: ${sale.transactionId}' : 'Card (No Ref)',
                          style: textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                            color: hasCardRef ? theme.colorScheme.primary : Colors.orange.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )
              else if (sale.paymentMethod.trim().toLowerCase() == 'cash')
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: AppRadius.smAll,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Iconsax.money,
                        size: 11,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'Cash',
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              // Gift Voucher pill
              if (sale.giftVoucherAmount > 0 || sale.giftVoucher != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.12),
                    borderRadius: AppRadius.smAll,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.card_giftcard_rounded,
                        size: 11,
                        color: Colors.purple.shade700,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        sale.giftVoucher?.code ?? 'Voucher',
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          color: Colors.purple.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              // Promo Code pill
              if (sale.promoCode != null && sale.promoCode!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.12),
                    borderRadius: AppRadius.smAll,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.discount_outlined,
                        size: 11,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        sale.promoCode!,
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Exact skeleton component matching SaleCard layout during loading states.
class SaleCardSkeleton extends StatelessWidget {
  const SaleCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Row: Icon, ID + Date, Badge ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SkeletonLoader(
                width: 44,
                height: 44,
                borderRadius: AppRadius.fullAll,
              ),
              AppSpacing.gapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonLoader(width: 120, height: 16),
                    AppSpacing.vGapXxs,
                    const SkeletonLoader(width: 85, height: 12),
                  ],
                ),
              ),
              const SkeletonLoader(
                width: 64,
                height: 22,
                borderRadius: AppRadius.smAll,
              ),
            ],
          ),
          AppSpacing.gapSm,

          // ── Divider ──
          Divider(
            height: 1,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
          AppSpacing.gapSm,

          // ── Bottom Details: Customer & Amount Row ──
          Row(
            children: const [
              Expanded(
                child: SkeletonLoader(width: double.infinity, height: 14),
              ),
              AppSpacing.gapSm,
              SkeletonLoader(width: 80, height: 16),
              AppSpacing.gapXxs,
              SkeletonLoader(width: 16, height: 16),
            ],
          ),
          AppSpacing.vGapXs,

          // ── Badges Skeleton Row ──
          Row(
            children: const [
              SkeletonLoader(
                width: 52,
                height: 18,
                borderRadius: AppRadius.smAll,
              ),
              AppSpacing.gapXs,
              SkeletonLoader(
                width: 68,
                height: 18,
                borderRadius: AppRadius.smAll,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// List of SaleCardSkeleton items used in PagedListView.
class SaleListSkeleton extends StatelessWidget {
  const SaleListSkeleton({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm),
          child: SaleCardSkeleton(),
        ),
      ),
    );
  }
}
