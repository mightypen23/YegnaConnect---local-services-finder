import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/app_providers.dart';
import '../../../models/service_request.dart';
import '../../../models/user_model.dart';
import '../../reviews/widgets/review_dialog.dart';

class RequestDetailScreen extends ConsumerWidget {
  const RequestDetailScreen({
    super.key,
    required this.requestId,
  });

  final String requestId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(serviceRequestsProvider);
    final user = ref.watch(userProvider);
    final isCustomer = user.role == UserRole.customer;

    final request = requests.firstWhere(
      (r) => r.id == requestId,
      orElse: () => requests.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Details'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lifecycle Status Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.green.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.green.withValues(alpha: .3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppTheme.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Current Status: ${request.status.displayName}',
                        style: const TextStyle(
                          color: AppTheme.ink,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Request Information Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEFF2F6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.serviceTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      request.description,
                      style: const TextStyle(color: AppTheme.muted, fontSize: 14),
                    ),
                    const Divider(height: 24),
                    _DetailRow(icon: Icons.person_outline, title: 'Customer', value: request.customerName),
                    const SizedBox(height: 8),
                    _DetailRow(icon: Icons.handyman_outlined, title: 'Provider', value: request.providerName),
                    const SizedBox(height: 8),
                    _DetailRow(icon: Icons.location_on_outlined, title: 'Location', value: request.location),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Actions Row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/chat-conversation/${request.providerId}'),
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Open Chat'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (request.status == RequestStatus.pending || request.status == RequestStatus.accepted)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          ref.read(serviceRequestsProvider.notifier).updateStatus(request.id, RequestStatus.cancelled);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Request cancelled')),
                          );
                        },
                        style: OutlinedButton.styleFrom(foregroundColor: AppTheme.accentRed),
                        child: const Text('Cancel Request'),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),

              // Completion / Review buttons
              if (isCustomer && request.status == RequestStatus.completed)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => ReviewDialog(request: request),
                      );
                    },
                    icon: const Icon(Icons.star),
                    label: const Text('Rate & Review Provider'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.title, required this.value});
  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.muted),
        const SizedBox(width: 8),
        Text('$title: ', style: const TextStyle(color: AppTheme.muted, fontSize: 13)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.ink, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
