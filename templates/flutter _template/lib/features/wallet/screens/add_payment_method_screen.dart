import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import '../../../core/utils/app_theme.dart';
import '../services/paystack_service.dart';

class AddPaymentMethodScreen extends ConsumerStatefulWidget {
  const AddPaymentMethodScreen({super.key});

  @override
  ConsumerState<AddPaymentMethodScreen> createState() =>
      _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState
    extends ConsumerState<AddPaymentMethodScreen> {
  final _formKey = GlobalKey<FormState>(debugLabel: 'add_payment_method_form');
  final PaystackService _paystackService = PaystackService();

  String _selectedType = 'mobile_money';
  bool _isLoading = false;
  bool _isDefault = false;

  // Form controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  String _selectedMobileProvider = 'mtn';
  List<String> _existingNames = [];

  @override
  void initState() {
    super.initState();
    _loadExistingPaymentMethods();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _accountNumberController.dispose();
    _bankNameController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingPaymentMethods() async {
    try {
      final result = await _paystackService.getUserPaymentMethods();
      if (result['success'] && result['data'] != null) {
        final paymentMethods = result['data'] as List;
        setState(() {
          _existingNames = paymentMethods
              .map((pm) => pm.name?.toString() ?? '')
              .where((name) => name.isNotEmpty)
              .toList();
        });
      }
    } catch (e) {
      developer.log('Error loading existing payment methods: $e');
    }
  }

  String _generateSuggestedName(String baseName) {
    if (!_existingNames.contains(baseName)) {
      return baseName;
    }

    int counter = 1;
    String suggestedName;
    do {
      suggestedName = '$baseName $counter';
      counter++;
    } while (_existingNames.contains(suggestedName) && counter <= 10);

    return suggestedName;
  }

  Future<void> _savePaymentMethod() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> details = {};

      switch (_selectedType) {
        case 'mobile_money':
          details = {
            'phone_number': _phoneController.text.trim(),
            'provider': _selectedMobileProvider,
          };
          break;
        case 'bank_account':
          details = {
            'account_number': _accountNumberController.text.trim(),
            'bank_name': _bankNameController.text.trim(),
          };
          break;
        case 'card':
          details = {
            'card_number': _cardNumberController.text.trim(),
            'expiry_date': _expiryController.text.trim(),
            'cvv': _cvvController.text.trim(),
          };
          break;
      }

      final result = await _paystackService.createUserPaymentMethod(
        name: _nameController.text.trim(),
        methodType: _selectedType,
        details: details,
        isDefault: _isDefault,
      );

      if (result['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment method added successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true); // Return true to indicate success
        }
      } else {
        String errorMessage = result['error'] ?? 'Failed to add payment method';

        // If it's a duplicate name error, suggest an alternative
        if (errorMessage.toLowerCase().contains(
              'already have a payment method',
            ) ||
            errorMessage.toLowerCase().contains('duplicate')) {
          final suggestedName = _generateSuggestedName(
            _nameController.text.trim(),
          );
          _showDuplicateNameDialog(suggestedName);
        } else {
          _showErrorSnackBar(errorMessage);
        }
      }
    } catch (e) {
      developer.log('Error adding payment method: $e');
      _showErrorSnackBar('An error occurred while adding the payment method');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  void _showDuplicateNameDialog(String suggestedName) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Duplicate Name',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'You already have a payment method with this name.',
                style: TextStyle(fontFamily: 'Montserrat'),
              ),
              const SizedBox(height: 16),
              Text(
                'Suggested name: "$suggestedName"',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(fontFamily: 'Montserrat', color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _nameController.text = suggestedName;
                });
              },
              child: const Text(
                'Use Suggestion',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Add Payment Method',
          style: TextStyle(
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
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Payment Method Type Selection
                    const Text(
                      'Payment Method Type',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPaymentTypeSelector(),
                    const SizedBox(height: 24),

                    // Payment Method Name
                    const Text(
                      'Payment Method Name',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'e.g., My MTN Mobile Money',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a name for this payment method';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Payment Method Details
                    _buildPaymentMethodDetails(),

                    const SizedBox(height: 24),

                    // Set as Default
                    Row(
                      children: [
                        Checkbox(
                          value: _isDefault,
                          onChanged: (value) {
                            setState(() {
                              _isDefault = value ?? false;
                            });
                          },
                          activeColor: AppTheme.primaryColor,
                        ),
                        const Expanded(
                          child: Text(
                            'Set as default payment method',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Save Button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    offset: const Offset(0, -2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _savePaymentMethod,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Add Payment Method',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentTypeSelector() {
    return Column(
      children: [
        _buildPaymentTypeOption(
          'mobile_money',
          'Mobile Money',
          'MTN, Vodafone, AirtelTigo',
          Icons.phone_android,
          Colors.orange,
        ),
        const SizedBox(height: 12),
        _buildPaymentTypeOption(
          'bank_account',
          'Bank Account',
          'Direct bank transfer',
          Icons.account_balance,
          Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildPaymentTypeOption(
          'card',
          'Debit/Credit Card',
          'Visa, Mastercard',
          Icons.credit_card,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildPaymentTypeOption(
    String value,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedType == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.primaryColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodDetails() {
    switch (_selectedType) {
      case 'mobile_money':
        return _buildMobileMoneyDetails();
      case 'bank_account':
        return _buildBankAccountDetails();
      case 'card':
        return _buildCardDetails();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMobileMoneyDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mobile Money Details',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 12),

        // Provider Selection
        const Text(
          'Provider',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedMobileProvider,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryColor),
            ),
          ),
          items: const [
            DropdownMenuItem(value: 'mtn', child: Text('MTN Mobile Money')),
            DropdownMenuItem(value: 'vodafone', child: Text('Vodafone Cash')),
            DropdownMenuItem(
              value: 'airteltigo',
              child: Text('AirtelTigo Money'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _selectedMobileProvider = value!;
            });
          },
        ),
        const SizedBox(height: 16),

        // Phone Number
        const Text(
          'Phone Number',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: 'e.g., +233241234567',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryColor),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your phone number';
            }
            if (!RegExp(r'^\+233\d{9}$').hasMatch(value.trim())) {
              return 'Please enter a valid Ghana phone number (+233xxxxxxxxx)';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBankAccountDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bank Account Details',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 12),

        // Bank Name
        const Text(
          'Bank Name',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _bankNameController,
          decoration: InputDecoration(
            hintText: 'e.g., Ghana Commercial Bank',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryColor),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter the bank name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Account Number
        const Text(
          'Account Number',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _accountNumberController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter your account number',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryColor),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your account number';
            }
            if (value.trim().length < 10) {
              return 'Account number must be at least 10 digits';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCardDetails() {
    return const Text(
      'Card payment coming soon',
      style: TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 14,
        color: Colors.grey,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
