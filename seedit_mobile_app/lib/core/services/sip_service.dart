import 'package:flutter/foundation.dart';
import '../../shared/models/sip_model.dart';

class SIPService {
  // Get user's SIP plans
  Future<List<SIPPlan>> getUserSIPPlans(String userId) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      return _getMockSIPPlans(userId);
    } catch (e) {
      debugPrint('Get user SIP plans error: $e');
      throw Exception('Failed to load SIP plans');
    }
  }

  // Get SIP plan by ID
  Future<SIPPlan?> getSIPPlanById(String sipId) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 300));
      
      return _getMockSIPPlan(sipId);
    } catch (e) {
      debugPrint('Get SIP plan by ID error: $e');
      return null;
    }
  }

  // Create new SIP plan
  Future<SIPPlan> createSIPPlan({
    required String userId,
    required String fundId,
    required String planName,
    String? description,
    required double amount,
    required SIPFrequency frequency,
    required DateTime startDate,
    DateTime? endDate,
    int? maxInstallments,
    required String paymentMethodId,
    SIPSettings? settings,
  }) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 800));
      
      final sipId = 'sip_${DateTime.now().millisecondsSinceEpoch}';
      final now = DateTime.now();
      
      final sip = SIPPlan(
        id: sipId,
        userId: userId,
        fundId: fundId,
        fundName: 'SeedIt Equity Growth Fund', // TODO: Get from fund service
        planName: planName,
        description: description,
        amount: amount,
        frequency: frequency,
        status: SIPStatus.active,
        startDate: startDate,
        endDate: endDate,
        maxInstallments: maxInstallments,
        paymentMethodId: paymentMethodId,
        paymentMethodType: 'wallet', // TODO: Get from payment method
        settings: settings ?? SIPSettings(),
        nextExecutionDate: _calculateNextExecutionDate(startDate, frequency),
        createdAt: now,
        updatedAt: now,
      );
      
      return sip;
    } catch (e) {
      debugPrint('Create SIP plan error: $e');
      throw Exception('Failed to create SIP plan');
    }
  }

  // Update SIP plan
  Future<SIPPlan> updateSIPPlan({
    required String sipId,
    String? planName,
    String? description,
    double? amount,
    SIPFrequency? frequency,
    DateTime? endDate,
    int? maxInstallments,
    String? paymentMethodId,
    SIPSettings? settings,
  }) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 600));
      
      final existingSIP = await getSIPPlanById(sipId);
      if (existingSIP == null) throw Exception('SIP plan not found');
      
      final updatedSIP = existingSIP.copyWith(
        planName: planName,
        description: description,
        amount: amount,
        frequency: frequency,
        endDate: endDate,
        maxInstallments: maxInstallments,
        paymentMethodId: paymentMethodId,
        settings: settings,
        updatedAt: DateTime.now(),
      );
      
      return updatedSIP;
    } catch (e) {
      debugPrint('Update SIP plan error: $e');
      throw Exception('Failed to update SIP plan');
    }
  }

  // Pause SIP plan
  Future<SIPPlan> pauseSIPPlan(String sipId) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 400));
      
      final existingSIP = await getSIPPlanById(sipId);
      if (existingSIP == null) throw Exception('SIP plan not found');
      
      return existingSIP.copyWith(
        status: SIPStatus.paused,
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Pause SIP plan error: $e');
      throw Exception('Failed to pause SIP plan');
    }
  }

  // Resume SIP plan
  Future<SIPPlan> resumeSIPPlan(String sipId) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 400));
      
      final existingSIP = await getSIPPlanById(sipId);
      if (existingSIP == null) throw Exception('SIP plan not found');
      
      return existingSIP.copyWith(
        status: SIPStatus.active,
        nextExecutionDate: _calculateNextExecutionDate(DateTime.now(), existingSIP.frequency),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Resume SIP plan error: $e');
      throw Exception('Failed to resume SIP plan');
    }
  }

  // Cancel SIP plan
  Future<SIPPlan> cancelSIPPlan(String sipId) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 400));
      
      final existingSIP = await getSIPPlanById(sipId);
      if (existingSIP == null) throw Exception('SIP plan not found');
      
      return existingSIP.copyWith(
        status: SIPStatus.cancelled,
        nextExecutionDate: null,
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Cancel SIP plan error: $e');
      throw Exception('Failed to cancel SIP plan');
    }
  }

  // Get SIP installments
  Future<List<SIPInstallment>> getSIPInstallments(String sipId) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 400));
      
      return _getMockSIPInstallments(sipId);
    } catch (e) {
      debugPrint('Get SIP installments error: $e');
      throw Exception('Failed to load SIP installments');
    }
  }

  // Execute SIP installment manually
  Future<SIPInstallment> executeSIPInstallment(String sipId) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 700));
      
      final installmentId = 'inst_${DateTime.now().millisecondsSinceEpoch}';
      final installment = SIPInstallment(
        id: installmentId,
        sipId: sipId,
        installmentNumber: 1, // TODO: Calculate actual number
        amount: 10000, // TODO: Get from SIP plan
        units: 125.5, // TODO: Calculate based on current NAV
        nav: 79.65,
        scheduledDate: DateTime.now(),
        executedDate: DateTime.now(),
        status: SIPInstallmentStatus.completed,
        paymentReference: 'PAY_${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      return installment;
    } catch (e) {
      debugPrint('Execute SIP installment error: $e');
      throw Exception('Failed to execute SIP installment');
    }
  }

  // Get SIP performance
  Future<SIPPerformance> getSIPPerformance(String sipId) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 400));
      
      return _getMockSIPPerformance(sipId);
    } catch (e) {
      debugPrint('Get SIP performance error: $e');
      throw Exception('Failed to load SIP performance');
    }
  }

  // Get auto investment rules
  Future<List<AutoInvestmentRule>> getAutoInvestmentRules(String userId) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 400));
      
      return _getMockAutoInvestmentRules(userId);
    } catch (e) {
      debugPrint('Get auto investment rules error: $e');
      throw Exception('Failed to load auto investment rules');
    }
  }

  // Create auto investment rule
  Future<AutoInvestmentRule> createAutoInvestmentRule({
    required String userId,
    required String name,
    String? description,
    required AutoInvestmentTrigger trigger,
    required List<AutoInvestmentAction> actions,
    Map<String, dynamic> conditions = const {},
  }) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 600));
      
      final ruleId = 'rule_${DateTime.now().millisecondsSinceEpoch}';
      final rule = AutoInvestmentRule(
        id: ruleId,
        userId: userId,
        name: name,
        description: description,
        trigger: trigger,
        actions: actions,
        status: AutoInvestmentStatus.active,
        conditions: conditions,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      return rule;
    } catch (e) {
      debugPrint('Create auto investment rule error: $e');
      throw Exception('Failed to create auto investment rule');
    }
  }

  // Calculate next execution date
  DateTime _calculateNextExecutionDate(DateTime startDate, SIPFrequency frequency) {
    switch (frequency) {
      case SIPFrequency.daily:
        return startDate.add(const Duration(days: 1));
      case SIPFrequency.weekly:
        return startDate.add(const Duration(days: 7));
      case SIPFrequency.monthly:
        return DateTime(startDate.year, startDate.month + 1, startDate.day);
      case SIPFrequency.quarterly:
        return DateTime(startDate.year, startDate.month + 3, startDate.day);
      case SIPFrequency.yearly:
        return DateTime(startDate.year + 1, startDate.month, startDate.day);
    }
  }

  // Mock data methods
  List<SIPPlan> _getMockSIPPlans(String userId) {
    return [
      SIPPlan(
        id: 'sip_001',
        userId: userId,
        fundId: 'fund_001',
        fundName: 'SeedIt Equity Growth Fund',
        planName: 'Monthly Growth Investment',
        description: 'Long-term wealth building through equity investments',
        amount: 10000,
        frequency: SIPFrequency.monthly,
        status: SIPStatus.active,
        startDate: DateTime.now().subtract(const Duration(days: 90)),
        maxInstallments: 60,
        completedInstallments: 3,
        totalInvested: 30000,
        totalUnits: 375.5,
        paymentMethodId: 'wallet_001',
        paymentMethodType: 'wallet',
        settings: SIPSettings(),
        nextExecutionDate: DateTime.now().add(const Duration(days: 15)),
        lastExecutionDate: DateTime.now().subtract(const Duration(days: 15)),
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      SIPPlan(
        id: 'sip_002',
        userId: userId,
        fundId: 'fund_002',
        fundName: 'SeedIt Balanced Fund',
        planName: 'Conservative Weekly SIP',
        description: 'Balanced approach with weekly investments',
        amount: 2500,
        frequency: SIPFrequency.weekly,
        status: SIPStatus.active,
        startDate: DateTime.now().subtract(const Duration(days: 60)),
        completedInstallments: 8,
        totalInvested: 20000,
        totalUnits: 250.8,
        paymentMethodId: 'bank_001',
        paymentMethodType: 'bank_transfer',
        settings: SIPSettings(),
        nextExecutionDate: DateTime.now().add(const Duration(days: 3)),
        lastExecutionDate: DateTime.now().subtract(const Duration(days: 4)),
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
    ];
  }

  SIPPlan _getMockSIPPlan(String sipId) {
    return _getMockSIPPlans('user_001')
        .firstWhere((sip) => sip.id == sipId);
  }

  List<SIPInstallment> _getMockSIPInstallments(String sipId) {
    return [
      SIPInstallment(
        id: 'inst_001',
        sipId: sipId,
        installmentNumber: 1,
        amount: 10000,
        units: 125.5,
        nav: 79.65,
        scheduledDate: DateTime.now().subtract(const Duration(days: 60)),
        executedDate: DateTime.now().subtract(const Duration(days: 60)),
        status: SIPInstallmentStatus.completed,
        paymentReference: 'PAY_123456',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
      SIPInstallment(
        id: 'inst_002',
        sipId: sipId,
        installmentNumber: 2,
        amount: 10000,
        units: 120.8,
        nav: 82.78,
        scheduledDate: DateTime.now().subtract(const Duration(days: 30)),
        executedDate: DateTime.now().subtract(const Duration(days: 30)),
        status: SIPInstallmentStatus.completed,
        paymentReference: 'PAY_789012',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      SIPInstallment(
        id: 'inst_003',
        sipId: sipId,
        installmentNumber: 3,
        amount: 10000,
        units: 0.0,
        nav: 0.0,
        scheduledDate: DateTime.now().add(const Duration(days: 15)),
        status: SIPInstallmentStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  SIPPerformance _getMockSIPPerformance(String sipId) {
    return SIPPerformance(
      sipId: sipId,
      totalInvested: 30000,
      currentValue: 32500,
      totalUnits: 375.5,
      averageNAV: 79.89,
      currentNAV: 86.55,
      totalReturn: 2500,
      totalReturnPercentage: 8.33,
      xirr: 12.5,
      totalInstallments: 3,
      firstInvestmentDate: DateTime.now().subtract(const Duration(days: 90)),
      lastInvestmentDate: DateTime.now().subtract(const Duration(days: 30)),
      calculatedAt: DateTime.now(),
    );
  }

  List<AutoInvestmentRule> _getMockAutoInvestmentRules(String userId) {
    return [
      AutoInvestmentRule(
        id: 'rule_001',
        userId: userId,
        name: 'Salary Auto-Invest',
        description: 'Automatically invest 20% of salary credits',
        trigger: AutoInvestmentTrigger.salaryCredit,
        actions: [
          AutoInvestmentAction(
            id: 'action_001',
            type: AutoInvestmentActionType.investPercentage,
            fundId: 'fund_001',
            percentage: 20.0,
          ),
        ],
        status: AutoInvestmentStatus.active,
        conditions: {'minAmount': 50000, 'maxAmount': 500000},
        lastTriggered: DateTime.now().subtract(const Duration(days: 30)),
        triggerCount: 3,
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
    ];
  }
}
