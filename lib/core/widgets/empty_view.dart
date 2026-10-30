import 'package:flutter/material.dart';
import 'package:pos/core/theme/app_spacing.dart';

/// Clean Empty State widget following flutter-uiux-design guidelines.
/// Replaces blank screens with a clear message and a single prominent call to action.
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: compact ? 36 : 56,
              color: theme.colorScheme.outline,
            ),
            compact ? AppSpacing.gapSm : AppSpacing.gapMd,
            Text(
              title,
              style: compact ? theme.textTheme.titleSmall : theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              AppSpacing.gapXs,
              Text(
                message!,
                textAlign: TextAlign.center,
                style: (compact ? theme.textTheme.bodySmall : theme.textTheme.bodyMedium)?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              compact ? AppSpacing.gapMd : AppSpacing.gapLg,
              TextButton.icon(
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(actionLabel!),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                ),
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
