import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/app_theme.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../models/wallet_models.dart';
import '../providers/user_payment_methods_provider.dart';

// Import standardized dialogs
import '../../../shared/widgets/dialogs/dialogs.dart';

class WalletDetailScreen extends ConsumerStatefulWidget {
  final PaymentMethod paymentMethod;

  const WalletDetailScreen({super.key, required this.paymentMethod});

  @override
  ConsumerState<WalletDetailScreen> createState() => _WalletDetailScreenState();
}

class _WalletDetailScreenState extends ConsumerState<WalletDetailScreen> {
  final _formKey = GlobalKey<FormState>(debugLabel: 'wallet_detail_form');
  late TextEditingController _nameController;
  late bool _isDefault;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.paymentMethod.name);
    _isDefault = widget.paymentMethod.isDefault;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _isEditing ? 'Edit Payment Method' : 'Payment Method Details',
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.check, color: AppTheme.primaryColor),
              onPressed: _saveChanges,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payment Method Header Card
              _buildPaymentMethodCard(),
              const SizedBox(height: 24),

              // Edit Form (only visible when editing)
              if (_isEditing) ...[_buildEditForm(), const SizedBox(height: 24)],

              // Comprehensive Details (only visible when not editing)
              if (!_isEditing) ...[
                _buildBasicInformationSection(),
                const SizedBox(height: 16),
                _buildTypeSpecificDetailsSection(),
                const SizedBox(height: 16),
                _buildMetadataSection(),
                const SizedBox(height: 24),
              ],

              // Action Buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard() {
    IconData icon;
    Color iconColor;

    switch (widget.paymentMethod.type) {
      case 'bank_account':
        icon = Icons.account_balance;
        iconColor = AppTheme.primaryColor;
        break;
      case 'card':
        icon = Icons.credit_card;
        iconColor = AppTheme.secondaryColor;
        break;
      case 'mobile_money':
        icon = Icons.phone_android;
        iconColor = AppTheme.accentColor;
        break;
      default:
        icon = Icons.payment;
        iconColor = AppTheme.companyInfoColor;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(icon, color: iconColor, size: 40),
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            widget.paymentMethod.name,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Display Name
          Text(
            widget.paymentMethod.displayName,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Type Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getTypeDisplayName(widget.paymentMethod.type),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: iconColor,
                fontFamily: 'Montserrat',
              ),
            ),
          ),

          // Default Badge
          if (widget.paymentMethod.isDefault) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Default Payment Method',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Edit Details',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),

          // Name Field
          CustomTextField(
            controller: _nameController,
            label: 'Payment Method Name',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Default Switch
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Set as Default',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Use this as your default payment method',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isDefault,
                onChanged: (value) => setState(() => _isDefault = value),
                activeColor: AppTheme.primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Save/Cancel buttons (only visible when editing)
        if (_isEditing) ...[
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _cancelEdit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.grey[700],
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],

        // Delete button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _showDeleteConfirmation,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[50],
              foregroundColor: Colors.red[600],
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.red[200]!),
              ),
            ),
            icon: const Icon(Icons.delete_outline),
            label: const Text(
              'Delete Payment Method',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getTypeDisplayName(String type) {
    switch (type) {
      case 'bank_account':
        return 'Bank Account';
      case 'card':
        return 'Credit/Debit Card';
      case 'mobile_money':
        return 'Mobile Money';
      case 'crypto_wallet':
        return 'Crypto Wallet';
      default:
        return 'Payment Method';
    }
  }

  Widget _buildBasicInformationSection() {
    return _buildSection(
      title: 'Basic Information',
      icon: Icons.info_outline,
      children: [
        _buildDetailRow('Payment Method Name', widget.paymentMethod.name),
        _buildDetailRow('Type', _getTypeDisplayName(widget.paymentMethod.type)),
        _buildDetailRow('Display Name', widget.paymentMethod.displayName),
        _buildDetailRow(
          'Default Method',
          widget.paymentMethod.isDefault ? 'Yes' : 'No',
          valueColor: widget.paymentMethod.isDefault ? Colors.green : null,
        ),
        _buildDetailRow(
          'Status',
          widget.paymentMethod.isActive ? 'Active' : 'Inactive',
          valueColor: widget.paymentMethod.isActive ? Colors.green : Colors.red,
        ),
        _buildDetailRow(
          'Verification Status',
          widget.paymentMethod.isVerified ? 'Verified' : 'Not Verified',
          valueColor: widget.paymentMethod.isVerified
              ? Colors.green
              : Colors.orange,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppTheme.primaryColor,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSpecificDetailsSection() {
    final details = widget.paymentMethod.details;
    if (details == null || details.isEmpty) {
      return const SizedBox.shrink();
    }

    IconData sectionIcon;
    String sectionTitle;
    List<Widget> detailRows = [];

    switch (widget.paymentMethod.type) {
      case 'bank_account':
        sectionIcon = Icons.account_balance;
        sectionTitle = 'Bank Account Details';
        detailRows = _buildBankAccountDetails(details);
        break;
      case 'mobile_money':
        sectionIcon = Icons.phone_android;
        sectionTitle = 'Mobile Money Details';
        detailRows = _buildMobileMoneyDetails(details);
        break;
      case 'card':
        sectionIcon = Icons.credit_card;
        sectionTitle = 'Card Details';
        detailRows = _buildCardDetails(details);
        break;
      case 'crypto_wallet':
        sectionIcon = Icons.currency_bitcoin;
        sectionTitle = 'Crypto Wallet Details';
        detailRows = _buildCryptoWalletDetails(details);
        break;
      default:
        sectionIcon = Icons.payment;
        sectionTitle = 'Payment Details';
        detailRows = _buildGenericDetails(details);
    }

    return _buildSection(
      title: sectionTitle,
      icon: sectionIcon,
      children: detailRows,
    );
  }

  List<Widget> _buildBankAccountDetails(Map<String, dynamic> details) {
    List<Widget> rows = [];

    if (details['bank_name'] != null) {
      rows.add(_buildDetailRow('Bank Name', details['bank_name']));
    }
    if (details['account_number'] != null) {
      rows.add(
        _buildDetailRow(
          'Account Number',
          _maskAccountNumber(details['account_number']),
        ),
      );
    }
    if (details['account_name'] != null) {
      rows.add(_buildDetailRow('Account Name', details['account_name']));
    }
    if (details['branch_code'] != null) {
      rows.add(_buildDetailRow('Branch Code', details['branch_code']));
    }

    return rows;
  }

  List<Widget> _buildMobileMoneyDetails(Map<String, dynamic> details) {
    List<Widget> rows = [];

    if (details['provider'] != null) {
      rows.add(_buildDetailRow('Provider', details['provider']));
    }
    if (details['phone_number'] != null) {
      rows.add(
        _buildDetailRow(
          'Phone Number',
          _maskPhoneNumber(details['phone_number']),
        ),
      );
    }
    if (details['account_name'] != null) {
      rows.add(_buildDetailRow('Account Name', details['account_name']));
    }
    if (details['network'] != null) {
      rows.add(_buildDetailRow('Network', details['network']));
    }

    return rows;
  }

  List<Widget> _buildCardDetails(Map<String, dynamic> details) {
    List<Widget> rows = [];

    if (details['card_type'] != null) {
      rows.add(_buildDetailRow('Card Type', details['card_type']));
    }
    if (details['cardholder_name'] != null) {
      rows.add(_buildDetailRow('Cardholder Name', details['cardholder_name']));
    }
    if (details['card_number'] != null) {
      rows.add(
        _buildDetailRow('Card Number', _maskCardNumber(details['card_number'])),
      );
    }

    return rows;
  }

  List<Widget> _buildCryptoWalletDetails(Map<String, dynamic> details) {
    List<Widget> rows = [];

    if (details['currency'] != null) {
      rows.add(_buildDetailRow('Currency', details['currency']));
    }
    if (details['wallet_address'] != null) {
      rows.add(
        _buildDetailRow(
          'Wallet Address',
          _maskWalletAddress(details['wallet_address']),
        ),
      );
    }

    return rows;
  }

  List<Widget> _buildGenericDetails(Map<String, dynamic> details) {
    List<Widget> rows = [];

    details.forEach((key, value) {
      if (value != null) {
        String displayKey = key
            .replaceAll('_', ' ')
            .split(' ')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
        rows.add(_buildDetailRow(displayKey, value.toString()));
      }
    });

    return rows;
  }

  Widget _buildMetadataSection() {
    return _buildSection(
      title: 'Metadata',
      icon: Icons.info,
      children: [
        if (widget.paymentMethod.createdAt != null)
          _buildDetailRow(
            'Created Date',
            DateFormat(
              'MMM dd, yyyy \'at\' hh:mm a',
            ).format(widget.paymentMethod.createdAt!),
          ),
        if (widget.paymentMethod.updatedAt != null)
          _buildDetailRow(
            'Last Updated',
            DateFormat(
              'MMM dd, yyyy \'at\' hh:mm a',
            ).format(widget.paymentMethod.updatedAt!),
          ),
        // _buildDetailRow('Payment Method ID', widget.paymentMethod.id),
      ],
    );
  }

  // Masking methods for sensitive information
  String _maskAccountNumber(String accountNumber) {
    if (accountNumber.length <= 4) return accountNumber;
    return '*' * (accountNumber.length - 4) +
        accountNumber.substring(accountNumber.length - 4);
  }

  String _maskPhoneNumber(String phoneNumber) {
    if (phoneNumber.length <= 4) return phoneNumber;
    return phoneNumber.substring(0, 3) +
        '*' * (phoneNumber.length - 7) +
        phoneNumber.substring(phoneNumber.length - 4);
  }

  String _maskCardNumber(String cardNumber) {
    if (cardNumber.length <= 4) return cardNumber;
    return '*' * (cardNumber.length - 4) +
        cardNumber.substring(cardNumber.length - 4);
  }

  String _maskWalletAddress(String walletAddress) {
    if (walletAddress.length <= 8) return walletAddress;
    return '${walletAddress.substring(0, 6)}...${walletAddress.substring(walletAddress.length - 6)}';
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _nameController.text = widget.paymentMethod.name;
      _isDefault = widget.paymentMethod.isDefault;
    });
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await ref
          .read(userPaymentMethodsProvider.notifier)
          .updatePaymentMethod(
            id: widget.paymentMethod.id,
            name: _nameController.text.trim(),
            isDefault: _isDefault,
          );

      if (mounted) {
        if (success) {
          setState(() => _isEditing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment method updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update payment method'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showDeleteConfirmation() async {
    final confirmed = await ConfirmationDialog.showDestructive(
      context: context,
      title: 'Delete Payment Method',
      message:
          'Are you sure you want to delete "${widget.paymentMethod.name}"?',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      details: 'This action cannot be undone.',
    );

    if (confirmed && mounted) {
      await _deletePaymentMethod();
    }
  }

  Future<void> _deletePaymentMethod() async {
    // Show loading dialog
    LoadingDialogManager.show(
      context: context,
      title: 'Deleting Payment Method',
      message: 'Please wait...',
      icon: Icons.delete,
    );

    try {
      final success = await ref
          .read(userPaymentMethodsProvider.notifier)
          .deletePaymentMethod(widget.paymentMethod.id);

      // Dismiss loading dialog
      LoadingDialogManager.dismiss();

      if (mounted) {
        if (success) {
          await MessageDialog.showSuccess(
            context: context,
            title: 'Payment Method Deleted',
            message:
                '${widget.paymentMethod.name} has been deleted successfully.',
          );
          if (mounted) {
            Navigator.of(context).pop(true); // Return true to indicate deletion
          }
        } else {
          await MessageDialog.showError(
            context: context,
            title: 'Deletion Failed',
            message: 'Failed to delete payment method. Please try again.',
          );
        }
      }
    } catch (e) {
      // Dismiss loading dialog
      LoadingDialogManager.dismiss();

      if (mounted) {
        await MessageDialog.showError(
          context: context,
          title: 'Error',
          message: 'An error occurred while deleting the payment method.',
          details: 'Please check your internet connection and try again.',
        );
      }
    }
  }
}
