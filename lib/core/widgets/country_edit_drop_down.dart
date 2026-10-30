import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pos/features/manage_customers/presentation/controllers/customer_edit_controller.dart';
import 'package:pos/core/models/country_model.dart';
import 'package:pos/core/theme/custome_drop_down_decoration.dart';

class CountryEditDropDown extends GetView<CustomerEditController> {
  final List<CountryModel> countries;
  final int? initialValue;
  final Function(int) onChanged;

  const CountryEditDropDown({
    super.key,
    required this.countries,
    required this.initialValue,
    required this.onChanged,
  });

  Future<List<CountryModel>> _getCountryData(String query) async {
    return await Future.delayed(
      const Duration(milliseconds: 500),
      () {
        return countries.where(
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
      items: countries,
      hintText: 'Select Country',
      initialItem: initialValue != null
          ? countries.firstWhereOrNull(
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
