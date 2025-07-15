import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import '../models/wallet_models.dart';
import '../services/user_payment_methods_service.dart';
import '../../../core/api/api_exception.dart';

/// State class for user payment methods
class UserPaymentMethodsState {
  final List<PaymentMethod> paymentMethods;
  final bool isLoading;
  final bool isInitialized;
  final String? errorMessage;

  const UserPaymentMethodsState({
    this.paymentMethods = const [],
    this.isLoading = false,
    this.isInitialized = false,
    this.errorMessage,
  });

  UserPaymentMethodsState copyWith({
    List<PaymentMethod>? paymentMethods,
    bool? isLoading,
    bool? isInitialized,
    String? errorMessage,
    bool clearError = false,
  }) {
    return UserPaymentMethodsState(
      paymentMethods: paymentMethods ?? this.paymentMethods,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Riverpod provider for managing user payment methods
class UserPaymentMethodsNotifier
    extends StateNotifier<UserPaymentMethodsState> {
  final UserPaymentMethodsService _service = UserPaymentMethodsService();

  UserPaymentMethodsNotifier() : super(const UserPaymentMethodsState()) {
    _initializePaymentMethods();
  }

  /// Initialize payment methods data
  Future<void> _initializePaymentMethods() async {
    if (state.isInitialized) return;

    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final paymentMethods = await _service.getUserPaymentMethods();

      state = state.copyWith(
        paymentMethods: paymentMethods,
        isLoading: false,
        isInitialized: true,
      );

      developer.log(
        'User payment methods initialized: ${paymentMethods.length} methods',
      );
    } catch (e) {
      developer.log('Error initializing payment methods: $e', error: e);
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        errorMessage: 'Failed to load payment methods',
      );
    }
  }

  /// Refresh payment methods
  Future<void> loadPaymentMethods() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final paymentMethods = await _service.getUserPaymentMethods();

      state = state.copyWith(paymentMethods: paymentMethods, isLoading: false);

      developer.log(
        'Payment methods refreshed: ${paymentMethods.length} methods',
      );
    } catch (e) {
      developer.log('Error refreshing payment methods: $e', error: e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to refresh payment methods',
      );
    }
  }

  /// Create a new payment method
  Future<bool> createPaymentMethod({
    required String name,
    required String type,
    required Map<String, dynamic> details,
    bool isDefault = false,
  }) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      // Validate details
      final validationErrors = _service.validatePaymentMethodDetails(
        type,
        details,
      );
      if (validationErrors != null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: validationErrors.values.first,
        );
        return false;
      }

      final newPaymentMethod = await _service.createPaymentMethod(
        name: name,
        type: type,
        details: details,
        isDefault: isDefault,
      );

      // Add to current list
      final updatedMethods = [...state.paymentMethods, newPaymentMethod];
      state = state.copyWith(paymentMethods: updatedMethods, isLoading: false);

      developer.log('Payment method created: ${newPaymentMethod.displayName}');
      return true;
    } catch (e) {
      developer.log('Error creating payment method: $e', error: e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is NetworkException
            ? e.message
            : 'Failed to create payment method',
      );
      return false;
    }
  }

  /// Update a payment method
  Future<bool> updatePaymentMethod({
    required String id,
    String? name,
    Map<String, dynamic>? details,
    bool? isDefault,
  }) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final updatedPaymentMethod = await _service.updatePaymentMethod(
        id: id,
        name: name,
        details: details,
        isDefault: isDefault,
      );

      // Update in current list
      final updatedMethods = state.paymentMethods.map((method) {
        return method.id == id ? updatedPaymentMethod : method;
      }).toList();

      state = state.copyWith(paymentMethods: updatedMethods, isLoading: false);

      developer.log(
        'Payment method updated: ${updatedPaymentMethod.displayName}',
      );
      return true;
    } catch (e) {
      developer.log('Error updating payment method: $e', error: e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is NetworkException
            ? e.message
            : 'Failed to update payment method',
      );
      return false;
    }
  }

  /// Delete a payment method
  Future<bool> deletePaymentMethod(String id) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      await _service.deletePaymentMethod(id);

      // Remove from current list
      final updatedMethods = state.paymentMethods
          .where((method) => method.id != id)
          .toList();
      state = state.copyWith(paymentMethods: updatedMethods, isLoading: false);

      developer.log('Payment method deleted: $id');
      return true;
    } catch (e) {
      developer.log('Error deleting payment method: $e', error: e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is NetworkException
            ? e.message
            : 'Failed to delete payment method',
      );
      return false;
    }
  }

  /// Get available payment method types
  List<Map<String, String>> getAvailableTypes() {
    return _service.getAvailablePaymentMethodTypes();
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Clear all data (for logout)
  void clearData() {
    state = const UserPaymentMethodsState();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}

/// Provider for UserPaymentMethodsNotifier
final userPaymentMethodsProvider =
    StateNotifierProvider<UserPaymentMethodsNotifier, UserPaymentMethodsState>((
      ref,
    ) {
      return UserPaymentMethodsNotifier();
    });

/// Convenience providers for accessing specific parts of the state
final userPaymentMethodsListProvider = Provider<List<PaymentMethod>>((ref) {
  return ref.watch(userPaymentMethodsProvider).paymentMethods;
});

final userPaymentMethodsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(userPaymentMethodsProvider).isLoading;
});

final userPaymentMethodsErrorProvider = Provider<String?>((ref) {
  return ref.watch(userPaymentMethodsProvider).errorMessage;
});

final defaultPaymentMethodProvider = Provider<PaymentMethod?>((ref) {
  final methods = ref.watch(userPaymentMethodsListProvider);
  try {
    return methods.firstWhere((method) => method.isDefault);
  } catch (e) {
    return methods.isNotEmpty ? methods.first : null;
  }
});
