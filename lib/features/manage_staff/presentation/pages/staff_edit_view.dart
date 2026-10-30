import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/utils/responsive.dart';
import 'package:pos/core/widgets/app_bottom_action_bar.dart';
import 'package:pos/core/widgets/app_form_elements.dart';
import 'package:pos/core/widgets/custome_app_bar.dart';

import '../../domain/entities/staff.dart';
import '../../domain/validators/staff_validator.dart';
import '../controllers/staff_controller.dart';

/// Redesigned Staff Edit Screen conforming to Material 3 guidelines and project UI/UX standards.
/// - Flat surface layout without unnecessary container cards
/// - CustomerAddView icon-badged section headers (_buildSectionHeader)
/// - Domain StaffValidator integration
/// - Modern account status switch card
/// - Thumb-accessible sticky bottom action bar
/// - Tablet/Desktop responsive layout
class StaffEditView extends GetView<StaffController> {
  const StaffEditView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final Staff staff = Get.arguments as Staff;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CustomeAppBar(
        title: 'Edit Staff Member',
        centerTitle: true,
        showbackArrow: true,
      ),
      bottomNavigationBar: Obx(
        () => AppBottomActionBar.primaryAction(
          label: 'Save Changes',
          icon: Iconsax.tick_circle,
          isLoading: controller.isSaving.value,
          onPressed: () async {
            if (controller.staffFormKey.currentState?.validate() ?? false) {
              await controller.updateStaff(
                staff,
                controller.nameController.text.trim(),
                controller.emailController.text.trim(),
                controller.passwordController.text.trim(),
                phoneNumber: controller.phoneNumberController.text.trim(),
                joinDate: controller.joinDateController.text.trim(),
              );
              Get.back();
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
                  _buildHeaderBanner(context, staff),
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
                    hint: 'Enter full name',
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
                    hint: 'Enter email address',
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

                  // ── Section 2: Employment & Status ────────────────────────
                  _buildSectionHeader(
                    context,
                    title: 'Employment & Access Status',
                    icon: Iconsax.briefcase,
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
                  AppSpacing.gapMd,

                  // Account Status Toggle Card
                  _buildStatusToggleCard(context, staff),
                  AppSpacing.gapLg,

                  // ── Section 3: Credentials & Access ───────────────────────
                  _buildSectionHeader(
                    context,
                    title: 'Password Management',
                    icon: Iconsax.lock,
                  ),

                  // New Password
                  Obx(
                    () => buildTextField(
                      label: 'New Password',
                      controller: controller.passwordController,
                      hint: 'Enter new password',
                      helperText: 'Leave blank to retain current password.',
                      isRequired: false,
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
                          StaffValidator.validatePassword(value, isEdit: true),
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

  // ── Account Status Switch Card ────────────────────────────────────────────
  Widget _buildStatusToggleCard(BuildContext context, Staff staff) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Obx(() {
      final isAdmin = staff.role.toLowerCase() == 'admin';
      final isActive = controller.isActiveEdit.value;

      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: AppRadius.mdAll,
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isActive ? Colors.green : colorScheme.error)
                    .withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isActive ? Iconsax.user_tick : Iconsax.user_remove,
                size: 20,
                color: isActive ? Colors.green : colorScheme.error,
              ),
            ),
            AppSpacing.hGapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Operational Account Status',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isAdmin
                        ? 'Administrator accounts cannot be deactivated here'
                        : (isActive
                            ? 'Active — permitted to perform rentals and transactions'
                            : 'Suspended — prevented from accessing the system'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: isActive,
              onChanged: isAdmin ? null : (val) => controller.isActiveEdit.value = val,
              activeThumbColor: Colors.green,
            ),
          ],
        ),
      );
    });
  }

  // ── Header Banner ─────────────────────────────────────────────────────────
  Widget _buildHeaderBanner(BuildContext context, Staff staff) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isAdmin = staff.role.toLowerCase() == 'admin';

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
          CircleAvatar(
            radius: 20,
            backgroundColor: (isAdmin ? colorScheme.primary : colorScheme.secondary)
                .withValues(alpha: 0.14),
            child: Text(
              staff.name.isNotEmpty ? staff.name[0].toUpperCase() : '?',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isAdmin ? colorScheme.primary : colorScheme.secondary,
              ),
            ),
          ),
          AppSpacing.gapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        staff.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isAdmin
                            ? colorScheme.primary.withValues(alpha: 0.1)
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        staff.role.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: isAdmin
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  staff.email,
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
