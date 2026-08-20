import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wallet_model.dart';

class WalletNotifier extends StateNotifier<ProviderWallet> {
  WalletNotifier()
      : super(ProviderWallet(
          providerId: 'prov_1',
          creditBalance: 50,
          transactions: [
            CreditTransaction(
              id: 'txn_101',
              type: CreditTransactionType.purchase,
              creditsAmount: 50,
              title: 'Starter Pack Purchased',
              description: 'Purchased 50 credits via Telebirr',
              timestamp: DateTime.now().subtract(const Duration(days: 2)),
              referenceNumber: 'TB-8941257',
              paymentMethod: 'Telebirr',
              balanceAfter: 50,
            ),
            CreditTransaction(
              id: 'txn_100',
              type: CreditTransactionType.bonus,
              creditsAmount: 10,
              title: 'Welcome Bonus',
              description: 'Bonus credits for completing provider registration',
              timestamp: DateTime.now().subtract(const Duration(days: 5)),
              referenceNumber: 'BONUS-REG',
              paymentMethod: 'System',
              balanceAfter: 10,
            ),
          ],
        ));

  bool deductCredits({
    required int amount,
    required String requestTitle,
    required String requestId,
  }) {
    if (state.creditBalance < amount) {
      return false; // Insufficient balance
    }

    final newBalance = state.creditBalance - amount;
    final newTransaction = CreditTransaction(
      id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
      type: CreditTransactionType.spend,
      creditsAmount: -amount,
      title: 'Unlocked Request Lead',
      description: 'Unlocked customer request: $requestTitle',
      timestamp: DateTime.now(),
      referenceNumber: 'REQ-$requestId',
      paymentMethod: 'Wallet Credit',
      balanceAfter: newBalance,
    );

    state = state.copyWith(
      creditBalance: newBalance,
      transactions: [newTransaction, ...state.transactions],
    );

    return true;
  }

  void topUpCredits({
    required CreditPackage package,
    required String paymentMethod,
  }) {
    final newBalance = state.creditBalance + package.credits;
    final newTransaction = CreditTransaction(
      id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
      type: CreditTransactionType.purchase,
      creditsAmount: package.credits,
      title: '${package.name} Purchased',
      description: 'Added ${package.credits} credits via $paymentMethod (${package.priceEtb.toInt()} ETB)',
      timestamp: DateTime.now(),
      referenceNumber: 'TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      paymentMethod: paymentMethod,
      balanceAfter: newBalance,
    );

    state = state.copyWith(
      creditBalance: newBalance,
      transactions: [newTransaction, ...state.transactions],
    );
  }
}

final walletProvider =
    StateNotifierProvider<WalletNotifier, ProviderWallet>((ref) {
  return WalletNotifier();
});
