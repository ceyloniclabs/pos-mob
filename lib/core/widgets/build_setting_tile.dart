import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';

/// Clean Settings ListTile following Material 3 typography and token standards.
Widget buildSettingTile({
  required String title,
  required String subtitle,
  IconData? leadingIcon,
  Widget? leading,
  Widget? trailing,
  String? badgeText,
  VoidCallback? onTap,
}) {
  final context = Get.context!;
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  Widget? leadingWidget = leading;
  if (leadingWidget == null && leadingIcon != null) {
    leadingWidget = Container(
      padding: const EdgeInsets.all(AppSpacing.xxs + 3),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: AppRadius.smAll,
      ),
      child: Icon(
        leadingIcon,
        size: 18,
        color: colorScheme.primary,
      ),
    );
  }

  return ListTile(
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.xxs,
    ),
    leading: leadingWidget,
    title: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (badgeText != null) ...[
          const SizedBox(width: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.8),
                width: 0.8,
              ),
            ),
            child: Text(
              badgeText,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ],
    ),
    subtitle: Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxs),
      child: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    ),
    trailing: trailing ??
        Icon(
          Icons.chevron_right_rounded,
          size: 20,
          color: colorScheme.onSurfaceVariant,
        ),
  );
}
