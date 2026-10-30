import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/utils/responsive.dart';
import 'package:pos/core/widgets/app_bottom_action_bar.dart';
import 'package:pos/core/widgets/custome_app_bar.dart';
import '../../domain/validators/promo_code_validator.dart';
import '../controllers/promo_code_controller.dart';

class PromoCodeAddView extends GetView<PromoCodeController> {
  const PromoCodeAddView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomeAppBar(
        title: 'Create Promo Code',
        centerTitle: true,
        showbackArrow: true,
      ),
      bottomNavigationBar: Obx(
        () => AppBottomActionBar.primaryAction(
          label: 'Save Promo Code',
          icon: Icons.check_circle_outline_rounded,
          isLoading: controller.isSaving.value,
          onPressed: controller.isSaving.value
              ? null
              : () async {
                  final success = await controller.createPromoCode();
                  if (success) {
                    Get.back();
                  }
                },
        ),
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 680,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel(context, 'Promo Code', isRequired: true),
                  AppSpacing.vGapXxs,
                  TextFormField(
                    controller: controller.codeController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      hintText: 'e.g. SUMMER50',
                      prefixIcon: Icon(Iconsax.ticket_discount, size: 20),
                    ),
                    validator: PromoCodeValidator.validateCode,
                  ),
                  AppSpacing.gapMd,
                  _buildFieldLabel(context, 'Referral / Partner Name', isRequired: true),
                  AppSpacing.vGapXxs,
                  TextFormField(
                    controller: controller.referralController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Hotel Partner / John Doe',
                      prefixIcon: Icon(Iconsax.user, size: 20),
                    ),
                    validator: PromoCodeValidator.validateReferral,
                  ),
                  AppSpacing.gapMd,
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel(context, 'Sales Discount (%)'),
                            AppSpacing.vGapXxs,
                            TextFormField(
                              controller: controller.salesPercentageController,
                              keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true),
                              decoration: const InputDecoration(
                                hintText: '0.00',
                                prefixIcon: Icon(Iconsax.percentage_square, size: 20),
                              ),
                              validator: (val) => PromoCodeValidator.validatePercentage(
                                val,
                                fieldName: 'Sales discount',
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
                            _buildFieldLabel(context, 'Rental Discount (%)'),
                            AppSpacing.vGapXxs,
                            TextFormField(
                              controller: controller.rentalPercentageController,
                              keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true),
                              decoration: const InputDecoration(
                                hintText: '0.00',
                                prefixIcon: Icon(Iconsax.percentage_square, size: 20),
                              ),
                              validator: (val) => PromoCodeValidator.validatePercentage(
                                val,
                                fieldName: 'Rental discount',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.gapMd,
                  _buildFieldLabel(context, 'Expire Date', isRequired: true),
                  AppSpacing.vGapXxs,
                  InkWell(
                    onTap: () => _pickExpireDate(context),
                    borderRadius: AppRadius.mdAll,
                    child: IgnorePointer(
                      child: Obx(
                        () => TextFormField(
                          controller: controller.expireDateController,
                          decoration: InputDecoration(
                            hintText: 'yyyy-MM-dd',
                            suffixIcon: const Icon(Iconsax.calendar_1, size: 20),
                            errorText: controller.selectedExpireDate.value == null &&
                                    controller.isSaving.value
                                ? 'Required'
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.gapMd,
                  _buildFieldLabel(context, 'Description'),
                  AppSpacing.vGapXxs,
                  TextFormField(
                    controller: controller.descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Optional promotional campaign notes...',
                      alignLabelWithHint: true,
                    ),
                  ),
                  AppSpacing.gapSm,
                  Obx(
                    () => InkWell(
                      onTap: () => controller.isActiveForm.toggle(),
                      borderRadius: AppRadius.smAll,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: controller.isActiveForm.value,
                              onChanged: (val) {
                                if (val != null) {
                                  controller.isActiveForm.value = val;
                                }
                              },
                            ),
                            Text(
                              'Active Status',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.gapXxl,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickExpireDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedExpireDate.value ??
          DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null) {
      controller.selectedExpireDate.value = picked;
      controller.expireDateController.text =
          DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Widget _buildFieldLabel(
    BuildContext context,
    String label, {
    bool isRequired = false,
  }) {
    return RichText(
      text: TextSpan(
        text: label,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(fontWeight: FontWeight.bold),
        children: isRequired
            ? const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ]
            : null,
      ),
    );
  }
}
