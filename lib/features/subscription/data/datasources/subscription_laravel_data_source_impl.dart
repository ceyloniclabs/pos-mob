import 'package:pos/core/constants/api_endpoints.dart';
import 'package:pos/core/models/base_get_list_response_model.dart';
import 'package:pos/core/models/base_get_single_response_model.dart';
import 'package:pos/core/network/api_service.dart';
import '../models/current_subscription_data_model.dart';
import '../models/subscription_model.dart';
import 'subscription_data_source.dart';

class SubscriptionLaravelDataSourceImpl implements SubscriptionDataSource {
  final ApiService _apiService;

  SubscriptionLaravelDataSourceImpl(this._apiService);

  @override
  Future<CurrentSubscriptionDataModel> getCurrentSubscription() async {
    final response = await _apiService.getRequest(EndPoints.currentSubscription);
    if (response is Map<String, dynamic>) {
      final baseResponse = BaseGetSingleResponseModel<CurrentSubscriptionDataModel>.fromJson(
        response,
        (data) => CurrentSubscriptionDataModel.fromJson(data),
      );
      if (baseResponse.success && baseResponse.data != null) {
        return baseResponse.data!;
      } else {
        throw Exception(baseResponse.message ?? 'Failed to load current subscription');
      }
    }
    throw Exception('Invalid response format for current subscription');
  }

  @override
  Future<List<SubscriptionModel>> getSubscriptionHistory() async {
    final response = await _apiService.getRequest(EndPoints.subscriptionHistory);
    if (response is Map<String, dynamic>) {
      final baseResponse = BaseGetListResponseModel<SubscriptionModel>.fromJson(
        response,
        (data) => SubscriptionModel.fromJson(data),
      );
      return baseResponse.data;
    }
    throw Exception('Invalid response format for subscription history');
  }
}
