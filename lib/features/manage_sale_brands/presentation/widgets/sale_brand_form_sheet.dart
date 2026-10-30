import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_floating_bottom_sheet.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/sale_category_drop_down.dart';
import '../../domain/entities/sale_brand.dart';
import '../../domain/validators/sale_brand_validator.dart';
import '../controllers/sale_brand_list_controller.dart';

class SaleBrandFormSheet extends StatefulWidget {
  const SaleBrandFormSheet({
    super.key,
    required this.controller,
    this.item,
  });

  final SaleBrandListController controller;
  final SaleBrand? item;

  static void show(
    BuildContext context,
    SaleBrandListController controller, {
    SaleBrand? item,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      isDismissible: true,
      builder: (context) => SaleBrandFormSheet(
        controller: controller,
        item: item,
      ),
    );
  }

  @override
  State<SaleBrandFormSheet> createState() => _SaleBrandFormSheetState();
}

class _SaleBrandFormSheetState extends State<SaleBrandFormSheet> {
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
      title: isEditing ? 'Edit Sale Brand' : 'Add Sale Brand',
      subtitle: isEditing
          ? 'Update merchandise brand name and category'
          : 'Register a new sales merchandise brand',
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.12),
          borderRadius: AppRadius.smAll,
        ),
        child: Icon(
          isEditing ? Iconsax.edit : Iconsax.award,
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
                        success = await widget.controller.updateSaleBrand(
                          widget.item!.id,
                          widget.controller.nameController.text.trim(),
                          _selectedCategory,
                        );
                      } else {
                        success = await widget.controller.addSaleBrand(
                          widget.controller.nameController.text.trim(),
                          _selectedCategory,
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
                  : (isEditing ? 'Update Brand' : 'Save Brand'),
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
            const FieldLabel('Sale Category', isRequired: true),
            AppSpacing.gapXs,
            Obx(
              () => SaleCategoryDropDown(
                initialValue: _selectedCategory > 0 ? _selectedCategory : null,
                saleCategoryList: widget.controller.saleCategoryList.toList(),
                validator: (category) {
                  if (category == null && _selectedCategory <= 0) {
                    return 'Please select a sale category';
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
              label: 'Brand Name',
              controller: widget.controller.nameController,
              hint: 'e.g. Quiksilver, Rip Curl, Hurley',
              isRequired: true,
              prefixIcon: Iconsax.tag,
              textInputAction: TextInputAction.next,
              validator: SaleBrandValidator.validateName,
            ),
            AppSpacing.gapSm,
          ],
        ),
      ),
    );
  }
}
