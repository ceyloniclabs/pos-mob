import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:pos/core/widgets/common_dialog.dart';
import 'package:pos/features/manage_sales/presentation/controllers/sale_controller.dart';

class MainController extends GetxController with WidgetsBindingObserver {
  final RxInt currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _checkArguments();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  void _checkArguments() {
    if (Get.arguments != null) {
      if (Get.arguments is int) {
        final target = Get.arguments as int;
        if (target >= 0 && target < 4) {
          currentIndex.value = target;
        }
      } else if (Get.arguments is Map && (Get.arguments as Map).containsKey('tab')) {
        final tab = (Get.arguments as Map)['tab'];
        if (tab is int && tab >= 0 && tab < 4) {
          currentIndex.value = tab;
        }
      }
    }
  }

  void changePage(int index) {
    if (index >= 0 && index < 4) {
      currentIndex.value = index;

      // Refresh sales data when Orders tab is selected (index 2)
      if (index == 2) {
        if (Get.isRegistered<SaleController>()) {
          final saleController = Get.find<SaleController>();
          saleController.refreshSales();
        }
      }
    }
  }

  /// Handles hardware / gesture back navigation on MainView.
  /// If not on Home tab, switches to Home tab.
  /// If on Home tab, displays Exit App confirmation dialog.
  Future<void> handleBackPress(BuildContext context) async {
    if (currentIndex.value != 0) {
      changePage(0);
      return;
    }

    if (Get.isDialogOpen == true || Get.isBottomSheetOpen == true) return;

    HapticFeedback.lightImpact();
    await CommonDialog.showExitDialog();
  }
}
