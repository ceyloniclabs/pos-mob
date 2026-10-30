import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pos/core/utils/app_data_formatter.dart';
import 'package:pos/features/manage_sale_items/domain/entities/sale_item.dart';
import 'package:pos/features/manage_sales/presentation/controllers/sale_create_controller.dart';

class SaleProductPickerDialog {
  static void show(BuildContext context, SaleCreateController controller) {
    SaleItem? selectedProduct;
    final quantityController = TextEditingController(text: '1');
    final priceController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                top: 16.h,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Product *',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // Virtualized Searchable Product Selector Tile (Replaces DropdownButton to prevent OOM)
                  InkWell(
                    onTap: () {
                      _openVirtualizedProductSearch(
                        context,
                        controller.availableSaleItems,
                        (chosen) {
                          setState(() {
                            selectedProduct = chosen;
                            priceController.text =
                                chosen.sellingPrice.toStringAsFixed(2);
                          });
                        },
                      );
                    },
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 14.h,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                        borderRadius: BorderRadius.circular(8.r),
                        color: Theme.of(context).cardColor,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Iconsax.box,
                            size: 20.w,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: selectedProduct == null
                                ? Text(
                                    '-- Tap to search & choose product --',
                                    style: TextStyle(
                                      color: Theme.of(context).hintColor,
                                      fontSize: 14.sp,
                                    ),
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        selectedProduct!.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.sp,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        'Stock: ${selectedProduct!.stockQuantity} | ${AppDataFormatter.formatCurrency(selectedProduct!.sellingPrice)}',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Quantity input
                  Text(
                    'Quantity *',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 6.h),
                  TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 10.h),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Price input
                  Text(
                    'Price (${controller.shopCurrency}) *',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 6.h),
                  TextField(
                    controller: priceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 10.h),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Confirm button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (selectedProduct == null) {
                          Get.snackbar(
                            'Select Product',
                            'Please select a product from the list',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }
                        final qty =
                            int.tryParse(quantityController.text.trim()) ?? 1;
                        final price =
                            double.tryParse(priceController.text.trim()) ??
                                selectedProduct!.sellingPrice;

                        if (qty > selectedProduct!.stockQuantity) {
                          Get.snackbar(
                            'Stock Limit Exceeded',
                            'Only ${selectedProduct!.stockQuantity} available in stock',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }

                        controller.addProduct(selectedProduct!, qty, price);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: const Text('Add to Cart'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Virtualized searchable modal bottom sheet capable of handling thousands of items smoothly without OOM.
  static void _openVirtualizedProductSearch(
    BuildContext context,
    List<SaleItem> allProducts,
    void Function(SaleItem) onSelected,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (searchCtx) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final query = searchQuery.trim().toLowerCase();
            final filtered = query.isEmpty
                ? allProducts
                : allProducts.where((p) {
                    final nameMatch = p.name.toLowerCase().contains(query);
                    final brandMatch =
                        p.brandName?.toLowerCase().contains(query) ?? false;
                    final categoryMatch =
                        p.categoryName?.toLowerCase().contains(query) ?? false;
                    return nameMatch || brandMatch || categoryMatch;
                  }).toList();

            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.85,
              child: Column(
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 10.h),
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select Product (${filtered.length})',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Search Field
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: TextField(
                      autofocus: false,
                      onChanged: (val) {
                        setModalState(() {
                          searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search product by name, brand, category...',
                        prefixIcon: const Icon(Iconsax.search_normal, size: 20),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Virtualized List
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Text(
                              'No matching products found',
                              style: TextStyle(
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            itemCount: filtered.length,
                            separatorBuilder: (context, index) => Divider(
                              height: 1,
                              color: Theme.of(context)
                                  .dividerColor
                                  .withValues(alpha: 0.1),
                            ),
                            itemBuilder: (context, index) {
                              final item = filtered[index];
                              return ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 4.w,
                                  vertical: 4.h,
                                ),
                                title: Text(
                                  item.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                subtitle: Text(
                                  '${item.brandName ?? 'Generic'} • ${item.categoryName ?? ''} • Stock: ${item.stockQuantity}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                                trailing: Text(
                                  AppDataFormatter.formatCurrency(
                                      item.sellingPrice),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                  ),
                                ),
                                onTap: () {
                                  onSelected(item);
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
