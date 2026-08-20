import 'package:go_router/go_router.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/landing_screen.dart';
import '../features/auth/screens/sign_in_screen.dart';
import '../features/auth/screens/sign_up_screen.dart';
import '../features/auth/screens/provider_sign_up_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash', builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(path: '/landing', builder: (context, state) => const LandingScreen()),
    GoRoute(path: '/sign-in', builder: (context, state) => const SignInScreen()),
    GoRoute(path: '/sign-up', builder: (context, state) => const SignUpScreen()),
    GoRoute(path: '/provider-sign-up', builder: (context, state) => const ProviderSignUpScreen()),
    GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
    GoRoute(path: '/', redirect: (_, __) => '/splash',
    ),
  ],
);
