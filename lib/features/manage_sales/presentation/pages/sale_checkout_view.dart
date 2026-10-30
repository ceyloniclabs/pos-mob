import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/utils/responsive.dart';
import 'package:pos/core/widgets/app_card.dart';
import 'package:pos/core/widgets/custome_app_bar.dart';
import 'package:pos/core/widgets/status_badge.dart';
import 'package:pos/core/utils/app_data_formatter.dart';
import 'package:pos/features/manage_sales/presentation/controllers/sale_create_controller.dart';
import 'package:pos/features/manage_sales/presentation/widgets/cash_payment_calculator_widget.dart';
import 'package:pos/features/manage_sales/presentation/widgets/external_card_terminal_widget.dart';

class SaleCheckoutView extends GetView<SaleCreateController> {
  const SaleCheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: const CustomeAppBar(
        title: 'Checkout & Payment',
        centerTitle: true,
        showbackArrow: true,
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 720,
          child: Column(
            children: [
              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Customer Info Card
                      _buildCustomerInfoCard(context, theme, textTheme),
                      AppSpacing.gapSm,

                      // 2. Total to Pay Banner
                      _buildTotalBanner(context, theme, textTheme),
                      AppSpacing.gapMd,

                      // 3. Discounts & Notes (Moved ABOVE Payment Method)
                      _buildDiscountsAndNotesCard(context, theme, textTheme),
                      AppSpacing.gapMd,

                      // 4. Payment Method Selector (Placed AFTER Discounts & Notes)
                      _buildPaymentMethodSection(context, theme, textTheme),
                      AppSpacing.gapSm,

                      // 5. Method Details (Cash calculator or Card terminal)
                      Obx(() {
                        final method = controller.paymentMethod.value;
                        if (method == 'cash') {
                          return const CashPaymentCalculatorWidget();
                        } else if (method == 'card') {
                          return const ExternalCardTerminalWidget();
                        }
                        return const SizedBox.shrink();
                      }),
                      AppSpacing.gapMd,
                    ],
                  ),
                ),
              ),

              // Bottom CTA Bar
              _buildBottomActionBar(context, theme, textTheme),
            ],
          ),
        ),
      ),
    );
  }

  // ── 1. Customer Info Card ──────────────────────────────────────────────
  Widget _buildCustomerInfoCard(
    BuildContext context,
    ThemeData theme,
    TextTheme textTheme,
  ) {
    return Obx(() {
      final customer = controller.selectedCustomer.value;
      final isWalkIn = customer == null;

      final initial = !isWalkIn && customer.name.isNotEmpty
          ? customer.name[0].toUpperCase()
          : null;

      return AppCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: theme.colorScheme.primary.withValues(
                alpha: 0.12,
              ),
              child: isWalkIn
                  ? Icon(
                      Iconsax.user,
                      size: 20,
                      color: theme.colorScheme.primary,
                    )
                  : Text(
                      initial ?? 'C',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
            ),
            AppSpacing.gapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isWalkIn ? 'Walk-in Customer' : customer.name,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.vGapXxs,
                  Text(
                    isWalkIn
                        ? 'Anonymous counter sale'
                        : '${customer.phone} • ${customer.membershipLevel.capitalizeFirst ?? customer.membershipLevel}',
                    style: textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (!isWalkIn)
              StatusBadge(
                label: customer.membershipLevel.capitalizeFirst ??
                    customer.membershipLevel,
                type: _getMembershipType(customer.membershipLevel),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: AppRadius.smAll,
                ),
                child: Text(
                  'Counter',
                  style: textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  // ── 2. Total to Pay Banner ─────────────────────────────────────────────
  Widget _buildTotalBanner(
    BuildContext context,
    ThemeData theme,
    TextTheme textTheme,
  ) {
    return Obx(() {
      final subtotal = controller.subtotal;
      final discountDeduction = controller.discountDeduction;
      final promoDeduction = controller.promoDeduction;
      final voucherDeduction = controller.effectiveVoucherDeduction;
      final grandTotal = controller.grandTotal;

      final hasManualDiscount = discountDeduction > 0;
      final hasPromo = promoDeduction > 0;
      final hasVoucher = voucherDeduction > 0;
      final hasAnyDeduction = hasManualDiscount || hasPromo || hasVoucher;

      return AppCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        backgroundColor: theme.colorScheme.primaryContainer.withValues(
          alpha: 0.25,
        ),
        child: Column(
          children: [
            // Subtotal Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Iconsax.receipt_2,
                      size: 15,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    AppSpacing.gapXxs,
                    Text(
                      'Subtotal',
                      style: textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Text(
                  AppDataFormatter.formatCurrency(subtotal),
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),

            // Manual Discount Row
            if (hasManualDiscount) ...[
              AppSpacing.vGapXs,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Iconsax.percentage_circle,
                        size: 14,
                        color: Colors.green.shade700,
                      ),
                      AppSpacing.gapXxs,
                      Text(
                        controller.discountType.value == 'percent'
                            ? 'Manual Discount (${controller.manualDiscountValue.toStringAsFixed(0)}%)'
                            : 'Manual Discount',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '- ${AppDataFormatter.formatCurrency(discountDeduction)}',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],

            // Promo Code Row
            if (hasPromo) ...[
              AppSpacing.vGapXs,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Iconsax.tag,
                        size: 14,
                        color: Colors.blue.shade700,
                      ),
                      AppSpacing.gapXxs,
                      Text(
                        controller.appliedPromoCode.value.isNotEmpty
                            ? 'Promo Code (${controller.appliedPromoCode.value} - ${controller.appliedPromoPercent.value.toStringAsFixed(0)}%)'
                            : 'Promo Code (${controller.appliedPromoPercent.value.toStringAsFixed(0)}%)',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '- ${AppDataFormatter.formatCurrency(promoDeduction)}',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],

            // Gift Voucher Row
            if (hasVoucher) ...[
              AppSpacing.vGapXs,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.card_giftcard_rounded,
                        size: 14,
                        color: Colors.purple.shade700,
                      ),
                      AppSpacing.gapXxs,
                      Text(
                        controller.appliedVoucherCode.value.isNotEmpty
                            ? 'Gift Voucher (${controller.appliedVoucherCode.value})'
                            : 'Gift Voucher',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.purple.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '- ${AppDataFormatter.formatCurrency(voucherDeduction)}',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.purple.shade700,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],

            AppSpacing.vGapSm,
            Divider(
              height: 1,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
            AppSpacing.vGapSm,

            // Total to Pay Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL TO PAY',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    if (hasAnyDeduction)
                      Text(
                        'Remaining balance',
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
                Text(
                  AppDataFormatter.formatCurrency(grandTotal),
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  // ── 3. Discounts & Notes Card (Moved Above Payment Method) ─────────────
  Widget _buildDiscountsAndNotesCard(
    BuildContext context,
    ThemeData theme,
    TextTheme textTheme,
  ) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        initiallyExpanded: false,
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        collapsedShape:
            const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        tilePadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.xxs),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: AppRadius.smAll,
          ),
          child: Icon(
            Iconsax.ticket_discount,
            size: 20,
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(
          'Discounts & Notes',
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Obx(() {
          final parts = <String>[];
          if (controller.discountDeduction > 0) {
            parts.add(
                'Discount: -${AppDataFormatter.formatCurrency(controller.discountDeduction)}');
          }
          if (controller.appliedPromoPercent.value > 0) {
            parts.add(
                'Promo: ${controller.appliedPromoPercent.value.toStringAsFixed(0)}%');
          }
          if (controller.appliedVoucherCode.value.isNotEmpty) {
            parts.add('Voucher: ${controller.appliedVoucherCode.value}');
          }
          if (parts.isNotEmpty) {
            return Text(
              parts.join(' • '),
              style: textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            );
          }
          return Text(
            'Manual discount, promo codes, vouchers & notes',
            style: textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          );
        }),
        childrenPadding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        children: [
          
          Divider(
            height: 1,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
          AppSpacing.gapMd,

          // Manual Discount Field & Fixed/Percent Toggle
          Text(
            'MANUAL DISCOUNT',
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          AppSpacing.vGapXxs,
          Row(
            children: [
              Expanded(
                child: Obx(() => TextField(
                  controller: controller.discountAmountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) => controller.addedItems.refresh(),
                  decoration: InputDecoration(
                    hintText: controller.discountType.value == 'percent'
                        ? 'e.g. 10 (%)'
                        : 'e.g. 500 (${controller.shopCurrency})',
                    suffixText: controller.discountType.value == 'percent'
                        ? '%'
                        : controller.shopCurrency,
                    suffixStyle: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.smAll,
                    ),
                  ),
                )),
              ),
              AppSpacing.gapSm,
              Obx(() {
                return SegmentedButton<String>(
                  segments: [
                    ButtonSegment(value: 'fixed', label: Text(controller.shopCurrency)),
                    const ButtonSegment(value: 'percent', label: Text('%')),
                  ],
                  selected: {controller.discountType.value},
                  onSelectionChanged: (Set<String> newSelection) {
                    controller.setDiscountType(newSelection.first);
                  },
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(borderRadius: AppRadius.smAll),
                    ),
                  ),
                );
              }),
            ],
          ),
          AppSpacing.gapMd,

          // Promo Code Section
          Text(
            'PROMO CODE (PERCENTAGE DISCOUNT)',
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          AppSpacing.vGapXxs,
          Obx(() {
            if (controller.appliedPromoCode.value.isNotEmpty) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller.promoCodeController,
                          readOnly: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.5),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.smAll,
                            ),
                          ),
                        ),
                      ),
                      AppSpacing.gapSm,
                      OutlinedButton.icon(
                        onPressed: controller.removePromo,
                        icon: const Icon(Icons.close_rounded, size: 16),
                        label: const Text('Remove'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                          side: BorderSide(color: theme.colorScheme.error),
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppRadius.smAll,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.vGapXs,
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer
                          .withValues(alpha: 0.4),
                      borderRadius: AppRadius.smAll,
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Promo Applied (${controller.appliedPromoCode.value} • ${controller.appliedPromoPercent.value.toStringAsFixed(0)}% off)',
                          style: textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Text(
                          '- ${AppDataFormatter.formatCurrency(controller.promoDeduction)}',
                          style: textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.promoCodeController,
                    decoration: InputDecoration(
                      hintText: 'e.g. SUMMER50',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.smAll,
                      ),
                    ),
                  ),
                ),
                AppSpacing.gapSm,
                FilledButton.tonal(
                  onPressed: controller.isApplyingPromo.value
                      ? null
                      : controller.applyPromo,
                  style: FilledButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.smAll,
                    ),
                  ),
                  child: controller.isApplyingPromo.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator.adaptive(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Apply'),
                ),
              ],
            );
          }),
          AppSpacing.gapMd,

          // Gift Voucher Section
          Text(
            'GIFT VOUCHER (FIXED BALANCE DEDUCTION)',
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          AppSpacing.vGapXxs,
          Obx(() {
            if (controller.appliedVoucherCode.value.isNotEmpty) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller.voucherCodeController,
                          readOnly: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.5),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.smAll,
                            ),
                          ),
                        ),
                      ),
                      AppSpacing.gapSm,
                      OutlinedButton.icon(
                        onPressed: controller.removeVoucher,
                        icon: const Icon(Icons.close_rounded, size: 16),
                        label: const Text('Remove'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                          side: BorderSide(color: theme.colorScheme.error),
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppRadius.smAll,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.vGapXs,
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.12),
                      borderRadius: AppRadius.smAll,
                      border: Border.all(
                        color: Colors.purple.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Voucher Applied (${controller.appliedVoucherCode.value})',
                          style: textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.purple.shade700,
                          ),
                        ),
                        Text(
                          '- ${AppDataFormatter.formatCurrency(controller.appliedVoucherDeduction.value)}',
                          style: textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.purple.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.voucherCodeController,
                    decoration: InputDecoration(
                      hintText: 'e.g. GIFT100',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.smAll,
                      ),
                    ),
                  ),
                ),
                AppSpacing.gapSm,
                FilledButton.tonal(
                  onPressed: controller.isApplyingVoucher.value
                      ? null
                      : controller.applyVoucher,
                  style: FilledButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.smAll,
                    ),
                  ),
                  child: controller.isApplyingVoucher.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator.adaptive(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Apply'),
                ),
              ],
            );
          }),
          AppSpacing.gapMd,

          // Sale Notes
          Text(
            'SALE NOTES',
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          AppSpacing.vGapXxs,
          TextField(
            controller: controller.notesController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Optional instructions or customer notes...',
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
    );
  }

  // ── 4. Payment Method Selector ─────────────────────────────────────────
  Widget _buildPaymentMethodSection(
    BuildContext context,
    ThemeData theme,
    TextTheme textTheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PAYMENT METHOD',
          style: textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        AppSpacing.gapSm,
        Obx(() {
          final currentMethod = controller.paymentMethod.value;
          return Row(
            children: [
              _buildPaymentPill(
                context: context,
                theme: theme,
                textTheme: textTheme,
                title: 'Cash',
                icon: Icons.payments_outlined,
                isSelected: currentMethod == 'cash',
                onTap: () => controller.paymentMethod.value = 'cash',
              ),
              AppSpacing.gapSm,
              _buildPaymentPill(
                context: context,
                theme: theme,
                textTheme: textTheme,
                title: 'Card',
                icon: Iconsax.card,
                isSelected: currentMethod == 'card',
                onTap: () => controller.paymentMethod.value = 'card',
              ),
              AppSpacing.gapSm,
              _buildPaymentPill(
                context: context,
                theme: theme,
                textTheme: textTheme,
                title: 'Transfer',
                icon: Iconsax.bank,
                isSelected: currentMethod == 'bank_transfer',
                onTap: () => controller.paymentMethod.value = 'bank_transfer',
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildPaymentPill({
    required BuildContext context,
    required ThemeData theme,
    required TextTheme textTheme,
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final backgroundColor = isSelected
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surfaceContainerLow;

    final borderColor = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.outlineVariant;

    final contentColor = isSelected
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurface;

    return Expanded(
      child: Material(
        color: backgroundColor,
        borderRadius: AppRadius.smAll,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.smAll,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: AppRadius.smAll,
              border: Border.all(
                color: borderColor,
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected ? theme.colorScheme.primary : contentColor,
                ),
                AppSpacing.vGapXxs,
                Text(
                  title,
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: contentColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Bottom Action Bar ──────────────────────────────────────────────────
  Widget _buildBottomActionBar(
    BuildContext context,
    ThemeData theme,
    TextTheme textTheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Obx(() {
          final isSubmitting = controller.isSubmitting.value;
          final isDraftLoading = controller.isSubmittingDraft.value;
          final isCompleteLoading = controller.isSubmittingComplete.value;

          return Row(
            children: [
              // Save Draft Button
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: isSubmitting
                        ? null
                        : () {
                            controller.saleStatus.value = 'pending';
                            controller.submitSale(isDraft: true);
                          },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.smAll,
                      ),
                    ),
                    child: isDraftLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator.adaptive(
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Iconsax.save_2, size: 16),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Save Draft',
                                  style: textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              AppSpacing.gapSm,

              // Complete Sale / Update Sale Button
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: isSubmitting
                        ? null
                        : () {
                            controller.saleStatus.value = 'completed';
                            controller.submitSale(isDraft: false);
                          },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.smAll,
                      ),
                    ),
                    child: isCompleteLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator.adaptive(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Complete Sale',
                                style: textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onPrimary,
                                  height: 1.1,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                AppDataFormatter.formatCurrency(controller.grandTotal),
                                style: textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onPrimary
                                      .withValues(alpha: 0.9),
                                  height: 1.1,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  StatusType _getMembershipType(String level) {
    switch (level.toLowerCase()) {
      case 'platinum':
      case 'gold':
        return StatusType.warning;
      case 'silver':
        return StatusType.info;
      case 'bronze':
      default:
        return StatusType.neutral;
    }
  }
}
