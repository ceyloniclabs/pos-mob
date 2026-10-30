import 'package:pos/core/utils/app_data_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pos/features/manage_sales/presentation/controllers/sale_create_controller.dart';

class SaleBottomBar extends GetView<SaleCreateController> {
  const SaleBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final current = controller.currentStep.value;

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Back or Cancel Button
              if (current > 0)
                Expanded(
                  flex: 1,
                  child: OutlinedButton.icon(
                    onPressed: controller.previousStep,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
              SizedBox(width: 12.w),

              // Next or Submit Button
              Expanded(
                flex: 2,
                child: current < 2
                    ? ElevatedButton.icon(
                        onPressed: controller.nextStep,
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(
                          current == 0
                              ? 'Next: Cart Items'
                              : 'Proceed to Checkout (${controller.addedItems.length})',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: controller.isSubmitting.value
                            ? null
                            : () => controller.submitSale(
                                isDraft: controller.saleStatus.value == 'pending',
                              ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: controller.isSubmitting.value
                            ? SizedBox(
                                width: 20.w,
                                height: 20.h,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                controller.saleStatus.value == 'pending'
                                    ? 'Save as Quote/Pending'
                                    : 'Save Sale (${AppDataFormatter.formatCurrency(controller.grandTotal)})',
                              ),
                      ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
