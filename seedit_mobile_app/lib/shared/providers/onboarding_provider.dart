import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../models/onboarding_model.dart';
import '../../core/services/onboarding_service.dart';
import 'auth_provider.dart';

// Onboarding service provider
final onboardingServiceProvider = Provider<OnboardingService>((ref) => OnboardingService());

// Onboarding state provider
final onboardingStateProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier(
    ref.read(onboardingServiceProvider),
  );
});

// Current onboarding progress provider
final onboardingProgressProvider = FutureProvider<OnboardingProgress?>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return null;
  
  final onboardingService = ref.read(onboardingServiceProvider);
  return await onboardingService.getOnboardingProgress(currentUser.id);
});

// Has seen onboarding provider
final hasSeenOnboardingProvider = FutureProvider<bool>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return false;
  
  final onboardingService = ref.read(onboardingServiceProvider);
  return await onboardingService.hasSeenOnboarding(currentUser.id);
});

// User preferences provider
final userPreferencesProvider = FutureProvider<UserPreferences?>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return null;
  
  final onboardingService = ref.read(onboardingServiceProvider);
  return await onboardingService.getUserPreferences(currentUser.id);
});

// Onboarding steps provider
final onboardingStepsProvider = Provider<List<OnboardingStep>>((ref) {
  final onboardingService = ref.read(onboardingServiceProvider);
  return onboardingService.getDefaultOnboardingSteps();
});

// Tutorials provider
final tutorialsProvider = Provider<List<OnboardingTutorial>>((ref) {
  final onboardingService = ref.read(onboardingServiceProvider);
  return onboardingService.getDefaultTutorials();
});

// Current step provider
final currentOnboardingStepProvider = Provider<OnboardingStep?>((ref) {
  final steps = ref.watch(onboardingStepsProvider);
  final progress = ref.watch(onboardingProgressProvider);
  
  return progress.when(
    data: (progressData) {
      if (progressData?.currentStepId != null) {
        return steps.where((step) => step.id == progressData!.currentStepId).firstOrNull;
      }
      return steps.firstOrNull;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// Onboarding completion percentage provider
final onboardingCompletionProvider = Provider<double>((ref) {
  final progress = ref.watch(onboardingProgressProvider);
  
  return progress.when(
    data: (progressData) => progressData?.completionPercentage ?? 0.0,
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

class OnboardingState {
  final bool isLoading;
  final String? error;
  final int currentStepIndex;
  final bool isOnboardingComplete;
  final bool showTutorial;

  OnboardingState({
    this.isLoading = false,
    this.error,
    this.currentStepIndex = 0,
    this.isOnboardingComplete = false,
    this.showTutorial = false,
  });

  OnboardingState copyWith({
    bool? isLoading,
    String? error,
    int? currentStepIndex,
    bool? isOnboardingComplete,
    bool? showTutorial,
  }) {
    return OnboardingState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
      showTutorial: showTutorial ?? this.showTutorial,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final OnboardingService _onboardingService;

  OnboardingNotifier(this._onboardingService) : super(OnboardingState());

  // Initialize onboarding for user
  Future<void> initializeOnboarding(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      var progress = await _onboardingService.getOnboardingProgress(userId);
      progress ??= await _onboardingService.createOnboardingProgress(userId);
      
      final steps = _onboardingService.getDefaultOnboardingSteps();
      final currentStepIndex = _getCurrentStepIndex(steps, progress);
      
      state = state.copyWith(
        isLoading: false,
        currentStepIndex: currentStepIndex,
        isOnboardingComplete: progress.isOnboardingComplete,
      );
    } catch (e) {
      debugPrint('Initialize onboarding error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Complete current step and move to next
  Future<void> completeCurrentStep(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final steps = _onboardingService.getDefaultOnboardingSteps();
      if (state.currentStepIndex < steps.length) {
        final currentStep = steps[state.currentStepIndex];
        await _onboardingService.completeStep(userId, currentStep.id);
        
        final nextIndex = state.currentStepIndex + 1;
        if (nextIndex >= steps.length) {
          // Onboarding complete
          await _onboardingService.completeOnboarding(userId);
          state = state.copyWith(
            isLoading: false,
            isOnboardingComplete: true,
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            currentStepIndex: nextIndex,
          );
        }
      }
    } catch (e) {
      debugPrint('Complete step error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Skip current step
  Future<void> skipCurrentStep(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final steps = _onboardingService.getDefaultOnboardingSteps();
      final nextIndex = state.currentStepIndex + 1;
      
      if (nextIndex >= steps.length) {
        // Onboarding complete
        await _onboardingService.completeOnboarding(userId);
        state = state.copyWith(
          isLoading: false,
          isOnboardingComplete: true,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          currentStepIndex: nextIndex,
        );
      }
    } catch (e) {
      debugPrint('Skip step error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Go to specific step
  Future<void> goToStep(int stepIndex) async {
    if (stepIndex >= 0 && stepIndex < _onboardingService.getDefaultOnboardingSteps().length) {
      state = state.copyWith(currentStepIndex: stepIndex);
    }
  }

  // Complete entire onboarding
  Future<void> completeOnboarding(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _onboardingService.completeOnboarding(userId);
      state = state.copyWith(
        isLoading: false,
        isOnboardingComplete: true,
      );
    } catch (e) {
      debugPrint('Complete onboarding error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Show tutorial
  void showTutorial() {
    state = state.copyWith(showTutorial: true);
  }

  // Hide tutorial
  void hideTutorial() {
    state = state.copyWith(showTutorial: false);
  }

  // Update user preferences
  Future<void> updateUserPreferences(String userId, UserPreferences preferences) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _onboardingService.updateUserPreferences(preferences);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      debugPrint('Update preferences error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Check if user should see onboarding
  Future<bool> shouldShowOnboarding(String userId) async {
    try {
      final hasSeenOnboarding = await _onboardingService.hasSeenOnboarding(userId);
      return !hasSeenOnboarding;
    } catch (e) {
      debugPrint('Should show onboarding error: $e');
      return true; // Default to showing onboarding on error
    }
  }

  // Reset onboarding (for testing/demo purposes)
  Future<void> resetOnboarding(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _onboardingService.setHasSeenOnboarding(userId, false);
      await initializeOnboarding(userId);
    } catch (e) {
      debugPrint('Reset onboarding error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Private helper methods
  int _getCurrentStepIndex(List<OnboardingStep> steps, OnboardingProgress progress) {
    if (progress.currentStepId != null) {
      final index = steps.indexWhere((step) => step.id == progress.currentStepId);
      return index >= 0 ? index : 0;
    }
    return 0;
  }

  // Get next incomplete step
  OnboardingStep? getNextIncompleteStep(List<OnboardingStep> steps, OnboardingProgress progress) {
    for (final step in steps) {
      if (!progress.isStepCompleted(step.id)) {
        return step;
      }
    }
    return null;
  }

  // Check if step is completed
  bool isStepCompleted(String stepId, OnboardingProgress progress) {
    return progress.isStepCompleted(stepId);
  }

  // Get completed steps count
  int getCompletedStepsCount(OnboardingProgress progress) {
    return progress.completedSteps.length;
  }

  // Get total steps count
  int getTotalStepsCount() {
    return _onboardingService.getDefaultOnboardingSteps().length;
  }
}
