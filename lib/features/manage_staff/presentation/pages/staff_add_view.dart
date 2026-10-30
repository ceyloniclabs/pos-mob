import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/utils/responsive.dart';
import 'package:pos/core/widgets/app_bottom_action_bar.dart';
import 'package:pos/core/widgets/app_form_elements.dart';
import 'package:pos/core/widgets/custome_app_bar.dart';

import '../../domain/validators/staff_validator.dart';
import '../controllers/staff_controller.dart';

/// Redesigned Staff Add Screen conforming to Material 3 guidelines and project UI/UX standards.
/// - Flat surface layout without unnecessary container cards
/// - CustomerAddView icon-badged section headers (_buildSectionHeader)
/// - Domain StaffValidator integration
/// - Thumb-accessible sticky bottom action bar
/// - Tablet/Desktop responsive layout
class StaffAddView extends GetView<StaffController> {
  const StaffAddView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CustomeAppBar(
        title: 'Add Staff Member',
        centerTitle: true,
        showbackArrow: true,
      ),
      bottomNavigationBar: Obx(
        () => AppBottomActionBar.primaryAction(
          label: 'Save Staff Member',
          icon: Iconsax.tick_circle,
          isLoading: controller.isSaving.value,
          onPressed: () async {
            if (controller.staffFormKey.currentState?.validate() ?? false) {
              final success = await controller.addStaff(
                controller.nameController.text.trim(),
                controller.emailController.text.trim(),
                controller.passwordController.text.trim(),
                phoneNumber: controller.phoneNumberController.text.trim(),
                joinDate: controller.joinDateController.text.trim(),
              );
              if (success) {
                Get.back();
              }
            }
          },
        ),
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 680,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Form(
              key: controller.staffFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Explanatory Banner
                  _buildHeaderBanner(context),
                  AppSpacing.gapLg,

                  // ── Section 1: Personal & Contact Information ─────────────
                  // NOTE: If card container wrapping is preferred later, see commented snippet below.
                  /*
                  AppCard(
                    child: Column(
                      children: [
                        buildTextField(...),
                        AppSpacing.gapMd,
                        buildTextField(...),
                        AppSpacing.gapMd,
                        buildTextField(...),
                      ],
                    ),
                  ),
                  */
                  _buildSectionHeader(
                    context,
                    title: 'Personal & Contact Information',
                    icon: Iconsax.user,
                  ),

                  // Full Name
                  buildTextField(
                    label: 'Full Name',
                    controller: controller.nameController,
                    hint: 'e.g. John Doe',
                    isRequired: true,
                    prefixIcon: Icon(
                      Iconsax.user,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    validator: StaffValidator.validateName,
                  ),
                  AppSpacing.gapMd,

                  // Email Address
                  buildTextField(
                    label: 'Email Address',
                    controller: controller.emailController,
                    hint: 'e.g. john@surfdesk.com',
                    keyboardType: TextInputType.emailAddress,
                    isRequired: true,
                    prefixIcon: Icon(
                      Iconsax.sms,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    validator: StaffValidator.validateEmail,
                  ),
                  AppSpacing.gapMd,

                  // Phone Number
                  buildTextField(
                    label: 'Phone Number',
                    controller: controller.phoneNumberController,
                    hint: 'e.g. +94 77 123 4567',
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icon(
                      Iconsax.call,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                  ),
                  AppSpacing.gapLg,

                  // ── Section 2: Employment Details ─────────────────────────
                  _buildSectionHeader(
                    context,
                    title: 'Employment & Timeline',
                    icon: Iconsax.calendar_1,
                  ),

                  // Join Date Picker
                  GestureDetector(
                    onTap: () async {
                      final now = DateTime.now();
                      final date = await showDatePicker(
                        context: context,
                        initialDate: now,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        controller.joinDateController.text =
                            "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                      }
                    },
                    child: AbsorbPointer(
                      child: buildTextField(
                        label: 'Join Date',
                        controller: controller.joinDateController,
                        hint: 'YYYY-MM-DD',
                        prefixIcon: Icon(
                          Iconsax.calendar_1,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                        suffixIcon: Icon(
                          Iconsax.calendar,
                          size: 18,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        readOnly: true,
                      ),
                    ),
                  ),
                  AppSpacing.gapLg,

                  // ── Section 3: Credentials & Access ───────────────────────
                  _buildSectionHeader(
                    context,
                    title: 'Security & Access Credentials',
                    icon: Iconsax.lock,
                  ),

                  // Password
                  Obx(
                    () => buildTextField(
                      label: 'Account Password',
                      controller: controller.passwordController,
                      hint: 'Minimum 6 characters',
                      isRequired: true,
                      obscureText: !controller.isPasswordVisible.value,
                      prefixIcon: Icon(
                        Iconsax.lock,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isPasswordVisible.value
                              ? Iconsax.eye
                              : Iconsax.eye_slash,
                          size: 20,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        onPressed: controller.isPasswordVisible.toggle,
                      ),
                      validator: (value) =>
                          StaffValidator.validatePassword(value, isEdit: false),
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

  // ── Section Header (Styled like CustomerAddView with icon badge) ───────────
  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm, top: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xxs + 1),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: AppRadius.smAll,
            ),
            child: Icon(icon, size: 14, color: theme.colorScheme.primary),
          ),
          AppSpacing.hGapXs,
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ── Policy Header Banner ──────────────────────────────────────────────────
  Widget _buildHeaderBanner(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: AppRadius.smAll,
            ),
            child: Icon(
              Iconsax.user_cirlce_add,
              size: 20,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          AppSpacing.gapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Staff Onboarding',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Create credentials for new team members. They will receive operational access to rentals, payments, and storefront tasks.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
