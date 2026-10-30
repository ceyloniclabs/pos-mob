import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_floating_bottom_sheet.dart';
import '../controllers/sale_item_list_controller.dart';

class SaleItemFilterSheet extends StatefulWidget {
  const SaleItemFilterSheet({
    super.key,
    required this.controller,
  });

  final SaleItemListController controller;

  static void show(BuildContext context, SaleItemListController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      isDismissible: true,
      enableDrag: false,
      builder: (context) => SaleItemFilterSheet(controller: controller),
    );
  }

  @override
  State<SaleItemFilterSheet> createState() => _SaleItemFilterSheetState();
}

class _SaleItemFilterSheetState extends State<SaleItemFilterSheet> {
  late int? _draftCategoryId;
  late int? _draftBrandId;
  late bool? _draftIsActive;

  @override
  void initState() {
    super.initState();
    _draftCategoryId = widget.controller.selectedCategoryId.value;
    _draftBrandId = widget.controller.selectedBrandId.value;
    _draftIsActive = widget.controller.selectedIsActive.value;
  }

  int get _activeFilterCount {
    int count = 0;
    if (_draftCategoryId != null) count++;
    if (_draftBrandId != null) count++;
    if (_draftIsActive != null) count++;
    return count;
  }

  bool get _hasChanges {
    return _draftCategoryId != widget.controller.selectedCategoryId.value ||
        _draftBrandId != widget.controller.selectedBrandId.value ||
        _draftIsActive != widget.controller.selectedIsActive.value;
  }

  void _reset() {
    setState(() {
      _draftCategoryId = null;
      _draftBrandId = null;
      _draftIsActive = null;
    });
  }

  void _apply() {
    widget.controller.selectedCategoryId.value = _draftCategoryId;
    widget.controller.selectedBrandId.value = _draftBrandId;
    widget.controller.selectedIsActive.value = _draftIsActive;
    widget.controller.pagingController.refresh();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final categories = widget.controller.categories;
    final allBrands = widget.controller.brands;
    final filteredBrands = _draftCategoryId != null
        ? allBrands
            .where((b) => b.saleCategoryId == _draftCategoryId)
            .toList()
        : allBrands.toList();

    return AppFloatingBottomSheet(
      title: 'Filter Sale Items',
      subtitle: 'Narrow list by status, category, and brand',
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
              onPressed: (_activeFilterCount > 0 || _hasChanges) ? _reset : null,
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

          // ── Status Filter ────────────────────────────────────────────────
          Text(
            'ITEM STATUS',
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
                label: 'All Status',
                icon: Iconsax.status,
                isSelected: _draftIsActive == null,
                onTap: () => setState(() => _draftIsActive = null),
              ),
              _FilterOptionChip(
                label: 'Active',
                accentColor: const Color(0xFF10B981),
                isSelected: _draftIsActive == true,
                onTap: () => setState(() => _draftIsActive = true),
              ),
              _FilterOptionChip(
                label: 'Inactive',
                accentColor: theme.colorScheme.error,
                isSelected: _draftIsActive == false,
                onTap: () => setState(() => _draftIsActive = false),
              ),
            ],
          ),
          AppSpacing.gapMd,

          // ── Category Filter ──────────────────────────────────────────────
          if (categories.isNotEmpty) ...[
            Text(
              'CATEGORY',
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
                  isSelected: _draftCategoryId == null,
                  onTap: () => setState(() {
                    _draftCategoryId = null;
                  }),
                ),
                for (final cat in categories)
                  _FilterOptionChip(
                    label: cat.name,
                    icon: Iconsax.folder,
                    isSelected: _draftCategoryId == cat.id,
                    onTap: () => setState(() {
                      _draftCategoryId = cat.id;
                      // Deselect brand if it does not belong to the selected category
                      if (_draftBrandId != null) {
                        final currentBrand = allBrands.firstWhereOrNull(
                          (b) => b.id == _draftBrandId,
                        );
                        if (currentBrand != null &&
                            currentBrand.saleCategoryId != cat.id) {
                          _draftBrandId = null;
                        }
                      }
                    }),
                  ),
              ],
            ),
            AppSpacing.gapMd,
          ],

          // ── Brand Filter ─────────────────────────────────────────────────
          if (filteredBrands.isNotEmpty) ...[
            Text(
              'BRAND',
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
                  label: 'All Brands',
                  icon: Iconsax.award,
                  isSelected: _draftBrandId == null,
                  onTap: () => setState(() => _draftBrandId = null),
                ),
                for (final brand in filteredBrands)
                  _FilterOptionChip(
                    label: brand.name,
                    icon: Iconsax.tag,
                    isSelected: _draftBrandId == brand.id,
                    onTap: () => setState(() => _draftBrandId = brand.id),
                  ),
              ],
            ),
            AppSpacing.gapSm,
          ],
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
