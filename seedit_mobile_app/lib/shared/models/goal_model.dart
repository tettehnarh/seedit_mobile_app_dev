import 'package:json_annotation/json_annotation.dart';

part 'goal_model.g.dart';

@JsonSerializable()
class FinancialGoal {
  final String id;
  final String userId;
  final String name;
  final String description;
  final GoalCategory category;
  final GoalPriority priority;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final DateTime? startDate;
  final GoalStatus status;
  final GoalStrategy strategy;
  final List<GoalMilestone> milestones;
  final List<String> linkedInvestmentIds;
  final List<String> linkedSIPIds;
  final GoalSettings settings;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  FinancialGoal({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.category,
    required this.priority,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.targetDate,
    this.startDate,
    required this.status,
    required this.strategy,
    this.milestones = const [],
    this.linkedInvestmentIds = const [],
    this.linkedSIPIds = const [],
    required this.settings,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory FinancialGoal.fromJson(Map<String, dynamic> json) => _$FinancialGoalFromJson(json);
  Map<String, dynamic> toJson() => _$FinancialGoalToJson(this);

  FinancialGoal copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    GoalCategory? category,
    GoalPriority? priority,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    DateTime? startDate,
    GoalStatus? status,
    GoalStrategy? strategy,
    List<GoalMilestone>? milestones,
    List<String>? linkedInvestmentIds,
    List<String>? linkedSIPIds,
    GoalSettings? settings,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FinancialGoal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      startDate: startDate ?? this.startDate,
      status: status ?? this.status,
      strategy: strategy ?? this.strategy,
      milestones: milestones ?? this.milestones,
      linkedInvestmentIds: linkedInvestmentIds ?? this.linkedInvestmentIds,
      linkedSIPIds: linkedSIPIds ?? this.linkedSIPIds,
      settings: settings ?? this.settings,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Calculated properties
  double get progressPercentage => targetAmount > 0 ? (currentAmount / targetAmount) * 100 : 0.0;
  double get remainingAmount => targetAmount - currentAmount;
  bool get isCompleted => currentAmount >= targetAmount;
  bool get isOverdue => DateTime.now().isAfter(targetDate) && !isCompleted;
  bool get isOnTrack => _calculateOnTrackStatus();
  
  int get daysRemaining => targetDate.difference(DateTime.now()).inDays;
  int get monthsRemaining => (daysRemaining / 30).ceil();
  
  double get monthlyRequiredAmount => monthsRemaining > 0 ? remainingAmount / monthsRemaining : 0.0;
  
  String get formattedTargetAmount => '₦${targetAmount.toStringAsFixed(2)}';
  String get formattedCurrentAmount => '₦${currentAmount.toStringAsFixed(2)}';
  String get formattedRemainingAmount => '₦${remainingAmount.toStringAsFixed(2)}';
  String get formattedMonthlyRequired => '₦${monthlyRequiredAmount.toStringAsFixed(2)}';

  bool _calculateOnTrackStatus() {
    if (isCompleted) return true;
    if (isOverdue) return false;
    
    final totalDays = targetDate.difference(startDate ?? createdAt).inDays;
    final elapsedDays = DateTime.now().difference(startDate ?? createdAt).inDays;
    
    if (totalDays <= 0) return false;
    
    final expectedProgress = (elapsedDays / totalDays) * 100;
    return progressPercentage >= expectedProgress * 0.8; // 80% threshold
  }
}

@JsonSerializable()
class GoalMilestone {
  final String id;
  final String goalId;
  final String name;
  final String? description;
  final double targetAmount;
  final DateTime targetDate;
  final MilestoneStatus status;
  final DateTime? achievedDate;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  GoalMilestone({
    required this.id,
    required this.goalId,
    required this.name,
    this.description,
    required this.targetAmount,
    required this.targetDate,
    required this.status,
    this.achievedDate,
    this.metadata = const {},
    required this.createdAt,
  });

  factory GoalMilestone.fromJson(Map<String, dynamic> json) => _$GoalMilestoneFromJson(json);
  Map<String, dynamic> toJson() => _$GoalMilestoneToJson(this);

  bool get isAchieved => status == MilestoneStatus.achieved;
  bool get isOverdue => DateTime.now().isAfter(targetDate) && !isAchieved;
  String get formattedTargetAmount => '₦${targetAmount.toStringAsFixed(2)}';
}

@JsonSerializable()
class GoalSettings {
  final bool enableNotifications;
  final bool enableMilestoneAlerts;
  final bool enableProgressReminders;
  final int reminderFrequencyDays;
  final bool autoInvestEnabled;
  final double? autoInvestAmount;
  final String? autoInvestFrequency;
  final bool rebalanceEnabled;
  final int rebalanceFrequencyMonths;
  final Map<String, dynamic> customSettings;

  GoalSettings({
    this.enableNotifications = true,
    this.enableMilestoneAlerts = true,
    this.enableProgressReminders = true,
    this.reminderFrequencyDays = 30,
    this.autoInvestEnabled = false,
    this.autoInvestAmount,
    this.autoInvestFrequency,
    this.rebalanceEnabled = false,
    this.rebalanceFrequencyMonths = 6,
    this.customSettings = const {},
  });

  factory GoalSettings.fromJson(Map<String, dynamic> json) => _$GoalSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$GoalSettingsToJson(this);
}

@JsonSerializable()
class GoalAllocation {
  final String id;
  final String goalId;
  final String fundId;
  final String fundName;
  final double allocationPercentage;
  final double currentValue;
  final double targetValue;
  final AllocationStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  GoalAllocation({
    required this.id,
    required this.goalId,
    required this.fundId,
    required this.fundName,
    required this.allocationPercentage,
    required this.currentValue,
    required this.targetValue,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GoalAllocation.fromJson(Map<String, dynamic> json) => _$GoalAllocationFromJson(json);
  Map<String, dynamic> toJson() => _$GoalAllocationToJson(this);

  double get progressPercentage => targetValue > 0 ? (currentValue / targetValue) * 100 : 0.0;
  double get remainingValue => targetValue - currentValue;
  bool get isOnTarget => progressPercentage >= 95.0;
  
  String get formattedCurrentValue => '₦${currentValue.toStringAsFixed(2)}';
  String get formattedTargetValue => '₦${targetValue.toStringAsFixed(2)}';
  String get formattedRemainingValue => '₦${remainingValue.toStringAsFixed(2)}';
}

@JsonSerializable()
class GoalRecommendation {
  final String id;
  final String goalId;
  final RecommendationType type;
  final String title;
  final String description;
  final Map<String, dynamic> actionData;
  final RecommendationPriority priority;
  final DateTime validUntil;
  final bool isRead;
  final bool isActioned;
  final DateTime createdAt;

  GoalRecommendation({
    required this.id,
    required this.goalId,
    required this.type,
    required this.title,
    required this.description,
    this.actionData = const {},
    required this.priority,
    required this.validUntil,
    this.isRead = false,
    this.isActioned = false,
    required this.createdAt,
  });

  factory GoalRecommendation.fromJson(Map<String, dynamic> json) => _$GoalRecommendationFromJson(json);
  Map<String, dynamic> toJson() => _$GoalRecommendationToJson(this);

  bool get isValid => DateTime.now().isBefore(validUntil);
  bool get isHighPriority => priority == RecommendationPriority.high;
}

@JsonSerializable()
class GoalProgress {
  final String goalId;
  final double currentAmount;
  final double progressPercentage;
  final List<ProgressDataPoint> progressHistory;
  final DateTime lastUpdated;
  final Map<String, dynamic> analytics;

  GoalProgress({
    required this.goalId,
    required this.currentAmount,
    required this.progressPercentage,
    this.progressHistory = const [],
    required this.lastUpdated,
    this.analytics = const {},
  });

  factory GoalProgress.fromJson(Map<String, dynamic> json) => _$GoalProgressFromJson(json);
  Map<String, dynamic> toJson() => _$GoalProgressToJson(this);
}

@JsonSerializable()
class ProgressDataPoint {
  final DateTime date;
  final double amount;
  final double percentage;
  final String? source; // 'investment', 'sip', 'manual'

  ProgressDataPoint({
    required this.date,
    required this.amount,
    required this.percentage,
    this.source,
  });

  factory ProgressDataPoint.fromJson(Map<String, dynamic> json) => _$ProgressDataPointFromJson(json);
  Map<String, dynamic> toJson() => _$ProgressDataPointToJson(this);
}

enum GoalCategory {
  @JsonValue('RETIREMENT')
  retirement,
  @JsonValue('EDUCATION')
  education,
  @JsonValue('HOME_PURCHASE')
  homePurchase,
  @JsonValue('EMERGENCY_FUND')
  emergencyFund,
  @JsonValue('VACATION')
  vacation,
  @JsonValue('WEDDING')
  wedding,
  @JsonValue('BUSINESS')
  business,
  @JsonValue('VEHICLE')
  vehicle,
  @JsonValue('HEALTHCARE')
  healthcare,
  @JsonValue('OTHER')
  other,
}

enum GoalPriority {
  @JsonValue('LOW')
  low,
  @JsonValue('MEDIUM')
  medium,
  @JsonValue('HIGH')
  high,
  @JsonValue('CRITICAL')
  critical,
}

enum GoalStatus {
  @JsonValue('DRAFT')
  draft,
  @JsonValue('ACTIVE')
  active,
  @JsonValue('PAUSED')
  paused,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('CANCELLED')
  cancelled,
  @JsonValue('OVERDUE')
  overdue,
}

enum GoalStrategy {
  @JsonValue('CONSERVATIVE')
  conservative,
  @JsonValue('MODERATE')
  moderate,
  @JsonValue('AGGRESSIVE')
  aggressive,
  @JsonValue('CUSTOM')
  custom,
}

enum MilestoneStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('IN_PROGRESS')
  inProgress,
  @JsonValue('ACHIEVED')
  achieved,
  @JsonValue('MISSED')
  missed,
}

enum AllocationStatus {
  @JsonValue('UNDER_ALLOCATED')
  underAllocated,
  @JsonValue('ON_TARGET')
  onTarget,
  @JsonValue('OVER_ALLOCATED')
  overAllocated,
}

enum RecommendationType {
  @JsonValue('INCREASE_INVESTMENT')
  increaseInvestment,
  @JsonValue('REBALANCE_PORTFOLIO')
  rebalancePortfolio,
  @JsonValue('CHANGE_STRATEGY')
  changeStrategy,
  @JsonValue('ADD_SIP')
  addSIP,
  @JsonValue('MILESTONE_REMINDER')
  milestoneReminder,
  @JsonValue('GOAL_ADJUSTMENT')
  goalAdjustment,
}

enum RecommendationPriority {
  @JsonValue('LOW')
  low,
  @JsonValue('MEDIUM')
  medium,
  @JsonValue('HIGH')
  high,
  @JsonValue('URGENT')
  urgent,
}
