import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/models/onboarding_model.dart';

class OnboardingService {
  static const String _onboardingProgressKey = 'onboarding_progress';
  static const String _userPreferencesKey = 'user_preferences';
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';
  static const String _currentStepKey = 'current_onboarding_step';

  // Get onboarding progress for user
  Future<OnboardingProgress?> getOnboardingProgress(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = prefs.getString('${_onboardingProgressKey}_$userId');
      
      if (progressJson != null) {
        final progressMap = Map<String, dynamic>.from(
          // In a real app, you'd use proper JSON parsing
          {'userId': userId, 'completedSteps': [], 'createdAt': DateTime.now().toIso8601String(), 'updatedAt': DateTime.now().toIso8601String()}
        );
        return OnboardingProgress.fromJson(progressMap);
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting onboarding progress: $e');
      return null;
    }
  }

  // Create new onboarding progress
  Future<OnboardingProgress> createOnboardingProgress(String userId) async {
    try {
      final progress = OnboardingProgress(
        userId: userId,
        completedSteps: [],
        currentStepId: 'welcome',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _saveOnboardingProgress(progress);
      return progress;
    } catch (e) {
      debugPrint('Error creating onboarding progress: $e');
      rethrow;
    }
  }

  // Update onboarding progress
  Future<OnboardingProgress> updateOnboardingProgress(OnboardingProgress progress) async {
    try {
      final updatedProgress = progress.copyWith(
        updatedAt: DateTime.now(),
      );
      
      await _saveOnboardingProgress(updatedProgress);
      return updatedProgress;
    } catch (e) {
      debugPrint('Error updating onboarding progress: $e');
      rethrow;
    }
  }

  // Complete onboarding step
  Future<OnboardingProgress> completeStep(String userId, String stepId) async {
    try {
      var progress = await getOnboardingProgress(userId);
      progress ??= await createOnboardingProgress(userId);
      
      final completedSteps = List<String>.from(progress.completedSteps);
      if (!completedSteps.contains(stepId)) {
        completedSteps.add(stepId);
      }
      
      final updatedProgress = progress.copyWith(
        completedSteps: completedSteps,
        updatedAt: DateTime.now(),
      );
      
      return await updateOnboardingProgress(updatedProgress);
    } catch (e) {
      debugPrint('Error completing step: $e');
      rethrow;
    }
  }

  // Complete entire onboarding
  Future<OnboardingProgress> completeOnboarding(String userId) async {
    try {
      var progress = await getOnboardingProgress(userId);
      progress ??= await createOnboardingProgress(userId);
      
      final updatedProgress = progress.copyWith(
        isOnboardingComplete: true,
        completedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await updateOnboardingProgress(updatedProgress);
      
      // Update user preferences
      await setHasSeenOnboarding(userId, true);
      
      return updatedProgress;
    } catch (e) {
      debugPrint('Error completing onboarding: $e');
      rethrow;
    }
  }

  // Check if user has seen onboarding
  Future<bool> hasSeenOnboarding(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('${_hasSeenOnboardingKey}_$userId') ?? false;
    } catch (e) {
      debugPrint('Error checking has seen onboarding: $e');
      return false;
    }
  }

  // Set has seen onboarding
  Future<void> setHasSeenOnboarding(String userId, bool hasSeen) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('${_hasSeenOnboardingKey}_$userId', hasSeen);
    } catch (e) {
      debugPrint('Error setting has seen onboarding: $e');
    }
  }

  // Get user preferences
  Future<UserPreferences?> getUserPreferences(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final preferencesJson = prefs.getString('${_userPreferencesKey}_$userId');
      
      if (preferencesJson != null) {
        // In a real app, you'd use proper JSON parsing
        final preferencesMap = {
          'userId': userId,
          'hasSeenOnboarding': await hasSeenOnboarding(userId),
          'hasSeenTutorials': false,
          'showHints': true,
          'enableNotifications': true,
          'completedTutorials': <String>[],
          'customSettings': <String, dynamic>{},
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };
        return UserPreferences.fromJson(preferencesMap);
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting user preferences: $e');
      return null;
    }
  }

  // Update user preferences
  Future<UserPreferences> updateUserPreferences(UserPreferences preferences) async {
    try {
      final updatedPreferences = preferences.copyWith(
        updatedAt: DateTime.now(),
      );
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        '${_userPreferencesKey}_${preferences.userId}',
        updatedPreferences.toJson().toString(),
      );
      
      return updatedPreferences;
    } catch (e) {
      debugPrint('Error updating user preferences: $e');
      rethrow;
    }
  }

  // Get default onboarding steps
  List<OnboardingStep> getDefaultOnboardingSteps() {
    return [
      OnboardingStep(
        id: 'welcome',
        title: 'Welcome to SeedIt',
        description: 'Your journey to smart investing starts here. Let\'s get you set up!',
        imageAsset: 'assets/images/onboarding_welcome.png',
        type: OnboardingStepType.welcome,
        actions: [
          OnboardingAction(
            id: 'get_started',
            label: 'Get Started',
            type: OnboardingActionType.next,
            isPrimary: true,
          ),
        ],
        order: 0,
      ),
      OnboardingStep(
        id: 'profile_setup',
        title: 'Set Up Your Profile',
        description: 'Complete your profile to personalize your investment experience.',
        imageAsset: 'assets/images/onboarding_profile.png',
        type: OnboardingStepType.profileSetup,
        actions: [
          OnboardingAction(
            id: 'setup_profile',
            label: 'Set Up Profile',
            type: OnboardingActionType.navigate,
            route: '/profile/edit',
            isPrimary: true,
          ),
          OnboardingAction(
            id: 'skip_profile',
            label: 'Skip for Now',
            type: OnboardingActionType.skip,
          ),
        ],
        order: 1,
      ),
      OnboardingStep(
        id: 'security_setup',
        title: 'Secure Your Account',
        description: 'Enable biometric authentication and set up security preferences.',
        imageAsset: 'assets/images/onboarding_security.png',
        type: OnboardingStepType.securitySetup,
        actions: [
          OnboardingAction(
            id: 'setup_security',
            label: 'Set Up Security',
            type: OnboardingActionType.navigate,
            route: '/security',
            isPrimary: true,
          ),
          OnboardingAction(
            id: 'skip_security',
            label: 'Skip for Now',
            type: OnboardingActionType.skip,
          ),
        ],
        order: 2,
      ),
      OnboardingStep(
        id: 'kyc_introduction',
        title: 'Identity Verification',
        description: 'Complete KYC verification to unlock all investment features.',
        imageAsset: 'assets/images/onboarding_kyc.png',
        type: OnboardingStepType.kycIntroduction,
        actions: [
          OnboardingAction(
            id: 'start_kyc',
            label: 'Start Verification',
            type: OnboardingActionType.navigate,
            route: '/kyc',
            isPrimary: true,
          ),
          OnboardingAction(
            id: 'skip_kyc',
            label: 'Skip for Now',
            type: OnboardingActionType.skip,
          ),
        ],
        order: 3,
      ),
      OnboardingStep(
        id: 'features_overview',
        title: 'Explore Features',
        description: 'Discover all the powerful features SeedIt has to offer.',
        imageAsset: 'assets/images/onboarding_features.png',
        type: OnboardingStepType.featuresOverview,
        actions: [
          OnboardingAction(
            id: 'explore_features',
            label: 'Explore Features',
            type: OnboardingActionType.tutorial,
            isPrimary: true,
          ),
          OnboardingAction(
            id: 'skip_features',
            label: 'Skip Tutorial',
            type: OnboardingActionType.skip,
          ),
        ],
        order: 4,
      ),
      OnboardingStep(
        id: 'completion',
        title: 'You\'re All Set!',
        description: 'Welcome to SeedIt! You\'re ready to start your investment journey.',
        imageAsset: 'assets/images/onboarding_complete.png',
        type: OnboardingStepType.completion,
        actions: [
          OnboardingAction(
            id: 'start_investing',
            label: 'Start Investing',
            type: OnboardingActionType.complete,
            route: '/home',
            isPrimary: true,
          ),
        ],
        order: 5,
      ),
    ];
  }

  // Get tutorials
  List<OnboardingTutorial> getDefaultTutorials() {
    return [
      OnboardingTutorial(
        id: 'getting_started',
        title: 'Getting Started',
        description: 'Learn the basics of using SeedIt',
        category: TutorialCategory.gettingStarted,
        isRequired: true,
        steps: [
          TutorialStep(
            id: 'navigation',
            title: 'Navigation',
            description: 'Learn how to navigate through the app',
            type: TutorialStepType.highlight,
            order: 0,
          ),
          TutorialStep(
            id: 'dashboard',
            title: 'Dashboard',
            description: 'Understand your investment dashboard',
            type: TutorialStepType.overlay,
            order: 1,
          ),
        ],
      ),
      OnboardingTutorial(
        id: 'investing_basics',
        title: 'Investment Basics',
        description: 'Learn how to make your first investment',
        category: TutorialCategory.investing,
        steps: [
          TutorialStep(
            id: 'browse_investments',
            title: 'Browse Investments',
            description: 'Discover available investment opportunities',
            type: TutorialStepType.highlight,
            order: 0,
          ),
          TutorialStep(
            id: 'make_investment',
            title: 'Make Investment',
            description: 'Learn how to invest in opportunities',
            type: TutorialStepType.tooltip,
            order: 1,
          ),
        ],
      ),
    ];
  }

  // Private helper methods
  Future<void> _saveOnboardingProgress(OnboardingProgress progress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        '${_onboardingProgressKey}_${progress.userId}',
        progress.toJson().toString(),
      );
    } catch (e) {
      debugPrint('Error saving onboarding progress: $e');
      rethrow;
    }
  }
}
