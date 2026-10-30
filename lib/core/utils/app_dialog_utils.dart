import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../features/splash/domain/entities/app_version_info.dart';
import '../../features/splash/domain/entities/maintenance_info.dart';

class AppDialogUtils {
  AppDialogUtils._();

  /// Show force update dialog - blocked from dismissing
  static void showForceUpdateDialog(AppVersionInfo versionInfo) {
    if (Get.isDialogOpen ?? false) return;

    Get.dialog(
      PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          icon: Icon(Iconsax.refresh_circle, size: 52.sp, color: Colors.blue.shade700),
          title: Text(
            'Update Required',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                versionInfo.updateMessage ??
                    'A new version (${versionInfo.latestVersion}) is required to continue using the application. Please update now to experience the latest features and fixes.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13.sp, height: 1.5),
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Latest version: v${versionInfo.latestVersion}',
                  style: TextStyle(
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  final url = versionInfo.storeUrl;
                  if (url != null && url.isNotEmpty) {
                    final uri = Uri.parse(url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  }
                },
                icon: const Icon(Icons.system_update_rounded),
                label: const Text('Update Now'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Show soft update dialog - user can update or dismiss
  static void showSoftUpdateDialog(AppVersionInfo versionInfo) {
    if (Get.isDialogOpen ?? false) return;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        icon: Icon(Iconsax.star, size: 48.sp, color: Colors.amber.shade700),
        title: Text(
          'Update Available',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
          textAlign: TextAlign.center,
        ),
        content: Text(
          versionInfo.updateMessage ??
              'Version ${versionInfo.latestVersion} is available with performance improvements and new features.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade700, fontSize: 13.sp, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Later', style: TextStyle(color: Colors.grey.shade600)),
          ),
          FilledButton(
            onPressed: () async {
              Get.back();
              final url = versionInfo.storeUrl;
              if (url != null && url.isNotEmpty) {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  /// Show maintenance dialog
  static void showMaintenanceDialog(MaintenanceInfo info, {VoidCallback? onRetry}) {
    if (Get.isDialogOpen ?? false) return;

    Get.dialog(
      PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          icon: Icon(Icons.construction_rounded, size: 52.sp, color: Colors.amber.shade800),
          title: Text(
            info.isFullMaintenance ? 'Under Maintenance' : '${info.affectedFeature ?? "Service"} Unavailable',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                info.message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13.sp, height: 1.5),
              ),
              if (info.estimatedEndTime != null && info.estimatedEndTime!.isNotEmpty) ...[
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule, size: 16.sp, color: Colors.amber.shade900),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(
                          'Estimated completion: ${info.estimatedEndTime}',
                          style: TextStyle(
                            color: Colors.amber.shade900,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton.icon(
              onPressed: () {
                Get.back();
                if (onRetry != null) {
                  onRetry();
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
            FilledButton.icon(
              onPressed: () async {
                final uri = Uri.parse('mailto:support@surfdesk.app');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
              icon: const Icon(Icons.support_agent_rounded, size: 18),
              label: const Text('Support'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.amber.shade800,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Show tenant suspended dialog
  static void showTenantSuspendedDialog({required String reason, String? billingUrl}) {
    if (Get.isDialogOpen ?? false) return;

    Get.dialog(
      PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          icon: Icon(Icons.block_rounded, size: 52.sp, color: Colors.red.shade700),
          title: Text(
            'Account Suspended',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                reason,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13.sp, height: 1.5),
              ),
              SizedBox(height: 8.h),
              Text(
                'Please contact your organization administrator or update your subscription.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11.sp),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  final url = billingUrl ?? 'https://billing.surfdesk.app';
                  final uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Icons.payment_rounded),
                label: const Text('Manage Subscription'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }
}
