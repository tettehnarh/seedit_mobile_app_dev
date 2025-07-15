import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../providers/user_payment_methods_provider.dart';
import '../models/wallet_models.dart';
import '../services/paystack_service.dart';
import '../../investments/providers/fund_subscription_provider.dart';
import '../../investments/providers/investment_provider.dart';
import '../../investments/models/investment_models.dart';

class TopUpScreen extends ConsumerStatefulWidget {
  const TopUpScreen({super.key});

  @override
  ConsumerState<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends ConsumerState<TopUpScreen> {
  final _formKey = GlobalKey<FormState>(debugLabel: 'top_up_form');
  final _amountController = TextEditingController();
  final _paystackService = PaystackService();
  PaymentMethod? _selectedPaymentMethod;
  Fund? _selectedFund;
  bool _isLoading = false;

  // Goal context data
  String? _goalId;
  String? _goalName;
  bool _fromGoalReminder = false;

  // Static manual payment method to avoid creating new instances
  static final PaymentMethod _manualPaymentMethod = PaymentMethod(
    id: 'manual',
    name: 'Manual Payment',
    displayName: 'Manual Payment (Bank Transfer/Mobile Money)',
    type: 'manual',
    isDefault: false,
    details: {},
  );

  @override
  void initState() {
    super.initState();
    // Load payment methods when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userPaymentMethodsProvider.notifier).loadPaymentMethods();
      ref.read(fundSubscriptionProvider.notifier).loadAllSubscriptions();

      // Check if context was passed from navigation (fund or goal)
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          // Handle fund context
          if (args['fund'] != null) {
            _selectedFund = args['fund'] as Fund;
          }

          // Handle goal context from reminder
          if (args['fromGoalReminder'] == true) {
            _fromGoalReminder = true;
            _goalId = args['goalId'] as String?;
            _goalName = args['goalName'] as String?;

            // Pre-fill suggested amount if provided
            if (args['suggestedAmount'] != null) {
              final suggestedAmount = args['suggestedAmount'] as double;
              _amountController.text = suggestedAmount.toStringAsFixed(2);
            }

            // Set fund from goal context if available
            if (args['linkedFundId'] != null &&
                args['linkedFundName'] != null) {
              // Create a temporary fund object for display
              _selectedFund = Fund(
                id: args['linkedFundId'] as String,
                name: args['linkedFundName'] as String,
                description: '',
                minimumInvestment: 0.0,
                currentPrice: 1.0,
                returnRate: 0.0,
                riskLevel: 'medium',
                category: 'general',
                isActive: true,
                createdAt: DateTime.now(),
                totalAssets: 0.0,
                managementFee: 0.0,
                inceptionDate: DateTime.now(),
              );
            }
          }
        });
      }

      // Force refresh portfolio data to ensure latest investment totals
      ref.read(forceRefreshPortfolioProvider)();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paymentMethods = ref.watch(userPaymentMethodsListProvider);
    final isLoadingPaymentMethods = ref.watch(
      userPaymentMethodsLoadingProvider,
    );
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _fromGoalReminder && _goalName != null
              ? 'Top Up for $_goalName'
              : _selectedFund != null
              ? 'Top Up ${_selectedFund!.name}'
              : 'Top Up Investment',
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
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Balance Card
              _buildCurrentBalanceCard(),
              const SizedBox(height: 24),

              // Fund Selection Section
              _buildFundSelectionSection(),
              const SizedBox(height: 24),

              // Amount Input Section
              _buildAmountInputSection(),
              const SizedBox(height: 24),

              // Payment Method Selection
              _buildPaymentMethodSection(
                paymentMethods,
                isLoadingPaymentMethods,
              ),
              const SizedBox(height: 32),

              // Continue Button
              _buildContinueButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Investments',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Consumer(
            builder: (context, ref, child) {
              final totalInvested = ref.watch(totalInvestedProvider);
              return Text(
                CurrencyFormatter.formatAmountWithCurrency(totalInvested),
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          const Text(
            'Across all funds',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFundSelectionSection() {
    final subscriptions = ref.watch(fundSubscriptionProvider).subscriptions;
    final subscribedFunds = subscriptions.values
        .where((subscription) => subscription.isSubscribed)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Fund to Top Up',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        if (subscribedFunds.isEmpty)
          _buildNoSubscribedFundsCard()
        else if (subscribedFunds.length == 1)
          _buildSingleFundCard(subscribedFunds.first)
        else
          _buildFundSelectionDropdown(subscribedFunds),
      ],
    );
  }

  Widget _buildNoSubscribedFundsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(Icons.info_outline, size: 48, color: Colors.blue[400]),
          const SizedBox(height: 12),
          const Text(
            'No Fund Subscriptions',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.companyInfoColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You need to subscribe to a fund before making top-ups. This will add to your wallet balance instead.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              color: AppTheme.companyInfoColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleFundCard(FundSubscription subscription) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.trending_up,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subscription.fundName,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Current Investment: ${CurrencyFormatter.formatAmountWithCurrency(subscription.totalInvested)}',
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    color: AppTheme.companyInfoColor,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle,
            color: AppTheme.primaryColor,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildFundSelectionDropdown(List<FundSubscription> subscribedFunds) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<FundSubscription>(
        value: _selectedFund != null
            ? subscribedFunds.firstWhere(
                (sub) => sub.fundId == _selectedFund!.id,
                orElse: () => subscribedFunds.first,
              )
            : subscribedFunds.first,
        decoration: InputDecoration(
          labelText: 'Select Fund to Top Up',
          labelStyle: const TextStyle(
            fontFamily: 'Montserrat',
            color: AppTheme.companyInfoColor,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.primaryColor),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        items: subscribedFunds.map((subscription) {
          return DropdownMenuItem<FundSubscription>(
            value: subscription,
            child: Text(
              subscription.fundName,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (FundSubscription? value) {
          if (value != null) {
            setState(() {
              // Convert FundSubscription to Fund for consistency
              _selectedFund = Fund(
                id: value.fundId,
                name: value.fundName,
                description: '',
                minimumInvestment: value.minimumInvestment,
                currentPrice: 0.0,
                returnRate: 0.0,
                riskLevel: 'medium',
                category: 'general',
                totalAssets: 0.0,
                managementFee: 0.0,
                inceptionDate: DateTime.now(),
              );
            });
          }
        },
      ),
    );
  }

  Widget _buildAmountInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter Amount',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: CustomTextField(
            controller: _amountController,
            label: 'Amount (GHS)',
            hint: '0.00',
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(
              Icons.attach_money,
              color: AppTheme.primaryColor,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an amount';
              }
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return 'Please enter a valid amount';
              }
              if (amount < 10) {
                return 'Minimum top-up amount is GHS 10';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {}); // Refresh UI when amount changes
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSection(
    List<PaymentMethod> paymentMethods,
    bool isLoading,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Method',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        if (isLoading)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            ),
          )
        else if (paymentMethods.isEmpty)
          _buildAddPaymentMethodPrompt()
        else
          _buildPaymentMethodDropdown(paymentMethods),
      ],
    );
  }

  Widget _buildAddPaymentMethodPrompt() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(Icons.payment, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          const Text(
            'No payment methods available',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.companyInfoColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add a payment method to continue',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              color: AppTheme.companyInfoColor,
            ),
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Add Payment Method',
            onPressed: () {
              Navigator.pushNamed(context, '/wallet/add');
            },
            backgroundColor: AppTheme.primaryColor,
            textColor: Colors.white,
            height: 40,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodDropdown(List<PaymentMethod> paymentMethods) {
    // Create ordered list: Manual Payment, Default method, Other methods
    // Ensure no duplicates by checking IDs
    final orderedMethods = <PaymentMethod>[
      _manualPaymentMethod,
      ...paymentMethods.where(
        (method) => method.isDefault && method.id != 'manual',
      ),
      ...paymentMethods.where(
        (method) => !method.isDefault && method.id != 'manual',
      ),
    ];

    // Ensure selected payment method exists in the list or reset it
    PaymentMethod? validSelectedMethod;
    if (_selectedPaymentMethod != null) {
      // Find the exact instance from orderedMethods that matches the selected method
      try {
        validSelectedMethod = orderedMethods.firstWhere(
          (method) => method.id == _selectedPaymentMethod!.id,
        );
      } catch (e) {
        // If no match found, don't set any value (will show placeholder)
        validSelectedMethod = null;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<PaymentMethod>(
          value: validSelectedMethod,
          isExpanded: true,
          hint: const Text(
            'Select payment method',
            style: TextStyle(fontSize: 14, fontFamily: 'Montserrat'),
          ),
          items: orderedMethods.map((method) {
            return DropdownMenuItem<PaymentMethod>(
              value: method,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 250),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getPaymentMethodIcon(method.type),
                      color: method.type == 'manual'
                          ? Colors.orange[600]!
                          : AppTheme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            method.displayName.isNotEmpty
                                ? method.displayName
                                : method.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          if (method.isDefault)
                            Text(
                              'Default',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.primaryColor,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (method.isVerified)
                      Icon(Icons.verified, color: Colors.green[600], size: 16),
                  ],
                ),
              ),
            );
          }).toList(),
          onChanged: (PaymentMethod? value) {
            setState(() {
              _selectedPaymentMethod = value;
            });
          },
        ),
      ),
    );
  }

  IconData _getPaymentMethodIcon(String type) {
    switch (type) {
      case 'bank_account':
        return Icons.account_balance;
      case 'card':
        return Icons.credit_card;
      case 'mobile_money':
        return Icons.phone_android;
      case 'manual':
        return Icons.receipt_long;
      default:
        return Icons.payment;
    }
  }

  Widget _buildContinueButton() {
    final canProceed =
        _amountController.text.isNotEmpty &&
        _selectedPaymentMethod != null &&
        _selectedFund != null &&
        !_isLoading;

    return Column(
      children: [
        CustomButton(
          text: _isLoading ? 'Processing...' : 'Continue to Payment',
          onPressed: canProceed ? _handleContinue : null,
          backgroundColor: AppTheme.primaryColor,
          textColor: Colors.white,
          height: 56,
          borderRadius: 12,
          isLoading: _isLoading,
        ),
        // Platform fee message for non-manual payment methods
        if (_selectedPaymentMethod != null &&
            _selectedPaymentMethod!.type != 'manual')
          _buildPlatformFeeMessage(),
      ],
    );
  }

  Widget _buildPlatformFeeMessage() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final platformFee = amount * 0.015; // 1.5% platform fee
    final totalAmount = amount + platformFee;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'Platform Fee Notice',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'A platform fee of 1.5% will be added to your payment amount.',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 13,
              color: Colors.orange[700],
            ),
          ),
          if (amount > 0) ...[
            const SizedBox(height: 8),
            Text(
              'Investment Amount: GHS ${amount.toStringAsFixed(2)}\n'
              'Platform Fee (1.5%): GHS ${platformFee.toStringAsFixed(2)}\n'
              'Total to Pay: GHS ${totalAmount.toStringAsFixed(2)}',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12,
                color: Colors.orange[700],
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _handleContinue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = double.parse(_amountController.text);

      // Calculate total amount including platform fee for non-manual payments
      final isManualPayment = _selectedPaymentMethod!.type == 'manual';
      final platformFee = isManualPayment
          ? 0.0
          : amount * 0.015; // 1.5% platform fee
      final totalAmount = amount + platformFee;

      // Initialize Paystack payment for investment top-up
      final result = await _paystackService.initializePayment(
        fundId: _selectedFund!.id,
        amount: amount, // Original investment amount
        paymentMethodId: _selectedPaymentMethod!.id,
        totalAmount: totalAmount, // Total amount including platform fee
      );

      if (mounted) {
        if (result['success'] == true) {
          // Navigate to Paystack WebView for payment
          Navigator.pushNamed(
            context,
            '/paystack-payment',
            arguments: {
              'authorization_url': result['data']['authorization_url'],
              'reference': result['data']['reference'],
              'amount': amount,
              'fund_name': _selectedFund!.name,
              'transaction_type': 'investment_top_up',
            },
          );
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Failed to initialize payment'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing top-up: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
