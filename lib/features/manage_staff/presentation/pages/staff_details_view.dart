import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:pos/core/routes/app_pages.dart';
import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_semantic_colors.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/utils/device_utils.dart';
import 'package:pos/core/utils/responsive.dart';
import 'package:pos/core/widgets/app_card.dart';
import 'package:pos/core/widgets/confirm_delete_dialog.dart';
import 'package:pos/core/widgets/custome_app_bar.dart';
import 'package:pos/core/widgets/entity_qr_dialog.dart';
import 'package:pos/core/widgets/info_row.dart';
import 'package:pos/core/widgets/status_badge.dart';
import 'package:pos/core/utils/app_data_formatter.dart';
import 'package:pos/core/utils/app_date_time_utils.dart';
import 'package:pos/features/activity_logs/presentation/widgets/activity_detail_bottom_sheet.dart';
import 'package:pos/features/activity_logs/presentation/widgets/activity_log_skeleton.dart';

import '../../domain/entities/staff.dart';
import '../controllers/staff_controller.dart';
import '../widgets/operational_metrics_skeleton.dart';

/// Redesigned Staff Profile Details Screen conforming to Material 3 guidelines and project UI/UX standards.
/// - Compact hero profile card
/// - Live operational metrics with 7, 30, and 90-day filter windows
/// - Recent operational activity timeline feed (4 items) with tap-to-inspect and full history link
/// - Operational account status card with live toggle switch
/// - Contact & employment record with formatted join date
/// - Role capability and permissions scope matrix
/// - Clean AppBar with dedicated Danger Zone action
class StaffDetailsView extends GetView<StaffController> {
  const StaffDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final args = Get.arguments;

    if (args is Staff) {
      if (controller.detailStaff.value == null || controller.detailStaff.value!.id != args.id) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.loadStaffProfileData(args);
        });
      }
    } else if (args is int) {
      if (controller.detailStaff.value == null || controller.detailStaff.value!.id != args) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.loadStaffById(args);
        });
      }
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomeAppBar(
        title: 'Staff Profile',
        centerTitle: true,
        showbackArrow: true,
        actions: [
          Obx(() {
            final currentStaff = controller.detailStaff.value;
            if (currentStaff == null) return const SizedBox.shrink();
            return EntityQrActionButton(
              table: 'users',
              id: currentStaff.id,
              title: '${currentStaff.name} QR',
            );
          }),
        ],
      ),
      body: Obx(() {
        final currentStaff = controller.detailStaff.value;
        if (controller.isLoadingDetail.value || currentStaff == null) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        final staff = _resolveStaff(currentStaff);
        final isAdmin = staff.role.toLowerCase() == 'admin';

        return RefreshIndicator(
          onRefresh: () async {
            await controller.fetchStaff();
            final current = controller.detailStaff.value;
            if (current != null) {
              await controller.loadStaffProfileData(current);
            } else if (args is int) {
              await controller.loadStaffById(args);
            }
          },
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
                  // ── Compact Profile Overview Header ──────────────────
                  _buildProfileHeaderCard(context, staff),
                  AppSpacing.gapLg,

                  // ── Performance Metrics (Live Telemetry) ─────────────
                  _buildSectionHeader(
                    context,
                    title: 'Performance & Operations',
                    icon: Iconsax.chart_21,
                    badgeText: 'Live Telemetry',
                  ),
                  _buildPerformanceMetricsSection(context, staff),
                  AppSpacing.gapLg,

                  // ── Recent Activity Log (Live Feed) ────────────────
                  _buildSectionHeader(
                    context,
                    title: 'Recent Activity Log',
                    icon: Iconsax.activity,
                    badgeText: 'Live Feed',
                  ),
                  _buildActivityLogSection(context, staff),
                  AppSpacing.gapLg,

                  // ── Operational Access & Account Status ───────────────
                  _buildSectionHeader(
                    context,
                    title: 'Operational Access & Status',
                    icon: Iconsax.shield_security,
                  ),
                  _buildAccountStatusCard(context, staff, isAdmin),
                  AppSpacing.gapLg,

                  // ── Contact & Employment Record ───────────────────────
                  _buildSectionHeader(
                    context,
                    title: 'Contact & Employment Record',
                    icon: Iconsax.personalcard,
                  ),
                  _buildContactCard(context, staff),
                  AppSpacing.gapLg,

                  // ── Role Permissions & Capabilities ───────────────────
                  _buildSectionHeader(
                    context,
                    title: 'Role Permissions & Capabilities',
                    icon: Iconsax.key,
                  ),
                  _buildRolePermissionsCard(context, staff, isAdmin),
                  AppSpacing.gapLg,

                  // ── Account Danger Zone (Non-admin) ───────────────────
                  if (!isAdmin) ...[
                    _buildDangerZoneCard(context, staff),
                    AppSpacing.gapLg,
                  ],

                  AppSpacing.gapXxl,
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Staff _resolveStaff(Staff initialStaff) {
    return controller.staffList.firstWhere(
      (u) => u.uid == initialStaff.uid,
      orElse: () => initialStaff,
    );
  }

  // ── Compact Profile Overview Card ─────────────────────────────────────────
  Widget _buildProfileHeaderCard(BuildContext context, Staff staff) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isAdmin = staff.role.toLowerCase() == 'admin';

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sleek Avatar
              CircleAvatar(
                radius: 26,
                backgroundColor: (isAdmin ? colorScheme.primary : colorScheme.secondary)
                    .withValues(alpha: 0.14),
                child: Text(
                  staff.name.isNotEmpty ? staff.name[0].toUpperCase() : '?',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isAdmin ? colorScheme.primary : colorScheme.secondary,
                  ),
                ),
              ),
              AppSpacing.hGapSm,

              // Member Details Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name & Status
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            staff.name,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        StatusBadge.fromStatus(staff.isActive ? 'active' : 'inactive'),
                      ],
                    ),
                    const SizedBox(height: 2),

                    // Email
                    Text(
                      staff.email,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Metadata Pill Wrap: Role + Join Date
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Role Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: isAdmin
                                ? colorScheme.primary.withValues(alpha: 0.12)
                                : colorScheme.surfaceContainerHighest,
                            borderRadius: AppRadius.smAll,
                            border: Border.all(
                              color: isAdmin
                                  ? colorScheme.primary.withValues(alpha: 0.3)
                                  : colorScheme.outlineVariant,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isAdmin ? Iconsax.shield_tick : Iconsax.user,
                                size: 11,
                                color: isAdmin ? colorScheme.primary : colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                staff.role.toUpperCase(),
                                style: textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  color: isAdmin ? colorScheme.primary : colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Join Date
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Iconsax.calendar_1,
                              size: 11,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'Joined ${_formatJoinDate(staff.joinDate)}',
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 10.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20),

          // Compact Quick Action Buttons (Call, Email, Edit)
          Row(
            children: [
              if (staff.phoneNumber != null && staff.phoneNumber!.isNotEmpty) ...[
                Expanded(
                  child: _buildCompactActionButton(
                    context,
                    icon: Iconsax.call,
                    label: 'Call',
                    onTap: () => DeviceUtils.lunchUrl('tel:${staff.phoneNumber}'),
                  ),
                ),
                AppSpacing.hGapSm,
              ],
              Expanded(
                child: _buildCompactActionButton(
                  context,
                  icon: Iconsax.sms,
                  label: 'Email',
                  onTap: () => DeviceUtils.lunchUrl('mailto:${staff.email}'),
                ),
              ),
              AppSpacing.hGapSm,
              Expanded(
                child: _buildCompactActionButton(
                  context,
                  icon: Iconsax.edit_2,
                  label: 'Edit',
                  onTap: () {
                    controller.initForm(staff);
                    Get.toNamed(Routes.STAFF_EDIT, arguments: staff);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.smAll,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: AppRadius.smAll,
          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: colorScheme.primary),
            const SizedBox(width: 5),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Performance Metrics Section ───────────────────────────────────────────
  Widget _buildPerformanceMetricsSection(BuildContext context, Staff staff) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Obx(() {
      final isLoading = controller.isLoadingMetrics.value;
      final metrics = controller.operationalMetrics.value;
      final currentWindow = controller.selectedDaysWindow.value;

      if (isLoading && metrics == null) {
        return const OperationalMetricsSkeleton();
      }

      return AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Operational Metrics',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildWindowSelector(context, currentWindow, isLoading),
              ],
            ),
            AppSpacing.gapMd,
            if (metrics != null) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      context,
                      icon: Iconsax.box_tick,
                      iconColor: colorScheme.primary,
                      value: '${metrics.rentalsIssued}',
                      label: 'Rentals Issued',
                      badgeText: '${metrics.windowDays}d window',
                      badgeColor: colorScheme.primary,
                    ),
                  ),
                  AppSpacing.hGapSm,
                  Expanded(
                    child: _buildMetricTile(
                      context,
                      icon: Iconsax.dollar_circle,
                      iconColor: Colors.blue,
                      value: '${metrics.salesHandled}',
                      label: 'Sales Handled',
                      badgeText: 'Active',
                      badgeColor: Colors.blue,
                    ),
                  ),
                ],
              ),
              AppSpacing.gapSm,
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      context,
                      icon: Iconsax.rotate_left,
                      iconColor: Colors.teal,
                      value: '${metrics.returnsProcessed}',
                      label: 'Returns Processed',
                      badgeText: '${metrics.damagesRecorded} damages',
                      badgeColor: metrics.damagesRecorded > 0 ? Colors.amber.shade800 : Colors.teal,
                    ),
                  ),
                  AppSpacing.hGapSm,
                  Expanded(
                    child: _buildMetricTile(
                      context,
                      icon: Iconsax.status_up,
                      iconColor: Colors.indigo,
                      value: '${metrics.returnRatePct}%',
                      label: 'Return Rate',
                      badgeText: '${metrics.agreementsSigned} signed',
                      badgeColor: Colors.indigo,
                    ),
                  ),
                ],
              ),
              AppSpacing.gapMd,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: AppRadius.smAll,
                  border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Iconsax.info_circle,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Audit Window: ${metrics.startDate} to ${metrics.endDate} • ${metrics.agreementsSigned} agreements • ${metrics.damagesRecorded} damages',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                alignment: Alignment.center,
                child: Text(
                  'No metrics available for this period.',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildWindowSelector(BuildContext context, int currentWindow, bool isLoading) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final windowOptions = [7, 30, 90];

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: AppRadius.smAll,
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: windowOptions.map((days) {
          final isSelected = days == currentWindow;
          return InkWell(
            onTap: isLoading ? null : () => controller.changeDaysWindow(days),
            borderRadius: AppRadius.xsAll,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? colorScheme.primary : Colors.transparent,
                borderRadius: AppRadius.xsAll,
              ),
              child: Text(
                '${days}D',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 10.5,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required String badgeText,
    required Color badgeColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: AppRadius.smAll,
                ),
                child: Icon(icon, size: 15, color: iconColor),
              ),
              const Spacer(),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.1),
                    borderRadius: AppRadius.smAll,
                  ),
                  child: Text(
                    badgeText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelSmall?.copyWith(
                      color: badgeColor,
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.gapSm,
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Recent Activity Log Section ───────────────────────────────────────────
  Widget _buildActivityLogSection(BuildContext context, Staff staff) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Operational Log',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed(Routes.ACTIVITY_LOGS, arguments: staff),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View More',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Icon(
                      Iconsax.arrow_right_3,
                      size: 12,
                      color: colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.gapMd,
          Obx(() {
            final isLoading = controller.isLoadingActivities.value;
            final activities = controller.recentStaffActivities;

            if (isLoading && activities.isEmpty) {
              return Column(
                children: List.generate(
                  3,
                  (_) => const Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.sm),
                    child: ActivityLogSkeleton(),
                  ),
                ),
              );
            }

            if (activities.isEmpty) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.md),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: AppRadius.mdAll,
                ),
                child: Column(
                  children: [
                    Icon(Iconsax.activity, size: 28, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
                    AppSpacing.gapXs,
                    Text(
                      'No recent activity logged for ${staff.name}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: List.generate(activities.length, (index) {
                final item = activities[index];
                final isLast = index == activities.length - 1;
                final (icon, itemColor) = _getActivityVisuals(context, item.action);
                final timeLabel = AppDataFormatter.customTimeAgo(item.createdAt.toIso8601String());

                return InkWell(
                  onTap: () => ActivityDetailBottomSheet.show(context, item),
                  borderRadius: AppRadius.smAll,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: itemColor.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: itemColor.withValues(alpha: 0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(icon, size: 14, color: itemColor),
                            ),
                            if (!isLast)
                              Container(
                                width: 1.5,
                                height: 32,
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                              ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.action,
                                        style: textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      timeLabel,
                                      style: textTheme.labelSmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.metadata?['description']?.toString() ??
                                      'Recorded by ${item.userName} (${item.role.toUpperCase()})',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            );
          }),
          AppSpacing.gapMd,
          // Bottom View More Button
          InkWell(
            onTap: () => Get.toNamed(Routes.ACTIVITY_LOGS, arguments: staff),
            borderRadius: AppRadius.smAll,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: AppRadius.smAll,
                border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.document_text, size: 14, color: colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    'View Full Activity History',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  (IconData, Color) _getActivityVisuals(BuildContext context, String action) {
    final theme = Theme.of(context);
    final semantics = context.semanticColors;
    final lower = action.toLowerCase();

    if (lower.contains('delete')) {
      return (Iconsax.trash, theme.colorScheme.error);
    } else if (lower.contains('damage')) {
      return (Iconsax.warning_2, theme.colorScheme.error);
    } else if (lower.contains('create') || lower.contains('add')) {
      return (Iconsax.add_circle, semantics.success);
    } else if (lower.contains('update') || lower.contains('edit')) {
      return (Iconsax.edit_2, theme.colorScheme.primary);
    } else if (lower.contains('logged in') || lower.contains('login')) {
      return (Iconsax.login, semantics.info);
    } else if (lower.contains('logged out') || lower.contains('logout')) {
      return (Iconsax.logout, theme.colorScheme.onSurfaceVariant);
    } else if (lower.contains('payment')) {
      return (Iconsax.card, semantics.warning);
    } else if (lower.contains('rental')) {
      return (Iconsax.calendar_1, theme.colorScheme.primary);
    } else if (lower.contains('sale')) {
      return (Iconsax.shopping_bag, semantics.success);
    } else if (lower.contains('customer') || lower.contains('user')) {
      return (Iconsax.user, semantics.info);
    } else if (lower.contains('voucher') || lower.contains('promo')) {
      return (Iconsax.discount_shape, semantics.warning);
    } else {
      return (Iconsax.activity, theme.colorScheme.primary);
    }
  }

  // ── Account Access & Status Card ──────────────────────────────────────────
  Widget _buildAccountStatusCard(
    BuildContext context,
    Staff staff,
    bool isAdmin,
  ) {
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
              color: (staff.isActive ? Colors.green : colorScheme.error)
                  .withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              staff.isActive ? Iconsax.user_tick : Iconsax.user_remove,
              size: 20,
              color: staff.isActive ? Colors.green : colorScheme.error,
            ),
          ),
          AppSpacing.gapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account Active Status',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isAdmin
                      ? 'Administrator accounts maintain permanent operational clearance.'
                      : (staff.isActive
                          ? 'Staff member is active and permitted to conduct point-of-sale and rental transactions.'
                          : 'Staff member is deactivated. System access and login privileges are revoked.'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: staff.isActive,
            onChanged: isAdmin ? null : (_) => controller.toggleStaffStatus(staff),
            activeThumbColor: Colors.green,
          ),
        ],
      ),
    );
  }

  // ── Contact Information Card ──────────────────────────────────────────────
  Widget _buildContactCard(BuildContext context, Staff staff) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          InfoRow(
            label: 'Official Email',
            value: staff.email,
            isBold: true,
          ),
          const Divider(height: 18),
          InfoRow(
            label: 'Contact Phone',
            value: (staff.phoneNumber != null && staff.phoneNumber!.isNotEmpty)
                ? staff.phoneNumber!
                : 'Not provided',
          ),
          const Divider(height: 18),
          InfoRow(
            label: 'Employment Joined Date',
            value: _formatJoinDate(staff.joinDate),
          ),
          const Divider(height: 18),
          InfoRow(
            label: 'Internal Staff ID',
            value: '#${staff.id}',
          ),
        ],
      ),
    );
  }

  // ── Role Permissions Scope Card ───────────────────────────────────────────
  Widget _buildRolePermissionsCard(
    BuildContext context,
    Staff staff,
    bool isAdmin,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isAdmin ? Iconsax.shield_tick : Iconsax.user_octagon,
                size: 18,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Granted System Privileges',
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          _buildPermissionItem(
            context,
            title: 'Point of Sale & Checkouts',
            detail: isAdmin
                ? 'Full access (sales, customer discounts, refunds, invoice receipts)'
                : 'Standard access (item checkouts and payment processing)',
            isGranted: true,
          ),
          const SizedBox(height: 12),
          _buildPermissionItem(
            context,
            title: 'Equipment & Rental Fleet',
            detail: isAdmin
                ? 'Full access (rental checkouts, damage rules, returns, and inspection)'
                : 'Operational access (checkouts, returns, duration tracking)',
            isGranted: true,
          ),
          const SizedBox(height: 12),
          _buildPermissionItem(
            context,
            title: 'Customer Directory & Profiles',
            detail: isAdmin
                ? 'Full access (register, view history, edit, delete customer records)'
                : 'Standard access (register new customers and view rental history)',
            isGranted: true,
          ),
          const SizedBox(height: 12),
          _buildPermissionItem(
            context,
            title: 'Store Settings & Staff Management',
            detail: isAdmin
                ? 'Full administrative control (manage staff credentials, store policies)'
                : 'Restricted (cannot modify shop settings or edit staff accounts)',
            isGranted: isAdmin,
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem(
    BuildContext context, {
    required String title,
    required String detail,
    required bool isGranted,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          isGranted ? Icons.check_circle_rounded : Icons.cancel_rounded,
          size: 16,
          color: isGranted ? Colors.green : colorScheme.error,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                detail,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Danger Zone Card ──────────────────────────────────────────────────────
  Widget _buildDangerZoneCard(BuildContext context, Staff staff) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.error.withValues(alpha: 0.04),
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Iconsax.danger, color: colorScheme.error, size: 22),
          AppSpacing.gapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Remove Staff Access',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.error,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Permanently revoke access credentials for this staff member.',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.hGapSm,
          OutlinedButton(
            onPressed: () => _showDeleteDialog(context, staff),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.error,
              side: BorderSide(color: colorScheme.error.withValues(alpha: 0.5)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.smAll),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ── Section Header ────────────────────────────────────────────────────────
  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required IconData icon,
    String? badgeText,
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
          if (badgeText != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: AppRadius.smAll,
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Text(
                badgeText,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Helper: Format Join Date ──────────────────────────────────────────────
  String _formatJoinDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 'Recent';
    try {
      final dt = AppDateTimeUtils.toLocal(raw);
      if (dt != null) {
        return DateFormat('MMM d, yyyy').format(dt);
      }
    } catch (_) {}
    return raw;
  }

  // ── Delete Confirmation Dialog ────────────────────────────────────────────
  void _showDeleteDialog(BuildContext context, Staff user) {
    showConfirmDeleteDialog(
      title: 'Delete Staff Member',
      message:
          'Are you sure you want to remove ${user.name}? This member will immediately lose access to storefront operations.',
      onConfirm: () async {
        await controller.deleteStaff(user);
        Get.back();
      },
    );
  }
}
