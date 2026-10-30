import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/core/routes/app_pages.dart';
import 'package:pos/core/utils/scaffold_message_utils.dart';

import '../../domain/usecases/sign_up_usecase.dart';
import 'auth_controller.dart';

class SignUpController extends GetxController {
  final SignUpUseCase signUpUseCase;

  SignUpController({required this.signUpUseCase});

  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> signUp() async {
    try {
      isLoading.value = true;
      final result = await signUpUseCase.execute(
        nameController.text.trim(),
        emailController.text.trim(),
        passwordController.text,
      );
      if (result != null) {
        if (Get.isRegistered<AuthController>()) {
          AuthController.to.setUser(result);
        }
        Get.offAllNamed(Routes.MAIN);
      } else {
        ScaffoldMessageUtils.showError('Unable to create account');
      }
    } catch (e) {
      ScaffoldMessageUtils.showError('Sign up failed: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
