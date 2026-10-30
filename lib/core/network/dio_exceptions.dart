import 'dart:developer';
import 'package:dio/dio.dart';

class DioExceptions implements Exception {
  String message = 'init';

  DioExceptions.fromDioError(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.cancel:
        message = 'Request to API server was cancelled';
        break;

      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout with API server';
        break;

      case DioExceptionType.connectionError:
        message = 'Network Error - Please try again ';
        break;

      case DioExceptionType.receiveTimeout:
        message = 'Receive timeout in connection with API server';
        break;

      // Updated to ensure it matches Dio's enum
      case DioExceptionType.badResponse:
        if (dioError.response != null) {
          message = _handleError(
            dioError.response!.statusCode!,
            dioError.response!.data,
          );
        } else {
          message = 'Received an invalid response from the server';
        }
        break;

      case DioExceptionType.sendTimeout:
        message = 'Send timeout in connection with API server';
        break;

      default:
        message = 'Something went wrong';
        break;
    }

    // Log the full error for debugging
    log('--- DIO EXCEPTION ---');
    log('Requsted API: ${dioError.requestOptions.path}');
    log('Status Code: ${dioError.response?.statusCode}');
    log('Response Data: ${dioError.response?.data}');
    log('Message parsed: $message');
    log('---------------------');
  }

  String _handleError(int statusCode, dynamic error) {
    switch (statusCode) {
      case 400:
        return error["message"]?.toString() ?? 'Bad Request';

      case 401:
        // return 'Authorization Required';
        return error["message"]?.toString() ?? 'Authorization Required';

      case 402:
        return 'Payment Required';

      case 403:
        return error["message"]?.toString() ?? 'Forbidden';

      case 404:
        // return 'Not Found';
        return error["message"]?.toString() ?? 'URL Not Found';

      case 405:
        return 'Method Not Allowed';

      case 406:
        return 'Not Acceptable';

      case 407:
        return 'Proxy Authentication Required';

      case 408:
        return 'Request TimeOut';

      case 409:
        return 'Conflict';

      case 410:
        return 'Gone';

      case 412:
        return 'Precondition Failed';

      case 413:
        return 'Request Entity Too Long';

      case 414:
        return 'Request URI too Long';

      case 422:
        if (error["errors"] != null && error["errors"] is Map) {
          final Map<String, dynamic> errors = error["errors"];
          List<String> messages = [];
          errors.forEach((key, value) {
            if (value is List) {
              messages.addAll(value.map((e) => e.toString()));
            } else {
              messages.add(value.toString());
            }
          });
          return messages.join('\n');
        }
        return error["message"]?.toString() ?? 'Unprocessable Entity';
      case 500:
        return 'Internal Server Error';

      default:
        return 'Oops, something went wrong';
    }
  }

  @override
  String toString() => message;
}
