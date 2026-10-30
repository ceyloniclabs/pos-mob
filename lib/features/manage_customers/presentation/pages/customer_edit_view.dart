import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'package:pos/core/constants/api_endpoints.dart';
import 'package:pos/core/enums.dart';
import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/utils/dialog_utils.dart';
import 'package:pos/core/utils/responsive.dart';
import 'package:pos/core/widgets/app_bottom_action_bar.dart';
import 'package:pos/core/widgets/country_edit_drop_down.dart';
import 'package:pos/core/widgets/custom_text_field.dart';
import 'package:pos/core/widgets/custome_app_bar.dart';
import 'package:pos/features/manage_customers/domain/validators/customer_validator.dart';
import 'package:pos/features/manage_customers/presentation/controllers/customer_edit_controller.dart';

class CustomerEditView extends GetView<CustomerEditController> {
  const CustomerEditView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: const CustomeAppBar(
        title: 'Edit Customer',
        centerTitle: true,
        showbackArrow: true,
      ),
      bottomNavigationBar: Obx(
        () => AppBottomActionBar.primaryAction(
          label: 'Update Customer',
          icon: Icons.check_circle_outline_rounded,
          isLoading: controller.isLoading.value,
          onPressed:
              controller.isLoading.value ? null : controller.updateCustomer,
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
                  // â”€â”€ Profile Photo Hero â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  _buildProfileHero(theme, textTheme),
                  AppSpacing.gapXl,

                  // â”€â”€ Section 1: Personal & Contact Information â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

                  // â”€â”€ Section 2: Identification & Country â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  _buildSectionHeader(
                    context,
                    title: 'Identification & Nationality',
                    icon: Iconsax.card,
                  ),
                  _buildCustomerTypeSelector(theme),
                  AppSpacing.gapMd,
                  Obx(() {
                    final isLocal = controller.selectedCustomerType.value ==
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
                  _buildCountryField(theme, textTheme),
                  AppSpacing.gapLg,

                  // â”€â”€ Section 3: Demographics & Membership â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  _buildSectionHeader(
                    context,
                    title: 'Demographics & Membership',
                    icon: Iconsax.profile_2user,
                  ),
                  const FieldLabel('Gender'),
                  AppSpacing.gapXs,
                  _buildGenderChips(theme),
                  AppSpacing.gapMd,
                  const FieldLabel('Membership Tier'),
                  AppSpacing.gapXs,
                  _buildMembershipChips(theme),
                  AppSpacing.gapLg,

                  // â”€â”€ Section 4: Document Attachment â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

  // â”€â”€ Section Header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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
            child: Icon(
              icon,
              size: 14,
              color: theme.colorScheme.primary,
            ),
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

  // â”€â”€ Profile Photo Hero â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildProfileHero(ThemeData theme, TextTheme textTheme) {
    return Center(
      child: Obx(() {
        final localPhoto = controller.profilePhoto.value;
        final hasExistingPhoto = controller.customer.profilePhoto != null &&
            controller.customer.profilePhoto!.isNotEmpty;

        ImageProvider? imageProvider;
        if (localPhoto != null) {
          imageProvider = FileImage(localPhoto);
        } else if (hasExistingPhoto) {
          final photo = controller.customer.profilePhoto!;
          final url = photo.startsWith('http')
              ? photo
              : '${EndPoints.baseUrl.replaceAll('/api/', '')}$photo';
          imageProvider = NetworkImage(url);
        }

        final hasAnyPhoto = imageProvider != null;

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
                        color: theme.colorScheme.primary.withValues(alpha: 0.35),
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
                      backgroundImage: imageProvider,
                      child: !hasAnyPhoto
                          ? Icon(
                              Iconsax.user,
                              size: 38,
                              color: theme.colorScheme.primary,
                            )
                          : null,
                    ),
                  ),
                ),
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
                if (localPhoto != null)
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
              hasAnyPhoto ? 'Change Profile Photo' : 'Add Profile Photo',
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            Text(
              'Optional â€¢ JPG or PNG',
              style: textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );
      }),
    );
  }

  // â”€â”€ Customer Type Segmented Pill â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildCustomerTypeSelector(ThemeData theme) {
    return Obx(() {
      final selectedType = controller.selectedCustomerType.value;
      final isLocal = selectedType == CustomerType.local.value;
      return Container(
        height: 48,
        padding: const EdgeInsets.all(3.5),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
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

  // â”€â”€ Country Field â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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
          controller.isCountriesLoading.value
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: CircularProgressIndicator.adaptive(),
                  ),
                )
              : CountryEditDropDown(
                  key: ValueKey(
                    'country_${controller.selectedCustomerType.value}_${controller.selectedCountryId.value}',
                  ),
                  countries: controller.countries,
                  initialValue: controller.selectedCountryId.value,
                  onChanged: (countryId) {
                    controller.selectedCountryId.value = countryId;
                  },
                ),
        ],
      );
    });
  }

  // â”€â”€ Gender Choice Chips â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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
            onTap: () => controller.selectedGender.value = GenderType.male.value,
          ),
          _SelectableChoiceChip(
            label: 'Female',
            icon: Icons.female_rounded,
            isSelected: currentGender == GenderType.female.value,
            onTap: () => controller.selectedGender.value = GenderType.female.value,
          ),
          _SelectableChoiceChip(
            label: 'Other',
            icon: Icons.transgender_rounded,
            isSelected: currentGender == GenderType.other.value,
            onTap: () => controller.selectedGender.value = GenderType.other.value,
          ),
        ],
      );
    });
  }

  // â”€â”€ Membership Tier Chips â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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
            onTap: () =>
                controller.selectedMembershipLevel.value = MembershipLevel.bronze.value,
          ),
          _SelectableChoiceChip(
            label: 'Silver',
            accentColor: const Color(0xFF94A3B8),
            isSelected: currentLevel == MembershipLevel.silver.value,
            onTap: () =>
                controller.selectedMembershipLevel.value = MembershipLevel.silver.value,
          ),
          _SelectableChoiceChip(
            label: 'Gold',
            accentColor: const Color(0xFFEAB308),
            isSelected: currentLevel == MembershipLevel.gold.value,
            onTap: () =>
                controller.selectedMembershipLevel.value = MembershipLevel.gold.value,
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

  // â”€â”€ Document Attachment Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildDocumentAttachmentCard(ThemeData theme, TextTheme textTheme) {
    return Obx(() {
      final docFile = controller.documentFile.value;
      final existingDocUrl = controller.customer.documentPhotoUrl;
      final hasExistingDoc =
          existingDocUrl != null && existingDocUrl.trim().isNotEmpty;

      if (docFile == null && !hasExistingDoc) {
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
                  icon: const Icon(Iconsax.folder_open, size: 16),
                  label: const Text('Browse Files'),
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Uploaded or Existing document card
      final bool isNewlyPicked = docFile != null;
      final String rawPath = isNewlyPicked ? docFile.path : existingDocUrl!;
      final bool isPdf = rawPath.toLowerCase().endsWith('.pdf');
      final String fileName = rawPath.split(RegExp(r'[/\\]')).last;
      final String fileSize = isNewlyPicked ? _formatFileSize(docFile) : '';
      final String fileTypeDesc = isPdf ? 'PDF Document' : 'Image File';
      final String subtitle = isNewlyPicked
          ? (fileSize.isNotEmpty ? '$fileSize â€¢ $fileTypeDesc' : fileTypeDesc)
          : 'Existing on record â€¢ $fileTypeDesc';

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
            child: isNewlyPicked
                ? Image.file(
                    docFile,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Icon(
                      Iconsax.gallery,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                  )
                : CachedNetworkImage(
                    imageUrl: rawPath.startsWith('http')
                        ? rawPath
                        : '${EndPoints.baseUrl.replaceAll('/api/', '')}$rawPath',
                    width: 50,
                    height: 50,
                    memCacheWidth: 150,
                    memCacheHeight: 150,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Container(
                      width: 50,
                      height: 50,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const Center(
                        child: SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                    errorWidget: (_, _, _) => Icon(
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
                              isNewlyPicked
                                  ? 'New file selected'
                                  : 'Attached on record',
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
                if (isNewlyPicked) ...[
                  AppSpacing.hGapXs,
                  IconButton.filledTonal(
                    icon: const Icon(Icons.close_rounded, size: 16),
                    color: theme.colorScheme.error,
                    style: IconButton.styleFrom(
                      backgroundColor:
                          theme.colorScheme.error.withValues(alpha: 0.1),
                      minimumSize: const Size(32, 32),
                      maximumSize: const Size(32, 32),
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    tooltip: 'Remove selected file',
                    onPressed: () => controller.documentFile.value = null,
                  ),
                ],
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

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Subcomponents
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.accentColor,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = accentColor ?? theme.colorScheme.primary;

    final backgroundColor = isSelected
        ? effectiveColor.withValues(alpha: 0.12)
        : theme.colorScheme.surfaceContainerLowest;

    final borderColor = isSelected
        ? effectiveColor.withValues(alpha: 0.8)
        : theme.colorScheme.outlineVariant.withValues(alpha: 0.6);

    final textColor = isSelected
        ? (accentColor != null ? effectiveColor : theme.colorScheme.primary)
        : theme.colorScheme.onSurfaceVariant;

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
