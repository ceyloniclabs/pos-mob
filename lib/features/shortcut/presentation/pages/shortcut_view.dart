import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'package:pos/core/widgets/custome_app_bar.dart';
import 'package:pos/features/shortcut/presentation/controllers/shortcut_controller.dart';
import 'package:pos/features/shortcut/presentation/widgets/short_cut_tile.dart';

class ShortcutView extends GetView<ShortcutController> {
  const ShortcutView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomeAppBar(
        title: 'App Shortcuts',
        centerTitle: true,
        showbackArrow: true,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.primary,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30.r,
                backgroundColor: Colors.white,
                child: Icon(Iconsax.shop, size: 30.w),
              ),
              SizedBox(height: 10.h),
              Text(
                'Surf Shop',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                    ),
              ),
              Text(
                'Management System',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
              ),
              Divider(color: Colors.white54),
              SizedBox(height: 16.h),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: controller.shortcuts.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1,
                  mainAxisExtent: 85.h,
                ),
                itemBuilder: (context, index) {
                  final item = controller.shortcuts[index];
                  return ShortcutTile(
                    label: item['label']!.toString(),
                    icon: item['icon'] as IconData,
                    onTap: () {
                      Get.toNamed(item['route']!.toString());
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
