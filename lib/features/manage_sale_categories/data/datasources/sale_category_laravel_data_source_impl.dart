import 'package:pos/core/constants/api_endpoints.dart';
import 'package:pos/core/network/api_service.dart';
import 'package:pos/core/models/base_get_list_response_model.dart';
import 'package:pos/core/models/base_get_single_response_model.dart';

import '../models/sale_category_model.dart';
import 'sale_category_data_source.dart';

class SaleCategoryLaravelDataSourceImpl implements SaleCategoryDataSource {
  final ApiService _apiService;

  SaleCategoryLaravelDataSourceImpl(this._apiService);

  @override
  Future<List<SaleCategoryModel>> getSaleCategories(
      {Map<String, dynamic>? filters}) async {
    final response = await _apiService.getRequest(
      EndPoints.saleCategories,
      queryParameters: filters,
    );
    final baseResponse = BaseGetListResponseModel<SaleCategoryModel>.fromJson(
      response,
      (data) => SaleCategoryModel.fromJson(data),
    );
    return baseResponse.data;
  }

  @override
  Future<String> createSaleCategory(String name, String? description) async {
    final response = await _apiService.postRequest(
      EndPoints.saleCategories,
      data: {
        "name": name,
        "description": description,
      },
    );
    final baseResponse = BaseGetSingleResponseModel<SaleCategoryModel>.fromJson(
      response,
      (data) => SaleCategoryModel.fromJson(data),
    );

    if (baseResponse.success) {
      return baseResponse.message!;
    } else {
      throw Exception(baseResponse.message);
    }
  }

  @override
  Future<String> updateSaleCategory(
      int id, String name, String? description) async {
    final response = await _apiService.putRequest(
      '${EndPoints.saleCategories}/$id',
      data: {
        "name": name,
        "description": description,
      },
    );
    final baseResponse = BaseGetSingleResponseModel<SaleCategoryModel>.fromJson(
      response,
      (data) => SaleCategoryModel.fromJson(data),
    );

    if (baseResponse.success) {
      return baseResponse.message!;
    } else {
      throw Exception(baseResponse.message);
    }
  }

  @override
  Future<String> deleteSaleCategory(int id) async {
    final response = await _apiService.deleteRequest(
      '${EndPoints.saleCategories}/$id',
    );
    final baseResponse = BaseGetSingleResponseModel<SaleCategoryModel>.fromJson(
      response,
      (data) => SaleCategoryModel.fromJson(data),
    );

    if (baseResponse.success) {
      return baseResponse.message!;
    } else {
      throw Exception(baseResponse.message);
    }
  }
}
