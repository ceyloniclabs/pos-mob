import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/utils/responsive.dart';
import 'package:pos/core/widgets/custome_app_bar.dart';
import 'package:pos/core/widgets/scanner_permission_widget.dart';
import '../controllers/global_qr_scanner_controller.dart';

/// Full-featured Global QR Scanner View for instant deep-linking.
class GlobalQrScannerView extends GetView<GlobalQrScannerController> {
  const GlobalQrScannerView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CustomeAppBar(
        title: controller.customTitle ?? 'Scan QR Code',
        showbackArrow: true,
        centerTitle: true,
        actions: [
          // Torch Flashlight Toggle
          Obx(
            () => IconButton(
              tooltip: controller.isTorchOn.value
                  ? 'Turn Flashlight Off'
                  : 'Turn Flashlight On',
              onPressed: controller.isCameraReady.value
                  ? controller.toggleTorch
                  : null,
              icon: Icon(
                controller.isTorchOn.value
                    ? Iconsax.flash_1
                    : Iconsax.flash_slash,
                size: 20,
                color: controller.isCameraReady.value
                    ? (controller.isTorchOn.value
                        ? colorScheme.primary
                        : Colors.white70)
                    : Colors.white30,
              ),
            ),
          ),
          // Camera Switch
          Obx(
            () => IconButton(
              tooltip: 'Switch Camera',
              onPressed: controller.isCameraReady.value
                  ? controller.switchCamera
                  : null,
              icon: Icon(
                Iconsax.refresh_2,
                size: 20,
                color: controller.isCameraReady.value
                    ? Colors.white70
                    : Colors.white30,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 480,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final viewfinderSize = (constraints.maxWidth * 0.72).clamp(
                220.0,
                300.0,
              );

              return Column(
                children: [
                  AppSpacing.gapMd,

                  // Instruction Header
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Text(
                      controller.customSubtitle ??
                          'Align the QR code within the frame to immediately jump to the details.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ),

                  AppSpacing.gapLg,

                  // Viewfinder Frame
                  Expanded(
                    child: Center(
                      child: Container(
                        width: viewfinderSize,
                        height: viewfinderSize,
                        decoration: BoxDecoration(
                          color: const Color(0xFF141414),
                          borderRadius: AppRadius.xlAll,
                          border: Border.all(
                            color: Colors.white24,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  colorScheme.primary.withValues(alpha: 0.15),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: AppRadius.xlAll,
                          child: Obx(() {
                            // 1. Checking permission state
                            if (controller.isCheckingPermission.value) {
                              return ScannerPermissionWidget(
                                isChecking: true,
                                onRequestPermission: controller
                                    .checkAndRequestCameraPermission,
                                onOpenSettings: controller.openSettings,
                              );
                            }

                            final status =
                                controller.cameraPermissionStatus.value;

                            // 2. Permission not granted state
                            if (status != PermissionStatus.granted &&
                                status != PermissionStatus.limited) {
                              return ScannerPermissionWidget(
                                status: status,
                                errorMessage:
                                    controller.cameraError.value.isNotEmpty
                                        ? controller.cameraError.value
                                        : null,
                                onRequestPermission: controller
                                    .checkAndRequestCameraPermission,
                                onOpenSettings: controller.openSettings,
                              );
                            }

                            // 3. Controller initializing state
                            if (controller.scannerController == null ||
                                !controller.isCameraReady.value) {
                              return ScannerPermissionWidget(
                                isChecking: true,
                                onRequestPermission: controller
                                    .checkAndRequestCameraPermission,
                                onOpenSettings: controller.openSettings,
                              );
                            }

                            // 4. Active Scanner state
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                MobileScanner(
                                  controller: controller.scannerController!,
                                  onDetect: controller.onDetect,
                                  errorBuilder: (context, error, child) {
                                    return ScannerPermissionWidget(
                                      errorMessage:
                                          'Camera initialization failed (${error.errorCode.name}).',
                                      onRequestPermission: controller
                                          .checkAndRequestCameraPermission,
                                      onOpenSettings: controller.openSettings,
                                      onRetry: () => controller
                                          .checkCameraPermission(autoRequest: true),
                                    );
                                  },
                                ),

                                // Viewfinder Corner Brackets
                                const Padding(
                                  padding: EdgeInsets.all(AppSpacing.md),
                                  child: _ScannerReticle(),
                                ),

                                // Loading Overlay when processing
                                Obx(() {
                                  if (!controller.isProcessing.value) {
                                    return const SizedBox.shrink();
                                  }
                                  return Container(
                                    color: Colors.black.withValues(alpha: 0.65),
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircularProgressIndicator.adaptive(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            colorScheme.primary,
                                          ),
                                        ),
                                        AppSpacing.gapMd,
                                        Text(
                                          'Opening details...',
                                          style: textTheme.bodySmall?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ),

                  AppSpacing.gapMd,

                  // Supported Entities Chips
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: AppRadius.mdAll,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Iconsax.scan_barcode,
                              size: 16,
                              color: colorScheme.primary,
                            ),
                            AppSpacing.gapXs,
                            Text(
                              'Supported QR Entities',
                              style: textTheme.labelSmall?.copyWith(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.gapXs,
                        Wrap(
                          spacing: 6.w,
                          runSpacing: 4.h,
                          alignment: WrapAlignment.center,
                          children: const [
                            _EntityChip(label: 'Surfboards'),
                            _EntityChip(label: 'Rentals'),
                            _EntityChip(label: 'Sales'),
                            _EntityChip(label: 'Sale Items'),
                            _EntityChip(label: 'Customers'),
                            _EntityChip(label: 'Staff / Admin'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  AppSpacing.gapMd,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _EntityChip extends StatelessWidget {
  final String label;

  const _EntityChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.9),
          fontSize: 11.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _ScannerReticle extends StatelessWidget {
  const _ScannerReticle();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    const cornerSize = 28.0;
    const thickness = 3.5;
    const radius = 12.0;

    return Stack(
      children: [
        // Top Left
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            width: cornerSize,
            height: cornerSize,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: primary, width: thickness),
                left: BorderSide(color: primary, width: thickness),
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(radius),
              ),
            ),
          ),
        ),
        // Top Right
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: cornerSize,
            height: cornerSize,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: primary, width: thickness),
                right: BorderSide(color: primary, width: thickness),
              ),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(radius),
              ),
            ),
          ),
        ),
        // Bottom Left
        Positioned(
          bottom: 0,
          left: 0,
          child: Container(
            width: cornerSize,
            height: cornerSize,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: primary, width: thickness),
                left: BorderSide(color: primary, width: thickness),
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(radius),
              ),
            ),
          ),
        ),
        // Bottom Right
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: cornerSize,
            height: cornerSize,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: primary, width: thickness),
                right: BorderSide(color: primary, width: thickness),
              ),
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(radius),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
