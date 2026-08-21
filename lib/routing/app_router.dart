import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/widgets/main_navigation_shell.dart';
import '../models/user_model.dart';
import '../providers/app_providers.dart';
import '../providers/auth_provider.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/landing_screen.dart';
import '../features/auth/screens/sign_in_screen.dart';
import '../features/auth/screens/sign_up_screen.dart';
import '../features/auth/screens/provider_sign_up_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/home/screens/customer_home_screen.dart';
import '../features/search/screens/search_screen.dart';
import '../features/provider_detail/screens/provider_detail_screen.dart';
import '../features/bookings/screens/create_booking_screen.dart';
import '../features/bookings/screens/booking_history_screen.dart';
import '../features/bookings/screens/request_detail_screen.dart';
import '../features/chat/screens/chat_list_screen.dart';
import '../features/chat/screens/chat_conversation_screen.dart';
import '../features/profile/screens/customer_profile_screen.dart';
import '../features/profile/screens/customer_profile_edit_screen.dart';
import '../features/profile/screens/provider_profile_edit_screen.dart';
import '../features/provider_dashboard/screens/provider_home_screen.dart';
import '../features/provider_dashboard/screens/provider_verification_screen.dart';
import '../features/wallet/screens/provider_wallet_screen.dart';
import '../features/wallet/screens/buy_credits_screen.dart';
import '../features/notifications/screens/notifications_screen.dart';

// Public routes reachable without an authenticated session.
const _authRoutes = {
  '/splash',
  '/landing',
  '/sign-in',
  '/sign-up',
  '/provider-sign-up',
  '/forgot-password',
};

// Notifies GoRouter to re-evaluate its redirect whenever auth status changes.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen<AuthState>(authProvider, (_, _) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isAuthRoute = _authRoutes.contains(state.matchedLocation);

      if (authState.status == AuthStatus.unknown) {
        return state.matchedLocation == '/splash' ? null : '/splash';
      }

      // Mid-login the user stays on the form, which renders its own progress
      // state. Redirecting here would remount splash and restart the session
      // restore, cancelling the login that is still in flight.
      if (authState.status == AuthStatus.authenticating) {
        return null;
      }

      if (authState.status == AuthStatus.authenticated) {
        if (isAuthRoute) {
          final role = ref.read(userProvider).role;
          return role == UserRole.provider ? '/provider-home' : '/home';
        }
        return null;
      }

      // Unauthenticated: move off splash, but allow other auth routes.
      if (state.matchedLocation == '/splash') {
        return '/landing';
      }
      return isAuthRoute ? null : '/landing';
    },
    routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/landing',
      builder: (context, state) => const LandingScreen(),
    ),
    GoRoute(
      path: '/sign-in',
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: '/sign-up',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/provider-sign-up',
      builder: (context, state) => const ProviderSignUpScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    // Bottom Navigation Shell Route
    ShellRoute(
      builder: (context, state, child) => MainNavigationShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const CustomerHomeScreen(),
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) => const SearchScreen(),
        ),
        GoRoute(
          path: '/chat',
          builder: (context, state) => const ChatListScreen(),
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) => const BookingHistoryScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const CustomerProfileScreen(),
        ),
      ],
    ),

    // Sub-Routes & Provider Screens
    GoRoute(
      path: '/provider-home',
      builder: (context, state) => const ProviderHomeScreen(),
    ),
    GoRoute(
      path: '/provider-detail/:id',
      builder: (context, state) {
        final providerId = state.pathParameters['id'] ?? 'prov_1';
        return ProviderDetailScreen(providerId: providerId);
      },
    ),
    GoRoute(
      path: '/create-booking',
      builder: (context, state) => const CreateBookingScreen(),
    ),
    GoRoute(
      path: '/request-detail/:id',
      builder: (context, state) {
        final requestId = state.pathParameters['id'] ?? 'req_101';
        return RequestDetailScreen(requestId: requestId);
      },
    ),
    GoRoute(
      path: '/chat-conversation/:providerId',
      builder: (context, state) {
        final providerId = state.pathParameters['providerId'] ?? 'prov_1';
        return ChatConversationScreen(providerId: providerId);
      },
    ),
    GoRoute(
      path: '/customer-profile-edit',
      builder: (context, state) => const CustomerProfileEditScreen(),
    ),
    GoRoute(
      path: '/provider-profile-edit',
      builder: (context, state) => const ProviderProfileEditScreen(),
    ),
    GoRoute(
      path: '/wallet',
      builder: (context, state) => const ProviderWalletScreen(),
    ),
    GoRoute(
      path: '/buy-credits',
      builder: (context, state) => const BuyCreditsScreen(),
    ),
    GoRoute(
      path: '/provider-verification',
      builder: (context, state) => const ProviderVerificationScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),

    // Fallback
    GoRoute(
      path: '/',
      redirect: (context, state) => '/splash',
    ),
  ],
  );
});
