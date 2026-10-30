import 'package:get/get.dart';
import '../controllers/sale_pos_scanner_controller.dart';

class SalePosScannerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SalePosScannerController>(() => SalePosScannerController());
  }
}
