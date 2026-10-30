import 'package:get/get.dart';

import '../../domain/usecases/sign_up_usecase.dart';
import '../controllers/sign_up_controller.dart';

class SignUpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignUpController>(
      () => SignUpController(
        signUpUseCase: Get.find<SignUpUseCase>(),
      ),
    );
  }
}
