import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../models/wallet_model.dart';
import 'network_providers.dart';

class WalletNotifier extends StateNotifier<ProviderWallet> {
  WalletNotifier(this._ref)
      : super(const ProviderWallet(providerId: '', creditBalance: 0, transactions: [])) {
    refresh();
  }

  final Ref _ref;

  Future<void> refresh() async {
    final api = _ref.read(apiClientProvider);
    try {
      final balanceResponse = await api.dio.get('/credits/balance');
      final balanceData = balanceResponse.data['data'] as Map<String, dynamic>;
      final balance = balanceData['balance'] as int;
      final providerId = balanceData['providerId'] as String? ?? '';

      final txResponse = await api.dio.get('/credits/transactions');
      final rows = (txResponse.data['data'] as List<dynamic>).cast<Map<String, dynamic>>();

      // Backend transactions come newest-first with no per-row running balance,
      // so reconstruct it locally from the current balance backwards.
      var running = balance;
      final transactions = <CreditTransaction>[];
      for (final row in rows) {
        final signedAmount = row['type'] == 'debit' ? -(row['amount'] as int) : (row['amount'] as int);
        transactions.add(_fromApiRow(row, balanceAfter: running));
        running -= signedAmount;
      }

      state = ProviderWallet(providerId: providerId, creditBalance: balance, transactions: transactions);
    } catch (_) {
      // Keep the current state; wallet screens already handle an empty/stale state.
    }
  }

  CreditTransaction _fromApiRow(Map<String, dynamic> row, {required int balanceAfter}) {
    final reason = row['reason'] as String? ?? '';
    final amount = row['amount'] as int;
    final isDebit = row['type'] == 'debit';
    final type = isDebit
        ? CreditTransactionType.spend
        : (reason.startsWith('Credit purchase') ? CreditTransactionType.purchase : CreditTransactionType.bonus);

    return CreditTransaction(
      id: row['id'] as String,
      type: type,
      creditsAmount: isDebit ? -amount : amount,
      title: reason.isEmpty ? (isDebit ? 'Credit used' : 'Credit added') : reason,
      description: reason,
      timestamp: DateTime.parse(row['created_at'] as String),
      referenceNumber: row['reference_id'] as String? ?? row['id'] as String,
      paymentMethod: isDebit ? 'Wallet Credit' : 'System',
      balanceAfter: balanceAfter,
    );
  }

  // Buys credits with a custom amount chosen by the provider.
  Future<void> purchaseCredits(int credits) async {
    final api = _ref.read(apiClientProvider);
    try {
      await api.dio.post('/credits/purchase', data: {'credits': credits});
      await refresh();
    } on DioException catch (e) {
      throw ApiClient.toApiException(e);
    }
  }
}

final walletProvider = StateNotifierProvider<WalletNotifier, ProviderWallet>((ref) {
  return WalletNotifier(ref);
});

