import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pos/core/routes/app_pages.dart';
import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/utils/responsive.dart';
import 'package:pos/core/widgets/app_card.dart';
import 'package:pos/core/widgets/custome_app_bar.dart';
import 'package:pos/core/widgets/error_view.dart';
import '../controllers/subscription_controller.dart';
import '../widgets/current_subscription_hero_card.dart';
import '../widgets/subscription_history_card.dart';
import '../widgets/subscription_skeleton.dart';

class SubscriptionView extends GetView<SubscriptionController> {
  const SubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CustomeAppBar(
        title: 'Subscription & License',
        centerTitle: true,
        showbackArrow: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => controller.fetchData(isRefresh: true),
          child: ResponsiveCenter(
            maxWidth: 680,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Obx(() {
                final isLoading = controller.isLoading.value;
                final errorMessage = controller.errorMessage.value;
                final currentData = controller.currentData.value;
                final history = controller.historyList;

                // 1. Initial Loading State (Skeleton)
                if (isLoading && currentData == null) {
                  return const SubscriptionSkeleton();
                }

                // 2. Error State with Retry
                if (errorMessage != null && currentData == null) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                    child: ErrorView(
                      title: 'Unable to load subscription details',
                      message: errorMessage,
                      onRetry: () => controller.fetchData(),
                    ),
                  );
                }

                // 3. Loaded Content
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Card: Current Subscription
                    if (currentData != null)
                      CurrentSubscriptionHeroCard(
                        currentData: currentData,
                        controller: controller,
                      ),

                    AppSpacing.gapLg,

                    // Section Header: History
                    _buildSectionHeader(
                      context,
                      title: 'Subscription History',
                      count: history.length,
                      icon: Iconsax.clock,
                      onViewAll: history.isNotEmpty
                          ? () => Get.toNamed(Routes.SUBSCRIPTION_HISTORY)
                          : null,
                    ),

                    AppSpacing.gapSm,

                    // History List or Empty State
                    if (history.isEmpty)
                      AppCard(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xl,
                          horizontal: AppSpacing.md,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Iconsax.document_text_1,
                                size: 36,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              AppSpacing.gapSm,
                              Text(
                                'No previous subscriptions found',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      ...controller.recentHistoryPreview.map(
                        (sub) => SubscriptionHistoryCard(
                          subscription: sub,
                          controller: controller,
                        ),
                      ),
                      if (history.length > 3) ...[
                        AppSpacing.gapXs,
                        Center(
                          child: TextButton.icon(
                            onPressed: () =>
                                Get.toNamed(Routes.SUBSCRIPTION_HISTORY),
                            icon: const Icon(Iconsax.document_text, size: 16),
                            label: Text(
                              'View all ${history.length} records',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],

                    AppSpacing.gapXxl,
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required int count,
    required IconData icon,
    VoidCallback? onViewAll,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xxs + 1),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: AppRadius.smAll,
          ),
          child: Icon(icon, size: 14, color: colorScheme.primary),
        ),
        AppSpacing.hGapXs,
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
            letterSpacing: -0.2,
          ),
        ),
        if (count > 0) ...[
          AppSpacing.hGapXs,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: AppRadius.fullAll,
            ),
            child: Text(
              '$count',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
        const Spacer(),
        if (onViewAll != null)
          InkWell(
            onTap: onViewAll,
            borderRadius: AppRadius.smAll,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: 2,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View all',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
