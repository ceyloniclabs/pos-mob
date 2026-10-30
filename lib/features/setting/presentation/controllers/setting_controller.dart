import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/core/controllers/persistent_data_controller.dart';
import 'package:pos/core/utils/scaffold_message_utils.dart';

import '../../domain/entities/shop_setting.dart';
import '../../domain/usecases/get_shop_settings_use_case.dart';
import '../../domain/usecases/update_shop_settings_use_case.dart';

class SettingController extends GetxController {
  final GetShopSettingsUseCase getShopSettingsUseCase;
  final UpdateShopSettingsUseCase updateShopSettingsUseCase;

  SettingController({
    required this.getShopSettingsUseCase,
    required this.updateShopSettingsUseCase,
  });

  final Rx<ShopSetting?> shopSettings = Rx<ShopSetting?>(null);
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxString errorMessage = ''.obs;

  final GlobalKey<FormState> shopDetailsFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> rentalSettingsFormKey = GlobalKey<FormState>();

  final TextEditingController shopNameController = TextEditingController();
  final TextEditingController shopEmailController = TextEditingController();
  final TextEditingController shopContactController = TextEditingController();
  final TextEditingController shopLocationController = TextEditingController();
  final TextEditingController privacyPolicyController = TextEditingController();
  final TextEditingController termsConditionsController =
      TextEditingController();

  final RxString currentShopName = ''.obs;
  final RxInt privacyPolicyWordCount = 0.obs;
  final RxInt termsConditionsWordCount = 0.obs;

  final RxString currency = 'LKR'.obs;
  final RxString timezone = 'Asia/Colombo'.obs;
  final RxString dateFormat = 'YYYY-MM-DD'.obs;

  final TextEditingController maxGraceHourlyController =
      TextEditingController();
  final TextEditingController maxGraceDailyController = TextEditingController();
  final TextEditingController maxGraceWeeklyController =
      TextEditingController();
  final TextEditingController maxGraceMonthlyController =
      TextEditingController();

  @override
  void onInit() {
    super.onInit();
    shopNameController.addListener(_updateShopName);
    privacyPolicyController.addListener(_updatePrivacyWordCount);
    termsConditionsController.addListener(_updateTermsWordCount);
    _loadSettings();
  }

  void _updateShopName() {
    currentShopName.value = shopNameController.text;
  }

  void _updatePrivacyWordCount() {
    final text = privacyPolicyController.text.trim();
    privacyPolicyWordCount.value =
        text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
  }

  void _updateTermsWordCount() {
    final text = termsConditionsController.text.trim();
    termsConditionsWordCount.value =
        text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
  }

  Future<void> _loadSettings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final data = await getShopSettingsUseCase.execute();
      if (isClosed) return;
      shopSettings.value = data;
      _initControllers(data);
    } catch (e) {
      if (isClosed) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      errorMessage.value = msg;
      ScaffoldMessageUtils.showError(
          'Failed to load shop details: $msg');
    } finally {
      if (!isClosed) {
        isLoading.value = false;
      }
    }
  }

  void _initControllers(ShopSetting? data) {
    if (data == null || isClosed) return;
    shopNameController.text = data.shopName;
    currentShopName.value = data.shopName;
    shopEmailController.text = data.shopEmail;
    shopContactController.text = data.shopContact;
    shopLocationController.text = data.shopLocation;
    privacyPolicyController.text = data.privacyPolicy;
    _updatePrivacyWordCount();
    termsConditionsController.text = data.termsConditions;
    _updateTermsWordCount();
    currency.value = data.currency;
    timezone.value = data.timezone;
    dateFormat.value = data.dateFormat;
    maxGraceHourlyController.text = data.maxGraceHourly;
    maxGraceDailyController.text = _minutesToHours(data.maxGraceDaily);
    maxGraceWeeklyController.text = _minutesToHours(data.maxGraceWeekly);
    maxGraceMonthlyController.text = _minutesToDays(data.maxGraceMonthly);
  }

  String _minutesToHours(String minutesStr) {
    final minutes = int.tryParse(minutesStr) ?? 0;
    return (minutes ~/ 60).toString();
  }

  String _minutesToDays(String minutesStr) {
    final minutes = int.tryParse(minutesStr) ?? 0;
    return (minutes ~/ (60 * 24)).toString();
  }

  String _hoursToMinutes(String hoursStr) {
    final hours = int.tryParse(hoursStr) ?? 0;
    return (hours * 60).toString();
  }

  String _daysToMinutes(String daysStr) {
    final days = int.tryParse(daysStr) ?? 0;
    return (days * 60 * 24).toString();
  }

  /// Reloads the shop settings from the remote server.
  Future<void> refreshSettings() async {
    await _loadSettings();
  }

  /// Submits the current form data to update shop settings.
  Future<void> saveSettings() async {
    try {
      isSaving.value = true;
      final current = shopSettings.value;
      final updated = ShopSetting(
        shopName: shopNameController.text.trim(),
        shopEmail: shopEmailController.text.trim(),
        shopContact: shopContactController.text.trim(),
        shopLocation: shopLocationController.text.trim(),
        privacyPolicy: privacyPolicyController.text.trim(),
        termsConditions: termsConditionsController.text.trim(),
        currency: currency.value,
        timezone: timezone.value,
        dateFormat: dateFormat.value,
        maxGraceHourly: maxGraceHourlyController.text.trim(),
        maxGraceDaily: _hoursToMinutes(maxGraceDailyController.text.trim()),
        maxGraceWeekly: _hoursToMinutes(maxGraceWeeklyController.text.trim()),
        maxGraceMonthly: _daysToMinutes(maxGraceMonthlyController.text.trim()),
        defaultLateFeeRate: current?.defaultLateFeeRate ?? 100.0,
        allowLateReturns: current?.allowLateReturns ?? true,
        taxRate: current?.taxRate ?? 0.0,
      );

      final updatedData = await updateShopSettingsUseCase.execute(updated);
      shopSettings.value = updatedData;
      _initControllers(updatedData);
      if (Get.isRegistered<PersistentDataController>()) {
        PersistentDataController.to.fetchShopSettings();
      }

      ScaffoldMessageUtils.showSuccess('Settings saved successfully');
    } catch (e) {
      ScaffoldMessageUtils.showError(
          'Failed to save settings: ${e.toString()}');
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    shopNameController.removeListener(_updateShopName);
    privacyPolicyController.removeListener(_updatePrivacyWordCount);
    termsConditionsController.removeListener(_updateTermsWordCount);

    shopNameController.dispose();
    shopEmailController.dispose();
    shopContactController.dispose();
    shopLocationController.dispose();
    privacyPolicyController.dispose();
    termsConditionsController.dispose();

    maxGraceHourlyController.dispose();
    maxGraceDailyController.dispose();
    maxGraceWeeklyController.dispose();
    maxGraceMonthlyController.dispose();
    super.onClose();
  }
}
