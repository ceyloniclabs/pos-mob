import 'dart:io';

import 'package:pos/core/constants/api_endpoints.dart';
import 'package:pos/core/models/base_get_list_response_model.dart';
import 'package:pos/core/models/base_get_single_response_model.dart';
import 'package:pos/core/network/api_service.dart';

import '../models/sale_item_inventory_model.dart';
import 'sale_item_data_source.dart';

class SaleItemLaravelDataSourceImpl implements SaleItemDataSource {
  final ApiService _apiService;

  SaleItemLaravelDataSourceImpl(this._apiService);

  @override
  Future<List<SaleItemInventoryModel>> getSaleItems({
    Map<String, dynamic>? filters,
  }) async {
    final response = await _apiService.getRequest(
      EndPoints.saleItems,
      queryParameters: filters,
    );
    final baseResponse =
        BaseGetListResponseModel<SaleItemInventoryModel>.fromJson(
      response,
      (data) => SaleItemInventoryModel.fromJson(data),
    );
    return baseResponse.data;
  }

  @override
  Future<SaleItemInventoryModel> getSaleItemById(int id) async {
    final response =
        await _apiService.getRequest('${EndPoints.saleItems}/$id');
    final baseResponse =
        BaseGetSingleResponseModel<SaleItemInventoryModel>.fromJson(
      response,
      (data) => SaleItemInventoryModel.fromJson(data),
    );
    if (baseResponse.success && baseResponse.data != null) {
      return baseResponse.data!;
    } else {
      throw Exception(baseResponse.message ?? 'Sale item not found');
    }
  }

  @override
  Future<String> createSaleItem(
    SaleItemInventoryModel model,
    List<File>? photos,
  ) async {
    final response = await _apiService.uploadFiles(
      EndPoints.saleItems,
      photos ?? [],
      fieldName: 'photos[]',
      data: model.toJson(),
    );

    final baseResponse =
        BaseGetSingleResponseModel<SaleItemInventoryModel>.fromJson(
      response,
      (data) => SaleItemInventoryModel.fromJson(data),
    );

    if (baseResponse.success) {
      return baseResponse.message ?? 'Successfully created sale item';
    } else {
      throw Exception(baseResponse.message ?? 'Failed to create sale item');
    }
  }

  @override
  Future<String> updateSaleItem(
    int id,
    SaleItemInventoryModel model,
    List<File>? photos,
  ) async {
    final dataMap = model.toJson();
    dataMap['_method'] = 'PUT';

    final response = await _apiService.uploadFiles(
      '${EndPoints.saleItems}/$id',
      photos ?? [],
      fieldName: 'photos[]',
      data: dataMap,
    );

    final baseResponse =
        BaseGetSingleResponseModel<SaleItemInventoryModel>.fromJson(
      response,
      (data) => SaleItemInventoryModel.fromJson(data),
    );

    if (baseResponse.success) {
      return baseResponse.message ?? 'Successfully updated sale item';
    } else {
      throw Exception(baseResponse.message ?? 'Failed to update sale item');
    }
  }

  @override
  Future<String> deleteSaleItem(int id) async {
    final response = await _apiService.deleteRequest(
      '${EndPoints.saleItems}/$id',
    );
    final baseResponse =
        BaseGetSingleResponseModel<SaleItemInventoryModel>.fromJson(
      response,
      (data) => SaleItemInventoryModel.fromJson(data),
    );

    if (baseResponse.success) {
      return baseResponse.message ?? 'Successfully deleted sale item';
    } else {
      throw Exception(baseResponse.message ?? 'Failed to delete sale item');
    }
  }
}
