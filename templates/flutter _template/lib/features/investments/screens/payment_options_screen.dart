import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import '../../../core/utils/app_theme.dart';
import '../../../core/api/api_client.dart';

import '../models/investment_models.dart';
import '../../wallet/models/wallet_models.dart';
import '../../wallet/providers/wallet_provider.dart';

class PaymentOptionsScreen extends ConsumerStatefulWidget {
  final Fund fund;
  final double amount;
  final PaymentMethod? wallet;

  const PaymentOptionsScreen({
    super.key,
    required this.fund,
    required this.amount,
    this.wallet,
  });

  @override
  ConsumerState<PaymentOptionsScreen> createState() =>
      _PaymentOptionsScreenState();
}

class _PaymentOptionsScreenState extends ConsumerState<PaymentOptionsScreen> {
  String _selectedPaymentOption = 'wallet'; // 'wallet' or 'invoice'
  bool _isProcessing = false;
  String? _invoiceReference;

  void _selectPaymentOption(String option) {
    setState(() {
      _selectedPaymentOption = option;
    });
  }

  Future<void> _processWalletPayment() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate wallet payment processing
      await Future.delayed(const Duration(seconds: 2));

      // Check if wallet has sufficient balance
      final walletBalance = ref.read(availableBalanceProvider);

      if (walletBalance < widget.amount) {
        _showInsufficientFundsDialog();
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      // Process payment
      final success = await ref
          .read(walletProvider.notifier)
          .withdrawFunds(widget.amount, widget.wallet?.id ?? '');

      if (success) {
        setState(() {
          _isProcessing = false;
        });
        _showPaymentSuccessDialog();
      } else {
        _showPaymentErrorDialog();
        setState(() {
          _isProcessing = false;
        });
      }
    } catch (e) {
      _showPaymentErrorDialog();
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _generateInvoice() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      developer.log(
        'Generating invoice for fund: ${widget.fund.name}, amount: ${widget.amount}',
      );

      // Call backend API to generate invoice
      final apiClient = ApiClient();
      final response = await apiClient.post('/api/payments/generate-invoice/', {
        'amount': widget.amount.toString(),
        'description': 'Investment in ${widget.fund.name}',
        'metadata': {
          'fund_id': widget.fund.id,
          'fund_name': widget.fund.name,
          'investment_type': 'fund_investment',
        },
      });

      if (response['reference'] != null) {
        setState(() {
          _invoiceReference = response['reference'];
          _isProcessing = false;
        });

        developer.log('Invoice generated successfully: $_invoiceReference');

        // Add transaction to recent transactions
        await _addInvoiceTransaction();

        _showInvoiceGeneratedDialog();
      } else {
        throw Exception('Invalid response from server');
      }
    } catch (e) {
      developer.log('Error generating invoice: $e');
      setState(() {
        _isProcessing = false;
      });
      _showInvoiceErrorDialog();
    }
  }

  Future<void> _addInvoiceTransaction() async {
    try {
      // Add the invoice as a pending transaction
      // Note: This would need to be implemented in the transaction provider
      // For now, we'll just log it
      developer.log('Invoice transaction would be added: $_invoiceReference');

      // TODO: Implement proper transaction addition in TransactionProvider
      // await ref.read(transactionProvider.notifier).addPendingTransaction({
      //   'type': 'investment',
      //   'amount': widget.amount,
      //   'description': 'Investment in ${widget.fund.name} (Invoice: $_invoiceReference)',
      //   'status': 'pending_payment',
      //   'fund_name': widget.fund.name,
      //   'payment_method': 'Manual Invoice',
      //   'reference': _invoiceReference,
      // });

      developer.log('Invoice transaction logged for future implementation');
    } catch (e) {
      developer.log('Error adding invoice transaction: $e');
      // Don't fail the whole process if transaction addition fails
    }
  }

  void _showInsufficientFundsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Insufficient Funds',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ),
        content: const Text(
          'Your wallet does not have sufficient balance for this investment. Please top up your wallet or choose the invoice payment option.',
          style: TextStyle(fontFamily: 'Montserrat', fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            const Text(
              'Payment Successful!',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your investment of GHS ${widget.amount.toStringAsFixed(2)} in ${widget.fund.name} has been processed successfully.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                color: AppTheme.companyInfoColor,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.popUntil(
                  context,
                  (route) => route.isFirst,
                ); // Go to home
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Payment Failed',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ),
        content: const Text(
          'There was an error processing your payment. Please try again or contact support.',
          style: TextStyle(fontFamily: 'Montserrat', fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInvoiceErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Invoice Generation Failed',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ),
        content: const Text(
          'There was an error generating your invoice. Please try again or contact support.',
          style: TextStyle(fontFamily: 'Montserrat', fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInvoiceGeneratedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Invoice Generated',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Invoice Reference',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      color: AppTheme.companyInfoColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _invoiceReference!,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(text: _invoiceReference!),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Reference copied to clipboard'),
                              backgroundColor: AppTheme.primaryColor,
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.copy,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Payment Instructions:',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Bank Transfer: Standard Bank Ghana\n• Account: 1234567890\n• Mobile Money: MTN +233123456789\n• Use invoice reference as payment reference\n• Send payment proof to support@investiture.com',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12,
                color: AppTheme.companyInfoColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your investment will be processed once payment is confirmed.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.popUntil(
                  context,
                  (route) => route.isFirst,
                ); // Go to home
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletBalance = ref.watch(availableBalanceProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Payment Options',
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
      body: Column(
        children: [
          // Investment Summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
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
                  'Investment Summary',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSummaryRow('Fund:', widget.fund.name),
                _buildSummaryRow(
                  'Amount:',
                  'GHS ${widget.amount.toStringAsFixed(2)}',
                ),
                _buildSummaryRow(
                  'Payment Method:',
                  widget.wallet?.displayName ?? 'Manual Payment',
                ),
                if (_selectedPaymentOption == 'wallet')
                  _buildSummaryRow(
                    'Available Balance:',
                    'GHS ${walletBalance.toStringAsFixed(2)}',
                    valueColor: walletBalance >= widget.amount
                        ? Colors.green
                        : Colors.red,
                  ),
              ],
            ),
          ),

          // Payment Options
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choose Payment Method',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Wallet Payment Option
                  _buildPaymentOption(
                    'wallet',
                    'Pay from Wallet',
                    'Use your available wallet balance',
                    Icons.account_balance_wallet,
                    walletBalance >= widget.amount,
                  ),
                  const SizedBox(height: 12),

                  // Invoice Payment Option
                  _buildPaymentOption(
                    'invoice',
                    'Generate Invoice',
                    'Get an invoice to pay manually',
                    Icons.receipt_long,
                    true,
                  ),
                ],
              ),
            ),
          ),

          // Action Button
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
                onPressed: _isProcessing
                    ? null
                    : (_selectedPaymentOption == 'wallet'
                          ? _processWalletPayment
                          : _generateInvoice),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _selectedPaymentOption == 'wallet'
                            ? 'Pay Now'
                            : 'Generate Invoice',
                        style: const TextStyle(
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
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
    String value,
    String title,
    String subtitle,
    IconData icon,
    bool isEnabled,
  ) {
    final isSelected = _selectedPaymentOption == value;

    return GestureDetector(
      onTap: isEnabled ? () => _selectPaymentOption(value) : null,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isEnabled ? Colors.white : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected && isEnabled
                ? AppTheme.primaryColor
                : Colors.grey.shade300,
            width: isSelected && isEnabled ? 2 : 1,
          ),
          boxShadow: isSelected && isEnabled
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected && isEnabled
                    ? AppTheme.primaryColor
                    : (isEnabled ? Colors.grey.shade100 : Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected && isEnabled
                    ? Colors.white
                    : (isEnabled ? Colors.grey.shade600 : Colors.grey.shade400),
                size: 24,
              ),
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
                      color: isEnabled
                          ? (isSelected
                                ? AppTheme.primaryColor
                                : AppTheme.primaryColor)
                          : Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      color: isEnabled
                          ? Colors.grey.shade600
                          : Colors.grey.shade400,
                    ),
                  ),
                  if (!isEnabled && value == 'wallet') ...[
                    const SizedBox(height: 4),
                    const Text(
                      'Insufficient balance',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected && isEnabled)
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
}
