import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_floating_bottom_sheet.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../domain/entities/sale_category.dart';
import '../../domain/validators/sale_category_validator.dart';
import '../controllers/sale_category_list_controller.dart';

class SaleCategoryFormSheet extends StatelessWidget {
  const SaleCategoryFormSheet({
    super.key,
    required this.controller,
    this.item,
  });

  final SaleCategoryListController controller;
  final SaleCategory? item;

  static void show(
    BuildContext context,
    SaleCategoryListController controller, {
    SaleCategory? item,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      isDismissible: true,
      builder: (context) => SaleCategoryFormSheet(
        controller: controller,
        item: item,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = item != null;

    return AppFloatingBottomSheet(
      isFloating: false,
      title: isEditing ? 'Edit Sale Category' : 'Add Sale Category',
      subtitle: isEditing
          ? 'Update sales category details'
          : 'Define a new category for catalog products',
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.12),
          borderRadius: AppRadius.smAll,
        ),
        child: Icon(
          isEditing ? Iconsax.edit : Iconsax.category_2,
          color: theme.colorScheme.primary,
          size: 18,
        ),
      ),
      footer: Obx(
        () => SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            onPressed: controller.isSaving.value
                ? null
                : () {
                    if (controller.formKey.currentState!.validate()) {
                      if (isEditing) {
                        controller.updateSaleCategory(
                          item!.id,
                          controller.nameController.text.trim(),
                          controller.descController.text.trim(),
                        );
                      } else {
                        controller.addSaleCategory(
                          controller.nameController.text.trim(),
                          controller.descController.text.trim(),
                        );
                      }
                    }
                  },
            icon: controller.isSaving.value
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
              controller.isSaving.value
                  ? 'Saving...'
                  : (isEditing ? 'Update Category' : 'Save Category'),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              label: 'Category Name',
              controller: controller.nameController,
              hint: 'e.g. Shirts, Wax, Fins',
              isRequired: true,
              prefixIcon: Iconsax.tag,
              textInputAction: TextInputAction.next,
              validator: SaleCategoryValidator.validateName,
            ),
            AppSpacing.gapMd,
            AppTextField(
              label: 'Description',
              controller: controller.descController,
              hint: 'Optional description of this product category',
              optional: true,
              prefixIcon: Iconsax.document_text,
              maxLines: 3,
              validator: SaleCategoryValidator.validateDescription,
            ),
            AppSpacing.gapSm,
          ],
        ),
      ),
    );
  }
}
