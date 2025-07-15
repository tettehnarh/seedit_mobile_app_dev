import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/onboarding_provider.dart';
import '../../../shared/providers/auth_provider.dart';

class OnboardingCheck extends ConsumerWidget {
  final Widget child;
  final bool forceOnboarding;

  const OnboardingCheck({
    super.key,
    required this.child,
    this.forceOnboarding = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final hasSeenOnboarding = ref.watch(hasSeenOnboardingProvider);

    // If no user is logged in, show the child
    if (currentUser == null) {
      return child;
    }

    // Check onboarding status
    return hasSeenOnboarding.when(
      data: (hasSeen) {
        // If user hasn't seen onboarding or we're forcing it, redirect
        if (!hasSeen || forceOnboarding) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/onboarding');
          });
          return const OnboardingLoadingScreen();
        }
        
        // User has seen onboarding, show the child
        return child;
      },
      loading: () => const OnboardingLoadingScreen(),
      error: (error, stack) {
        // On error, assume user needs onboarding
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/onboarding');
        });
        return const OnboardingLoadingScreen();
      },
    );
  }
}

class OnboardingLoadingScreen extends StatelessWidget {
  const OnboardingLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo or loading animation
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.savings,
                size: 60,
                color: Theme.of(context).primaryColor,
              ),
            ),
            
            const SizedBox(height: 32),
            
            Text(
              'SeedIt',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            
            const SizedBox(height: 16),
            
            const CircularProgressIndicator(),
            
            const SizedBox(height: 16),
            
            Text(
              'Preparing your experience...',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPrompt extends ConsumerWidget {
  final VoidCallback? onStart;
  final VoidCallback? onSkip;

  const OnboardingPrompt({
    super.key,
    this.onStart,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.explore,
            size: 48,
            color: Colors.white,
          ),
          
          const SizedBox(height: 16),
          
          const Text(
            'Welcome to SeedIt!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Let us show you around and help you get started with smart investing.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onSkip ?? () {
                    final currentUser = ref.read(currentUserProvider);
                    if (currentUser != null) {
                      ref.read(onboardingStateProvider.notifier)
                          .completeOnboarding(currentUser.id);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                  ),
                  child: const Text('Skip'),
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: ElevatedButton(
                  onPressed: onStart ?? () {
                    context.push('/onboarding');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).primaryColor,
                  ),
                  child: const Text('Get Started'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OnboardingBanner extends ConsumerWidget {
  final bool showProgress;

  const OnboardingBanner({
    super.key,
    this.showProgress = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingProgress = ref.watch(onboardingProgressProvider);
    final completionPercentage = ref.watch(onboardingCompletionProvider);

    return onboardingProgress.when(
      data: (progress) {
        if (progress == null || progress.isOnboardingComplete) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Complete your setup',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.push('/onboarding');
                    },
                    child: const Text('Continue'),
                  ),
                ],
              ),
              
              if (showProgress) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: completionPercentage / 100,
                  backgroundColor: Colors.blue.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  '${completionPercentage.toInt()}% complete',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade600,
                  ),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class OnboardingFloatingButton extends ConsumerWidget {
  const OnboardingFloatingButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasSeenOnboarding = ref.watch(hasSeenOnboardingProvider);

    return hasSeenOnboarding.when(
      data: (hasSeen) {
        if (hasSeen) {
          return const SizedBox.shrink();
        }

        return FloatingActionButton.extended(
          onPressed: () {
            context.push('/onboarding');
          },
          icon: const Icon(Icons.explore),
          label: const Text('Get Started'),
          backgroundColor: Theme.of(context).primaryColor,
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
