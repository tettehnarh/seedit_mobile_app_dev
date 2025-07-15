import 'package:json_annotation/json_annotation.dart';

part 'goal_models.g.dart';

@JsonSerializable()
class PersonalGoal {
  @JsonKey(fromJson: _stringFromJson)
  final String id;
  @JsonKey(fromJson: _stringFromJson)
  final String name;
  final String? description;
  @JsonKey(name: 'target_amount', fromJson: _doubleFromJson)
  final double targetAmount;
  @JsonKey(name: 'current_amount', fromJson: _doubleFromJson)
  final double currentAmount;
  @JsonKey(name: 'target_date', fromJson: _stringFromJson)
  final String targetDate;
  @JsonKey(fromJson: _stringFromJson)
  final String status;
  @JsonKey(name: 'investment_frequency', fromJson: _stringFromJson)
  final String investmentFrequency;
  @JsonKey(name: 'required_amount_per_frequency', fromJson: _doubleFromJson)
  final double requiredAmountPerFrequency;
  @JsonKey(name: 'linked_fund', fromJson: _nullableStringFromJson)
  final String? linkedFund;
  @JsonKey(name: 'linked_fund_name')
  final String? linkedFundName;
  @JsonKey(name: 'reminder_enabled', fromJson: _boolFromJson)
  final bool reminderEnabled;
  @JsonKey(name: 'allocation_percentage', fromJson: _doubleFromJson)
  final double allocationPercentage;
  @JsonKey(name: 'progress_percentage', fromJson: _doubleFromJson)
  final double progressPercentage;
  @JsonKey(name: 'remaining_amount', fromJson: _doubleFromJson)
  final double remainingAmount;
  @JsonKey(name: 'is_completed', fromJson: _boolFromJson)
  final bool isCompleted;
  @JsonKey(name: 'created_at', fromJson: _stringFromJson)
  final String createdAt;
  @JsonKey(name: 'updated_at', fromJson: _stringFromJson)
  final String updatedAt;

  const PersonalGoal({
    required this.id,
    required this.name,
    this.description,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    required this.status,
    required this.investmentFrequency,
    required this.requiredAmountPerFrequency,
    this.linkedFund,
    this.linkedFundName,
    required this.reminderEnabled,
    required this.allocationPercentage,
    required this.progressPercentage,
    required this.remainingAmount,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PersonalGoal.fromJson(Map<String, dynamic> json) =>
      _$PersonalGoalFromJson(json);

  Map<String, dynamic> toJson() => _$PersonalGoalToJson(this);

  PersonalGoal copyWith({
    String? id,
    String? name,
    String? description,
    double? targetAmount,
    double? currentAmount,
    String? targetDate,
    String? status,
    String? investmentFrequency,
    double? requiredAmountPerFrequency,
    String? linkedFund,
    String? linkedFundName,
    bool? reminderEnabled,
    double? allocationPercentage,
    double? progressPercentage,
    double? remainingAmount,
    bool? isCompleted,
    String? createdAt,
    String? updatedAt,
  }) {
    return PersonalGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      status: status ?? this.status,
      investmentFrequency: investmentFrequency ?? this.investmentFrequency,
      requiredAmountPerFrequency:
          requiredAmountPerFrequency ?? this.requiredAmountPerFrequency,
      linkedFund: linkedFund ?? this.linkedFund,
      linkedFundName: linkedFundName ?? this.linkedFundName,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      allocationPercentage: allocationPercentage ?? this.allocationPercentage,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class GoalContribution {
  final String id;
  final double amount;
  final String? notes;
  final String? transaction;
  @JsonKey(name: 'created_at')
  final String createdAt;

  const GoalContribution({
    required this.id,
    required this.amount,
    this.notes,
    this.transaction,
    required this.createdAt,
  });

  factory GoalContribution.fromJson(Map<String, dynamic> json) =>
      _$GoalContributionFromJson(json);

  Map<String, dynamic> toJson() => _$GoalContributionToJson(this);
}

@JsonSerializable()
class GoalsDashboard {
  @JsonKey(name: 'total_goals')
  final int totalGoals;
  @JsonKey(name: 'active_goals')
  final int activeGoals;
  @JsonKey(name: 'completed_goals')
  final int completedGoals;
  @JsonKey(name: 'total_target_amount')
  final double totalTargetAmount;
  @JsonKey(name: 'total_current_amount')
  final double totalCurrentAmount;
  @JsonKey(name: 'overall_progress_percentage')
  final double overallProgressPercentage;
  @JsonKey(name: 'last_updated')
  final String lastUpdated;

  const GoalsDashboard({
    required this.totalGoals,
    required this.activeGoals,
    required this.completedGoals,
    required this.totalTargetAmount,
    required this.totalCurrentAmount,
    required this.overallProgressPercentage,
    required this.lastUpdated,
  });

  factory GoalsDashboard.fromJson(Map<String, dynamic> json) =>
      _$GoalsDashboardFromJson(json);

  Map<String, dynamic> toJson() => _$GoalsDashboardToJson(this);
}

@JsonSerializable()
class CreateGoalRequest {
  final String name;
  final String? description;
  @JsonKey(name: 'target_amount')
  final double targetAmount;
  @JsonKey(name: 'target_date')
  final String targetDate;
  @JsonKey(name: 'investment_frequency')
  final String investmentFrequency;
  @JsonKey(name: 'linked_fund', fromJson: _nullableStringFromJson)
  final String? linkedFund;
  @JsonKey(name: 'reminder_enabled')
  final bool reminderEnabled;
  @JsonKey(name: 'allocation_percentage')
  final double allocationPercentage;

  const CreateGoalRequest({
    required this.name,
    this.description,
    required this.targetAmount,
    required this.targetDate,
    required this.investmentFrequency,
    this.linkedFund,
    this.reminderEnabled = true,
    this.allocationPercentage = 100.0,
  });

  factory CreateGoalRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateGoalRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateGoalRequestToJson(this);
}

@JsonSerializable()
class ContributeToGoalRequest {
  final double amount;
  final String? notes;

  const ContributeToGoalRequest({required this.amount, this.notes});

  factory ContributeToGoalRequest.fromJson(Map<String, dynamic> json) =>
      _$ContributeToGoalRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ContributeToGoalRequestToJson(this);
}

@JsonSerializable()
class Fund {
  @JsonKey(fromJson: _idFromJson)
  final String id;
  final String name;
  @JsonKey(name: 'code')
  final String code;
  @JsonKey(name: 'is_active')
  final bool isActive;

  const Fund({
    required this.id,
    required this.name,
    required this.code,
    required this.isActive,
  });

  factory Fund.fromJson(Map<String, dynamic> json) => _$FundFromJson(json);

  Map<String, dynamic> toJson() => _$FundToJson(this);

  // Helper method to convert int or string ID to string
  static String _idFromJson(dynamic id) {
    if (id is int) {
      return id.toString();
    } else if (id is String) {
      return id;
    } else {
      throw ArgumentError(
        'ID must be either int or String, got ${id.runtimeType}',
      );
    }
  }
}

// Enums for goal status and investment frequency
enum GoalStatus { active, completed, paused, cancelled }

enum InvestmentFrequency { daily, weekly, monthly, quarterly }

// Extension methods for enums
extension GoalStatusExtension on GoalStatus {
  String get value {
    switch (this) {
      case GoalStatus.active:
        return 'active';
      case GoalStatus.completed:
        return 'completed';
      case GoalStatus.paused:
        return 'paused';
      case GoalStatus.cancelled:
        return 'cancelled';
    }
  }

  String get displayName {
    switch (this) {
      case GoalStatus.active:
        return 'Active';
      case GoalStatus.completed:
        return 'Completed';
      case GoalStatus.paused:
        return 'Paused';
      case GoalStatus.cancelled:
        return 'Cancelled';
    }
  }
}

extension InvestmentFrequencyExtension on InvestmentFrequency {
  String get value {
    switch (this) {
      case InvestmentFrequency.daily:
        return 'daily';
      case InvestmentFrequency.weekly:
        return 'weekly';
      case InvestmentFrequency.monthly:
        return 'monthly';
      case InvestmentFrequency.quarterly:
        return 'quarterly';
    }
  }

  String get displayName {
    switch (this) {
      case InvestmentFrequency.daily:
        return 'Daily';
      case InvestmentFrequency.weekly:
        return 'Weekly';
      case InvestmentFrequency.monthly:
        return 'Monthly';
      case InvestmentFrequency.quarterly:
        return 'Quarterly';
    }
  }
}

// Helper functions for safe JSON parsing
String _stringFromJson(dynamic value) {
  if (value == null) {
    return '';
  }
  if (value is String) {
    return value;
  }
  if (value is int) {
    return value.toString();
  }
  if (value is double) {
    return value.toString();
  }
  if (value is bool) {
    return value.toString();
  }
  return value.toString();
}

String? _nullableStringFromJson(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is String) {
    return value;
  }
  if (value is int) {
    return value.toString();
  }
  if (value is double) {
    return value.toString();
  }
  if (value is bool) {
    return value.toString();
  }
  return value.toString();
}

double _doubleFromJson(dynamic value) {
  if (value == null) {
    return 0.0;
  }
  if (value is double) {
    return value;
  }
  if (value is int) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value) ?? 0.0;
  }
  return 0.0;
}

bool _boolFromJson(dynamic value) {
  if (value == null) {
    return false;
  }
  if (value is bool) {
    return value;
  }
  if (value is String) {
    return value.toLowerCase() == 'true';
  }
  if (value is int) {
    return value != 0;
  }
  return false;
}
