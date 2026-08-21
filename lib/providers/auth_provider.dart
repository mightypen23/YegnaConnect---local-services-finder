import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../core/storage/token_storage.dart';
import '../models/user_model.dart';
import 'app_providers.dart';
import 'network_providers.dart';

export 'network_providers.dart' show apiClientProvider, tokenStorageProvider;

enum AuthStatus { unknown, authenticating, authenticated, unauthenticated }

class AuthState {
  const AuthState({required this.status, this.errorMessage});

  const AuthState.unknown() : this(status: AuthStatus.unknown);
  const AuthState.authenticating() : this(status: AuthStatus.authenticating);
  const AuthState.authenticated() : this(status: AuthStatus.authenticated);
  const AuthState.unauthenticated([String? message]) : this(status: AuthStatus.unauthenticated, errorMessage: message);

  final AuthStatus status;
  final String? errorMessage;
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._ref) : super(const AuthState.unknown());

  final Ref _ref;

  ApiClient get _api => _ref.read(apiClientProvider);
  TokenStorage get _tokenStorage => _ref.read(tokenStorageProvider);

  Future<void> restoreSession() async {
    // Only meaningful on a cold start; re-entry would overwrite a live session.
    if (state.status != AuthStatus.unknown) return;
    try {
      final token = await _tokenStorage.readToken();
      if (token == null) {
        _ref.read(userProvider.notifier).clearUser();
        state = const AuthState.unauthenticated();
        return;
      }
      final response = await _api.dio.get('/auth/me');
      final user = UserModel.fromJson(response.data['user'] as Map<String, dynamic>);
      _ref.read(userProvider.notifier).setUser(user);
      state = const AuthState.authenticated();
    } on DioException {
      await _clearSession();
      state = const AuthState.unauthenticated();
    } catch (_) {
      await _clearSession();
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = const AuthState.authenticating();
    try {
      final response = await _api.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      await _handleAuthSuccess(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final apiException = ApiClient.toApiException(e);
      await _clearSession();
      state = AuthState.unauthenticated(apiException.message);
      throw apiException;
    }
  }

  Future<void> register({required String fullName, required String email, required String password}) async {
    state = const AuthState.authenticating();
    try {
      final response = await _api.dio.post('/auth/register', data: {
        'full_name': fullName,
        'email': email,
        'password': password,
      });
      await _handleAuthSuccess(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final apiException = ApiClient.toApiException(e);
      await _clearSession();
      state = AuthState.unauthenticated(apiException.message);
      throw apiException;
    }
  }

  // Creates the account and its provider profile as one unit. The session is
  // only published once the profile exists, so the router never sees a
  // half-built provider as a customer and routes them to the wrong home.
  Future<void> registerProvider({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
    required String location,
    required String bio,
    required String categoryId,
  }) async {
    state = const AuthState.authenticating();
    try {
      final registration = await _api.dio.post('/auth/register', data: {
        'full_name': fullName,
        'email': email,
        'password': password,
      });
      await _tokenStorage.saveToken(registration.data['token'] as String);

      final providerRes = await _api.dio.post('/providers', data: {
        'bio': bio,
        'full_name': fullName,
        'phone_number': phoneNumber,
        'location': location,
        'categories': [
          {'id': categoryId},
        ],
      });

      final providerData = providerRes.data != null ? providerRes.data['provider'] as Map<String, dynamic>? : null;
      final providerId = providerData?['id']?.toString();

      if (providerId != null) {
        await _api.dio.put('/providers/$providerId/location', data: {
          'address': location,
          'city': location,
          'region': 'Addis Ababa',
          'latitude': 9.0192,
          'longitude': 38.7525,
        });
      }

      await _api.dio.put('/auth/me', data: {
        'phone_number': phoneNumber,
        'location': location,
      });

      final me = await _api.dio.get('/auth/me');
      _ref.read(userProvider.notifier).setUser(UserModel.fromJson(me.data['user'] as Map<String, dynamic>));
      state = const AuthState.authenticated();
    } on DioException catch (e) {
      final apiException = ApiClient.toApiException(e);
      await _clearSession();
      state = AuthState.unauthenticated(apiException.message);
      throw apiException;
    }
  }

  Future<void> _handleAuthSuccess(Map<String, dynamic> data) async {
    final token = data['token'] as String;
    await _tokenStorage.saveToken(token);
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    _ref.read(userProvider.notifier).setUser(user);
    state = const AuthState.authenticated();
  }

  // Drops any previously stored credentials so a failed attempt can never
  // leave the app running on a stale session.
  Future<void> _clearSession() async {
    await _tokenStorage.clearToken();
    _ref.read(userProvider.notifier).clearUser();
  }

  Future<void> logout() async {
    await _clearSession();
    state = const AuthState.unauthenticated();
  }

  Future<void> updateProfile({String? fullName, String? phoneNumber, String? location}) async {
    try {
      final response = await _api.dio.put('/auth/me', data: {
        'full_name': ?fullName,
        'phone_number': ?phoneNumber,
        'location': ?location,
      });
      final user = UserModel.fromJson(response.data['user'] as Map<String, dynamic>);
      _ref.read(userProvider.notifier).setUser(user);
    } on DioException catch (e) {
      throw ApiClient.toApiException(e);
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
