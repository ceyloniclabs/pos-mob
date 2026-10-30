import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/enums.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_floating_bottom_sheet.dart';
import '../controllers/promo_code_controller.dart';

class PromoCodeFilterSheet extends StatefulWidget {
  const PromoCodeFilterSheet({
    super.key,
    required this.controller,
  });

  final PromoCodeController controller;

  static void show(BuildContext context, PromoCodeController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      isDismissible: true,
      enableDrag: false,
      builder: (context) => PromoCodeFilterSheet(controller: controller),
    );
  }

  @override
  State<PromoCodeFilterSheet> createState() => _PromoCodeFilterSheetState();
}

class _PromoCodeFilterSheetState extends State<PromoCodeFilterSheet> {
  late PromoCodeStatus _draftStatus;

  @override
  void initState() {
    super.initState();
    _draftStatus = widget.controller.selectedStatus.value;
  }

  int get _activeFilterCount {
    int count = 0;
    if (_draftStatus != PromoCodeStatus.all) count++;
    return count;
  }

  bool get _hasChanges {
    return _draftStatus != widget.controller.selectedStatus.value;
  }

  void _reset() {
    setState(() {
      _draftStatus = PromoCodeStatus.all;
    });
  }

  void _apply() {
    widget.controller.selectedStatus.value = _draftStatus;
    widget.controller.fetchPromoCodes();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return AppFloatingBottomSheet(
      title: 'Filter Promo Codes',
      subtitle: 'Narrow list by code status',
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
          Text(
            'PROMO CODE STATUS',
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
                label: 'All Codes',
                icon: Iconsax.discount_shape,
                isSelected: _draftStatus == PromoCodeStatus.all,
                onTap: () => setState(() => _draftStatus = PromoCodeStatus.all),
              ),
              _FilterOptionChip(
                label: 'Active',
                accentColor: const Color(0xFF10B981),
                isSelected: _draftStatus == PromoCodeStatus.active,
                onTap: () => setState(() => _draftStatus = PromoCodeStatus.active),
              ),
              _FilterOptionChip(
                label: 'Inactive',
                accentColor: theme.colorScheme.error,
                isSelected: _draftStatus == PromoCodeStatus.inactive,
                onTap: () => setState(() => _draftStatus = PromoCodeStatus.inactive),
              ),
            ],
          ),
          AppSpacing.gapMd,
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
