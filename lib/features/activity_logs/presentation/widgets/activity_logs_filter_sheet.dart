import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/custome_drop_down_decoration.dart';
import '../../domain/entities/activity_filter_options.dart';
import '../controllers/activity_logs_controller.dart';

enum _ActivityDatePreset {
  allTime('All Time'),
  today('Today'),
  thisWeek('This Week'),
  thisMonth('This Month'),
  custom('Custom');

  final String label;
  const _ActivityDatePreset(this.label);
}

class ActivityLogsFilterSheet extends StatefulWidget {
  const ActivityLogsFilterSheet({
    super.key,
    required this.controller,
  });

  final ActivityLogsController controller;

  /// Shows the filter bottom sheet as a compact modal bottom sheet conforming to Material 3 & UI guidelines.
  static Future<void> show(
    BuildContext context,
    ActivityLogsController controller,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      isDismissible: true,
      enableDrag: true,
      builder: (context) => ActivityLogsFilterSheet(controller: controller),
    );
  }

  @override
  State<ActivityLogsFilterSheet> createState() =>
      _ActivityLogsFilterSheetState();
}

class _ActivityLogsFilterSheetState extends State<ActivityLogsFilterSheet> {
  ActivityStaffOption? _draftStaff;
  String _draftRole = 'all';
  ActivityActionOption? _draftAction;
  DateTime? _draftStartDate;
  DateTime? _draftEndDate;
  _ActivityDatePreset _datePreset = _ActivityDatePreset.allTime;

  @override
  void initState() {
    super.initState();
    _draftStaff = widget.controller.selectedStaff.value;
    _draftRole = widget.controller.selectedRole.value;
    _draftAction = widget.controller.selectedAction.value;
    _draftStartDate = widget.controller.startDate.value;
    _draftEndDate = widget.controller.endDate.value;

    _determineInitialPreset();
  }

  List<ActivityStaffOption> get _staffDropdownItems {
    final list = widget.controller.availableStaffMembers.toList();
    if (_draftStaff != null && !list.contains(_draftStaff)) {
      list.insert(0, _draftStaff!);
    }
    return list;
  }

  ActivityStaffOption? get _initialStaffItem {
    if (_draftStaff == null) return null;
    final items = _staffDropdownItems;
    final idx = items.indexOf(_draftStaff!);
    return idx != -1 ? items[idx] : null;
  }

  List<ActivityActionOption> get _actionDropdownItems {
    final list = widget.controller.availableActions.toList();
    if (_draftAction != null && !list.contains(_draftAction)) {
      list.insert(0, _draftAction!);
    }
    return list;
  }

  ActivityActionOption? get _initialActionItem {
    if (_draftAction == null) return null;
    final items = _actionDropdownItems;
    final idx = items.indexOf(_draftAction!);
    return idx != -1 ? items[idx] : null;
  }

  void _determineInitialPreset() {
    if (_draftStartDate == null && _draftEndDate == null) {
      _datePreset = _ActivityDatePreset.allTime;
      return;
    }

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    if (_isSameDay(_draftStartDate, todayStart) &&
        _isSameDay(_draftEndDate, todayEnd)) {
      _datePreset = _ActivityDatePreset.today;
      return;
    }

    _datePreset = _ActivityDatePreset.custom;
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  int get _activeFilterCount {
    int count = 0;
    if (_draftStaff != null) count++;
    if (_draftRole != 'all') count++;
    if (_draftAction != null) count++;
    if (_draftStartDate != null || _draftEndDate != null) count++;
    return count;
  }

  void _reset() {
    setState(() {
      _draftStaff = null;
      _draftRole = 'all';
      _draftAction = null;
      _draftStartDate = null;
      _draftEndDate = null;
      _datePreset = _ActivityDatePreset.allTime;
    });
  }

  void _apply() {
    widget.controller.selectedStaff.value = _draftStaff;
    widget.controller.selectedRole.value = _draftRole;
    widget.controller.selectedAction.value = _draftAction;
    widget.controller.startDate.value = _draftStartDate;
    widget.controller.endDate.value = _draftEndDate;

    widget.controller.pagingController.refresh();
    Navigator.of(context).pop();
  }

  void _onPresetSelected(_ActivityDatePreset preset) async {
    final now = DateTime.now();
    DateTime? start;
    DateTime? end;

    switch (preset) {
      case _ActivityDatePreset.allTime:
        start = null;
        end = null;
        break;
      case _ActivityDatePreset.today:
        start = DateTime(now.year, now.month, now.day);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case _ActivityDatePreset.thisWeek:
        final weekday = now.weekday; // 1 = Monday
        start = DateTime(now.year, now.month, now.day - (weekday - 1));
        end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case _ActivityDatePreset.thisMonth:
        start = DateTime(now.year, now.month, 1);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case _ActivityDatePreset.custom:
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime(2035),
          initialDateRange: _draftStartDate != null && _draftEndDate != null
              ? DateTimeRange(start: _draftStartDate!, end: _draftEndDate!)
              : null,
        );
        if (picked != null) {
          setState(() {
            _draftStartDate = picked.start;
            _draftEndDate = picked.end;
            _datePreset = _ActivityDatePreset.custom;
          });
        }
        return;
    }

    setState(() {
      _draftStartDate = start;
      _draftEndDate = end;
      _datePreset = preset;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.78,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.outlineVariant.withValues(alpha: 0.8),
                  borderRadius: AppRadius.fullAll,
                ),
              ),
            ),

            // Top Header: Leading icon, Title, Subtitle, Active Count Badge, Close button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 4,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xxs + 1),
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.12),
                      borderRadius: AppRadius.smAll,
                    ),
                    child: Icon(
                      Icons.filter_list_rounded,
                      color: scheme.primary,
                      size: 18,
                    ),
                  ),
                  AppSpacing.hGapSm,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                'Filter Activity Logs',
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (_activeFilterCount > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1.5,
                                ),
                                decoration: BoxDecoration(
                                  color: scheme.primaryContainer,
                                  borderRadius: AppRadius.fullAll,
                                ),
                                child: Text(
                                  '$_activeFilterCount',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: scheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'Narrow down logs by role, staff, action or date',
                          style: textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    tooltip: 'Close',
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Scrollable Filter Sections Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Section 1: Role Filter ─────────────────────────────
                    Text(
                      'User Role',
                      style: textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: ['all', 'admin', 'staff'].map((role) {
                        final isSelected = _draftRole == role;
                        final label = role == 'all'
                            ? 'All Roles'
                            : (role == 'admin' ? 'Admins' : 'Staff');

                        return ChoiceChip(
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                          label: Text(label),
                          selected: isSelected,
                          showCheckmark: false,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? scheme.onPrimary
                                : scheme.onSurface,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 11.5,
                          ),
                          selectedColor: scheme.primary,
                          backgroundColor: scheme.surfaceContainerLow,
                          side: BorderSide(
                            color: isSelected
                                ? scheme.primary
                                : scheme.outlineVariant.withValues(alpha: 0.6),
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _draftRole = role;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),

                    AppSpacing.vGapMd,

                    // ── Section 2: Staff Member Filter (Animated Custom Dropdown) ───
                    if (_staffDropdownItems.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Staff Member',
                            style: textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurface,
                            ),
                          ),
                          if (_draftStaff != null)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _draftStaff = null;
                                });
                              },
                              child: Text(
                                'Clear',
                                style: textTheme.labelSmall?.copyWith(
                                  color: scheme.error,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      CustomDropdown<ActivityStaffOption>.search(
                        hintText: 'All Staff Members',
                        items: _staffDropdownItems,
                        initialItem: _initialStaffItem,
                        onChanged: (val) {
                          setState(() {
                            _draftStaff = val;
                          });
                        },
                        decoration: _buildCompactDropdownDecoration(context),
                        disabledDecoration:
                            buildCustomDropdownDisabledDecoration(context),
                      ),
                      AppSpacing.vGapMd,
                    ],

                    // ── Section 3: Action Type Filter (Animated Custom Dropdown) ───
                    if (_actionDropdownItems.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Action Type',
                            style: textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurface,
                            ),
                          ),
                          if (_draftAction != null)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _draftAction = null;
                                });
                              },
                              child: Text(
                                'Clear',
                                style: textTheme.labelSmall?.copyWith(
                                  color: scheme.error,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      CustomDropdown<ActivityActionOption>.search(
                        hintText: 'All Actions',
                        items: _actionDropdownItems,
                        initialItem: _initialActionItem,
                        onChanged: (val) {
                          setState(() {
                            _draftAction = val;
                          });
                        },
                        decoration: _buildCompactDropdownDecoration(context),
                        disabledDecoration:
                            buildCustomDropdownDisabledDecoration(context),
                      ),
                      AppSpacing.vGapMd,
                    ],

                    // ── Section 4: Date Range Presets ──────────────────────
                    Text(
                      'Date Range',
                      style: textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _ActivityDatePreset.values.map((preset) {
                        final isSelected = _datePreset == preset;
                        return ChoiceChip(
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                          label: Text(preset.label),
                          selected: isSelected,
                          showCheckmark: false,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? scheme.onPrimary
                                : scheme.onSurface,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 11.5,
                          ),
                          selectedColor: scheme.primary,
                          backgroundColor: scheme.surfaceContainerLow,
                          side: BorderSide(
                            color: isSelected
                                ? scheme.primary
                                : scheme.outlineVariant.withValues(alpha: 0.6),
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onSelected: (_) => _onPresetSelected(preset),
                        );
                      }).toList(),
                    ),

                    // Date Display (if active)
                    if (_draftStartDate != null || _draftEndDate != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: scheme.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Iconsax.calendar,
                                size: 14, color: scheme.primary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${_draftStartDate != null ? DateFormat('MMM d, yyyy').format(_draftStartDate!) : 'Any'} → ${_draftEndDate != null ? DateFormat('MMM d, yyyy').format(_draftEndDate!) : 'Any'}',
                                style: textTheme.bodySmall?.copyWith(
                                  color: scheme.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11.5,
                                ),
                              ),
                            ),
                            InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () {
                                setState(() {
                                  _draftStartDate = null;
                                  _draftEndDate = null;
                                  _datePreset = _ActivityDatePreset.allTime;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 15,
                                  color: scheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    AppSpacing.vGapSm,
                  ],
                ),
              ),
            ),

            const Divider(height: 1),

            // ── Pinned Bottom Action Bar ─────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: OutlinedButton.icon(
                      onPressed: _activeFilterCount > 0 ? _reset : null,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      icon: const Icon(Iconsax.rotate_left, size: 15),
                      label: const Text(
                        'Reset All',
                        style: TextStyle(fontSize: 12.5),
                      ),
                    ),
                  ),
                  AppSpacing.gapSm,
                  Expanded(
                    flex: 3,
                    child: FilledButton.icon(
                      onPressed: _apply,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: Text(
                        _activeFilterCount > 0
                            ? 'Apply Filters ($_activeFilterCount)'
                            : 'Apply Filters',
                        style: const TextStyle(fontSize: 12.5),
                      ),
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

  CustomDropdownDecoration _buildCompactDropdownDecoration(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return CustomDropdownDecoration(
      closedFillColor: scheme.surfaceContainerLow,
      expandedFillColor: scheme.surfaceContainerLow,
      expandedBorder: Border.all(color: scheme.primary, width: 1.2),
      closedBorder: Border.all(
        color: scheme.outlineVariant.withValues(alpha: 0.6),
        width: 1,
      ),
      closedBorderRadius: BorderRadius.circular(10),
      expandedBorderRadius: BorderRadius.circular(10),
      searchFieldDecoration: SearchFieldDecoration(
        fillColor: Colors.transparent,
        hintStyle: textTheme.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
          fontSize: 12,
        ),
        textStyle: textTheme.bodySmall?.copyWith(
          color: scheme.onSurface,
          fontSize: 12,
        ),
        contentPadding: EdgeInsets.zero,
      ),
      closedErrorBorder: Border.all(
        color: scheme.error,
        width: 1,
      ),
      closedErrorBorderRadius: BorderRadius.circular(10),
      headerStyle: textTheme.bodySmall?.copyWith(
        color: scheme.onSurface,
        fontWeight: FontWeight.w500,
        fontSize: 12.5,
      ),
      hintStyle: textTheme.bodySmall?.copyWith(
        color: scheme.onSurfaceVariant,
        fontSize: 12.5,
      ),
      listItemStyle: textTheme.bodySmall?.copyWith(
        color: scheme.onSurface,
        fontSize: 12.5,
      ),
      listItemDecoration: ListItemDecoration(
        selectedColor: scheme.primary.withValues(alpha: 0.12),
        highlightColor: scheme.surfaceContainerHighest,
      ),
    );
  }
}
