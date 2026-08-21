import 'package:dio/dio.dart';

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

  // Dio's default browser error is a misleading CORS message when the API
  // process is stopped. Keep the actual request URL available for diagnostics.

  final Dio dio;
}
