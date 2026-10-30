import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:pos/core/constants/app_sizes.dart';
import 'package:pos/core/routes/app_pages.dart';
import 'package:pos/core/widgets/build_setting_tile.dart';
import 'package:pos/core/widgets/custome_app_bar.dart';
import 'setting_form_utils.dart';

class InventoryView extends StatelessWidget {
  const InventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomeAppBar(
        title: 'Inventory & Catalog',
        centerTitle: true,
        showbackArrow: true,
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.sm,
          ),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  buildSettingTile(
                    title: 'Products / Items',
                    subtitle: 'Manage retail sale items, prices, and stock',
                    onTap: () {
                      Get.toNamed(Routes.SALE_ITEM_LIST);
                    },
                  ),
                  buildMenuDivider(),
                  buildSettingTile(
                    title: 'Categories',
                    subtitle: 'Manage catalog categories',
                    onTap: () {
                      Get.toNamed(Routes.SALE_CATEGORY);
                    },
                  ),
                  buildMenuDivider(),
                  buildSettingTile(
                    title: 'Sub Categories',
                    subtitle: 'Manage item sub categories',
                    onTap: () {
                      Get.toNamed(Routes.SALE_SUB_CATEGORY);
                    },
                  ),
                  buildMenuDivider(),
                  buildSettingTile(
                    title: 'Brands',
                    subtitle: 'Manage item brands',
                    onTap: () {
                      Get.toNamed(Routes.SALE_BRANDS);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
