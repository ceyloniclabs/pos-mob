import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pos/core/network/api_service.dart';
import 'package:pos/core/models/base_get_list_response_model.dart';
import 'package:pos/features/manage_sale_brands/data/models/sale_brand_model.dart';
import 'package:pos/core/models/country_model.dart';
import 'package:pos/core/constants/api_endpoints.dart';
import 'package:pos/core/models/base_get_single_response_model.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pos/features/setting/data/models/shop_setting_model.dart';
import 'package:pos/features/setting/domain/entities/shop_setting.dart';

class PersistentDataController extends GetxController {
  static PersistentDataController get to => Get.find();

  final ApiService _apiService;

  // Observable lists for dropdown data
  RxList<CountryModel> countries = <CountryModel>[].obs;
  final RxList<SaleBrandModel> brands = <SaleBrandModel>[].obs;

  // Shop Settings & Currency
  final Rxn<ShopSetting> shopSetting = Rxn<ShopSetting>();
  final RxString shopCurrency = 'USD'.obs;
  String get currency => shopCurrency.value;

  // Loading states
  final RxBool isLoading = false.obs;

  PersistentDataController(this._apiService);

  @override
  void onInit() {
    super.onInit();
    final cachedCurrency = GetStorage().read('shop_currency');
    if (cachedCurrency != null && cachedCurrency.toString().trim().isNotEmpty) {
      shopCurrency.value = cachedCurrency.toString().trim();
    }
    fetchCountries();
    fetchShopSettings();
  }

  Future<void> fetchShopSettings() async {
    try {
      final response = await _apiService.getRequest(EndPoints.shopSettings);
      if (response != null) {
        final parsed = BaseGetSingleResponseModel<ShopSettingModel>.fromJson(
          response,
          (json) => ShopSettingModel.fromJson(json),
        );
        if (parsed.success && parsed.data != null) {
          shopSetting.value = parsed.data;
          final curr = parsed.data!.currency.trim();
          if (curr.isNotEmpty) {
            shopCurrency.value = curr;
            GetStorage().write('shop_currency', curr);
          }
        }
      }
    } catch (e) {
      log("Failed to load shop settings: ${e.toString()}");
    }
  }

  Future<void> fetchCountries() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/json/countries.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);

      countries.value = jsonList
          .map((json) => CountryModel(
                id: json['id'],
                name: json['name'],
                isoCode: json['iso_code'],
              ))
          .toList();
    } catch (e) {
      log("Failed to load countries: ${e.toString()}");
    }
  }

  Future<void> loadDropdownData() async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      final data = await fetchDropdownData();
      if (data.containsKey('brands')) {
        brands.value = data['brands'] as List<SaleBrandModel>;
      }
    } catch (e) {
      log('Error loading dropdown data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Helper methods for finding items
  CountryModel? findCountryById(int id) =>
      countries.firstWhereOrNull((country) => country.id == id);

  SaleBrandModel? findBrandById(int id) =>
      brands.firstWhereOrNull((brand) => brand.id == id);

  Future<Map<String, List>> fetchDropdownData({
    CancelToken? cancelToken,
  }) async {
    final List<Future> apiCalls = [
      _apiService.getRequest(
        EndPoints.brands,
        queryParameters: const {'per_page': 100},
        cancelToken: cancelToken,
      ),
    ];

    try {
      final results = await Future.wait(
        apiCalls,
        eagerError: false,
      );

      final Map<String, List> dropdownData = {};

      if (results[0] != null) {
        final brandResponse =
            BaseGetListResponseModel<SaleBrandModel>.fromJson(
          results[0],
          (data) => SaleBrandModel.fromJson(data),
        );
        if (brandResponse.success) {
          dropdownData['brands'] = brandResponse.data;
        }
      }

      return dropdownData;
    } catch (e) {
      throw Exception('Failed to load dropdown data: ${e.toString()}');
    }
  }
}
