import 'package:json_annotation/json_annotation.dart';

part 'wallet_model.g.dart';

@JsonSerializable()
class Wallet {
  final String id;
  final String userId;
  final String currency;
  final double balance;
  final double availableBalance;
  final double pendingBalance;
  final double reservedBalance;
  final WalletStatus status;
  final WalletType type;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  Wallet({
    required this.id,
    required this.userId,
    required this.currency,
    required this.balance,
    required this.availableBalance,
    required this.pendingBalance,
    required this.reservedBalance,
    required this.status,
    required this.type,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) => _$WalletFromJson(json);
  Map<String, dynamic> toJson() => _$WalletToJson(this);

  Wallet copyWith({
    String? id,
    String? userId,
    String? currency,
    double? balance,
    double? availableBalance,
    double? pendingBalance,
    double? reservedBalance,
    WalletStatus? status,
    WalletType? type,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Wallet(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      currency: currency ?? this.currency,
      balance: balance ?? this.balance,
      availableBalance: availableBalance ?? this.availableBalance,
      pendingBalance: pendingBalance ?? this.pendingBalance,
      reservedBalance: reservedBalance ?? this.reservedBalance,
      status: status ?? this.status,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get formattedBalance => '₦${balance.toStringAsFixed(2)}';
  String get formattedAvailableBalance => '₦${availableBalance.toStringAsFixed(2)}';
  String get formattedPendingBalance => '₦${pendingBalance.toStringAsFixed(2)}';
  String get formattedReservedBalance => '₦${reservedBalance.toStringAsFixed(2)}';
  
  bool get isActive => status == WalletStatus.active;
  bool get canTransact => isActive && availableBalance > 0;
  bool get hasSufficientBalance => (amount) => availableBalance >= amount;
}

@JsonSerializable()
class WalletTransaction {
  final String id;
  final String walletId;
  final String userId;
  final TransactionType type;
  final TransactionCategory category;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final String currency;
  final TransactionStatus status;
  final String description;
  final String? reference;
  final String? externalReference;
  final Map<String, dynamic> metadata;
  final DateTime transactionDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  WalletTransaction({
    required this.id,
    required this.walletId,
    required this.userId,
    required this.type,
    required this.category,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.currency,
    required this.status,
    required this.description,
    this.reference,
    this.externalReference,
    this.metadata = const {},
    required this.transactionDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) => _$WalletTransactionFromJson(json);
  Map<String, dynamic> toJson() => _$WalletTransactionToJson(this);

  WalletTransaction copyWith({
    String? id,
    String? walletId,
    String? userId,
    TransactionType? type,
    TransactionCategory? category,
    double? amount,
    double? balanceBefore,
    double? balanceAfter,
    String? currency,
    TransactionStatus? status,
    String? description,
    String? reference,
    String? externalReference,
    Map<String, dynamic>? metadata,
    DateTime? transactionDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WalletTransaction(
      id: id ?? this.id,
      walletId: walletId ?? this.walletId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      balanceBefore: balanceBefore ?? this.balanceBefore,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      description: description ?? this.description,
      reference: reference ?? this.reference,
      externalReference: externalReference ?? this.externalReference,
      metadata: metadata ?? this.metadata,
      transactionDate: transactionDate ?? this.transactionDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get formattedAmount => '${type == TransactionType.credit ? '+' : '-'}₦${amount.toStringAsFixed(2)}';
  String get formattedBalanceAfter => '₦${balanceAfter.toStringAsFixed(2)}';
  bool get isCredit => type == TransactionType.credit;
  bool get isDebit => type == TransactionType.debit;
  bool get isCompleted => status == TransactionStatus.completed;
  bool get isPending => status == TransactionStatus.pending;
  bool get isFailed => status == TransactionStatus.failed;
}

@JsonSerializable()
class PaymentMethod {
  final String id;
  final String userId;
  final PaymentMethodType type;
  final String name;
  final String? last4Digits;
  final String? bankName;
  final String? accountNumber;
  final String? cardBrand;
  final String? expiryMonth;
  final String? expiryYear;
  final bool isDefault;
  final bool isActive;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentMethod({
    required this.id,
    required this.userId,
    required this.type,
    required this.name,
    this.last4Digits,
    this.bankName,
    this.accountNumber,
    this.cardBrand,
    this.expiryMonth,
    this.expiryYear,
    this.isDefault = false,
    this.isActive = true,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => _$PaymentMethodFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentMethodToJson(this);

  PaymentMethod copyWith({
    String? id,
    String? userId,
    PaymentMethodType? type,
    String? name,
    String? last4Digits,
    String? bankName,
    String? accountNumber,
    String? cardBrand,
    String? expiryMonth,
    String? expiryYear,
    bool? isDefault,
    bool? isActive,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      name: name ?? this.name,
      last4Digits: last4Digits ?? this.last4Digits,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      cardBrand: cardBrand ?? this.cardBrand,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get displayName {
    switch (type) {
      case PaymentMethodType.card:
        return '$cardBrand •••• $last4Digits';
      case PaymentMethodType.bankAccount:
        return '$bankName •••• $last4Digits';
      case PaymentMethodType.mobileMoney:
        return 'Mobile Money •••• $last4Digits';
      default:
        return name;
    }
  }

  String get typeDisplayName {
    switch (type) {
      case PaymentMethodType.card:
        return 'Card';
      case PaymentMethodType.bankAccount:
        return 'Bank Account';
      case PaymentMethodType.mobileMoney:
        return 'Mobile Money';
      case PaymentMethodType.wallet:
        return 'Wallet';
    }
  }
}

@JsonSerializable()
class DepositRequest {
  final String id;
  final String userId;
  final String walletId;
  final double amount;
  final String currency;
  final PaymentMethodType paymentMethod;
  final String? paymentMethodId;
  final DepositStatus status;
  final String? paymentReference;
  final String? externalReference;
  final String? notes;
  final Map<String, dynamic> metadata;
  final DateTime requestDate;
  final DateTime? completedDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  DepositRequest({
    required this.id,
    required this.userId,
    required this.walletId,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    this.paymentMethodId,
    required this.status,
    this.paymentReference,
    this.externalReference,
    this.notes,
    this.metadata = const {},
    required this.requestDate,
    this.completedDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DepositRequest.fromJson(Map<String, dynamic> json) => _$DepositRequestFromJson(json);
  Map<String, dynamic> toJson() => _$DepositRequestToJson(this);

  String get formattedAmount => '₦${amount.toStringAsFixed(2)}';
  bool get isPending => status == DepositStatus.pending;
  bool get isCompleted => status == DepositStatus.completed;
  bool get isFailed => status == DepositStatus.failed;
}

@JsonSerializable()
class WithdrawalRequest {
  final String id;
  final String userId;
  final String walletId;
  final double amount;
  final String currency;
  final PaymentMethodType withdrawalMethod;
  final String? paymentMethodId;
  final WithdrawalStatus status;
  final String? reference;
  final String? notes;
  final String? approvedBy;
  final DateTime? approvedDate;
  final Map<String, dynamic> metadata;
  final DateTime requestDate;
  final DateTime? completedDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  WithdrawalRequest({
    required this.id,
    required this.userId,
    required this.walletId,
    required this.amount,
    required this.currency,
    required this.withdrawalMethod,
    this.paymentMethodId,
    required this.status,
    this.reference,
    this.notes,
    this.approvedBy,
    this.approvedDate,
    this.metadata = const {},
    required this.requestDate,
    this.completedDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WithdrawalRequest.fromJson(Map<String, dynamic> json) => _$WithdrawalRequestFromJson(json);
  Map<String, dynamic> toJson() => _$WithdrawalRequestToJson(this);

  String get formattedAmount => '₦${amount.toStringAsFixed(2)}';
  bool get isPending => status == WithdrawalStatus.pending;
  bool get isApproved => status == WithdrawalStatus.approved;
  bool get isCompleted => status == WithdrawalStatus.completed;
  bool get isFailed => status == WithdrawalStatus.failed;
}

enum WalletStatus {
  @JsonValue('ACTIVE')
  active,
  @JsonValue('INACTIVE')
  inactive,
  @JsonValue('SUSPENDED')
  suspended,
  @JsonValue('CLOSED')
  closed,
}

enum WalletType {
  @JsonValue('PRIMARY')
  primary,
  @JsonValue('SAVINGS')
  savings,
  @JsonValue('INVESTMENT')
  investment,
  @JsonValue('GROUP')
  group,
}

enum TransactionType {
  @JsonValue('CREDIT')
  credit,
  @JsonValue('DEBIT')
  debit,
}

enum TransactionCategory {
  @JsonValue('DEPOSIT')
  deposit,
  @JsonValue('WITHDRAWAL')
  withdrawal,
  @JsonValue('INVESTMENT')
  investment,
  @JsonValue('REDEMPTION')
  redemption,
  @JsonValue('FEE')
  fee,
  @JsonValue('REFUND')
  refund,
  @JsonValue('TRANSFER')
  transfer,
  @JsonValue('INTEREST')
  interest,
  @JsonValue('DIVIDEND')
  dividend,
}

enum TransactionStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('PROCESSING')
  processing,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('FAILED')
  failed,
  @JsonValue('CANCELLED')
  cancelled,
  @JsonValue('REVERSED')
  reversed,
}

enum PaymentMethodType {
  @JsonValue('CARD')
  card,
  @JsonValue('BANK_ACCOUNT')
  bankAccount,
  @JsonValue('MOBILE_MONEY')
  mobileMoney,
  @JsonValue('WALLET')
  wallet,
}

enum DepositStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('PROCESSING')
  processing,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('FAILED')
  failed,
  @JsonValue('CANCELLED')
  cancelled,
}

enum WithdrawalStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('APPROVED')
  approved,
  @JsonValue('PROCESSING')
  processing,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('FAILED')
  failed,
  @JsonValue('CANCELLED')
  cancelled,
  @JsonValue('REJECTED')
  rejected,
}
