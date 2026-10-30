import 'package:get/get.dart';
import 'package:pos/core/controllers/app_config_controller.dart';

import '../../data/datasources/auth_data_source.dart';
import '../../data/datasources/auth_data_source_factory.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../controllers/auth_controller.dart';
import '../controllers/sign_in_controller.dart';
import '../controllers/sign_up_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // 1. DataSource
    Get.lazyPut<AuthDataSource>(
      () => AuthDataSourceFactory.create(
          Get.find<AppConfigController>().currentBackend.value),
    );

    // 2. Repository
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(),
    );

    // 3. Use Cases
    Get.lazyPut<SignInUseCase>(
      () => SignInUseCase(Get.find<AuthRepository>()),
    );
    Get.lazyPut<SignUpUseCase>(
      () => SignUpUseCase(Get.find<AuthRepository>()),
    );
    Get.lazyPut<SignOutUseCase>(
      () => SignOutUseCase(Get.find<AuthRepository>()),
    );
    Get.lazyPut<GetCurrentUserUseCase>(
      () => GetCurrentUserUseCase(Get.find<AuthRepository>()),
    );

    // 4. Controllers
    Get.lazyPut<AuthController>(
      () => AuthController(
        signOutUseCase: Get.find<SignOutUseCase>(),
        getCurrentUserUseCase: Get.find<GetCurrentUserUseCase>(),
      ),
    );
    Get.lazyPut<SignInController>(
      () => SignInController(
        signInUseCase: Get.find<SignInUseCase>(),
      ),
    );
    Get.lazyPut<SignUpController>(
      () => SignUpController(
        signUpUseCase: Get.find<SignUpUseCase>(),
      ),
    );
  }
}
