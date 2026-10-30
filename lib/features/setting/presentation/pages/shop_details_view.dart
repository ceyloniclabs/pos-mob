import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/utils/responsive.dart';
import 'package:pos/core/widgets/app_bottom_action_bar.dart';
import 'package:pos/core/widgets/app_card.dart';
import 'package:pos/core/widgets/app_form_elements.dart';
import 'package:pos/core/widgets/build_setting_tile.dart';
import 'package:pos/core/widgets/custome_app_bar.dart';
import 'package:pos/core/widgets/error_view.dart';
import 'package:pos/core/widgets/loading_indicator.dart';
import 'package:pos/core/widgets/status_badge.dart';

import '../../domain/validators/shop_setting_validator.dart';
import '../controllers/setting_controller.dart';
import 'full_screen_text_edit_view.dart';
import 'regional_currency_view.dart';
import 'master_data_view.dart';

/// Redesigned Shop Details Screen following senior Flutter UI/UX guidelines.
/// - Storefront Identity branding card with live shop avatar & verified status
/// - Icon-decorated inputs with proper keyboard types and validation
/// - Rich interactive Legal Policy cards with live word count and preview
/// - Shortcuts to related shop configurations (Regional and Rental settings)
/// - Sticky thumb-accessible bottom action bar
/// - Full state coverage: Skeleton loader, Error with retry, loaded form
class ShopDetailsView extends GetView<SettingController> {
  const ShopDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CustomeAppBar(
        title: 'Shop Details',
        centerTitle: true,
        showbackArrow: true,
      ),
      bottomNavigationBar: Obx(() {
        if (controller.isLoading.value && controller.shopSettings.value == null) {
          return const SizedBox.shrink();
        }
        return AppBottomActionBar.primaryAction(
          label: 'Save Changes',
          icon: Iconsax.tick_circle,
          isLoading: controller.isSaving.value,
          onPressed: () {
            if (controller.shopDetailsFormKey.currentState?.validate() ?? false) {
              controller.saveSettings();
            }
          },
        );
      }),
      body: SafeArea(
        child: Obx(() {
          // Loading skeleton state
          if (controller.isLoading.value && controller.shopSettings.value == null) {
            return _buildSkeleton(context);
          }

          // Error state with retry
          if (controller.errorMessage.value.isNotEmpty &&
              controller.shopSettings.value == null) {
            return ErrorView(
              message: controller.errorMessage.value,
              onRetry: controller.refreshSettings,
            );
          }

          // Main form content
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
                child: Form(
                  key: controller.shopDetailsFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Storefront Branding Header Card
                      _buildShopHeaderCard(context),
                      AppSpacing.gapLg,

                      // Section 1: Shop Identity (Directly rendered without wrapping card container)
                      // NOTE: If card container wrapping is preferred later, see commented snippet below.
                      /*
                      AppCard(
                        child: Column(
                          children: [
                            buildTextField(...),
                            AppSpacing.gapMd,
                            buildTextField(...),
                          ],
                        ),
                      ),
                      */
                      // Section 1: Shop Identity (Directly rendered without wrapping card container)
                      // NOTE: If card container wrapping is preferred later, see commented snippet below.
                      /*
                      AppCard(
                        child: Column(
                          children: [
                            buildTextField(...),
                            AppSpacing.gapMd,
                            buildTextField(...),
                          ],
                        ),
                      ),
                      */
                      _buildSectionHeader(
                        context,
                        title: 'Shop Identity',
                        icon: Iconsax.shop,
                      ),
                      buildTextField(
                        label: 'Shop Name',
                        controller: controller.shopNameController,
                        hint: 'e.g. SurfDesk Mirissa',
                        isRequired: true,
                        prefixIcon: Icon(
                          Iconsax.shop,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                        validator: ShopSettingValidator.validateShopName,
                      ),
                      AppSpacing.gapMd,
                      buildTextField(
                        label: 'Official Email',
                        controller: controller.shopEmailController,
                        hint: 'e.g. contact@surfdesk.com',
                        keyboardType: TextInputType.emailAddress,
                        isRequired: true,
                        prefixIcon: Icon(
                          Iconsax.sms,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                        validator: ShopSettingValidator.validateEmail,
                      ),
                      AppSpacing.gapLg,

                      // Section 2: Contact & Location (Directly rendered without wrapping card container)
                      /*
                      AppCard(
                        child: Column(
                          children: [
                            buildTextField(...),
                            AppSpacing.gapMd,
                            buildTextField(...),
                          ],
                        ),
                      ),
                      */
                      _buildSectionHeader(
                        context,
                        title: 'Contact & Location',
                        icon: Iconsax.location,
                      ),
                      buildTextField(
                        label: 'Direct Contact Number',
                        controller: controller.shopContactController,
                        hint: '+94 77 123 4567',
                        keyboardType: TextInputType.phone,
                        isRequired: true,
                        prefixIcon: Icon(
                          Iconsax.call,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                        validator: ShopSettingValidator.validatePhone,
                      ),
                      AppSpacing.gapMd,
                      buildTextField(
                        label: 'Physical Store Address',
                        controller: controller.shopLocationController,
                        hint: 'Weligama Beach Road, Southern Province, Sri Lanka',
                        maxLines: 2,
                        isRequired: true,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: Icon(
                            Iconsax.location,
                            size: 20,
                            color: colorScheme.primary,
                          ),
                        ),
                        validator: ShopSettingValidator.validateLocation,
                      ),
                      AppSpacing.gapLg,

                      // Section 3: Legal & Rental Policies
                      _buildSectionHeader(
                        context,
                        title: 'Customer & Legal Policies',
                        icon: Iconsax.shield_tick,
                      ),
                      Text(
                        'These documents appear on customer rental agreements, digital waivers, and printed receipts.',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      AppSpacing.gapSm,

                      // Privacy Policy Interactive Card
                      Obx(() => _buildPolicyCard(
                            context: context,
                            title: 'Privacy Policy',
                            subtitle:
                                'Customer personal data handling, safety records, and liability info.',
                            icon: Iconsax.shield_tick,
                            wordCount: controller.privacyPolicyWordCount.value,
                            textSnippet: controller.privacyPolicyController.text,
                            onTap: () {
                              Get.to(() => FullScreenTextEditView(
                                    title: 'Privacy Policy',
                                    controller:
                                        controller.privacyPolicyController,
                                    hint:
                                        'Enter customer data privacy policy...',
                                  ));
                            },
                          )),
                      AppSpacing.gapMd,

                      // Terms & Conditions Interactive Card
                      Obx(() => _buildPolicyCard(
                            context: context,
                            title: 'Terms & Conditions',
                            subtitle:
                                'Rental equipment safety rules, return grace rules, and damage liability.',
                            icon: Iconsax.document_text,
                            wordCount: controller.termsConditionsWordCount.value,
                            textSnippet: controller.termsConditionsController.text,
                            onTap: () {
                              Get.to(() => FullScreenTextEditView(
                                    title: 'Terms & Conditions',
                                    controller:
                                        controller.termsConditionsController,
                                    hint:
                                        'Enter rental terms, liability, and condition details...',
                                  ));
                            },
                          )),
                      AppSpacing.gapLg,

                      // Section 4: Related Shop Configurations
                      _buildSectionHeader(
                        context,
                        title: 'Related Shop Configurations',
                        icon: Iconsax.setting_2,
                      ),
                      AppCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            buildSettingTile(
                              title: 'Regional & Currency',
                              subtitle:
                                  'Manage timezone (${controller.timezone.value}) and shop currency (${controller.currency.value}).',
                              leadingIcon: Iconsax.global,
                              onTap: () {
                                Get.to(() => const RegionalCurrencyView());
                              },
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
                      AppSpacing.gapXxl,
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Section Header (Styled like CustomerAddView with icon badge) ───────────
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

  /// Storefront Branding Card displaying dynamic initials and store identity
  Widget _buildShopHeaderCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppCard(
      backgroundColor: colorScheme.surfaceContainerLow,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // Dynamic Avatar
          Obx(() {
            final name = controller.currentShopName.value.trim();
            final initial = name.isNotEmpty ? name[0].toUpperCase() : 'S';

            return Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: AppRadius.mdAll,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  initial,
                  style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
          AppSpacing.gapMd,
          // Shop Title and Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    controller.currentShopName.value.isEmpty
                        ? 'Shop Storefront'
                        : controller.currentShopName.value,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Surf Rental & Equipment Center',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                const Row(
                  children: [
                    StatusBadge(
                      label: 'Active Storefront',
                      type: StatusType.success,
                      icon: Icons.storefront_rounded,
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

  /// Policy document summary card with live word count and preview
  Widget _buildPolicyCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required int wordCount,
    required String textSnippet,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isConfigured = wordCount > 0;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isConfigured
                      ? colorScheme.primaryContainer.withValues(alpha: 0.6)
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: AppRadius.smAll,
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isConfigured
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              AppSpacing.gapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              AppSpacing.gapSm,
              StatusBadge(
                label: isConfigured ? '$wordCount words' : 'Not set',
                type: isConfigured ? StatusType.info : StatusType.warning,
                icon: isConfigured ? Iconsax.document_1 : Iconsax.warning_2,
              ),
            ],
          ),
          if (isConfigured && textSnippet.trim().isNotEmpty) ...[
            const Divider(height: 20),
            Text(
              textSnippet.trim().replaceAll('\n', ' '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          AppSpacing.gapSm,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Edit Document',
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: colorScheme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Shimmer / skeleton placeholder layout during initial load
  Widget _buildSkeleton(BuildContext context) {
    return ResponsiveCenter(
      maxWidth: 680,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card skeleton
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: AppRadius.mdAll,
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: const Row(
                children: [
                  SkeletonLoader(width: 58, height: 58, borderRadius: AppRadius.mdAll),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonLoader(width: 140, height: 18),
                        SizedBox(height: 8),
                        SkeletonLoader(width: 180, height: 12),
                        SizedBox(height: 8),
                        SkeletonLoader(width: 90, height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.gapLg,

            // Section 1 skeleton
            const Row(
              children: [
                SkeletonLoader(width: 22, height: 22, borderRadius: AppRadius.smAll),
                SizedBox(width: 8),
                SkeletonLoader(width: 110, height: 16),
              ],
            ),
            AppSpacing.gapSm,
            const SkeletonLoader(width: double.infinity, height: 50),
            AppSpacing.gapMd,
            const SkeletonLoader(width: double.infinity, height: 50),
            AppSpacing.gapLg,

            // Section 2 skeleton
            const Row(
              children: [
                SkeletonLoader(width: 22, height: 22, borderRadius: AppRadius.smAll),
                SizedBox(width: 8),
                SkeletonLoader(width: 130, height: 16),
              ],
            ),
            AppSpacing.gapSm,
            const SkeletonLoader(width: double.infinity, height: 50),
            AppSpacing.gapMd,
            const SkeletonLoader(width: double.infinity, height: 70),
            AppSpacing.gapLg,

            // Policy skeletons
            const Row(
              children: [
                SkeletonLoader(width: 22, height: 22, borderRadius: AppRadius.smAll),
                SizedBox(width: 8),
                SkeletonLoader(width: 150, height: 16),
              ],
            ),
            AppSpacing.gapSm,
            const SkeletonLoader(width: double.infinity, height: 100),
            AppSpacing.gapMd,
            const SkeletonLoader(width: double.infinity, height: 100),
          ],
        ),
      ),
    );
  }
}
