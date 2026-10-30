import 'package:get/get.dart';
import 'package:pos/core/controllers/app_config_controller.dart';
import 'package:pos/core/enums.dart';
import 'package:pos/core/routes/app_pages.dart';
import 'package:pos/core/storage/app_storage.dart';

class ConnectionModeController extends GetxController {
  final AppStorage _storage = AppStorage();

  final Rx<BackendProviderType?> selectedMode = Rx<BackendProviderType?>(null);

  @override
  void onInit() {
    super.onInit();
    final savedMode = _storage.readData<String>('backend_provider');
    if (savedMode != null) {
      if (savedMode == BackendProviderType.laravel.name) {
        selectedMode.value = BackendProviderType.laravel;
      } else if (savedMode == BackendProviderType.firebase.name) {
        selectedMode.value = BackendProviderType.firebase;
      }
    }
  }

  void selectWebShopMode() {
    selectedMode.value = BackendProviderType.laravel;
    _storage.saveData('backend_provider', BackendProviderType.laravel.name);
    if (Get.isRegistered<AppConfigController>()) {
      AppConfigController.to.setBackend(BackendProviderType.laravel);
    }

    final savedBaseUrl = _storage.readData<String>('baseUrl');
    if (savedBaseUrl != null && savedBaseUrl.isNotEmpty) {
      Get.toNamed(Routes.SIGN_IN);
    } else {
      Get.toNamed(Routes.SCAN_SHOP);
    }
  }

  void selectStandaloneMobileMode() {
    selectedMode.value = BackendProviderType.firebase;
    _storage.saveData('backend_provider', BackendProviderType.firebase.name);
    if (Get.isRegistered<AppConfigController>()) {
      AppConfigController.to.setBackend(BackendProviderType.firebase);
    }
    Get.toNamed(Routes.CLOUD_AUTH_PREVIEW);
  }
}
