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

  final Dio dio;
}