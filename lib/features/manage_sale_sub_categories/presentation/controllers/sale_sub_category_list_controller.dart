import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:pos/core/models/base_get_list_response_model.dart';
import 'package:pos/core/utils/app_logger.dart';
import 'package:pos/core/utils/scaffold_message_utils.dart';
import 'package:pos/core/utils/snack_bar_utils.dart';
import 'package:pos/core/widgets/confirm_delete_dialog.dart';

import 'package:pos/features/manage_sale_categories/domain/usecases/get_sale_categories_use_case.dart';
import 'package:pos/features/manage_sale_categories/data/models/sale_category_model.dart';

import '../../domain/entities/sale_sub_category.dart';
import '../../domain/usecases/create_sale_sub_category_use_case.dart';
import '../../domain/usecases/delete_sale_sub_category_use_case.dart';
import '../../domain/usecases/get_sale_sub_categories_use_case.dart';
import '../../domain/usecases/update_sale_sub_category_use_case.dart';

class SaleSubCategoryListController extends GetxController {
  final GetSaleSubCategoriesUseCase getSaleSubCategoriesUseCase;
  final CreateSaleSubCategoryUseCase createSaleSubCategoryUseCase;
  final UpdateSaleSubCategoryUseCase updateSaleSubCategoryUseCase;
  final DeleteSaleSubCategoryUseCase deleteSaleSubCategoryUseCase;
  final GetSaleCategoriesUseCase getSaleCategoriesUseCase;

  SaleSubCategoryListController({
    required this.getSaleSubCategoriesUseCase,
    required this.createSaleSubCategoryUseCase,
    required this.updateSaleSubCategoryUseCase,
    required this.deleteSaleSubCategoryUseCase,
    required this.getSaleCategoriesUseCase,
  });

  final PagingController<int, SaleSubCategory> pagingController =
      PagingController(firstPageKey: 1, invisibleItemsThreshold: 1);

  static const _pageSize = 10;

  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();

  // Form State
  final RxBool isSaving = false.obs;
  final formKey = GlobalKey<FormState>();
  late final TextEditingController nameController;
  late final TextEditingController descController;
  int selectedSaleCategory = -1;
  SaleSubCategory? editingItem;

  final RxList<SaleCategoryModel> saleCategoryList = <SaleCategoryModel>[].obs;

  Worker? _searchWorker;

  RxInt selectedFilterCategoryId = (-1).obs;

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  void resetFilters() {
    searchController.clear();
    searchQuery.value = '';
    selectedFilterCategoryId.value = -1;
  }

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    descController = TextEditingController();

    pagingController.addPageRequestListener((pageKey) {
      loadSaleSubCategories(pageKey);
    });

    _searchWorker = debounce(searchQuery, (_) {
      pagingController.refresh();
    }, time: const Duration(milliseconds: 500));

    loadSaleCategories();
  }

  Future<void> loadSaleCategories() async {
    final categories = await getSaleCategoriesUseCase.execute(
      filters: const {'per_page': 100},
    );
    saleCategoryList.assignAll(
      categories.map((e) => SaleCategoryModel.fromEntity(e)).toList(),
    );
  }

  void openForm([SaleSubCategory? item]) {
    editingItem = item;
    if (item != null) {
      nameController.text = item.name;
      descController.text = item.description;
      selectedSaleCategory = item.saleCategoryId;
    } else {
      nameController.clear();
      descController.clear();
      selectedSaleCategory = -1;
    }
  }

  Future<void> loadSaleSubCategories(int pageKey) async {
    try {
      final query = searchQuery.value.trim();
      final filters = {
        'page': pageKey,
        'per_page': _pageSize,
        if (query.isNotEmpty) 'search': query,
        if (selectedFilterCategoryId.value > 0)
          'sale_category_id': selectedFilterCategoryId.value,
      };

      AppLogger.info('>>> [SaleSubCategory API Call] Fetching Page $pageKey with: $filters');

      final result =
          await getSaleSubCategoriesUseCase.execute(filters: filters);
      if (isClosed) return;

      AppLogger.info('<<< [SaleSubCategory API Response] Page $pageKey returned ${result.length} items');

      pagingController.appendPageResult(
        newItems: result,
        currentPageKey: pageKey,
        defaultPageSize: _pageSize,
        idSelector: (s) => s.id,
      );

      AppLogger.info('=== [SaleSubCategory List] Total items now loaded in memory: ${pagingController.itemList?.length}');
    } catch (error) {
      if (isClosed) return;
      pagingController.error = error;
    }
  }

  Future<bool> addSaleSubCategory(
    String name,
    int saleCategoryId,
    String? description,
  ) async {
    try {
      isSaving.value = true;
      final saleSubCategory = SaleSubCategory(
        id: 0,
        name: name,
        saleCategoryId: saleCategoryId,
        description: description ?? '',
      );
      final result =
          await createSaleSubCategoryUseCase.execute(saleSubCategory);
      pagingController.refresh();
      ScaffoldMessageUtils.showSuccess(result);
      return true;
    } catch (error) {
      SnackbarUtils.showPersistentError(error.toString());
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> updateSaleSubCategory(
    int id,
    String name,
    int saleCategoryId,
    String? description,
  ) async {
    try {
      isSaving.value = true;
      final saleSubCategory = SaleSubCategory(
        id: id,
        name: name,
        saleCategoryId: saleCategoryId,
        description: description ?? '',
      );
      final result =
          await updateSaleSubCategoryUseCase.execute(id, saleSubCategory);
      pagingController.refresh();
      ScaffoldMessageUtils.showSuccess(result);
      return true;
    } catch (error) {
      SnackbarUtils.showPersistentError(error.toString());
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> confirmAndDelete(int id) async {
    showConfirmDeleteDialog(
      title: 'Delete Sale Sub Category',
      message:
          'Are you sure you want to delete this sale sub category? This action cannot be undone.',
      onConfirm: () async {
        await _deleteSaleSubCategory(id);
      },
    );
  }

  Future<void> _deleteSaleSubCategory(int id) async {
    try {
      final result = await deleteSaleSubCategoryUseCase.execute(id);
      pagingController.refresh();
      ScaffoldMessageUtils.showSuccess(result);
    } catch (error) {
      SnackbarUtils.showPersistentError(error.toString());
    }
  }

  @override
  void onClose() {
    _searchWorker?.dispose();
    searchController.dispose();
    nameController.dispose();
    descController.dispose();
    pagingController.dispose();
    super.onClose();
  }
}
