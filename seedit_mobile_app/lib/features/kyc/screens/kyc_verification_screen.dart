import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/kyc_provider.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/models/kyc_model.dart';
import '../../../shared/widgets/custom_button.dart';
import '../widgets/kyc_status_card.dart';
import '../widgets/kyc_progress_card.dart';
import '../widgets/kyc_steps_overview.dart';

class KycVerificationScreen extends ConsumerStatefulWidget {
  const KycVerificationScreen({super.key});

  @override
  ConsumerState<KycVerificationScreen> createState() => _KycVerificationScreenState();
}

class _KycVerificationScreenState extends ConsumerState<KycVerificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadKycApplication();
    });
  }

  void _loadKycApplication() {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null) {
      ref.read(kycStateProvider.notifier).loadKycApplication(currentUser.id);
    }
  }

  Future<void> _startKycProcess() async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null) {
      try {
        await ref.read(kycStateProvider.notifier).createKycApplication(
          currentUser.id,
          KycLevel.tier1,
        );
        
        if (mounted) {
          context.push('/kyc/personal-info');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final kycApplication = ref.watch(currentKycApplicationProvider);
    final isLoading = ref.watch(kycLoadingProvider);
    final completionPercentage = ref.watch(kycCompletionProvider);
    final kycStatus = ref.watch(kycStatusProvider);

    if (isLoading && kycApplication == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC Verification'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(kycStateProvider.notifier).refreshKycApplication();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header section
              Container(
                padding: const EdgeInsets.all(24),
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
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.verified_user,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Identity Verification',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Complete your KYC verification to unlock all features and start investing',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              if (kycApplication == null) ...[
                // No KYC application - show start process
                _buildStartKycSection(),
              ] else ...[
                // Existing KYC application
                KycStatusCard(
                  status: kycStatus!,
                  rejectionReason: kycApplication.rejectionReason,
                ),
                
                const SizedBox(height: 16),
                
                if (kycStatus == KycStatus.draft || kycStatus == KycStatus.rejected) ...[
                  KycProgressCard(
                    completionPercentage: completionPercentage,
                    onContinue: () {
                      _navigateToNextStep(kycApplication);
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  KycStepsOverview(
                    application: kycApplication,
                    onStepTap: (step) {
                      _navigateToStep(step);
                    },
                  ),
                ] else if (kycStatus == KycStatus.submitted || kycStatus == KycStatus.underReview) ...[
                  _buildUnderReviewSection(),
                ] else if (kycStatus == KycStatus.approved) ...[
                  _buildApprovedSection(),
                ],
              ],
              
              const SizedBox(height: 32),
              
              // Information section
              _buildInformationSection(),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartKycSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            children: [
              Icon(
                Icons.assignment,
                size: 48,
                color: Colors.blue.shade600,
              ),
              const SizedBox(height: 16),
              Text(
                'Start KYC Verification',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Begin your identity verification process to access all SeedIt features',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Start Verification',
                onPressed: _startKycProcess,
                backgroundColor: Colors.blue.shade600,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUnderReviewSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.hourglass_empty,
            size: 48,
            color: Colors.orange.shade600,
          ),
          const SizedBox(height: 16),
          Text(
            'Under Review',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your KYC application is being reviewed. We\'ll notify you once the review is complete.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.orange.shade700,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Review typically takes 1-3 business days',
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovedSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle,
            size: 48,
            color: Colors.green.shade600,
          ),
          const SizedBox(height: 16),
          Text(
            'Verification Complete',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your identity has been successfully verified. You can now access all SeedIt features.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Start Investing',
            onPressed: () {
              context.go('/home');
            },
            backgroundColor: Colors.green.shade600,
          ),
        ],
      ),
    );
  }

  Widget _buildInformationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Why do we need KYC?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              Icons.security,
              'Security',
              'Protect your account and prevent fraud',
            ),
            _buildInfoItem(
              Icons.gavel,
              'Compliance',
              'Meet regulatory requirements for financial services',
            ),
            _buildInfoItem(
              Icons.verified,
              'Trust',
              'Build trust and ensure a safe investment environment',
            ),
            const SizedBox(height: 16),
            Text(
              'Your information is encrypted and securely stored.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: Theme.of(context).primaryColor,
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
      ),
    );
  }

  void _navigateToNextStep(KycApplication application) {
    // Determine next step based on completion
    if (!application.personalInfo.isComplete) {
      context.push('/kyc/personal-info');
    } else if (!application.identityDocuments.isComplete) {
      context.push('/kyc/identity-documents');
    } else if (application.addressVerification?.isComplete != true) {
      context.push('/kyc/address-verification');
    } else if (application.financialInfo?.isComplete != true) {
      context.push('/kyc/financial-info');
    } else if (application.nextOfKin?.isComplete != true) {
      context.push('/kyc/next-of-kin');
    } else {
      context.push('/kyc/documents');
    }
  }

  void _navigateToStep(int step) {
    switch (step) {
      case 0:
        context.push('/kyc/personal-info');
        break;
      case 1:
        context.push('/kyc/identity-documents');
        break;
      case 2:
        context.push('/kyc/address-verification');
        break;
      case 3:
        context.push('/kyc/financial-info');
        break;
      case 4:
        context.push('/kyc/next-of-kin');
        break;
      case 5:
        context.push('/kyc/documents');
        break;
    }
  }
}
