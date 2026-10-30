import 'package:get/get.dart';
import 'package:pos/core/enums.dart';
import 'package:pos/core/network/api_service.dart';

import 'sale_item_data_source.dart';
import 'sale_item_laravel_data_source_impl.dart';

class SaleItemDataSourceFactory {
  static SaleItemDataSource create(BackendProviderType providerType) {
    switch (providerType) {
      case BackendProviderType.laravel:
        return SaleItemLaravelDataSourceImpl(Get.find<ApiService>());
      default:
        throw Exception("Unsupported BackendProviderType");
    }
  }
}
