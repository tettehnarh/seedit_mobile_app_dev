import 'package:json_annotation/json_annotation.dart';

part 'sip_model.g.dart';

@JsonSerializable()
class SIPPlan {
  final String id;
  final String userId;
  final String fundId;
  final String fundName;
  final String planName;
  final String? description;
  final double amount;
  final SIPFrequency frequency;
  final SIPStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final int? maxInstallments;
  final int completedInstallments;
  final double totalInvested;
  final double totalUnits;
  final String paymentMethodId;
  final String paymentMethodType;
  final SIPSettings settings;
  final List<SIPInstallment> installments;
  final DateTime? nextExecutionDate;
  final DateTime? lastExecutionDate;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  SIPPlan({
    required this.id,
    required this.userId,
    required this.fundId,
    required this.fundName,
    required this.planName,
    this.description,
    required this.amount,
    required this.frequency,
    required this.status,
    required this.startDate,
    this.endDate,
    this.maxInstallments,
    this.completedInstallments = 0,
    this.totalInvested = 0.0,
    this.totalUnits = 0.0,
    required this.paymentMethodId,
    required this.paymentMethodType,
    required this.settings,
    this.installments = const [],
    this.nextExecutionDate,
    this.lastExecutionDate,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory SIPPlan.fromJson(Map<String, dynamic> json) => _$SIPPlanFromJson(json);
  Map<String, dynamic> toJson() => _$SIPPlanToJson(this);

  SIPPlan copyWith({
    String? id,
    String? userId,
    String? fundId,
    String? fundName,
    String? planName,
    String? description,
    double? amount,
    SIPFrequency? frequency,
    SIPStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    int? maxInstallments,
    int? completedInstallments,
    double? totalInvested,
    double? totalUnits,
    String? paymentMethodId,
    String? paymentMethodType,
    SIPSettings? settings,
    List<SIPInstallment>? installments,
    DateTime? nextExecutionDate,
    DateTime? lastExecutionDate,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SIPPlan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fundId: fundId ?? this.fundId,
      fundName: fundName ?? this.fundName,
      planName: planName ?? this.planName,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      frequency: frequency ?? this.frequency,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      maxInstallments: maxInstallments ?? this.maxInstallments,
      completedInstallments: completedInstallments ?? this.completedInstallments,
      totalInvested: totalInvested ?? this.totalInvested,
      totalUnits: totalUnits ?? this.totalUnits,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      paymentMethodType: paymentMethodType ?? this.paymentMethodType,
      settings: settings ?? this.settings,
      installments: installments ?? this.installments,
      nextExecutionDate: nextExecutionDate ?? this.nextExecutionDate,
      lastExecutionDate: lastExecutionDate ?? this.lastExecutionDate,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Calculated properties
  bool get isActive => status == SIPStatus.active;
  bool get isPaused => status == SIPStatus.paused;
  bool get isCompleted => status == SIPStatus.completed;
  bool get isCancelled => status == SIPStatus.cancelled;
  
  double get averageNAV => totalUnits > 0 ? totalInvested / totalUnits : 0.0;
  double get progressPercentage => maxInstallments != null ? (completedInstallments / maxInstallments!) * 100 : 0.0;
  int get remainingInstallments => maxInstallments != null ? maxInstallments! - completedInstallments : 0;
  
  bool get hasEndDate => endDate != null;
  bool get hasMaxInstallments => maxInstallments != null;
  bool get isIndefinite => !hasEndDate && !hasMaxInstallments;
  
  String get formattedAmount => '₦${amount.toStringAsFixed(2)}';
  String get formattedTotalInvested => '₦${totalInvested.toStringAsFixed(2)}';
  String get frequencyText => _getFrequencyText();
  
  String _getFrequencyText() {
    switch (frequency) {
      case SIPFrequency.daily:
        return 'Daily';
      case SIPFrequency.weekly:
        return 'Weekly';
      case SIPFrequency.monthly:
        return 'Monthly';
      case SIPFrequency.quarterly:
        return 'Quarterly';
      case SIPFrequency.yearly:
        return 'Yearly';
    }
  }
}

@JsonSerializable()
class SIPInstallment {
  final String id;
  final String sipId;
  final int installmentNumber;
  final double amount;
  final double units;
  final double nav;
  final DateTime scheduledDate;
  final DateTime? executedDate;
  final SIPInstallmentStatus status;
  final String? paymentReference;
  final String? failureReason;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  SIPInstallment({
    required this.id,
    required this.sipId,
    required this.installmentNumber,
    required this.amount,
    this.units = 0.0,
    this.nav = 0.0,
    required this.scheduledDate,
    this.executedDate,
    required this.status,
    this.paymentReference,
    this.failureReason,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory SIPInstallment.fromJson(Map<String, dynamic> json) => _$SIPInstallmentFromJson(json);
  Map<String, dynamic> toJson() => _$SIPInstallmentToJson(this);

  bool get isCompleted => status == SIPInstallmentStatus.completed;
  bool get isPending => status == SIPInstallmentStatus.pending;
  bool get isFailed => status == SIPInstallmentStatus.failed;
  bool get isProcessing => status == SIPInstallmentStatus.processing;
  
  String get formattedAmount => '₦${amount.toStringAsFixed(2)}';
  String get formattedUnits => units.toStringAsFixed(4);
  String get formattedNAV => '₦${nav.toStringAsFixed(2)}';
}

@JsonSerializable()
class SIPSettings {
  final bool autoDebit;
  final bool skipOnInsufficientFunds;
  final bool pauseOnFailure;
  final int maxRetries;
  final int retryIntervalHours;
  final bool enableNotifications;
  final bool enableEmailAlerts;
  final bool enableSMSAlerts;
  final List<String> notificationTypes;
  final Map<String, dynamic> customSettings;

  SIPSettings({
    this.autoDebit = true,
    this.skipOnInsufficientFunds = false,
    this.pauseOnFailure = true,
    this.maxRetries = 3,
    this.retryIntervalHours = 24,
    this.enableNotifications = true,
    this.enableEmailAlerts = true,
    this.enableSMSAlerts = false,
    this.notificationTypes = const ['execution', 'failure', 'completion'],
    this.customSettings = const {},
  });

  factory SIPSettings.fromJson(Map<String, dynamic> json) => _$SIPSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$SIPSettingsToJson(this);
}

@JsonSerializable()
class SIPPerformance {
  final String sipId;
  final double totalInvested;
  final double currentValue;
  final double totalUnits;
  final double averageNAV;
  final double currentNAV;
  final double totalReturn;
  final double totalReturnPercentage;
  final double xirr;
  final int totalInstallments;
  final DateTime firstInvestmentDate;
  final DateTime? lastInvestmentDate;
  final DateTime calculatedAt;

  SIPPerformance({
    required this.sipId,
    required this.totalInvested,
    required this.currentValue,
    required this.totalUnits,
    required this.averageNAV,
    required this.currentNAV,
    required this.totalReturn,
    required this.totalReturnPercentage,
    required this.xirr,
    required this.totalInstallments,
    required this.firstInvestmentDate,
    this.lastInvestmentDate,
    required this.calculatedAt,
  });

  factory SIPPerformance.fromJson(Map<String, dynamic> json) => _$SIPPerformanceFromJson(json);
  Map<String, dynamic> toJson() => _$SIPPerformanceToJson(this);

  bool get isProfit => totalReturn > 0;
  String get formattedTotalInvested => '₦${totalInvested.toStringAsFixed(2)}';
  String get formattedCurrentValue => '₦${currentValue.toStringAsFixed(2)}';
  String get formattedTotalReturn => '₦${totalReturn.toStringAsFixed(2)}';
  String get formattedTotalReturnPercentage => '${totalReturnPercentage >= 0 ? '+' : ''}${totalReturnPercentage.toStringAsFixed(2)}%';
  String get formattedXIRR => '${xirr.toStringAsFixed(2)}%';
}

@JsonSerializable()
class AutoInvestmentRule {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final AutoInvestmentTrigger trigger;
  final List<AutoInvestmentAction> actions;
  final AutoInvestmentStatus status;
  final Map<String, dynamic> conditions;
  final DateTime? lastTriggered;
  final int triggerCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  AutoInvestmentRule({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.trigger,
    required this.actions,
    required this.status,
    this.conditions = const {},
    this.lastTriggered,
    this.triggerCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AutoInvestmentRule.fromJson(Map<String, dynamic> json) => _$AutoInvestmentRuleFromJson(json);
  Map<String, dynamic> toJson() => _$AutoInvestmentRuleToJson(this);

  bool get isActive => status == AutoInvestmentStatus.active;
}

@JsonSerializable()
class AutoInvestmentAction {
  final String id;
  final AutoInvestmentActionType type;
  final String fundId;
  final double? amount;
  final double? percentage;
  final Map<String, dynamic> parameters;

  AutoInvestmentAction({
    required this.id,
    required this.type,
    required this.fundId,
    this.amount,
    this.percentage,
    this.parameters = const {},
  });

  factory AutoInvestmentAction.fromJson(Map<String, dynamic> json) => _$AutoInvestmentActionFromJson(json);
  Map<String, dynamic> toJson() => _$AutoInvestmentActionToJson(this);
}

enum SIPFrequency {
  @JsonValue('DAILY')
  daily,
  @JsonValue('WEEKLY')
  weekly,
  @JsonValue('MONTHLY')
  monthly,
  @JsonValue('QUARTERLY')
  quarterly,
  @JsonValue('YEARLY')
  yearly,
}

enum SIPStatus {
  @JsonValue('ACTIVE')
  active,
  @JsonValue('PAUSED')
  paused,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('CANCELLED')
  cancelled,
  @JsonValue('DRAFT')
  draft,
}

enum SIPInstallmentStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('PROCESSING')
  processing,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('FAILED')
  failed,
  @JsonValue('SKIPPED')
  skipped,
  @JsonValue('CANCELLED')
  cancelled,
}

enum AutoInvestmentTrigger {
  @JsonValue('SALARY_CREDIT')
  salaryCredit,
  @JsonValue('WALLET_BALANCE')
  walletBalance,
  @JsonValue('MARKET_CONDITION')
  marketCondition,
  @JsonValue('DATE_BASED')
  dateBased,
  @JsonValue('GOAL_PROGRESS')
  goalProgress,
}

enum AutoInvestmentActionType {
  @JsonValue('INVEST_AMOUNT')
  investAmount,
  @JsonValue('INVEST_PERCENTAGE')
  investPercentage,
  @JsonValue('REBALANCE')
  rebalance,
  @JsonValue('PAUSE_SIP')
  pauseSIP,
  @JsonValue('RESUME_SIP')
  resumeSIP,
}

enum AutoInvestmentStatus {
  @JsonValue('ACTIVE')
  active,
  @JsonValue('INACTIVE')
  inactive,
  @JsonValue('PAUSED')
  paused,
}
