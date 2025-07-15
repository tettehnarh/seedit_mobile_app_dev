import 'package:flutter/material.dart';
import '../../../core/utils/app_theme.dart';

/// Base dialog widget that provides consistent styling and layout
/// for all dialogs throughout the app
class BaseDialog extends StatelessWidget {
  /// The title of the dialog
  final String? title;

  /// The main content of the dialog
  final Widget content;

  /// List of action buttons (typically Cancel, OK, etc.)
  final List<Widget>? actions;

  /// Optional icon to display in the title area
  final IconData? titleIcon;

  /// Color for the title icon and title text
  final Color? titleColor;

  /// Whether the dialog can be dismissed by tapping outside
  final bool barrierDismissible;

  /// Maximum width of the dialog
  final double? maxWidth;

  /// Whether to show a close button in the top-right corner
  final bool showCloseButton;

  /// Custom padding for the content area
  final EdgeInsets? contentPadding;

  /// Custom padding for the actions area
  final EdgeInsets? actionsPadding;

  const BaseDialog({
    super.key,
    this.title,
    required this.content,
    this.actions,
    this.titleIcon,
    this.titleColor,
    this.barrierDismissible = true,
    this.maxWidth,
    this.showCloseButton = false,
    this.contentPadding,
    this.actionsPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 40.0,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? 400.0,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20.0,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title Section
            if (title != null) _buildTitleSection(context),

            // Content Section
            Flexible(
              child: Container(
                padding:
                    contentPadding ??
                    const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 16.0),
                child: content,
              ),
            ),

            // Actions Section
            if (actions != null && actions!.isNotEmpty)
              _buildActionsSection(context),
          ],
        ),
      ),
    );
  }

  /// Build the title section with optional icon and close button
  Widget _buildTitleSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 8.0),
      child: Row(
        children: [
          // Title Icon
          if (titleIcon != null) ...[
            Icon(
              titleIcon,
              color: titleColor ?? AppTheme.primaryColor,
              size: 24.0,
            ),
            const SizedBox(width: 12.0),
          ],

          // Title Text
          Expanded(
            child: Text(
              title!,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                color: titleColor ?? AppTheme.primaryColor,
                height: 1.3,
              ),
            ),
          ),

          // Close Button
          if (showCloseButton)
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: Colors.grey, size: 20.0),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 32.0,
                minHeight: 32.0,
              ),
            ),
        ],
      ),
    );
  }

  /// Build the actions section with proper spacing and alignment
  Widget _buildActionsSection(BuildContext context) {
    return Container(
      padding:
          actionsPadding ?? const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          for (int i = 0; i < actions!.length; i++) ...[
            if (i > 0) const SizedBox(width: 12.0),
            actions![i],
          ],
        ],
      ),
    );
  }

  /// Show the dialog with consistent animation and barrier behavior
  static Future<T?> show<T>({
    required BuildContext context,
    required BaseDialog dialog,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => dialog,
    );
  }
}

/// Standard dialog button styles following app theme
class DialogButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final DialogButtonType type;
  final bool isLoading;
  final IconData? icon;

  const DialogButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = DialogButtonType.secondary,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case DialogButtonType.primary:
        return ElevatedButton.icon(
          onPressed: isLoading ? null : onPressed,
          style: AppTheme.primaryButtonStyle.copyWith(
            minimumSize: WidgetStateProperty.all(const Size(80.0, 40.0)),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            ),
          ),
          icon: isLoading
              ? const SizedBox(
                  width: 16.0,
                  height: 16.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : (icon != null
                    ? Icon(icon, size: 16.0)
                    : const SizedBox.shrink()),
          label: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        );

      case DialogButtonType.secondary:
        return OutlinedButton.icon(
          onPressed: isLoading ? null : onPressed,
          style: AppTheme.secondaryButtonStyle.copyWith(
            minimumSize: WidgetStateProperty.all(const Size(80.0, 40.0)),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            ),
          ),
          icon: icon != null ? Icon(icon, size: 16.0) : const SizedBox.shrink(),
          label: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        );

      case DialogButtonType.text:
        return TextButton.icon(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.primaryColor,
            minimumSize: const Size(80.0, 40.0),
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
          ),
          icon: icon != null ? Icon(icon, size: 16.0) : const SizedBox.shrink(),
          label: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        );

      case DialogButtonType.destructive:
        return ElevatedButton.icon(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            minimumSize: const Size(80.0, 40.0),
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          icon: icon != null ? Icon(icon, size: 16.0) : const SizedBox.shrink(),
          label: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
    }
  }
}

/// Types of dialog buttons with different styling
enum DialogButtonType {
  primary, // Filled button with primary color
  secondary, // Outlined button
  text, // Text-only button
  destructive, // Red button for dangerous actions
}
