import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';
import '../widgets/auth_widgets.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigation is handled by the router's auth redirect once this resolves.
    Future.microtask(() => ref.read(authProvider.notifier).restoreSession());
  }

  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: AuthLogo(width: 280)));
}