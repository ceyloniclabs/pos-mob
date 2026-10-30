import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:get_storage/get_storage.dart';

import 'package:pos/core/constants/api_endpoints.dart';
import 'package:pos/core/routes/app_pages.dart';
import 'package:pos/core/utils/app_logger.dart';
import 'package:pos/core/network/dio_exceptions.dart';
import 'package:pos/core/utils/app_date_time_utils.dart';
import 'package:pos/core/utils/app_dialog_utils.dart';
import 'package:pos/core/utils/scaffold_message_utils.dart';
import 'package:pos/features/splash/domain/entities/maintenance_info.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  late final Dio _dio;

  final box = GetStorage();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _initializeDio();
  }

  void _initializeDio() {
    final savedBaseUrl = box.read<String>('baseUrl');
    if (savedBaseUrl != null && savedBaseUrl.isNotEmpty) {
      EndPoints.baseUrl = savedBaseUrl;
    }
    log('Base URL: ${EndPoints.baseUrl}');
    _dio = Dio(
      BaseOptions(
        baseUrl: EndPoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    // Interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = GetStorage().read('token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Ensure any DateTime in request payload or query parameters is sent in UTC format
          if (options.data != null && options.data is! FormData) {
            options.data = _sanitizeDataForUtc(options.data);
          }
          if (options.queryParameters.isNotEmpty) {
            options.queryParameters = Map<String, dynamic>.from(
              _sanitizeDataForUtc(options.queryParameters) as Map,
            );
          }

          AppLogger.debug('🌐 [API Request] ${options.method} ${options.path} params=${options.queryParameters}');

          handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.debug('✅ [API Response] ${response.statusCode} ${response.requestOptions.path}');
          final data = response.data;
          if (data is Map<String, dynamic>) {
            if (data['maintenance'] == true) {
              AppDialogUtils.showMaintenanceDialog(MaintenanceInfo.fromJson(data));
              return;
            }
            if (data['tenant_suspended'] == true || data['account_suspended'] == true) {
              AppDialogUtils.showTenantSuspendedDialog(
                reason: data['suspended_reason']?.toString() ??
                    data['message']?.toString() ??
                    'Your tenant account is suspended.',
                billingUrl: data['billing_url']?.toString(),
              );
              return;
            }
          }
          handler.next(response);
        },
        onError: (DioException error, handler) {
          final statusCode = error.response?.statusCode;
          if (statusCode == 503) {
            final data = error.response?.data;
            if (data is Map<String, dynamic>) {
              AppDialogUtils.showMaintenanceDialog(MaintenanceInfo.fromJson(data));
            } else {
              AppDialogUtils.showMaintenanceDialog(
                const MaintenanceInfo(
                  message: 'The server is temporarily unavailable for maintenance. Please try again soon.',
                ),
              );
            }
            return;
          }

          // Handle 401 Session Expiration
          if (statusCode == 401) {
            final isSignIn = error.requestOptions.path.contains(EndPoints.signIn);
            if (!isSignIn) {
              AppLogger.error('Session expired (401). Invalidating session and redirecting to sign in.');
              box.remove('token');
              box.remove('user');
              if (Get.currentRoute != Routes.SIGN_IN) {
                Get.offAllNamed(Routes.SIGN_IN);
                ScaffoldMessageUtils.showError('Session expired. Please sign in again.');
              }
            }
          }

          handler.next(error);
        },
      ),
    );
  }

  void _safeLog(String prefix, dynamic data) {
    try {
      final str = data?.toString() ?? '';
      if (str.length > 500) {
        AppLogger.info('$prefix ${str.substring(0, 500)}... [truncated, length: ${str.length}]');
      } else {
        AppLogger.info('$prefix $str');
      }
    } catch (_) {}
  }

  void setBaseUrl(String newUrl) {
    String formattedUrl = newUrl.trim();
    if (!formattedUrl.endsWith('/')) {
      formattedUrl += '/';
    }
    if (!formattedUrl.endsWith('api/')) {
      formattedUrl += 'api/';
    }
    EndPoints.baseUrl = formattedUrl;
    _dio.options.baseUrl = formattedUrl;
    box.write('baseUrl', formattedUrl);
  }

  Future<dynamic> getRequest(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      _safeLog('GET $path:', response.data);
      return response.data;
    } on DioException catch (dioE) {
      log(dioE.toString());
      throw DioExceptions.fromDioError(dioE);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> downloadRequest(
    String path,
    String filePath, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      await _dio.download(
        path,
        filePath,
        queryParameters: queryParameters,
        options: options ??
            Options(
              responseType: ResponseType.bytes,
              headers: const {
                'Accept': 'application/pdf',
              },
            ),
        cancelToken: cancelToken,
      );
    } on DioException catch (dioE) {
      throw DioExceptions.fromDioError(dioE);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> postRequest(
    String path, {
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        options: options,
        cancelToken: cancelToken,
      );
      final fullUrl = response.requestOptions.uri.toString();
      _safeLog('POST URL: $fullUrl\nResponse:', response.data);
      return response.data;
    } on DioException catch (dioE) {
      final fullUrl = dioE.requestOptions.uri.toString();
      _safeLog('POST URL ERROR: $fullUrl\nError Response:', dioE.response?.data);
      throw DioExceptions.fromDioError(dioE);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> putRequest(
    String path, {
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        options: options,
        cancelToken: cancelToken,
      );
      _safeLog('PUT $path:', response.data);
      return response.data;
    } on DioException catch (dioE) {
      throw DioExceptions.fromDioError(dioE);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> deleteRequest(
    String path, {
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        options: options,
        cancelToken: cancelToken,
      );
      _safeLog('DELETE $path:', response.data);
      return response.data;
    } on DioException catch (dioE) {
      throw DioExceptions.fromDioError(dioE);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> uploadFile(
    String path,
    File file, {
    String fieldName = 'file',
    Map<String, dynamic>? data,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      String fileName = file.path.split(RegExp(r'[/\\]')).last;
      FormData formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
        ...?data,
      });

      final response = await _dio.post(
        path,
        data: formData,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );

      _safeLog('UPLOAD $path:', response.data);
      return response.data;
    } on DioException catch (dioE) {
      throw DioExceptions.fromDioError(dioE);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> uploadFiles(
    String path,
    List<File> files, {
    String fieldName = 'photos[]',
    Map<String, dynamic>? data,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      List<MultipartFile> multipartFiles = [];
      for (var file in files) {
        String fileName = file.path.split(RegExp(r'[/\\]')).last;
        multipartFiles.add(await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ));
      }

      FormData formData = FormData.fromMap({
        fieldName: multipartFiles,
        ...?data,
      });

      final response = await _dio.post(
        path,
        data: formData,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );

      _safeLog('UPLOAD MULTIPLE $path:', response.data);
      return response.data;
    } on DioException catch (dioE) {
      throw DioExceptions.fromDioError(dioE);
    } catch (e) {
      rethrow;
    }
  }

  /// Recursively converts any [DateTime] instance within request payloads or query parameters into a UTC ISO string.
  static dynamic _sanitizeDataForUtc(dynamic data) {
    if (data is DateTime) {
      return AppDateTimeUtils.toUtcIso(data);
    } else if (data is Map) {
      return data.map((key, value) => MapEntry(key, _sanitizeDataForUtc(value)));
    } else if (data is List) {
      return data.map((item) => _sanitizeDataForUtc(item)).toList();
    }
    return data;
  }
}
