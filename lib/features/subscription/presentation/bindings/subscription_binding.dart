import 'package:get/get.dart';
import 'package:pos/core/controllers/app_config_controller.dart';
import '../../data/datasources/subscription_data_source.dart';
import '../../data/datasources/subscription_data_source_factory.dart';
import '../../data/repositories/subscription_repository_impl.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../../domain/usecases/get_current_subscription_use_case.dart';
import '../../domain/usecases/get_subscription_history_use_case.dart';
import '../controllers/subscription_controller.dart';

class SubscriptionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SubscriptionDataSource>(
      () => SubscriptionDataSourceFactory.create(
        Get.find<AppConfigController>().currentBackend.value,
      ),
    );

    Get.lazyPut<SubscriptionRepository>(
      () => SubscriptionRepositoryImpl(Get.find<SubscriptionDataSource>()),
    );

    Get.lazyPut<GetCurrentSubscriptionUseCase>(
      () => GetCurrentSubscriptionUseCase(Get.find<SubscriptionRepository>()),
    );

    Get.lazyPut<GetSubscriptionHistoryUseCase>(
      () => GetSubscriptionHistoryUseCase(Get.find<SubscriptionRepository>()),
    );

    Get.lazyPut<SubscriptionController>(
      () => SubscriptionController(
        getCurrentSubscriptionUseCase: Get.find<GetCurrentSubscriptionUseCase>(),
        getSubscriptionHistoryUseCase: Get.find<GetSubscriptionHistoryUseCase>(),
      ),
    );
  }
}
