import 'package:get/get.dart';
import 'package:pos/core/enums.dart';
import 'package:pos/core/network/api_service.dart';

import 'shop_setting_data_source.dart';
import 'shop_setting_laravel_data_source_impl.dart';

class ShopSettingDataSourceFactory {
  static ShopSettingDataSource create(BackendProviderType type) {
    switch (type) {
      case BackendProviderType.laravel:
        return ShopSettingLaravelDataSourceImpl(Get.find<ApiService>());
      case BackendProviderType.firebase:
        throw UnimplementedError('Firebase provider not yet implemented for shop settings');
    }
  }
}
