import 'package:flutter/material.dart';
import 'package:pos/core/theme/app_spacing.dart';

/// Clean End of List indicator widget following the app's design system.
/// Uses standard padding (`top: AppSpacing.lg, bottom: AppSpacing.xxxl`) across
/// all paged lists and list views to provide adequate clearance above bottom navigation
/// bars and floating action buttons.
class EndOfListIndicator extends StatelessWidget {
  const EndOfListIndicator({
    super.key,
    this.text = '— End of List —',
    this.padding = const EdgeInsets.only(
      top: AppSpacing.lg,
      bottom: AppSpacing.xxxl,
    ),
  });

  final String text;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Padding(
      padding: padding,
      child: Center(
        child: Text(
          text,
          style: textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
