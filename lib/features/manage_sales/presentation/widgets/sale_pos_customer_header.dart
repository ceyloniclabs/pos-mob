import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pos/features/manage_customers/domain/entities/customer.dart';
import 'package:pos/features/manage_customers/presentation/widgets/customer_selection_bottom_sheet.dart';
import 'package:pos/features/manage_sales/presentation/controllers/sale_create_controller.dart';

class SalePosCustomerHeader extends GetView<SaleCreateController> {
  const SalePosCustomerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final customer = controller.selectedCustomer.value;

      if (customer == null) {
        return IconButton(
          icon: Icon(Icons.person_add_alt_1, size: 24.w),
          tooltip: 'Select Customer',
          onPressed: () => _openCustomerPicker(context),
        );
      }

      return Padding(
        padding: EdgeInsets.only(right: 8.w),
        child: Center(
          child: InkWell(
            borderRadius: BorderRadius.circular(20.r),
            onTap: () => _openCustomerPicker(context),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Iconsax.user_tick,
                    size: 16.w,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    customer.name.length > 12
                        ? '${customer.name.substring(0, 12)}...'
                        : customer.name,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  InkWell(
                    onTap: () => controller.selectedCustomer.value = null,
                    borderRadius: BorderRadius.circular(10.r),
                    child: Padding(
                      padding: EdgeInsets.all(2.w),
                      child: Icon(
                        Icons.close,
                        size: 16.w,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  void _openCustomerPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CustomerSelectionBottomSheet(
        allowWalkIn: true,
        selectedCustomer: controller.selectedCustomer.value,
        onCustomerSelected: (Customer? selected) {
          controller.selectedCustomer.value = selected;
        },
      ),
    );
  }
}
