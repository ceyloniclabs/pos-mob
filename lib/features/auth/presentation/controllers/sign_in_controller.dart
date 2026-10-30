import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/core/routes/app_pages.dart';
import 'package:pos/core/utils/scaffold_message_utils.dart';

import '../../domain/usecases/sign_in_usecase.dart';
import 'auth_controller.dart';

class SignInController extends GetxController {
  final SignInUseCase signInUseCase;

  SignInController({required this.signInUseCase});

  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> login() async {
    try {
      isLoading.value = true;
      final result = await signInUseCase.execute(
        emailController.text.trim(),
        passwordController.text,
      );
      if (result != null) {
        if (Get.isRegistered<AuthController>()) {
          AuthController.to.setUser(result);
        }
        Get.offAllNamed(Routes.MAIN);
      } else {
        ScaffoldMessageUtils.showError('Invalid credentials');
      }
    } catch (e) {
      ScaffoldMessageUtils.showError('Login failed: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
