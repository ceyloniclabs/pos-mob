import 'package:get/get.dart';
import 'package:pos/core/enums.dart';
import 'package:pos/core/network/api_service.dart';
import 'report_data_source.dart';
import 'report_laravel_data_source_impl.dart';

class ReportDataSourceFactory {
  static ReportDataSource create(BackendProviderType type) {
    switch (type) {
      case BackendProviderType.laravel:
        return ReportLaravelDataSourceImpl(apiService: Get.find<ApiService>());
      case BackendProviderType.firebase:
        throw UnimplementedError('Provider $type is not supported for reports');
    }
  }
}
