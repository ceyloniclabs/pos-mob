import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';

/// Clean, Material 3 compliant UI shown within the scanner viewfinder
/// when camera permissions are checking, denied, permanently denied, or errored.
class ScannerPermissionWidget extends StatelessWidget {
  final PermissionStatus? status;
  final bool isChecking;
  final String? errorMessage;
  final VoidCallback onRequestPermission;
  final VoidCallback onOpenSettings;
  final VoidCallback? onRetry;
  final bool isDarkBackground;

  const ScannerPermissionWidget({
    super.key,
    this.status,
    this.isChecking = false,
    this.errorMessage,
    required this.onRequestPermission,
    required this.onOpenSettings,
    this.onRetry,
    this.isDarkBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final primaryTextColor = isDarkBackground ? Colors.white : colorScheme.onSurface;
    final secondaryTextColor =
        isDarkBackground ? Colors.white.withValues(alpha: 0.75) : colorScheme.onSurfaceVariant;

    if (isChecking) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 28.w,
                height: 28.w,
                child: CircularProgressIndicator.adaptive(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                ),
              ),
              AppSpacing.gapSm,
              Text(
                'Checking camera permission...',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: secondaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final isPermanentlyDenied = status == PermissionStatus.permanentlyDenied ||
        status == PermissionStatus.restricted;

    final isError = errorMessage != null && errorMessage!.isNotEmpty;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: (isError ? colorScheme.error : colorScheme.primary)
                    .withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isError ? Icons.warning_amber_rounded : Iconsax.camera_slash,
                size: 28.w,
                color: isError ? colorScheme.error : colorScheme.primary,
              ),
            ),
            AppSpacing.gapSm,
            Text(
              isError
                  ? 'Camera Failed to Start'
                  : (isPermanentlyDenied
                      ? 'Camera Access Disabled'
                      : 'Camera Permission Needed'),
              textAlign: TextAlign.center,
              style: textTheme.titleSmall?.copyWith(
                color: primaryTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.gapXs,
            Text(
              isError
                  ? (errorMessage ?? 'An error occurred while starting the camera.')
                  : (isPermanentlyDenied
                      ? 'Camera permission is permanently denied. Please enable it in device settings to scan.'
                      : 'Allow camera access to scan QR codes and barcodes instantly.'),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: secondaryTextColor,
                fontSize: 11.sp,
                height: 1.3,
              ),
            ),
            AppSpacing.gapMd,
            if (isPermanentlyDenied)
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.smAll),
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: onOpenSettings,
                icon: const Icon(Icons.settings, size: 16),
                label: Text(
                  'Open Settings',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else if (isError)
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.smAll),
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: onRetry ?? onRequestPermission,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: Text(
                  'Retry Camera',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.smAll),
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: onRequestPermission,
                icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                label: Text(
                  'Grant Permission',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
