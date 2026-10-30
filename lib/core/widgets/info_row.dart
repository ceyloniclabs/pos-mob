import 'package:flutter/material.dart';
import 'package:pos/core/theme/app_spacing.dart';

/// Clean key-value info row for detail cards and screens.
/// Following flutter-uiux-design output-widgets specification.
class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
    this.textAlign = TextAlign.end,
    this.labelFlex = 2,
    this.valueFlex = 3,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;
  final TextAlign textAlign;
  final int labelFlex;
  final int valueFlex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: labelFlex,
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            AppSpacing.gapSm,
            Expanded(
              flex: valueFlex,
              child: Text(
                value,
                textAlign: textAlign,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
                  color: valueColor ?? theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
