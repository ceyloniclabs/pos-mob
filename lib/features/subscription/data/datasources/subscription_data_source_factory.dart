import 'package:get/get.dart';
import 'package:pos/core/enums.dart';
import 'package:pos/core/network/api_service.dart';
import 'subscription_data_source.dart';
import 'subscription_laravel_data_source_impl.dart';

class SubscriptionDataSourceFactory {
  static SubscriptionDataSource create(BackendProviderType type) {
    switch (type) {
      case BackendProviderType.laravel:
        return SubscriptionLaravelDataSourceImpl(Get.find<ApiService>());
      case BackendProviderType.firebase:
        throw UnimplementedError('Provider $type is not supported for subscriptions');
    }
  }
}
