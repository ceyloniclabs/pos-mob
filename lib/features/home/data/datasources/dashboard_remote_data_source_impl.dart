import 'package:pos/core/network/api_service.dart';
import 'package:pos/core/constants/api_endpoints.dart';
import 'package:pos/features/home/data/datasources/dashboard_data_source.dart';

class DashboardRemoteDataSourceImpl implements DashboardDataSource {
  final ApiService _apiService = ApiService();

  @override
  Future<Map<String, dynamic>> getAdminStats() async {
    final response = await _apiService.getRequest(EndPoints.adminDashboard);
    if (response['success'] == true) {
      return response['data'];
    }
    throw Exception(response['message'] ?? 'Failed to fetch admin stats');
  }

  @override
  Future<Map<String, dynamic>> getStaffStats() async {
    final response = await _apiService.getRequest(EndPoints.staffDashboard);
    if (response['success'] == true) {
      return response['data'];
    }
    throw Exception(response['message'] ?? 'Failed to fetch staff stats');
  }
}
