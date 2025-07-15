import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../../../core/utils/storage_utils.dart';
import '../../kyc/services/kyc_service.dart';
import '../../kyc/services/cached_kyc_service.dart';
import 'dart:developer' as developer;

/// State class for user management
class UserState {
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;
  final bool isLoggedIn;

  const UserState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.isLoggedIn = false,
  });

  UserState copyWith({
    UserModel? user,
    bool? isLoading,
    String? errorMessage,
    bool? isLoggedIn,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return UserState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

/// Riverpod provider for managing user state
class UserNotifier extends StateNotifier<UserState> {
  final AuthService _authService = AuthService();
  final KycService _kycService = KycService();
  final CachedKycService _cachedKycService = CachedKycService();

  UserNotifier() : super(const UserState()) {
    _initializeUser();
  }

  /// Initialize user from stored data
  Future<void> _initializeUser() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final isUserLoggedIn = await _authService.isLoggedIn();

      if (isUserLoggedIn) {
        // Load user data from storage first (without updating state)
        UserModel? tempUser;
        try {
          final email = await StorageUtils.getUserEmail();
          final userId = await StorageUtils.getString('user_id');
          final userName = await StorageUtils.getString('user_name');
          final kycStatus = await StorageUtils.getString('kyc_status');
          final isEmailVerified = await StorageUtils.getBool('email_verified');

          if (email != null && userId != null) {
            // Parse name into first and last name
            final nameParts = userName?.split(' ') ?? [];
            final firstName = nameParts.isNotEmpty ? nameParts.first : '';
            final lastName = nameParts.length > 1
                ? nameParts.sublist(1).join(' ')
                : '';

            tempUser = UserModel(
              id: userId,
              email: email,
              username: userName ?? email.split('@')[0],
              firstName: firstName,
              lastName: lastName,
              isEmailVerified: isEmailVerified,
              kycStatus: kycStatus ?? 'not_started',
            );
          }
        } catch (e) {
          developer.log('Error loading user from storage: $e', error: e);
        }

        // Sync KYC status from backend and get the most current data
        String? backendKycStatus;
        try {
          developer.log('🔄 Syncing KYC status using cached service...');

          final result = await _cachedKycService.getKycStatus(
            operationType: 'login',
          );

          if (result['success'] == true && result['data'] != null) {
            final data = result['data'];
            backendKycStatus = data['status'] ?? data['kyc_status'];
            final isCached = result['cached'] ?? false;
            final cacheHit = result['cache_hit'] ?? false;

            developer.log(
              '📊 KYC Status Result: Status=$backendKycStatus, Cached=$isCached, Hit=$cacheHit',
            );

            if (backendKycStatus != null && backendKycStatus.isNotEmpty) {
              // Update local storage with backend status
              await StorageUtils.setString('kyc_status', backendKycStatus);
              developer.log(
                '✅ KYC status synced from backend: $backendKycStatus',
              );
            }
          } else {
            developer.log(
              '❌ Failed to fetch KYC status from backend: ${result['error']}',
            );
          }
        } catch (e) {
          developer.log(
            '💥 Error syncing KYC status from backend: $e',
            error: e,
          );
        }

        // Update user with the most current KYC status (backend takes priority)
        if (tempUser != null) {
          final finalKycStatus = backendKycStatus ?? tempUser.kycStatus;
          final finalUser = tempUser.copyWith(kycStatus: finalKycStatus);

          // Single state update with final user data
          state = state.copyWith(
            user: finalUser,
            isLoggedIn: true,
            isLoading: false,
          );

          developer.log(
            'User initialized with final KYC status: $finalKycStatus',
          );
        } else {
          state = state.copyWith(isLoggedIn: true, isLoading: false);
        }
      } else {
        state = state.copyWith(isLoggedIn: false, isLoading: false);
      }
    } catch (e) {
      developer.log('Error initializing user: $e', error: e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to initialize user data',
      );
    }
  }

  /// Sync KYC status from backend using cached service
  Future<void> _syncKycStatusFromBackend() async {
    try {
      developer.log('🔄 Syncing KYC status using cached service...');

      // Use cached KYC service for optimized performance
      final result = await _cachedKycService.getKycStatus(
        operationType: 'login',
      );

      if (result['success'] == true && result['data'] != null) {
        final data = result['data'];
        final backendStatus = data['status'] ?? data['kyc_status'];
        final isCached = result['cached'] ?? false;
        final cacheHit = result['cache_hit'] ?? false;

        developer.log(
          '📊 KYC Status Result: Status=$backendStatus, Cached=$isCached, Hit=$cacheHit',
        );

        if (backendStatus != null && backendStatus.isNotEmpty) {
          // Update user's KYC status with backend value
          if (state.user != null) {
            final currentStatus = state.user!.kycStatus;

            // CRITICAL FIX: Always update to backend status, especially for pending_review
            // This ensures the authoritative backend status is preserved
            if (currentStatus != backendStatus) {
              developer.log(
                '🔄 Updating KYC status: $currentStatus → $backendStatus',
              );

              final updatedUser = state.user!.copyWith(
                kycStatus: backendStatus,
              );
              state = state.copyWith(user: updatedUser);

              // Update local storage with backend status
              await StorageUtils.setString('kyc_status', backendStatus);

              developer.log('✅ KYC status synced successfully: $backendStatus');
            } else {
              developer.log('✅ KYC status already up to date: $backendStatus');
            }
          } else {
            developer.log('⚠️ No user found to update KYC status');
          }
        } else {
          developer.log('⚠️ No valid status field in backend response');
        }
      } else {
        developer.log(
          '❌ Failed to fetch KYC status from backend: ${result['error']}',
        );
        // Don't update status if backend call fails - keep cached value
        // This prevents reverting to fallback values during network issues
      }
    } catch (e) {
      developer.log('💥 Error syncing KYC status from backend: $e', error: e);
      // Don't update status if there's an error - keep cached value
      // This prevents reverting to fallback values during errors
    }
  }

  /// Update user data after successful login
  void updateUserAfterLogin(Map<String, dynamic> userData) {
    try {
      final user = UserModel.fromJson(userData);
      state = state.copyWith(user: user, isLoggedIn: true, clearError: true);
      developer.log('User updated after login: ${user.displayName}');
    } catch (e) {
      developer.log('Error updating user after login: $e', error: e);
      state = state.copyWith(errorMessage: 'Failed to update user data');
    }
  }

  /// Update KYC status
  void updateKycStatus(String newStatus) {
    if (state.user != null) {
      final updatedUser = state.user!.copyWith(kycStatus: newStatus);
      state = state.copyWith(user: updatedUser);

      // Also update in storage
      StorageUtils.setString('kyc_status', newStatus);
      developer.log('KYC status updated to: $newStatus');
    }
  }

  /// Update user profile
  void updateUserProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) {
    if (state.user != null) {
      final updatedUser = state.user!.copyWith(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );
      state = state.copyWith(user: updatedUser);

      // Update storage
      if (firstName != null || lastName != null) {
        final fullName =
            '${firstName ?? state.user!.firstName} ${lastName ?? state.user!.lastName}'
                .trim();
        StorageUtils.setString('user_name', fullName);
      }

      if (phoneNumber != null) {
        StorageUtils.setString('user_phone', phoneNumber);
      }

      developer.log('User profile updated');
    }
  }

  /// Refresh user data from server
  Future<void> refreshUserData() async {
    try {
      developer.log('🔄 [USER_PROVIDER] refreshUserData() ENTRY');
      state = state.copyWith(isLoading: true, clearError: true);

      // First sync KYC status from backend to get the most current status
      developer.log('🔄 [USER_PROVIDER] Syncing KYC status from backend...');
      await _syncKycStatusFromBackend();

      developer.log(
        '🌐 [USER_PROVIDER] Calling _authService.getUserProfile()...',
      );
      final response = await _authService.getUserProfile();

      developer.log('✅ [USER_PROVIDER] getUserProfile() completed');
      developer.log('📦 [USER_PROVIDER] Response: $response');

      if (response['success'] == true) {
        developer.log(
          '🎯 [USER_PROVIDER] Response success, parsing user data...',
        );
        final user = UserModel.fromJson(response['data']);

        // CRITICAL FIX: Use the fresh backend KYC status that was just synced
        // The _syncKycStatusFromBackend() call above already updated state.user.kycStatus
        // with the latest backend status, so we should preserve that instead of overriding it
        final freshKycStatus = state.user?.kycStatus ?? 'not_started';
        final updatedUser = user.copyWith(kycStatus: freshKycStatus);

        state = state.copyWith(user: updatedUser, isLoading: false);
        developer.log(
          '✅ [USER_PROVIDER] User data refreshed successfully with fresh KYC status: $freshKycStatus',
        );
      } else {
        developer.log(
          '❌ [USER_PROVIDER] getUserProfile() failed: ${response['error']}',
        );
        state = state.copyWith(
          isLoading: false,
          errorMessage: response['error'] ?? 'Failed to refresh user data',
        );
      }
    } catch (e) {
      developer.log(
        '❌ [USER_PROVIDER] Error refreshing user data: $e',
        error: e,
      );
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to refresh user data',
      );
    }
  }

  /// Force refresh KYC status (bypass cache)
  Future<void> forceRefreshKycStatus() async {
    try {
      developer.log('🔄 Force refreshing KYC status (bypass cache)...');

      final result = await _cachedKycService.refreshKycStatus(
        operationType: 'login',
      );

      if (result['success'] == true && result['data'] != null) {
        final data = result['data'];
        final backendStatus = data['status'] ?? data['kyc_status'];

        if (backendStatus != null && state.user != null) {
          final currentStatus = state.user!.kycStatus;

          if (currentStatus != backendStatus) {
            developer.log(
              '🔄 Force updating KYC status: $currentStatus → $backendStatus',
            );

            final updatedUser = state.user!.copyWith(kycStatus: backendStatus);
            state = state.copyWith(user: updatedUser);

            await StorageUtils.setString('kyc_status', backendStatus);
            developer.log('✅ KYC status force refreshed: $backendStatus');
          } else {
            developer.log(
              '✅ KYC status unchanged after force refresh: $backendStatus',
            );
          }
        }
      } else {
        developer.log(
          '❌ Failed to force refresh KYC status: ${result['error']}',
        );
      }
    } catch (e) {
      developer.log('💥 Error force refreshing KYC status: $e', error: e);
    }
  }

  /// Get cache statistics for monitoring
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      return await _cachedKycService.getCacheStats();
    } catch (e) {
      developer.log('Error getting cache stats: $e');
      return {'error': e.toString()};
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      developer.log('Starting user logout process...');

      final result = await _authService.logout();

      if (result['success'] == true) {
        // Reset to initial state
        state = const UserState();

        // Additional cleanup
        await _clearUserCaches();

        developer.log('User logged out successfully');
      } else {
        state = state.copyWith(
          errorMessage: result['error'] ?? 'Logout failed',
        );
      }
    } catch (e) {
      developer.log('Error during logout: $e', error: e);

      // Force reset state even if logout fails
      state = const UserState();

      // Try to clear caches anyway
      try {
        await _clearUserCaches();
      } catch (cacheError) {
        developer.log(
          'Error clearing user caches: $cacheError',
          error: cacheError,
        );
      }

      state = state.copyWith(errorMessage: 'Logout completed with errors');
    }
  }

  /// Clear user-specific caches
  Future<void> _clearUserCaches() async {
    try {
      await Future.wait([
        StorageUtils.clearUserData(),
        StorageUtils.remove('user_cache'),
        StorageUtils.remove('profile_cache'),
      ]);
      developer.log('User caches cleared');
    } catch (e) {
      developer.log('Error clearing user caches: $e', error: e);
    }
  }

  /// Complete session cleanup for user data
  Future<void> clearCompleteSession() async {
    try {
      developer.log('Clearing complete user session...');

      // Clear all user-related data
      await Future.wait([StorageUtils.clearUserData(), _clearUserCaches()]);

      // Reset state
      state = const UserState();

      developer.log('User session cleared successfully');
    } catch (e) {
      developer.log('Error clearing user session: $e', error: e);

      // Force reset state
      state = const UserState();
    }
  }

  /// Reset state for new user session
  void resetForNewUser() {
    developer.log('Resetting user provider for new user...');
    state = const UserState();
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  @override
  void dispose() {
    _authService.dispose();
    _kycService.dispose();
    super.dispose();
  }
}

/// Provider for UserNotifier
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});

/// Convenience providers for accessing specific parts of the user state
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(userProvider).user;
});

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(userProvider).isLoggedIn;
});

final isKycCompletedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.isKycCompleted ?? false;
});

final userLoadingProvider = Provider<bool>((ref) {
  return ref.watch(userProvider).isLoading;
});

final userErrorProvider = Provider<String?>((ref) {
  return ref.watch(userProvider).errorMessage;
});
