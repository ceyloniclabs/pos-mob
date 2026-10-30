import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';
import '../../domain/entities/subscription_entity.dart';
import '../controllers/subscription_controller.dart';
import 'subscription_status_badge.dart';

class SubscriptionDetailSheet extends StatelessWidget {
  final SubscriptionEntity subscription;
  final SubscriptionController controller;

  const SubscriptionDetailSheet({
    super.key,
    required this.subscription,
    required this.controller,
  });

  static void show(
    BuildContext context,
    SubscriptionEntity subscription,
    SubscriptionController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SubscriptionDetailSheet(
        subscription: subscription,
        controller: controller,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: AppRadius.fullAll,
                ),
              ),
            ),

            // Sheet Title & Status
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subscription.planName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          controller.formatCurrency(
                            subscription.amount,
                            subscription.currency,
                          ),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
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
            ),

            const SizedBox(height: AppSpacing.md),
            Divider(height: 1, color: colorScheme.outlineVariant),

            // Scrollable Details List
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Column(
                  children: [
                    _buildItem(
                      context,
                      'Subscription ID',
                      '#${subscription.id}',
                      Iconsax.hashtag,
                    ),
                    _buildItem(
                      context,
                      'Validity',
                      '${controller.formatDate(subscription.startDate)} → ${controller.formatDate(subscription.endDate)}',
                      Iconsax.calendar_1,
                    ),
                    _buildItem(
                      context,
                      'Payment Date',
                      controller.formatDate(subscription.paymentDate),
                      Iconsax.calendar_tick,
                    ),
                    _buildItem(
                      context,
                      'Payment Method',
                      subscription.paymentMethod ?? 'N/A',
                      Iconsax.card_pos,
                    ),
                    if (subscription.paymentReference != null &&
                        subscription.paymentReference!.isNotEmpty)
                      _buildItem(
                        context,
                        'Reference',
                        subscription.paymentReference!,
                        Iconsax.receipt_2,
                      ),
                    if (subscription.creator != null)
                      _buildItem(
                        context,
                        'Processed By',
                        '${subscription.creator!.name} (${subscription.creator!.email})',
                        Iconsax.user_octagon,
                      ),
                    if (subscription.notes != null && subscription.notes!.isNotEmpty)
                      _buildItem(
                        context,
                        'Notes',
                        subscription.notes!,
                        Iconsax.note_text,
                      ),
                    if (subscription.createdAt != null)
                      _buildItem(
                        context,
                        'Created At',
                        controller.formatDateTime(subscription.createdAt),
                        Iconsax.clock,
                      ),
                  ],
                ),
              ),
            ),

            // Close Button
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xs,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: FilledButton.tonal(
                onPressed: () => Get.back(),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
          AppSpacing.hGapSm,
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          AppSpacing.hGapMd,
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
