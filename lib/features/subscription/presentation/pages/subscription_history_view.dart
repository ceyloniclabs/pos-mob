import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/utils/responsive.dart';
import 'package:pos/core/widgets/custome_app_bar.dart';
import 'package:pos/core/widgets/error_view.dart';
import '../controllers/subscription_controller.dart';
import '../widgets/subscription_history_card.dart';
import '../widgets/subscription_skeleton.dart';

class SubscriptionHistoryView extends GetView<SubscriptionController> {
  const SubscriptionHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CustomeAppBar(
        title: 'Subscription History',
        centerTitle: true,
        showbackArrow: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => controller.fetchData(isRefresh: true),
          child: ResponsiveCenter(
            maxWidth: 680,
            child: Obx(() {
              final isLoading = controller.isLoading.value;
              final errorMessage = controller.errorMessage.value;
              final allHistory = controller.historyList;
              final filtered = controller.filteredHistoryList;
              final selectedFilter = controller.selectedHistoryFilter.value;

              // 1. Loading State
              if (isLoading && allHistory.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: SubscriptionSkeleton(),
                );
              }

              // 2. Error State
              if (errorMessage != null && allHistory.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: ErrorView(
                      title: 'Unable to load history',
                      message: errorMessage,
                      onRetry: () => controller.fetchData(),
                    ),
                  ),
                );
              }

              // 3. Loaded State with Filter Bar
              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Filter Chips Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.sm,
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip(
                              context,
                              label: 'All',
                              count: allHistory.length,
                              filterKey: 'all',
                              isSelected: selectedFilter == 'all',
                            ),
                            AppSpacing.hGapXs,
                            _buildFilterChip(
                              context,
                              label: 'Active',
                              count: allHistory.where((s) => s.isActive && !s.isExpired).length,
                              filterKey: 'active',
                              isSelected: selectedFilter == 'active',
                            ),
                            AppSpacing.hGapXs,
                            _buildFilterChip(
                              context,
                              label: 'Upcoming',
                              count: allHistory.where((s) => s.isUpcoming).length,
                              filterKey: 'upcoming',
                              isSelected: selectedFilter == 'upcoming',
                            ),
                            AppSpacing.hGapXs,
                            _buildFilterChip(
                              context,
                              label: 'Expired',
                              count: allHistory.where((s) => s.isStatusExpired).length,
                              filterKey: 'expired',
                              isSelected: selectedFilter == 'expired',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // History Items List or Empty View
                  if (filtered.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Iconsax.document_text_1,
                                  size: 32,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              AppSpacing.gapMd,
                              Text(
                                'No subscriptions found',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                selectedFilter == 'all'
                                    ? 'No subscription records available yet.'
                                    : 'No subscriptions matching "$selectedFilter" status.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.xs,
                        AppSpacing.md,
                        AppSpacing.xl,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => SubscriptionHistoryCard(
                            subscription: filtered[index],
                            controller: controller,
                          ),
                          childCount: filtered.length,
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required int count,
    required String filterKey,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FilterChip(
      selected: isSelected,
      label: Text(count > 0 ? '$label ($count)' : label),
      labelStyle: theme.textTheme.labelMedium?.copyWith(
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
      ),
      selectedColor: colorScheme.primary,
      backgroundColor: colorScheme.surfaceContainerLow,
      side: BorderSide(
        color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
      ),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.fullAll),
      onSelected: (_) => controller.setHistoryFilter(filterKey),
    );
  }
}
