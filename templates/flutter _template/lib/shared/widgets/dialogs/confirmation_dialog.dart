import 'package:flutter/material.dart';
import '../../../core/utils/app_theme.dart';
import 'base_dialog.dart';

/// Confirmation dialog for user actions that require confirmation
class ConfirmationDialog extends StatelessWidget {
  /// The title of the confirmation dialog
  final String title;

  /// The message explaining what will happen
  final String message;

  /// Text for the confirm button (default: "Confirm")
  final String confirmText;

  /// Text for the cancel button (default: "Cancel")
  final String cancelText;

  /// Whether the action is destructive (uses red styling)
  final bool isDestructive;

  /// Optional icon to display
  final IconData? icon;

  /// Whether to show loading state on confirm button
  final bool isLoading;

  /// Additional details or warnings to display
  final String? details;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.isDestructive = false,
    this.icon,
    this.isLoading = false,
    this.details,
  });

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: title,
      titleIcon: icon ?? (isDestructive ? Icons.warning : Icons.help_outline),
      titleColor: isDestructive ? Colors.red : AppTheme.primaryColor,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16.0,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          if (details != null) ...[
            const SizedBox(height: 16.0),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.withValues(alpha: 0.1)
                    : AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: isDestructive
                      ? Colors.red.withValues(alpha: 0.3)
                      : AppTheme.primaryColor.withValues(alpha: 0.3),
                  width: 1.0,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isDestructive ? Icons.warning : Icons.info,
                    color: isDestructive ? Colors.red : AppTheme.primaryColor,
                    size: 20.0,
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      details!,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14.0,
                        color: isDestructive
                            ? Colors.red[700]
                            : AppTheme.primaryColor,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        DialogButton(
          text: cancelText,
          type: DialogButtonType.text,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        DialogButton(
          text: confirmText,
          type: isDestructive
              ? DialogButtonType.destructive
              : DialogButtonType.primary,
          isLoading: isLoading,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }

  /// Show a confirmation dialog and return the user's choice
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
    IconData? icon,
    String? details,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
        icon: icon,
        details: details,
      ),
    );
    return result ?? false;
  }

  /// Show a destructive confirmation dialog (red styling)
  static Future<bool> showDestructive({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Delete',
    String cancelText = 'Cancel',
    IconData? icon,
    String? details,
  }) async {
    return show(
      context: context,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      isDestructive: true,
      icon: icon ?? Icons.delete_forever,
      details: details,
    );
  }

  /// Show a simple yes/no confirmation dialog
  static Future<bool> showYesNo({
    required BuildContext context,
    required String title,
    required String message,
    IconData? icon,
    String? details,
  }) async {
    return show(
      context: context,
      title: title,
      message: message,
      confirmText: 'Yes',
      cancelText: 'No',
      icon: icon ?? Icons.help_outline,
      details: details,
    );
  }

  /// Show a confirmation dialog for leaving/canceling an action
  static Future<bool> showLeaveConfirmation({
    required BuildContext context,
    String title = 'Discard Changes?',
    String message =
        'You have unsaved changes. Are you sure you want to leave?',
  }) async {
    return show(
      context: context,
      title: title,
      message: message,
      confirmText: 'Discard',
      cancelText: 'Stay',
      isDestructive: true,
      icon: Icons.exit_to_app,
      details: 'Any unsaved changes will be lost permanently.',
    );
  }

  /// Show a confirmation dialog for activating something
  static Future<bool> showActivationConfirmation({
    required BuildContext context,
    required String itemName,
    String? requirements,
  }) async {
    return show(
      context: context,
      title: 'Activate $itemName',
      message: 'Are you ready to activate $itemName?',
      confirmText: 'Activate',
      cancelText: 'Cancel',
      icon: Icons.play_circle_outline,
      details: requirements,
    );
  }
}
