class WalletBalance {
  final double availableBalance;
  final double totalBalance;
  final double investedAmount;
  final double pendingAmount;
  final String currency;
  final DateTime lastUpdated;

  const WalletBalance({
    required this.availableBalance,
    required this.totalBalance,
    required this.investedAmount,
    this.pendingAmount = 0.0,
    this.currency = 'USD',
    required this.lastUpdated,
  });

  WalletBalance copyWith({
    double? availableBalance,
    double? totalBalance,
    double? investedAmount,
    double? pendingAmount,
    String? currency,
    DateTime? lastUpdated,
  }) {
    return WalletBalance(
      availableBalance: availableBalance ?? this.availableBalance,
      totalBalance: totalBalance ?? this.totalBalance,
      investedAmount: investedAmount ?? this.investedAmount,
      pendingAmount: pendingAmount ?? this.pendingAmount,
      currency: currency ?? this.currency,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    return WalletBalance(
      availableBalance: (json['availableBalance'] ?? 0).toDouble(),
      totalBalance: (json['totalBalance'] ?? 0).toDouble(),
      investedAmount: (json['investedAmount'] ?? 0).toDouble(),
      pendingAmount: (json['pendingAmount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      lastUpdated:
          DateTime.tryParse(json['lastUpdated'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'availableBalance': availableBalance,
      'totalBalance': totalBalance,
      'investedAmount': investedAmount,
      'pendingAmount': pendingAmount,
      'currency': currency,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory WalletBalance.empty() {
    return WalletBalance(
      availableBalance: 0.0,
      totalBalance: 0.0,
      investedAmount: 0.0,
      lastUpdated: DateTime.now(),
    );
  }
}

class Transaction {
  final String id;
  final String type; // 'deposit', 'withdrawal', 'investment', 'dividend'
  final double amount;
  final String description;
  final DateTime date;
  final String status; // 'completed', 'pending', 'failed'
  final String? referenceId;
  final Map<String, dynamic>? metadata;

  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
    required this.status,
    this.referenceId,
    this.metadata,
  });

  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isFailed => status.toLowerCase() == 'failed';

  bool get isCredit => type == 'deposit' || type == 'dividend';
  bool get isDebit => type == 'withdrawal' || type == 'investment';

  Transaction copyWith({
    String? id,
    String? type,
    double? amount,
    String? description,
    DateTime? date,
    String? status,
    String? referenceId,
    Map<String, dynamic>? metadata,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      status: status ?? this.status,
      referenceId: referenceId ?? this.referenceId,
      metadata: metadata ?? this.metadata,
    );
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? 'pending',
      referenceId: json['referenceId'],
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'status': status,
      'referenceId': referenceId,
      'metadata': metadata,
    };
  }
}

class PaymentMethod {
  final String id;
  final String type; // 'bank_account', 'card', 'mobile_money', 'crypto_wallet'
  final String name;
  final String displayName;
  final bool isDefault;
  final bool isActive;
  final bool isVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? details;

  const PaymentMethod({
    required this.id,
    required this.type,
    required this.name,
    required this.displayName,
    this.isDefault = false,
    this.isActive = true,
    this.isVerified = false,
    this.createdAt,
    this.updatedAt,
    this.details,
  });

  PaymentMethod copyWith({
    String? id,
    String? type,
    String? name,
    String? displayName,
    bool? isDefault,
    bool? isActive,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? details,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      details: details ?? this.details,
    );
  }

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? '',
      name: json['name'] ?? '',
      displayName: json['displayName'] ?? json['display_name'] ?? '',
      isDefault: json['isDefault'] ?? json['is_default'] ?? false,
      isActive: json['is_active'] ?? true,
      isVerified: json['isVerified'] ?? json['is_verified'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      details: json['details'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'display_name': displayName,
      'is_default': isDefault,
      'is_active': isActive,
      'is_verified': isVerified,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'details': details,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentMethod && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PaymentMethod(id: $id, name: $name, type: $type)';
  }
}

class WalletSummary {
  final WalletBalance balance;
  final List<Transaction> recentTransactions;
  final List<PaymentMethod> paymentMethods;
  final DateTime lastUpdated;

  const WalletSummary({
    required this.balance,
    required this.recentTransactions,
    required this.paymentMethods,
    required this.lastUpdated,
  });

  WalletSummary copyWith({
    WalletBalance? balance,
    List<Transaction>? recentTransactions,
    List<PaymentMethod>? paymentMethods,
    DateTime? lastUpdated,
  }) {
    return WalletSummary(
      balance: balance ?? this.balance,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  factory WalletSummary.fromJson(Map<String, dynamic> json) {
    final transactionsList =
        (json['recentTransactions'] as List<dynamic>? ?? [])
            .map((item) => Transaction.fromJson(item as Map<String, dynamic>))
            .toList();

    final paymentMethodsList = (json['paymentMethods'] as List<dynamic>? ?? [])
        .map((item) => PaymentMethod.fromJson(item as Map<String, dynamic>))
        .toList();

    return WalletSummary(
      balance: WalletBalance.fromJson(json['balance'] ?? {}),
      recentTransactions: transactionsList,
      paymentMethods: paymentMethodsList,
      lastUpdated:
          DateTime.tryParse(json['lastUpdated'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance.toJson(),
      'recentTransactions': recentTransactions.map((t) => t.toJson()).toList(),
      'paymentMethods': paymentMethods.map((p) => p.toJson()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory WalletSummary.empty() {
    return WalletSummary(
      balance: WalletBalance.empty(),
      recentTransactions: [],
      paymentMethods: [],
      lastUpdated: DateTime.now(),
    );
  }
}
