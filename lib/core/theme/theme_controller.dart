import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pos/core/utils/device_utils.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find();
  final _storage = GetStorage();
  final _key = 'isDarkMode';

  final _themeMode = ThemeMode.system.obs;
  ThemeMode get themeMode => _themeMode.value;

  /// Helper to determine the initial dark mode before controllers are bound.
  static bool getInitialIsDarkMode() {
    final storage = GetStorage();
    final saved = storage.read<bool>('isDarkMode');
    if (saved != null) return saved;
    return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
        Brightness.dark;
  }

  @override
  void onInit() {
    super.onInit();
    _loadThemeFromStorage();
  }

  bool get isDarkMode {
    if (_themeMode.value == ThemeMode.system) {
      return Get.isPlatformDarkMode;
    }
    return _themeMode.value == ThemeMode.dark;
  }

  void updateSystemOverlay([bool? dark]) {
    final isDark = dark ?? isDarkMode;
    DeviceUtils.updateSystemOverlay(isDark: isDark);
  }

  void _loadThemeFromStorage() {
    final savedTheme = _storage.read<bool>(_key);
    if (savedTheme == null) {
      _themeMode.value = ThemeMode.system;
    } else {
      _themeMode.value = savedTheme ? ThemeMode.dark : ThemeMode.light;
    }
    Get.changeThemeMode(_themeMode.value);
    updateSystemOverlay();
  }

  void toggleTheme() {
    final newIsDark = !isDarkMode;
    _themeMode.value = newIsDark ? ThemeMode.dark : ThemeMode.light;
    _storage.write(_key, newIsDark);
    Get.changeThemeMode(_themeMode.value);
    updateSystemOverlay(newIsDark);
  }
}
