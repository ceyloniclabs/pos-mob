import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:pos/features/manage_sale_categories/data/models/sale_category_model.dart';
import 'package:pos/core/theme/custome_drop_down_decoration.dart';

class SaleCategoryDropDown extends StatelessWidget {
  final int? initialValue;
  final List<SaleCategoryModel> saleCategoryList;
  final ValueChanged<SaleCategoryModel?> onChanged;
  final String? Function(SaleCategoryModel?)? validator;

  const SaleCategoryDropDown({
    super.key,
    this.initialValue,
    required this.saleCategoryList,
    required this.onChanged,
    this.validator,
  });

  Future<List<SaleCategoryModel>> _getSaleCategoryData(String query) async {
    return await Future.delayed(
      const Duration(milliseconds: 500),
      () {
        return saleCategoryList.where(
          (category) {
            return category.name.toLowerCase().contains(
                  query.toLowerCase(),
                );
          },
        ).toList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SaleCategoryModel? initialCategory;
    if (initialValue != null) {
      initialCategory = saleCategoryList.firstWhereOrNull(
        (category) => category.id == initialValue,
      );
    }

    return CustomDropdown<SaleCategoryModel>.searchRequest(
      futureRequest: _getSaleCategoryData,
      items: saleCategoryList,
      hintText: 'Select Sale Category',
      initialItem: initialCategory,
      onChanged: onChanged,
      validator: validator,
      decoration: buildCustomDropdownDecoration(context),
      disabledDecoration: buildCustomDropdownDisabledDecoration(context),
    );
  }
}
