import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import '../../../core/utils/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../providers/groups_provider.dart';
import '../models/group_models.dart';
import '../../wallet/providers/user_payment_methods_provider.dart';
import '../../wallet/models/wallet_models.dart';
import '../../wallet/screens/add_payment_method_screen.dart';
import '../../wallet/screens/paystack_webview_screen.dart';
import '../services/groups_service.dart';
import '../../../core/api/api_client.dart';

class GroupContributionScreen extends ConsumerStatefulWidget {
  final InvestmentGroup group;

  const GroupContributionScreen({super.key, required this.group});

  @override
  ConsumerState<GroupContributionScreen> createState() =>
      _GroupContributionScreenState();
}

class _GroupContributionScreenState
    extends ConsumerState<GroupContributionScreen> {
  late final _formKey = GlobalKey<FormState>(
    debugLabel: 'contribution_form_${widget.group.id}',
  );
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _groupsService = GroupsService(ApiClient());

  String? _selectedPaymentMethodId;
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Contribute to Group',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Group Info Card
              _buildGroupInfoCard(),
              const SizedBox(height: 20),

              // Contribution restriction warning
              if (!widget.group.canContribute)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_outlined,
                        color: Colors.red[700],
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Contribution Not Available',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[700],
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.group.contributionStatusMessage,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.red[600],
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Contribution Form
              _buildContributionForm(),
              const SizedBox(height: 32),

              // Submit Button
              Consumer(
                builder: (context, ref, child) {
                  final paymentMethodsState = ref.watch(
                    userPaymentMethodsProvider,
                  );
                  final hasPaymentMethods =
                      paymentMethodsState.paymentMethods.isNotEmpty;
                  final canSubmit =
                      !_isLoading &&
                      widget.group.canContribute &&
                      hasPaymentMethods &&
                      _selectedPaymentMethodId != null;

                  // Get selected payment method to show platform fee message
                  PaymentMethod? selectedPaymentMethod;
                  if (_selectedPaymentMethodId != null) {
                    try {
                      selectedPaymentMethod = paymentMethodsState.paymentMethods
                          .firstWhere(
                            (method) => method.id == _selectedPaymentMethodId,
                          );
                    } catch (e) {
                      // Payment method not found, ignore
                    }
                  }

                  return Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: _isLoading
                              ? 'PROCESSING...'
                              : !hasPaymentMethods
                              ? 'ADD PAYMENT METHOD FIRST'
                              : 'CONTRIBUTE',
                          onPressed: canSubmit ? _submitContribution : null,
                          backgroundColor: canSubmit
                              ? AppTheme.primaryColor
                              : Colors.grey[400]!,
                          height: 50,
                        ),
                      ),
                      // Platform fee message for non-manual payment methods
                      if (selectedPaymentMethod != null &&
                          selectedPaymentMethod.type != 'manual')
                        _buildPlatformFeeMessage(),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.group,
                  color: AppTheme.primaryColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.group.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.group.memberCount} members',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress Info
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Target Amount',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    Text(
                      CurrencyFormatter.formatAmount(widget.group.targetAmount),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Progress',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    Text(
                      '${widget.group.progressPercentage.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress Bar
          LinearProgressIndicator(
            value: widget.group.progressPercentage / 100,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildContributionForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contribution Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 20),

          // Amount Field
          CustomTextField(
            controller: _amountController,
            label: 'Contribution Amount (GHS)',
            hint: 'Enter amount to contribute',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Contribution amount is required';
              }
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return 'Please enter a valid amount';
              }
              if (widget.group.minimumContribution != null &&
                  amount < widget.group.minimumContribution!) {
                return 'Minimum contribution is ${CurrencyFormatter.formatAmount(widget.group.minimumContribution!)}';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Payment Method Selection
          _buildPaymentMethodSection(),

          const SizedBox(height: 16),

          // Note Field
          CustomTextField(
            controller: _noteController,
            label: 'Note (Optional)',
            hint: 'Add a note for this contribution',
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  /// Build payment method selection section
  Widget _buildPaymentMethodSection() {
    final paymentMethodsState = ref.watch(userPaymentMethodsProvider);
    final paymentMethods = paymentMethodsState.paymentMethods;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
                fontFamily: 'Montserrat',
              ),
            ),
            const Spacer(),
            if (paymentMethods.isEmpty)
              TextButton.icon(
                onPressed: () => _navigateToAddPaymentMethod(),
                icon: const Icon(Icons.add, size: 16),
                label: const Text(
                  'Add Method',
                  style: TextStyle(fontSize: 12, fontFamily: 'Montserrat'),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        if (paymentMethodsState.isLoading)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text(
                  'Loading payment methods...',
                  style: TextStyle(fontSize: 14, fontFamily: 'Montserrat'),
                ),
              ],
            ),
          )
        else if (paymentMethodsState.errorMessage != null)
          _buildPaymentMethodsErrorState(paymentMethodsState.errorMessage!)
        else if (paymentMethods.isEmpty)
          _buildEmptyPaymentMethodsState()
        else
          _buildPaymentMethodDropdown(paymentMethods),
      ],
    );
  }

  /// Build payment methods error state
  Widget _buildPaymentMethodsErrorState(String errorMessage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red[300]!),
        borderRadius: BorderRadius.circular(12),
        color: Colors.red[50],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red[700], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Error loading payment methods',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.red[700],
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: TextStyle(
              fontSize: 12,
              color: Colors.red[600],
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'RETRY',
              onPressed: () {
                ref
                    .read(userPaymentMethodsProvider.notifier)
                    .loadPaymentMethods();
              },
              backgroundColor: Colors.red[600]!,
              height: 36,
            ),
          ),
        ],
      ),
    );
  }

  /// Build empty payment methods state
  Widget _buildEmptyPaymentMethodsState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange[300]!),
        borderRadius: BorderRadius.circular(12),
        color: Colors.orange[50],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.payment, color: Colors.orange[700], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'No payment methods found',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[700],
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Add a payment method to contribute to this group',
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange[600],
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'ADD PAYMENT METHOD',
              onPressed: _navigateToAddPaymentMethod,
              backgroundColor: Colors.orange[600]!,
              height: 36,
            ),
          ),
        ],
      ),
    );
  }

  /// Build payment method dropdown
  Widget _buildPaymentMethodDropdown(List<PaymentMethod> paymentMethods) {
    // Set default selection if not set
    if (_selectedPaymentMethodId == null && paymentMethods.isNotEmpty) {
      _selectedPaymentMethodId = paymentMethods.first.id;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPaymentMethodId,
          isExpanded: true,
          hint: const Text(
            'Select payment method',
            style: TextStyle(fontSize: 14, fontFamily: 'Montserrat'),
          ),
          onChanged: (value) =>
              setState(() => _selectedPaymentMethodId = value),
          items: paymentMethods.map((method) {
            return DropdownMenuItem<String>(
              value: method.id,
              child: Row(
                children: [
                  _getPaymentMethodIcon(method.type),
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
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Get payment method icon based on type
  Widget _getPaymentMethodIcon(String type) {
    IconData iconData;
    Color iconColor;

    switch (type.toLowerCase()) {
      case 'bank_account':
        iconData = Icons.account_balance;
        iconColor = Colors.blue[600]!;
        break;
      case 'mobile_money':
        iconData = Icons.phone_android;
        iconColor = Colors.green[600]!;
        break;
      case 'card':
        iconData = Icons.credit_card;
        iconColor = Colors.purple[600]!;
        break;
      case 'crypto_wallet':
        iconData = Icons.currency_bitcoin;
        iconColor = Colors.orange[600]!;
        break;
      default:
        iconData = Icons.payment;
        iconColor = Colors.grey[600]!;
    }

    return Icon(iconData, color: iconColor, size: 20);
  }

  /// Navigate to add payment method screen
  Future<void> _navigateToAddPaymentMethod() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPaymentMethodScreen()),
    );

    // Refresh payment methods if a new one was added
    if (result == true) {
      ref.read(userPaymentMethodsProvider.notifier).loadPaymentMethods();
    }
  }

  Future<void> _submitContribution() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if group can still accept contributions
    if (!widget.group.canContribute) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.group.contributionStatusMessage),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if payment method is selected
    if (_selectedPaymentMethodId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final amount = double.parse(_amountController.text.trim());

      // Get selected payment method to determine if it's manual
      final paymentMethodsState = ref.read(userPaymentMethodsProvider);
      final selectedPaymentMethod = paymentMethodsState.paymentMethods
          .firstWhere((method) => method.id == _selectedPaymentMethodId);

      final isManualPayment = selectedPaymentMethod.type == 'manual';

      if (isManualPayment) {
        // Handle manual payment (existing flow)
        await _handleManualContribution(amount);
      } else {
        // Handle Paystack payment
        await _handlePaystackContribution(amount, selectedPaymentMethod);
      }
    } catch (e) {
      developer.log('❌ Error submitting contribution: $e', error: e);
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

  Future<void> _handleManualContribution(double amount) async {
    final contributionData = {
      'amount': amount.toString(),
      'payment_method_id': _selectedPaymentMethodId,
      'note': _noteController.text.trim().isNotEmpty
          ? _noteController.text.trim()
          : null,
    };

    final success = await ref
        .read(groupsProvider.notifier)
        .contributeToGroup(widget.group.id, contributionData);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contribution submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        final error = ref.read(groupsProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Failed to submit contribution'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handlePaystackContribution(
    double amount,
    PaymentMethod paymentMethod,
  ) async {
    // Calculate total amount including platform fee (1.5%)
    final platformFee = amount * 0.015; // 1.5% platform fee
    final totalAmount = amount + platformFee;

    // Initialize Paystack payment for group contribution
    final result = await _groupsService.initializeGroupContributionPayment(
      groupId: widget.group.id,
      contributionAmount: amount, // Original contribution amount
      paymentMethodId: paymentMethod.id,
      totalAmount: totalAmount, // Total amount including platform fee
    );

    if (mounted) {
      if (result['success'] == true) {
        // Navigate to Paystack WebView for payment
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaystackWebViewScreen(
              authorizationUrl: result['data']['authorization_url'],
              reference: result['data']['reference'],
              transactionId: result['data']['contribution_id'],
              paymentType: 'group_contribution', // Specify payment type
              onPaymentComplete: (paymentData) {
                _handlePaymentSuccess(paymentData);
              },
              onPaymentCancelled: () {
                _handlePaymentCancelled();
              },
            ),
          ),
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
  }

  void _handlePaymentSuccess(Map<String, dynamic> paymentData) {
    developer.log(
      '🔍 [GROUP_CONTRIBUTION_DEBUG] ===== HANDLING PAYMENT SUCCESS =====',
    );
    developer.log('🔍 [GROUP_CONTRIBUTION_DEBUG] Payment data: $paymentData');
    developer.log('🔍 [GROUP_CONTRIBUTION_DEBUG] Widget mounted: $mounted');
    developer.log('✅ Group contribution payment completed: $paymentData');

    if (mounted) {
      try {
        developer.log(
          '🔄 [GROUP_CONTRIBUTION_DEBUG] Showing success snackbar...',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Group contribution payment successful!'),
            backgroundColor: Colors.green,
          ),
        );
        developer.log('✅ [GROUP_CONTRIBUTION_DEBUG] Success snackbar shown');

        // Refresh group data asynchronously to avoid blocking UI
        developer.log(
          '🔄 [GROUP_CONTRIBUTION_DEBUG] Starting async group data refresh...',
        );
        _refreshGroupDataAsync();

        // Return to previous screen
        developer.log(
          '🔄 [GROUP_CONTRIBUTION_DEBUG] Navigating back to previous screen...',
        );
        Navigator.pop(context, true); // Return true to indicate success
        developer.log(
          '✅ [GROUP_CONTRIBUTION_DEBUG] Navigation completed successfully',
        );
      } catch (e) {
        developer.log(
          '❌ [GROUP_CONTRIBUTION_DEBUG] Error in payment success handler: $e',
        );
        developer.log(
          '❌ [GROUP_CONTRIBUTION_DEBUG] Error type: ${e.runtimeType}',
        );
        developer.log(
          '❌ [GROUP_CONTRIBUTION_DEBUG] Stack trace: ${StackTrace.current}',
        );

        // Still try to navigate back even if there's an error
        if (mounted) {
          developer.log(
            '🔄 [GROUP_CONTRIBUTION_DEBUG] Attempting fallback navigation...',
          );
          try {
            Navigator.pop(context, true);
            developer.log(
              '✅ [GROUP_CONTRIBUTION_DEBUG] Fallback navigation successful',
            );
          } catch (navError) {
            developer.log(
              '❌ [GROUP_CONTRIBUTION_DEBUG] Fallback navigation failed: $navError',
            );
          }
        }
      }
    } else {
      developer.log(
        '⚠️ [GROUP_CONTRIBUTION_DEBUG] Widget not mounted, skipping UI updates',
      );
    }
  }

  void _refreshGroupDataAsync() async {
    developer.log(
      '🔄 [GROUP_CONTRIBUTION_DEBUG] Starting group data refresh...',
    );
    try {
      await ref.read(groupsProvider.notifier).refreshGroups();
      developer.log(
        '✅ [GROUP_CONTRIBUTION_DEBUG] Group data refreshed successfully',
      );
    } catch (e) {
      developer.log(
        '❌ [GROUP_CONTRIBUTION_DEBUG] Error refreshing group data: $e',
      );
      developer.log(
        '❌ [GROUP_CONTRIBUTION_DEBUG] Error type: ${e.runtimeType}',
      );
      // Don't show error to user as payment was successful
    }
  }

  void _handlePaymentCancelled() {
    developer.log('❌ Group contribution payment cancelled');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment cancelled'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Widget _buildPlatformFeeMessage() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange[700], size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Platform Fee',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[700],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'A platform fee of 1.5% will be added to your contribution amount.',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 11,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
