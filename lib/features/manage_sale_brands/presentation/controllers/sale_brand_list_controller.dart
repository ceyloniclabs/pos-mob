import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:pos/core/models/base_get_list_response_model.dart';
import 'package:pos/core/utils/scaffold_message_utils.dart';
import 'package:pos/core/utils/snack_bar_utils.dart';
import 'package:pos/core/widgets/confirm_delete_dialog.dart';

import 'package:pos/features/manage_sale_categories/data/models/sale_category_model.dart';
import 'package:pos/features/manage_sale_categories/domain/usecases/get_sale_categories_use_case.dart';

import '../../domain/entities/sale_brand.dart';
import '../../domain/usecases/create_sale_brand_use_case.dart';
import '../../domain/usecases/delete_sale_brand_use_case.dart';
import '../../domain/usecases/get_sale_brands_use_case.dart';
import '../../domain/usecases/update_sale_brand_use_case.dart';

class SaleBrandListController extends GetxController {
  final GetSaleBrandsUseCase getSaleBrandsUseCase;
  final CreateSaleBrandUseCase createSaleBrandUseCase;
  final UpdateSaleBrandUseCase updateSaleBrandUseCase;
  final DeleteSaleBrandUseCase deleteSaleBrandUseCase;
  final GetSaleCategoriesUseCase getSaleCategoriesUseCase;

  SaleBrandListController({
    required this.getSaleBrandsUseCase,
    required this.createSaleBrandUseCase,
    required this.updateSaleBrandUseCase,
    required this.deleteSaleBrandUseCase,
    required this.getSaleCategoriesUseCase,
  });

  final PagingController<int, SaleBrand> pagingController =
      PagingController(firstPageKey: 1);

  static const _pageSize = 10;

  final RxString searchQuery = ''.obs;

  // Form State
  final RxBool isSaving = false.obs;
  final formKey = GlobalKey<FormState>();
  late final TextEditingController nameController;
  int selectedSaleCategory = -1;
  SaleBrand? editingItem;

  final RxList<SaleCategoryModel> saleCategoryList = <SaleCategoryModel>[].obs;
  RxInt selectedFilterCategoryId = (-1).obs;

  Worker? _searchWorker;

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();

    pagingController.addPageRequestListener((pageKey) {
      loadSaleBrands(pageKey);
    });

    _searchWorker = debounce(searchQuery, (_) {
      pagingController.refresh();
    }, time: const Duration(milliseconds: 500));

    loadSaleCategories();
  }

  Future<void> loadSaleCategories() async {
    final categories = await getSaleCategoriesUseCase.execute();
    saleCategoryList.assignAll(
      categories.map((e) => SaleCategoryModel.fromEntity(e)).toList(),
    );
  }

  void openForm([SaleBrand? item]) {
    editingItem = item;
    if (item != null) {
      nameController.text = item.name;
      selectedSaleCategory = item.saleCategoryId;
    } else {
      nameController.clear();
      selectedSaleCategory = -1;
    }
  }

  Future<void> loadSaleBrands(int page) async {
    try {
      final filters = {
        'page': page,
        'paginate': 'true',
        'per_page': _pageSize,
        'limit': _pageSize,
        if (searchQuery.value.isNotEmpty) 'search': searchQuery.value,
        if (selectedFilterCategoryId.value > 0)
          'sale_category_id': selectedFilterCategoryId.value,
      };

      final result = await getSaleBrandsUseCase.execute(filters: filters);
      if (isClosed) return;
      pagingController.appendPageResult(
        newItems: result,
        currentPageKey: page,
        defaultPageSize: _pageSize,
        idSelector: (b) => b.id,
      );
    } catch (error) {
      if (isClosed) return;
      pagingController.error = error;
    }
  }

  Future<bool> addSaleBrand(String name, int saleCategoryId) async {
    try {
      isSaving.value = true;
      final brand = SaleBrand(
        id: 0,
        name: name,
        saleCategoryId: saleCategoryId,
      );
      final result = await createSaleBrandUseCase.execute(brand);
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

  Future<bool> updateSaleBrand(int id, String name, int saleCategoryId) async {
    try {
      isSaving.value = true;
      final brand = SaleBrand(
        id: id,
        name: name,
        saleCategoryId: saleCategoryId,
      );
      final result = await updateSaleBrandUseCase.execute(id, brand);
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
      title: 'Delete Sale Brand',
      message:
          'Are you sure you want to delete this sale brand? This action cannot be undone.',
      onConfirm: () async {
        await _deleteSaleBrand(id);
      },
    );
  }

  Future<void> _deleteSaleBrand(int id) async {
    try {
      final result = await deleteSaleBrandUseCase.execute(id);
      pagingController.refresh();
      ScaffoldMessageUtils.showSuccess(result);
    } catch (error) {
      SnackbarUtils.showPersistentError(error.toString());
    }
  }

  @override
  void onClose() {
    _searchWorker?.dispose();
    nameController.dispose();
    pagingController.dispose();
    super.onClose();
  }
}
