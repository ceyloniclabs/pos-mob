import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'sale_create_controller.dart';

/// Controller for continuous/bulk POS QR scanning of retail sale items.
/// Features explicit runtime permission handling, lifecycle resume triggers,
/// and safe camera controller initialization.
class SalePosScannerController extends GetxController
    with WidgetsBindingObserver {
  MobileScannerController? scannerController;

  final Rx<PermissionStatus?> cameraPermissionStatus =
      Rx<PermissionStatus?>(null);
  final RxBool isCheckingPermission = true.obs;
  final RxBool isCameraReady = false.obs;
  final RxString cameraError = ''.obs;

  final RxBool isTorchOn = false.obs;
  final RxBool isScanning = true.obs;

  // Barcode holding & presence tracking to prevent accidental duplicate auto-adds
  String? _currentHeldCode;
  DateTime? _lastSeenTime;
  Timer? _heldCodeClearTimer;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    // Periodically checks if the scanned item was moved away from the camera beam.
    // If no barcode was seen in the frame for > 900ms, the lock is cleared so
    // bringing the item back will scan it again.
    _heldCodeClearTimer =
        Timer.periodic(const Duration(milliseconds: 350), (_) {
      if (_currentHeldCode != null && _lastSeenTime != null) {
        if (DateTime.now().difference(_lastSeenTime!).inMilliseconds > 900) {
          _currentHeldCode = null;
        }
      }
    });

    checkAndRequestCameraPermission();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
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

  /// Toggles hardware flashlight
  Future<void> toggleTorch() async {
    try {
      if (scannerController != null) {
        await scannerController!.toggleTorch();
        isTorchOn.value = !isTorchOn.value;
      }
    } catch (_) {}
  }

  /// Switches between back and front cameras
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

  /// Handles barcode/QR detection with strict anti-duplicate protection.
  /// As long as the same item is held continuously in the camera frame, it will NEVER re-scan.
  /// The user must either move it away and bring it back, or use the on-screen stepper (+ / -).
  void onDetect(BarcodeCapture capture) {
    if (!isScanning.value || !isCameraReady.value) return;

    for (final barcode in capture.barcodes) {
      final code = barcode.rawValue;
      if (code == null || code.trim().isEmpty) continue;

      final now = DateTime.now();

      // If this exact same barcode is continuously being held in the camera view,
      // update its seen time so it doesn't expire, but DO NOT trigger another scan!
      if (code == _currentHeldCode) {
        _lastSeenTime = now;
        return;
      }

      // Either a new item entered or the previous item was moved away and brought back
      _currentHeldCode = code;
      _lastSeenTime = now;

      if (Get.isRegistered<SaleCreateController>()) {
        Get.find<SaleCreateController>().scanAndAddProduct(code);
      }
      break;
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _heldCodeClearTimer?.cancel();
    _disposeScanner();
    super.onClose();
  }
}
