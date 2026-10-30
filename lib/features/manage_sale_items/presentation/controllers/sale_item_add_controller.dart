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
import '../../domain/usecases/create_sale_item_use_case.dart';

class SaleItemAddController extends GetxController {
  final CreateSaleItemUseCase _createSaleItemUseCase;
  final SaleBrandDataSource _brandDataSource;
  final SaleCategoryDataSource _saleCategoryService;
  final SaleSubCategoryDataSource _saleSubCategoryService;

  SaleItemAddController(
    this._createSaleItemUseCase,
    this._brandDataSource,
    this._saleCategoryService,
    this._saleSubCategoryService,
  );

  final formKey = GlobalKey<FormState>();

  final RxBool isSaving = false.obs;

  // Dropdown lists
  final RxList<SaleBrandModel> brands = <SaleBrandModel>[].obs;
  final RxList<SaleCategoryModel> categories = <SaleCategoryModel>[].obs;
  final RxList<SaleSubCategoryModel> subcategories =
      <SaleSubCategoryModel>[].obs;

  // Form controllers
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final buyingPriceController = TextEditingController();
  final sellingPriceController = TextEditingController();
  final stockQuantityController = TextEditingController();

  final Rx<int?> selectedBrandId = Rx<int?>(null);
  final Rx<int?> selectedCategoryId = Rx<int?>(null);
  final Rx<int?> selectedSubcategoryId = Rx<int?>(null);
  final RxBool isActive = true.obs;

  final RxList<String> selectedPhotosPaths = <String>[].obs;

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
    selectedCategoryId.value = categoryId;
    selectedBrandId.value = null;
    selectedSubcategoryId.value = null;
  }

  @override
  void onInit() {
    super.onInit();
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
        selectedPhotosPaths.assignAll(images.map((e) => e.path));
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        SnackbarUtils.showError('Failed to pick images: $e');
      });
    }
  }

  void removePhoto(int index) {
    selectedPhotosPaths.removeAt(index);
  }

  Future<void> addSaleItem() async {
    if (formKey.currentState!.validate()) {
      isSaving.value = true;
      try {
        final buyingPrice =
            double.tryParse(buyingPriceController.text.trim()) ?? 0.0;
        final sellingPrice =
            double.tryParse(sellingPriceController.text.trim()) ?? 0.0;
        final stockQty = int.tryParse(stockQuantityController.text.trim()) ?? 0;

        final saleItem = SaleItem(
          id: 0,
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
          photos: [],
        );

        final imageFiles = selectedPhotosPaths
            .map((path) => File(path))
            .toList();

        final message = await _createSaleItemUseCase.execute(
          saleItem,
          imageFiles,
        );
        ScaffoldMessageUtils.showSuccess(message);
        Get.back();
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
