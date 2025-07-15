import 'package:flutter/material.dart';
import 'dart:developer' as developer;

/// Global navigation service for handling navigation from anywhere in the app
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Get the current navigator state
  NavigatorState? get navigator => navigatorKey.currentState;

  /// Get the current context
  BuildContext? get context => navigatorKey.currentContext;

  /// Navigate to a named route
  Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    developer.log('🧭 [NAVIGATION_SERVICE] Navigating to: $routeName');
    return navigator!.pushNamed(routeName, arguments: arguments);
  }

  /// Navigate to a named route and clear the stack
  Future<dynamic> navigateAndClearStack(String routeName, {Object? arguments}) {
    developer.log(
      '🧭 [NAVIGATION_SERVICE] Navigating and clearing stack to: $routeName',
    );
    return navigator!.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Navigate to login screen (for automatic logout)
  Future<void> navigateToLogin({String? message}) {
    developer.log('🔐 [NAVIGATION_SERVICE] Navigating to login screen');

    // Clear the entire navigation stack and go to login
    return navigateAndClearStack(
      '/sign-in',
      arguments: {'message': message, 'autoLogout': true},
    );
  }

  /// Navigate to onboarding (for first-time users)
  Future<void> navigateToOnboarding() {
    developer.log('👋 [NAVIGATION_SERVICE] Navigating to onboarding');
    return navigateAndClearStack('/onboarding');
  }

  /// Navigate to home screen (after successful login)
  Future<void> navigateToHome() {
    developer.log('🏠 [NAVIGATION_SERVICE] Navigating to home screen');
    return navigateAndClearStack('/home');
  }

  /// Go back
  void goBack() {
    developer.log('⬅️ [NAVIGATION_SERVICE] Going back');
    navigator!.pop();
  }

  /// Check if we can go back
  bool canGoBack() {
    return navigator!.canPop();
  }

  /// Show a dialog
  Future<T?> showCustomDialog<T>({
    required Widget dialog,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context!,
      barrierDismissible: barrierDismissible,
      builder: (context) => dialog,
    );
  }

  /// Show a snackbar
  void showSnackBar(String message, {Color? backgroundColor}) {
    final scaffoldMessenger = ScaffoldMessenger.of(context!);
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Show a success message
  void showSuccess(String message) {
    showSnackBar(message, backgroundColor: Colors.green);
  }

  /// Show an error message
  void showError(String message) {
    showSnackBar(message, backgroundColor: Colors.red);
  }

  /// Show an info message
  void showInfo(String message) {
    showSnackBar(message, backgroundColor: Colors.blue);
  }
}

/// Mixin for widgets that need navigation capabilities
mixin NavigationMixin {
  NavigationService get navigation => NavigationService();
}

/// Extension for easy access to navigation service
extension NavigationExtension on BuildContext {
  NavigationService get navigation => NavigationService();
}
