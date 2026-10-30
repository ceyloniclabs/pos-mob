import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';

/// Clean Confirmation Bottom Sheet adhering to flutter-uiux-design bottom sheet standards.
void showConfirmBottomSheet(
  String title,
  String message,
  VoidCallback? onYes,
) {
  final context = Get.context!;
  final theme = Theme.of(context);

  Get.bottomSheet(
    SafeArea(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: AppRadius.sheetTop,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: AppRadius.fullAll,
              ),
            ),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.gapSm,
            Text(
              "Are you sure you want to proceed with this $message?",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            AppSpacing.gapLg,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
                    ),
                    onPressed: () => Get.back(),
                    child: const Text("Cancel"),
                  ),
                ),
                AppSpacing.gapSm,
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
                    ),
                    onPressed: () {
                      Get.back();
                      onYes?.call();
                    },
                    child: const Text("Confirm"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    isDismissible: true,
    enableDrag: true,
    isScrollControlled: true,
  );
}
