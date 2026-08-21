import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_client.dart';
import '../../../models/wallet_model.dart';
import '../../../providers/wallet_provider.dart';

class BuyCreditsScreen extends ConsumerStatefulWidget {
  const BuyCreditsScreen({super.key});

  @override
  ConsumerState<BuyCreditsScreen> createState() => _BuyCreditsScreenState();
}

class _BuyCreditsScreenState extends ConsumerState<BuyCreditsScreen> {
  CreditPackage _selectedPackage = CreditPackage.defaultPackages[1];
  String _selectedPaymentMethod = 'Telebirr';

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Up Wallet Credits'),
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
                          'Current Credit Balance',
                          style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${wallet.creditBalance} Credits',
                          style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                    const Icon(Icons.account_balance_wallet, color: Colors.white, size: 40),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Select Credit Package',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.ink),
              ),
              const SizedBox(height: 14),

              // Credit Packages List
              RadioGroup<String>(
                groupValue: _selectedPackage.id,
                onChanged: (packageId) {
                  if (packageId != null) {
                    setState(() {
                      _selectedPackage = CreditPackage.defaultPackages.firstWhere(
                        (package) => package.id == packageId,
                      );
                    });
                  }
                },
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: CreditPackage.defaultPackages.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                  final pkg = CreditPackage.defaultPackages[index];
                  final isSelected = _selectedPackage.id == pkg.id;

                  return InkWell(
                    onTap: () => setState(() => _selectedPackage = pkg),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppTheme.green : const Color(0xFFEFF2F6),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Radio<String>(
                            value: pkg.id,
                            activeColor: AppTheme.green,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      pkg.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.ink),
                                    ),
                                    if (pkg.badge != null) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.green.withValues(alpha: .15),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          pkg.badge!,
                                          style: const TextStyle(color: AppTheme.green, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  pkg.description,
                                  style: const TextStyle(color: AppTheme.muted, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${pkg.credits} Cr',
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.green),
                              ),
                              Text(
                                '${pkg.priceEtb.toInt()} ETB',
                                style: const TextStyle(color: AppTheme.muted, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                  },
                ),
              ),
              const SizedBox(height: 24),

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
                  onPressed: () => _processMockPayment(context, ref),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.greenLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Pay ${_selectedPackage.priceEtb.toInt()} ETB & Get ${_selectedPackage.credits} Credits',
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

  Future<void> _processMockPayment(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppTheme.green),
      ),
    );

    try {
      await ref.read(walletProvider.notifier).purchaseCredits(_selectedPackage);
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
              '${_selectedPackage.credits} credits have been added to your wallet via $_selectedPaymentMethod.',
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
