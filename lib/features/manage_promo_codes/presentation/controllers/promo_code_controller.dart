import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pos/core/enums.dart';
import 'package:pos/core/utils/scaffold_message_utils.dart';
import '../../../../core/widgets/confirm_delete_dialog.dart';

import '../../domain/entities/promo_code.dart';
import '../../domain/usecases/create_promo_code_use_case.dart';
import '../../domain/usecases/delete_promo_code_use_case.dart';
import '../../domain/usecases/get_promo_code_by_id_use_case.dart';
import '../../domain/usecases/get_promo_codes_use_case.dart';
import '../../domain/usecases/update_promo_code_use_case.dart';

class PromoCodeController extends GetxController {
  final GetPromoCodesUseCase getPromoCodesUseCase;
  final GetPromoCodeByIdUseCase getPromoCodeByIdUseCase;
  final CreatePromoCodeUseCase createPromoCodeUseCase;
  final UpdatePromoCodeUseCase updatePromoCodeUseCase;
  final DeletePromoCodeUseCase deletePromoCodeUseCase;

  PromoCodeController({
    required this.getPromoCodesUseCase,
    required this.getPromoCodeByIdUseCase,
    required this.createPromoCodeUseCase,
    required this.updatePromoCodeUseCase,
    required this.deletePromoCodeUseCase,
  });

  // Reactive states
  final RxList<PromoCode> promoCodes = <PromoCode>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();
  final Rx<PromoCodeStatus> selectedStatus = PromoCodeStatus.all.obs;

  // Form states
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController referralController = TextEditingController();
  final TextEditingController salesPercentageController = TextEditingController();
  final TextEditingController rentalPercentageController = TextEditingController();
  final TextEditingController expireDateController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final Rx<DateTime?> selectedExpireDate = Rx<DateTime?>(null);
  final RxBool isActiveForm = true.obs;

  List<PromoCode> get filteredPromoCodes {
    List<PromoCode> list = promoCodes.toList();
    if (searchQuery.value.trim().isNotEmpty) {
      final q = searchQuery.value.trim().toLowerCase();
      list = list.where((p) {
        return p.code.toLowerCase().contains(q) ||
            p.referral.toLowerCase().contains(q) ||
            (p.description?.toLowerCase().contains(q) ?? false);
      }).toList();
    }
    if (selectedStatus.value != PromoCodeStatus.all) {
      final active = selectedStatus.value == PromoCodeStatus.active;
      list = list.where((p) => p.isActive == active).toList();
    }
    list.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
    return list;
  }

  @override
  void onInit() {
    super.onInit();
    debounce(
      searchQuery,
      (_) => fetchPromoCodes(),
      time: const Duration(milliseconds: 500),
    );
    fetchPromoCodes();
  }

  void initForm([PromoCode? promoCode]) {
    if (promoCode != null) {
      codeController.text = promoCode.code;
      referralController.text = promoCode.referral;
      salesPercentageController.text = promoCode.salesPercentage.toStringAsFixed(2);
      rentalPercentageController.text = promoCode.rentalPercentage.toStringAsFixed(2);
      selectedExpireDate.value = promoCode.expireDate;
      expireDateController.text = DateFormat('yyyy-MM-dd').format(promoCode.expireDate);
      descriptionController.text = promoCode.description ?? '';
      isActiveForm.value = promoCode.isActive;
    } else {
      codeController.clear();
      referralController.clear();
      salesPercentageController.text = '0.00';
      rentalPercentageController.text = '0.00';
      selectedExpireDate.value = null;
      expireDateController.clear();
      descriptionController.clear();
      isActiveForm.value = true;
    }
  }

  Future<void> fetchPromoCodes() async {
    try {
      isLoading.value = true;
      final data = await getPromoCodesUseCase.execute(
        search: searchQuery.value,
        status: selectedStatus.value.value,
      );
      promoCodes.assignAll(data);
    } catch (e) {
      ScaffoldMessageUtils.showError('Failed to load promo codes: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    fetchPromoCodes();
  }

  void resetFilters() {
    selectedStatus.value = PromoCodeStatus.all;
    searchQuery.value = '';
    searchController.clear();
  }

  void confirmAndDelete(PromoCode promoCode) {
    showConfirmDeleteDialog(
      title: 'Delete Promo Code',
      message:
          'Are you sure you want to delete promo code "${promoCode.code}"? This action cannot be undone.',
      onConfirm: () => deletePromoCode(promoCode),
    );
  }

  Future<bool> createPromoCode() async {
    if (!formKey.currentState!.validate()) return false;
    if (selectedExpireDate.value == null) {
      ScaffoldMessageUtils.showError('Please select an expire date');
      return false;
    }

    try {
      isSaving.value = true;
      final salesPercentage = double.tryParse(salesPercentageController.text.trim()) ?? 0.0;
      final rentalPercentage = double.tryParse(rentalPercentageController.text.trim()) ?? 0.0;

      final newPromoCode = PromoCode(
        code: codeController.text.trim(),
        referral: referralController.text.trim(),
        salesPercentage: salesPercentage,
        rentalPercentage: rentalPercentage,
        expireDate: selectedExpireDate.value!,
        description: descriptionController.text.trim().isNotEmpty
            ? descriptionController.text.trim()
            : null,
        isActive: isActiveForm.value,
      );

      final created = await createPromoCodeUseCase.execute(newPromoCode);
      promoCodes.insert(0, created);
      ScaffoldMessageUtils.showSuccess('Promo code created successfully');
      return true;
    } catch (e) {
      ScaffoldMessageUtils.showError('Failed to create promo code: ${e.toString()}');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> updatePromoCode(PromoCode existing) async {
    if (!formKey.currentState!.validate()) return false;
    if (selectedExpireDate.value == null) {
      ScaffoldMessageUtils.showError('Please select an expire date');
      return false;
    }

    try {
      isSaving.value = true;
      final salesPercentage = double.tryParse(salesPercentageController.text.trim()) ?? 0.0;
      final rentalPercentage = double.tryParse(rentalPercentageController.text.trim()) ?? 0.0;

      final updatedPromoCode = existing.copyWith(
        code: codeController.text.trim(),
        referral: referralController.text.trim(),
        salesPercentage: salesPercentage,
        rentalPercentage: rentalPercentage,
        expireDate: selectedExpireDate.value!,
        description: descriptionController.text.trim().isNotEmpty
            ? descriptionController.text.trim()
            : null,
        isActive: isActiveForm.value,
      );

      final result = await updatePromoCodeUseCase.execute(updatedPromoCode);
      final index = promoCodes.indexWhere((e) => e.id == existing.id);
      if (index != -1) {
        promoCodes[index] = result;
      }
      ScaffoldMessageUtils.showSuccess('Promo code updated successfully');
      return true;
    } catch (e) {
      ScaffoldMessageUtils.showError('Failed to update promo code: ${e.toString()}');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deletePromoCode(PromoCode promoCode) async {
    if (promoCode.id == null) return;
    try {
      await deletePromoCodeUseCase.execute(promoCode.id!);
      promoCodes.removeWhere((e) => e.id == promoCode.id);
      ScaffoldMessageUtils.showSuccess('Promo code deleted successfully');
    } catch (e) {
      ScaffoldMessageUtils.showError('Failed to delete promo code: ${e.toString()}');
    }
  }

  Future<void> toggleStatus(PromoCode promoCode) async {
    try {
      final updated = promoCode.copyWith(isActive: !promoCode.isActive);
      final result = await updatePromoCodeUseCase.execute(updated);
      final index = promoCodes.indexWhere((e) => e.id == promoCode.id);
      if (index != -1) {
        promoCodes[index] = result;
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
    referralController.dispose();
    salesPercentageController.dispose();
    rentalPercentageController.dispose();
    expireDateController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
