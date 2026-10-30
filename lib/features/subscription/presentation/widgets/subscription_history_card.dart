import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/widgets/app_card.dart';
import '../../domain/entities/subscription_entity.dart';
import '../controllers/subscription_controller.dart';
import 'subscription_detail_sheet.dart';
import 'subscription_status_badge.dart';

class SubscriptionHistoryCard extends StatelessWidget {
  final SubscriptionEntity subscription;
  final SubscriptionController controller;

  const SubscriptionHistoryCard({
    super.key,
    required this.subscription,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppCard(
      onTap: () => SubscriptionDetailSheet.show(context, subscription, controller),
      padding: const EdgeInsets.all(AppSpacing.md),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subscription.planName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      controller.formatCurrency(subscription.amount, subscription.currency),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SubscriptionStatusBadge(
                status: subscription.status,
                isExpired: subscription.isExpired,
              ),
            ],
          ),
          AppSpacing.gapSm,
          Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
          AppSpacing.gapSm,
          Row(
            children: [
              Icon(Iconsax.calendar_1, size: 14, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${controller.formatDate(subscription.startDate)} → ${controller.formatDate(subscription.endDate)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppSpacing.hGapXs,
              if (subscription.paymentMethod != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: AppRadius.xsAll,
                  ),
                  child: Text(
                    subscription.paymentMethod!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
              Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
