import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/wallet_provider.dart';
import '../../../providers/app_providers.dart';
import '../../../models/service_request.dart';

class UnlockRequestDialog extends ConsumerWidget {
  const UnlockRequestDialog({
    super.key,
    required this.request,
  });

  final ServiceRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider);
    final hasEnoughCredits = wallet.creditBalance >= request.unlockCreditCost;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: hasEnoughCredits ? AppTheme.green.withValues(alpha: .1) : AppTheme.accentRed.withValues(alpha: .1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    hasEnoughCredits ? Icons.lock_open_rounded : Icons.warning_amber_rounded,
                    color: hasEnoughCredits ? AppTheme.green : AppTheme.accentRed,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    hasEnoughCredits ? 'Unlock Lead Details' : 'Insufficient Credits',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: hasEnoughCredits ? AppTheme.ink : AppTheme.accentRed,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              hasEnoughCredits
                  ? 'Unlocking this request lead allows you to view the customer contact info and accept the service.'
                  : 'You need ${request.unlockCreditCost} credits to unlock this customer request, but you only have ${wallet.creditBalance} credits.',
              style: const TextStyle(color: AppTheme.muted, fontSize: 14, height: 1.35),
            ),
            const SizedBox(height: 20),

            // Credit Cost & Balance Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEFF2F6)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Lead Unlock Cost:', style: TextStyle(color: AppTheme.muted, fontSize: 13)),
                      Text(
                        '${request.unlockCreditCost} Credits',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.ink, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Your Current Balance:', style: TextStyle(color: AppTheme.muted, fontSize: 13)),
                      Text(
                        '${wallet.creditBalance} Credits',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: hasEnoughCredits ? AppTheme.green : AppTheme.accentRed,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  if (hasEnoughCredits) ...[
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Balance After Unlock:', style: TextStyle(color: AppTheme.muted, fontSize: 13)),
                        Text(
                          '${wallet.creditBalance - request.unlockCreditCost} Credits',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.ink, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            if (hasEnoughCredits)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        final success = ref.read(walletProvider.notifier).deductCredits(
                              amount: request.unlockCreditCost,
                              requestTitle: request.serviceTitle,
                              requestId: request.id,
                            );

                        if (success) {
                          ref.read(serviceRequestsProvider.notifier).unlockRequest(request.id);
                          ref.read(serviceRequestsProvider.notifier).updateStatus(request.id, RequestStatus.accepted);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Lead unlocked and request accepted!')),
                          );
                        }
                      },
                      child: const Text('Unlock Lead'),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.push('/buy-credits');
                      },
                      style: FilledButton.styleFrom(backgroundColor: AppTheme.greenLight),
                      child: const Text('Buy Credits'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
