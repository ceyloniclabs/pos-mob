import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_floating_bottom_sheet.dart';
import '../controllers/sale_create_controller.dart';

class SaleCategoryFilterSheet extends StatefulWidget {
  const SaleCategoryFilterSheet({
    super.key,
    required this.controller,
  });

  final SaleCreateController controller;

  static void show(BuildContext context, SaleCreateController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      isDismissible: true,
      enableDrag: false,
      builder: (context) => SaleCategoryFilterSheet(controller: controller),
    );
  }

  @override
  State<SaleCategoryFilterSheet> createState() =>
      _SaleCategoryFilterSheetState();
}

class _SaleCategoryFilterSheetState extends State<SaleCategoryFilterSheet> {
  String? _draftCategory;

  @override
  void initState() {
    super.initState();
    _draftCategory = widget.controller.selectedCategory.value;
  }

  bool get _hasFilter => _draftCategory != null;

  bool get _hasChanges =>
      _draftCategory != widget.controller.selectedCategory.value;

  void _reset() {
    setState(() {
      _draftCategory = null;
    });
  }

  void _apply() {
    widget.controller.selectedCategory.value = _draftCategory;
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final categories = widget.controller.availableCategories;

    return AppFloatingBottomSheet(
      isFloating: false,
      title: 'Filter Products',
      subtitle: 'Filter items by product category',
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
              onPressed: (_hasFilter || _hasChanges) ? _reset : null,
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
                _draftCategory != null
                    ? 'Apply Filter (1)'
                    : 'Apply Filter',
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
            'CATEGORIES',
            style: textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w700,
            ),
          ),
          AppSpacing.gapSm,
          if (categories.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Center(
                child: Text(
                  'No categories available',
                  style: textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                _CategoryChip(
                  label: 'All Categories',
                  icon: Iconsax.category,
                  isSelected: _draftCategory == null,
                  onTap: () => setState(() => _draftCategory = null),
                ),
                ...categories.map(
                  (cat) => _CategoryChip(
                    label: cat,
                    icon: Iconsax.box,
                    isSelected: _draftCategory == cat,
                    onTap: () => setState(() => _draftCategory = cat),
                  ),
                ),
              ],
            ),
          AppSpacing.gapSm,
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
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
