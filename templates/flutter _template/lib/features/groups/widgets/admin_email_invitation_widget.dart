import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import '../../../core/utils/app_theme.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../auth/providers/auth_provider.dart';

class AdminEmailInvitationWidget extends ConsumerStatefulWidget {
  final List<String> adminEmails;
  final Function(List<String>) onEmailsChanged;
  final bool isRequired;

  const AdminEmailInvitationWidget({
    super.key,
    required this.adminEmails,
    required this.onEmailsChanged,
    this.isRequired = true,
  });

  @override
  ConsumerState<AdminEmailInvitationWidget> createState() =>
      _AdminEmailInvitationWidgetState();
}

class _AdminEmailInvitationWidgetState
    extends ConsumerState<AdminEmailInvitationWidget> {
  final List<TextEditingController> _emailControllers = [];
  final List<String> _validationErrors = [];
  late List<String> _adminEmails;

  @override
  void initState() {
    super.initState();
    _adminEmails = List.from(widget.adminEmails);
    _initializeEmailFields();
  }

  @override
  void dispose() {
    for (final controller in _emailControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeEmailFields() {
    // CRITICAL CHANGE: Don't include creator's email - they're automatically primary admin
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = ref.read(authProvider).user;

      if (_adminEmails.isNotEmpty) {
        // Initialize controllers for existing emails (edit mode)
        // Remove creator's email if it exists in the list
        if (currentUser != null) {
          _adminEmails.removeWhere((email) => email == currentUser.email);
        }
        for (final email in _adminEmails) {
          _addEmailController(email);
        }
      }

      // Start with 2 empty email fields for additional admins
      // (Creator is automatically admin, so we need 2 more for the 3-admin requirement)
      while (_emailControllers.length < 2) {
        _addEmailController('');
      }

      // Update parent with current emails (excluding creator)
      widget.onEmailsChanged(_adminEmails);
    });
  }

  void _addEmailController(String initialValue) {
    final controller = TextEditingController(text: initialValue);
    controller.addListener(_onEmailChanged);
    _emailControllers.add(controller);
    _validationErrors.add('');
  }

  void _onEmailChanged() {
    final emails = _emailControllers
        .map((controller) => controller.text.trim())
        .where((email) => email.isNotEmpty)
        .toList();

    // CRITICAL CHANGE: Remove creator's email if somehow included
    final currentUser = ref.read(authProvider).user;
    if (currentUser != null) {
      emails.removeWhere((email) => email == currentUser.email);
    }

    developer.log('🔍 [ADMIN_EMAIL_WIDGET] Email changed event triggered');
    developer.log('🔍 [ADMIN_EMAIL_WIDGET] Raw controller values:');
    for (int i = 0; i < _emailControllers.length; i++) {
      developer.log('  Controller $i: "${_emailControllers[i].text}"');
    }
    developer.log(
      '🔍 [ADMIN_EMAIL_WIDGET] Filtered emails (excluding creator): $emails',
    );
    developer.log('🔍 [ADMIN_EMAIL_WIDGET] Emails type: ${emails.runtimeType}');

    setState(() {
      _adminEmails = emails;
      _validateEmails();
    });

    developer.log('🔍 [ADMIN_EMAIL_WIDGET] Final admin emails: $_adminEmails');
    developer.log(
      '🔍 [ADMIN_EMAIL_WIDGET] Calling onEmailsChanged callback...',
    );
    widget.onEmailsChanged(_adminEmails);
  }

  void _validateEmails() {
    _validationErrors.clear();

    // CRITICAL CHANGE: Check for creator's email and show warning if entered
    final currentUser = ref.read(authProvider).user;

    for (int i = 0; i < _emailControllers.length; i++) {
      final email = _emailControllers[i].text.trim();
      String error = '';

      if (email.isNotEmpty) {
        // Check if user entered their own email
        if (currentUser != null && email == currentUser.email) {
          error = 'You are automatically the primary admin';
        }
        // Basic email validation
        else if (!_isValidEmail(email)) {
          error = 'Invalid email format';
        } else {
          // Check for duplicates
          final duplicateIndex = _emailControllers
              .take(i)
              .toList()
              .indexWhere((controller) => controller.text.trim() == email);
          if (duplicateIndex != -1) {
            error = 'Duplicate email address';
          }
        }
      }
      // No required field validation since all admin emails are optional

      _validationErrors.add(error);
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  void _addEmailField() {
    if (_emailControllers.length < 5) {
      // Maximum 5 admin invitations
      setState(() {
        _addEmailController('');
      });
    }
  }

  void _removeEmailField(int index) {
    if (_emailControllers.length > 1) {
      // CRITICAL CHANGE: Can remove any field since no field is for current user
      setState(() {
        _emailControllers[index].dispose();
        _emailControllers.removeAt(index);
        _validationErrors.removeAt(index);
      });
      _onEmailChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.admin_panel_settings,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Admin Invitations',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            'You are automatically the primary admin. Invite additional people to be group admins by entering their email addresses. They will receive invitation emails and can join as admins after completing registration (if needed).',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 16),

          // Email input fields
          ...List.generate(_emailControllers.length, (index) {
            final hasError =
                _validationErrors.length > index &&
                _validationErrors[index].isNotEmpty;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _emailControllers[index],
                      label: 'Admin Email ${index + 1}',
                      hint: 'Enter email address',
                      keyboardType: TextInputType.emailAddress,
                      validator: hasError
                          ? (_) => _validationErrors[index]
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () => _removeEmailField(index),
                    iconSize: 20,
                  ),
                ],
              ),
            );
          }),

          // Add email field button
          if (_emailControllers.length < 5) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _addEmailField,
              icon: const Icon(Icons.add, size: 16),
              label: const Text(
                'Add Another Admin Email',
                style: TextStyle(fontSize: 12, fontFamily: 'Montserrat'),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
          ],

          // Requirements info
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue[700], size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Admin Invitation Process',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '• You are automatically the primary admin of this group\n'
                  '• Invitation emails will be sent to all provided addresses\n'
                  '• Recipients can accept invitations after registering (if needed)\n'
                  '• Groups can have up to 5 total admins (including you)\n'
                  '• Additional admins are optional - you can create the group with just yourself as admin',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blue[700],
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ),

          // Validation summary
          if (_getValidationSummary().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red[700], size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getValidationSummary(),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.red[700],
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getValidationSummary() {
    final errors = _validationErrors
        .where((error) => error.isNotEmpty)
        .toList();
    if (errors.isEmpty) return '';

    return 'Please fix the following issues:\n${errors.map((e) => '• $e').join('\n')}';
  }
}
