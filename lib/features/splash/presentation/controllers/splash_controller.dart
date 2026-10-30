import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:pos/core/routes/app_pages.dart';
import 'package:pos/core/services/app_info_service.dart';
import 'package:pos/core/storage/app_storage.dart';
import 'package:pos/core/utils/app_dialog_utils.dart';
import 'package:pos/features/auth/presentation/controllers/auth_controller.dart';

import '../../domain/entities/maintenance_info.dart';
import '../../domain/usecases/check_app_update_use_case.dart';

class SplashController extends GetxController {
  final CheckAppUpdateUseCase _checkAppUpdateUseCase;
  final AppStorage _storage = AppStorage();

  SplashController(this._checkAppUpdateUseCase);

  final RxString statusMessage = 'Initializing application...'.obs;
  final RxDouble progress = 0.1.obs;
  final RxString buildNumber = ''.obs;

  final Completer<void> _animationCompleter = Completer<void>();

  @override
  void onInit() {
    super.onInit();
    _startInitialization();
  }

  /// Signals that the splash wave animation has completed or reached the navigation cue.
  void onAnimationCompleted() {
    if (!_animationCompleter.isCompleted) {
      _animationCompleter.complete();
    }
  }

  /// Allows skipping the animation (e.g. on user tap).
  void skipAnimation() {
    if (!_animationCompleter.isCompleted) {
      _animationCompleter.complete();
    }
  }

  Future<void> _startInitialization() async {
    try {
      // 1. Fetch package info
      final info = await Get.find<AppInfoService>().packageInfo;
      buildNumber.value = info.buildNumber;
    } catch (error, stackTrace) {
      Get.log('Unable to load app package information: $error\n$stackTrace');
    }

    await Future.delayed(const Duration(milliseconds: 300));

    // Phase 1: Connectivity check
    statusMessage.value = 'Checking network connectivity...';
    progress.value = 0.35;
    final hasInternet = await _checkConnectivity();

    await Future.delayed(const Duration(milliseconds: 300));

    // Phase 2: App update & maintenance check
    if (hasInternet) {
      statusMessage.value = 'Checking for updates...';
      progress.value = 0.65;

      final updateBlocked = await _checkForAppUpdates();
      if (updateBlocked) {
        // Stop navigation if force update or maintenance is active
        return;
      }
    }

    await Future.delayed(const Duration(milliseconds: 300));

    // Phase 3: Session & Onboarding check
    statusMessage.value = 'Restoring session...';
    progress.value = 1.0;

    await Future.delayed(const Duration(milliseconds: 350));
    await _proceedNavigation();
  }

  Future<bool> _checkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return !connectivityResult.contains(ConnectivityResult.none);
    } catch (_) {
      return true;
    }
  }

  /// Returns true if app should halt on current screen (force update or maintenance)
  Future<bool> _checkForAppUpdates() async {
    try {
      final currentBuild = int.tryParse(buildNumber.value) ?? 0;
      final versionInfo = await _checkAppUpdateUseCase.execute();

      if (versionInfo == null) return false;

      // Check maintenance mode first
      if (versionInfo.isMaintenance) {
        AppDialogUtils.showMaintenanceDialog(
          MaintenanceInfo(
            message: versionInfo.maintenanceMessage ??
                'Our systems are currently undergoing scheduled maintenance. Please check back soon.',
            estimatedEndTime: versionInfo.maintenanceEta,
          ),
          onRetry: () => _startInitialization(),
        );
        return true;
      }

      // Check version update
      if (versionInfo.latestBuildNumber > currentBuild) {
        if (Platform.isAndroid) {
          try {
            final updateInfo = await InAppUpdate.checkForUpdate();
            if (updateInfo.updateAvailability ==
                UpdateAvailability.updateAvailable) {
              if (versionInfo.isForceUpdate &&
                  updateInfo.immediateUpdateAllowed) {
                await InAppUpdate.performImmediateUpdate();
                return true;
              } else if (!versionInfo.isForceUpdate &&
                  updateInfo.flexibleUpdateAllowed) {
                await InAppUpdate.startFlexibleUpdate();
                await InAppUpdate.completeFlexibleUpdate();
                return false;
              }
            }
          } catch (_) {
            // Fallback to regular dialogs if in_app_update fails
          }
        }

        if (versionInfo.isForceUpdate) {
          AppDialogUtils.showForceUpdateDialog(versionInfo);
          return true;
        } else {
          // Soft update, display dialog and permit app flow
          AppDialogUtils.showSoftUpdateDialog(versionInfo);
          return false;
        }
      }
    } catch (_) {
      // If error occurs during update check, do not block user
    }
    return false;
  }

  Future<void> _proceedNavigation() async {
    // Wait until the splash wave animation completes (with 5s fallback timeout)
    try {
      await _animationCompleter.future.timeout(const Duration(seconds: 5));
    } catch (_) {
      // Fallback in case animation timing timed out
    }

    // 1. Check user auth token - If logged in, navigate straight to MAIN
    final token = _storage.readData<String>('token');
    if (token != null) {
      try {
        if (Get.isRegistered<AuthController>()) {
          final authController = Get.find<AuthController>();
          await authController.restoreSession();
        }
        Get.offNamed(Routes.MAIN);
        return;
      } catch (e) {
        await _storage.removeData('token');
      }
    }

    // 2. If user is NOT logged in, always show the Connection Mode selection screen
    Get.offNamed(Routes.CONNECTION_MODE);
  }

  @override
  void onClose() {
    if (!_animationCompleter.isCompleted) {
      _animationCompleter.complete();
    }
    super.onClose();
  }
}
