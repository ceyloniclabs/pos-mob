import 'package:pos/core/constants/api_endpoints.dart';
import 'package:pos/core/models/base_get_list_response_model.dart';
import 'package:pos/core/models/base_get_single_response_model.dart';
import 'package:pos/core/network/api_service.dart';
import '../models/staff_model.dart';
import 'staff_data_source.dart';

class StaffLaravelDataSourceImpl implements StaffDataSource {
  final ApiService _apiService;

  StaffLaravelDataSourceImpl(this._apiService);

  @override
  Future<List<StaffModel>> getStaff({
    String? role,
    String? status,
    String? search,
    int? page,
    int? perPage,
  }) async {
    final Map<String, dynamic> queryParams = {};
    if (role != null && role.isNotEmpty && role != 'all') {
      queryParams['role'] = role;
    }
    if (status != null && status.isNotEmpty && status != 'all') {
      queryParams['is_active'] = status == 'active' ? 'true' : 'false';
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (page != null) {
      queryParams['page'] = page;
    }
    if (perPage != null) {
      queryParams['per_page'] = perPage;
    }

    final response = await _apiService.getRequest(
      EndPoints.user,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    final baseResponse = BaseGetListResponseModel<StaffModel>.fromJson(
      response,
      (data) => StaffModel.fromJson(data),
    );

    return baseResponse.data;
  }

  @override
  Future<StaffModel> getStaffById(int id) async {
    final response = await _apiService.getRequest('${EndPoints.user}/$id');
    final baseResponse = BaseGetSingleResponseModel<StaffModel>.fromJson(
      response,
      (data) => StaffModel.fromJson(data),
    );
    if (baseResponse.success && baseResponse.data != null) {
      return baseResponse.data!;
    } else {
      throw Exception(baseResponse.message ?? 'Failed to fetch staff member');
    }
  }

  @override
  Future<StaffModel> createStaff(StaffModel staffModel, String password) async {
    final payload = staffModel.toJson();
    payload['password'] = password;
    final response = await _apiService.postRequest(EndPoints.signUp, data: payload);
    if (response['success'] == true) {
      if (response['data'] != null) {
        return StaffModel.fromJson(response['data']);
      }
      return staffModel.copyWith(id: 0, isActive: true);
    } else {
      throw Exception(response['message'] ?? 'Failed to add staff');
    }
  }

  @override
  Future<StaffModel> updateStaff(StaffModel staffModel, {String? password}) async {
    final payload = staffModel.toJson();
    if (password != null && password.isNotEmpty) {
      payload['password'] = password;
    }

    final response = await _apiService.putRequest('${EndPoints.user}/${staffModel.id}', data: payload);
    if (response['success'] == true && response['data'] != null) {
      return StaffModel.fromJson(response['data']);
    } else if (response['success'] == true) {
      return staffModel;
    }
    throw Exception(response['message'] ?? 'Failed to update staff');
  }

  @override
  Future<void> deleteStaff(int id) async {
    final response = await _apiService.deleteRequest('${EndPoints.user}/$id');
    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to delete staff');
    }
  }

  @override
  Future<void> updateStaffStatus(int id, bool isActive) async {
    final payload = {'is_active': isActive};
    final response = await _apiService
        .putRequest('${EndPoints.user}/$id/status', data: payload);
    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to update staff status');
    }
  }
}
