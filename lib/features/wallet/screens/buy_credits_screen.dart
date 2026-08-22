import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_client.dart';
import '../../../providers/wallet_provider.dart';

class BuyCreditsScreen extends ConsumerStatefulWidget {
  const BuyCreditsScreen({super.key});

  @override
  ConsumerState<BuyCreditsScreen> createState() => _BuyCreditsScreenState();
}

class _BuyCreditsScreenState extends ConsumerState<BuyCreditsScreen> {
  final _creditController = TextEditingController(text: '100');
  String _selectedPaymentMethod = 'Telebirr';

  // Rate: 100 credits = 50 ETB  →  1 credit = 0.5 ETB
  static const double _etbPerCredit = 0.5;
  static const int _minCredits = 10;

  int get _credits => int.tryParse(_creditController.text) ?? 0;
  double get _costEtb => _credits * _etbPerCredit;
  bool get _isValid => _credits >= _minCredits;

  @override
  void initState() {
    super.initState();
    _creditController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _creditController.dispose();
    super.dispose();
  }

  void _setQuickAmount(int amount) {
    _creditController.text = amount.toString();
    _creditController.selection = TextSelection.fromPosition(
      TextPosition(offset: _creditController.text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Up YC Coins'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Balance Info Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.green, AppTheme.greenLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.green.withValues(alpha: .25),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current YC Coin Balance',
                          style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${wallet.creditBalance} YC Coins',
                          style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                    const Icon(Icons.account_balance_wallet, color: Colors.white, size: 40),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Enter Credits Section
              const Text(
                'Enter YC Coins Amount',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.ink),
              ),
              const SizedBox(height: 6),
              Text(
                'Choose how many YC Coins you want to buy (min $_minCredits)',
                style: const TextStyle(color: AppTheme.muted, fontSize: 13),
              ),
              const SizedBox(height: 14),

              // Credit Amount Input
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _isValid ? AppTheme.green : const Color(0xFFEFF2F6), width: _isValid ? 2 : 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _creditController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.ink,
                        letterSpacing: 2,
                      ),
                      decoration: InputDecoration(
                        hintText: '100',
                        hintStyle: TextStyle(color: AppTheme.muted.withValues(alpha: .4), fontSize: 36, fontWeight: FontWeight.w900),
                        suffixText: 'YC Coins',
                        suffixStyle: const TextStyle(color: AppTheme.muted, fontSize: 14, fontWeight: FontWeight.w600),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFEFF2F6)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.payments_outlined, size: 18, color: AppTheme.green),
                        const SizedBox(width: 6),
                        Text(
                          'Cost: ${_costEtb.toStringAsFixed(_costEtb == _costEtb.roundToDouble() ? 0 : 2)} ETB',
                          style: const TextStyle(
                            color: AppTheme.green,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (!_isValid && _creditController.text.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Minimum $_minCredits credits required',
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Quick Pick Chips
              const Text(
                'Quick Pick',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.muted),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [50, 100, 200, 500, 1000].map((amount) {
                  final isSelected = _credits == amount;
                  return ActionChip(
                    label: Text('$amount'),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.ink,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    backgroundColor: isSelected ? AppTheme.green : const Color(0xFFF4F6F9),
                    side: BorderSide(
                      color: isSelected ? AppTheme.green : const Color(0xFFE0E4EB),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onPressed: () => _setQuickAmount(amount),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              // Payment Method
              const Text(
                'Payment Method',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.ink),
              ),
              const SizedBox(height: 12),

              // Payment Method Chips
              Row(
                children: ['Telebirr', 'Chapa', 'CBE Birr'].map((method) {
                  final isSelected = _selectedPaymentMethod == method;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(method),
                      selected: isSelected,
                      selectedColor: AppTheme.green,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.ink,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (_) => setState(() => _selectedPaymentMethod = method),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Confirm Purchase Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: _isValid ? () => _processPayment(context, ref) : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.greenLight,
                    disabledBackgroundColor: AppTheme.muted.withValues(alpha: .2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _isValid
                        ? 'Pay ${_costEtb.toStringAsFixed(_costEtb == _costEtb.roundToDouble() ? 0 : 2)} ETB & Get $_credits YC Coins'
                        : 'Enter Credit Amount',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _processPayment(BuildContext context, WidgetRef ref) async {
    final credits = _credits;
    final costEtb = _costEtb;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppTheme.green),
      ),
    );

    try {
      await ref.read(walletProvider.notifier).purchaseCredits(credits);
    } on ApiException catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Close loader
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      return;
    }

    if (!context.mounted) return;
    Navigator.pop(context); // Close loader

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: AppTheme.green, size: 60),
            const SizedBox(height: 14),
            const Text(
              'Top Up Successful!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.green),
            ),
            const SizedBox(height: 8),
            Text(
              '$credits YC Coins have been added to your wallet via $_selectedPaymentMethod for ${costEtb.toStringAsFixed(costEtb == costEtb.roundToDouble() ? 0 : 2)} ETB.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.muted, fontSize: 13),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.pop();
                },
                child: const Text('Back to Wallet'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
