import 'package:pos/core/utils/app_data_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';


import 'package:pos/core/widgets/custome_app_bar.dart';
import 'package:pos/core/widgets/entity_qr_dialog.dart';
import 'package:pos/core/widgets/status_chip.dart';
import 'package:pos/features/manage_sales/presentation/controllers/sale_details_controller.dart';

class SaleDetailsView extends GetView<SaleDetailsController> {
  const SaleDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomeAppBar(
        showbackArrow: true,
        title: Obx(() {
          final sale = controller.sale.value;
          final titleText = sale != null ? 'Sale #${sale.id}' : 'Sale Details';
          return Text(titleText, style: Theme.of(context).textTheme.titleSmall);
        }),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: 'View Invoice',
            onPressed: () => controller.openSaleInvoice(context),
          ),
          Obx(() {
            final sale = controller.sale.value;
            final id = sale?.id ?? controller.saleId;
            if (id == null || id <= 0) return const SizedBox.shrink();
            return EntityQrActionButton(
              table: 'sales',
              id: id,
              title: 'Sale #$id QR',
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final sale = controller.sale.value;
        if (sale == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 64.w,
                  color: Colors.grey,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Sale Not Found',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 8.h),
                ElevatedButton(
                  onPressed: controller.loadSaleDetails,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final isPending = sale.saleStatus.toLowerCase() == 'pending';

        return SafeArea(
          top: false,
          child: RefreshIndicator(
            onRefresh: controller.loadSaleDetails,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                top: 16.h,
                bottom: 40.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Status Header Card
                  _buildHeaderCard(context, sale, isPending),
                  SizedBox(height: 16.h),

                  // Customer Information Card
                  _buildCustomerCard(context, sale),
                  SizedBox(height: 16.h),

                  // Items in Sale Card
                  _buildItemsCard(context, sale),
                  SizedBox(height: 16.h),

                  // Discounts & Applied Vouchers Card (Promo Code & Gift Voucher)
                  if ((sale.promoCode != null && sale.promoCode!.isNotEmpty) ||
                      sale.giftVoucher != null ||
                      sale.giftVoucherAmount > 0) ...[
                    _buildDiscountsAndVouchersCard(context, sale),
                    SizedBox(height: 16.h),
                  ],

                  // Financial Summary Card
                  _buildFinancialCard(context, sale),
                  SizedBox(height: 16.h),

                  // Notes Card (if present)
                  if (sale.notes != null && sale.notes!.trim().isNotEmpty) ...[
                    _buildNotesCard(context, sale.notes!),
                    SizedBox(height: 16.h),
                  ],

                  // Extra bottom spacing so content can be scrolled comfortably past the navigation bar
                  // SizedBox(height: 10.h),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER CARD
  // ---------------------------------------------------------------------------
  Widget _buildHeaderCard(BuildContext context, dynamic sale, bool isPending) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sale #${sale.id}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Sale Date: ${AppDataFormatter.formatDateTimeDisplay(sale.saleDate, pattern: 'yyyy-MM-dd', fallback: 'N/A')}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              StatusChip(status: sale.saleStatus),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.badge_outlined,
                    size: 16.w,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'Staff: ${sale.staff?.name ?? 'Admin'}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.payment,
                    size: 16.w,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'Payment: ${sale.paymentMethod.toString().toUpperCase()}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ],
          ),
          if (sale.paymentMethod.toString().toLowerCase() == 'card') ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.6),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.credit_card_rounded,
                    size: 16.w,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      sale.transactionId != null && sale.transactionId.toString().trim().isNotEmpty
                          ? 'Terminal Ref: ${sale.transactionId}'
                          : 'Terminal Ref: None',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }



  // ---------------------------------------------------------------------------
  // CUSTOMER CARD
  // ---------------------------------------------------------------------------
  Widget _buildCustomerCard(BuildContext context, dynamic sale) {
    final customer = sale.customer;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
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
          SizedBox(height: 12.h),
          if (customer == null)
            Text(
              'Walk-in Customer (No customer registered)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            )
          else ...[
            Text(
              customer.name,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (customer.phone != null && customer.phone!.isNotEmpty) ...[
              SizedBox(height: 4.h),
              Row(
                children: [
                  Icon(Icons.phone_outlined, size: 14.w, color: Colors.grey),
                  SizedBox(width: 6.w),
                  Text(customer.phone!,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
            if (customer.email != null && customer.email!.isNotEmpty) ...[
              SizedBox(height: 4.h),
              Row(
                children: [
                  Icon(Icons.email_outlined, size: 14.w, color: Colors.grey),
                  SizedBox(width: 6.w),
                  Text(customer.email!,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ITEMS IN SALE CARD
  // ---------------------------------------------------------------------------
  Widget _buildItemsCard(BuildContext context, dynamic sale) {
    final entries = sale.saleItemEntries;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: 20.w,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Items Purchased (${entries.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (entries.isEmpty)
            Container(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              alignment: Alignment.center,
              child: Text(
                'No items recorded in this sale.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                final itemName = entry.saleItem?.name.isNotEmpty == true
                    ? entry.saleItem!.name
                    : 'Product #${entry.saleItemId}';

                return Container(
                  margin: EdgeInsets.only(bottom: index == entries.length - 1 ? 0 : 12.h),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 32.w,
                        height: 32.w,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              itemName,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.sp,
                                  ),
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Text(
                                  '${entry.quantity}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                    fontSize: 13.sp,
                                  ),
                                ),
                                Text(
                                  ' x ${AppDataFormatter.formatCurrency(entry.pricePerUnit)}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            AppDataFormatter.formatCurrency(entry.lineTotal),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FINANCIAL SUMMARY CARD
  // ---------------------------------------------------------------------------
  Widget _buildFinancialCard(BuildContext context, dynamic sale) {
    // Calculate subtotal from line totals if available
    double subtotal = 0.0;
    for (final entry in sale.saleItemEntries) {
      subtotal += entry.lineTotal;
    }
    if (subtotal == 0.0) {
      subtotal = sale.totalAmount + sale.discountAmount;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 20.w,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(width: 8.w),
              Text(
                'Financial Summary',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildPriceRow(
            context,
            'Subtotal:',
            AppDataFormatter.formatCurrency(subtotal),
          ),
          if (sale.discountAmount > 0) ...[
            SizedBox(height: 8.h),
            _buildPriceRow(
              context,
              'Manual Discount:',
              '- ${AppDataFormatter.formatCurrency(sale.discountAmount)}',
              isDeduction: true,
            ),
          ],
          if (sale.promoCode != null && sale.promoCode!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            _buildPriceRow(
              context,
              'Promo Code (${sale.promoCode}):',
              sale.promoCodeDiscount > 0
                  ? '- ${AppDataFormatter.formatCurrency(sale.promoCodeDiscount)}'
                  : 'Applied',
              isDeduction: sale.promoCodeDiscount > 0,
            ),
          ],
          if (sale.giftVoucherAmount > 0 || sale.giftVoucher != null) ...[
            SizedBox(height: 8.h),
            _buildPriceRow(
              context,
              sale.giftVoucher?.code != null && sale.giftVoucher!.code.isNotEmpty
                  ? 'Gift Voucher (${sale.giftVoucher!.code}):'
                  : 'Gift Voucher:',
              '- ${AppDataFormatter.formatCurrency(sale.giftVoucherAmount)}',
              isDeduction: true,
            ),
          ],
          const Divider(height: 20),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
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
                  'TOTAL AMOUNT',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                ),
                Text(
                  AppDataFormatter.formatCurrency(sale.totalAmount),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
          ),
          if (sale.amountPaid != null && sale.amountPaid! > 0) ...[
            SizedBox(height: 12.h),
            _buildPriceRow(
              context,
              'Amount Paid:',
              AppDataFormatter.formatCurrency(sale.amountPaid!),
            ),
          ],
          if (sale.changeAmount != null &&
              (sale.changeAmount! > 0 ||
                  (sale.paymentMethod.toString().toLowerCase() == 'cash' &&
                      sale.amountPaid != null))) ...[
            SizedBox(height: 8.h),
            _buildPriceRow(
              context,
              'Change / Balance:',
              AppDataFormatter.formatCurrency(sale.changeAmount!),
            ),
          ],
          if (sale.paymentMethod.toString().toLowerCase() == 'card') ...[
            SizedBox(height: 8.h),
            _buildPriceRow(
              context,
              'Card Terminal Ref:',
              sale.transactionId != null &&
                      sale.transactionId.toString().trim().isNotEmpty
                  ? sale.transactionId.toString()
                  : 'Not Provided',
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // NOTES CARD
  // ---------------------------------------------------------------------------
  Widget _buildNotesCard(BuildContext context, String notes) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note_alt_outlined, size: 20.w, color: Colors.grey),
              SizedBox(width: 8.w),
              Text(
                'Notes',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(notes, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DISCOUNTS & VOUCHERS CARD
  // ---------------------------------------------------------------------------
  Widget _buildDiscountsAndVouchersCard(BuildContext context, dynamic sale) {
    final theme = Theme.of(context);
    final hasPromo = (sale.promoCode != null && sale.promoCode.toString().isNotEmpty) ||
        sale.promoCodeDiscount > 0 ||
        sale.promoCodeDetails != null;
    final hasVoucher = sale.giftVoucher != null || sale.giftVoucherAmount > 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.redeem_rounded,
                size: 20.w,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: 8.w),
              Text(
                'Discounts & Applied Vouchers',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (hasPromo) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.discount_outlined,
                              size: 16.w, color: Colors.blue.shade700),
                          SizedBox(width: 6.w),
                          Text(
                            'Promo Code: ${sale.promoCode ?? 'Applied'}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.sp,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ],
                      ),
                      if (sale.promoCodeDiscount > 0)
                        Text(
                          '- ${AppDataFormatter.formatCurrency(sale.promoCodeDiscount)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.sp,
                            color: Colors.blue.shade800,
                          ),
                        ),
                    ],
                  ),
                  if (sale.promoCodeDetails != null) ...[
                    SizedBox(height: 6.h),
                    if (sale.promoCodeDetails!.referral.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 2.h),
                        child: Text(
                          'Referral: ${sale.promoCodeDetails!.referral}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    if (sale.promoCodeDetails!.salesPercentage > 0)
                      Padding(
                        padding: EdgeInsets.only(top: 2.h),
                        child: Text(
                          'Discount: ${sale.promoCodeDetails!.salesPercentage.toStringAsFixed(0)}% Off',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
          if (hasVoucher) ...[
            SizedBox(height: hasPromo ? 10.h : 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: Colors.purple.withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.card_giftcard_rounded,
                              size: 16.w, color: Colors.purple.shade700),
                          SizedBox(width: 6.w),
                          Text(
                            'Gift Voucher: ${sale.giftVoucher?.code ?? 'Applied'}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.sp,
                              color: Colors.purple.shade800,
                            ),
                          ),
                        ],
                      ),
                      if (sale.giftVoucherAmount > 0)
                        Text(
                          '- ${AppDataFormatter.formatCurrency(sale.giftVoucherAmount)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.sp,
                            color: Colors.purple.shade800,
                          ),
                        ),
                    ],
                  ),
                  if (sale.giftVoucher != null) ...[
                    SizedBox(height: 6.h),
                    if (sale.giftVoucher!.owner.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 2.h),
                        child: Text(
                          'Owner: ${sale.giftVoucher!.owner}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: Text(
                        'Initial: ${sale.giftVoucher!.currency} ${sale.giftVoucher!.initialAmount.toStringAsFixed(2)} | Balance Left: ${sale.giftVoucher!.currency} ${sale.giftVoucher!.balance.toStringAsFixed(2)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
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
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
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
