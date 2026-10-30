import 'package:get/get.dart';
import 'package:pos/core/enums.dart';
import 'package:pos/core/network/api_service.dart';

import 'sale_brand_data_source.dart';
import 'sale_brand_laravel_data_source_impl.dart';

class SaleBrandDataSourceFactory {
  static SaleBrandDataSource create(BackendProviderType providerType) {
    switch (providerType) {
      case BackendProviderType.laravel:
        return SaleBrandLaravelDataSourceImpl(Get.find<ApiService>());
      default:
        throw Exception("Unsupported BackendProviderType for SaleBrand");
    }
  }
}
