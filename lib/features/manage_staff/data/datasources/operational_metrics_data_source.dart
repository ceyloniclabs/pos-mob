import 'package:pos/core/constants/api_endpoints.dart';
import 'package:pos/core/network/api_service.dart';
import '../models/operational_metrics_model.dart';

abstract class OperationalMetricsDataSource {
  Future<OperationalMetricsModel> getOperationalMetrics({required int days});
}

class OperationalMetricsRemoteDataSourceImpl implements OperationalMetricsDataSource {
  final ApiService _apiService;

  OperationalMetricsRemoteDataSourceImpl({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  @override
  Future<OperationalMetricsModel> getOperationalMetrics({required int days}) async {
    final response = await _apiService.getRequest(
      EndPoints.operationalMetrics,
      queryParameters: {'days': days},
    );

    if (response is Map<String, dynamic>) {
      if (response['success'] == true && response['data'] is Map<String, dynamic>) {
        return OperationalMetricsModel.fromJson(response['data'] as Map<String, dynamic>);
      } else if (response.containsKey('data') && response['data'] is Map<String, dynamic>) {
        return OperationalMetricsModel.fromJson(response['data'] as Map<String, dynamic>);
      }
      throw Exception(response['message'] ?? 'Failed to fetch operational metrics');
    }

    throw Exception('Unexpected response format while fetching operational metrics');
  }
}
