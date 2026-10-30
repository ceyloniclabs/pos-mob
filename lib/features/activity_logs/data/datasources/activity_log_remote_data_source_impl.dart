import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_service.dart';
import '../../domain/entities/activity_filter_params.dart';
import '../models/activity_logs_response_model.dart';
import 'activity_log_data_source.dart';

class ActivityLogRemoteDataSourceImpl implements ActivityLogDataSource {
  final ApiService _apiService;

  ActivityLogRemoteDataSourceImpl({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  @override
  Future<ActivityLogsResponseModel> getActivityLogs(ActivityFilterParams params) async {
    final response = await _apiService.getRequest(
      EndPoints.activityLogs,
      queryParameters: params.toQueryParameters(),
    );

    if (response is Map<String, dynamic>) {
      if (response['success'] == true || response.containsKey('data')) {
        return ActivityLogsResponseModel.fromJson(response);
      }
      throw Exception(response['message'] ?? 'Failed to fetch activity logs');
    }

    throw Exception('Unexpected response format while fetching activity logs');
  }
}
