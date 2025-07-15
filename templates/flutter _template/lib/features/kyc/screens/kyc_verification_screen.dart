import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_theme.dart';
import '../models/kyc_models.dart';
import '../providers/kyc_provider.dart';
import '../widgets/kyc_status_card.dart';
import '../../auth/providers/user_provider.dart';

// Import standardized dialogs
import '../../../shared/widgets/dialogs/dialogs.dart';

// Step Status Enum
enum StepStatus { completed, current, pending, locked }

class KycVerificationScreen extends ConsumerStatefulWidget {
  const KycVerificationScreen({super.key});

  @override
  ConsumerState<KycVerificationScreen> createState() =>
      _KycVerificationScreenState();
}

class _KycVerificationScreenState extends ConsumerState<KycVerificationScreen> {
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    // Force refresh KYC status from backend when screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasInitialized) {
        _hasInitialized = true;
        ref.read(kycProvider.notifier).forceRefreshKycStatus();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only refresh if we haven't initialized yet (prevents duplicate calls)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasInitialized) {
        _hasInitialized = true;
        ref.read(kycProvider.notifier).forceRefreshKycStatus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final kycStatus = ref.watch(kycStatusProvider);
    final isLoading = ref.watch(kycLoadingProvider);
    final currentUser = ref.watch(currentUserProvider);

    // Use backend status from user provider as authoritative source
    final backendKycStatus =
        currentUser?.kycStatus.toLowerCase() ?? 'not_started';

    // Create a consistent KYC status that prioritizes backend status
    final consistentKycStatus =
        kycStatus?.copyWith(status: backendKycStatus) ??
        KycStatus(
          id: 'temp',
          status: backendKycStatus,
          personalInfo: null,
          nextOfKin: null,
          financialInfo: null,
          idInformation: null,
          documents: [],
          submittedAt: null,
          lastUpdated: DateTime.now(),
        );

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'KYC Verification',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.bug_report,
              color: AppTheme.primaryColor,
              size: 24,
            ),
            onPressed: () {
              _showDebugDialog(context, ref);
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.help_outline,
              color: AppTheme.primaryColor,
              size: 24,
            ),
            onPressed: () {
              _showHelpDialog(context);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(kycProvider.notifier).forceRefreshKycStatus();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // KYC Status Card
              KycStatusCard(
                kycStatus: consistentKycStatus,
                isLoading: isLoading,
              ),
              const SizedBox(height: 20),

              // Interactive KYC Steps
              _buildInteractiveStepsCard(
                context,
                ref,
                consistentKycStatus,
                isLoading,
              ),
              const SizedBox(height: 20),

              // Information Card
              _buildInformationCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveStepsCard(
    BuildContext context,
    WidgetRef ref,
    KycStatus? kycStatus,
    bool isLoading,
  ) {
    if (isLoading) {
      return _buildLoadingStepsCard();
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
          Row(
            children: [
              const Icon(
                Icons.checklist,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Verification Steps',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
              const Spacer(),
              _buildProgressIndicator(kycStatus),
            ],
          ),
          const SizedBox(height: 20),

          // Step 1: Personal Information
          _buildInteractiveStep(
            context,
            stepNumber: 1,
            title: 'Personal Information',
            description: 'Provide your basic personal details',
            status: _getStepStatus(1, kycStatus),
            kycStatus: kycStatus,
            onTap: () => _navigateToStep(context, 1, kycStatus),
          ),
          const SizedBox(height: 12),

          // Step 2: Next of Kin
          _buildInteractiveStep(
            context,
            stepNumber: 2,
            title: 'Next of Kin',
            description: 'Emergency contact information',
            status: _getStepStatus(2, kycStatus),
            kycStatus: kycStatus,
            onTap: () => _navigateToStep(context, 2, kycStatus),
          ),
          const SizedBox(height: 12),

          // Step 3: Financial Information
          _buildInteractiveStep(
            context,
            stepNumber: 3,
            title: 'Financial Information',
            description: 'Share your employment and income details',
            status: _getStepStatus(3, kycStatus),
            kycStatus: kycStatus,
            onTap: () => _navigateToStep(context, 3, kycStatus),
          ),
          const SizedBox(height: 12),

          // Step 4: ID Information & Documents
          _buildInteractiveStep(
            context,
            stepNumber: 4,
            title: 'ID Information',
            description: 'Provide ID details and upload documents',
            status: _getStepStatus(4, kycStatus),
            kycStatus: kycStatus,
            onTap: () => _navigateToStep(context, 4, kycStatus),
          ),
          const SizedBox(height: 20),

          // Submit Button (only show if all steps are completed)
          if (_canSubmit(kycStatus)) _buildSubmitButton(context, ref),
        ],
      ),
    );
  }

  Widget _buildInformationCard(BuildContext context) {
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
          Row(
            children: [
              Icon(Icons.info_outline, color: AppTheme.primaryColor, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Important Information',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildInfoItem(
            'Verification Time',
            'KYC verification typically takes 1-3 business days',
            Icons.schedule,
          ),
          const SizedBox(height: 12),

          _buildInfoItem(
            'Required Documents',
            'Valid government-issued ID and proof of address',
            Icons.document_scanner,
          ),
          const SizedBox(height: 12),

          _buildInfoItem(
            'Data Security',
            'Your information is encrypted and securely stored',
            Icons.security,
          ),
          const SizedBox(height: 12),

          _buildInfoItem(
            'Support',
            'Contact support if you need assistance',
            Icons.support_agent,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String description, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDebugDialog(BuildContext context, WidgetRef ref) {
    BaseDialog.show(
      context: context,
      dialog: BaseDialog(
        title: 'KYC Debug Info',
        titleIcon: Icons.bug_report,
        content: Consumer(
          builder: (context, ref, child) {
            final kycStatus = ref.watch(kycStatusProvider);
            final isLoading = ref.watch(kycLoadingProvider);
            final error = ref.watch(kycErrorProvider);

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDebugInfoItem('Loading', '$isLoading'),
                _buildDebugInfoItem('Error', error ?? 'None'),
                _buildDebugInfoItem('Status', kycStatus?.status ?? 'null'),
                _buildDebugInfoItem(
                  'Is Not Started',
                  '${kycStatus?.isNotStarted ?? 'null'}',
                ),
                _buildDebugInfoItem(
                  'Is Approved',
                  '${kycStatus?.isApproved ?? 'null'}',
                ),
                _buildDebugInfoItem(
                  'Is In Progress',
                  '${kycStatus?.isInProgress ?? 'null'}',
                ),
                _buildDebugInfoItem(
                  'Personal Info',
                  kycStatus?.personalInfo != null ? 'Present' : 'null',
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await ref
                          .read(kycProvider.notifier)
                          .forceRefreshKycStatus();
                    },
                    style: AppTheme.primaryButtonStyle,
                    child: const Text('Force Refresh KYC Status'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await ref
                          .read(kycProvider.notifier)
                          .forceRefreshFromBackendOnly();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Backend Only Refresh'),
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          DialogButton(
            text: 'Close',
            type: DialogButtonType.primary,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDebugInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    MessageDialog.showInfo(
      context: context,
      title: 'KYC Help',
      message: 'Know Your Customer (KYC) verification is required to:',
      actionItems: [
        'Comply with financial regulations',
        'Protect your account security',
        'Enable full investment features',
        'Process withdrawals and transfers',
      ],
      details: 'The process is secure and your data is protected.',
      buttonText: 'Got it',
    );
  }

  Widget _buildInteractiveStep(
    BuildContext context, {
    required int stepNumber,
    required String title,
    required String description,
    required StepStatus status,
    required KycStatus? kycStatus,
    required VoidCallback onTap,
  }) {
    final isReadOnly = kycStatus?.isReadOnly == true;
    final isClickable = status != StepStatus.locked && !isReadOnly;

    return GestureDetector(
      onTap: isClickable ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getStepBackgroundColor(status),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _getStepBorderColor(status), width: 1.5),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                // Step Number/Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isReadOnly
                        ? Colors.grey.shade400
                        : _getStepIconColor(status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: isReadOnly && kycStatus?.isPendingReview == true
                        ? const Icon(
                            Icons.hourglass_empty,
                            color: Colors.white,
                            size: 20,
                          )
                        : _getStepIcon(stepNumber, status),
                  ),
                ),
                const SizedBox(width: 16),

                // Step Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isReadOnly
                                    ? Colors.grey.shade600
                                    : _getStepTextColor(status),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isReadOnly && kycStatus?.isPendingReview == true)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Under Review',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange,
                                ),
                              ),
                            )
                          else
                            _getStatusBadge(status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isReadOnly && kycStatus?.isPendingReview == true
                            ? 'Information is being reviewed'
                            : description,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          color: isReadOnly
                              ? Colors.grey.shade500
                              : _getStepDescriptionColor(status),
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow Icon or Lock Icon
                if (isClickable)
                  Icon(
                    Icons.chevron_right,
                    color: _getStepArrowColor(status),
                    size: 20,
                  )
                else if (isReadOnly)
                  Icon(
                    Icons.lock_outline,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
              ],
            ),
            // Read-only overlay
            if (isReadOnly)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingStepsCard() {
    return Container(
      width: double.infinity,
      height: 400,
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

  Widget _buildProgressIndicator(KycStatus? kycStatus) {
    final completedSteps = _getCompletedStepsCount(kycStatus);
    final totalSteps = 4;
    final percentage = (completedSteps / totalSteps * 100).round();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$percentage%',
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  int _getCompletedStepsCount(KycStatus? kycStatus) {
    if (kycStatus == null) return 0;

    int count = 0;
    if (kycStatus.personalInfo != null) count++;
    if (kycStatus.nextOfKin != null) count++;
    if (kycStatus.financialInfo != null) count++;
    if (kycStatus.idInformation != null && kycStatus.documents.isNotEmpty) {
      count++;
    }

    return count;
  }

  StepStatus _getStepStatus(int stepNumber, KycStatus? kycStatus) {
    if (kycStatus == null) {
      return stepNumber == 1 ? StepStatus.current : StepStatus.locked;
    }

    switch (stepNumber) {
      case 1:
        return kycStatus.personalInfo != null
            ? StepStatus.completed
            : StepStatus.current;
      case 2:
        if (kycStatus.nextOfKin != null) return StepStatus.completed;
        if (kycStatus.personalInfo != null) return StepStatus.current;
        return StepStatus.locked;
      case 3:
        if (kycStatus.financialInfo != null) return StepStatus.completed;
        if (kycStatus.nextOfKin != null) return StepStatus.current;
        return StepStatus.locked;
      case 4:
        if (kycStatus.idInformation != null && kycStatus.documents.isNotEmpty) {
          return StepStatus.completed;
        }
        if (kycStatus.financialInfo != null) return StepStatus.current;
        return StepStatus.locked;
      default:
        return StepStatus.locked;
    }
  }

  void _navigateToStep(
    BuildContext context,
    int stepNumber,
    KycStatus? kycStatus,
  ) {
    final status = _getStepStatus(stepNumber, kycStatus);

    // Prevent navigation when KYC is under review or approved
    if (kycStatus?.isReadOnly == true) {
      String message;
      Color backgroundColor;

      if (kycStatus?.isPendingReview == true) {
        message =
            'Your KYC is under review. You cannot make changes at this time.';
        backgroundColor = Colors.orange;
      } else if (kycStatus?.isApproved == true) {
        message = 'Your KYC is already approved. No changes needed.';
        backgroundColor = Colors.green;
      } else {
        message = 'KYC is in read-only mode.';
        backgroundColor = Colors.grey;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(fontFamily: 'Montserrat'),
          ),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // Prevent navigation to locked steps
    if (status == StepStatus.locked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please complete the previous step first',
            style: const TextStyle(fontFamily: 'Montserrat'),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Navigate to the appropriate screen
    switch (stepNumber) {
      case 1:
        Navigator.pushNamed(context, '/kyc/personal-info');
        break;
      case 2:
        Navigator.pushNamed(context, '/kyc/next-of-kin');
        break;
      case 3:
        Navigator.pushNamed(context, '/kyc/financial-info');
        break;
      case 4:
        Navigator.pushNamed(context, '/kyc/documents');
        break;
    }
  }

  // Step styling helper methods
  Color _getStepBackgroundColor(StepStatus status) {
    switch (status) {
      case StepStatus.completed:
        return Colors.green.withValues(alpha: 0.1);
      case StepStatus.current:
        return AppTheme.primaryColor.withValues(alpha: 0.1);
      case StepStatus.pending:
        return Colors.grey.shade50;
      case StepStatus.locked:
        return Colors.grey.shade100;
    }
  }

  Color _getStepBorderColor(StepStatus status) {
    switch (status) {
      case StepStatus.completed:
        return Colors.green.withValues(alpha: 0.3);
      case StepStatus.current:
        return AppTheme.primaryColor.withValues(alpha: 0.3);
      case StepStatus.pending:
        return Colors.grey.shade300;
      case StepStatus.locked:
        return Colors.grey.shade300;
    }
  }

  Color _getStepIconColor(StepStatus status) {
    switch (status) {
      case StepStatus.completed:
        return Colors.green;
      case StepStatus.current:
        return AppTheme.primaryColor;
      case StepStatus.pending:
        return Colors.grey.shade400;
      case StepStatus.locked:
        return Colors.grey.shade400;
    }
  }

  Widget _getStepIcon(int stepNumber, StepStatus status) {
    if (status == StepStatus.completed) {
      return const Icon(Icons.check, color: Colors.white, size: 20);
    } else {
      return Text(
        stepNumber.toString(),
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      );
    }
  }

  Color _getStepTextColor(StepStatus status) {
    switch (status) {
      case StepStatus.completed:
        return Colors.green.shade700;
      case StepStatus.current:
        return AppTheme.primaryColor;
      case StepStatus.pending:
        return Colors.grey.shade600;
      case StepStatus.locked:
        return Colors.grey.shade500;
    }
  }

  Color _getStepDescriptionColor(StepStatus status) {
    switch (status) {
      case StepStatus.completed:
        return Colors.green.shade600;
      case StepStatus.current:
        return AppTheme.primaryColor.withValues(alpha: 0.8);
      case StepStatus.pending:
        return Colors.grey.shade500;
      case StepStatus.locked:
        return Colors.grey.shade400;
    }
  }

  Color _getStepArrowColor(StepStatus status) {
    switch (status) {
      case StepStatus.completed:
        return Colors.green.shade400;
      case StepStatus.current:
        return AppTheme.primaryColor.withValues(alpha: 0.7);
      case StepStatus.pending:
        return Colors.grey.shade400;
      case StepStatus.locked:
        return Colors.grey.shade400;
    }
  }

  Widget _getStatusBadge(StepStatus status) {
    String text;
    Color color;

    switch (status) {
      case StepStatus.completed:
        text = 'Completed';
        color = Colors.green;
        break;
      case StepStatus.current:
        text = 'Current';
        color = AppTheme.primaryColor;
        break;
      case StepStatus.pending:
        text = 'Pending';
        color = Colors.grey;
        break;
      case StepStatus.locked:
        text = 'Locked';
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  bool _canSubmit(KycStatus? kycStatus) {
    if (kycStatus == null) return false;

    return kycStatus.personalInfo != null &&
        kycStatus.nextOfKin != null &&
        kycStatus.financialInfo != null &&
        kycStatus.idInformation != null &&
        kycStatus.documents.isNotEmpty &&
        !kycStatus.isPendingReview &&
        !kycStatus.isApproved;
  }

  Widget _buildSubmitButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showSubmitConfirmation(context, ref),
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
        message: 'Please wait while we submit your information...',
        icon: Icons.upload,
      );

      try {
        // Submit KYC application
        final success = await ref
            .read(kycProvider.notifier)
            .submitCompleteKycApplication();

        // Dismiss loading dialog
        LoadingDialogManager.dismiss();

        if (context.mounted) {
          if (success) {
            await MessageDialog.showSuccess(
              context: context,
              title: 'KYC Submitted',
              message:
                  'Your KYC information has been submitted for review successfully!',
              details: 'You will be notified once the review is complete.',
            );
          } else {
            await MessageDialog.showError(
              context: context,
              title: 'Submission Failed',
              message: 'Failed to submit KYC. Please try again.',
              details:
                  'Check your internet connection and ensure all required fields are completed.',
            );
          }
        }
      } catch (error) {
        // Dismiss loading dialog
        LoadingDialogManager.dismiss();

        if (context.mounted) {
          await MessageDialog.showError(
            context: context,
            title: 'Submission Error',
            message: 'An error occurred while submitting your KYC information.',
            details:
                'Error: $error\n\nPlease check your internet connection and try again.',
          );
        }
      }
    }
  }
}
