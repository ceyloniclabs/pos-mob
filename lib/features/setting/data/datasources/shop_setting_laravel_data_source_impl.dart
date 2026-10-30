import 'package:pos/core/constants/api_endpoints.dart';
import 'package:pos/core/models/base_get_single_response_model.dart';
import 'package:pos/core/network/api_service.dart';

import '../models/shop_setting_model.dart';
import 'shop_setting_data_source.dart';

class ShopSettingLaravelDataSourceImpl implements ShopSettingDataSource {
  final ApiService _apiService;

  ShopSettingLaravelDataSourceImpl(this._apiService);

  @override
  Future<ShopSettingModel> getShopSettings() async {
    final response = await _apiService.getRequest(EndPoints.shopSettings);
    final baseResponse = BaseGetSingleResponseModel<ShopSettingModel>.fromJson(
      response,
      (data) => ShopSettingModel.fromJson(data),
    );

    if (baseResponse.success && baseResponse.data != null) {
      return baseResponse.data!;
    } else {
      throw Exception(baseResponse.message ?? 'Failed to fetch shop settings');
    }
  }

  @override
  Future<ShopSettingModel> updateShopSettings(ShopSettingModel model) async {
    final response = await _apiService.postRequest(
      '${EndPoints.shopSettings}/bulk',
      data: model.toJson(),
    );
    final baseResponse = BaseGetSingleResponseModel<ShopSettingModel>.fromJson(
      response,
      (data) => ShopSettingModel.fromJson(data),
    );

    if (baseResponse.success && baseResponse.data != null) {
      return baseResponse.data!;
    } else {
      throw Exception(baseResponse.message ?? 'Failed to update shop settings');
    }
  }
}
