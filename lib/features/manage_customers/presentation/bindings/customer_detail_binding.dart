import 'package:get/get.dart';
import 'package:pos/core/controllers/app_config_controller.dart';
import 'package:pos/features/manage_customers/data/datasources/customer_data_source.dart';
import 'package:pos/features/manage_customers/data/datasources/customer_data_source_factory.dart';
import 'package:pos/features/manage_customers/data/repositories/customer_repository_impl.dart';
import 'package:pos/features/manage_customers/domain/repositories/customer_repository.dart';
import 'package:pos/features/manage_customers/domain/usecases/get_customer_by_id_use_case.dart';
import 'package:pos/features/manage_customers/presentation/controllers/customer_detail_controller.dart';
import 'package:pos/features/manage_sales/data/datasources/sale_data_source.dart';
import 'package:pos/features/manage_sales/data/datasources/sale_data_source_factory.dart';
import 'package:pos/features/manage_sales/data/repositories/sale_repository_impl.dart';
import 'package:pos/features/manage_sales/domain/repositories/sale_repository.dart';
import 'package:pos/features/manage_sales/domain/usecases/get_sales_use_case.dart';

class CustomerDetailBinding extends Bindings {
  @override
  void dependencies() {
    // Customer dependencies
    if (!Get.isRegistered<CustomerDataSource>()) {
      Get.lazyPut<CustomerDataSource>(
        () => CustomerDataSourceFactory.create(
          Get.find<AppConfigController>().currentBackend.value,
        ),
        fenix: true,
      );
    }
    if (!Get.isRegistered<CustomerRepository>()) {
      Get.lazyPut<CustomerRepository>(
        () => CustomerRepositoryImpl(Get.find<CustomerDataSource>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<GetCustomerByIdUseCase>()) {
      Get.lazyPut<GetCustomerByIdUseCase>(
        () => GetCustomerByIdUseCase(Get.find<CustomerRepository>()),
        fenix: true,
      );
    }

    // Sales dependencies
    if (!Get.isRegistered<SaleDataSource>()) {
      Get.lazyPut<SaleDataSource>(
        () => SaleDataSourceFactory.create(
          Get.find<AppConfigController>().currentBackend.value,
        ),
        fenix: true,
      );
    }
    if (!Get.isRegistered<SaleRepository>()) {
      Get.lazyPut<SaleRepository>(
        () => SaleRepositoryImpl(Get.find<SaleDataSource>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<GetSalesUseCase>()) {
      Get.lazyPut<GetSalesUseCase>(
        () => GetSalesUseCase(Get.find<SaleRepository>()),
        fenix: true,
      );
    }

    // Controller
    Get.lazyPut<CustomerDetailController>(
      () => CustomerDetailController(
        getCustomerByIdUseCase: Get.find<GetCustomerByIdUseCase>(),
        getSalesUseCase: Get.find<GetSalesUseCase>(),
      ),
      fenix: true,
    );
  }
}
