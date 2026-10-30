import 'package:get/get.dart';
import 'package:pos/core/controllers/app_config_controller.dart';
import 'package:pos/core/enums.dart';

import '../../data/datasources/shop_setting_data_source.dart';
import '../../data/datasources/shop_setting_data_source_factory.dart';
import '../../data/repositories/shop_setting_repository_impl.dart';
import '../../domain/repositories/shop_setting_repository.dart';
import '../../domain/usecases/get_shop_settings_use_case.dart';
import '../../domain/usecases/update_shop_settings_use_case.dart';
import '../controllers/setting_controller.dart';

class SettingBinding extends Bindings {
  @override
  void dependencies() {
    BackendProviderType backend = BackendProviderType.laravel;
    if (Get.isRegistered<AppConfigController>()) {
      backend = Get.find<AppConfigController>().currentBackend.value;
    }

    // Layer 1: Data Source
    Get.lazyPut<ShopSettingDataSource>(
      () => ShopSettingDataSourceFactory.create(backend),
    );

    // Layer 2: Repository
    Get.lazyPut<ShopSettingRepository>(
      () => ShopSettingRepositoryImpl(Get.find<ShopSettingDataSource>()),
    );

    // Layer 3: Use Cases
    Get.lazyPut<GetShopSettingsUseCase>(
      () => GetShopSettingsUseCase(Get.find<ShopSettingRepository>()),
    );
    Get.lazyPut<UpdateShopSettingsUseCase>(
      () => UpdateShopSettingsUseCase(Get.find<ShopSettingRepository>()),
    );

    // Layer 4: Controller
    Get.lazyPut<SettingController>(
      () => SettingController(
        getShopSettingsUseCase: Get.find<GetShopSettingsUseCase>(),
        updateShopSettingsUseCase: Get.find<UpdateShopSettingsUseCase>(),
      ),
    );
  }
}
