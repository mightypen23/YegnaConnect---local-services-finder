import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/wallet_model.dart';
import '../../../providers/wallet_provider.dart';

class ProviderWalletScreen extends ConsumerWidget {
  const ProviderWalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider);
    final dateFormat = DateFormat('MMM dd, yyyy - hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Wallet & Credits'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wallet Balance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF27A148), Color(0xFF8CC63F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.green.withValues(alpha: .25),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available Credit Balance',
                      style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${wallet.creditBalance} Credits',
                          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                        ),
                        FilledButton.icon(
                          onPressed: () => context.push('/buy-credits'),
                          icon: const Icon(Icons.add_rounded, size: 20),
                          label: const Text('Top Up'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Credits are deducted when you unlock customer service leads.',
                      style: TextStyle(color: Colors.white.withValues(alpha: .9), fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Transaction History',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.ink),
              ),
              const SizedBox(height: 14),

              // Transactions List
              if (wallet.transactions.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      'No transactions yet.',
                      style: TextStyle(color: AppTheme.muted),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: wallet.transactions.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final txn = wallet.transactions[index];
                    final isSpend = txn.type == CreditTransactionType.spend;

                    return Container(
                      padding: const EdgeInsets.all(14),
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
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSpend
                                  ? AppTheme.accentOrange.withValues(alpha: .1)
                                  : AppTheme.green.withValues(alpha: .1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isSpend ? Icons.lock_open_rounded : Icons.add_circle_outline_rounded,
                              color: isSpend ? AppTheme.accentOrange : AppTheme.green,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  txn.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.ink),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  txn.description,
                                  style: const TextStyle(color: AppTheme.muted, fontSize: 12),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dateFormat.format(txn.timestamp),
                                  style: const TextStyle(color: AppTheme.muted, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${isSpend ? '' : '+'}${txn.creditsAmount} Cr',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  color: isSpend ? AppTheme.accentRed : AppTheme.green,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Bal: ${txn.balanceAfter}',
                                style: const TextStyle(color: AppTheme.muted, fontSize: 11),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
