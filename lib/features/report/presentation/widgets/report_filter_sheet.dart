import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/widgets/app_filter_bottom_sheet.dart';

import '../../domain/entities/report_filter.dart';
import '../../domain/entities/report_type.dart';
import '../../domain/validators/report_validator.dart';
import '../controllers/report_controller.dart';
import '../models/report_definition.dart';

enum _DatePreset {
  allTime('All Time', Iconsax.calendar_tick),
  today('Today', Iconsax.clock),
  thisWeek('This Week', Iconsax.calendar_1),
  thisMonth('This Month', Iconsax.calendar),
  last30Days('Last 30 Days', Iconsax.calendar_circle),
  thisYear('This Year', Iconsax.archive_book),
  custom('Custom', Iconsax.calendar_edit);

  final String label;
  final IconData icon;

  const _DatePreset(this.label, this.icon);
}

/// Redesigned Report Filter Bottom Sheet conforming to Material 3 & flutter-uiux-design guidelines.
/// Features:
/// - Floating bottom sheet layout with smooth drag-to-expand / drag-to-dismiss
/// - Pinned bottom action bar with reactive loading state & reset functionality
/// - Distinct grouped section cards with semantic icons and clean visual hierarchy
/// - Dynamic chip filters with active status tints and badges
/// - Quick date presets (Today, This Week, This Month, Last 30 Days, This Year) + calendar range picker
/// - Text field clear actions and reactive active filter counter
class ReportFilterSheet extends StatefulWidget {
  const ReportFilterSheet({
    super.key,
    required this.definition,
    required this.controller,
  });

  final ReportDefinition definition;
  final ReportController controller;

  static Future<void> show(
    BuildContext context, {
    required ReportDefinition definition,
    required ReportController controller,
  }) {
    return AppFilterBottomSheet.show<void>(
      context: context,
      builder: (context) => ReportFilterSheet(
        definition: definition,
        controller: controller,
      ),
    );
  }

  @override
  State<ReportFilterSheet> createState() => _ReportFilterSheetState();
}

class _ReportFilterSheetState extends State<ReportFilterSheet> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();

  String _customerType = 'all';
  String _rentalStatus = 'all';
  String _saleStatus = 'all';
  String _stockStatus = 'all';
  String _resolutionStatus = 'all';

  DateTime? _fromDate;
  DateTime? _toDate;
  _DatePreset _datePreset = _DatePreset.allTime;
  String? _dateRangeError;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onFieldChanged);
    _categoryController.addListener(_onFieldChanged);
    _brandController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _searchController.removeListener(_onFieldChanged);
    _categoryController.removeListener(_onFieldChanged);
    _brandController.removeListener(_onFieldChanged);
    _searchController.dispose();
    _categoryController.dispose();
    _brandController.dispose();
    super.dispose();
  }

  int get _activeFilterCount {
    int count = 0;
    switch (widget.definition.type) {
      case ReportType.customerList:
        if (_searchController.text.trim().isNotEmpty) count++;
        if (_customerType != 'all') count++;
        break;
      case ReportType.sales:
        if (_saleStatus != 'all') count++;
        if (_fromDate != null || _toDate != null) count++;
        break;
      case ReportType.salesInventory:
        if (_categoryController.text.trim().isNotEmpty) count++;
        if (_brandController.text.trim().isNotEmpty) count++;
        if (_stockStatus != 'all') count++;
        break;
    }
    return count;
  }

  void _setDatePreset(_DatePreset preset) {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    setState(() {
      _datePreset = preset;
      _dateRangeError = null;

      switch (preset) {
        case _DatePreset.allTime:
          _fromDate = null;
          _toDate = null;
          break;
        case _DatePreset.today:
          _fromDate = today;
          _toDate = today;
          break;
        case _DatePreset.thisWeek:
          _fromDate = today.subtract(Duration(days: today.weekday - 1));
          _toDate = today;
          break;
        case _DatePreset.thisMonth:
          _fromDate = DateTime(now.year, now.month, 1);
          _toDate = today;
          break;
        case _DatePreset.last30Days:
          _fromDate = today.subtract(const Duration(days: 30));
          _toDate = today;
          break;
        case _DatePreset.thisYear:
          _fromDate = DateTime(now.year, 1, 1);
          _toDate = today;
          break;
        case _DatePreset.custom:
          break;
      }
    });
  }

  Future<void> _openDateRangePicker() async {
    final now = DateTime.now();
    final initialRange = (_fromDate != null && _toDate != null)
        ? DateTimeRange(start: _fromDate!, end: _toDate!)
        : (_fromDate != null)
            ? DateTimeRange(start: _fromDate!, end: _fromDate!)
            : null;

    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: initialRange,
      firstDate: DateTime(2020),
      lastDate: now.add(const Duration(days: 365 * 3)),
      helpText: 'Select Date Range',
      saveText: 'Apply',
    );

    if (picked != null) {
      HapticFeedback.selectionClick();
      setState(() {
        _fromDate = picked.start;
        _toDate = picked.end;
        _datePreset = _DatePreset.custom;
        _dateRangeError = null;
      });
    }
  }

  Future<void> _pickSingleDate({required bool isFrom}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom
          ? (_fromDate ?? now)
          : (_toDate ?? _fromDate ?? now),
      firstDate: DateTime(2020),
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (picked == null) return;

    HapticFeedback.selectionClick();
    setState(() {
      if (isFrom) {
        _fromDate = picked;
        if (_toDate != null && _toDate!.isBefore(picked)) {
          _toDate = null;
        }
      } else {
        _toDate = picked;
      }
      _datePreset = _DatePreset.custom;
      _dateRangeError = null;
    });
  }

  void _resetFilters() {
    HapticFeedback.lightImpact();
    setState(() {
      _searchController.clear();
      _categoryController.clear();
      _brandController.clear();
      _customerType = 'all';
      _rentalStatus = 'all';
      _saleStatus = 'all';
      _stockStatus = 'all';
      _resolutionStatus = 'all';
      _fromDate = null;
      _toDate = null;
      _datePreset = _DatePreset.allTime;
      _dateRangeError = null;
    });
  }

  Future<void> _generateReport() async {
    final validationError =
        ReportValidator.validateDateRange(_fromDate, _toDate);
    if (validationError != null) {
      HapticFeedback.heavyImpact();
      setState(() {
        _dateRangeError = validationError;
      });
      return;
    }

    final request = ReportFilter(
      search: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
      customerType: _customerType,
      rentalStatus: _rentalStatus,
      fromDate: _fromDate,
      toDate: _toDate,
      saleStatus: _saleStatus,
      category: _categoryController.text.trim().isEmpty
          ? null
          : _categoryController.text.trim(),
      brand: _brandController.text.trim().isEmpty
          ? null
          : _brandController.text.trim(),
      stockStatus: _stockStatus,
      resolutionStatus: _resolutionStatus,
    );

    final file = await widget.controller.generateReport(
      widget.definition.type,
      request,
    );

    if (file != null && mounted) {
      Navigator.of(context).pop();
      widget.controller.openPdfPreview(file, widget.definition.type);
    }
  }

  String _getSubtitle() {
    switch (widget.definition.type) {
      case ReportType.customerList:
        return 'Filter customers & export directory PDF';
      case ReportType.sales:
        return 'Filter transactions & export revenue PDF';
      case ReportType.salesInventory:
        return 'Filter inventory by stock, brand & category';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppFilterBottomSheet(
        isFloating: false,
        title: widget.definition.title,
        subtitle: _getSubtitle(),
        maxHeightFactor: 0.90,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: widget.definition.gradient,
            borderRadius: AppRadius.mdAll,
            boxShadow: [
              BoxShadow(
                color: (widget.definition.gradient.colors.firstOrNull ??
                        Theme.of(context).colorScheme.primary)
                    .withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            widget.definition.icon,
            color: Colors.white,
            size: 22,
          ),
        ),
        activeFilterCount: _activeFilterCount,
        onReset: _resetFilters,
        onApply: _generateReport,
        applyLabel: 'Generate PDF',
        applyIcon: Iconsax.document_download,
        isLoading: widget.controller.isGenerating.value,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFilterSections(context),
            AppSpacing.vGapXs,
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSections(BuildContext context) {
    switch (widget.definition.type) {
      case ReportType.customerList:
        return _buildCustomerListFilters(context);
      case ReportType.sales:
        return _buildSalesFilters(context);
      case ReportType.salesInventory:
        return _buildSalesInventoryFilters(context);
    }
  }

  // ── Customer List Filters ────────────────────────────────────────────────
  Widget _buildCustomerListFilters(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FilterSection(
          title: 'Search Directory',
          icon: Iconsax.search_normal_1,
          child: TextFormField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search by name, phone, or email',
              prefixIcon: const Icon(Iconsax.search_normal, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      tooltip: 'Clear search',
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        _searchController.clear();
                      },
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _FilterSection(
          title: 'Customer Type',
          icon: Iconsax.profile_2user,
          badge: _customerType != 'all' ? 'Filtered' : null,
          child: _FilterChipGroup<String>(
            options: const [
              _ChipOption('all', 'All Customers', Iconsax.people),
              _ChipOption('local', 'Local', Iconsax.user, Color(0xFF0284C7)),
              _ChipOption('foreign', 'Foreign', Iconsax.global, Color(0xFF7C3AED)),
            ],
            selectedValue: _customerType,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              setState(() => _customerType = val);
            },
          ),
        ),
      ],
    );
  }

  // ── Sales Filters ────────────────────────────────────────────────────────
  Widget _buildSalesFilters(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FilterSection(
          title: 'Sale Status',
          icon: Iconsax.receipt_2_1,
          badge: _saleStatus != 'all' ? 'Filtered' : null,
          child: _FilterChipGroup<String>(
            options: const [
              _ChipOption('all', 'All Statuses', Iconsax.layer),
              _ChipOption('pending', 'Pending', Iconsax.clock, Color(0xFFF59E0B)),
              _ChipOption('completed', 'Completed', Iconsax.tick_circle, Color(0xFF10B981)),
              _ChipOption('cancelled', 'Cancelled', Iconsax.close_circle, Color(0xFF6B7280)),
            ],
            selectedValue: _saleStatus,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              setState(() => _saleStatus = val);
            },
          ),
        ),
        const SizedBox(height: 24),
        _buildDateRangeSection(context, title: 'Transaction Period'),
      ],
    );
  }

  // ── Sales Inventory Filters ──────────────────────────────────────────────
  Widget _buildSalesInventoryFilters(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FilterSection(
          title: 'Inventory Details',
          icon: Iconsax.box_1,
          child: Column(
            children: [
              TextFormField(
                controller: _categoryController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Category',
                  hintText: 'e.g., Shortboard, Wetsuit, Leash',
                  prefixIcon: const Icon(Iconsax.category, size: 20),
                  suffixIcon: _categoryController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          tooltip: 'Clear category',
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            _categoryController.clear();
                          },
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _brandController,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'Brand',
                  hintText: 'e.g., Channel Islands, Pyzel, Torq',
                  prefixIcon: const Icon(Iconsax.tag, size: 20),
                  suffixIcon: _brandController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          tooltip: 'Clear brand',
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            _brandController.clear();
                          },
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _FilterSection(
          title: 'Stock Availability',
          icon: Iconsax.layer,
          badge: _stockStatus != 'all' ? 'Filtered' : null,
          child: _FilterChipGroup<String>(
            options: const [
              _ChipOption('all', 'All Stock', Iconsax.layer),
              _ChipOption('in_stock', 'In Stock', Iconsax.box_tick, Color(0xFF10B981)),
              _ChipOption('low_stock', 'Low Stock', Iconsax.box_time, Color(0xFFF59E0B)),
              _ChipOption('out_of_stock', 'Out of Stock', Iconsax.box_remove, Color(0xFFEF4444)),
            ],
            selectedValue: _stockStatus,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              setState(() => _stockStatus = val);
            },
          ),
        ),
      ],
    );
  }

  // ── Shared Date Range Section ────────────────────────────────────────────
  Widget _buildDateRangeSection(BuildContext context, {required String title}) {
    final hasDates = _fromDate != null || _toDate != null;
    return _FilterSection(
      title: title,
      icon: Iconsax.calendar_1,
      badge: hasDates ? 'Filtered' : null,
      trailing: TextButton.icon(
        style: TextButton.styleFrom(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
        icon: const Icon(Iconsax.calendar_search, size: 16),
        label: const Text('Calendar'),
        onPressed: _openDateRangePicker,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick presets wrapped cleanly on 2 lines (NO horizontal scroll)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _DatePreset.values
                .where((p) => p != _DatePreset.custom)
                .map((preset) {
              final isSelected = _datePreset == preset;
              return _PresetPill(
                label: preset.label,
                icon: preset.icon,
                isSelected: isSelected,
                onTap: () => _setDatePreset(preset),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Date Tiles Row
          _DateRangeSelector(
            fromDate: _fromDate,
            toDate: _toDate,
            onFromTap: () => _pickSingleDate(isFrom: true),
            onToTap: () => _pickSingleDate(isFrom: false),
            onClear: () {
              HapticFeedback.selectionClick();
              _setDatePreset(_DatePreset.allTime);
            },
            errorText: _dateRangeError,
          ),
        ],
      ),
    );
  }
}

// ── Supporting UI Components ────────────────────────────────────────────────

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.title,
    required this.icon,
    required this.child,
    this.badge,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final String? badge;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: AppRadius.smAll,
              ),
              child: Icon(
                icon,
                size: 16,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (badge != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: AppRadius.fullAll,
                      ),
                      child: Text(
                        badge!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ?trailing,
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _ChipOption<T> {
  final T value;
  final String label;
  final IconData? icon;
  final Color? accentColor;

  const _ChipOption(this.value, this.label, [this.icon, this.accentColor]);
}

class _FilterChipGroup<T> extends StatelessWidget {
  const _FilterChipGroup({
    required this.options,
    required this.selectedValue,
    required this.onChanged,
  });

  final List<_ChipOption<T>> options;
  final T selectedValue;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((opt) {
        final isSelected = opt.value == selectedValue;
        return _FilterChipItem(
          label: opt.label,
          icon: opt.icon,
          isSelected: isSelected,
          accentColor: opt.accentColor,
          onTap: () => onChanged(opt.value),
        );
      }).toList(),
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  const _FilterChipItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.accentColor,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = accentColor ?? theme.colorScheme.primary;

    final bgColor = isSelected
        ? effectiveColor.withValues(alpha: 0.12)
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45);

    final borderColor = isSelected
        ? effectiveColor
        : theme.colorScheme.outlineVariant.withValues(alpha: 0.55);

    final textColor = isSelected
        ? (accentColor != null ? effectiveColor : theme.colorScheme.primary)
        : theme.colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 15,
                color:
                    isSelected ? textColor : textColor.withValues(alpha: 0.75),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: textColor,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Icon(
                Icons.check_rounded,
                size: 15,
                color: textColor,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PresetPill extends StatelessWidget {
  const _PresetPill({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateRangeSelector extends StatelessWidget {
  const _DateRangeSelector({
    required this.fromDate,
    required this.toDate,
    required this.onFromTap,
    required this.onToTap,
    required this.onClear,
    this.errorText,
  });

  final DateTime? fromDate;
  final DateTime? toDate;
  final VoidCallback onFromTap;
  final VoidCallback onToTap;
  final VoidCallback onClear;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = errorText != null;
    final hasDates = fromDate != null || toDate != null;

    int? durationDays;
    if (fromDate != null && toDate != null && !fromDate!.isAfter(toDate!)) {
      durationDays = toDate!.difference(fromDate!).inDays + 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _DateTileBox(
                label: 'Start Date',
                value: fromDate == null
                    ? 'Select date'
                    : DateFormat('MMM dd, yyyy').format(fromDate!),
                icon: Iconsax.calendar_1,
                isActive: fromDate != null,
                onTap: onFromTap,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                Iconsax.arrow_right_3,
                size: 16,
                color: theme.colorScheme.outlineVariant,
              ),
            ),
            Expanded(
              child: _DateTileBox(
                label: 'End Date',
                value: toDate == null
                    ? 'Select date'
                    : DateFormat('MMM dd, yyyy').format(toDate!),
                icon: Iconsax.calendar,
                isActive: toDate != null,
                onTap: onToTap,
              ),
            ),
          ],
        ),
        if (hasError) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 15,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    errorText!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (hasDates) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              if (durationDays != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Iconsax.timer_1,
                        size: 13,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        durationDays == 1
                            ? '1 day duration'
                            : '$durationDays days duration',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              TextButton.icon(
                onPressed: onClear,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: theme.colorScheme.error,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                icon: const Icon(Icons.close_rounded, size: 14),
                label: const Text('Clear dates'),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _DateTileBox extends StatelessWidget {
  const _DateTileBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? theme.colorScheme.primary.withValues(alpha: 0.08)
              : theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
            width: isActive ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 15,
                  color: isActive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isActive
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
