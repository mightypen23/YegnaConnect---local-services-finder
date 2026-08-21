import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../models/provider_model.dart';
import '../models/category.dart';
import '../models/service_request.dart';
import '../models/notification_model.dart';
import '../core/network/marketplace_api.dart';
import '../core/network/auth_api.dart';
import '../core/network/api_client.dart';
import '../core/constants/app_constants.dart';

final marketplaceApiProvider = Provider<MarketplaceApi>((ref) => MarketplaceApi());
final marketplaceLoadingProvider = StateProvider<bool>((ref) => true);
final marketplaceErrorProvider = StateProvider<String?>((ref) => null);
final categoriesLoadingProvider = StateProvider<bool>((ref) => true);
final categoriesErrorProvider = StateProvider<String?>((ref) => null);

final authApiProvider = Provider<AuthApi>((ref) => AuthApi(ApiClient(baseUrl: AppConstants.apiBaseUrl)));
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) => const FlutterSecureStorage());

class UserNotifier extends StateNotifier<UserModel> {
  UserNotifier(this.ref)
      : super(const UserModel(
          id: 'temp_id',
          fullName: 'Loading...',
          email: '',
          phoneNumber: '',
          location: 'Addis Ababa',
          role: UserRole.customer,
        )) {
    _loadUser();
  }
  
  final Ref ref;

  Future<void> _loadUser() async {
    try {
      final storage = ref.read(secureStorageProvider);
      final token = await storage.read(key: 'auth_token');
      if (token != null) {
        final authApi = ref.read(authApiProvider);
        final user = await authApi.getProfile(token);
        state = user;
      }
    } catch (e) {
      // Error loading user or token invalid
    }
  }

  Future<void> loadFromServer() => _loadUser();

  Future<void> login(String email, String password) async {
    final authApi = ref.read(authApiProvider);
    final response = await authApi.login(email, password);
    final token = response['token'] as String;
    final userJson = response['user'] as Map<String, dynamic>;
    
    await ref.read(secureStorageProvider).write(key: 'auth_token', value: token);
    state = UserModel.fromJson(userJson);
  }

  Future<void> register(String fullName, String email, String password) async {
    final authApi = ref.read(authApiProvider);
    final response = await authApi.register(fullName, email, password);
    final token = response['token'] as String;
    final userJson = response['user'] as Map<String, dynamic>;
    
    await ref.read(secureStorageProvider).write(key: 'auth_token', value: token);
    state = UserModel.fromJson(userJson);
  }

  Future<void> logout() async {
    await ref.read(secureStorageProvider).delete(key: 'auth_token');
    state = const UserModel(
      id: 'temp_id',
      fullName: 'Logged Out',
      email: '',
      phoneNumber: '',
      location: 'Addis Ababa',
      role: UserRole.customer,
    );
  }

  void toggleRole() {
    final nextRole = state.role == UserRole.customer ? UserRole.provider : UserRole.customer;
    state = state.copyWith(role: nextRole);
  }

  Future<void> updateProfile({String? fullName, String? phoneNumber, String? location, String? profileImage}) async {
    final token = await ref.read(secureStorageProvider).read(key: 'auth_token');
    if (token == null) return;
    final updated = await ref.read(authApiProvider).updateProfile(token, fullName: fullName, phoneNumber: phoneNumber, profileImage: profileImage);
    state = updated.copyWith(location: location ?? state.location);
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserModel>((ref) {
  return UserNotifier(ref);
});

// Categories Provider
class CategoriesNotifier extends StateNotifier<List<ServiceCategory>> {
  CategoriesNotifier(this.ref) : super(const []) { load(); }
  final Ref ref;
  Future<void> load() async {
    ref.read(categoriesLoadingProvider.notifier).state = true;
    ref.read(categoriesErrorProvider.notifier).state = null;
    try {
      state = await ref.read(marketplaceApiProvider).getCategories();
    } catch (_) {
      ref.read(categoriesErrorProvider.notifier).state = 'Unable to load service categories.';
    } finally {
      ref.read(categoriesLoadingProvider.notifier).state = false;
    }
  }
}
final categoriesProvider = StateNotifierProvider<CategoriesNotifier, List<ServiceCategory>>((ref) => CategoriesNotifier(ref));

// API-backed provider directory
class ProviderSearchNotifier extends StateNotifier<List<ProviderModel>> {
  ProviderSearchNotifier(this.ref) : super(const []) { load(); }
  final Ref ref;
  Future<void> load() async {
    try { state = await ref.read(marketplaceApiProvider).getProviders(); }
    catch (_) { ref.read(marketplaceErrorProvider.notifier).state = 'Unable to load providers. Check your connection.'; }
    finally { ref.read(marketplaceLoadingProvider.notifier).state = false; }
  }

  void filterProviders({
    String query = '',
    String? categoryId,
    double maxDistance = 50.0,
    double minRating = 0.0,
    bool verifiedOnly = false,
  }) {
    // Search filtering helper
  }
}

final providerSearchProvider =
    StateNotifierProvider<ProviderSearchNotifier, List<ProviderModel>>((ref) {
  return ProviderSearchNotifier(ref);
});

// Selected Category Filter State
final selectedCategoryFilterProvider = StateProvider<String?>((ref) => null);
final searchQueryProvider = StateProvider<String>((ref) => '');

// Filtered Providers Provider
final filteredProvidersProvider = Provider<List<ProviderModel>>((ref) {
  final providers = ref.watch(providerSearchProvider);
  final category = ref.watch(selectedCategoryFilterProvider);
  final categories = ref.watch(categoriesProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final selectedCategoryName = categories.where((item) => item.id == category).isEmpty
      ? null
      : categories.firstWhere((item) => item.id == category).title.toLowerCase();

  return providers.where((p) {
    final matchesQuery = query.isEmpty ||
        p.fullName.toLowerCase().contains(query) ||
        p.services.any((s) => s.toLowerCase().contains(query));

    final matchesCategory = selectedCategoryName == null ||
        p.services.any((s) => s.toLowerCase() == selectedCategoryName);

    return matchesQuery && matchesCategory;
  }).toList();
});

// Service Requests Notifier
class ServiceRequestsNotifier extends StateNotifier<List<ServiceRequest>> {
  ServiceRequestsNotifier(this.ref) : super(const []) { load(); }
  final Ref ref;

  Future<void> load() async {
    final token = await ref.read(secureStorageProvider).read(key: 'auth_token');
    if (token == null) return;
    try {
      final role = ref.read(userProvider).role;
      state = role == UserRole.provider
          ? await ref.read(marketplaceApiProvider).getProviderRequests(token)
          : await ref.read(marketplaceApiProvider).getMyRequests(token);
    } catch (_) {}
  }

  Future<bool> create({required String categoryId, required String description, String? providerId}) async {
    final token = await ref.read(secureStorageProvider).read(key: 'auth_token');
    if (token == null) return false;
    try {
      final request = await ref.read(marketplaceApiProvider).createRequest(token: token, categoryId: categoryId, description: description, providerId: providerId);
      state = [request, ...state];
      return true;
    } catch (_) { return false; }
  }

  void addRequest(ServiceRequest request) {
    state = [request, ...state];
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
}

final serviceRequestsProvider =
    StateNotifierProvider<ServiceRequestsNotifier, List<ServiceRequest>>((ref) {
  return ServiceRequestsNotifier(ref);
});

// Notifications Notifier
class NotificationsNotifier extends StateNotifier<List<AppNotification>> {
  NotificationsNotifier() : super(const []);

  void markAllRead() {
    state = state.map((n) => n.copyWith(isRead: true)).toList();
  }

  void addNotification(AppNotification notification) {
    state = [notification, ...state];
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<AppNotification>>((ref) {
  return NotificationsNotifier();
});
