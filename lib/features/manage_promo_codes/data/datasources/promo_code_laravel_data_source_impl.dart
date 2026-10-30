import 'package:pos/core/constants/api_endpoints.dart';
import 'package:pos/core/network/api_service.dart';
import '../models/promo_code_model.dart';
import 'promo_code_data_source.dart';

class PromoCodeLaravelDataSourceImpl implements PromoCodeDataSource {
  final ApiService _apiService;

  PromoCodeLaravelDataSourceImpl(this._apiService);

  @override
  Future<List<PromoCodeModel>> fetchPromoCodes({
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
      EndPoints.promoCodes,
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
            PromoCodeModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PromoCodeModel> fetchPromoCodeById(int id) async {
    final response =
        await _apiService.getRequest('${EndPoints.promoCodes}/$id');
    if (response['data'] != null && response['data'] is Map<String, dynamic>) {
      return PromoCodeModel.fromJson(
          response['data'] as Map<String, dynamic>);
    } else {
      throw Exception(
          response['message'] ?? 'Failed to fetch promo code details');
    }
  }

  @override
  Future<PromoCodeModel> createPromoCode(PromoCodeModel promoCode) async {
    final response = await _apiService.postRequest(
      EndPoints.promoCodes,
      data: promoCode.toJson(),
    );
    if (response['success'] == true && response['data'] != null) {
      return PromoCodeModel.fromJson(
          response['data'] as Map<String, dynamic>);
    } else {
      throw Exception(
          response['message'] ?? 'Failed to create promo code');
    }
  }

  @override
  Future<PromoCodeModel> updatePromoCode(PromoCodeModel promoCode) async {
    if (promoCode.id == null) {
      throw Exception('Promo code ID cannot be null during update');
    }
    final response = await _apiService.putRequest(
      '${EndPoints.promoCodes}/${promoCode.id}',
      data: promoCode.toJson(),
    );
    if (response['success'] == true && response['data'] != null) {
      return PromoCodeModel.fromJson(
          response['data'] as Map<String, dynamic>);
    } else {
      throw Exception(
          response['message'] ?? 'Failed to update promo code');
    }
  }

  @override
  Future<void> deletePromoCode(int id) async {
    final response =
        await _apiService.deleteRequest('${EndPoints.promoCodes}/$id');
    if (response['success'] != true) {
      throw Exception(
          response['message'] ?? 'Failed to delete promo code');
    }
  }
}
