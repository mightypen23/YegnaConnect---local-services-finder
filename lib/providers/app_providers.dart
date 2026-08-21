import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../models/user_model.dart';
import '../models/provider_model.dart';
import '../models/category.dart';
import '../models/service_request.dart';
import '../models/notification_model.dart';
import 'network_providers.dart';

// Current User State Provider
class UserNotifier extends StateNotifier<UserModel> {
  UserNotifier() : super(_guest);

  static const _guest = UserModel(
    id: '',
    fullName: '',
    email: '',
    phoneNumber: '',
    location: '',
    role: UserRole.customer,
  );

  void updateProfile({
    String? fullName,
    String? phoneNumber,
    String? location,
    UserRole? role,
  }) {
    state = state.copyWith(
      fullName: fullName,
      phoneNumber: phoneNumber,
      location: location,
      role: role,
    );
  }

  void toggleRole() {
    final nextRole = state.role == UserRole.customer ? UserRole.provider : UserRole.customer;
    state = state.copyWith(role: nextRole);
  }

  // Replaces the in-memory user with the authenticated backend profile.
  void setUser(UserModel user) {
    state = user;
  }

  void clearUser() {
    state = _guest;
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserModel>((ref) {
  return UserNotifier();
});

// Categories Provider - fetched from the backend, falling back to the
// bundled defaults if the request fails (e.g. offline).
final categoriesProvider = FutureProvider<List<ServiceCategory>>((ref) async {
  final api = ref.watch(apiClientProvider);
  try {
    final response = await api.dio.get('/categories');
    final categories = (response.data['categories'] as List<dynamic>)
        .map<ServiceCategory>((json) => ServiceCategory.fromJson(json as Map<String, dynamic>))
        .toList();
    return categories.isEmpty ? ServiceCategory.defaultCategories : categories;
  } catch (_) {
    return ServiceCategory.defaultCategories;
  }
});

// Providers List Provider - fetched from the backend.
class ProviderSearchNotifier extends StateNotifier<List<ProviderModel>> {
  ProviderSearchNotifier(this._ref) : super(const []) {
    _fetchProviders();
  }

  final Ref _ref;

  Future<void> _fetchProviders() async {
    final api = _ref.read(apiClientProvider);
    try {
      final response = await api.dio.get('/providers');
      final providers = (response.data['providers'] as List<dynamic>)
          .map<ProviderModel>((json) => ProviderModel.fromJson(json as Map<String, dynamic>))
          .toList();
      state = providers;
    } catch (_) {
      // Keep the empty state; screens already handle an empty provider list.
    }
  }
}

final providerSearchProvider =
    StateNotifierProvider<ProviderSearchNotifier, List<ProviderModel>>((ref) {
  return ProviderSearchNotifier(ref);
});

// Filter State
final selectedCategoryFilterProvider = StateProvider<String?>((ref) => null);
final searchQueryProvider = StateProvider<String>((ref) => '');
final maxDistanceProvider = StateProvider<double>((ref) => 50.0);
final minRatingProvider = StateProvider<double>((ref) => 0.0);
final verifiedOnlyProvider = StateProvider<bool>((ref) => false);

// Filtered Providers Provider
final filteredProvidersProvider = Provider<List<ProviderModel>>((ref) {
  final providers = ref.watch(providerSearchProvider);
  final category = ref.watch(selectedCategoryFilterProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final maxDistance = ref.watch(maxDistanceProvider);
  final minRating = ref.watch(minRatingProvider);
  final verifiedOnly = ref.watch(verifiedOnlyProvider);

  return providers.where((p) {
    final matchesQuery = query.isEmpty ||
        p.fullName.toLowerCase().contains(query) ||
        p.services.any((s) => s.toLowerCase().contains(query));

    final matchesCategory = category == null ||
        category.isEmpty ||
        p.services.any((s) => s.toLowerCase() == category.toLowerCase());

    final matchesDistance = p.distanceKm <= maxDistance;
    final matchesRating = p.rating >= minRating;
    final matchesVerified = !verifiedOnly || p.isVerified;

    return matchesQuery && matchesCategory && matchesDistance && matchesRating && matchesVerified;
  }).toList();
});

// Service Requests Notifier - fetched from the backend for the current
// user's role (customer's own requests, or a provider's incoming requests).
class ServiceRequestsNotifier extends StateNotifier<List<ServiceRequest>> {
  ServiceRequestsNotifier(this._ref) : super(const []) {
    refresh();
  }

  final Ref _ref;

  Future<void> refresh() async {
    final api = _ref.read(apiClientProvider);
    final role = _ref.read(userProvider).role;
    final endpoint = role == UserRole.provider ? '/requests/provider' : '/requests/me';
    try {
      final response = await api.dio.get(endpoint);
      final requests = (response.data['data'] as List<dynamic>)
          .map((json) => ServiceRequest.fromApiJson(json as Map<String, dynamic>))
          .toList();
      state = requests;
    } catch (_) {
      // Keep the current state; screens already handle an empty request list.
    }
  }

  void addRequest(ServiceRequest request) {
    state = [request, ...state];
  }

  // Creates a service request via POST /api/requests and prepends it on success.
  Future<void> createRequest({
    required String categoryId,
    String? description,
    String? providerId,
    double? latitude,
    double? longitude,
  }) async {
    final api = _ref.read(apiClientProvider);
    try {
      final response = await api.dio.post('/requests', data: {
        'category_id': categoryId,
        'description': ?description,
        'provider_id': ?providerId,
        'latitude': ?latitude,
        'longitude': ?longitude,
      });
      final request = ServiceRequest.fromApiJson(response.data['data'] as Map<String, dynamic>);
      state = [request, ...state];
    } on DioException catch (e) {
      throw ApiClient.toApiException(e);
    }
  }

  void updateStatus(String requestId, RequestStatus newStatus) {
    state = state.map((r) {
      if (r.id == requestId) {
        return r.copyWith(status: newStatus);
      }
      return r;
    }).toList();
  }

  void unlockRequest(String requestId) {
    state = state.map((r) {
      if (r.id == requestId) {
        return r.copyWith(isUnlockedByProvider: true);
      }
      return r;
    }).toList();
  }

  // Replaces a request in state with the server's version returned by an action endpoint.
  void _replaceWithApiResult(dynamic data) {
    final updated = ServiceRequest.fromApiJson(data as Map<String, dynamic>);
    state = state.map((r) => r.id == updated.id ? updated : r).toList();
  }

  // Provider accepts a pending request via PATCH /api/requests/:id/accept
  // (this is what "unlocks" the lead and spends the provider's credit).
  Future<void> acceptRequest(String requestId) async {
    final api = _ref.read(apiClientProvider);
    try {
      final response = await api.dio.patch('/requests/$requestId/accept');
      _replaceWithApiResult(response.data['data']);
    } on DioException catch (e) {
      throw ApiClient.toApiException(e);
    }
  }

  // Provider marks an accepted/in-progress request as completed.
  Future<void> completeRequest(String requestId) async {
    final api = _ref.read(apiClientProvider);
    try {
      final response = await api.dio.patch('/requests/$requestId/complete');
      _replaceWithApiResult(response.data['data']);
    } on DioException catch (e) {
      throw ApiClient.toApiException(e);
    }
  }

  // Customer or provider cancels a request.
  Future<void> cancelRequest(String requestId, {String? reason}) async {
    final api = _ref.read(apiClientProvider);
    try {
      final response = await api.dio.patch('/requests/$requestId/cancel', data: {
        'reason': ?reason,
      });
      _replaceWithApiResult(response.data['data']);
    } on DioException catch (e) {
      throw ApiClient.toApiException(e);
    }
  }
}

final serviceRequestsProvider =
    StateNotifierProvider<ServiceRequestsNotifier, List<ServiceRequest>>((ref) {
  return ServiceRequestsNotifier(ref);
});

// Notifications Notifier
class NotificationsNotifier extends StateNotifier<List<AppNotification>> {
  NotificationsNotifier(this._ref) : super(const []) {
    refresh();
  }

  final Ref _ref;
  int _page = 1;
  bool _hasMore = true;
  static const _pageSize = 20;

  bool get hasMore => _hasMore;

  Future<void> refresh() async {
    _page = 1;
    _hasMore = true;
    final api = _ref.read(apiClientProvider);
    try {
      final response = await api.dio.get('/notifications', queryParameters: {'page': 1, 'limit': _pageSize});
      final notifications = (response.data['data'] as List<dynamic>)
          .map((json) => AppNotification.fromJson(json as Map<String, dynamic>))
          .toList();
      state = notifications;
      _hasMore = notifications.length >= _pageSize;
    } catch (_) {
      // Keep current state on failure
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore) return;
    _page++;
    final api = _ref.read(apiClientProvider);
    try {
      final response = await api.dio.get('/notifications', queryParameters: {'page': _page, 'limit': _pageSize});
      final notifications = (response.data['data'] as List<dynamic>)
          .map((json) => AppNotification.fromJson(json as Map<String, dynamic>))
          .toList();
      state = [...state, ...notifications];
      _hasMore = notifications.length >= _pageSize;
    } catch (_) {
      _page--; // Revert page increment on failure
    }
  }

  Future<void> markAllRead() async {
    final api = _ref.read(apiClientProvider);
    try {
      await api.dio.patch('/notifications/read-all');
      state = state.map((n) => n.copyWith(isRead: true)).toList();
    } catch (_) {
      // Ignore network errors; local state unchanged
    }
  }

  Future<void> markRead(String id) async {
    final api = _ref.read(apiClientProvider);
    try {
      await api.dio.patch('/notifications/$id/read');
      state = state.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList();
    } catch (_) {
      // Ignore network errors; local state unchanged
    }
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<AppNotification>>((ref) {
  return NotificationsNotifier(ref);
});
