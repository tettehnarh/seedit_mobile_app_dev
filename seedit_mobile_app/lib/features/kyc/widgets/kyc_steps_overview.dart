import 'package:flutter/material.dart';
import '../../../shared/models/kyc_model.dart';

class KycStepsOverview extends StatelessWidget {
  final KycApplication application;
  final Function(int) onStepTap;

  const KycStepsOverview({
    super.key,
    required this.application,
    required this.onStepTap,
  });

  @override
  Widget build(BuildContext context) {
    final steps = _getSteps();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Verification Steps',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              final isLast = index == steps.length - 1;
              
              return Column(
                children: [
                  KycStepItem(
                    step: step,
                    onTap: () => onStepTap(index),
                  ),
                  if (!isLast) const SizedBox(height: 12),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  List<KycStepInfo> _getSteps() {
    return [
      KycStepInfo(
        title: 'Personal Information',
        description: 'Basic personal details and contact information',
        icon: Icons.person,
        isCompleted: application.personalInfo.isComplete,
        isRequired: true,
      ),
      KycStepInfo(
        title: 'Identity Documents',
        description: 'BVN, NIN, and other identification numbers',
        icon: Icons.badge,
        isCompleted: application.identityDocuments.isComplete,
        isRequired: true,
      ),
      KycStepInfo(
        title: 'Address Verification',
        description: 'Residential address and proof of address',
        icon: Icons.location_on,
        isCompleted: application.addressVerification?.isComplete == true,
        isRequired: true,
      ),
      KycStepInfo(
        title: 'Financial Information',
        description: 'Employment details and income information',
        icon: Icons.work,
        isCompleted: application.financialInfo?.isComplete == true,
        isRequired: true,
      ),
      KycStepInfo(
        title: 'Next of Kin',
        description: 'Emergency contact information',
        icon: Icons.family_restroom,
        isCompleted: application.nextOfKin?.isComplete == true,
        isRequired: true,
      ),
      KycStepInfo(
        title: 'Document Upload',
        description: 'Upload required verification documents',
        icon: Icons.upload_file,
        isCompleted: application.documents.isNotEmpty,
        isRequired: true,
      ),
    ];
  }
}

class KycStepItem extends StatelessWidget {
  final KycStepInfo step;
  final VoidCallback onTap;

  const KycStepItem({
    super.key,
    required this.step,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: step.isCompleted 
              ? Colors.green.shade50 
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: step.isCompleted 
                ? Colors.green.shade200 
                : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: step.isCompleted 
                    ? Colors.green 
                    : theme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                step.isCompleted ? Icons.check : step.icon,
                color: step.isCompleted 
                    ? Colors.white 
                    : theme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          step.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: step.isCompleted 
                                ? Colors.green.shade800 
                                : Colors.black,
                          ),
                        ),
                      ),
                      if (step.isRequired)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Required',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}

class KycStepInfo {
  final String title;
  final String description;
  final IconData icon;
  final bool isCompleted;
  final bool isRequired;

  KycStepInfo({
    required this.title,
    required this.description,
    required this.icon,
    required this.isCompleted,
    required this.isRequired,
  });
}

class KycStepsTimeline extends StatelessWidget {
  final List<KycStepInfo> steps;
  final int currentStep;
  final Function(int)? onStepTap;

  const KycStepsTimeline({
    super.key,
    required this.steps,
    required this.currentStep,
    this.onStepTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isLast = index == steps.length - 1;
        final isCurrent = index == currentStep;
        final isPast = index < currentStep;
        
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline indicator
              Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: step.isCompleted
                          ? Colors.green
                          : isCurrent
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      step.isCompleted
                          ? Icons.check
                          : isCurrent
                              ? step.icon
                              : step.icon,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        color: isPast || step.isCompleted
                            ? Colors.green
                            : Colors.grey.shade300,
                      ),
                    ),
                ],
              ),
              
              const SizedBox(width: 16),
              
              // Step content
              Expanded(
                child: GestureDetector(
                  onTap: onStepTap != null ? () => onStepTap!(index) : null,
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                step.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: step.isCompleted
                                      ? Colors.green.shade800
                                      : isCurrent
                                          ? Theme.of(context).primaryColor
                                          : Colors.black,
                                ),
                              ),
                            ),
                            if (step.isRequired)
                              Text(
                                'Required',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          step.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (step.isCompleted) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color: Colors.green.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Completed',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class KycStepCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isCompleted;
  final bool isActive;
  final VoidCallback? onTap;

  const KycStepCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.isCompleted,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: isActive ? 4 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isActive
                ? Border.all(color: theme.primaryColor, width: 2)
                : null,
          ),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green
                      : isActive
                          ? theme.primaryColor
                          : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCompleted ? Icons.check : icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isCompleted
                      ? Colors.green.shade800
                      : isActive
                          ? theme.primaryColor
                          : Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
