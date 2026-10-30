import 'package:pos/core/constants/api_endpoints.dart';
import 'package:pos/core/network/api_service.dart';
import 'package:pos/core/models/base_get_list_response_model.dart';
import 'package:pos/core/models/base_get_single_response_model.dart';

import '../models/sale_sub_category_model.dart';
import 'sale_sub_category_data_source.dart';

class SaleSubCategoryLaravelDataSourceImpl implements SaleSubCategoryDataSource {
  final ApiService _apiService;

  SaleSubCategoryLaravelDataSourceImpl(this._apiService);

  @override
  Future<List<SaleSubCategoryModel>> getSaleSubCategories(
      {Map<String, dynamic>? filters}) async {
    final response = await _apiService.getRequest(
      EndPoints.saleSubCategories,
      queryParameters: filters,
    );
    final baseResponse =
        BaseGetListResponseModel<SaleSubCategoryModel>.fromJson(
      response,
      (data) => SaleSubCategoryModel.fromJson(data),
    );
    return baseResponse.data;
  }

  @override
  Future<String> createSaleSubCategory(
    String name,
    int saleCategoryId,
    String? description,
  ) async {
    final response = await _apiService.postRequest(
      EndPoints.saleSubCategories,
      data: {
        "name": name,
        "sale_category_id": saleCategoryId,
        "description": description,
      },
    );
    final baseResponse =
        BaseGetSingleResponseModel<SaleSubCategoryModel>.fromJson(
      response,
      (data) => SaleSubCategoryModel.fromJson(data),
    );

    if (baseResponse.success) {
      return baseResponse.message!;
    } else {
      throw Exception(baseResponse.message);
    }
  }

  @override
  Future<String> updateSaleSubCategory(
    int id,
    String name,
    int saleCategoryId,
    String? description,
  ) async {
    final response = await _apiService.putRequest(
      '${EndPoints.saleSubCategories}/$id',
      data: {
        "name": name,
        "sale_category_id": saleCategoryId,
        "description": description,
      },
    );
    final baseResponse =
        BaseGetSingleResponseModel<SaleSubCategoryModel>.fromJson(
      response,
      (data) => SaleSubCategoryModel.fromJson(data),
    );

    if (baseResponse.success) {
      return baseResponse.message!;
    } else {
      throw Exception(baseResponse.message);
    }
  }

  @override
  Future<String> deleteSaleSubCategory(int id) async {
    final response = await _apiService.deleteRequest(
      '${EndPoints.saleSubCategories}/$id',
    );
    final baseResponse =
        BaseGetSingleResponseModel<SaleSubCategoryModel>.fromJson(
      response,
      (data) => SaleSubCategoryModel.fromJson(data),
    );

    if (baseResponse.success) {
      return baseResponse.message!;
    } else {
      throw Exception(baseResponse.message);
    }
  }
}
