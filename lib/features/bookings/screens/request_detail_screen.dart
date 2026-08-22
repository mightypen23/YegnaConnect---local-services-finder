import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_client.dart';
import '../../../providers/app_providers.dart';
import '../../../models/service_request.dart';
import '../../../models/user_model.dart';
import '../../reviews/widgets/review_dialog.dart';

class RequestDetailScreen extends ConsumerStatefulWidget {
  const RequestDetailScreen({
    super.key,
    required this.requestId,
  });

  final String requestId;

  @override
  ConsumerState<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends ConsumerState<RequestDetailScreen> {
  bool _cancelling = false;

  Future<void> _cancelRequest(String requestId) async {
    setState(() => _cancelling = true);
    try {
      await ref.read(serviceRequestsProvider.notifier).cancelRequest(requestId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request cancelled')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final requestId = widget.requestId;
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
                    if (request.isUnlockedByProvider)
                      _DetailRow(
                        icon: Icons.phone_outlined,
                        title: 'Phone',
                        value: request.providerPhoneNumber ?? '',
                      ),
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
                  if (request.status == RequestStatus.pending ||
                      request.status == RequestStatus.accepted ||
                      request.status == RequestStatus.inProgress)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _cancelling ? null : () => _cancelRequest(request.id),
                        style: OutlinedButton.styleFrom(foregroundColor: AppTheme.accentRed),
                        child: _cancelling
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.accentRed),
                              )
                            : const Text('Cancel Request'),
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