import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pos/core/access/access_policy.dart';
import 'package:pos/core/routes/app_pages.dart';
import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/utils/responsive.dart';
import 'package:pos/core/widgets/app_card.dart';
import 'package:pos/core/widgets/build_setting_tile.dart';
import 'package:pos/core/widgets/custome_app_bar.dart';
import 'package:pos/features/auth/presentation/controllers/auth_controller.dart';

import '../controllers/setting_controller.dart';
import 'master_data_view.dart';
import 'regional_currency_view.dart';
import 'shop_details_view.dart';

/// System Settings screen for POS retail management.
class SettingView extends GetView<SettingController> {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CustomeAppBar(
        title: 'System Settings',
        centerTitle: true,
        showbackArrow: true,
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 680,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overview Banner Card
                _buildOverviewBanner(context),
                AppSpacing.gapLg,

                // Section 1: General Configurations
                _buildSectionHeader(
                  context,
                  title: 'Store Configurations',
                  icon: Iconsax.setting_2,
                ),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      buildSettingTile(
                        title: 'Shop Details',
                        subtitle:
                            'Manage shop storefront, contact channels, and receipt header info.',
                        leadingIcon: Iconsax.shop,
                        onTap: () {
                          controller.refreshSettings();
                          Get.to(() => const ShopDetailsView());
                        },
                      ),
                      Divider(
                        height: 1,
                        color: colorScheme.outlineVariant,
                      ),
                      Obx(
                        () => buildSettingTile(
                          title: 'Regional & Currency',
                          subtitle:
                              'Configure timezone, system currency (${controller.currency.value}), and date format.',
                          leadingIcon: Iconsax.global,
                          onTap: () {
                            controller.refreshSettings();
                            Get.to(() => const RegionalCurrencyView());
                          },
                        ),
                      ),
                      Divider(
                        height: 1,
                        color: colorScheme.outlineVariant,
                      ),
                      buildSettingTile(
                        title: 'Catalog Master Data',
                        subtitle:
                            'Manage product categories, subcategories, and brands.',
                        leadingIcon: Iconsax.category,
                        onTap: () {
                          Get.to(() => const MasterDataView());
                        },
                      ),
                    ],
                  ),
                ),
                AppSpacing.gapLg,

                // Section: Subscription & License (Admin Only)
                if (AccessPolicy.allows(
                  AuthController.to.user.value?.role,
                  AppPermission.viewSubscription,
                )) ...[
                  _buildSectionHeader(
                    context,
                    title: 'Subscription & License',
                    icon: Iconsax.crown_1,
                  ),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: buildSettingTile(
                      title: 'Subscription & Plan',
                      subtitle:
                          'View active license, validity, remaining days, and billing history.',
                      leadingIcon: Iconsax.shield_tick,
                      onTap: () {
                        Get.toNamed(Routes.SUBSCRIPTION);
                      },
                    ),
                  ),
                  AppSpacing.gapLg,
                ],

                // Section 2: Team & Access
                _buildSectionHeader(
                  context,
                  title: 'Team & Staff Access',
                  icon: Iconsax.people,
                ),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: buildSettingTile(
                    title: 'Staff Access Control',
                    subtitle:
                        'Manage cashier permissions, roles, and staff accounts.',
                    leadingIcon: Iconsax.user_octagon,
                    onTap: () {
                      Get.toNamed(Routes.STAFF);
                    },
                  ),
                ),
                AppSpacing.gapLg,

                // Section 3: Reports & Analytics
                _buildSectionHeader(
                  context,
                  title: 'Reports & Analytics',
                  icon: Iconsax.chart_21,
                ),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: buildSettingTile(
                    title: 'System Reports',
                    subtitle:
                        'Generate and review sales transactions and inventory reports.',
                    leadingIcon: Iconsax.document_text,
                    onTap: () {
                      Get.toNamed(Routes.REPORT);
                    },
                  ),
                ),
                AppSpacing.gapLg,
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Overview Banner ────────────────────────────────────────────────────────
  Widget _buildOverviewBanner(BuildContext context) {
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: AppRadius.smAll,
            ),
            child: Icon(
              Iconsax.setting_4,
              size: 22,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          AppSpacing.gapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'POS Platform Configurations',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage your storefront identity, receipts, tax, currency defaults, and cashier staff permissions.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Header ─────────────────────────────────────────────────────────
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
}
