import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/provider_model.dart';
import '../models/category.dart';
import '../models/service_request.dart';
import '../models/chat_message.dart';
import '../models/notification_model.dart';
import '../models/review.dart';

// Current User State Provider
class UserNotifier extends StateNotifier<UserModel> {
  UserNotifier()
      : super(const UserModel(
          id: 'usr_001',
          fullName: 'Jhon Sheferaw',
          email: 'jhon.sheferaw@gmail.com',
          phoneNumber: '+251-912345678',
          location: 'Mexico, Addis Ababa',
          role: UserRole.customer,
        ));

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
}

final userProvider = StateNotifierProvider<UserNotifier, UserModel>((ref) {
  return UserNotifier();
});

// Categories Provider
final categoriesProvider = Provider<List<ServiceCategory>>((ref) {
  return ServiceCategory.defaultCategories;
});

// Mock Providers List Provider
class ProviderSearchNotifier extends StateNotifier<List<ProviderModel>> {
  ProviderSearchNotifier()
      : super([
          const ProviderModel(
            id: 'prov_1',
            userId: 'u_solomon',
            fullName: 'Solomon Getaw',
            phoneNumber: '+251-912345678',
            location: 'Kality, Addis Ababa',
            bio: 'Experienced TV & Dish technician with over 6 years fixing signal issues and home installations.',
            rating: 4.0,
            reviewCount: 1200,
            skillsCount: 6,
            completedOrders: 89,
            totalOrders: 94,
            services: ['Tv/Dish', 'Electrician', 'Plumber', 'Painting'],
            isVerified: true,
            distanceKm: 1.2,
          ),
          const ProviderModel(
            id: 'prov_2',
            userId: 'u_nardos',
            fullName: 'Nardos Tesfaye',
            phoneNumber: '+251-911223344',
            location: 'Bole, Addis Ababa',
            bio: 'Professional electrician providing safe wiring, circuit repair, and light fitting.',
            rating: 4.8,
            reviewCount: 450,
            skillsCount: 4,
            completedOrders: 142,
            totalOrders: 145,
            services: ['Electrician', 'Plumber'],
            isVerified: true,
            distanceKm: 2.5,
          ),
          const ProviderModel(
            id: 'prov_3',
            userId: 'u_abebe',
            fullName: 'Abebe Sheferaw',
            phoneNumber: '+251-922334455',
            location: 'Sarbet, Addis Ababa',
            bio: 'Expert plumber handling emergency leaks, pipe replacement, and bathroom fittings.',
            rating: 4.5,
            reviewCount: 310,
            skillsCount: 5,
            completedOrders: 78,
            totalOrders: 82,
            services: ['Plumber', 'Cleaning'],
            isVerified: true,
            distanceKm: 3.8,
          ),
          const ProviderModel(
            id: 'prov_4',
            userId: 'u_sitota',
            fullName: 'Sitota Tesfaw',
            phoneNumber: '+251-933445566',
            location: 'Kazanchis, Addis Ababa',
            bio: 'Interior and exterior painter. Clean work with top quality paints.',
            rating: 4.2,
            reviewCount: 190,
            skillsCount: 3,
            completedOrders: 54,
            totalOrders: 58,
            services: ['Painting', 'Cleaning'],
            isVerified: false,
            distanceKm: 4.1,
          ),
        ]);

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
  return ProviderSearchNotifier();
});

// Selected Category Filter State
final selectedCategoryFilterProvider = StateProvider<String?>((ref) => null);
final searchQueryProvider = StateProvider<String>((ref) => '');

// Filtered Providers Provider
final filteredProvidersProvider = Provider<List<ProviderModel>>((ref) {
  final providers = ref.watch(providerSearchProvider);
  final category = ref.watch(selectedCategoryFilterProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();

  return providers.where((p) {
    final matchesQuery = query.isEmpty ||
        p.fullName.toLowerCase().contains(query) ||
        p.services.any((s) => s.toLowerCase().contains(query));

    final matchesCategory = category == null ||
        category.isEmpty ||
        p.services.any((s) => s.toLowerCase() == category.toLowerCase());

    return matchesQuery && matchesCategory;
  }).toList();
});

// Service Requests Notifier
class ServiceRequestsNotifier extends StateNotifier<List<ServiceRequest>> {
  ServiceRequestsNotifier()
      : super([
          ServiceRequest(
            id: 'req_101',
            customerId: 'usr_001',
            customerName: 'Jhon Sheferaw',
            providerId: 'prov_1',
            providerName: 'Solomon Getaw',
            categoryId: 'tvdish',
            serviceTitle: 'Fix TV Signal & Antenna',
            description: 'My dish signal is completely lost after heavy rain.',
            location: 'Bole, back of Skylight hotel',
            status: RequestStatus.accepted,
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
            scheduledAt: DateTime.now().add(const Duration(hours: 4)),
            isUnlockedByProvider: true,
            syncToken: 'sync_101',
          ),
          ServiceRequest(
            id: 'req_102',
            customerId: 'usr_001',
            customerName: 'Jhon Sheferaw',
            providerId: 'prov_1',
            providerName: 'Solomon Getaw',
            categoryId: 'electrician',
            serviceTitle: 'Main Switch Box Repair',
            description: 'Fuse trips whenever electric stove is turned on.',
            location: 'Mexico, Addis Ababa',
            status: RequestStatus.pending,
            createdAt: DateTime.now().subtract(const Duration(hours: 5)),
            scheduledAt: DateTime.now().add(const Duration(days: 1)),
            isUnlockedByProvider: false,
            unlockCreditCost: 5,
            syncToken: 'sync_102',
          ),
        ]);

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
  return ServiceRequestsNotifier();
});

// Notifications Notifier
class NotificationsNotifier extends StateNotifier<List<AppNotification>> {
  NotificationsNotifier()
      : super([
          AppNotification(
            id: 'notif_1',
            title: 'Request Accepted',
            message: 'Solomon Getaw accepted your request for TV/Dish service.',
            timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
            type: NotificationType.requestStatusChanged,
            isRead: false,
          ),
          AppNotification(
            id: 'notif_2',
            title: 'New Message',
            message: 'Solomon: Yes of course where are you?',
            timestamp: DateTime.now().subtract(const Duration(hours: 1)),
            type: NotificationType.chatMessage,
            isRead: true,
          ),
          AppNotification(
            id: 'notif_3',
            title: 'Credits Added',
            message: '75 credits have been added to your wallet successfully.',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            type: NotificationType.walletCredit,
            isRead: true,
          ),
        ]);

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
