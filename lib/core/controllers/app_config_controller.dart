import 'package:get/get.dart';
import 'package:pos/core/enums.dart';
import 'package:pos/core/storage/app_storage.dart';

class AppConfigController extends GetxController {
  static AppConfigController get to => Get.find();

  final AppStorage _storage;

  AppConfigController({required this._storage});

  static const String backendStorageKey = 'backend_provider';

  // Observable state for the current backend provider
  final Rx<BackendProviderType> currentBackend =
      BackendProviderType.laravel.obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialBackend();
  }

  void _loadInitialBackend() {
    final savedType = _storage.readData<String>(backendStorageKey) ??
        _storage.readData<String>('backend_provider_type');
    if (savedType != null) {
      if (savedType == BackendProviderType.firebase.name) {
        currentBackend.value = BackendProviderType.firebase;
      } else {
        currentBackend.value = BackendProviderType.laravel;
      }
    }
  }

  // Called during login or settings change
  void setBackend(BackendProviderType type) {
    currentBackend.value = type;
    _storage.saveData(backendStorageKey, type.name);
    _storage.saveData('backend_provider_type', type.name);
  }
}
