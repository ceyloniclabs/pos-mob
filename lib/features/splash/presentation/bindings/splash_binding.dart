import 'package:get/get.dart';
import 'package:pos/core/network/api_service.dart';
import '../../data/datasources/app_update_datasource.dart';
import '../../data/repositories/app_update_repository_impl.dart';
import '../../domain/repositories/app_update_repository.dart';
import '../../domain/usecases/check_app_update_use_case.dart';
import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.put(ApiService());
    }

    Get.lazyPut<AppUpdateDataSource>(
      () => AppUpdateDataSourceImpl(Get.find<ApiService>()),
    );

    Get.lazyPut<AppUpdateRepository>(
      () => AppUpdateRepositoryImpl(Get.find<AppUpdateDataSource>()),
    );

    Get.lazyPut<CheckAppUpdateUseCase>(
      () => CheckAppUpdateUseCase(Get.find<AppUpdateRepository>()),
    );

    Get.put(SplashController(Get.find<CheckAppUpdateUseCase>()));
  }
}
