import 'package:get/get.dart';

import '../../features/auth/data/datasources/auth_data_source.dart';
import '../../features/auth/data/datasources/auth_data_source_factory.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../controllers/app_config_controller.dart';
import '../controllers/persistent_data_controller.dart';
import '../network/api_service.dart';
import '../services/app_info_service.dart';
import '../services/qr_scanner/global_qr_router.dart';
import '../storage/app_storage.dart';
import '../theme/theme_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AppInfoService(), permanent: true);
    Get.put(ApiService());
    Get.put(AppStorage());
    Get.put(
      AppConfigController(storage: Get.find<AppStorage>()),
      permanent: true,
    );

    Get.put<AuthDataSource>(
      AuthDataSourceFactory.create(
        Get.find<AppConfigController>().currentBackend.value,
      ),
    );
    Get.put<AuthRepository>(
      AuthRepositoryImpl(),
      permanent: true,
    );

    Get.put(SignInUseCase(Get.find<AuthRepository>()), permanent: true);
    Get.put(SignUpUseCase(Get.find<AuthRepository>()), permanent: true);
    Get.put(SignOutUseCase(Get.find<AuthRepository>()), permanent: true);
    Get.put(GetCurrentUserUseCase(Get.find<AuthRepository>()), permanent: true);

    Get.put<ThemeController>(ThemeController(), permanent: true);
    Get.put<AuthController>(
      AuthController(
        signOutUseCase: Get.find<SignOutUseCase>(),
        getCurrentUserUseCase: Get.find<GetCurrentUserUseCase>(),
      ),
      permanent: true,
    );

    Get.put(PersistentDataController(Get.find<ApiService>()), permanent: true);

    GlobalQrRouter.initializeDefaults();
  }
}
