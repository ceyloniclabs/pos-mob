import 'package:get/get.dart';
import 'package:pos/core/controllers/app_config_controller.dart';
import 'package:pos/core/enums.dart';

import '../../data/datasources/report_data_source.dart';
import '../../data/datasources/report_data_source_factory.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../../domain/repositories/report_repository.dart';
import '../../domain/usecases/get_customer_list_report_use_case.dart';
import '../../domain/usecases/get_sales_inventory_report_use_case.dart';
import '../../domain/usecases/get_sales_report_use_case.dart';
import '../controllers/report_controller.dart';

class ReportBinding extends Bindings {
  @override
  void dependencies() {
    // Determine backend provider
    BackendProviderType backend = BackendProviderType.laravel;
    if (Get.isRegistered<AppConfigController>()) {
      backend = Get.find<AppConfigController>().currentBackend.value;
    }

    // Layer 1: Data Source
    Get.lazyPut<ReportDataSource>(
      () => ReportDataSourceFactory.create(backend),
    );

    // Layer 2: Repository
    Get.lazyPut<ReportRepository>(
      () => ReportRepositoryImpl(Get.find<ReportDataSource>()),
    );

    // Layer 3: Use Cases
    Get.lazyPut<GetCustomerListReportUseCase>(
      () => GetCustomerListReportUseCase(Get.find<ReportRepository>()),
    );
    Get.lazyPut<GetSalesReportUseCase>(
      () => GetSalesReportUseCase(Get.find<ReportRepository>()),
    );
    Get.lazyPut<GetSalesInventoryReportUseCase>(
      () => GetSalesInventoryReportUseCase(Get.find<ReportRepository>()),
    );

    // Layer 4: Controller
    Get.lazyPut<ReportController>(
      () => ReportController(
        getCustomerListReportUseCase: Get.find<GetCustomerListReportUseCase>(),
        getSalesReportUseCase: Get.find<GetSalesReportUseCase>(),
        getSalesInventoryReportUseCase:
            Get.find<GetSalesInventoryReportUseCase>(),
      ),
    );
  }
}
