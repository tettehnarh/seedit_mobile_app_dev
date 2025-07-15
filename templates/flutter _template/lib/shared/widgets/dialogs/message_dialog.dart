import 'package:flutter/material.dart';
import '../../../core/utils/app_theme.dart';
import 'base_dialog.dart';

/// Message dialog for displaying information, success, warning, or error messages
class MessageDialog extends StatelessWidget {
  /// The title of the message dialog
  final String title;

  /// The main message content
  final String message;

  /// The type of message (determines styling and icon)
  final MessageType type;

  /// Text for the action button (default: "OK")
  final String buttonText;

  /// Optional additional details or instructions
  final String? details;

  /// Optional custom icon (overrides type-based icon)
  final IconData? customIcon;

  /// Optional list of action items or steps
  final List<String>? actionItems;

  const MessageDialog({
    super.key,
    required this.title,
    required this.message,
    required this.type,
    this.buttonText = 'OK',
    this.details,
    this.customIcon,
    this.actionItems,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getTypeConfiguration();

    return BaseDialog(
      title: title,
      titleIcon: customIcon ?? config.icon,
      titleColor: config.color,
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

          // Action items list
          if (actionItems != null && actionItems!.isNotEmpty) ...[
            const SizedBox(height: 16.0),
            ...actionItems!.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6.0, right: 8.0),
                      width: 4.0,
                      height: 4.0,
                      decoration: BoxDecoration(
                        color: config.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14.0,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Additional details
          if (details != null) ...[
            const SizedBox(height: 16.0),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: config.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: config.color.withValues(alpha: 0.3),
                  width: 1.0,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(config.detailIcon, color: config.color, size: 20.0),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      details!,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14.0,
                        color: config.color,
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
          text: buttonText,
          type: type == MessageType.error
              ? DialogButtonType.destructive
              : DialogButtonType.primary,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  /// Get configuration based on message type
  _MessageTypeConfig _getTypeConfiguration() {
    switch (type) {
      case MessageType.success:
        return _MessageTypeConfig(
          color: Colors.green,
          icon: Icons.check_circle_outline,
          detailIcon: Icons.info_outline,
        );
      case MessageType.error:
        return _MessageTypeConfig(
          color: Colors.red,
          icon: Icons.error_outline,
          detailIcon: Icons.warning_outlined,
        );
      case MessageType.warning:
        return _MessageTypeConfig(
          color: Colors.orange,
          icon: Icons.warning_outlined,
          detailIcon: Icons.info_outline,
        );
      case MessageType.info:
        return _MessageTypeConfig(
          color: AppTheme.primaryColor,
          icon: Icons.info_outline,
          detailIcon: Icons.lightbulb_outline,
        );
    }
  }

  /// Show a success message dialog
  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    String? details,
    List<String>? actionItems,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => MessageDialog(
        title: title,
        message: message,
        type: MessageType.success,
        buttonText: buttonText,
        details: details,
        actionItems: actionItems,
      ),
    );
  }

  /// Show an error message dialog
  static Future<void> showError({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    String? details,
    List<String>? actionItems,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => MessageDialog(
        title: title,
        message: message,
        type: MessageType.error,
        buttonText: buttonText,
        details: details,
        actionItems: actionItems,
      ),
    );
  }

  /// Show a warning message dialog
  static Future<void> showWarning({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    String? details,
    List<String>? actionItems,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => MessageDialog(
        title: title,
        message: message,
        type: MessageType.warning,
        buttonText: buttonText,
        details: details,
        actionItems: actionItems,
      ),
    );
  }

  /// Show an info message dialog
  static Future<void> showInfo({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    String? details,
    List<String>? actionItems,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => MessageDialog(
        title: title,
        message: message,
        type: MessageType.info,
        buttonText: buttonText,
        details: details,
        actionItems: actionItems,
      ),
    );
  }

  /// Show a simple error dialog with just a message
  static Future<void> showSimpleError({
    required BuildContext context,
    required String message,
  }) async {
    await showError(context: context, title: 'Error', message: message);
  }

  /// Show a simple success dialog with just a message
  static Future<void> showSimpleSuccess({
    required BuildContext context,
    required String message,
  }) async {
    await showSuccess(context: context, title: 'Success', message: message);
  }
}

/// Types of message dialogs
enum MessageType { success, error, warning, info }

/// Configuration for different message types
class _MessageTypeConfig {
  final Color color;
  final IconData icon;
  final IconData detailIcon;

  _MessageTypeConfig({
    required this.color,
    required this.icon,
    required this.detailIcon,
  });
}
