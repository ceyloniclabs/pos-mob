import 'package:flutter/material.dart';
import 'package:pos/core/models/info_item.dart';
import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';

/// Clean details card for displaying grouped key-value items.
/// Adheres to Material 3 surface styling and typography.
class BuildInfoCard extends StatelessWidget {
  const BuildInfoCard({
    super.key,
    required this.title,
    required this.items,
    this.option,
  });

  final String title;
  final List<InfoItem> items;
  final Widget? option;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: AppRadius.mdAll,
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ?option,
            ],
          ),
          AppSpacing.gapMd,
          ...items.map((item) => _buildInfoRow(context, item)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, InfoItem item) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            item.icon,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          AppSpacing.gapSm,
          Expanded(
            flex: 2,
            child: Text(
              item.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          AppSpacing.gapSm,
          Expanded(
            flex: 3,
            child: Text(
              item.value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
