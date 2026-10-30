import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/utils/responsive.dart';
import 'package:pos/core/widgets/app_bottom_action_bar.dart';
import 'package:pos/core/widgets/app_card.dart';
import 'package:pos/core/widgets/app_form_elements.dart';
import 'package:pos/core/widgets/custome_app_bar.dart';
import 'package:pos/core/widgets/error_view.dart';
import 'package:pos/core/widgets/loading_indicator.dart';

import '../controllers/setting_controller.dart';

/// Redesigned Regional & Currency settings screen.
/// - Live format preview showing formatted currency, date, and timezone
/// - Custom dropdowns for System Currency, Timezone, and Date format
/// - Sticky thumb-accessible bottom action bar
/// - Full state coverage: Skeleton loader, Error with retry, pull-to-refresh
class RegionalCurrencyView extends GetView<SettingController> {
  const RegionalCurrencyView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CustomeAppBar(
        title: 'Regional & Currency',
        centerTitle: true,
        showbackArrow: true,
      ),
      bottomNavigationBar: Obx(() {
        if (controller.isLoading.value && controller.shopSettings.value == null) {
          return const SizedBox.shrink();
        }
        return AppBottomActionBar.primaryAction(
          label: 'Save Regional Preferences',
          icon: Iconsax.tick_circle,
          isLoading: controller.isSaving.value,
          onPressed: controller.saveSettings,
        );
      }),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.shopSettings.value == null) {
            return _buildSkeleton(context);
          }

          if (controller.errorMessage.value.isNotEmpty &&
              controller.shopSettings.value == null) {
            return ErrorView(
              message: controller.errorMessage.value,
              onRetry: controller.refreshSettings,
            );
          }

          return RefreshIndicator(
            onRefresh: controller.refreshSettings,
            child: ResponsiveCenter(
              maxWidth: 680,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Explanatory Banner
                    _buildInfoBanner(context),
                    AppSpacing.gapLg,

                    // Live Formats Preview Card
                    _buildLivePreviewCard(context),
                    AppSpacing.gapLg,

                    // Form Section (Rendered directly on surface without wrapping AppCard)
                    // NOTE: If card container wrapping is preferred later, see commented snippet below.
                    /*
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildDropdownField(
                            context: context,
                            label: 'System Currency',
                            rxValue: controller.currency,
                            items: const [
                              'LKR',
                              'USD',
                              'EUR',
                              'GBP',
                              'AUD',
                              'CAD',
                              'SGD',
                            ],
                            hint: 'Select Currency',
                            helperText:
                                'Used for sales, rental rates, deposits, and accounting reports.',
                            isRequired: true,
                          ),
                          AppSpacing.gapLg,
                          buildDropdownField(
                            context: context,
                            label: 'Store Timezone',
                            rxValue: controller.timezone,
                            items: const [
                              'Asia/Colombo',
                              'UTC',
                              'America/New_York',
                              'Europe/London',
                              'Asia/Tokyo',
                              'Australia/Sydney',
                            ],
                            hint: 'Select Timezone',
                            helperText:
                                'All rental duration timers and receipts sync to this timezone.',
                            isRequired: true,
                          ),
                          AppSpacing.gapLg,
                          buildDropdownField(
                            context: context,
                            label: 'Date Display Format',
                            rxValue: controller.dateFormat,
                            items: const [
                              'YYYY-MM-DD',
                              'DD-MM-YYYY',
                              'MM/DD/YYYY',
                              'DD/MM/YYYY',
                            ],
                            hint: 'Select Format',
                            helperText:
                                'Format applied across booking dates, logs, and customer receipts.',
                            isRequired: true,
                          ),
                        ],
                      ),
                    ),
                    */
                    _buildSectionHeader(
                      context,
                      title: 'Regional Configurations',
                      icon: Iconsax.global,
                    ),
                    buildDropdownField(
                      context: context,
                      label: 'System Currency',
                      rxValue: controller.currency,
                      items: const [
                        'LKR',
                        'USD',
                        'EUR',
                        'GBP',
                        'AUD',
                        'CAD',
                        'SGD',
                      ],
                      hint: 'Select Currency',
                      helperText:
                          'Used for sales, rental rates, deposits, and accounting reports.',
                      isRequired: true,
                    ),
                    AppSpacing.gapLg,
                    buildDropdownField(
                      context: context,
                      label: 'Store Timezone',
                      rxValue: controller.timezone,
                      items: const [
                        'Asia/Colombo',
                        'UTC',
                        'America/New_York',
                        'Europe/London',
                        'Asia/Tokyo',
                        'Australia/Sydney',
                      ],
                      hint: 'Select Timezone',
                      helperText:
                          'All rental duration timers and receipts sync to this timezone.',
                      isRequired: true,
                    ),
                    AppSpacing.gapLg,
                    buildDropdownField(
                      context: context,
                      label: 'Date Display Format',
                      rxValue: controller.dateFormat,
                      items: const [
                        'YYYY-MM-DD',
                        'DD-MM-YYYY',
                        'MM/DD/YYYY',
                        'DD/MM/YYYY',
                      ],
                      hint: 'Select Format',
                      helperText:
                          'Format applied across booking dates, logs, and customer receipts.',
                      isRequired: true,
                    ),
                    AppSpacing.gapXxl,
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildInfoBanner(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: AppRadius.smAll,
            ),
            child: Icon(
              Iconsax.global,
              size: 20,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          AppSpacing.gapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Localization & Financial Standards',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Configure standard accounting currency and operational time zones for your storefront operations.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLivePreviewCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppCard(
      backgroundColor: colorScheme.surfaceContainerLowest,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.eye,
                size: 18,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Live Format Preview',
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Obx(() {
            final curr = controller.currency.value.isEmpty
                ? 'LKR'
                : controller.currency.value;
            final tz = controller.timezone.value.isEmpty
                ? 'Asia/Colombo'
                : controller.timezone.value;
            final df = controller.dateFormat.value.isEmpty
                ? 'YYYY-MM-DD'
                : controller.dateFormat.value;

            return Column(
              children: [
                _buildPreviewRow(
                  label: 'Rental Rate Preview',
                  value: '$curr 2,500.00 / hr',
                  icon: Iconsax.money_tick,
                  context: context,
                ),
                const SizedBox(height: 10),
                _buildPreviewRow(
                  label: 'Active Timezone',
                  value: tz,
                  icon: Iconsax.clock,
                  context: context,
                ),
                const SizedBox(height: 10),
                _buildPreviewRow(
                  label: 'Date Display',
                  value: _sampleDateForFormat(df),
                  icon: Iconsax.calendar_1,
                  context: context,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPreviewRow({
    required String label,
    required String value,
    required IconData icon,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            value,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  String _sampleDateForFormat(String format) {
    return switch (format) {
      'DD-MM-YYYY' => '08-10-2026',
      'MM/DD/YYYY' => '10/08/2026',
      'DD/MM/YYYY' => '08/10/2026',
      _ => '2026-10-08',
    };
  }

  // ── Section Header (Styled like CustomerAddView / ShopDetailsView) ─────────
  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm, top: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xxs + 1),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: AppRadius.smAll,
            ),
            child: Icon(icon, size: 14, color: theme.colorScheme.primary),
          ),
          AppSpacing.hGapXs,
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return ResponsiveCenter(
      maxWidth: 680,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonLoader(width: double.infinity, height: 80),
            AppSpacing.gapLg,
            const SkeletonLoader(width: double.infinity, height: 130),
            AppSpacing.gapLg,
            const SkeletonLoader(width: 170, height: 20),
            AppSpacing.gapMd,
            const SkeletonLoader(width: double.infinity, height: 52),
            AppSpacing.gapLg,
            const SkeletonLoader(width: double.infinity, height: 52),
            AppSpacing.gapLg,
            const SkeletonLoader(width: double.infinity, height: 52),
          ],
        ),
      ),
    );
  }
}
