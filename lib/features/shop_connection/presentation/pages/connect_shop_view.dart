import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pos/core/routes/app_pages.dart';
import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/utils/responsive.dart';
import 'package:pos/core/widgets/custome_app_bar.dart';
import 'package:pos/core/widgets/scanner_permission_widget.dart';

import '../controllers/connect_shop_controller.dart';

/// Redesigned Connect to Shop Screen adhering to Senior Flutter UI/UX guidelines.
/// - Clean M3 App Bar with Flashlight and Camera switch actions
/// - Modern viewfinder frame with corner bracket overlays
/// - Explicit camera permission handling and lifecycle recovery
/// - Responsive layout fitting within the viewport without overflow
class ConnectShopView extends GetView<ConnectShopController> {
  const ConnectShopView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomeAppBar(
        title: 'Connect to Shop',
        showbackArrow: true,
        centerTitle: true,
        leadingOnPressed: () {
          if (Navigator.canPop(context)) {
            Get.back();
          } else {
            Get.offNamed(Routes.CONNECTION_MODE);
          }
        },
        actions: [
          // Camera switch
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
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.outlineVariant,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 420,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxHeight < 640;
              final viewfinderSize = (constraints.maxHeight * 0.36).clamp(
                200.0,
                255.0,
              );

              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Spacer(),

                          // Header Instruction
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                  ),
                                  child: Text(
                                    'Scan the pairing QR code from your shop web dashboard to link this terminal device.',
                                    textAlign: TextAlign.center,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          isCompact ? AppSpacing.gapMd : AppSpacing.gapLg,

                          // Modern Viewfinder Container
                          Center(
                            child: Container(
                              width: viewfinderSize,
                              height: viewfinderSize,
                              decoration: BoxDecoration(
                                color: const Color(0xFF141414),
                                borderRadius: AppRadius.xlAll,
                                border: Border.all(
                                  color: colorScheme.outlineVariant.withValues(
                                    alpha: 0.6,
                                  ),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.primary.withValues(
                                      alpha: 0.08,
                                    ),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: AppRadius.xlAll,
                                child: Obx(() {
                                  // 1. Checking permission
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

                                  // 2. Permission not granted
                                  if (status != PermissionStatus.granted &&
                                      status != PermissionStatus.limited) {
                                    return ScannerPermissionWidget(
                                      status: status,
                                      errorMessage: controller
                                              .cameraError.value.isNotEmpty
                                          ? controller.cameraError.value
                                          : null,
                                      onRequestPermission: controller
                                          .checkAndRequestCameraPermission,
                                      onOpenSettings: controller.openSettings,
                                    );
                                  }

                                  // 3. Controller initializing
                                  if (controller.scannerController == null ||
                                      !controller.isCameraReady.value) {
                                    return ScannerPermissionWidget(
                                      isChecking: true,
                                      onRequestPermission: controller
                                          .checkAndRequestCameraPermission,
                                      onOpenSettings: controller.openSettings,
                                    );
                                  }

                                  // 4. Scanner active
                                  return Stack(
                                    children: [
                                      // Camera Feed / Loading State
                                      Obx(
                                        () => controller.isScanning.value
                                            ? MobileScanner(
                                                controller: controller
                                                    .scannerController!,
                                                onDetect: controller.onDetect,
                                                errorBuilder:
                                                    (context, error, child) {
                                                  return ScannerPermissionWidget(
                                                    errorMessage:
                                                        'Camera initialization failed (${error.errorCode.name}).',
                                                    onRequestPermission: controller
                                                        .checkAndRequestCameraPermission,
                                                    onOpenSettings: controller
                                                        .openSettings,
                                                    onRetry: () => controller
                                                        .checkCameraPermission(
                                                            autoRequest: true),
                                                  );
                                                },
                                              )
                                            : Container(
                                                color: colorScheme
                                                    .surfaceContainerHigh,
                                                alignment: Alignment.center,
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    CircularProgressIndicator
                                                        .adaptive(
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                              Color>(
                                                        colorScheme.primary,
                                                      ),
                                                    ),
                                                    AppSpacing.gapMd,
                                                    Text(
                                                      'Connecting to shop...',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: textTheme.bodySmall
                                                          ?.copyWith(
                                                        color: colorScheme
                                                            .onSurfaceVariant,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                      ),

                                      // Corner Frame Overlay
                                      const Padding(
                                        padding: EdgeInsets.all(AppSpacing.md),
                                        child: _ScannerOverlay(),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ),
                          ),
                          isCompact ? AppSpacing.gapSm : AppSpacing.gapMd,

                          // Alignment Guidance Row
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Iconsax.scan_barcode,
                                  size: 18,
                                  color: colorScheme.primary,
                                ),
                                AppSpacing.gapXs,
                                Flexible(
                                  child: Text(
                                    'Position QR code within the frame',
                                    textAlign: TextAlign.center,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Spacer(),

                          // Return to Sign In Link
                          Center(
                            child: TextButton(
                              onPressed: () => Get.offNamed(Routes.SIGN_IN),
                              child: Text(
                                'Already connected? Return to Sign In',
                                style: textTheme.labelMedium?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          AppSpacing.gapXs,
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    const cornerSize = 24.0;
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
