import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../widgets/auth_widgets.dart';

class ProviderSignUpScreen extends StatelessWidget {
  const ProviderSignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back)),
              const SizedBox(height: 10),
              const Center(child: AuthLogo(width: 140)),
              const SizedBox(height: 24),
              const Text('Become a service provider', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800, color: AppTheme.ink)),
              const SizedBox(height: 7),
              const Text('Tell clients about you and the services you offer.', style: TextStyle(color: AppTheme.muted, fontSize: 15)),
              const SizedBox(height: 24),
              const AuthField(label: 'Full name', icon: Icons.person_outline),
              const SizedBox(height: 12),
              const AuthField(label: 'Phone number', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              const AuthField(label: 'Service you provide', icon: Icons.handyman_outlined),
              const SizedBox(height: 12),
              const AuthField(label: 'Service category', icon: Icons.category_outlined),
              const SizedBox(height: 12),
              const AuthField(label: 'Location / city', icon: Icons.location_on_outlined),
              const SizedBox(height: 12),
              const AuthField(label: 'Short description', icon: Icons.notes_outlined),
              const SizedBox(height: 18),
              AuthButton(label: 'Continue', onPressed: () => context.push('/sign-up')),
            ],
          ),
        ),
      ),
    );
  }
}
