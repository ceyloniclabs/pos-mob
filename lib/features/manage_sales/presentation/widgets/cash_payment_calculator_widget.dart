import 'package:pos/core/utils/app_data_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/widgets/app_card.dart';
import 'package:pos/features/manage_sales/presentation/controllers/sale_create_controller.dart';

class CashPaymentCalculatorWidget extends GetView<SaleCreateController> {
  const CashPaymentCalculatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            children: [
              Icon(
                Icons.payments_outlined,
                size: 20.w,
                color: theme.colorScheme.primary,
              ),
              AppSpacing.gapSm,
              Expanded(
                child: Text(
                  'CASH PAYMENT CALCULATOR',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.gapMd,

          // Two-column layout for Amount Received & Return Change
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column 1: Amount Received
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AMOUNT RECEIVED (${controller.shopCurrency}) *',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    AppSpacing.vGapXxs,
                    TextField(
                      controller: controller.amountReceivedController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (value) =>
                          controller.updateAmountReceived(value),
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.smAll,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.gapMd,

              // Column 2: Return Change Display Box
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RETURN CHANGE (${controller.shopCurrency})',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    AppSpacing.vGapXxs,
                    Obx(
                      () => Container(
                        width: double.infinity,
                        height: 48,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer
                              .withValues(alpha: 0.35),
                          borderRadius: AppRadius.smAll,
                          border: Border.all(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          AppDataFormatter.formatCurrency(controller.returnChange),
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
