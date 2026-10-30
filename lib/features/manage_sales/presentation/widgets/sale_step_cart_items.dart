import 'package:pos/core/utils/app_data_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pos/features/manage_sales/presentation/controllers/sale_create_controller.dart';
import 'sale_product_picker_dialog.dart';

class SaleStepCartItems extends GetView<SaleCreateController> {
  const SaleStepCartItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cart Summary Banner
        Obx(() => Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Theme.of(context)
                      .dividerColor
                      .withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${controller.addedItems.length} Products in Cart',
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Subtotal: ${AppDataFormatter.formatCurrency(controller.subtotal)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () =>
                        SaleProductPickerDialog.show(context, controller),
                    icon: Icon(Icons.add, size: 16.w),
                    label: const Text('Add Product'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 10.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ],
              ),
            )),
        SizedBox(height: 16.h),

        // Added Items List or Empty State
        Obx(() {
          if (controller.addedItems.isEmpty) {
            return _buildEmptyCartState(context);
          }
          return Column(
            children: List.generate(controller.addedItems.length, (index) {
              final item = controller.addedItems[index];
              return _buildCartItemCard(context, item, index);
            }),
          );
        }),
      ],
    );
  }

  Widget _buildEmptyCartState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 70.w,
            height: 70.w,
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 34.w,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Your Cart is Empty',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Add products to this sale by tapping "+ Add Product" button.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          SizedBox(height: 20.h),
          ElevatedButton.icon(
            onPressed: () =>
                SaleProductPickerDialog.show(context, controller),
            icon: Icon(Icons.add, size: 18.w),
            label: const Text('Add Product to Cart'),
            style: ElevatedButton.styleFrom(
              padding:
                  EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(
      BuildContext context, SaleCreateItemEntry item, int index) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Stock Available: ${item.product.stockQuantity}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.redAccent, size: 20),
                  onPressed: () => controller.removeProduct(index),
                ),
              ],
            ),
            const Divider(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Quantity Stepper
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context)
                          .dividerColor
                          .withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          controller.updateItemQuantity(
                              index, item.quantity - 1);
                        },
                        borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(8.r)),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 6.h),
                          child: Icon(Icons.remove, size: 16.w),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 6.h),
                        color: Theme.of(context)
                            .dividerColor
                            .withValues(alpha: 0.05),
                        child: Text(
                          '${item.quantity}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          if (item.quantity < item.product.stockQuantity) {
                            controller.updateItemQuantity(
                                index, item.quantity + 1);
                          } else {
                            Get.snackbar(
                              'Stock Limit',
                              'Cannot exceed available stock of ${item.product.stockQuantity}',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }
                        },
                        borderRadius: BorderRadius.horizontal(
                            right: Radius.circular(8.r)),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 6.h),
                          child: Icon(Icons.add, size: 16.w),
                        ),
                      ),
                    ],
                  ),
                ),

                // Line Total
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${AppDataFormatter.formatCurrency(item.pricePerUnit)} each',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      AppDataFormatter.formatCurrency(item.lineTotal),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
