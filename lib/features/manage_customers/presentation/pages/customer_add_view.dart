import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'package:pos/core/enums.dart';
import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/utils/dialog_utils.dart';
import 'package:pos/core/utils/responsive.dart';
import 'package:pos/core/widgets/app_bottom_action_bar.dart';
import 'package:pos/core/widgets/country_drop_down.dart';
import 'package:pos/core/widgets/custom_text_field.dart';
import 'package:pos/core/widgets/custome_app_bar.dart';
import 'package:pos/features/manage_customers/domain/validators/customer_validator.dart';
import 'package:pos/features/manage_customers/presentation/controllers/customer_add_controller.dart';

class CustomerAddView extends GetView<CustomerAddController> {
  const CustomerAddView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: CustomeAppBar(
        title: 'Add Customer',
        centerTitle: true,
        showbackArrow: true,
        leadingOnPressed: () => Get.back(result: controller.isAdded.value),
      ),
      bottomNavigationBar: Obx(
        () => AppBottomActionBar.primaryAction(
          label: 'Save Customer',
          icon: Icons.check_circle_outline_rounded,
          isLoading: controller.isLoading.value,
          onPressed: controller.isLoading.value ? null : controller.addCustomer,
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
                  // ── Hero Profile Avatar ──────────────────────────────────
                  _buildProfileHero(theme, textTheme),
                  AppSpacing.gapLg,

                  // ── Customer Classification (Segmented Pill) ─────────────
                  _buildSectionHeader(
                    context,
                    title: 'Customer Classification',
                    icon: Iconsax.category,
                  ),
                  _buildCustomerTypeSelector(theme),
                  AppSpacing.gapLg,

                  // ── Section 1: Personal & Contact Information ────────────
                  _buildSectionHeader(
                    context,
                    title: 'Personal & Contact Information',
                    icon: Iconsax.user,
                  ),
                  AppTextField(
                    label: 'Full Name',
                    isRequired: true,
                    hint: 'e.g. John Doe',
                    controller: controller.nameController,
                    prefixIcon: Iconsax.user,
                    textInputAction: TextInputAction.next,
                    validator: CustomerValidator.validateName,
                  ),
                  AppSpacing.gapMd,
                  AppTextField(
                    label: 'Phone Number',
                    isRequired: true,
                    hint: 'e.g. +94 77 123 4567',
                    controller: controller.phoneController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Iconsax.call,
                    textInputAction: TextInputAction.next,
                    validator: CustomerValidator.validatePhone,
                  ),
                  AppSpacing.gapMd,
                  AppTextField(
                    label: 'Email Address',
                    isRequired: true,
                    hint: 'e.g. customer@example.com',
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Iconsax.sms,
                    textInputAction: TextInputAction.next,
                    validator: CustomerValidator.validateEmail,
                  ),
                  AppSpacing.gapLg,

                  // ── Section 2: Identification & Country ──────────────────
                  _buildSectionHeader(
                    context,
                    title: 'Identification & Nationality',
                    icon: Iconsax.card,
                  ),
                  // Dynamic identification field based on type
                  Obx(() {
                    final isLocal =
                        controller.selectedCustomerType.value ==
                        CustomerType.local.value;
                    return isLocal
                        ? AppTextField(
                            label: 'National Identity Card (NIC)',
                            isRequired: true,
                            hint: 'e.g. 199512345678 or 951234567V',
                            controller: controller.nicController,
                            prefixIcon: Iconsax.card,
                            validator: CustomerValidator.validateNic,
                          )
                        : AppTextField(
                            label: 'Passport Number',
                            isRequired: true,
                            hint: 'e.g. N12345678',
                            controller: controller.passportController,
                            prefixIcon: Iconsax.document_text,
                            validator: CustomerValidator.validatePassport,
                          );
                  }),
                  AppSpacing.gapMd,

                  // Country field
                  _buildCountryField(theme, textTheme),
                  AppSpacing.gapLg,

                  // ── Section 3: Demographics & Membership ─────────────────
                  _buildSectionHeader(
                    context,
                    title: 'Demographics & Membership',
                    icon: Iconsax.profile_2user,
                  ),
                  // Gender choice chips
                  const FieldLabel('Gender'),
                  AppSpacing.gapXs,
                  _buildGenderChips(theme),
                  AppSpacing.gapMd,

                  // Membership Tier selection chips
                  const FieldLabel('Membership Tier'),
                  AppSpacing.gapXs,
                  _buildMembershipChips(theme),
                  AppSpacing.gapLg,

                  // ── Section 4: Document Attachment ───────────────────────
                  _buildSectionHeader(
                    context,
                    title: 'Identity Document (Optional)',
                    icon: Iconsax.document_upload,
                  ),
                  _buildDocumentAttachmentCard(theme, textTheme),
                  AppSpacing.gapXxl,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Section Header ───────────────────────────────────────────────────────
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

  // ── Profile Photo Hero ───────────────────────────────────────────────────
  Widget _buildProfileHero(ThemeData theme, TextTheme textTheme) {
    return Center(
      child: Obx(() {
        final photo = controller.profilePhoto.value;
        return Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  onTap: () => DialogUtils.showImageSourceDialog(
                    onImageSourceSelected: controller.pickImage,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.35,
                        ),
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 44,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      backgroundImage: photo != null ? FileImage(photo) : null,
                      child: photo == null
                          ? Icon(
                              Iconsax.user,
                              size: 38,
                              color: theme.colorScheme.primary,
                            )
                          : null,
                    ),
                  ),
                ),
                // Camera trigger badge
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => DialogUtils.showImageSourceDialog(
                      onImageSourceSelected: controller.pickImage,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.xxs),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.surface,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Iconsax.camera,
                        size: 15,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
                // Remove photo button if photo exists
                if (photo != null)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => controller.profilePhoto.value = null,
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.xxs),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.surface,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 13,
                          color: theme.colorScheme.onError,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            AppSpacing.gapSm,
            Text(
              photo != null ? 'Change Profile Photo' : 'Add Profile Photo',
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            Text(
              'Optional • JPG or PNG',
              style: textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );
      }),
    );
  }

  // ── Customer Type Segmented Pill ─────────────────────────────────────────
  Widget _buildCustomerTypeSelector(ThemeData theme) {
    return Obx(() {
      final selectedType = controller.selectedCustomerType.value;
      final isLocal = selectedType == CustomerType.local.value;
      return Container(
        height: 48,
        padding: const EdgeInsets.all(3.5),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.5,
          ),
          borderRadius: AppRadius.mdAll,
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _TypeSelectionSegment(
                title: 'Local',
                tag: 'NIC',
                icon: Iconsax.location,
                isSelected: isLocal,
                onTap: () {
                  controller.selectedCustomerType.value =
                      CustomerType.local.value;
                },
              ),
            ),
            Expanded(
              child: _TypeSelectionSegment(
                title: 'Foreigner',
                tag: 'Passport',
                icon: Iconsax.global,
                isSelected: !isLocal,
                onTap: () {
                  controller.selectedCustomerType.value =
                      CustomerType.foreigner.value;
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  // ── Country Field ────────────────────────────────────────────────────────
  Widget _buildCountryField(ThemeData theme, TextTheme textTheme) {
    return Obx(() {
      final isLocal =
          controller.selectedCustomerType.value == CustomerType.local.value;

      if (isLocal) {
        return AppTextField(
          label: 'Country of Origin',
          isRequired: true,
          controller: TextEditingController(text: 'Sri Lanka'),
          readOnly: true,
          enabled: false,
          prefixIcon: Iconsax.map,
          helperText: 'Auto-assigned for local customers (Sri Lanka)',
          suffix: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(
              Icons.lock_outline_rounded,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FieldLabel('Country of Origin', isRequired: true),
          AppSpacing.gapXs,
          CountryDropDown(
            key: ValueKey('country_${controller.selectedCountryId.value}'),
            initialValue: controller.selectedCountryId.value,
          ),
        ],
      );
    });
  }

  // ── Gender Choice Chips ──────────────────────────────────────────────────
  Widget _buildGenderChips(ThemeData theme) {
    return Obx(() {
      final currentGender = controller.selectedGender.value;
      return Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          _SelectableChoiceChip(
            label: 'Male',
            icon: Icons.male_rounded,
            isSelected: currentGender == GenderType.male.value,
            onTap: () =>
                controller.selectedGender.value = GenderType.male.value,
          ),
          _SelectableChoiceChip(
            label: 'Female',
            icon: Icons.female_rounded,
            isSelected: currentGender == GenderType.female.value,
            onTap: () =>
                controller.selectedGender.value = GenderType.female.value,
          ),
          _SelectableChoiceChip(
            label: 'Other',
            icon: Icons.transgender_rounded,
            isSelected: currentGender == GenderType.other.value,
            onTap: () =>
                controller.selectedGender.value = GenderType.other.value,
          ),
        ],
      );
    });
  }

  // ── Membership Tier Chips ────────────────────────────────────────────────
  Widget _buildMembershipChips(ThemeData theme) {
    return Obx(() {
      final currentLevel = controller.selectedMembershipLevel.value;
      return Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          _SelectableChoiceChip(
            label: 'Bronze',
            accentColor: const Color(0xFFCD7F32),
            isSelected: currentLevel == MembershipLevel.bronze.value,
            onTap: () => controller.selectedMembershipLevel.value =
                MembershipLevel.bronze.value,
          ),
          _SelectableChoiceChip(
            label: 'Silver',
            accentColor: const Color(0xFF94A3B8),
            isSelected: currentLevel == MembershipLevel.silver.value,
            onTap: () => controller.selectedMembershipLevel.value =
                MembershipLevel.silver.value,
          ),
          _SelectableChoiceChip(
            label: 'Gold',
            accentColor: const Color(0xFFEAB308),
            isSelected: currentLevel == MembershipLevel.gold.value,
            onTap: () => controller.selectedMembershipLevel.value =
                MembershipLevel.gold.value,
          ),
          _SelectableChoiceChip(
            label: 'Platinum',
            accentColor: const Color(0xFFA855F7),
            isSelected: currentLevel == MembershipLevel.platinum.value,
            onTap: () => controller.selectedMembershipLevel.value =
                MembershipLevel.platinum.value,
          ),
        ],
      );
    });
  }

  // ── Document Attachment Card ─────────────────────────────────────────────
  Widget _buildDocumentAttachmentCard(ThemeData theme, TextTheme textTheme) {
    return Obx(() {
      final docFile = controller.documentFile.value;

      if (docFile == null) {
        // Empty dropzone state
        return InkWell(
          onTap: controller.pickDocument,
          borderRadius: AppRadius.mdAll,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: AppRadius.mdAll,
              border: Border.all(
                color: theme.colorScheme.outlineVariant,
                style: BorderStyle.solid,
                width: 1.2,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Iconsax.document_upload,
                    color: theme.colorScheme.primary,
                    size: 26,
                  ),
                ),
                AppSpacing.gapSm,
                Text(
                  'Upload ID or Passport Document',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AppSpacing.vGapXxs,
                Text(
                  'Accepted formats: PDF, JPG, PNG (Max 5MB)',
                  style: textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                AppSpacing.gapMd,
                FilledButton.tonalIcon(
                  onPressed: controller.pickDocument,
                  icon: const Icon(Icons.attach_file_rounded, size: 16),
                  label: const Text('Browse File'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(130, 38),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.smAll,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Uploaded document card
      final isPdf = docFile.path.toLowerCase().endsWith('.pdf');
      final fileName = docFile.path.split(RegExp(r'[/\\]')).last;
      final fileSize = _formatFileSize(docFile);
      final fileTypeDesc = isPdf ? 'PDF Document' : 'Image File';
      final subtitle = fileSize.isNotEmpty
          ? '$fileSize • $fileTypeDesc'
          : fileTypeDesc;

      Widget thumbnail;
      if (isPdf) {
        thumbnail = Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: theme.colorScheme.error.withValues(alpha: 0.1),
            borderRadius: AppRadius.smAll,
            border: Border.all(
              color: theme.colorScheme.error.withValues(alpha: 0.25),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.picture_as_pdf_rounded,
                color: theme.colorScheme.error,
                size: 22,
              ),
              const SizedBox(height: 1),
              Text(
                'PDF',
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );
      } else {
        thumbnail = Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: AppRadius.smAll,
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
          child: ClipRRect(
            borderRadius: AppRadius.smAll,
            child: Image.file(
              docFile,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Icon(
                Iconsax.gallery,
                color: theme.colorScheme.primary,
                size: 22,
              ),
            ),
          ),
        );
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: AppRadius.mdAll,
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
            width: 1.2,
          ),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                thumbnail,
                AppSpacing.hGapMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        fileName,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppSpacing.vGapXxs,
                      Text(
                        subtitle,
                        style: textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 11.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          AppSpacing.hGapXxs,
                          Flexible(
                            child: Text(
                              'Attached successfully',
                              style: textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF10B981),
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                AppSpacing.hGapXs,
                IconButton.filledTonal(
                  icon: const Icon(Icons.close_rounded, size: 16),
                  color: theme.colorScheme.error,
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.error.withValues(
                      alpha: 0.1,
                    ),
                    minimumSize: const Size(32, 32),
                    maximumSize: const Size(32, 32),
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  tooltip: 'Remove document',
                  onPressed: () => controller.documentFile.value = null,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Divider(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                height: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Center(
                child: TextButton.icon(
                  onPressed: controller.pickDocument,
                  icon: const Icon(Icons.sync_rounded, size: 15),
                  label: const Text('Change Document'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Formats byte length into a readable size string (e.g. 1.2 MB).
  String _formatFileSize(File file) {
    try {
      final bytes = file.lengthSync();
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (_) {
      return '';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Subcomponents
// ─────────────────────────────────────────────────────────────────────────────

/// Compact segmented pill tab for choosing Customer Type (Local vs Foreigner).
class _TypeSelectionSegment extends StatelessWidget {
  const _TypeSelectionSegment({
    required this.title,
    required this.tag,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String tag;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: isSelected ? theme.colorScheme.surface : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      elevation: isSelected ? 1 : 0,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary.withValues(alpha: 0.12)
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  tag,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact choice chip for gender & membership selections.
class _SelectableChoiceChip extends StatelessWidget {
  const _SelectableChoiceChip({
    required this.label,
    this.icon,
    this.accentColor,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData? icon;
  final Color? accentColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveColor = accentColor ?? theme.colorScheme.primary;

    final backgroundColor = isSelected
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surfaceContainerLow;

    final textColor = isSelected
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurface;

    final borderColor = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.outlineVariant;

    return Material(
      color: backgroundColor,
      borderRadius: AppRadius.smAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smAll,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          decoration: BoxDecoration(
            borderRadius: AppRadius.smAll,
            border: Border.all(
              color: borderColor,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (accentColor != null)
                Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.only(right: 6.0),
                  decoration: BoxDecoration(
                    color: effectiveColor,
                    shape: BoxShape.circle,
                  ),
                )
              else if (icon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 5.0),
                  child: Icon(
                    icon,
                    size: 14,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: textColor,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
