import 'package:dio/dio.dart';
import '../../models/user_model.dart';
import 'api_client.dart';

class AuthApi {
  AuthApi(this._client);
  final ApiClient _client;

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _client.dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> register(String fullName, String email, String password) async {
    final response = await _client.dio.post('/auth/register', data: {
      'full_name': fullName,
      'email': email,
      'password': password,
    });
    return response.data;
  }

  Future<UserModel> getProfile(String token) async {
    final response = await _client.dio.get('/auth/me', 
      options: Options(headers: {'Authorization': 'Bearer $token'})
    );
    return UserModel.fromJson(response.data['user'] as Map<String, dynamic>);
  }

  Future<UserModel> updateProfile(String token, {String? fullName, String? phoneNumber, String? location}) async {
    try {
      final response = await _client.dio.put('/auth/me', data: {
        'full_name': ?fullName,
        'phone_number': ?phoneNumber,
        'location': ?location,
      }, options: Options(headers: {'Authorization': 'Bearer $token'}));
      return UserModel.fromJson(Map<String, dynamic>.from(response.data['user'] as Map));
    } on DioException catch (error) {
      final data = error.response?.data;
      final message = data is Map && data['error'] != null
          ? data['error'].toString()
          : 'Profile update failed (${error.response?.statusCode ?? 'network error'})';
      throw Exception(message);
    }
  }
}
