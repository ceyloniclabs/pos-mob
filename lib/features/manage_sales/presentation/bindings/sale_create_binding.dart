import 'package:get/get.dart';
import 'package:pos/core/controllers/app_config_controller.dart';
import 'package:pos/features/auth/presentation/controllers/auth_controller.dart';
import 'package:pos/features/manage_customers/data/datasources/customer_data_source.dart';
import 'package:pos/features/manage_customers/data/datasources/customer_data_source_factory.dart';
import 'package:pos/features/manage_customers/data/repositories/customer_repository_impl.dart';
import 'package:pos/features/manage_customers/domain/repositories/customer_repository.dart';
import 'package:pos/features/manage_customers/domain/usecases/get_customers_use_case.dart';
import 'package:pos/features/manage_sales/data/datasources/sale_data_source.dart';
import 'package:pos/features/manage_sales/data/datasources/sale_data_source_factory.dart';
import 'package:pos/features/manage_sales/data/repositories/sale_repository_impl.dart';
import 'package:pos/features/manage_sales/domain/repositories/sale_repository.dart';
import 'package:pos/features/manage_sales/domain/usecases/create_sale_use_case.dart';
import 'package:pos/features/manage_sales/domain/usecases/get_sale_customers_use_case.dart';
import 'package:pos/features/manage_sales/domain/usecases/get_sale_items_use_case.dart';
import 'package:pos/features/manage_sales/domain/usecases/update_sale_use_case.dart';
import 'package:pos/features/manage_sales/presentation/controllers/sale_create_controller.dart';

class SaleCreateBinding extends Bindings {
  @override
  void dependencies() {
    // Layer 1: Data Source
    if (!Get.isRegistered<SaleDataSource>()) {
      Get.lazyPut<SaleDataSource>(
        () => SaleDataSourceFactory.create(
          Get.find<AppConfigController>().currentBackend.value,
        ),
      );
    }

    // Layer 2: Repository
    if (!Get.isRegistered<SaleRepository>()) {
      Get.lazyPut<SaleRepository>(
        () => SaleRepositoryImpl(Get.find<SaleDataSource>()),
      );
    }

    // Customer dependencies for customer selection
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

    if (!Get.isRegistered<GetCustomersUseCase>()) {
      Get.lazyPut<GetCustomersUseCase>(
        () => GetCustomersUseCase(Get.find<CustomerRepository>()),
        fenix: true,
      );
    }

    // Layer 3: Use Cases
    Get.lazyPut<GetSaleCustomersUseCase>(
      () => GetSaleCustomersUseCase(Get.find<SaleRepository>()),
    );

    Get.lazyPut<GetSaleItemsUseCase>(
      () => GetSaleItemsUseCase(Get.find<SaleRepository>()),
    );

    Get.lazyPut<CreateSaleUseCase>(
      () => CreateSaleUseCase(Get.find<SaleRepository>()),
    );

    Get.lazyPut<UpdateSaleUseCase>(
      () => UpdateSaleUseCase(Get.find<SaleRepository>()),
    );

    // Layer 4: Controller
    Get.lazyPut<SaleCreateController>(
      () => SaleCreateController(
        getSaleCustomersUseCase: Get.find<GetSaleCustomersUseCase>(),
        getSaleItemsUseCase: Get.find<GetSaleItemsUseCase>(),
        createSaleUseCase: Get.find<CreateSaleUseCase>(),
        updateSaleUseCase: Get.find<UpdateSaleUseCase>(),
        authController: Get.find<AuthController>(),
      ),
      fenix: true,
    );
  }
}
