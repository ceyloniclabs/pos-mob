import 'package:pos/core/utils/app_data_formatter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:pos/core/theme/app_semantic_colors.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/theme/custome_drop_down_decoration.dart';
import 'package:pos/core/utils/responsive.dart';
import 'package:pos/core/widgets/app_card.dart';
import 'package:pos/core/widgets/custom_button.dart';
import 'package:pos/core/widgets/custom_text_field.dart';
import 'package:pos/core/widgets/custome_app_bar.dart';
import 'package:pos/core/widgets/error_view.dart';
import 'package:pos/core/widgets/info_row.dart';
import 'package:pos/core/widgets/loading_indicator.dart';
import 'package:pos/features/payment_invoice/presentation/controllers/payment_invoice_controller.dart';

class PaymentInvoiceView extends GetView<PaymentInvoiceController> {
  const PaymentInvoiceView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final semantics = context.semanticColors;

    return Scaffold(
      appBar: const CustomeAppBar(
        title: 'Payment Invoice',
        centerTitle: true,
        showbackArrow: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const ResponsiveCenter(
            maxWidth: 720,
            child: PaymentInvoiceSkeleton(),
          );
        }

        if (controller.hasError.value || controller.summary == null) {
          return ErrorView(
            message: 'Failed to load invoice: ${controller.errorMessage}',
            onRetry: () => controller.fetchInvoice(),
          );
        }

        final summary = controller.summary!;

        return RefreshIndicator(
          onRefresh: () async => await controller.fetchInvoice(),
          child: ResponsiveCenter(
            maxWidth: 720,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rental #${controller.rental.id} • ${controller.rental.customer?.name ?? 'Customer'}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  AppSpacing.gapLg,
                  Text(
                    'Cost Breakdown',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  AppSpacing.gapSm,

                  // Items List
                  ...((controller.rental.rentalItemEntries as Iterable?)?.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    entry.item?.name ?? 'Rental Item',
                                    style: textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                AppSpacing.gapSm,
                                Text(
                                  AppDataFormatter.formatCurrency(entry.itemEntryTotalAmount),
                                  style: textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            AppSpacing.gapXxs,
                            Text(
                              'RATE ${AppDataFormatter.formatCurrency(entry.capturedRate ?? entry.itemEntryTotalAmount)} / ${(entry.capturedDurationType ?? "DAILY").toUpperCase()}',
                              style: textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                letterSpacing: 0.5,
                              ),
                            ),
                            if (entry.lateFee > 0) ...[
                              AppSpacing.gapXs,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'LATE FEE',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.error,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    '+ ${AppDataFormatter.formatCurrency(entry.lateFee)}',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.error,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (entry.damages != null && entry.damages!.isNotEmpty) ...[
                              Builder(
                                builder: (context) {
                                  final totalDamage = entry.damages!
                                      .fold(0.0, (sum, d) => sum + d.damageFee);
                                  if (totalDamage > 0) {
                                    return Column(
                                      children: [
                                        AppSpacing.gapXs,
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'DAMAGE FEE',
                                              style: textTheme.labelSmall?.copyWith(
                                                color: theme.colorScheme.error,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            Text(
                                              '+ ${AppDataFormatter.formatCurrency(totalDamage)}',
                                              style: textTheme.bodyMedium?.copyWith(
                                                color: theme.colorScheme.error,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }) ?? []),
                  AppSpacing.gapMd,

                  // Summary Totals Card
                  AppCard(
                    child: Column(
                      children: [
                        InfoRow(
                          label: 'Rental Subtotal',
                          value: AppDataFormatter.formatCurrency(summary.totalRental),
                        ),
                        if (summary.totalLateFee > 0) ...[
                          InfoRow(
                            label: 'Late Fee',
                            value: '+ ${AppDataFormatter.formatCurrency(summary.totalLateFee)}',
                            valueColor: theme.colorScheme.error,
                          ),
                        ],
                        if (summary.totalDamageFee > 0) ...[
                          InfoRow(
                            label: 'Damage Fee',
                            value: '+ ${AppDataFormatter.formatCurrency(summary.totalDamageFee)}',
                            valueColor: theme.colorScheme.error,
                          ),
                        ],
                        InfoRow(
                          label: 'Total Charged',
                          value: AppDataFormatter.formatCurrency(summary.totalCharged),
                          isBold: true,
                        ),
                        if (summary.totalAdvance > 0) ...[
                          InfoRow(
                            label: 'Advance Payment',
                            value: '- ${AppDataFormatter.formatCurrency(summary.totalAdvance)}',
                            valueColor: semantics.success,
                          ),
                        ],
                        if (summary.totalPaid > 0) ...[
                          InfoRow(
                            label: 'Payments Received',
                            value: '- ${AppDataFormatter.formatCurrency(summary.totalPaid)}',
                            valueColor: semantics.success,
                          ),
                        ],
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                          child: Divider(color: theme.colorScheme.outlineVariant),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'BALANCE DUE',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  AppSpacing.vGapXxs,
                                  Text(
                                    AppDataFormatter.formatCurrency(summary.balanceDue),
                                    style: textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AppSpacing.gapSm,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'SECURITY DEPOSIT',
                                    textAlign: TextAlign.right,
                                    style: textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  AppSpacing.vGapXxs,
                                  Text(
                                    AppDataFormatter.formatCurrency(summary.totalDeposit),
                                    textAlign: TextAlign.right,
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.gapLg,

                  // Settle Balance Section
                  if (controller.rental.rentalStatus?.toString().toLowerCase() != 'completed')
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Settle Balance',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          AppSpacing.gapMd,
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const FieldLabel('Amount'),
                                    AppSpacing.gapXs,
                                    Obx(
                                      () => TextField(
                                        controller: controller.paymentAmountController,
                                        keyboardType: const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                        enabled: controller.paymentMethod.value == 'Cash',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              AppSpacing.gapMd,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const FieldLabel('Method'),
                                    AppSpacing.gapXs,
                                    Obx(
                                      () => CustomDropdown<String>(
                                        initialItem: controller.paymentMethod.value,
                                        items: const ['Cash', 'Card'],
                                        onChanged: (val) {
                                          if (val != null) {
                                            controller.paymentMethod.value = val;
                                            if (val == 'Card' && controller.summary != null) {
                                              controller.paymentAmountController.text =
                                                  controller.summary!.balanceDue.toStringAsFixed(2);
                                            }
                                          }
                                        },
                                        decoration: buildCustomDropdownDecoration(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  AppSpacing.gapXxl,
                ],
              ),
            ),
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        if (controller.isLoading.value ||
            controller.hasError.value ||
            controller.summary == null) {
          return const SizedBox.shrink();
        }

        final isCompleted =
            controller.rental.rentalStatus?.toString().toLowerCase() == 'completed';

        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
            ),
            child: AppButton(
              label: isCompleted ? 'Download Detailed Bill' : 'Record Payment',
              icon: isCompleted ? Icons.download_rounded : Icons.check_circle_outline_rounded,
              onPressed: isCompleted ? controller.downloadDetailedBill : controller.recordPayment,
              type: AppButtonType.primary,
              expand: true,
            ),
          ),
        );
      }),
    );
  }
}

/// Exact skeleton component matching PaymentInvoiceView layout during loading state.
class PaymentInvoiceSkeleton extends StatelessWidget {
  const PaymentInvoiceSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: Rental ID & Customer Name ────────────────────────────
          const SkeletonLoader(width: 180, height: 16),
          AppSpacing.gapLg,

          // ── Section Title: Cost Breakdown ────────────────────────────────
          const SkeletonLoader(width: 130, height: 20),
          AppSpacing.gapSm,

          // ── Item Entry Cards (2 dummy items) ─────────────────────────────
          for (int i = 0; i < 2; i++) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        SkeletonLoader(width: 150, height: 16),
                        SkeletonLoader(width: 80, height: 16),
                      ],
                    ),
                    AppSpacing.gapXxs,
                    const SkeletonLoader(width: 120, height: 12),
                  ],
                ),
              ),
            ),
          ],
          AppSpacing.gapMd,

          // ── Summary Totals Card ──────────────────────────────────────────
          AppCard(
            child: Column(
              children: [
                _buildSkeletonInfoRow(),
                AppSpacing.gapXs,
                _buildSkeletonInfoRow(),
                AppSpacing.gapXs,
                _buildSkeletonInfoRow(),
                AppSpacing.gapXs,
                _buildSkeletonInfoRow(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Divider(color: theme.colorScheme.outlineVariant),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          SkeletonLoader(width: 80, height: 12),
                          SizedBox(height: 6),
                          SkeletonLoader(width: 110, height: 22),
                        ],
                      ),
                    ),
                    AppSpacing.gapSm,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          SkeletonLoader(width: 90, height: 12),
                          SizedBox(height: 6),
                          SkeletonLoader(width: 80, height: 18),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.gapLg,

          // ── Settle Balance Card ──────────────────────────────────────────
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLoader(width: 110, height: 18),
                AppSpacing.gapMd,
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          SkeletonLoader(width: 50, height: 12),
                          SizedBox(height: 6),
                          SkeletonLoader(
                            width: double.infinity,
                            height: 48,
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.gapMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          SkeletonLoader(width: 50, height: 12),
                          SizedBox(height: 6),
                          SkeletonLoader(
                            width: double.infinity,
                            height: 48,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.gapXxl,
        ],
      ),
    );
  }

  static Widget _buildSkeletonInfoRow() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SkeletonLoader(width: 100, height: 14),
          SkeletonLoader(width: 70, height: 14),
        ],
      ),
    );
  }
}

