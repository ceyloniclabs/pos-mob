import 'package:get/get.dart';
import 'package:pos/core/controllers/app_config_controller.dart';
import 'package:pos/features/manage_customers/data/datasources/customer_data_source.dart';
import 'package:pos/features/manage_customers/data/datasources/customer_data_source_factory.dart';
import 'package:pos/features/manage_customers/data/repositories/customer_repository_impl.dart';
import 'package:pos/features/manage_customers/domain/repositories/customer_repository.dart';
import 'package:pos/features/manage_customers/domain/usecases/create_customer_use_case.dart';
import 'package:pos/features/manage_customers/domain/usecases/delete_customer_use_case.dart';
import 'package:pos/features/manage_customers/domain/usecases/get_customers_use_case.dart';
import 'package:pos/features/manage_customers/domain/usecases/get_customer_by_id_use_case.dart';
import 'package:pos/features/manage_customers/domain/usecases/update_customer_use_case.dart';
import 'package:pos/features/manage_customers/domain/usecases/upload_customer_photo_use_case.dart';

import 'package:pos/features/manage_customers/presentation/controllers/customer_list_controller.dart';

class CustomerListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerDataSource>(
      () => CustomerDataSourceFactory.create(
          Get.find<AppConfigController>().currentBackend.value),
      fenix: true,
    );
    Get.lazyPut<CustomerRepository>(
      () => CustomerRepositoryImpl(Get.find<CustomerDataSource>()),
      fenix: true,
    );

    Get.lazyPut<GetCustomersUseCase>(() => GetCustomersUseCase(Get.find<CustomerRepository>()), fenix: true);
    Get.lazyPut<GetCustomerByIdUseCase>(() => GetCustomerByIdUseCase(Get.find<CustomerRepository>()), fenix: true);
    Get.lazyPut<DeleteCustomerUseCase>(() => DeleteCustomerUseCase(Get.find<CustomerRepository>()), fenix: true);
    Get.lazyPut<CreateCustomerUseCase>(() => CreateCustomerUseCase(Get.find<CustomerRepository>()), fenix: true);
    Get.lazyPut<UpdateCustomerUseCase>(() => UpdateCustomerUseCase(Get.find<CustomerRepository>()), fenix: true);
    Get.lazyPut<UploadCustomerPhotoUseCase>(() => UploadCustomerPhotoUseCase(Get.find<CustomerRepository>()), fenix: true);

    Get.lazyPut<CustomerListController>(
      () => CustomerListController(
        getCustomersUseCase: Get.find<GetCustomersUseCase>(),
        deleteCustomerUseCase: Get.find<DeleteCustomerUseCase>(),
      ),
    );
  }
}
