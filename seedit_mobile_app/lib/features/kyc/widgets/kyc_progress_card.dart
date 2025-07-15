import 'package:flutter/material.dart';
import '../../../shared/widgets/custom_button.dart';

class KycProgressCard extends StatelessWidget {
  final double completionPercentage;
  final VoidCallback onContinue;
  final List<String>? missingSteps;

  const KycProgressCard({
    super.key,
    required this.completionPercentage,
    required this.onContinue,
    this.missingSteps,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isComplete = completionPercentage >= 100;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isComplete
              ? [Colors.green, Colors.green.shade700]
              : [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isComplete ? Colors.green : theme.primaryColor).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isComplete ? Icons.check_circle : Icons.assignment,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isComplete ? 'Application Complete!' : 'Complete Your KYC',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Text(
            isComplete
                ? 'Your KYC application is ready for submission!'
                : 'Complete all required steps to submit your verification.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${completionPercentage.toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: completionPercentage / 100,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 6,
                ),
              ),
            ],
          ),
          
          if (missingSteps != null && missingSteps!.isNotEmpty && !isComplete) ...[
            const SizedBox(height: 16),
            Text(
              'Remaining steps:',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...missingSteps!.take(3).map((step) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.radio_button_unchecked,
                    size: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      step,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
          
          const SizedBox(height: 16),
          
          CustomButton(
            text: isComplete ? 'Submit Application' : 'Continue',
            onPressed: onContinue,
            backgroundColor: Colors.white,
            textColor: isComplete ? Colors.green : theme.primaryColor,
            height: 40,
          ),
        ],
      ),
    );
  }
}

class KycStepProgress extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepTitles;
  final List<bool> stepCompleted;

  const KycStepProgress({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepTitles,
    required this.stepCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Progress indicators
        Row(
          children: List.generate(totalSteps, (index) {
            final isCompleted = stepCompleted[index];
            final isCurrent = index == currentStep;
            final isUpcoming = index > currentStep;
            
            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Colors.green
                            : isCurrent
                                ? theme.primaryColor
                                : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  if (index < totalSteps - 1) const SizedBox(width: 4),
                ],
              ),
            );
          }),
        ),
        
        const SizedBox(height: 12),
        
        // Step indicators
        Row(
          children: List.generate(totalSteps, (index) {
            final isCompleted = stepCompleted[index];
            final isCurrent = index == currentStep;
            
            return Expanded(
              child: Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.green
                          : isCurrent
                              ? theme.primaryColor
                              : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCompleted ? Icons.check : Icons.circle,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    stepTitles[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                      color: isCompleted
                          ? Colors.green
                          : isCurrent
                              ? theme.primaryColor
                              : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}

class KycProgressSummary extends StatelessWidget {
  final double completionPercentage;
  final int completedSteps;
  final int totalSteps;
  final bool canSubmit;

  const KycProgressSummary({
    super.key,
    required this.completionPercentage,
    required this.completedSteps,
    required this.totalSteps,
    required this.canSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: canSubmit ? Colors.green : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                canSubmit ? Icons.check_circle : Icons.info_outline,
                color: canSubmit ? Colors.green : theme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                canSubmit ? 'Ready to Submit' : 'Application Progress',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: canSubmit ? Colors.green : theme.primaryColor,
                ),
              ),
              const Spacer(),
              Text(
                '${completionPercentage.toInt()}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: canSubmit ? Colors.green : theme.primaryColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: completionPercentage / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                canSubmit ? Colors.green : theme.primaryColor,
              ),
              minHeight: 6,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            '$completedSteps of $totalSteps steps completed',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          
          if (canSubmit) ...[
            const SizedBox(height: 8),
            Text(
              'All required information has been provided. You can now submit your application for review.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class KycProgressIndicator extends StatelessWidget {
  final double progress;
  final Color? color;
  final double size;
  final double strokeWidth;

  const KycProgressIndicator({
    super.key,
    required this.progress,
    this.color,
    this.size = 60,
    this.strokeWidth = 6,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.primaryColor;
    
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          CircularProgressIndicator(
            value: progress / 100,
            strokeWidth: strokeWidth,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
          ),
          Center(
            child: Text(
              '${progress.toInt()}%',
              style: TextStyle(
                fontSize: size * 0.2,
                fontWeight: FontWeight.bold,
                color: effectiveColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
