import 'package:dio/dio.dart';
import '../../models/category.dart';
import '../../models/provider_model.dart';
import '../constants/app_constants.dart';
import 'api_client.dart';
import '../../models/service_request.dart';

class MarketplaceApi {
  MarketplaceApi() : _client = ApiClient(baseUrl: AppConstants.apiBaseUrl);
  final ApiClient _client;

  Future<List<ServiceCategory>> getCategories() async {
    final response = await _client.dio.get('/categories');
    return (response.data['categories'] as List<dynamic>? ?? [])
        .map((item) => ServiceCategory.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<List<ProviderModel>> getProviders() async {
    final response = await _client.dio.get('/providers');
    return (response.data['providers'] as List<dynamic>? ?? [])
        .map((item) => ProviderModel.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<List<ServiceRequest>> getMyRequests(String token) async {
    final response = await _client.dio.get('/requests/me', options: Options(headers: {'Authorization': 'Bearer $token'}));
    return (response.data['data'] as List<dynamic>? ?? [])
        .map((item) => ServiceRequest.fromApiJson(Map<String, dynamic>.from(item as Map))).toList();
  }

  Future<List<ServiceRequest>> getProviderRequests(String token) async {
    final response = await _client.dio.get('/requests/provider', options: Options(headers: {'Authorization': 'Bearer $token'}));
    return (response.data['data'] as List<dynamic>? ?? [])
        .map((item) => ServiceRequest.fromApiJson(Map<String, dynamic>.from(item as Map))).toList();
  }

  Future<ServiceRequest> createRequest({required String token, required String categoryId, required String description, String? providerId}) async {
    final response = await _client.dio.post('/requests', data: {'category_id': categoryId, 'description': description, 'provider_id': ?providerId}, options: Options(headers: {'Authorization': 'Bearer $token'}));
    return ServiceRequest.fromApiJson(Map<String, dynamic>.from(response.data['data'] as Map));
  }

  Future<int> getWalletBalance(String token) async {
    final response = await _client.dio.get('/credits/balance', options: Options(headers: {'Authorization': 'Bearer $token'}));
    return (response.data['data']['balance'] as num).toInt();
  }

  Future<Map<String, dynamic>> createProvider({required String token, required String fullName, required String phoneNumber, required String bio, required String categoryId, required String location}) async {
    try {
      final response = await _client.dio.post('/providers', data: {
        'bio': bio,
        'full_name': fullName,
        'phone_number': phoneNumber,
        'categories': [{'id': categoryId, 'skill_level': 'intermediate'}],
        'location': {'address': location, 'city': location, 'region': 'Addis Ababa', 'latitude': 9.0192, 'longitude': 38.7525},
      }, options: Options(headers: {'Authorization': 'Bearer $token'}));
      return Map<String, dynamic>.from(response.data['provider'] as Map);
    } on DioException catch (error) {
      final data = error.response?.data;
      final message = data is Map && data['error'] != null
          ? data['error'].toString()
          : 'Provider request failed (${error.response?.statusCode ?? 'network error'})';
      throw Exception(message);
    }
  }
}
