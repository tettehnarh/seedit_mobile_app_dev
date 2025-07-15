// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PersonalGoal _$PersonalGoalFromJson(Map<String, dynamic> json) => PersonalGoal(
  id: _stringFromJson(json['id']),
  name: _stringFromJson(json['name']),
  description: json['description'] as String?,
  targetAmount: _doubleFromJson(json['target_amount']),
  currentAmount: _doubleFromJson(json['current_amount']),
  targetDate: _stringFromJson(json['target_date']),
  status: _stringFromJson(json['status']),
  investmentFrequency: _stringFromJson(json['investment_frequency']),
  requiredAmountPerFrequency: _doubleFromJson(
    json['required_amount_per_frequency'],
  ),
  linkedFund: _nullableStringFromJson(json['linked_fund']),
  linkedFundName: json['linked_fund_name'] as String?,
  reminderEnabled: _boolFromJson(json['reminder_enabled']),
  allocationPercentage: _doubleFromJson(json['allocation_percentage']),
  progressPercentage: _doubleFromJson(json['progress_percentage']),
  remainingAmount: _doubleFromJson(json['remaining_amount']),
  isCompleted: _boolFromJson(json['is_completed']),
  createdAt: _stringFromJson(json['created_at']),
  updatedAt: _stringFromJson(json['updated_at']),
);

Map<String, dynamic> _$PersonalGoalToJson(PersonalGoal instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'target_amount': instance.targetAmount,
      'current_amount': instance.currentAmount,
      'target_date': instance.targetDate,
      'status': instance.status,
      'investment_frequency': instance.investmentFrequency,
      'required_amount_per_frequency': instance.requiredAmountPerFrequency,
      'linked_fund': instance.linkedFund,
      'linked_fund_name': instance.linkedFundName,
      'reminder_enabled': instance.reminderEnabled,
      'allocation_percentage': instance.allocationPercentage,
      'progress_percentage': instance.progressPercentage,
      'remaining_amount': instance.remainingAmount,
      'is_completed': instance.isCompleted,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

GoalContribution _$GoalContributionFromJson(Map<String, dynamic> json) =>
    GoalContribution(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      notes: json['notes'] as String?,
      transaction: json['transaction'] as String?,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$GoalContributionToJson(GoalContribution instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'notes': instance.notes,
      'transaction': instance.transaction,
      'created_at': instance.createdAt,
    };

GoalsDashboard _$GoalsDashboardFromJson(Map<String, dynamic> json) =>
    GoalsDashboard(
      totalGoals: (json['total_goals'] as num).toInt(),
      activeGoals: (json['active_goals'] as num).toInt(),
      completedGoals: (json['completed_goals'] as num).toInt(),
      totalTargetAmount: (json['total_target_amount'] as num).toDouble(),
      totalCurrentAmount: (json['total_current_amount'] as num).toDouble(),
      overallProgressPercentage: (json['overall_progress_percentage'] as num)
          .toDouble(),
      lastUpdated: json['last_updated'] as String,
    );

Map<String, dynamic> _$GoalsDashboardToJson(GoalsDashboard instance) =>
    <String, dynamic>{
      'total_goals': instance.totalGoals,
      'active_goals': instance.activeGoals,
      'completed_goals': instance.completedGoals,
      'total_target_amount': instance.totalTargetAmount,
      'total_current_amount': instance.totalCurrentAmount,
      'overall_progress_percentage': instance.overallProgressPercentage,
      'last_updated': instance.lastUpdated,
    };

CreateGoalRequest _$CreateGoalRequestFromJson(Map<String, dynamic> json) =>
    CreateGoalRequest(
      name: json['name'] as String,
      description: json['description'] as String?,
      targetAmount: (json['target_amount'] as num).toDouble(),
      targetDate: json['target_date'] as String,
      investmentFrequency: json['investment_frequency'] as String,
      linkedFund: _nullableStringFromJson(json['linked_fund']),
      reminderEnabled: json['reminder_enabled'] as bool? ?? true,
      allocationPercentage:
          (json['allocation_percentage'] as num?)?.toDouble() ?? 100.0,
    );

Map<String, dynamic> _$CreateGoalRequestToJson(CreateGoalRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'target_amount': instance.targetAmount,
      'target_date': instance.targetDate,
      'investment_frequency': instance.investmentFrequency,
      'linked_fund': instance.linkedFund,
      'reminder_enabled': instance.reminderEnabled,
      'allocation_percentage': instance.allocationPercentage,
    };

ContributeToGoalRequest _$ContributeToGoalRequestFromJson(
  Map<String, dynamic> json,
) => ContributeToGoalRequest(
  amount: (json['amount'] as num).toDouble(),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$ContributeToGoalRequestToJson(
  ContributeToGoalRequest instance,
) => <String, dynamic>{'amount': instance.amount, 'notes': instance.notes};

Fund _$FundFromJson(Map<String, dynamic> json) => Fund(
  id: Fund._idFromJson(json['id']),
  name: json['name'] as String,
  code: json['code'] as String,
  isActive: json['is_active'] as bool,
);

Map<String, dynamic> _$FundToJson(Fund instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'code': instance.code,
  'is_active': instance.isActive,
};
