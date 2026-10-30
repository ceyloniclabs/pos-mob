import 'dart:convert';
import 'dart:developer';
import 'dart:math' hide log;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:pos/core/controllers/persistent_data_controller.dart';
import 'package:pos/core/enums.dart';
import 'package:pos/core/models/base_get_list_response_model.dart';
import 'package:pos/core/services/qr_scanner/qr_payload.dart';
import 'package:pos/core/utils/app_date_time_utils.dart';
import 'package:pos/core/utils/scaffold_message_utils.dart';
import 'package:pos/features/auth/presentation/controllers/auth_controller.dart';
import 'package:pos/features/manage_customers/domain/entities/customer.dart';
import 'package:pos/features/manage_sale_categories/data/datasources/sale_category_data_source_factory.dart';
import 'package:pos/features/manage_sale_items/domain/entities/sale_item.dart';
import 'package:pos/features/manage_sales/domain/entities/sale.dart';
import 'package:pos/features/manage_sales/domain/usecases/create_sale_use_case.dart';
import 'package:pos/features/manage_sales/domain/usecases/get_sale_customers_use_case.dart';
import 'package:pos/features/manage_sales/domain/usecases/get_sale_items_use_case.dart';
import 'package:pos/features/manage_sales/domain/usecases/update_sale_use_case.dart';
import 'package:pos/features/manage_sales/domain/validators/sale_validator.dart';
import 'package:pos/core/network/api_service.dart';
import 'package:pos/core/routes/app_pages.dart';
import 'package:pos/features/main/presentation/controllers/main_controller.dart';
import 'package:pos/features/manage_sales/presentation/controllers/sale_controller.dart';
import '../bindings/sale_pos_scanner_binding.dart';
import '../models/sale_cart_item.dart';
import '../pages/sale_pos_scanner_view.dart';
import '../../data/models/sale_model.dart';

export '../models/sale_cart_item.dart';

/// Real-time feedback model for live POS QR item scanning.
class SaleScanFeedback {
  final bool isSuccess;
  final String message;
  final SaleItem? product;
  final String? itemName;
  final double? price;
  final int? inCartQty;
  final DateTime timestamp;

  SaleScanFeedback({
    required this.isSuccess,
    required this.message,
    this.product,
    this.itemName,
    this.price,
    this.inCartQty,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class SaleCreateController extends GetxController {
  final GetSaleCustomersUseCase getSaleCustomersUseCase;
  final GetSaleItemsUseCase getSaleItemsUseCase;
  final CreateSaleUseCase createSaleUseCase;
  final UpdateSaleUseCase updateSaleUseCase;
  final AuthController authController;

  SaleCreateController({
    required this.getSaleCustomersUseCase,
    required this.getSaleItemsUseCase,
    required this.createSaleUseCase,
    required this.updateSaleUseCase,
    required this.authController,
  });

  // Edit mode tracking
  final Rxn<int> editingSaleId = Rxn<int>();
  bool get isEditMode => editingSaleId.value != null;
  Sale? _pendingEditSale;

  String get shopCurrency {
    if (Get.isRegistered<PersistentDataController>()) {
      return PersistentDataController.to.currency;
    }
    return 'USD';
  }

  // Form selections
  final Rx<Customer?> selectedCustomer = Rx<Customer?>(null);
  void setCustomer(Customer? customer) => selectedCustomer.value = customer;
  final RxList<Customer> customers = <Customer>[].obs;
  final RxBool isCustomersLoading = false.obs;
  final RxString customerSearchQuery = ''.obs;

  final RxString saleStatus = 'completed'.obs; // POS default is completed
  final RxString paymentMethod = 'cash'.obs;

  // Products
  final PagingController<int, SaleItem> productsPagingController =
      PagingController(
        firstPageKey: 1,
        invisibleItemsThreshold: 1,
      );
  static const int _productPageSize = 10;
  final RxList<String> dynamicCategories = <String>[].obs;
  Worker? _searchWorker;
  Worker? _categoryWorker;
  Worker? _customerSearchWorker;

  final RxList<SaleItem> availableSaleItems = <SaleItem>[].obs;
  final RxBool isProductsLoading = false.obs;
  final RxList<SaleCreateItemEntry> addedItems = <SaleCreateItemEntry>[].obs;

  // Catalog Filter & Search for Fast POS
  final RxString searchQuery = ''.obs;
  final Rxn<String> selectedCategory = Rxn<String>();
  final TextEditingController searchController = TextEditingController();
  final RxBool isGridView = true.obs;

  // Live POS Continuous QR Scanner
  final Rxn<SaleScanFeedback> scanFeedback = Rxn<SaleScanFeedback>();

  // Form Controllers
  final TextEditingController notesController = TextEditingController();
  final TextEditingController discountAmountController =
      TextEditingController();
  final RxString discountType = 'fixed'.obs; // 'fixed' or 'percent'

  final TextEditingController promoCodeController = TextEditingController();
  final RxDouble appliedPromoPercent = 0.0.obs;
  final RxString appliedPromoCode = ''.obs;
  final Rxn<int> appliedPromoCodeId = Rxn<int>();
  final RxBool isApplyingPromo = false.obs;

  final TextEditingController voucherCodeController = TextEditingController();
  final RxDouble appliedVoucherDeduction = 0.0.obs;
  final RxString appliedVoucherCode = ''.obs;
  final Rxn<int> appliedVoucherId = Rxn<int>();
  final RxBool isApplyingVoucher = false.obs;

  // Cash Calculator & External Card Terminal Controllers
  final TextEditingController amountReceivedController =
      TextEditingController();
  final TextEditingController transactionRefController = TextEditingController();
  final RxDouble amountReceivedValue = 0.0.obs;

  final RxBool isSubmitting = false.obs;
  final RxBool isSubmittingDraft = false.obs;
  final RxBool isSubmittingComplete = false.obs;

  // Wizard Flow Step Management (kept for backward compatibility)
  final RxInt currentStep = 0.obs;

  // --- Fast POS Catalog & Cart Helpers ---

  List<String> get availableCategories {
    final catSet = <String>{...dynamicCategories};
    for (final item in availableSaleItems) {
      if (item.categoryName != null && item.categoryName!.trim().isNotEmpty) {
        catSet.add(item.categoryName!.trim());
      }
    }
    final categories = catSet.toList();
    categories.sort();
    return categories;
  }

  List<SaleItem> get filteredSaleItems {
    final query = searchQuery.value.trim().toLowerCase();
    final cat = selectedCategory.value;

    return availableSaleItems.where((item) {
      if (!item.isActive) return false;
      if (item.stockQuantity <= 0) return false;
      final matchesSearch = query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          (item.brandName != null &&
              item.brandName!.toLowerCase().contains(query));
      final matchesCat = cat == null || item.categoryName == cat;
      return matchesSearch && matchesCat;
    }).toList();
  }

  List<Customer> get filteredCustomers {
    final query = customerSearchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return customers;
    return customers
        .where((c) =>
            c.name.toLowerCase().contains(query) ||
            c.phone.toLowerCase().contains(query))
        .toList();
  }

  int getItemCartQuantity(int productId) {
    final match =
        addedItems.firstWhereOrNull((item) => item.product.id == productId);
    return match?.quantity ?? 0;
  }

  void incrementProduct(SaleItem product) {
    addProduct(product, 1, product.sellingPrice);
  }

  void decrementProduct(SaleItem product) {
    final index =
        addedItems.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      if (addedItems[index].quantity > 1) {
        updateItemQuantity(index, addedItems[index].quantity - 1);
      } else {
        removeProduct(index);
      }
    }
  }

  /// Opens the continuous QR scanner for rapid multi-item POS entry
  void openContinuousQrScanner() {
    scanFeedback.value = null;
    Get.to(
      () => const SalePosScannerView(),
      binding: SalePosScannerBinding(),
      routeName: Routes.SALE_QR_SCANNER,
    );
  }

  /// Validates and adds a product to the cart from a scanned QR payload string
  bool scanAndAddProduct(String rawCode) {
    try {
      int? itemId;

      // 1. Attempt standard QrPayload JSON format: {"table": "sale_items", "id": 12}
      try {
        final payload = QrPayload.fromString(rawCode);
        if (payload.table.toLowerCase() != 'sale_items') {
          scanFeedback.value = SaleScanFeedback(
            isSuccess: false,
            message: 'Not a retail item QR (Table: "${payload.table}")',
          );
          HapticFeedback.heavyImpact();
          return false;
        }
        itemId = payload.id;
      } catch (_) {
        // Fallback: If raw text is directly a numeric ID
        final directId = int.tryParse(rawCode.trim());
        if (directId != null && directId > 0) {
          itemId = directId;
        }
      }

      if (itemId == null) {
        scanFeedback.value = SaleScanFeedback(
          isSuccess: false,
          message: 'Invalid QR format. Could not resolve item ID.',
        );
        HapticFeedback.heavyImpact();
        return false;
      }

      // 2. Locate product in loaded inventory catalog
      final product =
          availableSaleItems.firstWhereOrNull((item) => item.id == itemId);
      if (product == null) {
        scanFeedback.value = SaleScanFeedback(
          isSuccess: false,
          message: 'Item #$itemId not found in catalog.',
        );
        HapticFeedback.heavyImpact();
        return false;
      }

      // 3. Status validation
      if (!product.isActive) {
        scanFeedback.value = SaleScanFeedback(
          isSuccess: false,
          message: '${product.name} is inactive and cannot be sold.',
        );
        HapticFeedback.heavyImpact();
        return false;
      }

      // 4. Stock validation
      if (product.stockQuantity <= 0) {
        scanFeedback.value = SaleScanFeedback(
          isSuccess: false,
          message: '${product.name} is out of stock (Stock: 0).',
        );
        HapticFeedback.heavyImpact();
        return false;
      }

      // 5. Cart ceiling vs inventory check
      final currentInCart = getItemCartQuantity(product.id);
      if (currentInCart >= product.stockQuantity) {
        scanFeedback.value = SaleScanFeedback(
          isSuccess: false,
          message:
              'Max stock reached. Only ${product.stockQuantity} available.',
          itemName: product.name,
          inCartQty: currentInCart,
        );
        HapticFeedback.heavyImpact();
        return false;
      }

      // 6. Success: Increment into cart using core cart state
      incrementProduct(product);
      HapticFeedback.mediumImpact();

      final newQty = currentInCart + 1;
      scanFeedback.value = SaleScanFeedback(
        isSuccess: true,
        message: 'Added to cart!',
        product: product,
        itemName: product.name,
        price: product.sellingPrice,
        inCartQty: newQty,
      );
      return true;
    } catch (e) {
      scanFeedback.value = SaleScanFeedback(
        isSuccess: false,
        message: 'Scan error: $e',
      );
      HapticFeedback.heavyImpact();
      return false;
    }
  }

  /// Increments the quantity of the last scanned product directly from the scanner screen
  void incrementFeedbackProduct() {
    final feedback = scanFeedback.value;
    if (feedback != null && feedback.product != null) {
      final product = feedback.product!;
      final currentInCart = getItemCartQuantity(product.id);
      if (currentInCart >= product.stockQuantity) {
        scanFeedback.value = SaleScanFeedback(
          isSuccess: false,
          message: 'Max stock reached. Only ${product.stockQuantity} available.',
          product: product,
          itemName: product.name,
          inCartQty: currentInCart,
        );
        HapticFeedback.heavyImpact();
        return;
      }
      incrementProduct(product);
      HapticFeedback.mediumImpact();
      scanFeedback.value = SaleScanFeedback(
        isSuccess: true,
        message: 'Quantity increased',
        product: product,
        itemName: product.name,
        price: product.sellingPrice,
        inCartQty: currentInCart + 1,
      );
    }
  }

  /// Decrements the quantity of the last scanned product directly from the scanner screen
  void decrementFeedbackProduct() {
    final feedback = scanFeedback.value;
    if (feedback != null && feedback.product != null) {
      final product = feedback.product!;
      final currentInCart = getItemCartQuantity(product.id);
      if (currentInCart > 0) {
        decrementProduct(product);
        HapticFeedback.lightImpact();
        final newInCart = getItemCartQuantity(product.id);
        scanFeedback.value = SaleScanFeedback(
          isSuccess: true,
          message: newInCart > 0 ? 'Quantity decreased' : 'Removed from cart',
          product: product,
          itemName: product.name,
          price: product.sellingPrice,
          inCartQty: newInCart,
        );
      }
    }
  }

  int get totalCartItemCount =>
      addedItems.fold(0, (sum, item) => sum + item.quantity);

  void setExactCash() {
    amountReceivedController.text = grandTotal.toStringAsFixed(2);
    updateAmountReceived(grandTotal.toStringAsFixed(2));
  }

  void setPresetCash(double amount) {
    amountReceivedController.text = amount.toStringAsFixed(2);
    updateAmountReceived(amount.toStringAsFixed(2));
  }

  List<double> get quickCashPresets {
    if (grandTotal <= 0) return const [];
    final current = grandTotal;
    final presets = <double>[current];

    final standardNotes = [100.0, 500.0, 1000.0, 2000.0, 5000.0, 10000.0];
    for (final note in standardNotes) {
      if (note > current && !presets.contains(note)) {
        presets.add(note);
      }
    }
    return presets.take(4).toList();
  }

  bool nextStep() {
    if (currentStep.value == 0) {
      currentStep.value = 1;
      return true;
    } else if (currentStep.value == 1) {
      final itemsError = SaleValidator.validateItems(addedItems);
      if (itemsError != null) {
        ScaffoldMessageUtils.showError(itemsError);
        return false;
      }
      currentStep.value = 2;
      return true;
    }
    return false;
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  void goToStep(int step) {
    if (step == 2 && addedItems.isEmpty) {
      ScaffoldMessageUtils.showError(
          'Please add at least one product before proceeding to checkout');
      return;
    }
    currentStep.value = step;
  }

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is Sale) {
      initForEdit(Get.arguments as Sale);
    }
    loadCustomers();
    loadSaleItems();

    productsPagingController.addPageRequestListener((pageKey) {
      loadSaleItemsPage(pageKey);
    });

    _searchWorker = debounce(searchQuery, (_) {
      productsPagingController.refresh();
    }, time: const Duration(milliseconds: 350));

    _customerSearchWorker = debounce(customerSearchQuery, (query) {
      loadCustomers(search: query);
    }, time: const Duration(milliseconds: 350));

    _categoryWorker = ever(selectedCategory, (_) {
      productsPagingController.refresh();
    });

    _loadCategories();
  }

  void initForEdit(Sale sale) {
    editingSaleId.value = sale.id;
    _pendingEditSale = sale;
    saleStatus.value = sale.saleStatus;
    paymentMethod.value = sale.paymentMethod;
    notesController.text = sale.notes ?? '';
    if (sale.discountAmount > 0) {
      discountAmountController.text = sale.discountAmount.toStringAsFixed(2);
    } else {
      discountAmountController.clear();
    }
    promoCodeController.text = sale.promoCode ?? '';
    appliedPromoCodeId.value = sale.promoCodeId;
    if (promoCodeController.text.isNotEmpty) {
      // Automatically validate promo code to fetch the percentage and apply the discount
      applyPromo();
    }
    
    // Assign the already applied gift voucher amount from the pending sale
    appliedVoucherId.value = sale.giftVoucherId;
    appliedVoucherDeduction.value = sale.giftVoucherAmount;
    if (sale.giftVoucher != null) {
      appliedVoucherCode.value = sale.giftVoucher!.code;
      voucherCodeController.text = sale.giftVoucher!.code;
    }

    if (sale.amountPaid != null && sale.amountPaid! > 0) {
      amountReceivedController.text = sale.amountPaid!.toStringAsFixed(2);
      amountReceivedValue.value = sale.amountPaid!;
    }

    if (sale.transactionId != null) {
      if (sale.transactionId!.startsWith('CASH_REC:')) {
        final recMatch =
            RegExp(r'CASH_REC:([0-9.]+)').firstMatch(sale.transactionId!);
        if (recMatch != null && amountReceivedValue.value == 0.0) {
          final amt = double.tryParse(recMatch.group(1)!) ?? 0.0;
          amountReceivedController.text = amt.toStringAsFixed(2);
          amountReceivedValue.value = amt;
        }
      } else {
        transactionRefController.text = sale.transactionId!;
      }
    }

    final loadedItems = <SaleCreateItemEntry>[];
    for (final entry in sale.saleItemEntries) {
      final product = SaleCartProduct(
        id: entry.saleItemId,
        name: entry.saleItem?.name.isNotEmpty == true
            ? entry.saleItem!.name
            : 'Item #${entry.saleItemId}',
        stockQuantity: entry.saleItem?.stockQuantity ?? 100,
        sellingPrice: entry.pricePerUnit,
      );
      loadedItems.add(
        SaleCreateItemEntry(
          product: product,
          quantity: entry.quantity,
          pricePerUnit: entry.pricePerUnit,
        ),
      );
    }
    addedItems.assignAll(loadedItems);
  }

  Future<void> loadCustomers({String? search}) async {
    try {
      isCustomersLoading.value = true;
      final filters = <String, dynamic>{
        'per_page': 100,
      };
      if (search != null && search.trim().isNotEmpty) {
        filters['search'] = search.trim();
      }
      final result = await getSaleCustomersUseCase.execute(filters: filters);
      customers.assignAll(result);

      if (_pendingEditSale?.customerId != null) {
        final match = customers.firstWhereOrNull(
          (c) => c.id == _pendingEditSale!.customerId,
        );
        if (match != null) {
          selectedCustomer.value = match;
        }
      }
    } catch (e) {
      ScaffoldMessageUtils.showError('Failed to load customers: $e');
    } finally {
      isCustomersLoading.value = false;
    }
  }

  Future<void> loadSaleItems({String? search, String? category}) async {
    try {
      isProductsLoading.value = true;
      final filters = <String, dynamic>{
        'per_page': 100,
      };
      if (search != null && search.trim().isNotEmpty) {
        filters['search'] = search.trim();
      }
      if (category != null && category.trim().isNotEmpty) {
        filters['category'] = category.trim();
      }
      final result = await getSaleItemsUseCase.execute(filters: filters);
      availableSaleItems.assignAll(result);
    } catch (e) {
      ScaffoldMessageUtils.showError('Failed to load sale items: $e');
    } finally {
      isProductsLoading.value = false;
    }
  }

  Future<void> loadSaleItemsPage(int pageKey) async {
    try {
      final filters = <String, dynamic>{
        'page': pageKey,
        'per_page': _productPageSize,
        'is_active': 1,
      };
      if (searchQuery.value.trim().isNotEmpty) {
        filters['search'] = searchQuery.value.trim();
      }
      if (selectedCategory.value != null &&
          selectedCategory.value!.trim().isNotEmpty) {
        filters['category'] = selectedCategory.value!.trim();
      }

      final result = await getSaleItemsUseCase.execute(filters: filters);
      if (isClosed) return;

      productsPagingController.appendPageResult(
        newItems: result,
        currentPageKey: pageKey,
        defaultPageSize: _productPageSize,
        idSelector: (item) => item.id,
      );

      for (final item in result) {
        final existingIdx = availableSaleItems.indexWhere((e) => e.id == item.id);
        if (existingIdx >= 0) {
          availableSaleItems[existingIdx] = item;
        } else {
          availableSaleItems.add(item);
        }
      }
    } catch (e) {
      if (isClosed) return;
      productsPagingController.error = e;
    }
  }

  Future<void> _loadCategories() async {
    try {
      final ds =
          SaleCategoryDataSourceFactory.create(BackendProviderType.laravel);
      final categories = await ds.getSaleCategories();
      final names = categories
          .map((c) => c.name.trim())
          .where((n) => n.isNotEmpty)
          .toSet()
          .toList();
      names.sort();
      dynamicCategories.assignAll(names);
    } catch (_) {
      // Fallback silently if categories endpoint fails
    }
  }

  void addProduct(SaleItem product, int quantity, double price) {
    final existingIndex =
        addedItems.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      addedItems[existingIndex].quantity += quantity;
      addedItems[existingIndex].pricePerUnit = price;
      addedItems.refresh();
    } else {
      addedItems.add(
        SaleCreateItemEntry(
          product: SaleCartProduct.fromSaleItem(product),
          quantity: quantity,
          pricePerUnit: price,
        ),
      );
    }
  }

  void updateItemQuantity(int index, int quantity) {
    if (index >= 0 && index < addedItems.length) {
      if (quantity <= 0) {
        removeProduct(index);
      } else {
        addedItems[index].quantity = quantity;
        addedItems.refresh();
      }
    }
  }

  void removeProduct(int index) {
    if (index >= 0 && index < addedItems.length) {
      addedItems.removeAt(index);
    }
  }

  double get subtotal =>
      addedItems.fold(0.0, (sum, item) => sum + item.lineTotal);

  double get manualDiscountValue =>
      double.tryParse(discountAmountController.text.trim()) ?? 0.0;

  double get discountDeduction {
    if (discountType.value == 'percent') {
      return subtotal * (manualDiscountValue / 100);
    }
    return manualDiscountValue;
  }

  void setDiscountType(String type) {
    if (discountType.value != type) {
      discountType.value = type;
      discountAmountController.clear();
      addedItems.refresh();
    }
  }

  double get promoDeduction =>
      subtotal * (appliedPromoPercent.value / 100);

  double get effectiveVoucherDeduction {
    final remaining = max(0.0, subtotal - discountDeduction - promoDeduction);
    return min(remaining, appliedVoucherDeduction.value);
  }

  double get grandTotal {
    final total = subtotal -
        discountDeduction -
        promoDeduction -
        effectiveVoucherDeduction;
    return max(0.0, total);
  }

  double get amountReceived {
    return amountReceivedValue.value;
  }

  double get returnChange {
    final diff = amountReceived - grandTotal;
    return diff > 0 ? diff : 0.0;
  }

  void updateAmountReceived(String text) {
    final val = double.tryParse(text.trim()) ?? 0.0;
    amountReceivedValue.value = val;
  }

  Future<void> applyPromo() async {
    final code = promoCodeController.text.trim();
    if (code.isEmpty) return;

    try {
      isApplyingPromo.value = true;
      final response = await ApiService().postRequest(
        'promo-codes/validate',
        data: {'code': code},
      );
      
      if (response['success'] == true) {
        final data = response['data'];
        appliedPromoPercent.value = (data['sales_percentage'] as num).toDouble();
        appliedPromoCode.value = code;
        appliedPromoCodeId.value =
            data['id'] != null ? int.tryParse(data['id'].toString()) : null;
        ScaffoldMessageUtils.showSuccess(response['message'] ?? 'Promo code applied!');
      } else {
        ScaffoldMessageUtils.showError(response['message'] ?? 'Invalid promo code');
      }
    } catch (e) {
      ScaffoldMessageUtils.showError(e.toString());
    } finally {
      isApplyingPromo.value = false;
    }
  }

  void removePromo() {
    appliedPromoPercent.value = 0.0;
    appliedPromoCode.value = '';
    appliedPromoCodeId.value = null;
    promoCodeController.clear();
  }

  Future<void> applyVoucher() async {
    final code = voucherCodeController.text.trim();
    if (code.isEmpty) return;

    try {
      isApplyingVoucher.value = true;
      final response = await ApiService().postRequest(
        'gift-vouchers/validate',
        data: {'code': code},
      );
      
      if (response['success'] == true) {
        final data = response['data'];
        final balance = (data['balance'] as num).toDouble();
        appliedVoucherDeduction.value = balance;
        appliedVoucherCode.value = code;
        appliedVoucherId.value =
            data['id'] != null ? int.tryParse(data['id'].toString()) : null;
        ScaffoldMessageUtils.showSuccess(response['message'] ?? 'Gift voucher applied!');
      } else {
        ScaffoldMessageUtils.showError(response['message'] ?? 'Invalid gift voucher');
      }
    } catch (e) {
      ScaffoldMessageUtils.showError(e.toString());
    } finally {
      isApplyingVoucher.value = false;
    }
  }

  void removeVoucher() {
    appliedVoucherDeduction.value = 0.0;
    appliedVoucherCode.value = '';
    appliedVoucherId.value = null;
    voucherCodeController.clear();
  }

  void resetForm() {
    currentStep.value = 0;
    selectedCustomer.value = null;
    customerSearchQuery.value = '';
    saleStatus.value = 'completed';
    paymentMethod.value = 'cash';
    addedItems.clear();
    searchController.clear();
    searchQuery.value = '';
    selectedCategory.value = null;
    notesController.clear();
    discountAmountController.clear();
    discountType.value = 'fixed';
    promoCodeController.clear();
    appliedPromoPercent.value = 0.0;
    appliedPromoCode.value = '';
    appliedPromoCodeId.value = null;
    voucherCodeController.clear();
    appliedVoucherDeduction.value = 0.0;
    appliedVoucherCode.value = '';
    appliedVoucherId.value = null;
    amountReceivedController.clear();
    amountReceivedValue.value = 0.0;
    transactionRefController.clear();
    editingSaleId.value = null;
    _pendingEditSale = null;
  }

  Future<void> submitSale({bool isDraft = false}) async {
    if (isSubmitting.value) return;
    isSubmitting.value = true;
    if (isDraft) {
      isSubmittingDraft.value = true;
    } else {
      isSubmittingComplete.value = true;
    }

    try {
      final itemsError = SaleValidator.validateItems(addedItems);
      if (itemsError != null) {
        ScaffoldMessageUtils.showError(itemsError);
        return;
      }

      final discountError =
          SaleValidator.validateDiscount(discountDeduction, subtotal);
      if (discountError != null) {
        ScaffoldMessageUtils.showError(discountError);
        return;
      }

      if (saleStatus.value == 'completed' && paymentMethod.value == 'cash') {
        final cashError = SaleValidator.validateCashAmountReceived(
          amountReceived,
          grandTotal,
          currency: shopCurrency,
        );
        if (cashError != null) {
          ScaffoldMessageUtils.showError(cashError);
          return;
        }
      }

      // Resolve staff ID from injected AuthController
      int staffId = 1;
      final user = authController.user.value;
      if (user != null) {
        staffId = int.tryParse(user.id) ?? int.tryParse(user.uid) ?? 1;
      }

      final staffError = SaleValidator.validateStaffId(staffId);
      if (staffError != null) {
        ScaffoldMessageUtils.showError(staffError);
        return;
      }

      // Format sale date as YYYY-MM-DD in UTC
      final now = DateTime.now();
      final saleDate = AppDateTimeUtils.toUtcDateOnly(now)!;

      final dateError = SaleValidator.validateSaleDate(saleDate);
      if (dateError != null) {
        ScaffoldMessageUtils.showError(dateError);
        return;
      }

      // Transaction ID reference (used for card payment)
      String? txId;
      if (paymentMethod.value == 'card') {
        if (transactionRefController.text.trim().isNotEmpty) {
          txId = transactionRefController.text.trim();
        }
      }

      // Calculate amount paid and change
      final double calculatedAmountPaid;
      final double calculatedChangeAmount;
      if (paymentMethod.value == 'cash') {
        calculatedAmountPaid = amountReceived > 0 ? amountReceived : grandTotal;
        calculatedChangeAmount = returnChange;
      } else {
        calculatedAmountPaid = grandTotal;
        calculatedChangeAmount = 0.0;
      }

      // Build typed Sale domain entity â€” no raw Map in controller
      final saleEntity = Sale(
        id: editingSaleId.value ?? 0,
        customerId: selectedCustomer.value?.id,
        staffId: staffId,
        saleDate: saleDate,
        saleStatus: saleStatus.value,
        paymentMethod: paymentMethod.value,
        transactionId: txId,
        notes: notesController.text.trim(),
        totalAmount: grandTotal,
        discountAmount: discountDeduction,
        promoCode: promoCodeController.text.trim().isNotEmpty
            ? promoCodeController.text.trim()
            : null,
        promoCodeId: appliedPromoCodeId.value,
        promoCodeDiscount: promoDeduction,
        giftVoucherId: appliedVoucherId.value,
        giftVoucherAmount: effectiveVoucherDeduction,
        amountPaid: calculatedAmountPaid,
        changeAmount: calculatedChangeAmount,
        saleItemEntries: addedItems
            .map(
              (e) => SaleItemEntry(
                id: 0,
                saleId: editingSaleId.value ?? 0,
                saleItemId: e.product.id,
                quantity: e.quantity,
                pricePerUnit: e.pricePerUnit,
                lineTotal: e.lineTotal,
              ),
            )
            .toList(),
      );

      final salePayload = SaleModel.fromEntity(saleEntity).toJson();
      log(const JsonEncoder.withIndent('  ').convert(salePayload), name: 'SALE_PAYLOAD');

      final String message;
      if (isEditMode) {
        message =
            await updateSaleUseCase.execute(editingSaleId.value!, saleEntity);
      } else {
        message = await createSaleUseCase.execute(saleEntity);
      }

      ScaffoldMessageUtils.showSuccess(message);

      Get.until((route) => route.settings.name == Routes.MAIN || route.isFirst);
      if (Get.isRegistered<MainController>()) {
        Get.find<MainController>().changePage(2);
      }
      if (Get.isRegistered<SaleController>()) {
        Get.find<SaleController>().pagingController.refresh();
      }
    } catch (e) {
      ScaffoldMessageUtils.showError(
          'Failed to ${isEditMode ? 'update' : 'create'} sale: $e');
    } finally {
      isSubmittingDraft.value = false;
      isSubmittingComplete.value = false;
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    _searchWorker?.dispose();
    _categoryWorker?.dispose();
    _customerSearchWorker?.dispose();
    productsPagingController.dispose();
    searchController.dispose();
    notesController.dispose();
    discountAmountController.dispose();
    promoCodeController.dispose();
    voucherCodeController.dispose();
    amountReceivedController.dispose();
    transactionRefController.dispose();
    super.onClose();
  }
}
