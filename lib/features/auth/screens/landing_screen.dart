import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../widgets/auth_widgets.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 24, 26, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const AuthLogo(width: 190),
              const SizedBox(height: 22),
              Text(
                'Local services, connected.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.ink,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Find trusted people around you for the work that matters.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.muted, fontSize: 15, height: 1.35),
              ),
              const SizedBox(height: 22),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'How will you use YegnaConnect?',
                  style: TextStyle(color: AppTheme.ink, fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 12),
              _RoleChoice(
                icon: Icons.handyman_outlined,
                title: 'I provide services',
                subtitle: 'Offer your skills and grow your local work',
                onPressed: () => context.push('/provider-sign-up'),
              ),
              const SizedBox(height: 12),
              _RoleChoice(
                icon: Icons.search_rounded,
                title: 'I need a service',
                subtitle: 'Find trusted providers near you',
                onPressed: () => context.push('/sign-up'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => context.push('/sign-in'),
                child: const Text('Already have an account? Sign in'),
              ),
              const Spacer(),
              const Text(
                'By continuing, you agree to our Terms and Privacy Policy',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleChoice extends StatelessWidget {
  const _RoleChoice({required this.icon, required this.title, required this.subtitle, required this.onPressed});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.all(14),
          alignment: Alignment.centerLeft,
          side: const BorderSide(color: Color(0xFFD9E2EA)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: AppTheme.green.withValues(alpha: .1), borderRadius: BorderRadius.circular(11)),
              child: Icon(icon, color: AppTheme.green),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.muted),
          ],
        ),
      ),
    );
  }
}
