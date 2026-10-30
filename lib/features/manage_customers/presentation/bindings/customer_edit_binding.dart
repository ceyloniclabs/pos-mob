import 'package:get/get.dart';
import 'package:pos/core/controllers/app_config_controller.dart';
import 'package:pos/features/manage_customers/data/datasources/customer_data_source.dart';
import 'package:pos/features/manage_customers/data/datasources/customer_data_source_factory.dart';
import 'package:pos/features/manage_customers/data/repositories/customer_repository_impl.dart';
import 'package:pos/features/manage_customers/domain/repositories/customer_repository.dart';
import 'package:pos/features/manage_customers/domain/usecases/update_customer_use_case.dart';
import 'package:pos/features/manage_customers/presentation/controllers/customer_edit_controller.dart';

class CustomerEditBinding extends Bindings {
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

    Get.lazyPut<UpdateCustomerUseCase>(
      () => UpdateCustomerUseCase(Get.find<CustomerRepository>()),
    );

    Get.lazyPut<CustomerEditController>(
      () => CustomerEditController(
        updateCustomerUseCase: Get.find<UpdateCustomerUseCase>(),
      ),
    );
  }
}
