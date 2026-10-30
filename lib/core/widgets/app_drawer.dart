import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pos/core/access/access_policy.dart';
import 'package:pos/core/routes/app_pages.dart';
import 'package:pos/core/utils/device_utils.dart';
import 'package:pos/features/auth/presentation/controllers/auth_controller.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final role = AuthController.to.user.value?.role;
    bool can(AppPermission permission) => AccessPolicy.allows(role, permission);

    return Drawer(
      width: DeviceUtils.getScreenWidth() * 0.75,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28.r,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Iconsax.shop,
                    size: 28.w,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Ceylonic POS',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Point of Sale & Inventory',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            icon: Iconsax.home,
            title: 'Dashboard',
            onTap: () {
              Get.offAllNamed(Routes.HOME);
            },
          ),
          if (can(AppPermission.operateSales))
            _buildDrawerItem(
              icon: Iconsax.shop,
              title: 'Quick Register (POS)',
              onTap: () => Get.toNamed(Routes.SALE_ADD),
            ),
          if (can(AppPermission.operateSales))
            _buildDrawerItem(
              icon: Iconsax.receipt_item,
              title: 'Sales & Orders',
              onTap: () => Get.toNamed(Routes.SALES),
            ),
          if (can(AppPermission.manageSalesCatalog))
            _buildDrawerItem(
              icon: Iconsax.box,
              title: 'Products / Items',
              onTap: () => Get.toNamed(Routes.SALE_ITEM_LIST),
            ),
          if (can(AppPermission.registerAndLookupCustomers))
            _buildDrawerItem(
              icon: Iconsax.people,
              title: 'Customers',
              onTap: () => Get.toNamed(Routes.CUSTOMER_LIST),
            ),
          if (can(AppPermission.viewReports))
            _buildDrawerItem(
              icon: Iconsax.document_text,
              title: 'Reports & Analytics',
              onTap: () {
                Get.back();
                Get.toNamed(Routes.REPORT);
              },
            ),
          const Divider(),
          if (can(AppPermission.manageShopSettings))
            _buildDrawerItem(
              icon: Iconsax.setting_2,
              title: 'System Settings',
              onTap: () => Get.toNamed(Routes.SETTING),
            ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 22.w),
      title: Text(title),
      onTap: onTap,
    );
  }
}
