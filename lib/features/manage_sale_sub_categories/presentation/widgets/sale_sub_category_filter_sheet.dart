import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_floating_bottom_sheet.dart';
import '../controllers/sale_sub_category_list_controller.dart';

class SaleSubCategoryFilterSheet extends StatefulWidget {
  const SaleSubCategoryFilterSheet({
    super.key,
    required this.controller,
  });

  final SaleSubCategoryListController controller;

  static void show(
    BuildContext context,
    SaleSubCategoryListController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      isDismissible: true,
      enableDrag: false,
      builder: (context) => SaleSubCategoryFilterSheet(controller: controller),
    );
  }

  @override
  State<SaleSubCategoryFilterSheet> createState() =>
      _SaleSubCategoryFilterSheetState();
}

class _SaleSubCategoryFilterSheetState
    extends State<SaleSubCategoryFilterSheet> {
  late int _draftCategoryId;

  @override
  void initState() {
    super.initState();
    _draftCategoryId = widget.controller.selectedFilterCategoryId.value;
  }

  bool get _hasActiveFilters => _draftCategoryId > 0;

  bool get _hasChanges =>
      _draftCategoryId != widget.controller.selectedFilterCategoryId.value;

  void _reset() {
    setState(() {
      _draftCategoryId = -1;
    });
  }

  void _apply() {
    widget.controller.selectedFilterCategoryId.value = _draftCategoryId;
    widget.controller.pagingController.refresh();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final categories = widget.controller.saleCategoryList;

    return AppFloatingBottomSheet(
      title: 'Filter Sub-Categories',
      subtitle: 'Narrow list by parent sale category',
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
              onPressed: (_hasActiveFilters || _hasChanges) ? _reset : null,
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
                _hasActiveFilters ? 'Apply Filters (1)' : 'Apply Filters',
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
            'PARENT SALE CATEGORY',
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
                label: 'All Categories',
                icon: Iconsax.category_2,
                isSelected: _draftCategoryId <= 0,
                onTap: () => setState(() => _draftCategoryId = -1),
              ),
              for (final cat in categories)
                _FilterOptionChip(
                  label: cat.name,
                  icon: Iconsax.folder,
                  isSelected: _draftCategoryId == cat.id,
                  onTap: () => setState(() => _draftCategoryId = cat.id),
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
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
            vertical: 6.0,
          ),
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
              if (icon != null)
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
