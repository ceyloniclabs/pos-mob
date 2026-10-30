import 'package:pos/core/utils/app_data_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pos/features/manage_sales/presentation/controllers/sale_create_controller.dart';
import 'package:pos/features/manage_sales/presentation/widgets/cash_payment_calculator_widget.dart';
import 'package:pos/features/manage_sales/presentation/widgets/external_card_terminal_widget.dart';

class SaleStepCheckout extends GetView<SaleCreateController> {
  const SaleStepCheckout({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Order Summary Overview Card
        _buildCard(
          context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.receipt_outlined,
                        size: 20.w,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Order Overview',
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () => controller.goToStep(1),
                    icon: Icon(Icons.edit, size: 14.w),
                    label: const Text('Edit Cart'),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Obx(() => _buildOverviewRow(
                    context,
                    'Customer:',
                    controller.selectedCustomer.value?.name ??
                        'Walk-in Customer',
                  )),
              Obx(() => Padding(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Status:',
                            style: Theme.of(context).textTheme.bodyMedium),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: controller.saleStatus.value,
                            isDense: true,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            items: const [
                              DropdownMenuItem(
                                value: 'completed',
                                child: Text('Completed'),
                              ),
                              DropdownMenuItem(
                                value: 'pending',
                                child: Text('Pending / Quote'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                controller.saleStatus.value = val;
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  )),
              Obx(() => Padding(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Payment Method:',
                            style: Theme.of(context).textTheme.bodyMedium),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: controller.paymentMethod.value,
                            isDense: true,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            items: const [
                              DropdownMenuItem(
                                value: 'cash',
                                child: Text('Cash'),
                              ),
                              DropdownMenuItem(
                                value: 'card',
                                child: Text('Card'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                controller.paymentMethod.value = val;
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  )),
              Obx(() => _buildOverviewRow(
                    context,
                    'Total Items:',
                    '${controller.addedItems.length} product(s) in cart',
                  )),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // Discounts, Promo, Voucher Card
        _buildCard(
          context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Manual Discount
              _buildSectionLabel(context, 'MANUAL DISCOUNT'),
              SizedBox(height: 6.h),
              Row(
                children: [
                  Obx(() => ChoiceChip(
                        label: Text('${controller.shopCurrency} (Fixed)'),
                        selected: controller.discountType.value == 'fixed',
                        onSelected: (selected) {
                          if (selected) controller.setDiscountType('fixed');
                        },
                      )),
                  SizedBox(width: 4.w),
                  Obx(() => ChoiceChip(
                        label: const Text('% (Percent)'),
                        selected: controller.discountType.value == 'percent',
                        onSelected: (selected) {
                          if (selected) controller.setDiscountType('percent');
                        },
                      )),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Obx(() => TextField(
                      controller: controller.discountAmountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: controller.discountType.value == 'percent'
                            ? '10 (%)'
                            : '0.00',
                        suffixText: controller.discountType.value == 'percent'
                            ? '%'
                            : null,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 8.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                      ),
                      onChanged: (_) => controller.addedItems.refresh(),
                    )),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Promo Code
              _buildSectionLabel(
                  context, 'Promo Code (Percentage Discount)'),
              SizedBox(height: 6.h),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.promoCodeController,
                      decoration: InputDecoration(
                        hintText: 'E.G. SUMMER50',
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 10.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  ElevatedButton(
                    onPressed: controller.applyPromo,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: const Text('Apply Promo'),
                  ),
                ],
              ),
              Obx(() {
                if (controller.appliedPromoPercent.value <= 0) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: EdgeInsets.only(top: 6.h),
                  child: Text(
                    '${controller.appliedPromoPercent.value.toStringAsFixed(0)}% promo discount applied',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
              SizedBox(height: 16.h),

              // Gift Voucher
              _buildSectionLabel(
                  context, 'Gift Voucher (Fixed Balance Deduction)'),
              SizedBox(height: 6.h),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.voucherCodeController,
                      decoration: InputDecoration(
                        hintText: 'E.G. GIFT100',
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 10.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  ElevatedButton(
                    onPressed: controller.applyVoucher,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: const Text('Apply Voucher'),
                  ),
                ],
              ),
              Obx(() {
                if (controller.appliedVoucherDeduction.value <= 0) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: EdgeInsets.only(top: 6.h),
                  child: Text(
                    '${AppDataFormatter.formatCurrency(controller.appliedVoucherDeduction.value)} voucher deducted',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // Financial Breakdown Card
        _buildCard(
          context,
          child: Obx(() => Column(
                children: [
                  _buildPriceRow(
                    context,
                    'Subtotal:',
                    AppDataFormatter.formatCurrency(controller.subtotal),
                  ),
                  if (controller.discountDeduction > 0) ...[
                    SizedBox(height: 8.h),
                    _buildPriceRow(
                      context,
                      'Manual Discount:',
                      '- ${AppDataFormatter.formatCurrency(controller.discountDeduction)}',
                      isDeduction: true,
                    ),
                  ],
                  if (controller.promoDeduction > 0) ...[
                    SizedBox(height: 8.h),
                    _buildPriceRow(
                      context,
                      'Promo Deduction:',
                      '- ${AppDataFormatter.formatCurrency(controller.promoDeduction)}',
                      isDeduction: true,
                    ),
                  ],
                  if (controller.effectiveVoucherDeduction > 0) ...[
                    SizedBox(height: 8.h),
                    _buildPriceRow(
                      context,
                      controller.appliedVoucherCode.value.isNotEmpty
                          ? 'Gift Voucher (${controller.appliedVoucherCode.value}):'
                          : 'Gift Voucher:',
                      '- ${AppDataFormatter.formatCurrency(controller.effectiveVoucherDeduction)}',
                      isDeduction: true,
                    ),
                  ],
                  const Divider(height: 24),

                  // GRAND TOTAL Container
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 14.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'GRAND TOTAL',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                        ),
                        Text(
                          AppDataFormatter.formatCurrency(controller.grandTotal),
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
        ),

        // Dynamic Payment Component (Cash Calculator or Card Terminal)
        Obx(() {
          final status = controller.saleStatus.value.toLowerCase();
          final method = controller.paymentMethod.value.toLowerCase();

          if (status == 'completed' && method == 'cash') {
            return Column(
              children: [
                SizedBox(height: 16.h),
                const CashPaymentCalculatorWidget(),
              ],
            );
          } else if (status == 'completed' && method == 'card') {
            return Column(
              children: [
                SizedBox(height: 16.h),
                const ExternalCardTerminalWidget(),
              ],
            );
          }
          return const SizedBox.shrink();
        }),
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

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Text(
      label,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
    );
  }

  Widget _buildOverviewRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    BuildContext context,
    String label,
    String value, {
    bool isDeduction = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDeduction ? Colors.green : null,
              ),
        ),
      ],
    );
  }
}
