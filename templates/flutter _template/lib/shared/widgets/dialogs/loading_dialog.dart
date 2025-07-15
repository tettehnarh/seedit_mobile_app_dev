import 'package:flutter/material.dart';
import '../../../core/utils/app_theme.dart';
import 'base_dialog.dart';

/// Loading dialog for displaying progress during async operations
class LoadingDialog extends StatelessWidget {
  /// The title of the loading dialog
  final String title;

  /// The message describing what's happening
  final String message;

  /// Whether to show a cancel button
  final bool showCancel;

  /// Text for the cancel button
  final String cancelText;

  /// Optional progress value (0.0 to 1.0) for determinate progress
  final double? progress;

  /// Optional icon to display
  final IconData? icon;

  /// Whether the dialog can be dismissed by tapping outside
  final bool barrierDismissible;

  const LoadingDialog({
    super.key,
    required this.title,
    required this.message,
    this.showCancel = false,
    this.cancelText = 'Cancel',
    this.progress,
    this.icon,
    this.barrierDismissible = false,
  });

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: title,
      titleIcon: icon ?? Icons.hourglass_empty,
      barrierDismissible: barrierDismissible,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress indicator
          if (progress != null)
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            )
          else
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),

          const SizedBox(height: 24.0),

          // Message
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16.0,
              color: Colors.black87,
              height: 1.4,
            ),
          ),

          // Progress percentage (for determinate progress)
          if (progress != null) ...[
            const SizedBox(height: 12.0),
            Text(
              '${(progress! * 100).round()}%',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14.0,
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
      actions: showCancel
          ? [
              DialogButton(
                text: cancelText,
                type: DialogButtonType.text,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ]
          : null,
    );
  }

  /// Show a loading dialog
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String message,
    bool showCancel = false,
    String cancelText = 'Cancel',
    double? progress,
    IconData? icon,
    bool barrierDismissible = false,
  }) async {
    return await showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => LoadingDialog(
        title: title,
        message: message,
        showCancel: showCancel,
        cancelText: cancelText,
        progress: progress,
        icon: icon,
        barrierDismissible: barrierDismissible,
      ),
    );
  }

  /// Show a simple loading dialog with just a message
  static Future<T?> showSimple<T>({
    required BuildContext context,
    required String message,
    bool showCancel = false,
  }) async {
    return await show<T>(
      context: context,
      title: 'Loading',
      message: message,
      showCancel: showCancel,
    );
  }

  /// Show a loading dialog for file upload with progress
  static Future<T?> showUpload<T>({
    required BuildContext context,
    required String fileName,
    double? progress,
    bool showCancel = true,
  }) async {
    return await show<T>(
      context: context,
      title: 'Uploading File',
      message: 'Uploading $fileName...',
      progress: progress,
      showCancel: showCancel,
      icon: Icons.cloud_upload,
    );
  }

  /// Show a loading dialog for download with progress
  static Future<T?> showDownload<T>({
    required BuildContext context,
    required String fileName,
    double? progress,
    bool showCancel = true,
  }) async {
    return await show<T>(
      context: context,
      title: 'Downloading File',
      message: 'Downloading $fileName...',
      progress: progress,
      showCancel: showCancel,
      icon: Icons.cloud_download,
    );
  }

  /// Show a loading dialog for processing/saving data
  static Future<T?> showProcessing<T>({
    required BuildContext context,
    String title = 'Processing',
    String message = 'Please wait while we process your request...',
    bool showCancel = false,
  }) async {
    return await show<T>(
      context: context,
      title: title,
      message: message,
      showCancel: showCancel,
      icon: Icons.settings,
    );
  }

  /// Show a loading dialog for network requests
  static Future<T?> showNetworkRequest<T>({
    required BuildContext context,
    String title = 'Loading',
    String message = 'Connecting to server...',
    bool showCancel = true,
  }) async {
    return await show<T>(
      context: context,
      title: title,
      message: message,
      showCancel: showCancel,
      icon: Icons.wifi,
    );
  }
}

/// Helper class for managing loading dialogs with automatic dismissal
class LoadingDialogManager {
  static LoadingDialog? _currentDialog;
  static BuildContext? _currentContext;

  /// Show a loading dialog and keep reference for dismissal
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    bool showCancel = false,
    String cancelText = 'Cancel',
    IconData? icon,
  }) async {
    _currentContext = context;
    _currentDialog = LoadingDialog(
      title: title,
      message: message,
      showCancel: showCancel,
      cancelText: cancelText,
      icon: icon,
    );

    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => _currentDialog!,
    );
  }

  /// Dismiss the currently shown loading dialog
  static void dismiss() {
    if (_currentContext != null && _currentDialog != null) {
      Navigator.of(_currentContext!).pop();
      _currentDialog = null;
      _currentContext = null;
    }
  }

  /// Update the progress of the current loading dialog
  static void updateProgress(double progress) {
    // Note: This would require a StatefulWidget implementation
    // For now, dismiss and show new dialog with updated progress
    if (_currentContext != null) {
      dismiss();
      // Would need to re-show with new progress
    }
  }

  /// Check if a loading dialog is currently shown
  static bool get isShowing =>
      _currentDialog != null && _currentContext != null;
}
