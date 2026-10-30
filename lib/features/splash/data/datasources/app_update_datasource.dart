import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pos/core/network/api_service.dart';
import '../models/app_version_info_model.dart';

abstract class AppUpdateDataSource {
  Future<AppVersionInfoModel?> fetchAppVersion();
}

class AppUpdateDataSourceImpl implements AppUpdateDataSource {
  final ApiService _apiService;

  AppUpdateDataSourceImpl(this._apiService);

  @override
  Future<AppVersionInfoModel?> fetchAppVersion() async {
    try {
      final platform = Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'other');
      // Calling app/version endpoint
      final response = await _apiService.getRequest(
        'app/version',
        queryParameters: {'platform': platform},
        options: Options(receiveTimeout: const Duration(seconds: 5)),
      );

      if (response != null && response is Map<String, dynamic>) {
        return AppVersionInfoModel.fromJson(response);
      }
      return null;
    } catch (_) {
      // In case endpoint is unreachable or not yet deployed, fail silently
      return null;
    }
  }
}
