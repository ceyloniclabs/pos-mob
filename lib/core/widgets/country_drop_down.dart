import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pos/core/models/country_model.dart';
import 'package:pos/core/theme/custome_drop_down_decoration.dart';
import 'package:pos/features/manage_customers/presentation/controllers/customer_add_controller.dart';

class CountryDropDown extends GetView<CustomerAddController> {
  final int? initialValue;

  const CountryDropDown({
    super.key,
    this.initialValue,
  });

  Future<List<CountryModel>> _getCountryData(String query) async {
    return await Future.delayed(
      const Duration(milliseconds: 500),
      () {
        return controller.countries.where(
          (country) {
            return country.name.toLowerCase().contains(
                  query.toLowerCase(),
                );
          },
        ).toList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomDropdown<CountryModel>.searchRequest(
      futureRequest: _getCountryData,
      items: controller.countries,
      hintText: 'Select Country',
      initialItem: initialValue != null
          ? controller.countries.firstWhereOrNull(
              (country) => country.id == initialValue,
            )
          : null,
      onChanged: (value) {
        if (value != null) {
          controller.selectedCountryId.value = value.id;
        }
      },
      validator: (value) => value == null ? 'Country is required' : null,
      decoration: buildCustomDropdownDecoration(context),
      disabledDecoration: buildCustomDropdownDisabledDecoration(context),
      closedHeaderPadding: EdgeInsets.all(10.w),
      expandedHeaderPadding: EdgeInsets.all(10.w),
    );
  }
}
