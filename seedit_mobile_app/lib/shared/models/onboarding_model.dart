import 'package:json_annotation/json_annotation.dart';

part 'onboarding_model.g.dart';

@JsonSerializable()
class OnboardingStep {
  final String id;
  final String title;
  final String description;
  final String? imageAsset;
  final String? lottieAsset;
  final OnboardingStepType type;
  final Map<String, dynamic>? data;
  final List<OnboardingAction> actions;
  final bool isRequired;
  final bool isCompleted;
  final int order;

  OnboardingStep({
    required this.id,
    required this.title,
    required this.description,
    this.imageAsset,
    this.lottieAsset,
    required this.type,
    this.data,
    required this.actions,
    this.isRequired = true,
    this.isCompleted = false,
    required this.order,
  });

  factory OnboardingStep.fromJson(Map<String, dynamic> json) => _$OnboardingStepFromJson(json);
  Map<String, dynamic> toJson() => _$OnboardingStepToJson(this);

  OnboardingStep copyWith({
    String? id,
    String? title,
    String? description,
    String? imageAsset,
    String? lottieAsset,
    OnboardingStepType? type,
    Map<String, dynamic>? data,
    List<OnboardingAction>? actions,
    bool? isRequired,
    bool? isCompleted,
    int? order,
  }) {
    return OnboardingStep(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageAsset: imageAsset ?? this.imageAsset,
      lottieAsset: lottieAsset ?? this.lottieAsset,
      type: type ?? this.type,
      data: data ?? this.data,
      actions: actions ?? this.actions,
      isRequired: isRequired ?? this.isRequired,
      isCompleted: isCompleted ?? this.isCompleted,
      order: order ?? this.order,
    );
  }
}

@JsonSerializable()
class OnboardingAction {
  final String id;
  final String label;
  final OnboardingActionType type;
  final String? route;
  final Map<String, dynamic>? data;
  final bool isPrimary;

  OnboardingAction({
    required this.id,
    required this.label,
    required this.type,
    this.route,
    this.data,
    this.isPrimary = false,
  });

  factory OnboardingAction.fromJson(Map<String, dynamic> json) => _$OnboardingActionFromJson(json);
  Map<String, dynamic> toJson() => _$OnboardingActionToJson(this);
}

@JsonSerializable()
class OnboardingProgress {
  final String userId;
  final List<String> completedSteps;
  final String? currentStepId;
  final bool isOnboardingComplete;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  OnboardingProgress({
    required this.userId,
    required this.completedSteps,
    this.currentStepId,
    this.isOnboardingComplete = false,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OnboardingProgress.fromJson(Map<String, dynamic> json) => _$OnboardingProgressFromJson(json);
  Map<String, dynamic> toJson() => _$OnboardingProgressToJson(this);

  OnboardingProgress copyWith({
    String? userId,
    List<String>? completedSteps,
    String? currentStepId,
    bool? isOnboardingComplete,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OnboardingProgress(
      userId: userId ?? this.userId,
      completedSteps: completedSteps ?? this.completedSteps,
      currentStepId: currentStepId ?? this.currentStepId,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double get completionPercentage {
    if (completedSteps.isEmpty) return 0.0;
    // Assuming total steps based on OnboardingStepType enum
    const totalSteps = 8; // Welcome, Profile, Security, KYC, Investment, Features, Tutorial, Complete
    return (completedSteps.length / totalSteps) * 100;
  }

  bool isStepCompleted(String stepId) {
    return completedSteps.contains(stepId);
  }
}

@JsonSerializable()
class OnboardingTutorial {
  final String id;
  final String title;
  final String description;
  final List<TutorialStep> steps;
  final TutorialCategory category;
  final bool isRequired;
  final bool isCompleted;

  OnboardingTutorial({
    required this.id,
    required this.title,
    required this.description,
    required this.steps,
    required this.category,
    this.isRequired = false,
    this.isCompleted = false,
  });

  factory OnboardingTutorial.fromJson(Map<String, dynamic> json) => _$OnboardingTutorialFromJson(json);
  Map<String, dynamic> toJson() => _$OnboardingTutorialToJson(this);
}

@JsonSerializable()
class TutorialStep {
  final String id;
  final String title;
  final String description;
  final String? targetWidget;
  final TutorialStepType type;
  final Map<String, dynamic>? data;
  final int order;

  TutorialStep({
    required this.id,
    required this.title,
    required this.description,
    this.targetWidget,
    required this.type,
    this.data,
    required this.order,
  });

  factory TutorialStep.fromJson(Map<String, dynamic> json) => _$TutorialStepFromJson(json);
  Map<String, dynamic> toJson() => _$TutorialStepToJson(this);
}

@JsonSerializable()
class UserPreferences {
  final String userId;
  final bool hasSeenOnboarding;
  final bool hasSeenTutorials;
  final bool showHints;
  final bool enableNotifications;
  final List<String> completedTutorials;
  final Map<String, dynamic> customSettings;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserPreferences({
    required this.userId,
    this.hasSeenOnboarding = false,
    this.hasSeenTutorials = false,
    this.showHints = true,
    this.enableNotifications = true,
    this.completedTutorials = const [],
    this.customSettings = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) => _$UserPreferencesFromJson(json);
  Map<String, dynamic> toJson() => _$UserPreferencesToJson(this);

  UserPreferences copyWith({
    String? userId,
    bool? hasSeenOnboarding,
    bool? hasSeenTutorials,
    bool? showHints,
    bool? enableNotifications,
    List<String>? completedTutorials,
    Map<String, dynamic>? customSettings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserPreferences(
      userId: userId ?? this.userId,
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      hasSeenTutorials: hasSeenTutorials ?? this.hasSeenTutorials,
      showHints: showHints ?? this.showHints,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      completedTutorials: completedTutorials ?? this.completedTutorials,
      customSettings: customSettings ?? this.customSettings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum OnboardingStepType {
  @JsonValue('WELCOME')
  welcome,
  @JsonValue('PROFILE_SETUP')
  profileSetup,
  @JsonValue('SECURITY_SETUP')
  securitySetup,
  @JsonValue('KYC_INTRODUCTION')
  kycIntroduction,
  @JsonValue('INVESTMENT_PREFERENCES')
  investmentPreferences,
  @JsonValue('FEATURES_OVERVIEW')
  featuresOverview,
  @JsonValue('TUTORIAL')
  tutorial,
  @JsonValue('COMPLETION')
  completion,
}

enum OnboardingActionType {
  @JsonValue('NEXT')
  next,
  @JsonValue('SKIP')
  skip,
  @JsonValue('NAVIGATE')
  navigate,
  @JsonValue('COMPLETE')
  complete,
  @JsonValue('TUTORIAL')
  tutorial,
}

enum TutorialCategory {
  @JsonValue('GETTING_STARTED')
  gettingStarted,
  @JsonValue('INVESTING')
  investing,
  @JsonValue('SECURITY')
  security,
  @JsonValue('PROFILE')
  profile,
  @JsonValue('FEATURES')
  features,
}

enum TutorialStepType {
  @JsonValue('HIGHLIGHT')
  highlight,
  @JsonValue('TOOLTIP')
  tooltip,
  @JsonValue('OVERLAY')
  overlay,
  @JsonValue('MODAL')
  modal,
  @JsonValue('ANIMATION')
  animation,
}
