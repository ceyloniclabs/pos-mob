import 'package:get/get.dart';
import 'package:pos/core/enums.dart';
import 'package:pos/core/network/api_service.dart';
import 'sale_data_source.dart';
import 'sale_laravel_data_source_impl.dart';

class SaleDataSourceFactory {
  static SaleDataSource create(BackendProviderType type) {
    switch (type) {
      case BackendProviderType.laravel:
      case BackendProviderType.firebase:
        return SaleLaravelDataSourceImpl(
          Get.find<ApiService>(),
        );
    }
  }
}
