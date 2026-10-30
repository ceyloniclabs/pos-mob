import 'package:get/get.dart';
import '../controllers/global_qr_scanner_controller.dart';

class GlobalQrScannerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GlobalQrScannerController>(() => GlobalQrScannerController());
  }
}
