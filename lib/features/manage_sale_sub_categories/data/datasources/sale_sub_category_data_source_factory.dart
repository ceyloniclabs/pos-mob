import 'package:get/get.dart';
import 'package:pos/core/enums.dart';
import 'package:pos/core/network/api_service.dart';

import 'sale_sub_category_data_source.dart';
import 'sale_sub_category_laravel_data_source_impl.dart';

class SaleSubCategoryDataSourceFactory {
  static SaleSubCategoryDataSource create(BackendProviderType providerType) {
    switch (providerType) {
      case BackendProviderType.laravel:
        return SaleSubCategoryLaravelDataSourceImpl(Get.find<ApiService>());
      default:
        throw Exception("Unsupported BackendProviderType");
    }
  }
}
