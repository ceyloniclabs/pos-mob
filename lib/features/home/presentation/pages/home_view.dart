import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/routes/app_pages.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/error_view.dart';
import '../controllers/home_controller.dart';
import '../widgets/home_header.dart';
import '../widgets/home_quick_actions.dart';
import '../widgets/home_skeleton.dart';
import '../widgets/home_stat_card.dart';
import '../widgets/recent_activity_list.dart';
import '../widgets/today_overview_banner.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../main/presentation/controllers/main_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = context.semanticColors;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.fetchDashboardStats,
          child: ResponsiveCenter(
            maxWidth: 800,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top Header ─────────────────────────────────────────────
                  const HomeHeader(),
                  AppSpacing.gapLg,

                  // ── Reactive Body States ───────────────────────────────────
                  Obx(() {
                    final data = controller.dashboardData.value;
                    final isLoading = controller.isLoading.value;
                    final errorMessage = controller.errorMessage.value;

                    // 1. Initial Loading State (Skeleton)
                    if (isLoading && data == null) {
                      return const HomeDashboardSkeleton();
                    }

                    // 2. Full Error State (with Retry)
                    if (errorMessage != null && data == null) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xxl,
                        ),
                        child: ErrorView(
                          title: 'Unable to load dashboard',
                          message: errorMessage,
                          onRetry: controller.fetchDashboardStats,
                        ),
                      );
                    }

                    // 3. Loaded Dashboard Content
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Today's Overview Banner ──────────────────────────
                        const TodayOverviewBanner(),
                        AppSpacing.gapLg,

                        // ── Quick Stats Grid ─────────────────────────────────
                        const SectionHeader(
                          title: 'Quick Stats',
                          padding: EdgeInsets.zero,
                        ),
                        AppSpacing.gapSm,
                        Row(
                          children: [
                            Expanded(
                              child: HomeStatCard(
                                label: "Today's Sales",
                                value: data?.todaysSales.toString() ?? '0',
                                icon: Iconsax.shopping_cart,
                                accentColor: semantics.success,
                                onTap: _navigateToSalesTab,
                              ),
                            ),
                            AppSpacing.gapSm,
                            Expanded(
                              child: HomeStatCard(
                                label: 'Orders Completed',
                                value: data?.todaysSales.toString() ?? '0',
                                icon: Iconsax.receipt_item,
                                accentColor: theme.colorScheme.primary,
                                onTap: _navigateToSalesTab,
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.gapSm,
                        Row(
                          children: [
                            Expanded(
                              child: HomeStatCard(
                                label: 'Customers',
                                value: data?.customers.toString() ?? '0',
                                icon: Iconsax.people,
                                accentColor: semantics.info,
                                onTap: () => Get.toNamed(Routes.CUSTOMER_LIST),
                              ),
                            ),
                            AppSpacing.gapSm,
                            Expanded(
                              child: HomeStatCard(
                                label: 'Products',
                                value: 'Catalog',
                                icon: Iconsax.box,
                                accentColor: semantics.warning,
                                onTap: () => Get.toNamed(Routes.SALE_ITEM_LIST),
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.gapXl,

                        // ── Quick Actions ────────────────────────────────────
                        const SectionHeader(
                          title: 'Quick Actions',
                          padding: EdgeInsets.zero,
                        ),
                        AppSpacing.gapSm,
                        const HomeQuickActions(),
                        AppSpacing.gapXl,

                        // ── Recent Activity ──────────────────────────────────
                        () {
                          final role = AuthController.to.user.value?.role;
                          final isAdmin = role == 'admin';
                          return RecentActivityList(
                            activities: data?.recentActivity ?? const [],
                            recentLogs: isAdmin ? controller.recentLogs : null,
                            isLoadingLogs: controller.isLoadingRecentLogs.value,
                          );
                        }(),
                        AppSpacing.gapXl,
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToSalesTab() {
    if (Get.isRegistered<MainController>()) {
      Get.find<MainController>().changePage(2);
    } else {
      Get.toNamed(Routes.SALE);
    }
  }
}
