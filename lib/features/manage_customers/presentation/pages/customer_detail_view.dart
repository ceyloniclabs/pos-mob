import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:pos/core/constants/api_endpoints.dart';
import 'package:pos/core/enums.dart';
import 'package:pos/core/routes/app_pages.dart';
import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/utils/responsive.dart';
import 'package:pos/core/utils/scaffold_message_utils.dart';
import 'package:pos/core/widgets/custome_app_bar.dart';
import 'package:pos/core/widgets/entity_qr_dialog.dart';
import 'package:pos/features/manage_customers/presentation/controllers/customer_detail_controller.dart';
import 'package:pos/features/manage_customers/presentation/controllers/customer_list_controller.dart';
import 'package:pos/features/manage_customers/presentation/widgets/customer_info_tab.dart';

import 'package:pos/features/manage_customers/presentation/widgets/customer_sales_tab.dart';

class CustomerDetailView extends GetView<CustomerDetailController> {
  const CustomerDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Obx(() {
      if (controller.isLoading.value || !controller.hasCustomer) {
        return const Scaffold(
          appBar: CustomeAppBar(
            title: 'Customer Details',
            centerTitle: true,
            showbackArrow: true,
          ),
          body: Center(child: CircularProgressIndicator.adaptive()),
        );
      }

      return Scaffold(
        appBar: CustomeAppBar(
          title: 'Customer Details',
          centerTitle: true,
          showbackArrow: true,
          actions: [
            if (controller.customer.id != null)
              EntityQrActionButton(
                table: 'customers',
                id: controller.customer.id!,
                title: '${controller.customer.name} QR',
              ),
            // IconButton(
            //   icon: const Icon(Iconsax.edit_2, size: 20),
            //   tooltip: 'Edit Customer',
            //   onPressed: () => _editCustomer(context),
            // ),
            const SizedBox(width: 4),
          ],
        ),
        body: SafeArea(
          bottom: false,
          child: ResponsiveCenter(
            maxWidth: 720,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: Obx(
                      () => _buildCustomerHeader(context, theme, textTheme),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverTabBarDelegate(
                      TabBar(
                        controller: controller.tabController,
                        indicatorColor: theme.colorScheme.primary,
                        indicatorWeight: 3,
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: theme.colorScheme.primary,
                        unselectedLabelColor:
                            theme.colorScheme.onSurfaceVariant,
                        labelStyle: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                        unselectedLabelStyle: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 13.5,
                        ),
                        tabs: const [
                          Tab(
                            icon: Icon(Iconsax.info_circle, size: 18),
                            text: 'Information',
                            iconMargin: EdgeInsets.only(bottom: 2),
                          ),
                          Tab(
                            icon: Icon(Iconsax.shopping_bag, size: 18),
                            text: 'Sales',
                            iconMargin: EdgeInsets.only(bottom: 2),
                          ),
                        ],
                      ),
                      backgroundColor: theme.colorScheme.surface,
                      bottomBorderColor: theme.colorScheme.outlineVariant
                          .withValues(alpha: 0.5),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: controller.tabController,
                children: const [
                  CustomerInfoTab(),
                  CustomerSalesTab(),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  // ── Customer Profile Header Card ──────────────────────────────────────────
  Widget _buildCustomerHeader(
    BuildContext context,
    ThemeData theme,
    TextTheme textTheme,
  ) {
    final customer = controller.customer;

    ImageProvider? imageProvider;
    if (customer.profilePhoto != null && customer.profilePhoto!.isNotEmpty) {
      final photo = customer.profilePhoto!;
      final url = photo.startsWith('http')
          ? photo
          : '${EndPoints.baseUrl.replaceAll('/api/', '')}$photo';
      imageProvider = NetworkImage(url);
    }

    final initial = customer.name.isNotEmpty
        ? customer.name[0].toUpperCase()
        : '?';

    // Tier color
    Color tierColor;
    switch (customer.membershipLevel.toLowerCase()) {
      case 'silver':
        tierColor = const Color(0xFF94A3B8);
        break;
      case 'gold':
        tierColor = const Color(0xFFEAB308);
        break;
      case 'platinum':
        tierColor = const Color(0xFFA855F7);
        break;
      case 'bronze':
      default:
        tierColor = const Color(0xFFCD7F32);
        break;
    }

    final isLocal =
        customer.customerType.toLowerCase() == CustomerType.local.value;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: AppRadius.lgAll,
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.7),
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            // Row with Avatar, Name, Badges
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar with outline
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.25),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    backgroundImage: imageProvider,
                    onBackgroundImageError: imageProvider != null
                        ? (error, stackTrace) {}
                        : null,
                    child: imageProvider == null
                        ? Text(
                            initial,
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                          )
                        : null,
                  ),
                ),
                AppSpacing.hGapMd,
                // Name & Badges
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppSpacing.vGapXxs,
                      // Badges wrap
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          // Membership badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: tierColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: tierColor.withValues(alpha: 0.4),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: tierColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  customer.membershipLevel.capitalizeFirst ??
                                      customer.membershipLevel,
                                  style: textTheme.labelSmall?.copyWith(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: tierColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Customer Type badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: theme.colorScheme.outlineVariant
                                    .withValues(alpha: 0.6),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isLocal ? Iconsax.location : Iconsax.global,
                                  size: 11,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isLocal
                                      ? 'Local (NIC)'
                                      : 'Foreigner (Passport)',
                                  style: textTheme.labelSmall?.copyWith(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.vGapXxs,
                      // Quick phone caption
                      Text(
                        customer.phone,
                        style: textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            AppSpacing.gapMd,
            // Quick Actions Bar
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: AppRadius.mdAll,
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _HeaderActionButton(
                      icon: Iconsax.call,
                      label: 'Call',
                      onTap: () => _callCustomer(context),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 24,
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.4,
                    ),
                  ),
                  Expanded(
                    child: _HeaderActionButton(
                      icon: Iconsax.messages_2,
                      label: 'SMS',
                      onTap: () => _sendSms(context),
                    ),
                  ),
                  if (customer.email.isNotEmpty) ...[
                    Container(
                      width: 1,
                      height: 24,
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.4,
                      ),
                    ),
                    Expanded(
                      child: _HeaderActionButton(
                        icon: Iconsax.sms,
                        label: 'Email',
                        onTap: () => _sendEmail(context),
                      ),
                    ),
                  ],
                  Container(
                    width: 1,
                    height: 24,
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.4,
                    ),
                  ),
                  Expanded(
                    child: _HeaderActionButton(
                      icon: Iconsax.edit_2,
                      label: 'Edit',
                      onTap: () => _editCustomer(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────
  Future<void> _callCustomer(BuildContext context) async {
    final phone = controller.customer.phone.replaceAll(RegExp(r'\s+'), '');
    if (phone.isEmpty) {
      ScaffoldMessageUtils.showError('No phone number available.');
      return;
    }

    final uri = Uri.parse('tel:$phone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessageUtils.showInfo('Dialer unavailable: $phone');
      }
    } catch (_) {
      ScaffoldMessageUtils.showInfo('Dialer unavailable: $phone');
    }
  }

  Future<void> _sendSms(BuildContext context) async {
    final phone = controller.customer.phone.replaceAll(RegExp(r'\s+'), '');
    if (phone.isEmpty) {
      ScaffoldMessageUtils.showError('No phone number available.');
      return;
    }

    final uri = Uri.parse('sms:$phone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessageUtils.showInfo('SMS client unavailable: $phone');
      }
    } catch (_) {
      ScaffoldMessageUtils.showInfo('SMS client unavailable: $phone');
    }
  }

  Future<void> _sendEmail(BuildContext context) async {
    final email = controller.customer.email.trim();
    if (email.isEmpty) {
      ScaffoldMessageUtils.showError('No email address available.');
      return;
    }

    final uri = Uri.parse('mailto:$email');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessageUtils.showInfo('Email client unavailable: $email');
      }
    } catch (_) {
      ScaffoldMessageUtils.showInfo('Email client unavailable: $email');
    }
  }

  Future<void> _editCustomer(BuildContext context) async {
    final result = await Get.toNamed(
      Routes.CUSTOMER_EDIT,
      arguments: controller.customer,
    );
    if (result == true) {
      // Refresh list if registered
      if (Get.isRegistered<CustomerListController>()) {
        Get.find<CustomerListController>().pagingController.refresh();
      }
    }
  }
}

// ── Header Action Button ─────────────────────────────────────────────────────
class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.smAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(height: 3),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sliver Persistent TabBar Delegate ────────────────────────────────────────
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate(
    this.tabBar, {
    required this.backgroundColor,
    required this.bottomBorderColor,
  });

  final TabBar tabBar;
  final Color backgroundColor;
  final Color bottomBorderColor;

  @override
  double get minExtent => tabBar.preferredSize.height + 1;

  @override
  double get maxExtent => tabBar.preferredSize.height + 1;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: backgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          tabBar,
          Divider(height: 1, thickness: 1, color: bottomBorderColor),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
