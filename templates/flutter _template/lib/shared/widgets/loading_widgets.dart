import 'package:flutter/material.dart';
import '../../core/utils/app_theme.dart';

/// Standardized loading widgets following AppTheme colors and design patterns
class LoadingWidgets {
  LoadingWidgets._();

  /// Standard circular progress indicator with AppTheme colors
  static Widget circular({
    double size = 24.0,
    double strokeWidth = 2.0,
    Color? color,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppTheme.primaryColor,
        ),
      ),
    );
  }

  /// Large circular progress indicator for full-screen loading
  static Widget circularLarge({
    double size = 48.0,
    double strokeWidth = 4.0,
    Color? color,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppTheme.primaryColor,
        ),
      ),
    );
  }

  /// Linear progress indicator with AppTheme colors
  static Widget linear({
    double? value,
    Color? backgroundColor,
    Color? valueColor,
    double height = 4.0,
  }) {
    return SizedBox(
      height: height,
      child: LinearProgressIndicator(
        value: value,
        backgroundColor: backgroundColor ?? Colors.grey[300],
        valueColor: AlwaysStoppedAnimation<Color>(
          valueColor ?? AppTheme.primaryColor,
        ),
      ),
    );
  }

  /// Shimmer loading effect for list items
  static Widget shimmerListItem({
    double height = 80.0,
    EdgeInsets margin = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
  }) {
    return Container(
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: const _ShimmerEffect(),
    );
  }

  /// Shimmer loading effect for cards
  static Widget shimmerCard({
    double height = 120.0,
    EdgeInsets margin = const EdgeInsets.all(16.0),
    BorderRadius? borderRadius,
  }) {
    return Container(
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius ?? BorderRadius.circular(12.0),
      ),
      child: const _ShimmerEffect(),
    );
  }

  /// Loading overlay for buttons
  static Widget buttonLoading({
    double size = 20.0,
    Color? color,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Colors.white,
        ),
      ),
    );
  }

  /// Full-screen loading overlay
  static Widget fullScreenOverlay({
    String? message,
    bool showBackground = true,
    Color? backgroundColor,
  }) {
    return Container(
      color: showBackground 
          ? (backgroundColor ?? Colors.black.withOpacity(0.5))
          : Colors.transparent,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            circularLarge(),
            if (message != null) ...[
              const SizedBox(height: 16.0),
              Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Loading state for empty screens
  static Widget emptyScreenLoading({
    String message = 'Loading...',
    IconData? icon,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 48.0,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16.0),
          ],
          circularLarge(),
          const SizedBox(height: 16.0),
          Text(
            message,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16.0,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Loading state for list views
  static Widget listLoading({
    int itemCount = 5,
    double itemHeight = 80.0,
  }) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) => shimmerListItem(height: itemHeight),
    );
  }

  /// Loading state for grid views
  static Widget gridLoading({
    int itemCount = 6,
    int crossAxisCount = 2,
    double childAspectRatio = 1.0,
  }) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => shimmerCard(margin: EdgeInsets.zero),
    );
  }

  /// Loading state for investment/transaction operations
  static Widget transactionLoading({
    String message = 'Processing transaction...',
  }) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          circularLarge(),
          const SizedBox(height: 16.0),
          Text(
            message,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16.0,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Loading state for API requests with retry option
  static Widget apiRequestLoading({
    String message = 'Loading...',
    VoidCallback? onRetry,
    bool showRetry = false,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          circularLarge(),
          const SizedBox(height: 16.0),
          Text(
            message,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16.0,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          if (showRetry && onRetry != null) ...[
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Internal shimmer effect widget
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
