import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_theme.dart';
import '../models/kyc_models.dart';
import '../providers/kyc_provider.dart';

// Import standardized dialogs
import '../../../shared/widgets/dialogs/dialogs.dart';

class KycStepsCard extends ConsumerWidget {
  final KycStatus? kycStatus;
  final bool isLoading;

  const KycStepsCard({super.key, this.kycStatus, this.isLoading = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading) {
      return _buildLoadingCard();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Verification Steps',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),

          // Step 1: Personal Information
          _buildStepItem(
            context,
            stepNumber: 1,
            title: 'Personal Information',
            description: 'Provide your basic personal details',
            isCompleted: kycStatus?.personalInfo != null,
            isActive: kycStatus?.personalInfo == null,
            onTap: () {
              Navigator.pushNamed(context, '/kyc/personal-info');
            },
          ),
          const SizedBox(height: 12),

          // Step 2: Next of Kin
          _buildStepItem(
            context,
            stepNumber: 2,
            title: 'Next of Kin',
            description: 'Emergency contact information',
            isCompleted: kycStatus?.nextOfKin != null,
            isActive:
                kycStatus?.personalInfo != null && kycStatus?.nextOfKin == null,
            onTap: () {
              if (kycStatus?.personalInfo != null) {
                Navigator.pushNamed(context, '/kyc/next-of-kin');
              }
            },
          ),
          const SizedBox(height: 12),

          // Step 3: Financial Information
          _buildStepItem(
            context,
            stepNumber: 3,
            title: 'Financial Information',
            description: 'Share your employment and income details',
            isCompleted: kycStatus?.financialInfo != null,
            isActive:
                kycStatus?.nextOfKin != null &&
                kycStatus?.financialInfo == null,
            onTap: () {
              if (kycStatus?.nextOfKin != null) {
                Navigator.pushNamed(context, '/kyc/financial-info');
              }
            },
          ),
          const SizedBox(height: 12),

          // Step 4: ID Information (Consolidated with Documents)
          _buildStepItem(
            context,
            stepNumber: 4,
            title: 'ID Information',
            description: 'Provide ID details and upload documents',
            isCompleted:
                kycStatus?.idInformation != null &&
                kycStatus?.documents.isNotEmpty == true,
            isActive:
                kycStatus?.financialInfo != null &&
                (kycStatus?.idInformation == null ||
                    kycStatus?.documents.isEmpty == true),
            onTap: () {
              if (kycStatus?.financialInfo != null) {
                Navigator.pushNamed(context, '/kyc/documents');
              }
            },
          ),
          const SizedBox(height: 20),

          // Submit Button (only show if all steps are completed)
          if (_canSubmit()) _buildSubmitButton(context, ref),
        ],
      ),
    );
  }

  Widget _buildStepItem(
    BuildContext context, {
    required int stepNumber,
    required String title,
    required String description,
    required bool isCompleted,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isActive || isCompleted ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : isCompleted
              ? Colors.green.withValues(alpha: 0.1)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? AppTheme.primaryColor.withValues(alpha: 0.3)
                : isCompleted
                ? Colors.green.withValues(alpha: 0.3)
                : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            // Step Number/Check Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.green
                    : isActive
                    ? AppTheme.primaryColor
                    : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : Text(
                        stepNumber.toString(),
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),

            // Step Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isCompleted
                          ? Colors.green.shade700
                          : isActive
                          ? AppTheme.primaryColor
                          : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      color: isCompleted
                          ? Colors.green.shade600
                          : isActive
                          ? AppTheme.primaryColor.withValues(alpha: 0.8)
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow Icon
            if (isActive || isCompleted)
              Icon(
                Icons.chevron_right,
                color: isCompleted
                    ? Colors.green.shade400
                    : isActive
                    ? AppTheme.primaryColor.withValues(alpha: 0.7)
                    : Colors.grey.shade400,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _showSubmitConfirmation(context, ref);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Submit for Review',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  bool _canSubmit() {
    return kycStatus?.personalInfo != null &&
        kycStatus?.nextOfKin != null &&
        kycStatus?.financialInfo != null &&
        kycStatus?.idInformation != null &&
        kycStatus?.documents.isNotEmpty == true &&
        !kycStatus!.isPendingReview &&
        !kycStatus!.isApproved;
  }

  void _showSubmitConfirmation(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Submit for Review',
      message:
          'Are you sure you want to submit your KYC information for review?',
      confirmText: 'Submit',
      cancelText: 'Cancel',
      icon: Icons.send,
      details: 'You won\'t be able to make changes once submitted.',
    );

    if (confirmed && context.mounted) {
      // Show loading dialog
      LoadingDialogManager.show(
        context: context,
        title: 'Submitting KYC',
        message: 'Please wait while we submit your KYC information...',
      );

      try {
        // Submit KYC application
        final success = await ref
            .read(kycProvider.notifier)
            .submitCompleteKycApplication();

        // Hide loading dialog
        if (context.mounted) {
          LoadingDialogManager.dismiss();
        }

        if (success) {
          // Show success message
          if (context.mounted) {
            await MessageDialog.showSuccess(
              context: context,
              title: 'KYC Submitted',
              message:
                  'Your KYC information has been submitted for review successfully!',
              details: 'You will be notified once the review is complete.',
            );
          }
        } else {
          // Show error message
          if (context.mounted) {
            final errorMessage =
                ref.read(kycProvider).errorMessage ??
                'Failed to submit KYC application. Please try again.';
            await MessageDialog.showError(
              context: context,
              title: 'Submission Failed',
              message: errorMessage,
            );
          }
        }
      } catch (e) {
        // Hide loading dialog
        if (context.mounted) {
          LoadingDialogManager.dismiss();
        }

        // Show error message
        if (context.mounted) {
          await MessageDialog.showError(
            context: context,
            title: 'Submission Error',
            message:
                'An unexpected error occurred while submitting your KYC application. Please try again.',
          );
        }
      }
    }
  }

  Widget _buildLoadingCard() {
    return Container(
      width: double.infinity,
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      ),
    );
  }
}
