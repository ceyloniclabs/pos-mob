import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_semantic_colors.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/widgets/app_card.dart';
import '../../domain/entities/current_subscription_data_entity.dart';
import '../controllers/subscription_controller.dart';
import 'subscription_status_badge.dart';

class CurrentSubscriptionHeroCard extends StatelessWidget {
  final CurrentSubscriptionDataEntity currentData;
  final SubscriptionController controller;

  const CurrentSubscriptionHeroCard({
    super.key,
    required this.currentData,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final semantics = context.semanticColors;

    final sub = currentData.subscription;
    final isExpired = currentData.isExpired || (sub?.isExpired ?? false);
    final daysRemaining = currentData.daysRemaining;
    final isExpiringSoon = !isExpired && daysRemaining > 0 && daysRemaining <= 14;

    if (sub == null) {
      return AppCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.crown_1,
                  size: 32,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              AppSpacing.gapMd,
              Text(
                'No Active Subscription',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'There is currently no active license attached to your shop.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Expiry Warning Banner (if expired or expiring soon) ──────────────
        if (isExpired) ...[
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm + 2),
            decoration: BoxDecoration(
              color: colorScheme.error.withValues(alpha: 0.1),
              borderRadius: AppRadius.mdAll,
              border: Border.all(
                color: colorScheme.error.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Iconsax.danger, color: colorScheme.error, size: 20),
                AppSpacing.hGapSm,
                Expanded(
                  child: Text(
                    'Your subscription has expired. Please contact support to renew your license.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.gapMd,
        ] else if (isExpiringSoon) ...[
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm + 2),
            decoration: BoxDecoration(
              color: semantics.warning.withValues(alpha: 0.1),
              borderRadius: AppRadius.mdAll,
              border: Border.all(
                color: semantics.warning.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Iconsax.info_circle, color: semantics.warning, size: 20),
                AppSpacing.hGapSm,
                Expanded(
                  child: Text(
                    'Your plan expires in $daysRemaining days. Renew early to maintain uninterrupted access.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: semantics.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.gapMd,
        ],

        // ── Hero Subscription Card ───────────────────────────────────────────
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Banner Section
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.08),
                      colorScheme.surfaceContainerLow,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.12),
                            borderRadius: AppRadius.smAll,
                          ),
                          child: Icon(
                            Iconsax.crown_1,
                            size: 24,
                            color: colorScheme.primary,
                          ),
                        ),
                        AppSpacing.hGapMd,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sub.planName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                controller.formatCurrency(sub.amount, sub.currency),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SubscriptionStatusBadge(
                          status: sub.status,
                          isExpired: isExpired,
                        ),
                      ],
                    ),
                    AppSpacing.gapMd,

                    // Days Remaining Pill & Countdown
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: isExpired
                            ? colorScheme.error.withValues(alpha: 0.08)
                            : (isExpiringSoon
                                ? semantics.warning.withValues(alpha: 0.08)
                                : colorScheme.primary.withValues(alpha: 0.08)),
                        borderRadius: AppRadius.smAll,
                        border: Border.all(
                          color: isExpired
                              ? colorScheme.error.withValues(alpha: 0.2)
                              : (isExpiringSoon
                                  ? semantics.warning.withValues(alpha: 0.2)
                                  : colorScheme.primary.withValues(alpha: 0.2)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isExpired ? Iconsax.timer_pause : Iconsax.timer_1,
                            size: 16,
                            color: isExpired
                                ? colorScheme.error
                                : (isExpiringSoon
                                    ? semantics.warning
                                    : colorScheme.primary),
                          ),
                          AppSpacing.hGapXs,
                          Expanded(
                            child: Text(
                              isExpired
                                  ? 'License Expired'
                                  : '$daysRemaining days remaining',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isExpired
                                    ? colorScheme.error
                                    : (isExpiringSoon
                                        ? semantics.warning
                                        : colorScheme.primary),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          AppSpacing.hGapSm,
                          Text(
                            'Expiry: ${controller.formatDate(currentData.systemExpiresAt ?? sub.endDate)}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Details Body Grid
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    _buildDetailRow(
                      context,
                      label: 'System Access Cut-off',
                      value: controller.formatDateTime(currentData.systemExpiresAt),
                      icon: Iconsax.calendar_tick,
                    ),
                    Divider(height: 18, color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
                    _buildDetailRow(
                      context,
                      label: 'Valid Period',
                      value:
                          '${controller.formatDate(sub.startDate)} → ${controller.formatDate(sub.endDate)}',
                      icon: Iconsax.calendar_1,
                    ),
                    Divider(height: 18, color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
                    _buildDetailRow(
                      context,
                      label: 'Payment Method',
                      value: sub.paymentMethod ?? 'N/A',
                      icon: Iconsax.card_pos,
                      extra: sub.paymentReference != null && sub.paymentReference!.isNotEmpty
                          ? 'Ref: ${sub.paymentReference}'
                          : null,
                    ),
                    Divider(height: 18, color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
                    _buildDetailRow(
                      context,
                      label: 'Activated By',
                      value: sub.creator?.name ?? 'Admin',
                      icon: Iconsax.user_octagon,
                      extra: sub.creator?.email,
                    ),
                    if (sub.notes != null && sub.notes!.isNotEmpty) ...[
                      Divider(height: 18, color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
                      _buildDetailRow(
                        context,
                        label: 'Notes',
                        value: sub.notes!,
                        icon: Iconsax.note_text,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    String? extra,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
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
        AppSpacing.hGapSm,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                textAlign: TextAlign.end,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (extra != null && extra.isNotEmpty)
                Text(
                  extra,
                  textAlign: TextAlign.end,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
