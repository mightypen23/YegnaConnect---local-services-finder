import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_client.dart';
import '../../../providers/app_providers.dart';
import '../../../models/provider_model.dart';

class ProviderDetailScreen extends ConsumerWidget {
  const ProviderDetailScreen({
    super.key,
    required this.providerId,
  });

  final String providerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providers = ref.watch(providerSearchProvider);
    if (providers.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final provider = providers.firstWhere(
      (p) => p.id == providerId,
      orElse: () => providers.first,
    );

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
                        onPressed: () => context.pop(),
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
                      const SizedBox(width: 48), // Balance spacing
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Avatar with Green Camera Badge
                  Stack(
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
                  const SizedBox(height: 12),
                  Text(
                    provider.fullName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${provider.rating} ',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: i < provider.rating.floor() ? Colors.amber : Colors.grey.shade300,
                          ),
                        ),
                      ),
                      Text(
                        ' (${provider.reviewCount > 999 ? '1.2k' : provider.reviewCount})',
                        style: const TextStyle(color: AppTheme.muted, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 3 Stats Pills Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatBox(value: '${provider.skillsCount}', label: 'Skills'),
                      _StatBox(value: '${provider.completedOrders}', label: 'completed'),
                      _StatBox(value: '${provider.totalOrders}', label: 'orders'),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Location Box
                  _InfoCard(
                    icon: Icons.location_on_outlined,
                    text: provider.location,
                  ),
                  const SizedBox(height: 12),

                  // Phone Box
                  _InfoCard(
                    icon: Icons.phone_outlined,
                    text: provider.phoneNumber,
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Services',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.ink,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Services Tags Grid (2 columns)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2.8,
                    ),
                    itemCount: provider.services.length,
                    itemBuilder: (context, index) {
                      final service = provider.services[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFEFF2F6)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.handyman_outlined, color: AppTheme.blue, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                service,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.italic,
                                  color: AppTheme.ink,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),

                  // Action Buttons: Chat & Book Now
                  Row(
                    children: [
                      Container(
                        height: 54,
                        width: 58,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F7F9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: IconButton(
                          onPressed: () => context.push('/chat-conversation/${provider.id}'),
                          icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppTheme.ink, size: 24),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: SizedBox(
                          height: 54,
                          child: FilledButton(
                            onPressed: () => _handleBookingRequest(context, ref, provider),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.greenLight,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Book Now',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleBookingRequest(BuildContext context, WidgetRef ref, ProviderModel provider) async {
    if (provider.categoryIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This provider has no service category set up.')),
      );
      return;
    }

    try {
      await ref.read(serviceRequestsProvider.notifier).createRequest(
            categoryId: provider.categoryIds.first,
            providerId: provider.id,
            description: 'Service request booked directly from provider profile.',
          );
      if (!context.mounted) return;
      // Show "Order Requested!" Dialog matching Visily UI
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _OrderRequestedDialog(providerName: provider.fullName),
      );
    } on ApiException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }
}

class _OrderRequestedDialog extends StatelessWidget {
  const _OrderRequestedDialog({required this.providerName});
  final String providerName;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.send_rounded, color: AppTheme.green, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Order Requested!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.green,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'your order is successfully requested to that service provider now you can contact',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.muted,
                fontSize: 14,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 140,
              height: 46,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/history');
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.greenLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Done', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 95,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFF2F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
              color: AppTheme.ink,
            ),
          ),
        ],
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
