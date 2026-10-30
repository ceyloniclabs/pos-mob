import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'package:pos/core/routes/app_pages.dart';
import 'package:pos/core/theme/app_theme.dart';
import 'package:pos/core/theme/theme_controller.dart';
import 'package:pos/core/widgets/app_menu_components.dart';
import 'package:pos/core/widgets/app_version_badge.dart';
import 'package:pos/core/widgets/common_dialog.dart';
import 'package:pos/core/widgets/custome_app_bar.dart';
import 'package:pos/core/access/access_policy.dart';
import 'package:pos/features/auth/presentation/controllers/auth_controller.dart';

class MoreMenuView extends StatelessWidget {
  const MoreMenuView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final role = AuthController.to.user.value?.role;
    bool can(AppPermission permission) => AccessPolicy.allows(role, permission);

    return Scaffold(
      appBar: const CustomeAppBar(
        title: 'More',
        centerTitle: true,
        showbackArrow: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── User profile card ──────────────────────────────────────────
            Obx(() {
              final user = AuthController.to.user.value;
              return AppProfileCard(
                name: user?.name ?? 'User',
                email: user?.email ?? '',
                colorScheme: colorScheme,
                textTheme: textTheme,
              );
            }),

            const SizedBox(height: 20),

            // ── Inventory & Catalog ──────────────────────────────
            if (can(AppPermission.manageSalesCatalog)) ...[
              AppSectionHeader(label: 'Catalog & Inventory', textTheme: textTheme),
              AppMenuGroup(
                children: [
                  AppMenuTile(
                    icon: Iconsax.box,
                    iconColor: const Color(0xFFF59E0B),
                    title: 'Products / Items',
                    onTap: () => Get.toNamed(Routes.SALE_ITEM_LIST),
                  ),
                  AppMenuTile(
                    icon: Iconsax.category_2,
                    iconColor: const Color(0xFF10B981),
                    title: 'Categories',
                    onTap: () => Get.toNamed(Routes.SALE_CATEGORY),
                  ),
                  AppMenuTile(
                    icon: Iconsax.element_3,
                    iconColor: const Color(0xFF14B8A6),
                    title: 'Sub-Categories',
                    onTap: () => Get.toNamed(Routes.SALE_SUB_CATEGORY),
                  ),
                  AppMenuTile(
                    icon: Iconsax.award,
                    iconColor: const Color(0xFFEC4899),
                    title: 'Brands',
                    onTap: () => Get.toNamed(Routes.SALE_BRANDS),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // ── Customers ────────────────────────────────────────
            if (can(AppPermission.registerAndLookupCustomers)) ...[
              AppSectionHeader(label: 'Customers', textTheme: textTheme),
              AppMenuGroup(
                children: [
                  AppMenuTile(
                    icon: Iconsax.people,
                    iconColor: const Color(0xFF0EA5E9),
                    title: 'Customers Directory',
                    onTap: () => Get.toNamed(Routes.CUSTOMER_LIST),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // ── Promotions ─────────────────────────────────────────
            if (can(AppPermission.managePromotions)) ...[
              AppSectionHeader(label: 'Promotions & Discounts', textTheme: textTheme),
              AppMenuGroup(
                children: [
                  AppMenuTile(
                    icon: Iconsax.discount_shape,
                    iconColor: const Color(0xFF10B981),
                    title: 'Promo Codes',
                    onTap: () => Get.toNamed(Routes.PROMO_CODE_LIST),
                  ),
                  AppMenuTile(
                    icon: Iconsax.card_pos,
                    iconColor: const Color(0xFFF59E0B),
                    title: 'Gift Vouchers',
                    onTap: () => Get.toNamed(Routes.GIFT_VOUCHER_LIST),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // ── Reports ───────────────────────────────────────────
            if (can(AppPermission.viewReports)) ...[
              AppSectionHeader(label: 'Reports & Analytics', textTheme: textTheme),
              AppMenuGroup(
                children: [
                  AppMenuTile(
                    icon: Iconsax.document_text,
                    iconColor: const Color(0xFF3B82F6),
                    title: 'Sales & Inventory Reports',
                    onTap: () => Get.toNamed(Routes.REPORT),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // ── Administration ────────────────────────────────────
            if (can(AppPermission.manageShopSettings) ||
                can(AppPermission.manageStaff)) ...[
              AppSectionHeader(label: 'Administration', textTheme: textTheme),
              AppMenuGroup(
                children: [
                  if (can(AppPermission.manageShopSettings))
                    AppMenuTile(
                      icon: Iconsax.building,
                      iconColor: const Color(0xFF8B5CF6),
                      title: 'System Settings',
                      onTap: () => Get.toNamed(Routes.SETTING),
                    ),
                  if (can(AppPermission.manageStaff))
                    AppMenuTile(
                      icon: Iconsax.profile_2user,
                      iconColor: const Color(0xFF6366F1),
                      title: 'Staff Management',
                      onTap: () => Get.toNamed(Routes.STAFF),
                    ),
                  if (can(AppPermission.viewAuditLogs))
                    AppMenuTile(
                      icon: Iconsax.clock,
                      iconColor: const Color(0xFF64748B),
                      title: 'Activity Logs',
                      onTap: () => Get.toNamed(Routes.ACTIVITY_LOGS),
                    ),
                  if (can(AppPermission.viewSubscription))
                    AppMenuTile(
                      icon: Iconsax.crown,
                      iconColor: const Color(0xFFF59E0B),
                      title: 'Subscription & License',
                      onTap: () => Get.toNamed(Routes.SUBSCRIPTION),
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // ── App preferences ────────────────────────────────────────────
            AppSectionHeader(label: 'Preferences', textTheme: textTheme),
            AppMenuGroup(
              children: [
                // Theme toggle tile
                Obx(
                  () => ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.amber.withValues(alpha: 0.12)
                            : Colors.indigo.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        ThemeController.to.isDarkMode
                            ? Iconsax.sun_1
                            : Iconsax.moon,
                        size: 20,
                        color: isDark ? Colors.amber : Colors.indigo,
                      ),
                    ),
                    title: Text(
                      ThemeController.to.isDarkMode
                          ? 'Dark Mode'
                          : 'Light Mode',
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      'Switch app appearance',
                      style: textTheme.bodySmall,
                    ),
                    trailing: Switch(
                      value: ThemeController.to.isDarkMode,
                      onChanged: (_) => ThemeController.to.toggleTheme(),
                      activeThumbColor: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Logout ─────────────────────────────────────────────────────
            AppMenuGroup(
              children: [
                AppMenuTile(
                  icon: Iconsax.logout,
                  iconColor: AppColors.error,
                  title: 'Logout',
                  titleColor: AppColors.error,
                  onTap: () async {
                    final confirm = await CommonDialog.showLogoutDialog();
                    if (confirm) {
                      await AuthController.to.logout();
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── App Info & Version ─────────────────────────────────────────
            const Center(
              child: AppVersionBadge(showIcon: false),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
