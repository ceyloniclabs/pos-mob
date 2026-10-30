import 'package:pos/core/constants/api_endpoints.dart';
import 'package:pos/core/network/api_service.dart';
import 'package:pos/core/models/base_get_list_response_model.dart';
import 'package:pos/core/models/base_get_single_response_model.dart';
import 'package:pos/features/manage_customers/data/models/customer_model.dart';
import 'package:pos/features/manage_sale_items/data/models/sale_item_inventory_model.dart';
import '../models/sale_model.dart';
import 'sale_data_source.dart';

class SaleLaravelDataSourceImpl implements SaleDataSource {
  final ApiService _apiService;

  SaleLaravelDataSourceImpl(this._apiService);

  @override
  Future<List<SaleModel>> getSales(int page, {Map<String, dynamic>? filters}) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        ...?filters,
      };
      final response = await _apiService.getRequest(
        EndPoints.sales,
        queryParameters: queryParams,
      );

      final Map<String, dynamic> responseMap = response is Map<String, dynamic>
          ? response
          : Map<String, dynamic>.from(response as Map);

      final baseResponse = BaseGetListResponseModel<SaleModel>.fromJson(
        responseMap,
        (data) => SaleModel.fromJson(data),
      );

      if (baseResponse.success) {
        return baseResponse.data;
      }
    } catch (e) {
      return Future.error(e);
    }
    return [];
  }

  @override
  Future<List<SaleItemInventoryModel>> getSaleItems({Map<String, dynamic>? filters}) async {
    try {
      final response = await _apiService.getRequest(
        EndPoints.saleItems,
        queryParameters: filters,
      );

      final baseResponse =
          BaseGetListResponseModel<SaleItemInventoryModel>.fromJson(
        response,
        (data) => SaleItemInventoryModel.fromJson(data),
      );

      if (baseResponse.success) {
        return baseResponse.data;
      }
    } catch (e) {
      return Future.error(e);
    }
    return [];
  }

  @override
  Future<List<CustomerModel>> getCustomers({Map<String, dynamic>? filters}) async {
    try {
      final response = await _apiService.getRequest(
        EndPoints.customer,
        queryParameters: filters,
      );

      final baseResponse = BaseGetListResponseModel<CustomerModel>.fromJson(
        response,
        (data) => CustomerModel.fromJson(data),
      );

      if (baseResponse.success) {
        return baseResponse.data;
      }
    } catch (e) {
      return Future.error(e);
    }
    return [];
  }

  @override
  Future<SaleModel> getSaleById(int id) async {
    try {
      final response = await _apiService.getRequest(
        '${EndPoints.sales}/$id',
      );

      final Map<String, dynamic> responseMap = response is Map<String, dynamic>
          ? response
          : Map<String, dynamic>.from(response as Map);

      final baseResponse = BaseGetSingleResponseModel<SaleModel>.fromJson(
        responseMap,
        (data) => SaleModel.fromJson(data),
      );

      if (baseResponse.success && baseResponse.data != null) {
        return baseResponse.data!;
      } else {
        throw Exception(baseResponse.message ?? 'Failed to load sale details');
      }
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future<String> createSale(SaleModel sale) async {
    try {
      final response = await _apiService.postRequest(
        EndPoints.sales,
        data: sale.toJson(),
      );

      final baseResponse = BaseGetSingleResponseModel<dynamic>.fromJson(
        response,
        (data) => data,
      );

      if (baseResponse.success) {
        return baseResponse.message ?? 'Sale created successfully';
      } else {
        throw Exception(baseResponse.message ?? 'Failed to create sale');
      }
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future<String> updateSale(int id, SaleModel sale) async {
    try {
      final response = await _apiService.putRequest(
        '${EndPoints.sales}/$id',
        data: sale.toJson(),
      );

      final baseResponse = BaseGetSingleResponseModel<dynamic>.fromJson(
        response,
        (data) => data,
      );

      if (baseResponse.success) {
        return baseResponse.message ?? 'Sale updated successfully';
      } else {
        throw Exception(baseResponse.message ?? 'Failed to update sale');
      }
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future<String> updateCardReference(
    int id,
    String transactionId, {
    String status = 'completed',
  }) async {
    try {
      final response = await _apiService.putRequest(
        '${EndPoints.sales}/$id',
        data: {
          'sale_status': status,
          'transaction_id': transactionId,
        },
      );

      final baseResponse = BaseGetSingleResponseModel<dynamic>.fromJson(
        response,
        (data) => data,
      );

      if (baseResponse.success) {
        return baseResponse.message ?? 'Card reference updated successfully';
      } else {
        throw Exception(baseResponse.message ?? 'Failed to update reference');
      }
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future<String> getSaleInvoiceUrl(int id) async {
    try {
      final response = await _apiService.getRequest('${EndPoints.sales}/$id/invoice');

      final baseResponse = BaseGetSingleResponseModel<Map<String, dynamic>>.fromJson(
        response,
        (data) => data,
      );

      if (baseResponse.success && baseResponse.data != null) {
        final invoiceUrl = baseResponse.data!['invoice_url']?.toString();
        if (invoiceUrl != null && invoiceUrl.isNotEmpty) {
          return invoiceUrl;
        }
        throw Exception('Invoice URL not found in response');
      } else {
        throw Exception(baseResponse.message ?? 'Failed to retrieve invoice');
      }
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future<void> deleteSale(int id) async {
    try {
      final response = await _apiService.deleteRequest(
        '${EndPoints.sales}/$id',
      );

      final Map<String, dynamic> responseMap = response is Map<String, dynamic>
          ? response
          : Map<String, dynamic>.from(response as Map);

      if (responseMap['success'] != true) {
        throw Exception(responseMap['message'] ?? 'Failed to delete sale');
      }
    } catch (e) {
      return Future.error(e);
    }
  }
}
