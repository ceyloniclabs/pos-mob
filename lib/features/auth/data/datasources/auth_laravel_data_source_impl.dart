import 'dart:developer';

import 'package:pos/core/constants/api_endpoints.dart';
import 'package:pos/core/network/api_service.dart';
import 'package:pos/core/models/base_login_response_model.dart';
import 'package:pos/features/auth/data/models/user_model.dart';
import 'package:pos/features/auth/data/datasources/auth_data_source.dart';
import 'package:get_storage/get_storage.dart';

class AuthLaravelDataSourceImpl implements AuthDataSource {
  final ApiService _apiService;

  AuthLaravelDataSourceImpl(this._apiService);

  @override
  Future<UserModel?> signIn(String email, String password) async {
    try {
      final response = await _apiService.postRequest(
        EndPoints.signIn,
        data: {'email': email, 'password': password},
      );

      final baseResponse = BaseLoginResponseModel<UserModel>.fromJson(
        response,
        (data) => UserModel.fromJson(data),
      );

      if (baseResponse.success) {
        if (baseResponse.token != null) {
          await GetStorage().write('token', baseResponse.token);
        }
        return baseResponse.data;
      }
      throw Exception(baseResponse.message ?? 'Unknown error occurred');
    } on FormatException catch (e) {
      log('Format Exception: ${e.message}');
      throw Exception('Invalid response format: ${e.message}');
    } catch (e) {
      log('General Exception: ${e.toString()}');
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> signUp(String name, String email, String password) async {
    try {
      final response = await _apiService.postRequest(
        EndPoints.signUp,
        data: {'name': name, 'email': email, 'password': password},
      );

      final baseResponse = BaseLoginResponseModel<UserModel>.fromJson(
        response,
        (data) => UserModel.fromJson(data),
      );

      if (baseResponse.success) {
        if (baseResponse.token != null) {
          await GetStorage().write('token', baseResponse.token);
        }
        return baseResponse.data;
      }
      throw Exception(baseResponse.message ?? 'Unknown error occurred');
    } catch (e) {
      log('Error signing up: ${e.toString()}');
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser(String userId) async {
    try {
      final response = await _apiService.getRequest(
        '${EndPoints.user}/$userId',
      );

      log('API Response: $response');

      final baseResponse = BaseLoginResponseModel<UserModel>.fromJson(
        response,
        (data) => UserModel.fromJson(data),
      );

      if (baseResponse.success) {
        if (baseResponse.data == null && response['data'] != null) {
          return UserModel.fromJson(response['data']);
        }
        return baseResponse.data;
      }
      return null;
    } catch (e) {
      log('Error getting current user: ${e.toString()}');
      return null;
    }
  }

  @override
  Future<bool> signOut() async {
    try {
      final response = await _apiService.postRequest(EndPoints.logout);
      return response['success'] == true;
    } catch (e) {
      log('Error signing out: ${e.toString()}');
      return false;
    }
  }
}
