import 'dart:async';

import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pos/core/models/base_get_list_response_model.dart';
import 'package:pos/core/utils/scaffold_message_utils.dart';
import 'package:pos/core/widgets/confirm_delete_dialog.dart';
import 'package:pos/features/manage_sale_brands/data/datasources/sale_brand_data_source.dart';
import 'package:pos/features/manage_sale_brands/data/models/sale_brand_model.dart';
import 'package:pos/features/manage_sale_categories/data/datasources/sale_category_data_source.dart';
import 'package:pos/features/manage_sale_categories/data/models/sale_category_model.dart';

import '../../domain/entities/sale_item.dart';
import '../../domain/usecases/delete_sale_item_use_case.dart';
import '../../domain/usecases/get_sale_items_use_case.dart';

class SaleItemListController extends GetxController {
  final GetSaleItemsUseCase _getSaleItemsUseCase;
  final DeleteSaleItemUseCase _deleteSaleItemUseCase;
  final SaleCategoryDataSource _categoryDataSource;
  final SaleBrandDataSource _brandDataSource;

  SaleItemListController(
    this._getSaleItemsUseCase,
    this._deleteSaleItemUseCase,
    this._categoryDataSource,
    this._brandDataSource,
  );

  final PagingController<int, SaleItem> pagingController =
      PagingController(firstPageKey: 1);

  static const _pageSize = 10;

  // Filter States
  final RxString searchQuery = ''.obs;
  final RxnInt selectedCategoryId = RxnInt();
  final RxnInt selectedBrandId = RxnInt();
  final RxnBool selectedIsActive = RxnBool();

  // Dropdown States
  final RxList<SaleCategoryModel> categories = <SaleCategoryModel>[].obs;
  final RxList<SaleBrandModel> brands = <SaleBrandModel>[].obs;

  Worker? _searchWorker;

  @override
  void onInit() {
    super.onInit();
    _loadDropdownData();

    pagingController.addPageRequestListener((pageKey) {
      loadSaleItems(pageKey);
    });

    _searchWorker = debounce(searchQuery, (_) {
      pagingController.refresh();
    }, time: const Duration(milliseconds: 500));
  }

  Future<void> _loadDropdownData() async {
    try {
      final fetchedCategories = await _categoryDataSource
          .getSaleCategories(filters: {'paginate': false});
      categories.assignAll(fetchedCategories);

      final fetchedBrands =
          await _brandDataSource.getSaleBrands(filters: {'paginate': false});
      brands.assignAll(fetchedBrands);
    } catch (e) {
      // Ignored non-critical dropdown filter load errors
    }
  }

  Future<void> loadSaleItems(int pageKey) async {
    try {
      final filters = {
        'page': pageKey,
        'per_page': _pageSize,
        'limit': _pageSize,
        if (searchQuery.value.trim().isNotEmpty)
          'search': searchQuery.value.trim(),
        if (selectedCategoryId.value != null)
          'category_id': selectedCategoryId.value,
        if (selectedBrandId.value != null) 'brand_id': selectedBrandId.value,
        if (selectedIsActive.value != null)
          'is_active': selectedIsActive.value! ? 1 : 0,
      };

      final result = await _getSaleItemsUseCase.execute(filters: filters);
      if (isClosed) return;
      pagingController.appendPageResult(
        newItems: result,
        currentPageKey: pageKey,
        defaultPageSize: _pageSize,
        idSelector: (item) => item.id,
      );
    } catch (error) {
      if (isClosed) return;
      pagingController.error = error;
    }
  }

  void applyFilters() {
    pagingController.refresh();
  }

  void resetFilters() {
    searchQuery.value = '';
    selectedCategoryId.value = null;
    selectedBrandId.value = null;
    selectedIsActive.value = null;
    pagingController.refresh();
  }

  Future<void> confirmAndDelete(int id) async {
    showConfirmDeleteDialog(
      title: 'Delete Sale Item',
      message:
          'Are you sure you want to delete this sale item? This action cannot be undone.',
      onConfirm: () async {
        await _deleteSaleItem(id);
      },
    );
  }

  Future<void> _deleteSaleItem(int id) async {
    try {
      final message = await _deleteSaleItemUseCase.execute(id);
      pagingController.refresh();
      ScaffoldMessageUtils.showSuccess(message);
    } catch (error) {
      ScaffoldMessageUtils.showError(
          'Failed to delete item: ${error.toString()}');
    }
  }

  void refreshList() {
    pagingController.refresh();
  }

  @override
  void onClose() {
    _searchWorker?.dispose();
    pagingController.dispose();
    super.onClose();
  }
}
