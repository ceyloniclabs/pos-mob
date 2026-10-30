import 'package:pos/core/constants/api_endpoints.dart';
import 'package:pos/core/network/api_service.dart';
import '../models/gift_voucher_model.dart';
import 'gift_voucher_data_source.dart';

class GiftVoucherLaravelDataSourceImpl implements GiftVoucherDataSource {
  final ApiService _apiService;

  GiftVoucherLaravelDataSourceImpl(this._apiService);

  @override
  Future<List<GiftVoucherModel>> fetchGiftVouchers({
    int? page,
    int? perPage,
    String? search,
    String? status,
  }) async {
    final Map<String, dynamic> queryParams = {};
    if (page != null) queryParams['page'] = page;
    if (perPage != null) queryParams['perPage'] = perPage;
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    if (status != null && status.isNotEmpty && status != 'all') {
      queryParams['is_active'] = status == 'active' ? 'true' : 'false';
    }

    final response = await _apiService.getRequest(
      EndPoints.giftVouchers,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    List<dynamic> list = [];
    if (response['data'] is Map<String, dynamic> &&
        response['data']['data'] is List) {
      list = response['data']['data'] as List<dynamic>;
    } else if (response['data'] is List) {
      list = response['data'] as List<dynamic>;
    }

    return list
        .map((item) =>
            GiftVoucherModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<GiftVoucherModel> fetchGiftVoucherById(int id) async {
    final response =
        await _apiService.getRequest('${EndPoints.giftVouchers}/$id');
    if (response['data'] != null && response['data'] is Map<String, dynamic>) {
      return GiftVoucherModel.fromJson(
          response['data'] as Map<String, dynamic>);
    } else {
      throw Exception(
          response['message'] ?? 'Failed to fetch gift voucher details');
    }
  }

  @override
  Future<GiftVoucherModel> createGiftVoucher(GiftVoucherModel voucher) async {
    final response = await _apiService.postRequest(
      EndPoints.giftVouchers,
      data: voucher.toJson(),
    );
    if (response['success'] == true && response['data'] != null) {
      return GiftVoucherModel.fromJson(
          response['data'] as Map<String, dynamic>);
    } else {
      throw Exception(
          response['message'] ?? 'Failed to create gift voucher');
    }
  }

  @override
  Future<GiftVoucherModel> updateGiftVoucher(GiftVoucherModel voucher) async {
    if (voucher.id == null) {
      throw Exception('Voucher ID cannot be null during update');
    }
    final response = await _apiService.putRequest(
      '${EndPoints.giftVouchers}/${voucher.id}',
      data: voucher.toJson(),
    );
    if (response['success'] == true && response['data'] != null) {
      return GiftVoucherModel.fromJson(
          response['data'] as Map<String, dynamic>);
    } else {
      throw Exception(
          response['message'] ?? 'Failed to update gift voucher');
    }
  }

  @override
  Future<void> deleteGiftVoucher(int id) async {
    final response =
        await _apiService.deleteRequest('${EndPoints.giftVouchers}/$id');
    if (response['success'] != true) {
      throw Exception(
          response['message'] ?? 'Failed to delete gift voucher');
    }
  }
}
