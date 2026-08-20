import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/wallet_provider.dart';
import '../../../models/service_request.dart';
import '../../wallet/widgets/unlock_request_dialog.dart';

class ProviderHomeScreen extends ConsumerWidget {
  const ProviderHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final wallet = ref.watch(walletProvider);
    final requests = ref.watch(serviceRequestsProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppTheme.border,
                    child: const Icon(Icons.person, color: AppTheme.muted, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              user.fullName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.ink),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.green.withValues(alpha: .15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text('Verified', style: TextStyle(color: AppTheme.green, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Text('Service Provider Dashboard', style: TextStyle(color: AppTheme.muted, fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.push('/notifications'),
                    icon: const Icon(Icons.notifications_none_rounded, size: 28),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Wallet & Credits Widget Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF27A148), Color(0xFF8CC63F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.green.withValues(alpha: .2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 28),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Wallet Credit Balance', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                Text(
                                  '${wallet.creditBalance} Credits',
                                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                          ],
                        ),
                        OutlinedButton(
                          onPressed: () => context.push('/wallet'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                          child: const Text('Manage Wallet'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3 Quick Stats Pills
              Row(
                children: [
                  Expanded(child: _ProviderStatCard(title: 'Completed', value: '89', icon: Icons.check_circle_outline)),
                  const SizedBox(width: 10),
                  Expanded(child: _ProviderStatCard(title: 'Active Jobs', value: '2', icon: Icons.work_outline)),
                  const SizedBox(width: 10),
                  Expanded(child: _ProviderStatCard(title: 'Wallet Cr', value: '${wallet.creditBalance}', icon: Icons.stars_outlined)),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                'Incoming Service Leads & Requests',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.ink),
              ),
              const SizedBox(height: 14),

              // Incoming Service Request Cards
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: requests.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final req = requests[index];
                  return _ProviderRequestCard(request: req);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProviderStatCard extends StatelessWidget {
  const _ProviderStatCard({required this.title, required this.value, required this.icon});
  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFF2F6)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.green, size: 22),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.ink)),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(fontSize: 11, color: AppTheme.muted, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ProviderRequestCard extends ConsumerWidget {
  const _ProviderRequestCard({required this.request});
  final ServiceRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFF2F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                request.serviceTitle,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.ink),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.blue.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${request.unlockCreditCost} Cr Lead',
                  style: const TextStyle(color: AppTheme.blue, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(request.description, style: const TextStyle(color: AppTheme.muted, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.muted),
              const SizedBox(width: 4),
              Text(
                request.isUnlockedByProvider ? request.location : 'Location: Hidden (Unlock Lead to View)',
                style: TextStyle(
                  fontSize: 12,
                  color: request.isUnlockedByProvider ? AppTheme.ink : AppTheme.muted,
                  fontWeight: request.isUnlockedByProvider ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Unlock CTA or Accepted Status
          if (!request.isUnlockedByProvider)
            SizedBox(
              width: double.infinity,
              height: 44,
              child: FilledButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => UnlockRequestDialog(request: request),
                  );
                },
                icon: const Icon(Icons.lock_open_rounded, size: 18),
                label: Text('Unlock Contact Details (${request.unlockCreditCost} Credits)'),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/chat-conversation/${request.providerId}'),
                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                    label: const Text('Chat Customer'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      ref.read(serviceRequestsProvider.notifier).updateStatus(request.id, RequestStatus.inProgress);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Service marked as In Progress')),
                      );
                    },
                    child: const Text('Start Work'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
