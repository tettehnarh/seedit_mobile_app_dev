// Standardized dialog components for the SeedIt Mobile App
//
// This library provides a comprehensive set of reusable dialog components
// that follow the app's design system and ensure consistent user experience
// across all features.
//
// ## Available Dialog Types:
//
// ### Base Components
// - [BaseDialog] - Foundation dialog with consistent styling
// - [DialogButton] - Standardized button component for dialogs
//
// ### Specialized Dialogs
// - [ConfirmationDialog] - For user confirmations and destructive actions
// - [MessageDialog] - For success, error, warning, and info messages
// - [SelectionDialog] - For choosing from a list of options
// - [LoadingDialog] - For displaying progress during async operations
//
// ## Usage Examples:
//
// ```dart
// // Show a simple error message
// await MessageDialog.showError(
//   context: context,
//   title: 'Registration Failed',
//   message: 'An account with this email already exists.',
// );
//
// // Show a confirmation dialog
// final confirmed = await ConfirmationDialog.show(
//   context: context,
//   title: 'Delete Group',
//   message: 'Are you sure you want to delete this group?',
//   isDestructive: true,
// );
//
// // Show a selection dialog
// final source = await SelectionDialog.showImageSource(
//   context: context,
// );
//
// // Show a loading dialog
// LoadingDialogManager.show(
//   context: context,
//   title: 'Uploading',
//   message: 'Please wait...',
// );
// ```
//
// ## Design Principles:
//
// - **Consistency**: All dialogs follow the same visual design language
// - **Accessibility**: Proper contrast ratios and touch targets
// - **Responsiveness**: Adapts to different screen sizes
// - **Theming**: Uses AppTheme colors and Montserrat typography
// - **Usability**: Clear actions and intuitive interactions

// Import Flutter material for BuildContext
import 'package:flutter/material.dart';

// Base components
export 'base_dialog.dart';

// Specialized dialog types
export 'confirmation_dialog.dart';
export 'message_dialog.dart';
export 'selection_dialog.dart';
export 'loading_dialog.dart';

// Utility classes and enums
export 'base_dialog.dart' show DialogButton, DialogButtonType;
export 'message_dialog.dart' show MessageType;
export 'selection_dialog.dart' show SelectionOption, ImageSource;
export 'loading_dialog.dart' show LoadingDialogManager;

// Import the dialog classes for use in AppDialogs
import 'confirmation_dialog.dart';
import 'message_dialog.dart';
import 'selection_dialog.dart';
import 'loading_dialog.dart';

/// Utility class providing quick access to common dialog patterns
class AppDialogs {
  AppDialogs._(); // Private constructor to prevent instantiation

  /// Show a simple error message
  static Future<void> showError({
    required BuildContext context,
    required String message,
    String title = 'Error',
  }) async {
    await MessageDialog.showError(
      context: context,
      title: title,
      message: message,
    );
  }

  /// Show a simple success message
  static Future<void> showSuccess({
    required BuildContext context,
    required String message,
    String title = 'Success',
  }) async {
    await MessageDialog.showSuccess(
      context: context,
      title: title,
      message: message,
    );
  }

  /// Show a simple confirmation dialog
  static Future<bool> confirm({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) async {
    return await ConfirmationDialog.show(
      context: context,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      isDestructive: isDestructive,
    );
  }

  /// Show a delete confirmation dialog
  static Future<bool> confirmDelete({
    required BuildContext context,
    required String itemName,
    String? details,
  }) async {
    return await ConfirmationDialog.showDestructive(
      context: context,
      title: 'Delete $itemName',
      message: 'Are you sure you want to delete this $itemName?',
      confirmText: 'Delete',
      details: details ?? 'This action cannot be undone.',
    );
  }

  /// Show an image source selection dialog
  static Future<ImageSource?> selectImageSource({
    required BuildContext context,
  }) async {
    return await SelectionDialog.showImageSource(context: context);
  }

  /// Show a loading dialog
  static Future<void> showLoading({
    required BuildContext context,
    String title = 'Loading',
    String message = 'Please wait...',
    bool showCancel = false,
  }) async {
    await LoadingDialog.show(
      context: context,
      title: title,
      message: message,
      showCancel: showCancel,
    );
  }

  /// Show a network error dialog with retry option
  static Future<bool> showNetworkError({
    required BuildContext context,
    String? customMessage,
  }) async {
    return await ConfirmationDialog.show(
      context: context,
      title: 'Connection Error',
      message:
          customMessage ??
          'Unable to connect to the server. Please check your internet connection.',
      confirmText: 'Retry',
      cancelText: 'Cancel',
      icon: Icons.wifi_off,
      details: 'Make sure you have a stable internet connection and try again.',
    );
  }

  /// Show a feature unavailable dialog (for KYC restrictions)
  static Future<void> showFeatureUnavailable({
    required BuildContext context,
    required String featureName,
    String? customMessage,
  }) async {
    await MessageDialog.showWarning(
      context: context,
      title: '$featureName Unavailable',
      message:
          customMessage ??
          'You need to complete your KYC verification to access this feature.',
      actionItems: [
        'Complete your KYC verification',
        'Wait for approval from our team',
        'Try accessing the feature again',
      ],
    );
  }

  /// Show a validation error dialog
  static Future<void> showValidationError({
    required BuildContext context,
    required List<String> errors,
  }) async {
    await MessageDialog.showError(
      context: context,
      title: 'Validation Error',
      message: 'Please fix the following issues:',
      actionItems: errors,
    );
  }

  /// Show a maintenance dialog
  static Future<void> showMaintenance({
    required BuildContext context,
    String? estimatedTime,
  }) async {
    await MessageDialog.showInfo(
      context: context,
      title: 'Maintenance Mode',
      message: 'The app is currently undergoing maintenance.',
      details: estimatedTime != null
          ? 'Estimated completion time: $estimatedTime'
          : 'Please try again later.',
    );
  }
}
