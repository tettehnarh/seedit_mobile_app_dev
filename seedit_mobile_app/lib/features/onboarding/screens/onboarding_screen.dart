import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/onboarding_provider.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/models/onboarding_model.dart';
import '../../../shared/widgets/custom_button.dart';
import '../widgets/onboarding_step_widget.dart';
import '../widgets/onboarding_progress_indicator.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeOnboarding();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _initializeOnboarding() {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null) {
      ref.read(onboardingStateProvider.notifier).initializeOnboarding(currentUser.id);
    }
  }

  Future<void> _handleStepAction(OnboardingAction action) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    final onboardingNotifier = ref.read(onboardingStateProvider.notifier);

    switch (action.type) {
      case OnboardingActionType.next:
        await onboardingNotifier.completeCurrentStep(currentUser.id);
        _moveToNextStep();
        break;
      case OnboardingActionType.skip:
        await onboardingNotifier.skipCurrentStep(currentUser.id);
        _moveToNextStep();
        break;
      case OnboardingActionType.navigate:
        if (action.route != null) {
          await onboardingNotifier.completeCurrentStep(currentUser.id);
          if (mounted) {
            context.push(action.route!);
          }
        }
        break;
      case OnboardingActionType.complete:
        await onboardingNotifier.completeOnboarding(currentUser.id);
        if (mounted) {
          context.go(action.route ?? '/home');
        }
        break;
      case OnboardingActionType.tutorial:
        onboardingNotifier.showTutorial();
        break;
    }
  }

  void _moveToNextStep() {
    final onboardingState = ref.read(onboardingStateProvider);
    if (onboardingState.isOnboardingComplete) {
      context.go('/home');
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _moveToPreviousStep() {
    if (_pageController.page! > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingStateProvider);
    final steps = ref.watch(onboardingStepsProvider);

    if (onboardingState.isLoading && steps.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with progress and skip button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Back button (only show after first step)
                  if (onboardingState.currentStepIndex > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _moveToPreviousStep,
                    )
                  else
                    const SizedBox(width: 48),
                  
                  // Progress indicator
                  Expanded(
                    child: OnboardingProgressIndicator(
                      currentStep: onboardingState.currentStepIndex,
                      totalSteps: steps.length,
                    ),
                  ),
                  
                  // Skip button (only show if not on last step)
                  if (onboardingState.currentStepIndex < steps.length - 1)
                    TextButton(
                      onPressed: () async {
                        final currentUser = ref.read(currentUserProvider);
                        if (currentUser != null) {
                          await ref.read(onboardingStateProvider.notifier)
                              .skipCurrentStep(currentUser.id);
                          _moveToNextStep();
                        }
                      },
                      child: const Text('Skip'),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),
            
            // Onboarding steps
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: steps.length,
                onPageChanged: (index) {
                  ref.read(onboardingStateProvider.notifier).goToStep(index);
                },
                itemBuilder: (context, index) {
                  final step = steps[index];
                  return OnboardingStepWidget(
                    step: step,
                    onActionPressed: _handleStepAction,
                  );
                },
              ),
            ),
            
            // Error handling
            if (onboardingState.error != null)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        onboardingState.error!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        ref.read(onboardingStateProvider.notifier).clearError();
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class OnboardingWelcomeScreen extends ConsumerWidget {
  const OnboardingWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo or illustration
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.savings,
                  size: 100,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              
              const SizedBox(height: 48),
              
              Text(
                'Welcome to SeedIt',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              Text(
                'Your journey to smart investing starts here. Let\'s get you set up with everything you need to grow your wealth.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              CustomButton(
                text: 'Get Started',
                onPressed: () {
                  context.push('/onboarding');
                },
                icon: Icons.arrow_forward,
              ),
              
              const SizedBox(height: 16),
              
              TextButton(
                onPressed: () {
                  context.go('/home');
                },
                child: const Text('Skip Onboarding'),
              ),
              
              const SizedBox(height: 32),
              
              // Features preview
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFeaturePreview(
                    Icons.security,
                    'Secure',
                    'Bank-level security',
                  ),
                  _buildFeaturePreview(
                    Icons.trending_up,
                    'Smart',
                    'AI-powered insights',
                  ),
                  _buildFeaturePreview(
                    Icons.group,
                    'Social',
                    'Group investing',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturePreview(IconData icon, String title, String description) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.blue,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        Text(
          description,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class OnboardingCompletionScreen extends ConsumerWidget {
  const OnboardingCompletionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success animation or illustration
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 100,
                  color: Colors.green,
                ),
              ),
              
              const SizedBox(height: 48),
              
              Text(
                'You\'re All Set!',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              Text(
                'Welcome to SeedIt! You\'re ready to start your investment journey. Explore opportunities, track your portfolio, and grow your wealth.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              CustomButton(
                text: 'Start Investing',
                onPressed: () {
                  context.go('/home');
                },
                backgroundColor: Colors.green,
                icon: Icons.rocket_launch,
              ),
              
              const SizedBox(height: 16),
              
              CustomButton(
                text: 'Take a Tour',
                onPressed: () {
                  ref.read(onboardingStateProvider.notifier).showTutorial();
                  context.go('/home');
                },
                isOutlined: true,
                icon: Icons.tour,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
