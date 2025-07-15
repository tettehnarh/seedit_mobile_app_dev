import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/fund_model.dart';
import '../../../shared/models/wallet_model.dart';
import '../../../shared/providers/investment_provider.dart';
import '../../../shared/providers/fund_provider.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../widgets/investment_summary_card.dart';
import '../widgets/payment_method_selector.dart';

class InvestmentOrderScreen extends ConsumerStatefulWidget {
  final String fundId;

  const InvestmentOrderScreen({
    super.key,
    required this.fundId,
  });

  @override
  ConsumerState<InvestmentOrderScreen> createState() => _InvestmentOrderScreenState();
}

class _InvestmentOrderScreenState extends ConsumerState<InvestmentOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  
  PaymentMethod? _selectedPaymentMethod;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPaymentMethod == null) {
      _showError('Please select a payment method');
      return;
    }
    if (!_agreedToTerms) {
      _showError('Please agree to the terms and conditions');
      return;
    }

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    final amount = double.tryParse(_amountController.text.replaceAll(',', ''));
    if (amount == null) return;

    // Check wallet balance if using wallet
    if (_selectedPaymentMethod == PaymentMethod.wallet) {
      final hasBalance = await ref.read(investmentStateProvider.notifier)
          .checkWalletBalance(currentUser.id, amount);
      
      if (!hasBalance) {
        _showError('Insufficient wallet balance');
        return;
      }
    }

    final order = await ref.read(investmentStateProvider.notifier)
        .createInvestmentOrder(
          userId: currentUser.id,
          fundId: widget.fundId,
          amount: amount,
          paymentMethod: _selectedPaymentMethod!,
          notes: _notesController.text.trim().isNotEmpty 
              ? _notesController.text.trim() 
              : null,
        );

    if (order != null && mounted) {
      context.push('/investment/order/${order.id}/confirmation');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fund = ref.watch(fundByIdProvider(widget.fundId));
    final wallet = ref.watch(userWalletProvider);
    final paymentMethods = ref.watch(userPaymentMethodsProvider);
    final investmentState = ref.watch(investmentStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Place Investment Order'),
        elevation: 0,
      ),
      body: fund.when(
        data: (fundData) {
          if (fundData == null) {
            return const Center(
              child: Text('Fund not found'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fund information
                  _buildFundInfoCard(fundData),
                  
                  const SizedBox(height: 24),
                  
                  // Investment amount
                  _buildInvestmentAmountSection(fundData),
                  
                  const SizedBox(height: 24),
                  
                  // Payment method
                  _buildPaymentMethodSection(paymentMethods),
                  
                  const SizedBox(height: 24),
                  
                  // Wallet balance (if available)
                  wallet.when(
                    data: (walletData) {
                      if (walletData != null) {
                        return _buildWalletBalanceCard(walletData);
                      }
                      return const SizedBox.shrink();
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Investment summary
                  _buildInvestmentSummary(fundData),
                  
                  const SizedBox(height: 24),
                  
                  // Notes
                  _buildNotesSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Terms and conditions
                  _buildTermsAndConditions(),
                  
                  const SizedBox(height: 32),
                  
                  // Place order button
                  CustomButton(
                    text: investmentState.isLoading ? 'Processing...' : 'Place Order',
                    onPressed: investmentState.isLoading ? null : _placeOrder,
                    isLoading: investmentState.isLoading,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Error display
                  if (investmentState.error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade600),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              investmentState.error!,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              ref.read(investmentStateProvider.notifier).clearError();
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(fundByIdProvider(widget.fundId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFundInfoCard(InvestmentFund fund) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fund.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              fund.shortDescription,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoItem('NAV', '₦${fund.currentNAV.toStringAsFixed(2)}'),
                const SizedBox(width: 24),
                _buildInfoItem('Min. Investment', fund.formattedTotalAssets),
                const SizedBox(width: 24),
                _buildInfoItem('Risk Level', fund.riskLevelText),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildInvestmentAmountSection(InvestmentFund fund) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Investment Amount',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _CurrencyInputFormatter(),
          ],
          decoration: InputDecoration(
            labelText: 'Amount (₦)',
            hintText: 'Enter investment amount',
            prefixText: '₦ ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            helperText: 'Min: ₦${fund.minimumInvestment.toStringAsFixed(0)} | Max: ₦${fund.maximumInvestment.toStringAsFixed(0)}',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter an amount';
            }
            
            final amount = double.tryParse(value.replaceAll(',', ''));
            if (amount == null) {
              return 'Please enter a valid amount';
            }
            
            if (amount < fund.minimumInvestment) {
              return 'Amount must be at least ₦${fund.minimumInvestment.toStringAsFixed(0)}';
            }
            
            if (amount > fund.maximumInvestment) {
              return 'Amount cannot exceed ₦${fund.maximumInvestment.toStringAsFixed(0)}';
            }
            
            return null;
          },
          onChanged: (value) {
            setState(() {}); // Trigger rebuild for summary
          },
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSection(AsyncValue<List<PaymentMethod>> paymentMethods) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Method',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        paymentMethods.when(
          data: (methods) => PaymentMethodSelector(
            paymentMethods: methods,
            selectedMethod: _selectedPaymentMethod,
            onMethodSelected: (method) {
              setState(() {
                _selectedPaymentMethod = method;
              });
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Text('Error loading payment methods: $error'),
        ),
      ],
    );
  }

  Widget _buildWalletBalanceCard(Wallet wallet) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.account_balance_wallet,
              color: Colors.blue.shade600,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Wallet Balance',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    wallet.formattedAvailableBalance,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                context.push('/wallet/deposit');
              },
              child: const Text('Add Funds'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvestmentSummary(InvestmentFund fund) {
    final amount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0.0;
    final units = amount > 0 ? amount / fund.currentNAV : 0.0;

    return InvestmentSummaryCard(
      fund: fund,
      amount: amount,
      units: units,
      paymentMethod: _selectedPaymentMethod,
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notes (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Add any notes about this investment...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsAndConditions() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _agreedToTerms,
          onChanged: (value) {
            setState(() {
              _agreedToTerms = value ?? false;
            });
          },
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _agreedToTerms = !_agreedToTerms;
              });
            },
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87),
                children: [
                  const TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms and Conditions',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final int newTextLength = newValue.text.length;
    int selectionIndex = newValue.selection.end;
    int usedSubstringIndex = 0;
    final StringBuffer newText = StringBuffer();

    // Remove any existing commas
    final String digitsOnly = newValue.text.replaceAll(',', '');
    
    // Add commas every three digits from the right
    final String reversed = digitsOnly.split('').reversed.join('');
    for (int i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) {
        newText.write(',');
        if (i < selectionIndex) {
          selectionIndex++;
        }
      }
      newText.write(reversed[i]);
    }

    final String formatted = newText.toString().split('').reversed.join('');

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: formatted.length,
      ),
    );
  }
}
