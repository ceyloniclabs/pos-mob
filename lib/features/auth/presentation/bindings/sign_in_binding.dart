import 'package:get/get.dart';

import '../../domain/usecases/sign_in_usecase.dart';
import '../controllers/sign_in_controller.dart';

class SignInBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignInController>(
      () => SignInController(
        signInUseCase: Get.find<SignInUseCase>(),
      ),
    );
  }
}
