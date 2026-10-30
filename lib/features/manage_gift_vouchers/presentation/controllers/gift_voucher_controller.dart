import 'package:pos/core/controllers/persistent_data_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pos/core/enums.dart';
import 'package:pos/core/utils/scaffold_message_utils.dart';
import 'package:pos/core/widgets/confirm_delete_dialog.dart';

import '../../domain/entities/gift_voucher.dart';
import '../../domain/usecases/create_gift_voucher_use_case.dart';
import '../../domain/usecases/delete_gift_voucher_use_case.dart';
import '../../domain/usecases/get_gift_voucher_by_id_use_case.dart';
import '../../domain/usecases/get_gift_vouchers_use_case.dart';
import '../../domain/usecases/update_gift_voucher_use_case.dart';

class GiftVoucherController extends GetxController {
  final GetGiftVouchersUseCase getGiftVouchersUseCase;
  final GetGiftVoucherByIdUseCase getGiftVoucherByIdUseCase;
  final CreateGiftVoucherUseCase createGiftVoucherUseCase;
  final UpdateGiftVoucherUseCase updateGiftVoucherUseCase;
  final DeleteGiftVoucherUseCase deleteGiftVoucherUseCase;

  GiftVoucherController({
    required this.getGiftVouchersUseCase,
    required this.getGiftVoucherByIdUseCase,
    required this.createGiftVoucherUseCase,
    required this.updateGiftVoucherUseCase,
    required this.deleteGiftVoucherUseCase,
  });

  // 1. Reactive states
  final RxList<GiftVoucher> giftVouchers = <GiftVoucher>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();
  final Rx<GiftVoucherStatus> selectedStatus = GiftVoucherStatus.all.obs;

  // Form states
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController ownerController = TextEditingController();
  final TextEditingController initialAmountController = TextEditingController();
  final TextEditingController balanceController = TextEditingController();
  final TextEditingController currencyController = TextEditingController(text: Get.isRegistered<PersistentDataController>() ? PersistentDataController.to.currency : 'USD');
  final TextEditingController expireDateController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final Rx<DateTime?> selectedExpireDate = Rx<DateTime?>(null);
  final RxBool isActiveForm = true.obs;

  List<GiftVoucher> get filteredGiftVouchers {
    List<GiftVoucher> list = giftVouchers.toList();
    if (searchQuery.value.trim().isNotEmpty) {
      final q = searchQuery.value.trim().toLowerCase();
      list = list.where((v) {
        return v.code.toLowerCase().contains(q) ||
            v.owner.toLowerCase().contains(q) ||
            (v.description?.toLowerCase().contains(q) ?? false);
      }).toList();
    }
    if (selectedStatus.value != GiftVoucherStatus.all) {
      final active = selectedStatus.value == GiftVoucherStatus.active;
      list = list.where((v) => v.isActive == active).toList();
    }
    // Sort by id descending
    list.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
    return list;
  }

  @override
  void onInit() {
    super.onInit();
    debounce(
      searchQuery,
      (_) => fetchGiftVouchers(),
      time: const Duration(milliseconds: 500),
    );
    fetchGiftVouchers();
  }

  void initForm([GiftVoucher? voucher]) {
    if (voucher != null) {
      codeController.text = voucher.code;
      ownerController.text = voucher.owner;
      initialAmountController.text = voucher.initialAmount.toStringAsFixed(2);
      balanceController.text = voucher.balance.toStringAsFixed(2);
      currencyController.text = voucher.currency;
      selectedExpireDate.value = voucher.expireDate;
      expireDateController.text = DateFormat('yyyy-MM-dd').format(voucher.expireDate);
      descriptionController.text = voucher.description ?? '';
      isActiveForm.value = voucher.isActive;
    } else {
      codeController.clear();
      ownerController.clear();
      initialAmountController.clear();
      balanceController.clear();
      currencyController.text = Get.isRegistered<PersistentDataController>() ? PersistentDataController.to.currency : 'USD';
      selectedExpireDate.value = null;
      expireDateController.clear();
      descriptionController.clear();
      isActiveForm.value = true;
    }
  }

  Future<void> fetchGiftVouchers() async {
    try {
      isLoading.value = true;
      final data = await getGiftVouchersUseCase.execute(
        search: searchQuery.value,
        status: selectedStatus.value.value,
      );
      giftVouchers.assignAll(data);
    } catch (e) {
      ScaffoldMessageUtils.showError('Failed to load gift vouchers: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    fetchGiftVouchers();
  }

  void resetFilters() {
    selectedStatus.value = GiftVoucherStatus.all;
    searchQuery.value = '';
    searchController.clear();
  }

  void confirmAndDelete(GiftVoucher voucher) {
    showConfirmDeleteDialog(
      title: 'Delete Gift Voucher',
      message:
          'Are you sure you want to delete voucher "${voucher.code}"? This action cannot be undone.',
      onConfirm: () => deleteGiftVoucher(voucher),
    );
  }

  Future<bool> createGiftVoucher() async {
    if (!formKey.currentState!.validate()) return false;
    if (selectedExpireDate.value == null) {
      ScaffoldMessageUtils.showError('Please select an expire date');
      return false;
    }

    try {
      isSaving.value = true;
      final initialAmount = double.parse(initialAmountController.text.trim());
      final balance = balanceController.text.trim().isNotEmpty
          ? double.tryParse(balanceController.text.trim()) ?? initialAmount
          : initialAmount;

      final newVoucher = GiftVoucher(
        code: codeController.text.trim(),
        owner: ownerController.text.trim(),
        initialAmount: initialAmount,
        balance: balance,
        expireDate: selectedExpireDate.value!,
        description: descriptionController.text.trim().isNotEmpty
            ? descriptionController.text.trim()
            : null,
        currency: currencyController.text.trim().isNotEmpty
            ? currencyController.text.trim()
            : (Get.isRegistered<PersistentDataController>() ? PersistentDataController.to.currency : 'USD'),
        isActive: isActiveForm.value,
      );

      final created = await createGiftVoucherUseCase.execute(newVoucher);
      giftVouchers.insert(0, created);
      ScaffoldMessageUtils.showSuccess('Gift voucher created successfully');
      return true;
    } catch (e) {
      ScaffoldMessageUtils.showError('Failed to create gift voucher: ${e.toString()}');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> updateGiftVoucher(GiftVoucher existing) async {
    if (!formKey.currentState!.validate()) return false;
    if (selectedExpireDate.value == null) {
      ScaffoldMessageUtils.showError('Please select an expire date');
      return false;
    }

    try {
      isSaving.value = true;
      final initialAmount = double.parse(initialAmountController.text.trim());
      final balance = balanceController.text.trim().isNotEmpty
          ? double.tryParse(balanceController.text.trim()) ?? initialAmount
          : initialAmount;

      final updatedVoucher = existing.copyWith(
        code: codeController.text.trim(),
        owner: ownerController.text.trim(),
        initialAmount: initialAmount,
        balance: balance,
        expireDate: selectedExpireDate.value!,
        description: descriptionController.text.trim().isNotEmpty
            ? descriptionController.text.trim()
            : null,
        currency: currencyController.text.trim().isNotEmpty
            ? currencyController.text.trim()
            : (Get.isRegistered<PersistentDataController>() ? PersistentDataController.to.currency : 'USD'),
        isActive: isActiveForm.value,
      );

      final result = await updateGiftVoucherUseCase.execute(updatedVoucher);
      final index = giftVouchers.indexWhere((e) => e.id == existing.id);
      if (index != -1) {
        giftVouchers[index] = result;
      }
      ScaffoldMessageUtils.showSuccess('Gift voucher updated successfully');
      return true;
    } catch (e) {
      ScaffoldMessageUtils.showError('Failed to update gift voucher: ${e.toString()}');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteGiftVoucher(GiftVoucher voucher) async {
    if (voucher.id == null) return;
    try {
      await deleteGiftVoucherUseCase.execute(voucher.id!);
      giftVouchers.removeWhere((e) => e.id == voucher.id);
      ScaffoldMessageUtils.showSuccess('Gift voucher deleted successfully');
    } catch (e) {
      ScaffoldMessageUtils.showError('Failed to delete gift voucher: ${e.toString()}');
    }
  }

  Future<void> toggleStatus(GiftVoucher voucher) async {
    try {
      final updated = voucher.copyWith(isActive: !voucher.isActive);
      final result = await updateGiftVoucherUseCase.execute(updated);
      final index = giftVouchers.indexWhere((e) => e.id == voucher.id);
      if (index != -1) {
        giftVouchers[index] = result;
      }
      ScaffoldMessageUtils.showSuccess('Status updated successfully');
    } catch (e) {
      ScaffoldMessageUtils.showError('Failed to update status: ${e.toString()}');
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    codeController.dispose();
    ownerController.dispose();
    initialAmountController.dispose();
    balanceController.dispose();
    currencyController.dispose();
    expireDateController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
