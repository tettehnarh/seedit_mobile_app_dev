import 'package:flutter/material.dart';
import '../../../core/utils/app_theme.dart';
import 'base_dialog.dart';

/// Selection dialog for choosing from a list of options
class SelectionDialog<T> extends StatelessWidget {
  /// The title of the selection dialog
  final String title;

  /// Optional subtitle or description
  final String? subtitle;

  /// List of selectable options
  final List<SelectionOption<T>> options;

  /// Currently selected value (if any)
  final T? selectedValue;

  /// Whether to show cancel button
  final bool showCancel;

  /// Text for cancel button
  final String cancelText;

  /// Optional icon for the dialog
  final IconData? icon;

  const SelectionDialog({
    super.key,
    required this.title,
    this.subtitle,
    required this.options,
    this.selectedValue,
    this.showCancel = true,
    this.cancelText = 'Cancel',
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: title,
      titleIcon: icon,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subtitle != null) ...[
            Text(
              subtitle!,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14.0,
                color: Colors.black54,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16.0),
          ],

          // Options list
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: options
                    .map((option) => _buildOptionTile(context, option))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
      actions: showCancel
          ? [
              DialogButton(
                text: cancelText,
                type: DialogButtonType.text,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ]
          : null,
    );
  }

  /// Build an individual option tile
  Widget _buildOptionTile(BuildContext context, SelectionOption<T> option) {
    final isSelected = selectedValue == option.value;

    return InkWell(
      onTap: option.enabled
          ? () => Navigator.of(context).pop(option.value)
          : null,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
        margin: const EdgeInsets.only(bottom: 4.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          border: isSelected
              ? Border.all(color: AppTheme.primaryColor, width: 1.0)
              : null,
        ),
        child: Row(
          children: [
            // Leading icon
            if (option.icon != null) ...[
              Icon(
                option.icon,
                color: option.enabled
                    ? (isSelected ? AppTheme.primaryColor : Colors.black54)
                    : Colors.grey,
                size: 24.0,
              ),
              const SizedBox(width: 12.0),
            ],

            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16.0,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: option.enabled
                          ? (isSelected
                                ? AppTheme.primaryColor
                                : Colors.black87)
                          : Colors.grey,
                      height: 1.3,
                    ),
                  ),
                  if (option.subtitle != null) ...[
                    const SizedBox(height: 2.0),
                    Text(
                      option.subtitle!,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14.0,
                        color: option.enabled ? Colors.black54 : Colors.grey,
                        height: 1.2,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Selection indicator
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
                size: 20.0,
              ),
          ],
        ),
      ),
    );
  }

  /// Show a selection dialog and return the selected value
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? subtitle,
    required List<SelectionOption<T>> options,
    T? selectedValue,
    bool showCancel = true,
    String cancelText = 'Cancel',
    IconData? icon,
  }) async {
    return await showDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => SelectionDialog<T>(
        title: title,
        subtitle: subtitle,
        options: options,
        selectedValue: selectedValue,
        showCancel: showCancel,
        cancelText: cancelText,
        icon: icon,
      ),
    );
  }

  /// Show a simple selection dialog with string options
  static Future<String?> showStringOptions({
    required BuildContext context,
    required String title,
    String? subtitle,
    required List<String> options,
    String? selectedValue,
    bool showCancel = true,
    IconData? icon,
  }) async {
    final selectionOptions = options
        .map((option) => SelectionOption<String>(value: option, title: option))
        .toList();

    return await show<String>(
      context: context,
      title: title,
      subtitle: subtitle,
      options: selectionOptions,
      selectedValue: selectedValue,
      showCancel: showCancel,
      icon: icon,
    );
  }

  /// Show an image source selection dialog (Camera/Gallery)
  static Future<ImageSource?> showImageSource({
    required BuildContext context,
    String title = 'Select Image Source',
  }) async {
    final options = [
      SelectionOption<ImageSource>(
        value: ImageSource.camera,
        title: 'Camera',
        subtitle: 'Take a new photo',
        icon: Icons.camera_alt,
      ),
      SelectionOption<ImageSource>(
        value: ImageSource.gallery,
        title: 'Photo Library',
        subtitle: 'Choose from existing photos',
        icon: Icons.photo_library,
      ),
    ];

    return await show<ImageSource>(
      context: context,
      title: title,
      options: options,
      icon: Icons.image,
    );
  }
}

/// Represents a selectable option in the dialog
class SelectionOption<T> {
  /// The value that will be returned when this option is selected
  final T value;

  /// The display title for this option
  final String title;

  /// Optional subtitle for additional information
  final String? subtitle;

  /// Optional icon to display
  final IconData? icon;

  /// Whether this option can be selected
  final bool enabled;

  const SelectionOption({
    required this.value,
    required this.title,
    this.subtitle,
    this.icon,
    this.enabled = true,
  });
}

/// Image source options for image picker dialogs
enum ImageSource { camera, gallery }
