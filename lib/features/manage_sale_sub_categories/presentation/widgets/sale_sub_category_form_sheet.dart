import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_floating_bottom_sheet.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/sale_category_drop_down.dart';
import '../../domain/entities/sale_sub_category.dart';
import '../../domain/validators/sale_sub_category_validator.dart';
import '../controllers/sale_sub_category_list_controller.dart';

class SaleSubCategoryFormSheet extends StatefulWidget {
  const SaleSubCategoryFormSheet({
    super.key,
    required this.controller,
    this.item,
  });

  final SaleSubCategoryListController controller;
  final SaleSubCategory? item;

  static void show(
    BuildContext context,
    SaleSubCategoryListController controller, {
    SaleSubCategory? item,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      isDismissible: true,
      builder: (context) => SaleSubCategoryFormSheet(
        controller: controller,
        item: item,
      ),
    );
  }

  @override
  State<SaleSubCategoryFormSheet> createState() =>
      _SaleSubCategoryFormSheetState();
}

class _SaleSubCategoryFormSheetState extends State<SaleSubCategoryFormSheet> {
  int _selectedCategory = -1;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.controller.selectedSaleCategory;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.item != null;

    return AppFloatingBottomSheet(
      isFloating: false,
      title: isEditing ? 'Edit Sub-Category' : 'Add Sub-Category',
      subtitle: isEditing
          ? 'Update sub-category title and parent category'
          : 'Create a new sub-category linked to a sales category',
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.12),
          borderRadius: AppRadius.smAll,
        ),
        child: Icon(
          isEditing ? Iconsax.edit : Iconsax.element_3,
          color: theme.colorScheme.primary,
          size: 18,
        ),
      ),
      footer: Obx(
        () => SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            onPressed: widget.controller.isSaving.value
                ? null
                : () async {
                    if (widget.controller.formKey.currentState!.validate()) {
                      bool success = false;
                      if (isEditing) {
                        success =
                            await widget.controller.updateSaleSubCategory(
                          widget.item!.id,
                          widget.controller.nameController.text.trim(),
                          _selectedCategory,
                          widget.controller.descController.text.trim(),
                        );
                      } else {
                        success = await widget.controller.addSaleSubCategory(
                          widget.controller.nameController.text.trim(),
                          _selectedCategory,
                          widget.controller.descController.text.trim(),
                        );
                      }
                      if (success) {
                        Get.back();
                      }
                    }
                  },
            icon: widget.controller.isSaving.value
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check_circle_outline_rounded, size: 18),
            label: Text(
              widget.controller.isSaving.value
                  ? 'Saving...'
                  : (isEditing ? 'Update Sub-Category' : 'Save Sub-Category'),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
      child: Form(
        key: widget.controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FieldLabel('Parent Sale Category', isRequired: true),
            AppSpacing.gapXs,
            Obx(
              () => SaleCategoryDropDown(
                initialValue: _selectedCategory > 0 ? _selectedCategory : null,
                saleCategoryList:
                    widget.controller.saleCategoryList.toList(),
                validator: (category) {
                  if (category == null && _selectedCategory <= 0) {
                    return 'Please select a parent sale category';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value?.id ?? -1;
                    widget.controller.selectedSaleCategory = _selectedCategory;
                  });
                },
              ),
            ),
            AppSpacing.gapMd,

            AppTextField(
              label: 'Sub-Category Name',
              controller: widget.controller.nameController,
              hint: 'e.g. T-Shirts, Boardshorts, Wetsuits',
              isRequired: true,
              prefixIcon: Iconsax.tag,
              textInputAction: TextInputAction.next,
              validator: SaleSubCategoryValidator.validateName,
            ),
            AppSpacing.gapMd,

            AppTextField(
              label: 'Description',
              controller: widget.controller.descController,
              hint: 'Optional description of this sub-category',
              optional: true,
              prefixIcon: Iconsax.document_text,
              maxLines: 3,
              validator: SaleSubCategoryValidator.validateDescription,
            ),
            AppSpacing.gapSm,
          ],
        ),
      ),
    );
  }
}
