import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/widgets/app_filter_bottom_sheet.dart';
import '../controllers/sale_controller.dart';

class SaleFilterSheet extends StatefulWidget {
  const SaleFilterSheet({
    super.key,
    required this.controller,
  });

  final SaleController controller;

  static Future<void> show(
    BuildContext context, {
    required SaleController controller,
  }) {
    return AppFilterBottomSheet.show<void>(
      context: context,
      builder: (context) => SaleFilterSheet(controller: controller),
    );
  }

  @override
  State<SaleFilterSheet> createState() => _SaleFilterSheetState();
}

class _SaleFilterSheetState extends State<SaleFilterSheet> {
  static const List<String> _statuses = [
    'all',
    'completed',
    'pending',
    'draft',
  ];

  late String _draftStatus;
  DateTime? _draftDate;

  @override
  void initState() {
    super.initState();
    _draftStatus = widget.controller.selectedStatus.value;
    _draftDate = widget.controller.selectedDate.value;
  }

  int get _activeFilterCount {
    int count = 0;
    if (_draftStatus != 'all') count++;
    if (_draftDate != null) count++;
    return count;
  }

  void _reset() {
    setState(() {
      _draftStatus = 'all';
      _draftDate = null;
    });
  }

  void _apply() {
    widget.controller.selectedStatus.value = _draftStatus;
    widget.controller.selectedDate.value = _draftDate;
    widget.controller.pagingController.refresh();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppFilterBottomSheet(
      title: 'Filter Sales',
      subtitle: 'Narrow sales by status and date',
      isFloating: false,
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.xxs),
        decoration: BoxDecoration(
          color: scheme.primary.withValues(alpha: 0.12),
          borderRadius: AppRadius.smAll,
        ),
        child: Icon(
          Iconsax.filter_search,
          color: scheme.primary,
          size: 18,
        ),
      ),
      activeFilterCount: _activeFilterCount,
      onReset: _reset,
      onApply: _apply,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sale Status Section
          Text(
            'Sale Status',
            style: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          AppSpacing.vGapXs,
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: _statuses.map((status) {
              final isSelected = _draftStatus == status;
              final labelText = status == 'all'
                  ? 'All Statuses'
                  : status.capitalizeFirst ?? status;

              return ChoiceChip(
                label: Text(labelText),
                selected: isSelected,
                showCheckmark: false,
                labelStyle: TextStyle(
                  color: isSelected ? scheme.onPrimary : scheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
                selectedColor: scheme.primary,
                backgroundColor: scheme.surfaceContainerLow,
                side: BorderSide(
                  color: isSelected ? scheme.primary : scheme.outlineVariant,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.smAll,
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _draftStatus = status;
                    });
                  }
                },
              );
            }).toList(),
          ),

          AppSpacing.vGapMd,

          // Date Filter Section
          Text(
            'Filter by Date',
            style: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          AppSpacing.vGapXs,
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _draftDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() {
                        _draftDate = picked;
                      });
                    }
                  },
                  borderRadius: AppRadius.smAll,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLow,
                      borderRadius: AppRadius.smAll,
                      border: Border.all(
                        color: _draftDate != null
                            ? scheme.primary
                            : scheme.outlineVariant,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Iconsax.calendar_1,
                          size: 18,
                          color: _draftDate != null
                              ? scheme.primary
                              : scheme.onSurfaceVariant,
                        ),
                        AppSpacing.hGapSm,
                        Expanded(
                          child: Text(
                            _draftDate != null
                                ? DateFormat('EEE, MMM dd, yyyy')
                                    .format(_draftDate!)
                                : 'Pick a specific date...',
                            style: textTheme.bodyMedium?.copyWith(
                              color: _draftDate != null
                                  ? scheme.onSurface
                                  : scheme.onSurfaceVariant,
                              fontWeight: _draftDate != null
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_draftDate != null) ...[
                AppSpacing.hGapXs,
                IconButton(
                  tooltip: 'Clear Date',
                  onPressed: () {
                    setState(() {
                      _draftDate = null;
                    });
                  },
                  icon: const Icon(Icons.close_rounded, size: 20),
                ),
              ],
            ],
          ),
          AppSpacing.vGapSm,
        ],
      ),
    );
  }
}
