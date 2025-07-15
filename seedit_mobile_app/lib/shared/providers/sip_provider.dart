import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../models/sip_model.dart';
import '../../core/services/sip_service.dart';
import 'auth_provider.dart';

// Service provider
final sipServiceProvider = Provider<SIPService>((ref) => SIPService());

// User SIP plans provider
final userSIPPlansProvider = FutureProvider<List<SIPPlan>>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return [];
  
  final service = ref.read(sipServiceProvider);
  return await service.getUserSIPPlans(currentUser.id);
});

// SIP plan by ID provider
final sipPlanByIdProvider = FutureProvider.family<SIPPlan?, String>((ref, sipId) async {
  final service = ref.read(sipServiceProvider);
  return await service.getSIPPlanById(sipId);
});

// SIP installments provider
final sipInstallmentsProvider = FutureProvider.family<List<SIPInstallment>, String>((ref, sipId) async {
  final service = ref.read(sipServiceProvider);
  return await service.getSIPInstallments(sipId);
});

// SIP performance provider
final sipPerformanceProvider = FutureProvider.family<SIPPerformance, String>((ref, sipId) async {
  final service = ref.read(sipServiceProvider);
  return await service.getSIPPerformance(sipId);
});

// Auto investment rules provider
final autoInvestmentRulesProvider = FutureProvider<List<AutoInvestmentRule>>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return [];
  
  final service = ref.read(sipServiceProvider);
  return await service.getAutoInvestmentRules(currentUser.id);
});

// SIP management state provider
final sipManagementProvider = StateNotifierProvider<SIPManagementNotifier, SIPManagementState>((ref) {
  return SIPManagementNotifier(ref.read(sipServiceProvider));
});

class SIPManagementState {
  final bool isLoading;
  final String? error;
  final SIPPlan? currentSIP;
  final SIPInstallment? currentInstallment;
  final SIPPerformance? currentPerformance;
  final AutoInvestmentRule? currentRule;

  SIPManagementState({
    this.isLoading = false,
    this.error,
    this.currentSIP,
    this.currentInstallment,
    this.currentPerformance,
    this.currentRule,
  });

  SIPManagementState copyWith({
    bool? isLoading,
    String? error,
    SIPPlan? currentSIP,
    SIPInstallment? currentInstallment,
    SIPPerformance? currentPerformance,
    AutoInvestmentRule? currentRule,
  }) {
    return SIPManagementState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentSIP: currentSIP ?? this.currentSIP,
      currentInstallment: currentInstallment ?? this.currentInstallment,
      currentPerformance: currentPerformance ?? this.currentPerformance,
      currentRule: currentRule ?? this.currentRule,
    );
  }
}

class SIPManagementNotifier extends StateNotifier<SIPManagementState> {
  final SIPService _service;

  SIPManagementNotifier(this._service) : super(SIPManagementState());

  // Create SIP plan
  Future<SIPPlan?> createSIPPlan({
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
    state = state.copyWith(isLoading: true, error: null);

    try {
      final sip = await _service.createSIPPlan(
        userId: userId,
        fundId: fundId,
        planName: planName,
        description: description,
        amount: amount,
        frequency: frequency,
        startDate: startDate,
        endDate: endDate,
        maxInstallments: maxInstallments,
        paymentMethodId: paymentMethodId,
        settings: settings,
      );

      state = state.copyWith(
        isLoading: false,
        currentSIP: sip,
      );

      return sip;
    } catch (e) {
      debugPrint('Create SIP plan error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  // Update SIP plan
  Future<SIPPlan?> updateSIPPlan({
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
    state = state.copyWith(isLoading: true, error: null);

    try {
      final sip = await _service.updateSIPPlan(
        sipId: sipId,
        planName: planName,
        description: description,
        amount: amount,
        frequency: frequency,
        endDate: endDate,
        maxInstallments: maxInstallments,
        paymentMethodId: paymentMethodId,
        settings: settings,
      );

      state = state.copyWith(
        isLoading: false,
        currentSIP: sip,
      );

      return sip;
    } catch (e) {
      debugPrint('Update SIP plan error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  // Pause SIP plan
  Future<bool> pauseSIPPlan(String sipId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final sip = await _service.pauseSIPPlan(sipId);
      
      state = state.copyWith(
        isLoading: false,
        currentSIP: sip,
      );

      return true;
    } catch (e) {
      debugPrint('Pause SIP plan error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Resume SIP plan
  Future<bool> resumeSIPPlan(String sipId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final sip = await _service.resumeSIPPlan(sipId);
      
      state = state.copyWith(
        isLoading: false,
        currentSIP: sip,
      );

      return true;
    } catch (e) {
      debugPrint('Resume SIP plan error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Cancel SIP plan
  Future<bool> cancelSIPPlan(String sipId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final sip = await _service.cancelSIPPlan(sipId);
      
      state = state.copyWith(
        isLoading: false,
        currentSIP: sip,
      );

      return true;
    } catch (e) {
      debugPrint('Cancel SIP plan error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Execute SIP installment
  Future<SIPInstallment?> executeSIPInstallment(String sipId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final installment = await _service.executeSIPInstallment(sipId);
      
      state = state.copyWith(
        isLoading: false,
        currentInstallment: installment,
      );

      return installment;
    } catch (e) {
      debugPrint('Execute SIP installment error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  // Create auto investment rule
  Future<AutoInvestmentRule?> createAutoInvestmentRule({
    required String userId,
    required String name,
    String? description,
    required AutoInvestmentTrigger trigger,
    required List<AutoInvestmentAction> actions,
    Map<String, dynamic> conditions = const {},
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final rule = await _service.createAutoInvestmentRule(
        userId: userId,
        name: name,
        description: description,
        trigger: trigger,
        actions: actions,
        conditions: conditions,
      );

      state = state.copyWith(
        isLoading: false,
        currentRule: rule,
      );

      return rule;
    } catch (e) {
      debugPrint('Create auto investment rule error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Clear current SIP
  void clearCurrentSIP() {
    state = state.copyWith(currentSIP: null);
  }

  // Clear current installment
  void clearCurrentInstallment() {
    state = state.copyWith(currentInstallment: null);
  }

  // Clear current performance
  void clearCurrentPerformance() {
    state = state.copyWith(currentPerformance: null);
  }

  // Clear current rule
  void clearCurrentRule() {
    state = state.copyWith(currentRule: null);
  }
}

// SIP calculator provider
final sipCalculatorProvider = StateNotifierProvider<SIPCalculatorNotifier, SIPCalculatorState>((ref) {
  return SIPCalculatorNotifier();
});

class SIPCalculatorState {
  final double amount;
  final SIPFrequency frequency;
  final int duration; // in months
  final double expectedReturn; // annual percentage
  final double totalInvestment;
  final double maturityValue;
  final double totalReturns;

  SIPCalculatorState({
    this.amount = 10000,
    this.frequency = SIPFrequency.monthly,
    this.duration = 60, // 5 years
    this.expectedReturn = 12.0,
    this.totalInvestment = 0,
    this.maturityValue = 0,
    this.totalReturns = 0,
  });

  SIPCalculatorState copyWith({
    double? amount,
    SIPFrequency? frequency,
    int? duration,
    double? expectedReturn,
    double? totalInvestment,
    double? maturityValue,
    double? totalReturns,
  }) {
    return SIPCalculatorState(
      amount: amount ?? this.amount,
      frequency: frequency ?? this.frequency,
      duration: duration ?? this.duration,
      expectedReturn: expectedReturn ?? this.expectedReturn,
      totalInvestment: totalInvestment ?? this.totalInvestment,
      maturityValue: maturityValue ?? this.maturityValue,
      totalReturns: totalReturns ?? this.totalReturns,
    );
  }
}

class SIPCalculatorNotifier extends StateNotifier<SIPCalculatorState> {
  SIPCalculatorNotifier() : super(SIPCalculatorState()) {
    _calculateSIP();
  }

  void updateAmount(double amount) {
    state = state.copyWith(amount: amount);
    _calculateSIP();
  }

  void updateFrequency(SIPFrequency frequency) {
    state = state.copyWith(frequency: frequency);
    _calculateSIP();
  }

  void updateDuration(int duration) {
    state = state.copyWith(duration: duration);
    _calculateSIP();
  }

  void updateExpectedReturn(double expectedReturn) {
    state = state.copyWith(expectedReturn: expectedReturn);
    _calculateSIP();
  }

  void _calculateSIP() {
    final amount = state.amount;
    final duration = state.duration;
    final annualReturn = state.expectedReturn / 100;
    
    // Calculate frequency multiplier
    int frequencyMultiplier;
    switch (state.frequency) {
      case SIPFrequency.daily:
        frequencyMultiplier = 365;
        break;
      case SIPFrequency.weekly:
        frequencyMultiplier = 52;
        break;
      case SIPFrequency.monthly:
        frequencyMultiplier = 12;
        break;
      case SIPFrequency.quarterly:
        frequencyMultiplier = 4;
        break;
      case SIPFrequency.yearly:
        frequencyMultiplier = 1;
        break;
    }
    
    final monthlyReturn = annualReturn / 12;
    final totalInstallments = (duration * 12) ~/ (12 / frequencyMultiplier);
    final totalInvestment = amount * totalInstallments;
    
    // Calculate maturity value using SIP formula
    final maturityValue = amount * 
        (((1 + monthlyReturn / frequencyMultiplier).pow(totalInstallments) - 1) / 
         (monthlyReturn / frequencyMultiplier)) * 
        (1 + monthlyReturn / frequencyMultiplier);
    
    final totalReturns = maturityValue - totalInvestment;
    
    state = state.copyWith(
      totalInvestment: totalInvestment,
      maturityValue: maturityValue,
      totalReturns: totalReturns,
    );
  }
}

// Extension for power calculation
extension NumExtension on num {
  double pow(num exponent) {
    return dart.math.pow(this, exponent).toDouble();
  }
}

import 'dart:math' as dart.math;
