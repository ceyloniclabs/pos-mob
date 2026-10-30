import 'package:pos/core/constants/api_endpoints.dart';
import 'package:pos/core/models/base_get_single_response_model.dart';
import 'package:pos/core/network/api_service.dart';

import '../models/payment_invoice_model.dart';
import 'payment_invoice_data_source.dart';

class PaymentInvoiceLaravelDataSourceImpl implements PaymentInvoiceDataSource {
  final ApiService _apiService;

  PaymentInvoiceLaravelDataSourceImpl(this._apiService);

  @override
  Future<PaymentInvoiceModel> getPaymentInvoice(int id) async {
    final response = await _apiService.getRequest('${EndPoints.sales}/$id/invoice');
    final baseResponse = BaseGetSingleResponseModel<Map<String, dynamic>>.fromJson(
      response,
      (data) => data,
    );
    if (baseResponse.success && baseResponse.data != null) {
      final summaryJson = baseResponse.data!['summary'] as Map<String, dynamic>;
      return PaymentInvoiceModel.fromJson(summaryJson);
    } else {
      throw Exception(baseResponse.message ?? 'Failed to fetch invoice');
    }
  }

  @override
  Future<String> recordPayment(Map<String, dynamic> data) async {
    final response = await _apiService.postRequest('payments', data: data);
    final baseResponse = BaseGetSingleResponseModel.fromJson(response, (_) => null);
    if (baseResponse.success) {
      return baseResponse.message ?? 'Success';
    } else {
      throw Exception(baseResponse.message ?? 'Unknown error');
    }
  }

  @override
  Future<String> getBillUrl(int id) async {
    final response = await _apiService.getRequest('${EndPoints.sales}/$id/bill');
    final baseResponse = BaseGetSingleResponseModel<Map<String, dynamic>>.fromJson(
      response,
      (data) => data,
    );
    if (baseResponse.success && baseResponse.data != null) {
      return baseResponse.data!['bill_url'] as String;
    } else {
      throw Exception(baseResponse.message ?? 'Failed to fetch bill');
    }
  }
}
