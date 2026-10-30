import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:pos/core/models/base_get_list_response_model.dart';
import 'package:pos/core/utils/scaffold_message_utils.dart';
import 'package:pos/core/utils/snack_bar_utils.dart';
import 'package:pos/core/widgets/confirm_delete_dialog.dart';

import '../../domain/entities/sale_category.dart';
import '../../domain/usecases/create_sale_category_use_case.dart';
import '../../domain/usecases/delete_sale_category_use_case.dart';
import '../../domain/usecases/get_sale_categories_use_case.dart';
import '../../domain/usecases/update_sale_category_use_case.dart';

class SaleCategoryListController extends GetxController {
  final GetSaleCategoriesUseCase getSaleCategoriesUseCase;
  final CreateSaleCategoryUseCase createSaleCategoryUseCase;
  final UpdateSaleCategoryUseCase updateSaleCategoryUseCase;
  final DeleteSaleCategoryUseCase deleteSaleCategoryUseCase;

  SaleCategoryListController({
    required this.getSaleCategoriesUseCase,
    required this.createSaleCategoryUseCase,
    required this.updateSaleCategoryUseCase,
    required this.deleteSaleCategoryUseCase,
  });

  final PagingController<int, SaleCategory> pagingController =
      PagingController(firstPageKey: 1);

  static const _pageSize = 10;

  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();

  // Form State
  final RxBool isSaving = false.obs;
  final formKey = GlobalKey<FormState>();
  late final TextEditingController nameController;
  late final TextEditingController descController;
  SaleCategory? editingItem;

  Worker? _searchWorker;

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    descController = TextEditingController();

    pagingController.addPageRequestListener((pageKey) {
      loadSaleCategories(pageKey);
    });

    _searchWorker = debounce(searchQuery, (_) {
      pagingController.refresh();
    }, time: const Duration(milliseconds: 500));
  }

  void openForm([SaleCategory? item]) {
    editingItem = item;
    if (item != null) {
      nameController.text = item.name;
      descController.text = item.description;
    } else {
      nameController.clear();
      descController.clear();
    }
  }

  Future<void> loadSaleCategories(int pageKey) async {
    try {
      final query = searchQuery.value.trim();
      final filters = {
        'page': pageKey,
        'per_page': _pageSize,
        if (query.isNotEmpty) 'search': query,
      };

      final result = await getSaleCategoriesUseCase.execute(filters: filters);
      if (isClosed) return;
      pagingController.appendPageResult(
        newItems: result,
        currentPageKey: pageKey,
        defaultPageSize: _pageSize,
        idSelector: (c) => c.id,
      );
    } catch (error) {
      if (isClosed) return;
      pagingController.error = error;
    }
  }

  Future<void> addSaleCategory(String name, String description) async {
    try {
      isSaving.value = true;
      final saleCategory =
          SaleCategory(id: 0, name: name, description: description);
      final result = await createSaleCategoryUseCase.execute(saleCategory);
      pagingController.refresh();
      ScaffoldMessageUtils.showSuccess(result);
      Get.back();
    } catch (error) {
      SnackbarUtils.showPersistentError(error.toString());
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> updateSaleCategory(
      int id, String name, String description) async {
    try {
      isSaving.value = true;
      final saleCategory =
          SaleCategory(id: id, name: name, description: description);
      final result =
          await updateSaleCategoryUseCase.execute(id, saleCategory);
      pagingController.refresh();
      ScaffoldMessageUtils.showSuccess(result);
      Get.back();
    } catch (error) {
      SnackbarUtils.showPersistentError(error.toString());
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> confirmAndDelete(int id) async {
    showConfirmDeleteDialog(
      title: 'Delete Sale Category',
      message:
          'Are you sure you want to delete this sale category? This action cannot be undone.',
      onConfirm: () async {
        await _deleteSaleCategory(id);
      },
    );
  }

  Future<void> _deleteSaleCategory(int id) async {
    try {
      final result = await deleteSaleCategoryUseCase.execute(id);
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
