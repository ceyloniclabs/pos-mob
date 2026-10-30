import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pos/core/theme/custome_drop_down_decoration.dart';

class CommonSearchableDropdown<T> extends StatelessWidget {
  final List<T>? items;
  final String hintText;
  final String? searchHintText;
  final T? initialItem;
  final Future<List<T>> Function(String)? futureRequest;
  final PaginatedSearchRequest<T>? paginatedRequest;
  final int pageSize;
  final void Function(T?) onChanged;
  final String Function(T)? itemToString;
  final String? Function(T?)? validator;
  final Widget Function(BuildContext, T, bool)? headerBuilder;
  final Widget Function(BuildContext, T, bool, void Function())? listItemBuilder;
  final bool enabled;
  final bool canClearSelection;
  final bool excludeSelected;
  final Widget? loadMoreIndicator;
  final CustomDropdownDecoration? decoration;
  final CustomDropdownDisabledDecoration? disabledDecoration;

  const CommonSearchableDropdown({
    super.key,
    this.items,
    required this.hintText,
    this.searchHintText,
    this.futureRequest,
    this.paginatedRequest,
    this.pageSize = 10,
    required this.onChanged,
    this.itemToString,
    this.initialItem,
    this.validator,
    this.headerBuilder,
    this.listItemBuilder,
    this.enabled = true,
    this.canClearSelection = false,
    this.excludeSelected = true,
    this.loadMoreIndicator,
    this.decoration,
    this.disabledDecoration,
  }) : assert(
          (futureRequest == null) != (paginatedRequest == null),
          'Provide exactly one of futureRequest or paginatedRequest',
        );

  @override
  Widget build(BuildContext context) {
    if (paginatedRequest != null) {
      return CustomDropdown<T>.searchRequest(
        paginatedRequest: paginatedRequest,
        pageSize: pageSize,
        items: items,
        hintText: hintText,
        searchHintText: searchHintText,
        initialItem: initialItem,
        onChanged: onChanged,
        enabled: enabled,
        canClearSelection: canClearSelection,
        excludeSelected: excludeSelected,
        headerBuilder: headerBuilder,
        listItemBuilder: listItemBuilder,
        loadMoreIndicator: loadMoreIndicator ??
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.0),
                ),
              ),
            ),
        decoration: decoration ?? buildCustomDropdownDecoration(context),
        disabledDecoration:
            disabledDecoration ?? buildCustomDropdownDisabledDecoration(context),
        closedHeaderPadding: EdgeInsets.all(10.w),
        expandedHeaderPadding: EdgeInsets.all(10.w),
        validator: validator,
      );
    }

    return CustomDropdown<T>.searchRequest(
      futureRequest: futureRequest,
      items: items,
      hintText: hintText,
      searchHintText: searchHintText,
      initialItem: initialItem,
      onChanged: onChanged,
      enabled: enabled,
      canClearSelection: canClearSelection,
      excludeSelected: excludeSelected,
      headerBuilder: headerBuilder,
      listItemBuilder: listItemBuilder,
      decoration: decoration ?? buildCustomDropdownDecoration(context),
      disabledDecoration:
          disabledDecoration ?? buildCustomDropdownDisabledDecoration(context),
      closedHeaderPadding: EdgeInsets.all(10.w),
      expandedHeaderPadding: EdgeInsets.all(10.w),
      validator: validator,
    );
  }
}
