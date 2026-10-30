import 'package:get/get.dart';
import '../controllers/connect_shop_controller.dart';

class ConnectShopBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConnectShopController>(() => ConnectShopController());
  }
}
