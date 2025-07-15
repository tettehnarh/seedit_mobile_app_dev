import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_theme.dart';
import '../providers/user_payment_methods_provider.dart';

class WalletAddScreen extends ConsumerStatefulWidget {
  const WalletAddScreen({super.key});

  @override
  ConsumerState<WalletAddScreen> createState() => _WalletAddScreenState();
}

class _WalletAddScreenState extends ConsumerState<WalletAddScreen> {
  final _formKey = GlobalKey<FormState>(debugLabel: 'wallet_add_form');
  final _nameController = TextEditingController();

  String _selectedType = 'bank_account';
  bool _isDefault = false;
  bool _isLoading = false;

  // Bank Account fields
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountNameController = TextEditingController();

  // Mobile Money fields
  final _providerController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  // Card fields
  final _cardNumberController = TextEditingController();
  final _cardTypeController = TextEditingController();
  final _cardholderNameController = TextEditingController();

  // Crypto Wallet fields
  final _currencyController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountNameController.dispose();
    _providerController.dispose();
    _phoneNumberController.dispose();
    _cardNumberController.dispose();
    _cardTypeController.dispose();
    _cardholderNameController.dispose();
    _currencyController.dispose();
    _addressController.dispose();
    super.dispose();
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payment Method Type Selection
              _buildTypeSelectionCard(),
              const SizedBox(height: 24),

              // Basic Information
              _buildBasicInfoCard(),
              const SizedBox(height: 24),

              // Type-specific fields
              _buildTypeSpecificFields(),
              const SizedBox(height: 32),

              // Save Button
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelectionCard() {
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
            'Payment Method Type',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),

          // Type options
          ...ref
              .read(userPaymentMethodsProvider.notifier)
              .getAvailableTypes()
              .map((type) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedType = type['type']!;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _selectedType == type['type']
                            ? AppTheme.primaryColor.withValues(alpha: 0.1)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedType == type['type']
                              ? AppTheme.primaryColor
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getTypeIcon(type['type']!),
                            color: _selectedType == type['type']
                                ? AppTheme.primaryColor
                                : Colors.grey.shade600,
                            size: 24,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  type['name']!,
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: _selectedType == type['type']
                                        ? AppTheme.primaryColor
                                        : Colors.grey.shade800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  type['description']!,
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_selectedType == type['type'])
                            const Icon(
                              Icons.check_circle,
                              color: AppTheme.primaryColor,
                              size: 24,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard() {
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
            'Basic Information',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),

          // Name field
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Payment Method Name',
              hintText: 'e.g., My Primary Bank Account',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primaryColor),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a name for this payment method';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Default checkbox
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
    );
  }

  Widget _buildTypeSpecificFields() {
    switch (_selectedType) {
      case 'bank_account':
        return _buildBankAccountFields();
      case 'mobile_money':
        return _buildMobileMoneyFields();
      case 'card':
        return _buildCardFields();
      case 'crypto_wallet':
        return _buildCryptoWalletFields();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBankAccountFields() {
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
            'Bank Account Details',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),

          // Bank Name
          TextFormField(
            controller: _bankNameController,
            decoration: InputDecoration(
              labelText: 'Bank Name',
              hintText: 'e.g., Standard Bank',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primaryColor),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the bank name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Account Number
          TextFormField(
            controller: _accountNumberController,
            decoration: InputDecoration(
              labelText: 'Account Number',
              hintText: 'Enter your account number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primaryColor),
              ),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the account number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Account Name
          TextFormField(
            controller: _accountNameController,
            decoration: InputDecoration(
              labelText: 'Account Name',
              hintText: 'Name on the account',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primaryColor),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the account name';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMobileMoneyFields() {
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
            'Mobile Money Details',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),

          // Provider
          DropdownButtonFormField<String>(
            value: _providerController.text.isEmpty
                ? null
                : _providerController.text,
            decoration: InputDecoration(
              labelText: 'Provider',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primaryColor),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'MTN', child: Text('MTN Mobile Money')),
              DropdownMenuItem(value: 'Vodafone', child: Text('Vodafone Cash')),
              DropdownMenuItem(
                value: 'AirtelTigo',
                child: Text('AirtelTigo Money'),
              ),
            ],
            onChanged: (value) {
              _providerController.text = value ?? '';
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a provider';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Phone Number
          TextFormField(
            controller: _phoneNumberController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              hintText: '+233123456789',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primaryColor),
              ),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Account Name
          TextFormField(
            controller: _accountNameController,
            decoration: InputDecoration(
              labelText: 'Account Name',
              hintText: 'Name registered with mobile money',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primaryColor),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the account name';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCardFields() {
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
            'Card Details',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),

          // Card Type
          DropdownButtonFormField<String>(
            value: _cardTypeController.text.isEmpty
                ? null
                : _cardTypeController.text,
            decoration: InputDecoration(
              labelText: 'Card Type',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primaryColor),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'Visa', child: Text('Visa')),
              DropdownMenuItem(value: 'Mastercard', child: Text('Mastercard')),
              DropdownMenuItem(
                value: 'American Express',
                child: Text('American Express'),
              ),
            ],
            onChanged: (value) {
              _cardTypeController.text = value ?? '';
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a card type';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Card Number
          TextFormField(
            controller: _cardNumberController,
            decoration: InputDecoration(
              labelText: 'Card Number',
              hintText: '1234 5678 9012 3456',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primaryColor),
              ),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the card number';
              }
              if (value.length < 13) {
                return 'Card number must be at least 13 digits';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Cardholder Name
          TextFormField(
            controller: _cardholderNameController,
            decoration: InputDecoration(
              labelText: 'Cardholder Name',
              hintText: 'Name on the card',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primaryColor),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the cardholder name';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoWalletFields() {
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
            'Crypto Wallet Details',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),

          // Currency
          DropdownButtonFormField<String>(
            value: _currencyController.text.isEmpty
                ? null
                : _currencyController.text,
            decoration: InputDecoration(
              labelText: 'Currency',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primaryColor),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'Bitcoin', child: Text('Bitcoin (BTC)')),
              DropdownMenuItem(
                value: 'Ethereum',
                child: Text('Ethereum (ETH)'),
              ),
              DropdownMenuItem(value: 'USDT', child: Text('Tether (USDT)')),
              DropdownMenuItem(value: 'USDC', child: Text('USD Coin (USDC)')),
            ],
            onChanged: (value) {
              _currencyController.text = value ?? '';
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a currency';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Wallet Address
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: 'Wallet Address',
              hintText: 'Enter your wallet address',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primaryColor),
              ),
            ),
            maxLines: 2,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the wallet address';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
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
                'Save Payment Method',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Future<void> _savePaymentMethod() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final details = _buildDetailsMap();

      final success = await ref
          .read(userPaymentMethodsProvider.notifier)
          .createPaymentMethod(
            name: _nameController.text.trim(),
            type: _selectedType,
            details: details,
            isDefault: _isDefault,
          );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment method added successfully'),
              backgroundColor: AppTheme.primaryColor,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          final error = ref.read(userPaymentMethodsErrorProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error ?? 'Failed to add payment method'),
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
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Map<String, dynamic> _buildDetailsMap() {
    switch (_selectedType) {
      case 'bank_account':
        return {
          'bank_name': _bankNameController.text.trim(),
          'account_number': _accountNumberController.text.trim(),
          'account_name': _accountNameController.text.trim(),
        };
      case 'mobile_money':
        return {
          'provider': _providerController.text.trim(),
          'phone_number': _phoneNumberController.text.trim(),
          'account_name': _accountNameController.text.trim(),
        };
      case 'card':
        return {
          'card_type': _cardTypeController.text.trim(),
          'card_number': _cardNumberController.text.trim(),
          'cardholder_name': _cardholderNameController.text.trim(),
        };
      case 'crypto_wallet':
        return {
          'currency': _currencyController.text.trim(),
          'address': _addressController.text.trim(),
        };
      default:
        return {};
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'bank_account':
        return Icons.account_balance;
      case 'mobile_money':
        return Icons.phone_android;
      case 'card':
        return Icons.credit_card;
      case 'crypto_wallet':
        return Icons.currency_bitcoin;
      default:
        return Icons.payment;
    }
  }
}
