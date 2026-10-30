import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pos/features/manage_customers/domain/entities/customer.dart';
import 'package:pos/features/manage_customers/presentation/widgets/customer_selection_bottom_sheet.dart';
import 'package:pos/features/manage_sales/presentation/controllers/sale_create_controller.dart';

class SaleStepCustomer extends GetView<SaleCreateController> {
  const SaleStepCustomer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Customer Selection Card
        _buildCard(
          context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 20.w,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Customer Details',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              Obx(() {
                final customer = controller.selectedCustomer.value;
                return InkWell(
                  onTap: () => _openCustomerPicker(context),
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.35),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18.r,
                          backgroundColor: customer == null
                              ? Theme.of(context).colorScheme.secondaryContainer
                              : Theme.of(context).colorScheme.primaryContainer,
                          child: Icon(
                            customer == null ? Iconsax.user : Iconsax.user_tick,
                            color: customer == null
                                ? Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer
                                : Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                            size: 18.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customer?.name ?? 'Walk-in Customer (Default)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                customer != null
                                    ? '${customer.phone} • ${customer.membershipLevel.toUpperCase()}'
                                    : 'Tap to search & select registered customer',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        if (customer != null)
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            tooltip: 'Reset to Walk-in',
                            onPressed: () =>
                                controller.selectedCustomer.value = null,
                          )
                        else
                          Icon(
                            Icons.arrow_drop_down,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                      ],
                    ),
                  ),
                );
              }),
              Obx(() {
                final customer = controller.selectedCustomer.value;
                if (customer == null) return const SizedBox.shrink();
                return Column(
                  children: [
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 18.w,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  customer.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Phone: ${customer.phone} • Membership: ${customer.membershipLevel.toUpperCase()}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // Sale Status & Payment Method Card
        _buildCard(
          context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.settings_outlined,
                    size: 20.w,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Sale Configuration',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Sale Status
              _buildSectionLabel(context, 'SALE STATUS'),
              SizedBox(height: 8.h),
              Obx(() => Row(
                    children: [
                      Expanded(
                        child: _buildSelectablePill(
                          context,
                          title: 'Completed',
                          icon: Icons.check_circle_outline,
                          isSelected:
                              controller.saleStatus.value == 'completed',
                          onTap: () => controller.saleStatus.value = 'completed',
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _buildSelectablePill(
                          context,
                          title: 'Pending / Quote',
                          icon: Icons.hourglass_top,
                          isSelected: controller.saleStatus.value == 'pending',
                          onTap: () => controller.saleStatus.value = 'pending',
                        ),
                      ),
                    ],
                  )),
              SizedBox(height: 18.h),

              // Payment Method
              _buildSectionLabel(context, 'PAYMENT METHOD'),
              SizedBox(height: 8.h),
              Obx(() => Row(
                    children: [
                      Expanded(
                        child: _buildSelectablePill(
                          context,
                          title: 'Cash',
                          icon: Icons.payments_outlined,
                          isSelected: controller.paymentMethod.value == 'cash',
                          onTap: () => controller.paymentMethod.value = 'cash',
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _buildSelectablePill(
                          context,
                          title: 'Card',
                          icon: Icons.credit_card_outlined,
                          isSelected: controller.paymentMethod.value == 'card',
                          onTap: () => controller.paymentMethod.value = 'card',
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // Sale Notes Card
        _buildCard(
          context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.note_alt_outlined,
                    size: 20.w,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Sale Notes (Optional)',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: controller.notesController,
                maxLines: 3,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText:
                      'Any special instructions, notes, or customer requests...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  contentPadding: EdgeInsets.all(12.w),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: child,
    );
  }

  Widget _buildSelectablePill(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.12)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : Theme.of(context).dividerColor.withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18.w,
              color: isSelected
                  ? primaryColor
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
            ),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? primaryColor
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Text(
      label,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
    );
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
