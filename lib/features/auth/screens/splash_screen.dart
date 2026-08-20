import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/auth_widgets.dart';

class SplashScreen extends StatefulWidget { const SplashScreen({super.key}); @override State<SplashScreen> createState() => _SplashScreenState(); }
class _SplashScreenState extends State<SplashScreen> { @override void initState() { super.initState(); Future.delayed(const Duration(milliseconds: 1800), () { if (mounted) context.go('/landing'); }); } @override Widget build(BuildContext context) => const Scaffold(body: Center(child: AuthLogo(width: 280))); }