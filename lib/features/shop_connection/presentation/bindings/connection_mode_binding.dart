import 'package:get/get.dart';
import '../controllers/connection_mode_controller.dart';

class ConnectionModeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConnectionModeController>(() => ConnectionModeController());
  }
}
