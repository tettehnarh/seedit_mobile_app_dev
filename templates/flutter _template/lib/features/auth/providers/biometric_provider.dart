import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import '../services/biometric_service.dart';

/// Provider for biometric service
final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

/// State class for biometric authentication
class BiometricState {
  final bool isAvailable;
  final bool isEnabled;
  final bool isLoading;
  final List<BiometricType> availableTypes;
  final String? errorMessage;
  final String? successMessage;

  const BiometricState({
    this.isAvailable = false,
    this.isEnabled = false,
    this.isLoading = false,
    this.availableTypes = const [],
    this.errorMessage,
    this.successMessage,
  });

  BiometricState copyWith({
    bool? isAvailable,
    bool? isEnabled,
    bool? isLoading,
    List<BiometricType>? availableTypes,
    String? errorMessage,
    String? successMessage,
  }) {
    return BiometricState(
      isAvailable: isAvailable ?? this.isAvailable,
      isEnabled: isEnabled ?? this.isEnabled,
      isLoading: isLoading ?? this.isLoading,
      availableTypes: availableTypes ?? this.availableTypes,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  /// Clear messages
  BiometricState clearMessages() {
    return copyWith(errorMessage: null, successMessage: null);
  }

  @override
  String toString() {
    return 'BiometricState(isAvailable: $isAvailable, isEnabled: $isEnabled, isLoading: $isLoading, availableTypes: $availableTypes, errorMessage: $errorMessage, successMessage: $successMessage)';
  }
}

/// Notifier for managing biometric authentication state
class BiometricNotifier extends StateNotifier<BiometricState> {
  final BiometricService _biometricService;

  BiometricNotifier(this._biometricService) : super(const BiometricState()) {
    // Delay initialization to avoid provider modification during build
    Future(() {
      _initialize();
    });
  }

  /// Initialize biometric state
  Future<void> _initialize() async {
    developer.log('Initializing biometric state', name: 'BiometricNotifier');
    await checkBiometricStatus();
  }

  /// Check current biometric status
  Future<void> checkBiometricStatus() async {
    try {
      state = state.copyWith(isLoading: true);

      // Check availability
      final availability = await _biometricService.checkBiometricAvailability();
      final isAvailable = availability == BiometricAvailability.available;

      // Get available types
      final availableTypes = isAvailable
          ? await _biometricService.getAvailableBiometrics()
          : <BiometricType>[];

      // Check if enabled
      final isEnabled =
          isAvailable && await _biometricService.isBiometricEnabled();

      state = state.copyWith(
        isAvailable: isAvailable,
        isEnabled: isEnabled,
        availableTypes: availableTypes,
        isLoading: false,
      );

      developer.log(
        'Biometric status updated: available=$isAvailable, enabled=$isEnabled',
        name: 'BiometricNotifier',
      );
    } catch (e) {
      developer.log(
        'Error checking biometric status: $e',
        name: 'BiometricNotifier',
      );
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to check biometric status',
      );
    }
  }

  /// Enable biometric authentication
  Future<bool> enableBiometric(String authToken) async {
    try {
      developer.log(
        'Enabling biometric authentication',
        name: 'BiometricNotifier',
      );
      state = state.copyWith(isLoading: true);

      final result = await _biometricService.enableBiometric(authToken);

      if (result.success) {
        state = state.copyWith(
          isEnabled: true,
          isLoading: false,
          successMessage: result.message,
        );
        developer.log(
          'Biometric authentication enabled successfully',
          name: 'BiometricNotifier',
        );
        return true;
      } else {
        state = state.copyWith(isLoading: false, errorMessage: result.message);
        developer.log(
          'Failed to enable biometric authentication: ${result.message}',
          name: 'BiometricNotifier',
        );
        return false;
      }
    } catch (e) {
      developer.log(
        'Error enabling biometric authentication: $e',
        name: 'BiometricNotifier',
      );
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to enable biometric authentication',
      );
      return false;
    }
  }

  /// Disable biometric authentication
  Future<bool> disableBiometric() async {
    try {
      developer.log(
        'Disabling biometric authentication',
        name: 'BiometricNotifier',
      );
      state = state.copyWith(isLoading: true);

      final result = await _biometricService.disableBiometric();

      if (result.success) {
        state = state.copyWith(
          isEnabled: false,
          isLoading: false,
          successMessage: result.message,
        );
        developer.log(
          'Biometric authentication disabled successfully',
          name: 'BiometricNotifier',
        );
        return true;
      } else {
        state = state.copyWith(isLoading: false, errorMessage: result.message);
        developer.log(
          'Failed to disable biometric authentication: ${result.message}',
          name: 'BiometricNotifier',
        );
        return false;
      }
    } catch (e) {
      developer.log(
        'Error disabling biometric authentication: $e',
        name: 'BiometricNotifier',
      );
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to disable biometric authentication',
      );
      return false;
    }
  }

  /// Authenticate with biometrics
  Future<String?> authenticateWithBiometric() async {
    try {
      developer.log(
        'Attempting biometric authentication',
        name: 'BiometricNotifier',
      );
      state = state.copyWith(isLoading: true);

      final result = await _biometricService.authenticateWithBiometric();

      state = state.copyWith(isLoading: false);

      if (result.success && result.authToken != null) {
        developer.log(
          'Biometric authentication successful',
          name: 'BiometricNotifier',
        );
        return result.authToken;
      } else {
        state = state.copyWith(
          errorMessage:
              result.errorMessage ?? 'Biometric authentication failed',
        );
        developer.log(
          'Biometric authentication failed: ${result.errorMessage}',
          name: 'BiometricNotifier',
        );
        return null;
      }
    } catch (e) {
      developer.log(
        'Error during biometric authentication: $e',
        name: 'BiometricNotifier',
      );
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Biometric authentication error',
      );
      return null;
    }
  }

  /// Clear biometric data (for logout)
  Future<void> clearBiometricData() async {
    try {
      developer.log('Clearing biometric data', name: 'BiometricNotifier');
      await _biometricService.clearBiometricData();

      state = state.copyWith(
        isEnabled: false,
        successMessage: 'Biometric data cleared',
      );
    } catch (e) {
      developer.log(
        'Error clearing biometric data: $e',
        name: 'BiometricNotifier',
      );
      state = state.copyWith(errorMessage: 'Failed to clear biometric data');
    }
  }

  /// Get user-friendly biometric type name
  String getBiometricTypeName() {
    return _biometricService.getBiometricTypeName(state.availableTypes);
  }

  /// Clear messages
  void clearMessages() {
    state = state.clearMessages();
  }

  /// Refresh biometric status
  Future<void> refresh() async {
    await checkBiometricStatus();
  }
}

/// Provider for biometric state management
final biometricProvider =
    StateNotifierProvider<BiometricNotifier, BiometricState>((ref) {
      final biometricService = ref.read(biometricServiceProvider);
      return BiometricNotifier(biometricService);
    });

/// Provider to check if biometric is available
final biometricAvailableProvider = FutureProvider<bool>((ref) async {
  final biometricService = ref.read(biometricServiceProvider);
  final availability = await biometricService.checkBiometricAvailability();
  return availability == BiometricAvailability.available;
});

/// Provider to check if biometric is enabled
final biometricEnabledProvider = FutureProvider<bool>((ref) async {
  final biometricService = ref.read(biometricServiceProvider);
  return await biometricService.isBiometricEnabled();
});

/// Provider for available biometric types
final availableBiometricsProvider = FutureProvider<List<BiometricType>>((
  ref,
) async {
  final biometricService = ref.read(biometricServiceProvider);
  return await biometricService.getAvailableBiometrics();
});
