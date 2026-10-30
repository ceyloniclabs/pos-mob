import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/custome_app_bar.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/end_of_list_indicator.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/entities/activity_log_entity.dart';
import '../controllers/activity_logs_controller.dart';
import '../widgets/activity_log_card.dart';
import '../widgets/activity_log_skeleton.dart';
import '../widgets/activity_logs_filter_sheet.dart';

class ActivityLogsView extends GetView<ActivityLogsController> {
  const ActivityLogsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: const CustomeAppBar(
        title: 'Activity Logs',
        showbackArrow: true,
        centerTitle: true,
      ),
      body: ResponsiveCenter(
        maxWidth: 720,
        child: Column(
          children: [
            // â”€â”€ Search & Filter Controls â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Obx(() {
                      final hasQuery =
                          controller.searchQuery.value.isNotEmpty;
                      return TextField(
                        controller: controller.searchInputController,
                        decoration: InputDecoration(
                          hintText: 'Search user or action...',
                          prefixIcon: const Icon(
                            Iconsax.search_normal,
                            size: 20,
                          ),
                          suffixIcon: hasQuery
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                  ),
                                  tooltip: 'Clear search',
                                  onPressed: controller.clearSearch,
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                        ),
                        onChanged: (val) {
                          controller.searchQuery.value = val;
                        },
                      );
                    }),
                  ),
                  AppSpacing.hGapSm,
                  // Quick Date Filter
                  Obx(() {
                    final hasDate = controller.startDate.value != null ||
                        controller.endDate.value != null;
                    return Tooltip(
                      message: hasDate
                          ? 'Clear date filter'
                          : 'Filter by date range',
                      child: IconButton.filledTonal(
                        icon: Icon(
                          hasDate
                              ? Icons.close_rounded
                              : Iconsax.calendar,
                          size: 20,
                        ),
                        style: hasDate
                            ? IconButton.styleFrom(
                                backgroundColor: scheme.primaryContainer,
                                foregroundColor: scheme.onPrimaryContainer,
                              )
                            : null,
                        onPressed: () {
                          if (hasDate) {
                            controller.clearDateRange();
                          } else {
                            _selectDateRange(context);
                          }
                        },
                      ),
                    );
                  }),
                  AppSpacing.hGapSm,
                  // Filter Sheet Button matching customer_list_view / sale_item_list_view
                  Obx(() {
                    final count = controller.activeFilterCount;
                    final isFiltered = count > 0;
                    return Badge(
                      isLabelVisible: isFiltered,
                      label: Text('$count'),
                      child: IconButton.filledTonal(
                        icon: const Icon(Icons.filter_list_rounded, size: 22),
                        tooltip: 'Filter Logs',
                        style: isFiltered
                            ? IconButton.styleFrom(
                                backgroundColor: scheme.primaryContainer,
                                foregroundColor: scheme.onPrimaryContainer,
                              )
                            : null,
                        onPressed: () => _showFilterSheet(context),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // â”€â”€ Active Staff Filter Banner â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Obx(() {
              final staff = controller.selectedStaff.value;
              if (staff == null) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 4,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.08),
                  borderRadius: AppRadius.smAll,
                  border: Border.all(color: scheme.primary.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    Icon(Iconsax.user, size: 16, color: scheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Filtered by staff: ${staff.name} (${staff.role.toUpperCase()})',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: controller.clearStaff,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            // â”€â”€ Paginated Activity Logs List â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Expanded(
              child: RefreshIndicator(
                onRefresh: () =>
                    Future.sync(() => controller.pagingController.refresh()),
                child: PagedListView<int, ActivityLogEntity>.separated(
                  pagingController: controller.pagingController,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  separatorBuilder: (_, _) => AppSpacing.vGapSm,
                  builderDelegate:
                      PagedChildBuilderDelegate<ActivityLogEntity>(
                    firstPageProgressIndicatorBuilder: (_) => Column(
                      children: List.generate(
                        6,
                        (_) => const Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.sm),
                          child: ActivityLogSkeleton(),
                        ),
                      ),
                    ),
                    newPageProgressIndicatorBuilder: (_) => const Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    ),
                    firstPageErrorIndicatorBuilder: (ctx) => ErrorView(
                      message: controller.pagingController.error?.toString() ??
                          'Failed to load activity logs',
                      onRetry: () => controller.pagingController.refresh(),
                    ),
                    newPageErrorIndicatorBuilder: (ctx) => Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Center(
                        child: TextButton.icon(
                          onPressed: () =>
                              controller.pagingController.retryLastFailedRequest(),
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          label: const Text('Retry'),
                        ),
                      ),
                    ),
                    noItemsFoundIndicatorBuilder: (ctx) => EmptyView(
                      icon: Iconsax.document_text,
                      title: controller.hasActiveFilters
                          ? 'No Matching Logs'
                          : 'No Activity Logs Yet',
                      message: controller.hasActiveFilters
                          ? 'Try adjusting your filters or search terms.'
                          : 'System activities will appear here in real time as actions occur.',
                    ),
                    noMoreItemsIndicatorBuilder: (ctx) =>
                        const EndOfListIndicator(text: 'â€” End of activity logs â€”'),
                    itemBuilder: (context, log, index) {
                      return ActivityLogCard(log: log);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
      initialDateRange: controller.startDate.value != null &&
              controller.endDate.value != null
          ? DateTimeRange(
              start: controller.startDate.value!,
              end: controller.endDate.value!,
            )
          : null,
    );

    if (picked != null) {
      controller.startDate.value = picked.start;
      controller.endDate.value = picked.end;
      controller.pagingController.refresh();
    }
  }

  void _showFilterSheet(BuildContext context) {
    ActivityLogsFilterSheet.show(context, controller);
  }
}
