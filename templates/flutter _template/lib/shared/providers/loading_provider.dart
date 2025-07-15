import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;

/// Loading state for different operations
class LoadingState {
  final Map<String, bool> _loadingStates = {};
  final Map<String, String?> _loadingMessages = {};
  final Map<String, DateTime> _loadingStartTimes = {};

  LoadingState();

  /// Check if a specific operation is loading
  bool isLoading(String operation) => _loadingStates[operation] ?? false;

  /// Check if any operation is loading
  bool get hasAnyLoading => _loadingStates.values.any((loading) => loading);

  /// Get loading message for an operation
  String? getLoadingMessage(String operation) => _loadingMessages[operation];

  /// Get all currently loading operations
  List<String> get loadingOperations => 
      _loadingStates.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

  /// Get loading duration for an operation
  Duration? getLoadingDuration(String operation) {
    final startTime = _loadingStartTimes[operation];
    if (startTime != null && isLoading(operation)) {
      return DateTime.now().difference(startTime);
    }
    return null;
  }

  /// Create a copy with updated loading state
  LoadingState copyWith({
    required String operation,
    required bool isLoading,
    String? message,
  }) {
    final newState = LoadingState();
    newState._loadingStates.addAll(_loadingStates);
    newState._loadingMessages.addAll(_loadingMessages);
    newState._loadingStartTimes.addAll(_loadingStartTimes);

    if (isLoading) {
      newState._loadingStates[operation] = true;
      newState._loadingMessages[operation] = message;
      newState._loadingStartTimes[operation] = DateTime.now();
    } else {
      newState._loadingStates[operation] = false;
      newState._loadingMessages.remove(operation);
      newState._loadingStartTimes.remove(operation);
    }

    return newState;
  }

  /// Clear all loading states
  LoadingState clearAll() {
    return LoadingState();
  }
}

/// Notifier for managing global loading states
class LoadingNotifier extends StateNotifier<LoadingState> {
  LoadingNotifier() : super(LoadingState());

  /// Start loading for an operation
  void startLoading(String operation, {String? message}) {
    developer.log('🔄 Starting loading for operation: $operation');
    if (message != null) {
      developer.log('📝 Loading message: $message');
    }
    
    state = state.copyWith(
      operation: operation,
      isLoading: true,
      message: message,
    );
  }

  /// Stop loading for an operation
  void stopLoading(String operation) {
    final duration = state.getLoadingDuration(operation);
    developer.log('✅ Stopping loading for operation: $operation');
    if (duration != null) {
      developer.log('⏱️ Operation took: ${duration.inMilliseconds}ms');
    }
    
    state = state.copyWith(
      operation: operation,
      isLoading: false,
    );
  }

  /// Update loading message for an operation
  void updateLoadingMessage(String operation, String message) {
    if (state.isLoading(operation)) {
      developer.log('📝 Updating loading message for $operation: $message');
      state = state.copyWith(
        operation: operation,
        isLoading: true,
        message: message,
      );
    }
  }

  /// Clear all loading states
  void clearAll() {
    developer.log('🧹 Clearing all loading states');
    state = state.clearAll();
  }

  /// Execute an async operation with automatic loading management
  Future<T> withLoading<T>(
    String operation,
    Future<T> Function() asyncOperation, {
    String? loadingMessage,
    String? successMessage,
    String? errorMessage,
  }) async {
    try {
      startLoading(operation, message: loadingMessage);
      
      final result = await asyncOperation();
      
      if (successMessage != null) {
        developer.log('✅ $operation completed: $successMessage');
      }
      
      return result;
    } catch (error) {
      if (errorMessage != null) {
        developer.log('❌ $operation failed: $errorMessage');
      }
      developer.log('❌ Error in $operation: $error');
      rethrow;
    } finally {
      stopLoading(operation);
    }
  }
}

/// Global loading provider
final loadingProvider = StateNotifierProvider<LoadingNotifier, LoadingState>(
  (ref) => LoadingNotifier(),
);

/// Convenience providers for common loading operations
final isAnyLoadingProvider = Provider<bool>((ref) {
  return ref.watch(loadingProvider).hasAnyLoading;
});

/// Investment-specific loading providers
final investmentLoadingProvider = Provider<bool>((ref) {
  return ref.watch(loadingProvider).isLoading('investment');
});

final portfolioLoadingProvider = Provider<bool>((ref) {
  return ref.watch(loadingProvider).isLoading('portfolio');
});

final transactionLoadingProvider = Provider<bool>((ref) {
  return ref.watch(loadingProvider).isLoading('transaction');
});

final fundLoadingProvider = Provider<bool>((ref) {
  return ref.watch(loadingProvider).isLoading('funds');
});

/// Authentication loading providers
final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(loadingProvider).isLoading('auth');
});

final loginLoadingProvider = Provider<bool>((ref) {
  return ref.watch(loadingProvider).isLoading('login');
});

final signupLoadingProvider = Provider<bool>((ref) {
  return ref.watch(loadingProvider).isLoading('signup');
});

/// KYC loading providers
final kycLoadingProvider = Provider<bool>((ref) {
  return ref.watch(loadingProvider).isLoading('kyc');
});

final kycSubmissionLoadingProvider = Provider<bool>((ref) {
  return ref.watch(loadingProvider).isLoading('kyc_submission');
});

/// Groups loading providers
final groupsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(loadingProvider).isLoading('groups');
});

final groupCreationLoadingProvider = Provider<bool>((ref) {
  return ref.watch(loadingProvider).isLoading('group_creation');
});

/// Wallet loading providers
final walletLoadingProvider = Provider<bool>((ref) {
  return ref.watch(loadingProvider).isLoading('wallet');
});

final paymentLoadingProvider = Provider<bool>((ref) {
  return ref.watch(loadingProvider).isLoading('payment');
});

/// Utility functions for common loading operations
class LoadingOperations {
  static const String investment = 'investment';
  static const String portfolio = 'portfolio';
  static const String transaction = 'transaction';
  static const String funds = 'funds';
  static const String auth = 'auth';
  static const String login = 'login';
  static const String signup = 'signup';
  static const String kyc = 'kyc';
  static const String kycSubmission = 'kyc_submission';
  static const String groups = 'groups';
  static const String groupCreation = 'group_creation';
  static const String wallet = 'wallet';
  static const String payment = 'payment';
  static const String userProfile = 'user_profile';
  static const String settings = 'settings';
  static const String notifications = 'notifications';
  static const String support = 'support';
  static const String fileUpload = 'file_upload';
  static const String dataRefresh = 'data_refresh';
  static const String apiRequest = 'api_request';
}

/// Extension methods for easier loading management
extension LoadingExtensions on WidgetRef {
  /// Start loading for an operation
  void startLoading(String operation, {String? message}) {
    read(loadingProvider.notifier).startLoading(operation, message: message);
  }

  /// Stop loading for an operation
  void stopLoading(String operation) {
    read(loadingProvider.notifier).stopLoading(operation);
  }

  /// Check if an operation is loading
  bool isLoading(String operation) {
    return watch(loadingProvider).isLoading(operation);
  }

  /// Execute an async operation with automatic loading management
  Future<T> withLoading<T>(
    String operation,
    Future<T> Function() asyncOperation, {
    String? loadingMessage,
    String? successMessage,
    String? errorMessage,
  }) {
    return read(loadingProvider.notifier).withLoading(
      operation,
      asyncOperation,
      loadingMessage: loadingMessage,
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }
}
