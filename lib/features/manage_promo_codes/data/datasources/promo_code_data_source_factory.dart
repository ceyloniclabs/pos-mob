import 'package:get/get.dart';
import 'package:pos/core/enums.dart';
import 'package:pos/core/network/api_service.dart';
import 'promo_code_data_source.dart';
import 'promo_code_laravel_data_source_impl.dart';

class PromoCodeDataSourceFactory {
  static PromoCodeDataSource create(BackendProviderType type) {
    switch (type) {
      case BackendProviderType.laravel:
        return PromoCodeLaravelDataSourceImpl(Get.find<ApiService>());
      case BackendProviderType.firebase:
        throw UnimplementedError('Firebase provider not yet implemented for promo codes');
    }
  }
}
