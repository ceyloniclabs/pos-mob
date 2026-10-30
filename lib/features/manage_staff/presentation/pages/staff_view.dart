import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pos/core/enums.dart';
import 'package:pos/core/routes/app_pages.dart';
import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/utils/responsive.dart';
import 'package:pos/core/widgets/app_card.dart';
import 'package:pos/core/widgets/app_floating_bottom_sheet.dart';
import 'package:pos/core/widgets/confirm_delete_dialog.dart';
import 'package:pos/core/widgets/custome_app_bar.dart';
import 'package:pos/core/widgets/empty_view.dart';
import 'package:pos/core/widgets/end_of_list_indicator.dart';
import 'package:pos/core/widgets/loading_indicator.dart';
import 'package:pos/core/widgets/status_badge.dart';

import '../../domain/entities/staff.dart';
import '../controllers/staff_controller.dart';

/// Redesigned Staff Directory Screen conforming to Material 3 guidelines and project UI/UX standards.
/// - Live search with debounce and clear action
/// - Clean filter icon button with badge indicator matching CustomerListView
/// - Modern floating filter bottom sheet matching CustomerFilterSheet
/// - Zero-overflow responsive Wrap for badges
/// - Standard '+' AppBar action (no floating action button)
/// - Full state coverage: Skeleton loader, EmptyView with CTA, Pull-to-refresh
class StaffView extends GetView<StaffController> {
  const StaffView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomeAppBar(
        title: 'Staff Directory',
        centerTitle: true,
        showbackArrow: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Staff Member',
            onPressed: () {
              controller.initForm();
              Get.toNamed(Routes.STAFF_ADD);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          controller.initForm();
          await Get.toNamed(Routes.STAFF_ADD);
          controller.fetchStaff();
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Staff'),
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 680,
          child: Column(
            children: [
              // ── Search & Filter Controls ─────────────────────────────
              _buildSearchAndFilterHeader(context),

              // ── Quick Summary Metrics Strip ─────────────────────────
              _buildSummaryMetrics(context),

              // ── Staff Members Directory List ────────────────────────
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => controller.pagingController.refresh(),
                  child: PagedListView<int, Staff>(
                    pagingController: controller.pagingController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.xs,
                      AppSpacing.md,
                      80,
                    ),
                    builderDelegate: PagedChildBuilderDelegate<Staff>(
                      firstPageProgressIndicatorBuilder: (_) =>
                          const StaffListSkeleton(itemCount: 6),
                      newPageProgressIndicatorBuilder: (_) => const Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: Center(
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      ),
                      noItemsFoundIndicatorBuilder: (context) {
                        final hasFilterOrSearch =
                            controller.searchQuery.value.isNotEmpty ||
                            controller.selectedRole.value != StaffRole.all ||
                            controller.selectedStatus.value != StaffStatus.all;

                        if (hasFilterOrSearch) {
                          return EmptyView(
                            icon: Iconsax.user_search,
                            title: 'No Matching Staff Members',
                            message:
                                'No staff members match "${controller.searchQuery.value}" with the selected filters.',
                            actionLabel: 'Reset Filters',
                            onAction: () {
                              controller.resetFilters();
                            },
                          );
                        }

                        return EmptyView(
                          icon: Iconsax.user_octagon,
                          title: 'No Staff Members Registered',
                          message:
                              'Add store clerks, technicians, and managers to delegate operational roles.',
                          actionLabel: 'Add Staff Member',
                          onAction: () {
                            controller.initForm();
                            Get.toNamed(Routes.STAFF_ADD);
                          },
                        );
                      },
                      noMoreItemsIndicatorBuilder: (_) =>
                          const EndOfListIndicator(),
                      itemBuilder: (context, staff, index) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _buildStaffItem(context, staff),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Search and Filter Header ──────────────────────────────────────────────
  Widget _buildSearchAndFilterHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          Expanded(
            child: Obx(() {
              final query = controller.searchQuery.value;
              return TextField(
                onChanged: (value) => controller.searchQuery.value = value,
                decoration: InputDecoration(
                  hintText: 'Search staff by name or email...',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  prefixIcon: Icon(
                    Iconsax.search_normal_1,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  suffixIcon: query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          color: colorScheme.onSurfaceVariant,
                          tooltip: 'Clear search',
                          onPressed: () => controller.searchQuery.value = '',
                        )
                      : null,
                  filled: true,
                  fillColor: colorScheme.surfaceContainerLow,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.mdAll,
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.mdAll,
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.mdAll,
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              );
            }),
          ),
          AppSpacing.gapSm,
          Obx(() {
            final hasActiveFilters =
                controller.selectedRole.value != StaffRole.all ||
                controller.selectedStatus.value != StaffStatus.all;

            return Badge(
              isLabelVisible: hasActiveFilters,
              smallSize: 8,
              child: IconButton.filledTonal(
                icon: const Icon(Icons.filter_list_rounded, size: 22),
                tooltip: 'Filter Staff',
                style: hasActiveFilters
                    ? IconButton.styleFrom(
                        backgroundColor: colorScheme.primaryContainer,
                        foregroundColor: colorScheme.onPrimaryContainer,
                      )
                    : null,
                onPressed: () => StaffFilterSheet.show(context, controller),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Quick Summary Metrics Strip ───────────────────────────────────────────
  Widget _buildSummaryMetrics(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Obx(() {
      final list = controller.filteredStaffList;
      final total = list.length;
      final active = list.where((s) => s.isActive).length;
      final admins = list.where((s) => s.role.toLowerCase() == 'admin').length;

      if (total == 0) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildMetricChip(
                context,
                label: 'Total Staff',
                count: '$total',
                icon: Iconsax.people,
                color: colorScheme.onSurfaceVariant,
              ),
              AppSpacing.hGapXs,
              _buildMetricChip(
                context,
                label: 'Active',
                count: '$active',
                icon: Iconsax.user_tick,
                color: Colors.green,
              ),
              AppSpacing.hGapXs,
              _buildMetricChip(
                context,
                label: 'Admins',
                count: '$admins',
                icon: Iconsax.shield_tick,
                color: colorScheme.primary,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildMetricChip(
    BuildContext context, {
    required String label,
    required String count,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: AppRadius.smAll,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              count,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 10.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Staff Member Card with Slidable Actions ───────────────────────────────
  Widget _buildStaffItem(BuildContext context, Staff staff) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isAdmin = staff.role.toLowerCase() == 'admin';

    return Slidable(
      key: ValueKey(staff.uid),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) {
              controller.initForm(staff);
              Get.toNamed(Routes.STAFF_EDIT, arguments: staff);
            },
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            icon: Iconsax.edit_2,
            label: 'Edit',
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(AppRadius.md),
            ),
          ),
          SlidableAction(
            onPressed: (_) => _showDeleteDialog(context, staff),
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
            icon: Iconsax.trash,
            label: 'Delete',
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(AppRadius.md),
            ),
          ),
        ],
      ),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        onTap: () {
          Get.toNamed(Routes.STAFF_DETAILS, arguments: staff);
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar with initials
            CircleAvatar(
              radius: 24,
              backgroundColor: isAdmin
                  ? colorScheme.primary.withValues(alpha: 0.14)
                  : colorScheme.secondary.withValues(alpha: 0.14),
              child: Text(
                staff.name.isNotEmpty ? staff.name[0].toUpperCase() : '?',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isAdmin ? colorScheme.primary : colorScheme.secondary,
                ),
              ),
            ),
            AppSpacing.hGapMd,

            // Staff Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    staff.name,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),

                  // Email
                  Row(
                    children: [
                      Icon(
                        Iconsax.sms,
                        size: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          staff.email,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Badges Wrap (Never overflows on narrow widths)
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // Role Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isAdmin
                              ? colorScheme.primary.withValues(alpha: 0.1)
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isAdmin
                                ? colorScheme.primary.withValues(alpha: 0.25)
                                : colorScheme.outlineVariant,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isAdmin ? Iconsax.shield_tick : Iconsax.user,
                              size: 11,
                              color: isAdmin
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              (staff.role.capitalizeFirst ?? staff.role)
                                  .toUpperCase(),
                              style: textTheme.labelSmall?.copyWith(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: isAdmin
                                    ? colorScheme.primary
                                    : colorScheme.onSurfaceVariant,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Active / Inactive Status Badge
                      StatusBadge.fromStatus(
                        staff.isActive ? 'active' : 'inactive',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Chevron
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ── Delete Confirmation Dialog ────────────────────────────────────────────
  void _showDeleteDialog(BuildContext context, Staff user) {
    showConfirmDeleteDialog(
      title: 'Delete Staff Member',
      message:
          'Are you sure you want to remove ${user.name}? This member will lose access to system point-of-sale and rental operations.',
      onConfirm: () {
        controller.deleteStaff(user);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Modern Staff Filter Bottom Sheet (Matching CustomerFilterSheet style)
// ─────────────────────────────────────────────────────────────────────────────
class StaffFilterSheet extends StatefulWidget {
  const StaffFilterSheet({super.key, required this.controller});

  final StaffController controller;

  static void show(BuildContext context, StaffController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      isDismissible: true,
      enableDrag: false,
      builder: (context) => StaffFilterSheet(controller: controller),
    );
  }

  @override
  State<StaffFilterSheet> createState() => _StaffFilterSheetState();
}

class _StaffFilterSheetState extends State<StaffFilterSheet> {
  late StaffRole _draftRole;
  late StaffStatus _draftStatus;

  @override
  void initState() {
    super.initState();
    _draftRole = widget.controller.selectedRole.value;
    _draftStatus = widget.controller.selectedStatus.value;
  }

  int get _activeFilterCount {
    int count = 0;
    if (_draftRole != StaffRole.all) count++;
    if (_draftStatus != StaffStatus.all) count++;
    return count;
  }

  bool get _hasChanges {
    return _draftRole != widget.controller.selectedRole.value ||
        _draftStatus != widget.controller.selectedStatus.value;
  }

  void _reset() {
    setState(() {
      _draftRole = StaffRole.all;
      _draftStatus = StaffStatus.all;
    });
  }

  void _apply() {
    widget.controller.selectedRole.value = _draftRole;
    widget.controller.selectedStatus.value = _draftStatus;
    widget.controller.fetchStaff();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return AppFloatingBottomSheet(
      title: 'Filter Staff Directory',
      subtitle: 'Narrow staff members by role and account status',
      isFloating: false,
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.xxs),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.12),
          borderRadius: AppRadius.smAll,
        ),
        child: Icon(
          Iconsax.filter_search,
          color: theme.colorScheme.primary,
          size: 18,
        ),
      ),
      footer: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: (_activeFilterCount > 0 || _hasChanges)
                  ? _reset
                  : null,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 8,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.smAll,
                ),
                textStyle: textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('Reset All'),
            ),
          ),
          AppSpacing.gapSm,
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: _apply,
              icon: const Icon(Icons.check_rounded, size: 16),
              label: Text(
                _activeFilterCount > 0
                    ? 'Apply Filters ($_activeFilterCount)'
                    : 'Apply Filters',
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 8,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.smAll,
                ),
                textStyle: textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSpacing.gapXs,
          Text(
            'STAFF ROLE',
            style: textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w700,
            ),
          ),
          AppSpacing.gapSm,
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              _FilterOptionChip(
                label: 'All Roles',
                icon: Iconsax.people,
                isSelected: _draftRole == StaffRole.all,
                onTap: () => setState(() => _draftRole = StaffRole.all),
              ),
              _FilterOptionChip(
                label: 'Admin',
                icon: Iconsax.shield_tick,
                isSelected: _draftRole == StaffRole.admin,
                onTap: () => setState(() => _draftRole = StaffRole.admin),
              ),
              _FilterOptionChip(
                label: 'Staff',
                icon: Iconsax.user,
                isSelected: _draftRole == StaffRole.staff,
                onTap: () => setState(() => _draftRole = StaffRole.staff),
              ),
            ],
          ),
          AppSpacing.gapMd,
          Text(
            'ACCOUNT STATUS',
            style: textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w700,
            ),
          ),
          AppSpacing.gapSm,
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              _FilterOptionChip(
                label: 'All Statuses',
                icon: Iconsax.status,
                isSelected: _draftStatus == StaffStatus.all,
                onTap: () => setState(() => _draftStatus = StaffStatus.all),
              ),
              _FilterOptionChip(
                label: 'Active',
                icon: Iconsax.user_tick,
                accentColor: Colors.green,
                isSelected: _draftStatus == StaffStatus.active,
                onTap: () => setState(() => _draftStatus = StaffStatus.active),
              ),
              _FilterOptionChip(
                label: 'Inactive',
                icon: Iconsax.user_remove,
                accentColor: theme.colorScheme.error,
                isSelected: _draftStatus == StaffStatus.inactive,
                onTap: () =>
                    setState(() => _draftStatus = StaffStatus.inactive),
              ),
            ],
          ),
          AppSpacing.gapSm,
        ],
      ),
    );
  }
}

class _FilterOptionChip extends StatelessWidget {
  const _FilterOptionChip({
    required this.label,
    this.icon,
    this.accentColor,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData? icon;
  final Color? accentColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveColor = accentColor ?? theme.colorScheme.primary;

    final backgroundColor = isSelected
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surfaceContainerLow;

    final textColor = isSelected
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurface;

    final borderColor = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.outlineVariant;

    return Material(
      color: backgroundColor,
      borderRadius: AppRadius.smAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smAll,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          decoration: BoxDecoration(
            borderRadius: AppRadius.smAll,
            border: Border.all(
              color: borderColor,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (accentColor != null)
                Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.only(right: 6.0),
                  decoration: BoxDecoration(
                    color: effectiveColor,
                    shape: BoxShape.circle,
                  ),
                )
              else if (icon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 5.0),
                  child: Icon(
                    icon,
                    size: 14,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: textColor,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom 1:1 Pixel-Perfect Staff Skeleton Matching Real Card Layout
// ─────────────────────────────────────────────────────────────────────────────

class StaffCardSkeleton extends StatelessWidget {
  const StaffCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Avatar placeholder (exact 48x48 circle)
          const SkeletonLoader(
            width: 48,
            height: 48,
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
          AppSpacing.hGapMd,

          // 2. Staff Details placeholder
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name placeholder
                const SkeletonLoader(
                  width: 140,
                  height: 16,
                  borderRadius: AppRadius.xsAll,
                ),
                const SizedBox(height: 6),

                // Email row placeholder
                const Row(
                  children: [
                    SkeletonLoader(
                      width: 13,
                      height: 13,
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                    ),
                    SizedBox(width: 4),
                    Flexible(
                      child: SkeletonLoader(
                        width: 150,
                        height: 12,
                        borderRadius: AppRadius.xsAll,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Badges Wrap placeholder (Role Pill & Status Badge)
                const Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Role pill skeleton
                    SkeletonLoader(
                      width: 72,
                      height: 22,
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                    ),
                    // Status badge skeleton
                    SkeletonLoader(
                      width: 60,
                      height: 22,
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 3. Chevron placeholder
          const SkeletonLoader(
            width: 16,
            height: 16,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ],
      ),
    );
  }
}

class StaffListSkeleton extends StatelessWidget {
  const StaffListSkeleton({
    super.key,
    this.itemCount = 6,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm),
          child: StaffCardSkeleton(),
        ),
      ),
    );
  }
}
