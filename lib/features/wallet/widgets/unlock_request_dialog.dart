import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_client.dart';
import '../../../providers/wallet_provider.dart';
import '../../../providers/app_providers.dart';
import '../../../models/service_request.dart';

class UnlockRequestDialog extends ConsumerStatefulWidget {
  const UnlockRequestDialog({
    super.key,
    required this.request,
  });

  final ServiceRequest request;

  @override
  ConsumerState<UnlockRequestDialog> createState() => _UnlockRequestDialogState();
}

class _UnlockRequestDialogState extends ConsumerState<UnlockRequestDialog> {
  bool _accepting = false;

  Future<void> _accept() async {
    setState(() => _accepting = true);
    try {
      await ref.read(serviceRequestsProvider.notifier).acceptRequest(widget.request.id);
      await ref.read(walletProvider.notifier).refresh();
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lead unlocked and request accepted!')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      setState(() => _accepting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
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
                      onPressed: _accepting ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _accepting ? null : _accept,
                      child: _accepting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text('Unlock Lead'),
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

