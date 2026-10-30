import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/enums.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_floating_bottom_sheet.dart';
import '../controllers/customer_list_controller.dart';

class CustomerFilterSheet extends StatefulWidget {
  const CustomerFilterSheet({
    super.key,
    required this.controller,
  });

  final CustomerListController controller;

  static void show(BuildContext context, CustomerListController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      isDismissible: true,
      enableDrag: false,
      builder: (context) => CustomerFilterSheet(controller: controller),
    );
  }

  @override
  State<CustomerFilterSheet> createState() => _CustomerFilterSheetState();
}

class _CustomerFilterSheetState extends State<CustomerFilterSheet> {
  late CustomerFilterType _draftType;
  late MembershipFilterLevel _draftMembership;

  @override
  void initState() {
    super.initState();
    _draftType = widget.controller.selectedType.value;
    _draftMembership = widget.controller.selectedMembership.value;
  }

  int get _activeFilterCount {
    int count = 0;
    if (_draftType != CustomerFilterType.all) count++;
    if (_draftMembership != MembershipFilterLevel.all) count++;
    return count;
  }

  bool get _hasChanges {
    return _draftType != widget.controller.selectedType.value ||
        _draftMembership != widget.controller.selectedMembership.value;
  }

  void _reset() {
    setState(() {
      _draftType = CustomerFilterType.all;
      _draftMembership = MembershipFilterLevel.all;
    });
  }

  void _apply() {
    widget.controller.selectedType.value = _draftType;
    widget.controller.selectedMembership.value = _draftMembership;
    widget.controller.pagingController.refresh();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return AppFloatingBottomSheet(
      title: 'Filter Customers',
      subtitle: 'Narrow list by type and membership',
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
            'CUSTOMER TYPE',
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
                label: 'All Types',
                icon: Iconsax.people,
                isSelected: _draftType == CustomerFilterType.all,
                onTap: () => setState(() => _draftType = CustomerFilterType.all),
              ),
              _FilterOptionChip(
                label: 'Local',
                icon: Iconsax.location,
                isSelected: _draftType == CustomerFilterType.local,
                onTap: () => setState(() => _draftType = CustomerFilterType.local),
              ),
              _FilterOptionChip(
                label: 'Foreigner',
                icon: Iconsax.global,
                isSelected: _draftType == CustomerFilterType.foreigner,
                onTap: () => setState(() => _draftType = CustomerFilterType.foreigner),
              ),
            ],
          ),
          AppSpacing.gapMd,
          Text(
            'MEMBERSHIP TIER',
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
                label: 'All Tiers',
                icon: Iconsax.medal,
                isSelected: _draftMembership == MembershipFilterLevel.all,
                onTap: () => setState(() => _draftMembership = MembershipFilterLevel.all),
              ),
              _FilterOptionChip(
                label: 'Bronze',
                accentColor: const Color(0xFFCD7F32),
                isSelected: _draftMembership == MembershipFilterLevel.bronze,
                onTap: () => setState(() => _draftMembership = MembershipFilterLevel.bronze),
              ),
              _FilterOptionChip(
                label: 'Silver',
                accentColor: const Color(0xFF94A3B8),
                isSelected: _draftMembership == MembershipFilterLevel.silver,
                onTap: () => setState(() => _draftMembership = MembershipFilterLevel.silver),
              ),
              _FilterOptionChip(
                label: 'Gold',
                accentColor: const Color(0xFFEAB308),
                isSelected: _draftMembership == MembershipFilterLevel.gold,
                onTap: () => setState(() => _draftMembership = MembershipFilterLevel.gold),
              ),
              _FilterOptionChip(
                label: 'Platinum',
                accentColor: const Color(0xFFA855F7),
                isSelected: _draftMembership == MembershipFilterLevel.platinum,
                onTap: () => setState(() => _draftMembership = MembershipFilterLevel.platinum),
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
