import 'package:flutter/material.dart';
import '../../../shared/models/onboarding_model.dart';
import '../../../shared/widgets/custom_button.dart';

class OnboardingStepWidget extends StatelessWidget {
  final OnboardingStep step;
  final Function(OnboardingAction) onActionPressed;

  const OnboardingStepWidget({
    super.key,
    required this.step,
    required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Step illustration
          _buildStepIllustration(context),
          
          const SizedBox(height: 48),
          
          // Step title
          Text(
            step.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Step description
          Text(
            step.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 48),
          
          // Step-specific content
          _buildStepContent(context),
          
          const Spacer(),
          
          // Action buttons
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildStepIllustration(BuildContext context) {
    // Use different illustrations based on step type
    IconData iconData;
    Color iconColor;
    
    switch (step.type) {
      case OnboardingStepType.welcome:
        iconData = Icons.waving_hand;
        iconColor = Colors.orange;
        break;
      case OnboardingStepType.profileSetup:
        iconData = Icons.person_add;
        iconColor = Colors.blue;
        break;
      case OnboardingStepType.securitySetup:
        iconData = Icons.security;
        iconColor = Colors.green;
        break;
      case OnboardingStepType.kycIntroduction:
        iconData = Icons.verified_user;
        iconColor = Colors.purple;
        break;
      case OnboardingStepType.investmentPreferences:
        iconData = Icons.trending_up;
        iconColor = Colors.teal;
        break;
      case OnboardingStepType.featuresOverview:
        iconData = Icons.explore;
        iconColor = Colors.indigo;
        break;
      case OnboardingStepType.tutorial:
        iconData = Icons.school;
        iconColor = Colors.amber;
        break;
      case OnboardingStepType.completion:
        iconData = Icons.celebration;
        iconColor = Colors.green;
        break;
    }

    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        size: 100,
        color: iconColor,
      ),
    );
  }

  Widget _buildStepContent(BuildContext context) {
    switch (step.type) {
      case OnboardingStepType.welcome:
        return _buildWelcomeContent(context);
      case OnboardingStepType.profileSetup:
        return _buildProfileSetupContent(context);
      case OnboardingStepType.securitySetup:
        return _buildSecuritySetupContent(context);
      case OnboardingStepType.kycIntroduction:
        return _buildKycIntroductionContent(context);
      case OnboardingStepType.featuresOverview:
        return _buildFeaturesOverviewContent(context);
      case OnboardingStepType.completion:
        return _buildCompletionContent(context);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildWelcomeContent(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildFeatureHighlight(
              Icons.security,
              'Secure',
              'Bank-level security',
              Colors.green,
            ),
            _buildFeatureHighlight(
              Icons.trending_up,
              'Smart',
              'AI-powered insights',
              Colors.blue,
            ),
            _buildFeatureHighlight(
              Icons.group,
              'Social',
              'Group investing',
              Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileSetupContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.blue.shade600,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            'Complete your profile to get personalized investment recommendations and unlock all features.',
            style: TextStyle(
              color: Colors.blue.shade700,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySetupContent(BuildContext context) {
    return Column(
      children: [
        _buildSecurityFeature(
          Icons.fingerprint,
          'Biometric Authentication',
          'Use Face ID or Touch ID for quick access',
        ),
        const SizedBox(height: 12),
        _buildSecurityFeature(
          Icons.timer,
          'Auto-lock',
          'Automatically lock the app when inactive',
        ),
        const SizedBox(height: 12),
        _buildSecurityFeature(
          Icons.lock,
          'Encryption',
          'All data is encrypted and secure',
        ),
      ],
    );
  }

  Widget _buildKycIntroductionContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        children: [
          Text(
            'Why KYC?',
            style: TextStyle(
              color: Colors.purple.shade800,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '• Comply with financial regulations\n• Protect against fraud\n• Unlock higher investment limits\n• Access premium features',
            style: TextStyle(
              color: Colors.purple.shade700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesOverviewContent(BuildContext context) {
    return Column(
      children: [
        _buildFeatureItem(
          Icons.dashboard,
          'Investment Dashboard',
          'Track your portfolio performance',
        ),
        const SizedBox(height: 12),
        _buildFeatureItem(
          Icons.group,
          'Group Investments',
          'Invest with friends and family',
        ),
        const SizedBox(height: 12),
        _buildFeatureItem(
          Icons.analytics,
          'Smart Analytics',
          'AI-powered investment insights',
        ),
      ],
    );
  }

  Widget _buildCompletionContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.rocket_launch,
            color: Colors.green.shade600,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re ready to start investing!',
            style: TextStyle(
              color: Colors.green.shade800,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: step.actions.map((action) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CustomButton(
            text: action.label,
            onPressed: () => onActionPressed(action),
            isOutlined: !action.isPrimary,
            backgroundColor: action.isPrimary ? null : Colors.transparent,
            textColor: action.isPrimary ? null : Theme.of(context).primaryColor,
            icon: _getActionIcon(action.type),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeatureHighlight(
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
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

  Widget _buildSecurityFeature(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.green,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.indigo.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.indigo,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData? _getActionIcon(OnboardingActionType type) {
    switch (type) {
      case OnboardingActionType.next:
        return Icons.arrow_forward;
      case OnboardingActionType.skip:
        return Icons.skip_next;
      case OnboardingActionType.navigate:
        return Icons.open_in_new;
      case OnboardingActionType.complete:
        return Icons.check;
      case OnboardingActionType.tutorial:
        return Icons.play_circle;
    }
  }
}
