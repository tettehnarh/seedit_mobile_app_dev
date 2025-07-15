import 'package:flutter/material.dart';
import '../../../core/utils/app_theme.dart';

/// Read-only text field component for KYC review mode
class ReadOnlyTextField extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final bool isMultiline;

  const ReadOnlyTextField({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.isMultiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: AppTheme.smallTextStyle.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value.isEmpty ? 'Not provided' : value,
            style: AppTheme.bodyTextStyle.copyWith(
              color: value.isEmpty ? Colors.grey[400] : Colors.grey[800],
              fontStyle: value.isEmpty ? FontStyle.italic : FontStyle.normal,
            ),
            maxLines: isMultiline ? null : 1,
            overflow: isMultiline ? null : TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Read-only dropdown display component for KYC review mode
class ReadOnlyDropdownField extends StatelessWidget {
  final String label;
  final String value;
  final String? displayValue;
  final IconData? icon;
  final Widget? prefix;

  const ReadOnlyDropdownField({
    super.key,
    required this.label,
    required this.value,
    this.displayValue,
    this.icon,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: AppTheme.smallTextStyle.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (prefix != null) ...[prefix!, const SizedBox(width: 8)],
              Expanded(
                child: Text(
                  displayValue ?? (value.isEmpty ? 'Not selected' : value),
                  style: AppTheme.bodyTextStyle.copyWith(
                    color: value.isEmpty ? Colors.grey[400] : Colors.grey[800],
                    fontStyle: value.isEmpty
                        ? FontStyle.italic
                        : FontStyle.normal,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Read-only date display component for KYC review mode
class ReadOnlyDateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final String? dateFormat;
  final IconData? icon;

  const ReadOnlyDateField({
    super.key,
    required this.label,
    this.date,
    this.dateFormat,
    this.icon,
  });

  String _formatDate(DateTime date) {
    if (dateFormat != null) {
      // Custom format if provided
      return dateFormat!;
    }
    // Default format: DD/MM/YYYY
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: AppTheme.smallTextStyle.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[500]),
              const SizedBox(width: 8),
              Text(
                date != null ? _formatDate(date!) : 'Not selected',
                style: AppTheme.bodyTextStyle.copyWith(
                  color: date != null ? Colors.grey[800] : Colors.grey[400],
                  fontStyle: date != null ? FontStyle.normal : FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Read-only document display component for KYC review mode
class ReadOnlyDocumentField extends StatelessWidget {
  final String label;
  final String? documentPath;
  final VoidCallback? onView;
  final IconData? icon;

  const ReadOnlyDocumentField({
    super.key,
    required this.label,
    this.documentPath,
    this.onView,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final hasDocument = documentPath != null && documentPath!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: AppTheme.smallTextStyle.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasDocument) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.green[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Document Uploaded',
                        style: AppTheme.smallTextStyle.copyWith(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (onView != null)
                  TextButton.icon(
                    onPressed: onView,
                    icon: Icon(
                      Icons.visibility,
                      size: 16,
                      color: AppTheme.primaryColor,
                    ),
                    label: Text(
                      'View',
                      style: AppTheme.smallTextStyle.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                    ),
                  ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 16,
                  color: Colors.grey[400],
                ),
                const SizedBox(width: 8),
                Text(
                  'No document uploaded',
                  style: AppTheme.bodyTextStyle.copyWith(
                    color: Colors.grey[400],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Review status banner component
class KycReviewStatusBanner extends StatelessWidget {
  final String status;
  final String? message;

  const KycReviewStatusBanner({super.key, required this.status, this.message});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData icon;
    String displayText;

    switch (status.toLowerCase()) {
      case 'pending_review':
        backgroundColor = Colors.orange[50]!;
        textColor = Colors.orange[700]!;
        icon = Icons.schedule;
        displayText = 'Pending Review';
        break;
      case 'under_review':
        backgroundColor = Colors.blue[50]!;
        textColor = Colors.blue[700]!;
        icon = Icons.rate_review;
        displayText = 'Under Review';
        break;
      case 'approved':
        backgroundColor = Colors.green[50]!;
        textColor = Colors.green[700]!;
        icon = Icons.check_circle;
        displayText = 'Approved';
        break;
      case 'rejected':
        backgroundColor = Colors.red[50]!;
        textColor = Colors.red[700]!;
        icon = Icons.cancel;
        displayText = 'Rejected';
        break;
      default:
        backgroundColor = Colors.grey[50]!;
        textColor = Colors.grey[700]!;
        icon = Icons.info;
        displayText = status;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayText,
                  style: AppTheme.subheadingStyle.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    message!,
                    style: AppTheme.smallTextStyle.copyWith(
                      color: textColor.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
