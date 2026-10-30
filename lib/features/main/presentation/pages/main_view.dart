import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:pos/features/home/presentation/pages/home_view.dart';
import 'package:pos/features/manage_sales/presentation/pages/sale_create_view.dart';
import 'package:pos/features/manage_sales/presentation/pages/sale_view.dart';
import 'package:pos/features/main/presentation/controllers/main_controller.dart';
import 'package:pos/features/main/presentation/pages/custom_bottom_nav_bar.dart';
import 'package:pos/features/main/presentation/pages/more_menu_view.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  final List<Widget> pages = const [
    HomeView(),
    SaleCreateView(),
    SaleView(),
    MoreMenuView(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        controller.handleBackPress(context);
      },
      child: Scaffold(
        body: Obx(
          () => AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                fit: StackFit.expand,
                alignment: Alignment.topCenter,
                children: <Widget>[
                  ...previousChildren,
                  ?currentChild,
                ],
              );
            },
            child: KeyedSubtree(
              key: ValueKey(controller.currentIndex.value),
              child: pages[controller.currentIndex.value],
            ),
          ),
        ),
        bottomNavigationBar: Obx(
          () => CustomBottomNavBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changePage,
          ),
        ),
      ),
    );
  }
}
