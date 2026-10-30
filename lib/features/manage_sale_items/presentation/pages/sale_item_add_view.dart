import 'package:pos/core/controllers/persistent_data_controller.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_bottom_action_bar.dart';
import '../../../../core/widgets/common_searchable_drop_down.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/custome_app_bar.dart';
import '../../../manage_sale_brands/data/models/sale_brand_model.dart';
import '../../../manage_sale_categories/data/models/sale_category_model.dart';
import '../../../manage_sale_sub_categories/data/models/sale_sub_category_model.dart';
import '../../domain/validators/sale_item_validator.dart';
import '../controllers/sale_item_add_controller.dart';

class SaleItemAddView extends GetView<SaleItemAddController> {
  const SaleItemAddView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: const CustomeAppBar(
        title: 'Add Sale Item',
        centerTitle: true,
        showbackArrow: true,
      ),
      bottomNavigationBar: Obx(
        () => AppBottomActionBar.primaryAction(
          label: 'Save Sale Item',
          icon: Icons.check_circle_outline_rounded,
          isLoading: controller.isSaving.value,
          onPressed: controller.isSaving.value ? null : controller.addSaleItem,
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
                  // ── Section 1: General Details ───────────────────────────
                  _buildSectionHeader(
                    context,
                    title: 'General Details',
                    icon: Iconsax.box,
                  ),
                  AppTextField(
                    label: 'Item Name',
                    isRequired: true,
                    hint: 'Enter item name',
                    controller: controller.nameController,
                    prefixIcon: Iconsax.box,
                    textInputAction: TextInputAction.next,
                    validator: SaleItemValidator.validateName,
                  ),
                  AppSpacing.gapMd,
                  AppTextField(
                    label: 'Description',
                    optional: true,
                    hint: 'Provide details, sizing, or notes...',
                    controller: controller.descriptionController,
                    maxLines: 3,
                    textInputAction: TextInputAction.next,
                  ),
                  AppSpacing.gapLg,

                  // ── Section 2: Classification ────────────────────────────
                  _buildSectionHeader(
                    context,
                    title: 'Classification',
                    icon: Iconsax.category_2,
                  ),
                  // Category Dropdown
                  const FieldLabel('Category', isRequired: true),
                  AppSpacing.gapXs,
                  Obx(
                    () => CommonSearchableDropdown<SaleCategoryModel>(
                      items: controller.categories.toList(),
                      hintText: 'Select category',
                      futureRequest: (query) async {
                        return controller.categories
                            .where(
                              (c) => c.name.toLowerCase().contains(
                                    query.toLowerCase(),
                                  ),
                            )
                            .toList();
                      },
                      onChanged: (cat) => controller.onCategoryChanged(cat?.id),
                      itemToString: (cat) => cat.name,
                      validator: (_) => SaleItemValidator.validateCategoryId(
                        controller.selectedCategoryId.value,
                      ),
                      initialItem: controller.categories.firstWhereOrNull(
                        (c) => c.id == controller.selectedCategoryId.value,
                      ),
                    ),
                  ),
                  AppSpacing.gapMd,

                  // Sub-Category Dropdown
                  const FieldLabel('Sub-Category', optional: true),
                  AppSpacing.gapXs,
                  Obx(
                    () => CommonSearchableDropdown<SaleSubCategoryModel>(
                      items: controller.filteredSubcategories,
                      hintText: controller.selectedCategoryId.value == null
                          ? 'Select a category first'
                          : 'Select sub-category (optional)',
                      futureRequest: (query) async {
                        return controller.filteredSubcategories
                            .where(
                              (s) => s.name.toLowerCase().contains(
                                    query.toLowerCase(),
                                  ),
                            )
                            .toList();
                      },
                      onChanged: (sub) =>
                          controller.selectedSubcategoryId.value = sub?.id,
                      itemToString: (sub) => sub.name,
                      initialItem: controller.filteredSubcategories
                          .firstWhereOrNull(
                        (s) => s.id == controller.selectedSubcategoryId.value,
                      ),
                    ),
                  ),
                  AppSpacing.gapMd,

                  // Brand Dropdown
                  const FieldLabel('Brand', isRequired: true),
                  AppSpacing.gapXs,
                  Obx(
                    () => CommonSearchableDropdown<SaleBrandModel>(
                      items: controller.filteredBrands,
                      hintText: controller.selectedCategoryId.value == null
                          ? 'Select a category first'
                          : 'Select brand',
                      futureRequest: (query) async {
                        return controller.filteredBrands
                            .where(
                              (b) => b.name.toLowerCase().contains(
                                    query.toLowerCase(),
                                  ),
                            )
                            .toList();
                      },
                      onChanged: (brand) =>
                          controller.selectedBrandId.value = brand?.id,
                      itemToString: (brand) => brand.name,
                      validator: (_) => SaleItemValidator.validateBrandId(
                        controller.selectedBrandId.value,
                      ),
                      initialItem: controller.filteredBrands.firstWhereOrNull(
                        (b) => b.id == controller.selectedBrandId.value,
                      ),
                    ),
                  ),
                  AppSpacing.gapLg,

                  // ── Section 3: Pricing & Inventory ───────────────────────
                  _buildSectionHeader(
                    context,
                    title: 'Pricing & Inventory',
                    icon: Iconsax.coin,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Buying Price (${Get.isRegistered<PersistentDataController>() ? PersistentDataController.to.currency : "USD"})',
                          isRequired: true,
                          hint: '0.00',
                          controller: controller.buyingPriceController,
                          keyboardType:
                              const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          prefixIcon: Iconsax.money_send,
                          textInputAction: TextInputAction.next,
                          validator: SaleItemValidator.validateBuyingPrice,
                        ),
                      ),
                      AppSpacing.gapSm,
                      Expanded(
                        child: AppTextField(
                          label: 'Selling Price (${Get.isRegistered<PersistentDataController>() ? PersistentDataController.to.currency : "USD"})',
                          isRequired: true,
                          hint: '0.00',
                          controller: controller.sellingPriceController,
                          keyboardType:
                              const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          prefixIcon: Iconsax.coin,
                          textInputAction: TextInputAction.next,
                          validator: SaleItemValidator.validateSellingPrice,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.gapMd,
                  AppTextField(
                    label: 'Stock Quantity',
                    isRequired: true,
                    hint: '0',
                    controller: controller.stockQuantityController,
                    keyboardType: TextInputType.number,
                    prefixIcon: Iconsax.box,
                    textInputAction: TextInputAction.done,
                    validator:
                        SaleItemValidator.validateStockQuantity,
                  ),
                  // Item status input commented out - automatically active
                  // Row(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [
                  //     Expanded(
                  //       child: Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           const FieldLabel('Item Status'),
                  //           AppSpacing.gapXs,
                  //           _buildStatusSelector(theme),
                  //         ],
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  AppSpacing.gapLg,

                  // ── Section 4: Product Photos ────────────────────────────
                  _buildSectionHeader(
                    context,
                    title: 'Product Photos (Optional)',
                    icon: Iconsax.gallery,
                  ),
                  _buildPhotoAttachmentSection(context, theme, textTheme),
                  AppSpacing.gapXxl,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

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

  Widget _buildPhotoAttachmentSection(
    BuildContext context,
    ThemeData theme,
    TextTheme textTheme,
  ) {
    return Obx(() {
      final paths = controller.selectedPhotosPaths;

      if (paths.isEmpty) {
        // Empty dropzone state (exact match to Customer document attachment)
        return InkWell(
          onTap: controller.pickPhotos,
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
                  'Upload Product Photos',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AppSpacing.vGapXxs,
                Text(
                  'Accepted formats: JPG, PNG (Max 5MB)',
                  style: textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                AppSpacing.gapMd,
                FilledButton.tonalIcon(
                  onPressed: controller.pickPhotos,
                  icon: const Icon(Icons.attach_file_rounded, size: 16),
                  label: const Text('Browse Files'),
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

      // Uploaded photos card (exact match to Customer document attachment)
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
            for (int i = 0; i < paths.length; i++) ...[
              if (i > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Divider(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.4,
                    ),
                    height: 1,
                  ),
                ),
              _buildUploadedPhotoItem(
                context,
                theme,
                textTheme,
                file: File(paths[i]),
                onRemove: () => controller.removePhoto(i),
              ),
            ],
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
                  onPressed: controller.pickPhotos,
                  icon: const Icon(Icons.add_photo_alternate_rounded, size: 16),
                  label: const Text('Add More Photos'),
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

  Widget _buildUploadedPhotoItem(
    BuildContext context,
    ThemeData theme,
    TextTheme textTheme, {
    required File file,
    required VoidCallback onRemove,
  }) {
    final fileName = file.path.split(RegExp(r'[/\\]')).last;
    final fileSize = _formatFileSize(file);
    final subtitle =
        fileSize.isNotEmpty ? '$fileSize • Image File' : 'Image File';

    final thumbnail = Container(
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
          file,
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

    return Row(
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
          tooltip: 'Remove photo',
          onPressed: onRemove,
        ),
      ],
    );
  }

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