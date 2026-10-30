import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pos/core/controllers/app_config_controller.dart';
import 'package:pos/core/enums.dart';
import 'package:pos/core/network/api_service.dart';
import 'package:pos/core/routes/app_pages.dart';
import 'package:pos/core/utils/scaffold_message_utils.dart';

class ConnectShopController extends GetxController with WidgetsBindingObserver {
  MobileScannerController? scannerController;

  final Rx<PermissionStatus?> cameraPermissionStatus =
      Rx<PermissionStatus?>(null);
  final RxBool isCheckingPermission = true.obs;
  final RxBool isCameraReady = false.obs;
  final RxString cameraError = ''.obs;

  final RxBool isScanning = true.obs;
  final RxBool isTorchOn = false.obs;
  bool _isHandled = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
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

  void onDetect(BarcodeCapture capture) async {
    if (_isHandled || !isScanning.value || !isCameraReady.value) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        final url = barcode.rawValue!;
        if (url.startsWith('http')) {
          _isHandled = true;
          isScanning.value = false;
          try {
            await scannerController?.stop();
          } catch (_) {}
          connectWithUrl(url);
          break;
        }
      }
    }
  }

  Future<void> connectWithUrl(String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return;

    try {
      if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
        isScanning.value = false;
        ApiService().setBaseUrl(trimmed);
        if (Get.isRegistered<AppConfigController>()) {
          AppConfigController.to.setBackend(BackendProviderType.laravel);
        }
        ScaffoldMessageUtils.showSuccess('Successfully connected to shop!');
        Get.offNamed(Routes.SIGN_IN);
      } else {
        throw Exception('URL must start with http:// or https://');
      }
    } catch (e) {
      _isHandled = false;
      isScanning.value = true;
      try {
        await scannerController?.start();
      } catch (_) {}
      ScaffoldMessageUtils.showError(
        'Connection failed: ${e.toString().replaceAll('Exception: ', '')}',
      );
    }
  }

  Future<void> toggleTorch() async {
    try {
      if (scannerController != null) {
        await scannerController!.toggleTorch();
        isTorchOn.value = !isTorchOn.value;
      }
    } catch (_) {}
  }

  Future<void> switchCamera() async {
    try {
      if (scannerController != null) {
        await scannerController!.switchCamera();
      }
    } catch (_) {}
  }

  Future<void> openSettings() async {
    await openAppSettings();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeScanner();
    super.onClose();
  }
}
