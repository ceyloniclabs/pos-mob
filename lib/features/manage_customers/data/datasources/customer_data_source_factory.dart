import 'package:get/get.dart';
import 'package:pos/core/enums.dart';
import 'package:pos/core/network/api_service.dart';
import 'package:pos/features/manage_customers/data/datasources/customer_data_source.dart';
import 'package:pos/features/manage_customers/data/datasources/customer_laravel_data_source_impl.dart';

class CustomerDataSourceFactory {
  static CustomerDataSource create(BackendProviderType type) {
    switch (type) {
      case BackendProviderType.firebase:
      // return FirebaseCustomerDataSource();
      case BackendProviderType.laravel:
        return CustomerLaravelDataSourceImpl(
          Get.find<ApiService>(),
        );
    }
  }
}
