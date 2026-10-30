import 'package:pos/core/constants/api_endpoints.dart';
import 'package:pos/core/network/api_service.dart';
import 'package:pos/core/models/base_get_list_response_model.dart';
import 'package:pos/core/models/base_get_single_response_model.dart';

import '../models/sale_brand_model.dart';
import 'sale_brand_data_source.dart';

class SaleBrandLaravelDataSourceImpl implements SaleBrandDataSource {
  final ApiService _apiService;

  SaleBrandLaravelDataSourceImpl(this._apiService);

  @override
  Future<List<SaleBrandModel>> getSaleBrands({Map<String, dynamic>? filters}) async {
    final response = await _apiService.getRequest(
      EndPoints.brands,
      queryParameters: filters,
    );
    final baseResponse = BaseGetListResponseModel<SaleBrandModel>.fromJson(
      response,
      (data) => SaleBrandModel.fromJson(data),
    );
    return baseResponse.data;
  }

  @override
  Future<String> createSaleBrand(String name, int saleCategoryId) async {
    final response = await _apiService.postRequest(
      EndPoints.brands,
      data: {
        "name": name,
        "sale_category_id": saleCategoryId,
      },
    );
    final baseResponse = BaseGetSingleResponseModel<SaleBrandModel>.fromJson(
      response,
      (data) => SaleBrandModel.fromJson(data),
    );

    if (baseResponse.success) {
      return baseResponse.message ?? 'Brand created successfully';
    } else {
      throw Exception(baseResponse.message);
    }
  }

  @override
  Future<String> updateSaleBrand(int id, String name, int saleCategoryId) async {
    final response = await _apiService.putRequest(
      '${EndPoints.brands}/$id',
      data: {
        "name": name,
        "sale_category_id": saleCategoryId,
      },
    );
    final baseResponse = BaseGetSingleResponseModel<SaleBrandModel>.fromJson(
      response,
      (data) => SaleBrandModel.fromJson(data),
    );

    if (baseResponse.success) {
      return baseResponse.message ?? 'Brand updated successfully';
    } else {
      throw Exception(baseResponse.message);
    }
  }

  @override
  Future<String> deleteSaleBrand(int id) async {
    final response = await _apiService.deleteRequest(
      '${EndPoints.brands}/$id',
    );
    final baseResponse = BaseGetSingleResponseModel<SaleBrandModel>.fromJson(
      response,
      (data) => SaleBrandModel.fromJson(data),
    );

    if (baseResponse.success) {
      return baseResponse.message ?? 'Brand deleted successfully';
    } else {
      throw Exception(baseResponse.message);
    }
  }
}
