import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import '../../../core/api/api_client.dart';
import '../services/investment_service.dart';

/// Fund subscription data model
class FundSubscription {
  final String fundId;
  final String fundName;
  final bool isSubscribed;
  final bool termsAccepted;
  final bool minimumInvestmentMet;
  final double totalInvested;
  final double minimumInvestment;
  final DateTime? subscribedAt;

  const FundSubscription({
    required this.fundId,
    required this.fundName,
    required this.isSubscribed,
    required this.termsAccepted,
    required this.minimumInvestmentMet,
    required this.totalInvested,
    required this.minimumInvestment,
    this.subscribedAt,
  });

  factory FundSubscription.fromJson(Map<String, dynamic> json) {
    return FundSubscription(
      fundId: json['fund_id']?.toString() ?? '',
      fundName: json['fund_name'] ?? '',
      isSubscribed: json['is_subscribed'] ?? false,
      termsAccepted: json['terms_accepted'] ?? false,
      minimumInvestmentMet: json['minimum_investment_met'] ?? false,
      totalInvested:
          double.tryParse(json['total_invested']?.toString() ?? '0') ?? 0.0,
      minimumInvestment:
          double.tryParse(json['minimum_investment']?.toString() ?? '0') ?? 0.0,
      subscribedAt: json['subscribed_at'] != null
          ? DateTime.tryParse(json['subscribed_at'])
          : null,
    );
  }

  FundSubscription copyWith({
    String? fundId,
    String? fundName,
    bool? isSubscribed,
    bool? termsAccepted,
    bool? minimumInvestmentMet,
    double? totalInvested,
    double? minimumInvestment,
    DateTime? subscribedAt,
  }) {
    return FundSubscription(
      fundId: fundId ?? this.fundId,
      fundName: fundName ?? this.fundName,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      minimumInvestmentMet: minimumInvestmentMet ?? this.minimumInvestmentMet,
      totalInvested: totalInvested ?? this.totalInvested,
      minimumInvestment: minimumInvestment ?? this.minimumInvestment,
      subscribedAt: subscribedAt ?? this.subscribedAt,
    );
  }
}

/// Fund investment status model for enhanced fund details
class FundInvestmentStatus {
  final String fundId;
  final String fundName;
  final bool hasActiveInvestment;
  final bool isSubscribed;
  final bool termsAccepted;
  final bool minimumInvestmentMet;
  final double totalInvested;
  final double minimumInvestment;
  final Map<String, dynamic>? investmentDetails;
  final List<Map<String, dynamic>> recentTransactions;
  final bool canInvest;
  final bool canWithdraw;
  final bool canTopUp;

  const FundInvestmentStatus({
    required this.fundId,
    required this.fundName,
    required this.hasActiveInvestment,
    required this.isSubscribed,
    required this.termsAccepted,
    required this.minimumInvestmentMet,
    required this.totalInvested,
    required this.minimumInvestment,
    this.investmentDetails,
    this.recentTransactions = const [],
    required this.canInvest,
    required this.canWithdraw,
    required this.canTopUp,
  });

  factory FundInvestmentStatus.fromJson(Map<String, dynamic> json) {
    return FundInvestmentStatus(
      fundId: json['fund_id']?.toString() ?? '',
      fundName: json['fund_name'] ?? '',
      hasActiveInvestment: json['has_active_investment'] ?? false,
      isSubscribed: json['is_subscribed'] ?? false,
      termsAccepted: json['terms_accepted'] ?? false,
      minimumInvestmentMet: json['minimum_investment_met'] ?? false,
      totalInvested:
          double.tryParse(json['total_invested']?.toString() ?? '0') ?? 0.0,
      minimumInvestment:
          double.tryParse(json['minimum_investment']?.toString() ?? '0') ?? 0.0,
      investmentDetails: json['investment_details'],
      recentTransactions:
          (json['recent_transactions'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      canInvest: json['can_invest'] ?? false,
      canWithdraw: json['can_withdraw'] ?? false,
      canTopUp: json['can_top_up'] ?? false,
    );
  }
}

/// State class for fund subscriptions
class FundSubscriptionState {
  final Map<String, FundSubscription> subscriptions;
  final bool isLoading;
  final String? errorMessage;

  const FundSubscriptionState({
    this.subscriptions = const {},
    this.isLoading = false,
    this.errorMessage,
  });

  FundSubscriptionState copyWith({
    Map<String, FundSubscription>? subscriptions,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FundSubscriptionState(
      subscriptions: subscriptions ?? this.subscriptions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Riverpod provider for managing fund subscriptions
class FundSubscriptionNotifier extends StateNotifier<FundSubscriptionState> {
  final ApiClient _apiClient = ApiClient();
  final InvestmentService _investmentService = InvestmentService();

  FundSubscriptionNotifier() : super(const FundSubscriptionState());

  /// Get subscription status for a specific fund
  Future<FundSubscription?> getFundSubscription(String fundId) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final response = await _apiClient.get(
        '/investments/subscriptions/$fundId/',
      );

      final subscription = FundSubscription.fromJson(response);

      // Update state with new subscription
      final updatedSubscriptions = Map<String, FundSubscription>.from(
        state.subscriptions,
      );
      updatedSubscriptions[fundId] = subscription;

      state = state.copyWith(
        subscriptions: updatedSubscriptions,
        isLoading: false,
      );

      developer.log(
        'Fund subscription loaded: $fundId - ${subscription.isSubscribed}',
      );
      return subscription;
    } catch (e) {
      developer.log('Error getting fund subscription: $e', error: e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load subscription status',
      );
      return null;
    }
  }

  /// Accept terms and conditions for a fund
  Future<bool> acceptTerms(String fundId) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final response = await _apiClient.postWithAuth(
        '/investments/subscriptions/$fundId/',
        {},
      );

      final subscription = FundSubscription.fromJson(response);

      // Update state with new subscription
      final updatedSubscriptions = Map<String, FundSubscription>.from(
        state.subscriptions,
      );
      updatedSubscriptions[fundId] = subscription;

      state = state.copyWith(
        subscriptions: updatedSubscriptions,
        isLoading: false,
      );

      developer.log('Terms accepted for fund: $fundId');
      return true;
    } catch (e) {
      developer.log('Error accepting terms: $e', error: e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to accept terms',
      );
      return false;
    }
  }

  /// Get all user subscriptions with retry mechanism
  Future<void> loadAllSubscriptions({int retryCount = 0}) async {
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 2);

    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final response = await _apiClient.get('/investments/subscriptions/');

      final subscriptionsData =
          response['subscriptions'] as List<dynamic>? ?? [];

      final subscriptions = <String, FundSubscription>{};

      for (final data in subscriptionsData) {
        developer.log(
          '🔍 [FUND_SUBSCRIPTION_PROVIDER] Processing subscription data: $data',
        );
        final subscription = FundSubscription.fromJson(data);
        subscriptions[subscription.fundId] = subscription;
        developer.log(
          '✅ [FUND_SUBSCRIPTION_PROVIDER] Parsed subscription: ${subscription.fundName} (${subscription.fundId}) - subscribed: ${subscription.isSubscribed}',
        );
      }

      state = state.copyWith(subscriptions: subscriptions, isLoading: false);

      final endTimestamp = DateTime.now().toIso8601String();
      developer.log(
        '✅ [FUND_SUBSCRIPTION_PROVIDER] State updated at $endTimestamp',
      );
      developer.log('📊 [FUND_SUBSCRIPTION_PROVIDER] Final state:');
      developer.log('   - Total subscriptions: ${subscriptions.length}');
      developer.log('   - Is loading: false');
      developer.log('   - Error message: null');

      if (subscriptions.isNotEmpty) {
        developer.log(
          '📋 [FUND_SUBSCRIPTION_PROVIDER] All loaded subscriptions:',
        );
        subscriptions.forEach((fundId, subscription) {
          developer.log(
            '   - ${subscription.fundName} (${subscription.fundId}): subscribed=${subscription.isSubscribed}, total_invested=${subscription.totalInvested}',
          );
        });
      }

      developer.log(
        '✅ [FUND_SUBSCRIPTION_PROVIDER] All subscriptions loaded successfully: ${subscriptions.length}',
      );
    } catch (e) {
      final errorTimestamp = DateTime.now().toIso8601String();
      developer.log(
        '❌ [FUND_SUBSCRIPTION_PROVIDER] Error loading subscriptions at $errorTimestamp (attempt ${retryCount + 1}): $e',
        error: e,
      );

      if (retryCount < maxRetries) {
        developer.log(
          '🔄 [FUND_SUBSCRIPTION_PROVIDER] Retrying subscription load in ${retryDelay.inSeconds} seconds...',
        );
        await Future.delayed(retryDelay);
        return loadAllSubscriptions(retryCount: retryCount + 1);
      }

      final finalErrorMessage =
          'Failed to load subscriptions after $maxRetries attempts';
      state = state.copyWith(isLoading: false, errorMessage: finalErrorMessage);

      developer.log(
        '💥 [FUND_SUBSCRIPTION_PROVIDER] Final error after all retries: $finalErrorMessage',
      );
    }
  }

  /// Check if user is subscribed to a fund
  bool isSubscribedToFund(String fundId) {
    final subscription = state.subscriptions[fundId];
    return subscription?.isSubscribed ?? false;
  }

  /// Get subscription for a fund (from cache)
  FundSubscription? getSubscription(String fundId) {
    return state.subscriptions[fundId];
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Refresh subscription status after investment completion
  Future<void> refreshSubscriptionAfterInvestment(String fundId) async {
    try {
      developer.log(
        'Refreshing subscription status after investment for fund: $fundId',
      );

      // Force refresh the subscription status from backend
      await getFundSubscription(fundId);

      // Also refresh all subscriptions to ensure consistency
      await loadAllSubscriptions();

      developer.log(
        'Subscription status refreshed successfully for fund: $fundId',
      );
    } catch (e) {
      developer.log(
        'Error refreshing subscription after investment: $e',
        error: e,
      );
    }
  }

  /// Get fund investment status (enhanced version with investment details)
  Future<FundInvestmentStatus?> getFundInvestmentStatus(String fundId) async {
    try {
      developer.log('Getting fund investment status for fund: $fundId');

      final response = await _investmentService.getFundInvestmentStatus(fundId);
      final status = FundInvestmentStatus.fromJson(response);

      developer.log(
        'Fund investment status loaded: $fundId - hasActiveInvestment: ${status.hasActiveInvestment}',
      );
      return status;
    } catch (e) {
      developer.log('Error getting fund investment status: $e', error: e);
      return null;
    }
  }

  /// Clear all data (for logout)
  void clearData() {
    state = const FundSubscriptionState();
  }
}

/// Provider for FundSubscriptionNotifier
final fundSubscriptionProvider =
    StateNotifierProvider<FundSubscriptionNotifier, FundSubscriptionState>((
      ref,
    ) {
      return FundSubscriptionNotifier();
    });

/// Convenience providers for accessing specific parts of the state
final fundSubscriptionLoadingProvider = Provider<bool>((ref) {
  return ref.watch(fundSubscriptionProvider).isLoading;
});

final fundSubscriptionErrorProvider = Provider<String?>((ref) {
  return ref.watch(fundSubscriptionProvider).errorMessage;
});

/// Provider to check if user is subscribed to a specific fund
final isSubscribedToFundProvider = Provider.family<bool, String>((ref, fundId) {
  return ref
      .watch(fundSubscriptionProvider.notifier)
      .isSubscribedToFund(fundId);
});

/// Provider to get subscription for a specific fund
final fundSubscriptionDetailsProvider =
    Provider.family<FundSubscription?, String>((ref, fundId) {
      return ref
          .watch(fundSubscriptionProvider.notifier)
          .getSubscription(fundId);
    });

/// Provider to get fund investment status (async)
final fundInvestmentStatusProvider =
    FutureProvider.family<FundInvestmentStatus?, String>((ref, fundId) async {
      return ref
          .read(fundSubscriptionProvider.notifier)
          .getFundInvestmentStatus(fundId);
    });
