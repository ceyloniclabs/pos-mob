import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pos/core/utils/scaffold_message_utils.dart';
import 'package:pos/core/utils/snack_bar_utils.dart';
import 'package:pos/features/manage_sale_brands/data/datasources/sale_brand_data_source.dart';
import 'package:pos/features/manage_sale_brands/data/models/sale_brand_model.dart';
import 'package:pos/features/manage_sale_categories/data/datasources/sale_category_data_source.dart';
import 'package:pos/features/manage_sale_categories/data/models/sale_category_model.dart';
import 'package:pos/features/manage_sale_sub_categories/data/datasources/sale_sub_category_data_source.dart';
import 'package:pos/features/manage_sale_sub_categories/data/models/sale_sub_category_model.dart';

import '../../domain/entities/sale_item.dart';
import '../../domain/usecases/update_sale_item_use_case.dart';

class SaleItemEditController extends GetxController {
  final UpdateSaleItemUseCase _updateSaleItemUseCase;
  final SaleBrandDataSource _brandDataSource;
  final SaleCategoryDataSource _saleCategoryService;
  final SaleSubCategoryDataSource _saleSubCategoryService;

  SaleItemEditController(
    this._updateSaleItemUseCase,
    this._brandDataSource,
    this._saleCategoryService,
    this._saleSubCategoryService,
  );

  late final SaleItem initialItem;

  final formKey = GlobalKey<FormState>();
  final RxBool isSaving = false.obs;

  // Dropdown lists
  final RxList<SaleBrandModel> brands = <SaleBrandModel>[].obs;
  final RxList<SaleCategoryModel> categories = <SaleCategoryModel>[].obs;
  final RxList<SaleSubCategoryModel> subcategories =
      <SaleSubCategoryModel>[].obs;

  // Form controllers
  late final TextEditingController nameController;
  late final TextEditingController descriptionController;
  late final TextEditingController buyingPriceController;
  late final TextEditingController sellingPriceController;
  late final TextEditingController stockQuantityController;

  final Rx<int?> selectedBrandId = Rx<int?>(null);
  final Rx<int?> selectedCategoryId = Rx<int?>(null);
  final Rx<int?> selectedSubcategoryId = Rx<int?>(null);
  final RxBool isActive = true.obs;

  final RxList<String> existingPhotos = <String>[].obs;
  final RxList<String> newPhotosPaths = <String>[].obs;

  List<SaleBrandModel> get filteredBrands {
    if (selectedCategoryId.value == null) return [];
    return brands
        .where((b) => b.saleCategoryId == selectedCategoryId.value)
        .toList();
  }

  List<SaleSubCategoryModel> get filteredSubcategories {
    if (selectedCategoryId.value == null) return [];
    return subcategories
        .where((s) => s.saleCategoryId == selectedCategoryId.value)
        .toList();
  }

  void onCategoryChanged(int? categoryId) {
    if (selectedCategoryId.value == categoryId) return;
    selectedCategoryId.value = categoryId;
    selectedBrandId.value = null;
    selectedSubcategoryId.value = null;
  }

  @override
  void onInit() {
    super.onInit();
    initialItem = Get.arguments as SaleItem;

    nameController = TextEditingController(text: initialItem.name);
    descriptionController = TextEditingController(
      text: initialItem.description ?? '',
    );
    buyingPriceController = TextEditingController(
      text: initialItem.buyingPrice.toString(),
    );
    sellingPriceController = TextEditingController(
      text: initialItem.sellingPrice.toString(),
    );
    stockQuantityController = TextEditingController(
      text: initialItem.stockQuantity.toString(),
    );

    selectedBrandId.value = initialItem.brandId;
    selectedCategoryId.value = initialItem.categoryId;
    selectedSubcategoryId.value = initialItem.subcategoryId;
    isActive.value = initialItem.isActive;
    existingPhotos.assignAll(initialItem.photos);

    loadDropdownData();
  }

  Future<void> loadDropdownData() async {
    try {
      final fetchedBrands = await _brandDataSource.getSaleBrands(
        filters: {'paginate': false},
      );
      brands.assignAll(fetchedBrands);

      final fetchedCategories = await _saleCategoryService.getSaleCategories(
        filters: {'paginate': false},
      );
      categories.assignAll(fetchedCategories);

      final fetchedSubcategories = await _saleSubCategoryService
          .getSaleSubCategories(filters: {'paginate': false});
      subcategories.assignAll(fetchedSubcategories);
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        SnackbarUtils.showPersistentError('Failed to load form data: $e');
      });
    }
  }

  Future<void> pickPhotos() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage(imageQuality: 50);
      if (images.isNotEmpty) {
        newPhotosPaths.addAll(images.map((e) => e.path));
      }
    } catch (e) {
      SnackbarUtils.showError('Failed to pick images: $e');
    }
  }

  void removeNewPhoto(int index) {
    newPhotosPaths.removeAt(index);
  }

  Future<void> updateSaleItem() async {
    if (formKey.currentState!.validate()) {
      isSaving.value = true;
      try {
        final buyingPrice =
            double.tryParse(buyingPriceController.text.trim()) ?? 0.0;
        final sellingPrice =
            double.tryParse(sellingPriceController.text.trim()) ?? 0.0;
        final stockQty = int.tryParse(stockQuantityController.text.trim()) ?? 0;

        final updatedSaleItem = initialItem.copyWith(
          brandId: selectedBrandId.value!,
          categoryId: selectedCategoryId.value!,
          subcategoryId: selectedSubcategoryId.value,
          name: nameController.text.trim(),
          description: descriptionController.text.trim().isNotEmpty
              ? descriptionController.text.trim()
              : null,
          buyingPrice: buyingPrice,
          sellingPrice: sellingPrice,
          stockQuantity: stockQty,
          isActive: isActive.value,
        );

        final newImageFiles = newPhotosPaths.map((path) => File(path)).toList();

        final message = await _updateSaleItemUseCase.execute(
          initialItem.id,
          updatedSaleItem,
          newImageFiles,
        );
        ScaffoldMessageUtils.showSuccess(message);
        Get.back(result: true);
      } catch (e) {
        SnackbarUtils.showPersistentError(e.toString());
      } finally {
        isSaving.value = false;
      }
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    buyingPriceController.dispose();
    sellingPriceController.dispose();
    stockQuantityController.dispose();
    super.onClose();
  }
}
