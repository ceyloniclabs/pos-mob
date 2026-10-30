import 'package:get/get.dart';
import 'package:pos/core/enums.dart';
import 'package:pos/core/network/api_service.dart';
import 'staff_data_source.dart';
import 'staff_laravel_data_source_impl.dart';

class StaffDataSourceFactory {
  static StaffDataSource create(BackendProviderType type) {
    switch (type) {
      case BackendProviderType.laravel:
        return StaffLaravelDataSourceImpl(Get.find<ApiService>());
      case BackendProviderType.firebase:
        throw UnimplementedError('Provider $type is not supported');
    }
  }
}
