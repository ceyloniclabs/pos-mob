import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

class DialogUtils {
  static void showImageSourceDialog({
    required Function(ImageSource) onImageSourceSelected,
  }) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SafeArea(
          bottom: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Image Source',
                style: Get.textTheme.titleMedium,
              ),
              SizedBox(height: 16.h),
              ListTile(
                leading: Icon(Iconsax.camera, size: 24.w),
                title: const Text('Camera'),
                onTap: () {
                  Get.back();
                  onImageSourceSelected(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Iconsax.gallery, size: 24.w),
                title: const Text('Gallery'),
                onTap: () {
                  Get.back();
                  onImageSourceSelected(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
