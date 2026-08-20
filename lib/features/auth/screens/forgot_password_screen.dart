import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../widgets/auth_widgets.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back)),
              const SizedBox(height: 25),
              const Center(child: AuthLogo(width: 140)),
              const SizedBox(height: 28),
              const Text('Reset your password', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.ink)),
              const SizedBox(height: 8),
              const Text('Enter your email and we’ll send you a reset link.', style: TextStyle(color: AppTheme.muted, fontSize: 15)),
              const SizedBox(height: 24),
              const AuthField(label: 'Email address', icon: Icons.mail_outline),
              const SizedBox(height: 18),
              AuthButton(label: 'Send reset link', onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
