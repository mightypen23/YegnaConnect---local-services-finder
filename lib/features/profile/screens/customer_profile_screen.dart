import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/user_model.dart';

class CustomerProfileScreen extends ConsumerWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final isProvider = user.role == UserRole.provider;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            // Top Green Gradient Header with Avatar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 44, 20, 24),
              decoration: const BoxDecoration(
                gradient: AppTheme.headerGradient,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppTheme.ink),
                        onPressed: () => context.go('/home'),
                      ),
                      const Expanded(
                        child: Text(
                          'Profile',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: AppTheme.ink,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Avatar with Edit Button
                  GestureDetector(
                    onTap: () {
                      if (isProvider) {
                        context.push('/provider-profile-edit');
                      } else {
                        context.push('/customer-profile-edit');
                      }
                    },
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 54,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: AppTheme.border,
                            child: const Icon(Icons.person, size: 55, color: AppTheme.muted),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppTheme.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, color: Colors.white, size: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.fullName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.ink,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location Box
                  _InfoCard(
                    icon: Icons.location_on_outlined,
                    text: user.location,
                  ),
                  const SizedBox(height: 12),

                  // Phone Box
                  _InfoCard(
                    icon: Icons.phone_outlined,
                    text: user.phoneNumber,
                  ),
                  const SizedBox(height: 20),

                  // Action Buttons
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        if (isProvider) {
                          context.push('/provider-profile-edit');
                        } else {
                          context.push('/customer-profile-edit');
                        }
                      },
                      child: const Text('Edit Profile'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () async {
                        await ref.read(authProvider.notifier).logout();
                        if (context.mounted) {
                          context.go('/landing');
                        }
                      },
                      icon: const Icon(Icons.logout, color: AppTheme.accentRed),
                      label: const Text('Sign Out', style: TextStyle(color: AppTheme.accentRed, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFF2F6)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.muted, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
                color: AppTheme.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}