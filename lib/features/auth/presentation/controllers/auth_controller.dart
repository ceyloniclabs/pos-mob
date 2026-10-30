import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/core/routes/app_pages.dart';
import 'package:pos/core/storage/app_storage.dart';
import 'package:pos/core/utils/scaffold_message_utils.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';

/// Global session controller managing authenticated user state and application session.
class AuthController extends GetxController {
  static AuthController get to => Get.find<AuthController>();

  final SignOutUseCase signOutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final AppStorage _storage = AppStorage();

  AuthController({
    required this.signOutUseCase,
    required this.getCurrentUserUseCase,
  });

  final Rxn<UserEntity> user = Rxn<UserEntity>();

  bool get isLoggedIn => user.value != null;

  void setUser(UserEntity? newUser) {
    user.value = newUser;
  }

  Future<void> restoreSession() async {
    try {
      final currentUser = await getCurrentUserUseCase.execute();
      if (currentUser != null) {
        user.value = currentUser;
      } else {
        throw Exception('Session expired');
      }
    } catch (e) {
      user.value = null;
      await _storage.removeData('token');
      throw Exception('Failed to restore session');
    }
  }

  Future<void> logout() async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      await signOutUseCase.execute();
    } catch (_) {
      // Continue with full local cleanup even if API fails or device is offline
    } finally {
      user.value = null;
      await _storage.removeData('token');
      await _storage.removeData('user');
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      Get.offAllNamed(Routes.SPLASH);
      ScaffoldMessageUtils.showSuccess('Logged out successfully');
    }
  }
}
