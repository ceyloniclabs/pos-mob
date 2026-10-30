import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/utils/app_data_formatter.dart';
import 'package:pos/core/utils/responsive.dart';
import 'package:pos/core/widgets/custome_app_bar.dart';
import 'package:pos/core/widgets/scanner_permission_widget.dart';
import '../controllers/sale_create_controller.dart';
import '../controllers/sale_pos_scanner_controller.dart';

/// Fullscreen Continuous POS QR Scanner for rapid multi-item entry.
/// Features high-contrast controls, anti-duplicate hold locking,
/// explicit camera permission checking, and an interactive on-screen quantity stepper (+ / -).
class SalePosScannerView extends GetView<SalePosScannerController> {
  const SalePosScannerView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final SaleCreateController saleCreateController =
        Get.find<SaleCreateController>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CustomeAppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          tooltip: 'Back',
          icon: Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: Colors.white,
            ),
          ),
          onPressed: () => Get.back(),
        ),
        title: 'Scan Sale Items',
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          // Flashlight Toggle in High-Contrast Circle
          Obx(
            () => IconButton(
              tooltip: controller.isTorchOn.value
                  ? 'Turn Flashlight Off'
                  : 'Turn Flashlight On',
              onPressed: controller.isCameraReady.value
                  ? controller.toggleTorch
                  : null,
              icon: Container(
                padding: EdgeInsets.all(7.w),
                decoration: BoxDecoration(
                  color: controller.isCameraReady.value
                      ? (controller.isTorchOn.value
                          ? colorScheme.primary
                          : Colors.white.withValues(alpha: 0.18))
                      : Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  controller.isTorchOn.value
                      ? Iconsax.flash_1
                      : Iconsax.flash_slash,
                  size: 18.w,
                  color: controller.isCameraReady.value
                      ? Colors.white
                      : Colors.white30,
                ),
              ),
            ),
          ),
          // Camera Switch in High-Contrast Circle
          Obx(
            () => IconButton(
              tooltip: 'Switch Camera',
              onPressed: controller.isCameraReady.value
                  ? controller.switchCamera
                  : null,
              icon: Container(
                padding: EdgeInsets.all(7.w),
                decoration: BoxDecoration(
                  color: controller.isCameraReady.value
                      ? Colors.white.withValues(alpha: 0.18)
                      : Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.flip_camera_ios_rounded,
                  size: 18,
                  color: controller.isCameraReady.value
                      ? Colors.white
                      : Colors.white30,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 480,
          child: Column(
            children: [
              AppSpacing.gapXs,

              // Top Hint
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  'Continuous Scan: Aim at item QR tags sequentially.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),

              AppSpacing.gapSm,

              // Viewfinder Area
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final viewfinderSize =
                        (constraints.maxWidth * 0.72).clamp(220.0, 300.0);

                    return Center(
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
                              color: colorScheme.primary.withValues(alpha: 0.15),
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

                            // 3. Scanner initializing state
                            if (controller.scannerController == null ||
                                !controller.isCameraReady.value) {
                              return ScannerPermissionWidget(
                                isChecking: true,
                                onRequestPermission: controller
                                    .checkAndRequestCameraPermission,
                                onOpenSettings: controller.openSettings,
                              );
                            }

                            // 4. Active Scanner
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                // Scanner Feed
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
                              ],
                            );
                          }),
                        ),
                      ),
                    );
                  },
                ),
              ),

              AppSpacing.gapSm,

              // Live Feedback Card (Shows scanned item, stepper, or error)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Obx(() {
                  final feedback = saleCreateController.scanFeedback.value;
                  if (feedback == null) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: AppRadius.mdAll,
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Iconsax.scan_barcode,
                            size: 18.w,
                            color: colorScheme.primary,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Ready to scan items...',
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (feedback.isSuccess) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B5E20).withValues(alpha: 0.85),
                        borderRadius: AppRadius.mdAll,
                        border: Border.all(color: Colors.greenAccent, width: 1.2),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.greenAccent,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  size: 16,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      feedback.itemName ?? 'Item added',
                                      style: textTheme.titleSmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (feedback.price != null)
                                      Text(
                                        AppDataFormatter.formatCurrency(
                                            feedback.price),
                                        style: textTheme.bodySmall?.copyWith(
                                          color: Colors.white.withValues(alpha: 0.9),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              // Live Stepper directly in the scanner feedback card
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black45,
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () => saleCreateController
                                          .decrementFeedbackProduct(),
                                      borderRadius: BorderRadius.circular(16.r),
                                      child: Padding(
                                        padding: EdgeInsets.all(6.w),
                                        child: const Icon(
                                          Icons.remove_rounded,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 6.w),
                                      child: Text(
                                        '${feedback.inCartQty ?? 1}',
                                        style: TextStyle(
                                          color: Colors.greenAccent,
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => saleCreateController
                                          .incrementFeedbackProduct(),
                                      borderRadius: BorderRadius.circular(16.r),
                                      child: Padding(
                                        padding: EdgeInsets.all(6.w),
                                        child: const Icon(
                                          Icons.add_rounded,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'Item locked • Move away to scan next, or use + / - above',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB71C1C).withValues(alpha: 0.85),
                        borderRadius: AppRadius.mdAll,
                        border: Border.all(color: Colors.redAccent, width: 1.2),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.warning_amber_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              feedback.message,
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                }),
              ),

              AppSpacing.gapMd,

              // Bottom Persistent Dock for Cart Summary & Done Button
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                child: Obx(() {
                  final cartCount = saleCreateController.totalCartItemCount;
                  final total = saleCreateController.grandTotal;

                  return Row(
                    children: [
                      // Cart Summary
                      Expanded(
                        child: Row(
                          children: [
                            Badge(
                              label: Text('$cartCount'),
                              isLabelVisible: cartCount > 0,
                              backgroundColor: colorScheme.primary,
                              child: Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Iconsax.shopping_cart,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  cartCount > 0
                                      ? AppDataFormatter.formatCurrency(total)
                                      : 'Cart is empty',
                                  style: textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '$cartCount items scanned',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: Colors.white60,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Done Button
                      FilledButton.icon(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.check_circle_rounded, size: 18),
                        label: Text(
                          cartCount > 0 ? 'Done ($cartCount)' : 'Done',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: FilledButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
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
