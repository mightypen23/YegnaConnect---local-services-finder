import 'package:dio/dio.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({
    required String baseUrl,
  }) : dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {
              'Content-Type': 'application/json',
            },
          ),
        );

  final Dio dio;

  static ApiException toApiException(DioException error) {
    final data = error.response?.data;
    if (data is Map && data['error'] is String) {
      return ApiException(data['error'] as String, statusCode: error.response?.statusCode);
    }
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return ApiException('Could not connect to the server. Check your connection.');
      default:
        return ApiException('Something went wrong. Please try again.', statusCode: error.response?.statusCode);
    }
  }
}