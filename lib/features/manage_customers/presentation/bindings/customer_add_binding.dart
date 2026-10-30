import 'package:get/get.dart';
import 'package:pos/core/controllers/app_config_controller.dart';
import 'package:pos/features/manage_customers/data/datasources/customer_data_source.dart';
import 'package:pos/features/manage_customers/data/datasources/customer_data_source_factory.dart';
import 'package:pos/features/manage_customers/data/repositories/customer_repository_impl.dart';
import 'package:pos/features/manage_customers/domain/repositories/customer_repository.dart';
import 'package:pos/features/manage_customers/domain/usecases/create_customer_use_case.dart';
import 'package:pos/features/manage_customers/presentation/controllers/customer_add_controller.dart';

class CustomerAddBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerDataSource>(
      () => CustomerDataSourceFactory.create(
        Get.find<AppConfigController>().currentBackend.value,
      ),
    );

    Get.lazyPut<CustomerRepository>(
      () => CustomerRepositoryImpl(Get.find<CustomerDataSource>()),
    );

    Get.lazyPut<CreateCustomerUseCase>(
      () => CreateCustomerUseCase(Get.find<CustomerRepository>()),
    );

    Get.lazyPut<CustomerAddController>(
      () => CustomerAddController(
        createCustomerUseCase: Get.find<CreateCustomerUseCase>(),
      ),
    );
  }
}
