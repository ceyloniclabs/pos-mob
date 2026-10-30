import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pos/core/services/qr_scanner/global_qr_router.dart';

class GlobalQrScannerController extends GetxController
    with WidgetsBindingObserver {
  MobileScannerController? scannerController;

  final Rx<PermissionStatus?> cameraPermissionStatus =
      Rx<PermissionStatus?>(null);
  final RxBool isCheckingPermission = true.obs;
  final RxBool isCameraReady = false.obs;
  final RxString cameraError = ''.obs;

  final RxBool isScanning = true.obs;
  final RxBool isTorchOn = false.obs;
  final RxBool isProcessing = false.obs;
  final RxString lastScannedCode = ''.obs;

  String? customTitle;
  String? customSubtitle;
  bool returnResult = false;
  bool _isHandled = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    final args = Get.arguments;
    if (args is Map) {
      returnResult = args['returnResult'] == true;
      customTitle = args['title'] as String?;
      customSubtitle = args['subtitle'] as String?;
    }
    GlobalQrRouter.initializeDefaults();
    checkAndRequestCameraPermission();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-verify permission if returning from external settings
      if (cameraPermissionStatus.value != PermissionStatus.granted) {
        checkCameraPermission(autoRequest: false);
      }
    }
  }

  /// Explicit check and runtime permission request prior to booting CameraX.
  Future<void> checkAndRequestCameraPermission() async {
    await checkCameraPermission(autoRequest: true);
  }

  /// Probes camera permission status, requesting on-demand if specified.
  Future<void> checkCameraPermission({bool autoRequest = false}) async {
    isCheckingPermission.value = true;
    cameraError.value = '';
    try {
      var status = await Permission.camera.status;
      if (!status.isGranted && autoRequest) {
        status = await Permission.camera.request();
      }
      cameraPermissionStatus.value = status;
      if (status.isGranted || status.isLimited) {
        _initScanner();
      } else {
        _disposeScanner();
      }
    } catch (e) {
      cameraError.value = 'Failed to check camera permission: $e';
    } finally {
      isCheckingPermission.value = false;
    }
  }

  void _initScanner() {
    if (scannerController == null) {
      scannerController = MobileScannerController(
        facing: CameraFacing.back,
        detectionSpeed: DetectionSpeed.normal,
      );
      isCameraReady.value = true;
    }
  }

  void _disposeScanner() {
    isCameraReady.value = false;
    scannerController?.dispose();
    scannerController = null;
  }

  /// Handles camera detection events from [MobileScanner].
  void onDetect(BarcodeCapture capture) async {
    if (_isHandled || isProcessing.value || !isScanning.value) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final rawValue = barcode.rawValue;
      if (rawValue != null && rawValue.trim().isNotEmpty) {
        // Prevent duplicate rapid-fire processing
        if (lastScannedCode.value == rawValue && isProcessing.value) {
          return;
        }

        _isHandled = true;
        isProcessing.value = true;
        lastScannedCode.value = rawValue;

        // Provide tactile feedback on successful capture
        try {
          await HapticFeedback.mediumImpact();
        } catch (_) {}

        if (returnResult) {
          isScanning.value = false;
          try {
            await scannerController?.stop();
          } catch (_) {}
          Get.back(result: rawValue);
          return;
        }

        final routed = await GlobalQrRouter.routeRaw(rawValue);

        // Debounce window before re-enabling scanner
        await Future.delayed(const Duration(milliseconds: 1200));
        isProcessing.value = false;
        _isHandled = false;

        if (routed) {
          // Reset last code so the user can re-scan if desired later
          lastScannedCode.value = '';
        }
        break;
      }
    }
  }

  /// Toggles the hardware flashlight torch.
  Future<void> toggleTorch() async {
    try {
      if (scannerController != null) {
        await scannerController!.toggleTorch();
        isTorchOn.value = !isTorchOn.value;
      }
    } catch (_) {}
  }

  /// Switches between back and front cameras.
  Future<void> switchCamera() async {
    try {
      if (scannerController != null) {
        await scannerController!.switchCamera();
      }
    } catch (_) {}
  }

  /// Opens application settings to allow the user to manually enable permissions.
  Future<void> openSettings() async {
    await openAppSettings();
  }

  /// Resets processing state if user wants to retry manually.
  void resumeScanning() {
    _isHandled = false;
    isProcessing.value = false;
    lastScannedCode.value = '';
    isScanning.value = true;
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeScanner();
    super.onClose();
  }
}
