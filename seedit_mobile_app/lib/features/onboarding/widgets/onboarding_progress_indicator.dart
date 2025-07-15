import 'package:flutter/material.dart';

class OnboardingProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color? activeColor;
  final Color? inactiveColor;

  const OnboardingProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveActiveColor = activeColor ?? theme.primaryColor;
    final effectiveInactiveColor = inactiveColor ?? Colors.grey.shade300;

    return Row(
      children: List.generate(totalSteps, (index) {
        final isActive = index <= currentStep;
        
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(
              right: index < totalSteps - 1 ? 8 : 0,
            ),
            decoration: BoxDecoration(
              color: isActive ? effectiveActiveColor : effectiveInactiveColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

class OnboardingStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepTitles;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? completedColor;

  const OnboardingStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepTitles,
    this.activeColor,
    this.inactiveColor,
    this.completedColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveActiveColor = activeColor ?? theme.primaryColor;
    final effectiveInactiveColor = inactiveColor ?? Colors.grey.shade300;
    final effectiveCompletedColor = completedColor ?? Colors.green;

    return Column(
      children: [
        // Step indicators
        Row(
          children: List.generate(totalSteps, (index) {
            final isCompleted = index < currentStep;
            final isCurrent = index == currentStep;
            final isUpcoming = index > currentStep;

            Color stepColor;
            IconData stepIcon;

            if (isCompleted) {
              stepColor = effectiveCompletedColor;
              stepIcon = Icons.check;
            } else if (isCurrent) {
              stepColor = effectiveActiveColor;
              stepIcon = Icons.circle;
            } else {
              stepColor = effectiveInactiveColor;
              stepIcon = Icons.circle_outlined;
            }

            return Expanded(
              child: Row(
                children: [
                  // Step circle
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCompleted || isCurrent 
                          ? stepColor 
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: stepColor,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      stepIcon,
                      size: 16,
                      color: isCompleted || isCurrent 
                          ? Colors.white 
                          : stepColor,
                    ),
                  ),
                  
                  // Connecting line (except for last step)
                  if (index < totalSteps - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        color: isCompleted 
                            ? effectiveCompletedColor 
                            : effectiveInactiveColor,
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        
        const SizedBox(height: 8),
        
        // Step titles
        Row(
          children: List.generate(totalSteps, (index) {
            final isCompleted = index < currentStep;
            final isCurrent = index == currentStep;
            
            Color textColor;
            FontWeight fontWeight;

            if (isCompleted) {
              textColor = effectiveCompletedColor;
              fontWeight = FontWeight.w600;
            } else if (isCurrent) {
              textColor = effectiveActiveColor;
              fontWeight = FontWeight.w600;
            } else {
              textColor = Colors.grey.shade600;
              fontWeight = FontWeight.normal;
            }

            return Expanded(
              child: Text(
                index < stepTitles.length ? stepTitles[index] : 'Step ${index + 1}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: textColor,
                  fontWeight: fontWeight,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }),
        ),
      ],
    );
  }
}

class OnboardingProgressBar extends StatelessWidget {
  final double progress;
  final String? label;
  final Color? progressColor;
  final Color? backgroundColor;
  final double height;

  const OnboardingProgressBar({
    super.key,
    required this.progress,
    this.label,
    this.progressColor,
    this.backgroundColor,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveProgressColor = progressColor ?? theme.primaryColor;
    final effectiveBackgroundColor = backgroundColor ?? Colors.grey.shade200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: effectiveProgressColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: effectiveBackgroundColor,
            valueColor: AlwaysStoppedAnimation<Color>(effectiveProgressColor),
            minHeight: height,
          ),
        ),
      ],
    );
  }
}

class OnboardingCircularProgress extends StatelessWidget {
  final double progress;
  final String? centerText;
  final double size;
  final double strokeWidth;
  final Color? progressColor;
  final Color? backgroundColor;

  const OnboardingCircularProgress({
    super.key,
    required this.progress,
    this.centerText,
    this.size = 80,
    this.strokeWidth = 6,
    this.progressColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveProgressColor = progressColor ?? theme.primaryColor;
    final effectiveBackgroundColor = backgroundColor ?? Colors.grey.shade200;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: strokeWidth,
            backgroundColor: effectiveBackgroundColor,
            valueColor: AlwaysStoppedAnimation<Color>(effectiveProgressColor),
          ),
          if (centerText != null)
            Center(
              child: Text(
                centerText!,
                style: TextStyle(
                  fontSize: size * 0.2,
                  fontWeight: FontWeight.bold,
                  color: effectiveProgressColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class OnboardingStepCard extends StatelessWidget {
  final int stepNumber;
  final String title;
  final String description;
  final bool isCompleted;
  final bool isCurrent;
  final VoidCallback? onTap;

  const OnboardingStepCard({
    super.key,
    required this.stepNumber,
    required this.title,
    required this.description,
    this.isCompleted = false,
    this.isCurrent = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color cardColor;
    Color textColor;
    Color numberColor;
    IconData? statusIcon;

    if (isCompleted) {
      cardColor = Colors.green.shade50;
      textColor = Colors.green.shade800;
      numberColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (isCurrent) {
      cardColor = theme.primaryColor.withOpacity(0.1);
      textColor = theme.primaryColor;
      numberColor = theme.primaryColor;
    } else {
      cardColor = Colors.grey.shade50;
      textColor = Colors.grey.shade600;
      numberColor = Colors.grey.shade400;
    }

    return Card(
      color: cardColor,
      elevation: isCurrent ? 2 : 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Step number or status icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: numberColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: statusIcon != null
                      ? Icon(
                          statusIcon,
                          color: Colors.white,
                          size: 20,
                        )
                      : Text(
                          stepNumber.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Step content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Arrow indicator
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: textColor.withOpacity(0.6),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
