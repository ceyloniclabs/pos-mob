import 'package:get/get.dart';
import 'package:pos/core/routes/app_pages.dart';
import 'package:pos/core/utils/scaffold_message_utils.dart';
import 'package:pos/core/widgets/confirm_delete_dialog.dart';

import '../../domain/entities/sale_item.dart';
import '../../domain/usecases/delete_sale_item_use_case.dart';
import '../../domain/usecases/get_sale_item_by_id_use_case.dart';

class SaleItemDetailController extends GetxController {
  final DeleteSaleItemUseCase _deleteSaleItemUseCase;
  final GetSaleItemByIdUseCase _getSaleItemByIdUseCase;

  SaleItemDetailController(
    this._deleteSaleItemUseCase,
    this._getSaleItemByIdUseCase,
  );

  final Rx<SaleItem?> saleItem = Rx<SaleItem?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is SaleItem) {
      saleItem.value = args;
      refreshSaleItem();
    } else if (args is int) {
      fetchSaleItemDetails(args);
    }
  }

  Future<void> fetchSaleItemDetails(int id) async {
    isLoading.value = true;
    try {
      final item = await _getSaleItemByIdUseCase.execute(id);
      saleItem.value = item;
    } catch (e) {
      ScaffoldMessageUtils.showError(
          'Failed to load sale item details: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshSaleItem() async {
    final itemId = saleItem.value?.id;
    if (itemId == null) return;
    try {
      final updatedItem = await _getSaleItemByIdUseCase.execute(itemId);
      saleItem.value = updatedItem;
    } catch (e) {
      ScaffoldMessageUtils.showError(
          'Failed to refresh sale item: ${e.toString()}');
    }
  }

  void goToEdit() async {
    if (saleItem.value == null) return;
    final result = await Get.toNamed(
      Routes.SALE_ITEM_EDIT,
      arguments: saleItem.value,
    );
    if (result == true) {
      refreshSaleItem();
    }
  }

  Future<void> confirmAndDelete() async {
    if (saleItem.value == null) return;
    showConfirmDeleteDialog(
      title: 'Delete Sale Item',
      message:
          'Are you sure you want to delete this sale item? This action cannot be undone.',
      onConfirm: () async {
        await _deleteSaleItem();
      },
    );
  }

  Future<void> _deleteSaleItem() async {
    if (saleItem.value == null) return;
    try {
      final result = await _deleteSaleItemUseCase.execute(saleItem.value!.id);
      ScaffoldMessageUtils.showSuccess(result);
      Get.back(result: true);
    } catch (e) {
      ScaffoldMessageUtils.showError(
          'Failed to delete sale item: ${e.toString()}');
    }
  }
}
