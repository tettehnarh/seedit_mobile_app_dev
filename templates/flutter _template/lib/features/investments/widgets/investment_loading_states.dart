import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_theme.dart';
import '../../../shared/widgets/loading_widgets.dart';
import '../../../shared/providers/loading_provider.dart';

/// Investment-specific loading state widgets
class InvestmentLoadingStates {
  InvestmentLoadingStates._();

  /// Loading state for portfolio summary
  static Widget portfolioSummaryLoading() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title shimmer
          Container(
            height: 20.0,
            width: 150.0,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: const _ShimmerEffect(),
          ),
          const SizedBox(height: 16.0),
          
          // Value shimmer
          Container(
            height: 32.0,
            width: 200.0,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: const _ShimmerEffect(),
          ),
          const SizedBox(height: 8.0),
          
          // Subtitle shimmer
          Container(
            height: 16.0,
            width: 120.0,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: const _ShimmerEffect(),
          ),
        ],
      ),
    );
  }

  /// Loading state for fund list
  static Widget fundListLoading({int itemCount = 5}) {
    return ListView.builder(
      itemCount: itemCount,
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, index) => Container(
        height: 120.0,
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Fund icon shimmer
              Container(
                width: 60.0,
                height: 60.0,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const _ShimmerEffect(),
              ),
              const SizedBox(width: 16.0),
              
              // Fund details shimmer
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 18.0,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: const _ShimmerEffect(),
                    ),
                    const SizedBox(height: 8.0),
                    Container(
                      height: 14.0,
                      width: 150.0,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: const _ShimmerEffect(),
                    ),
                    const SizedBox(height: 8.0),
                    Container(
                      height: 16.0,
                      width: 100.0,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: const _ShimmerEffect(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Loading state for transaction processing
  static Widget transactionProcessingLoading({
    required String message,
    bool showCancel = false,
    VoidCallback? onCancel,
  }) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Loading indicator
          LoadingWidgets.circularLarge(
            size: 56.0,
            strokeWidth: 4.0,
          ),
          const SizedBox(height: 24.0),
          
          // Message
          Text(
            message,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8.0),
          
          Text(
            'Please wait while we process your request...',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14.0,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          
          if (showCancel && onCancel != null) ...[
            const SizedBox(height: 24.0),
            TextButton(
              onPressed: onCancel,
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Loading overlay for investment operations
  static Widget investmentOperationOverlay({
    required String operation,
    String? details,
  }) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32.0),
          margin: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LoadingWidgets.circularLarge(
                size: 64.0,
                strokeWidth: 5.0,
              ),
              const SizedBox(height: 24.0),
              
              Text(
                operation,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              
              if (details != null) ...[
                const SizedBox(height: 12.0),
                Text(
                  details,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16.0,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Loading state for investment dashboard
  static Widget dashboardLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Portfolio summary loading
          portfolioSummaryLoading(),
          const SizedBox(height: 24.0),
          
          // Quick actions loading
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 80.0,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: const _ShimmerEffect(),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Container(
                  height: 80.0,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: const _ShimmerEffect(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24.0),
          
          // Recent transactions loading
          Container(
            height: 200.0,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: const _ShimmerEffect(),
          ),
        ],
      ),
    );
  }
}

/// Consumer widget that automatically shows loading states for investment operations
class InvestmentLoadingConsumer extends ConsumerWidget {
  final Widget child;
  final String? loadingOperation;
  final Widget? customLoadingWidget;

  const InvestmentLoadingConsumer({
    super.key,
    required this.child,
    this.loadingOperation,
    this.customLoadingWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = loadingOperation != null 
        ? ref.watch(loadingProvider).isLoading(loadingOperation!)
        : ref.watch(isAnyLoadingProvider);

    if (isLoading) {
      return customLoadingWidget ?? 
             LoadingWidgets.fullScreenOverlay(
               message: 'Processing...',
             );
    }

    return child;
  }
}

/// Shimmer effect for loading states
class _ShimmerEffect extends StatefulWidget {
  const _ShimmerEffect();

  @override
  State<_ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<_ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}
