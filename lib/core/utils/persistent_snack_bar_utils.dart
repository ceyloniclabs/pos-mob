import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PersistentSnackBarUtils {
  static void showPersistentError(String message) {
    _closeAndShow(
      title: 'Error',
      message: message,
      background: Colors.red.withValues(alpha: 0.1),
      icon: const Icon(Icons.error, color: Colors.red),
      textColor: Colors.red,
    );
  }

  static void showPersistentSuccess(String message) {
    _closeAndShow(
      title: 'Success',
      message: message,
      background: Colors.green.withValues(alpha: 0.1),
      icon: const Icon(Icons.check_circle, color: Colors.green),
      textColor: Colors.green,
    );
  }

  static void showPersistentInfo(String message) {
    _closeAndShow(
      title: 'Info',
      message: message,
      background: Colors.blue.withValues(alpha: 0.1),
      icon: const Icon(Icons.info_outline, color: Colors.blue),
      textColor: Colors.blue,
    );
  }

  static void _closeAndShow({
    required String title,
    required String message,
    required Color background,
    required Icon icon,
    required Color textColor,
  }) {
    Get.closeAllSnackbars();
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: background,
      colorText: textColor,
      duration: null, // Persistent
      isDismissible: true,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: icon,
      mainButton: TextButton(
        onPressed: () => Get.closeAllSnackbars(),
        child: Text(
          'Dismiss',
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }
}
