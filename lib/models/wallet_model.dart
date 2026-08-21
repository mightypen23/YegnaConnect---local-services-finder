enum CreditTransactionType { purchase, spend, refund, bonus }

class CreditTransaction {
  final String id;
  final CreditTransactionType type;
  final int creditsAmount;
  final String title;
  final String description;
  final DateTime timestamp;
  final String? referenceNumber;
  final String? paymentMethod;
  final int balanceAfter;

  const CreditTransaction({
    required this.id,
    required this.type,
    required this.creditsAmount,
    required this.title,
    required this.description,
    required this.timestamp,
    this.referenceNumber,
    this.paymentMethod,
    required this.balanceAfter,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'creditsAmount': creditsAmount,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'referenceNumber': referenceNumber,
      'paymentMethod': paymentMethod,
      'balanceAfter': balanceAfter,
    };
  }

  factory CreditTransaction.fromJson(Map<String, dynamic> json) {
    return CreditTransaction(
      id: json['id'] as String,
      type: CreditTransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CreditTransactionType.purchase,
      ),
      creditsAmount: json['creditsAmount'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      referenceNumber: json['referenceNumber'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      balanceAfter: json['balanceAfter'] as int,
    );
  }
}

class CreditPackage {
  final String id;
  final String name;
  final int credits;
  final double priceEtb;
  final String? badge;
  final String description;

  const CreditPackage({
    required this.id,
    required this.name,
    required this.credits,
    required this.priceEtb,
    this.badge,
    required this.description,
  });

  static const List<CreditPackage> defaultPackages = [
    CreditPackage(
      id: 'pkg_starter',
      name: 'Starter Pack',
      credits: 25,
      priceEtb: 50.0,
      description: 'Ideal for trying out lead access',
    ),
    CreditPackage(
      id: 'pkg_standard',
      name: 'Standard Pack',
      credits: 75,
      priceEtb: 135.0,
      badge: 'Popular',
      description: '10% bonus credits for active providers',
    ),
    CreditPackage(
      id: 'pkg_pro',
      name: 'Pro Pack',
      credits: 200,
      priceEtb: 320.0,
      badge: 'Best Value',
      description: '20% bonus credits for high volume providers',
    ),
    CreditPackage(
      id: 'pkg_unlimited',
      name: 'Master Pack',
      credits: 500,
      priceEtb: 750.0,
      badge: 'Top Tier',
      description: 'Maximum savings & priority request alerts',
    ),
  ];
}

class ProviderWallet {
  final String providerId;
  final int creditBalance;
  final List<CreditTransaction> transactions;

  const ProviderWallet({
    required this.providerId,
    this.creditBalance = 30,
    required this.transactions,
  });

  ProviderWallet copyWith({
    String? providerId,
    int? creditBalance,
    List<CreditTransaction>? transactions,
  }) {
    return ProviderWallet(
      providerId: providerId ?? this.providerId,
      creditBalance: creditBalance ?? this.creditBalance,
      transactions: transactions ?? this.transactions,
    );
  }
}
