import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_theme.dart';
import '../models/investment_models.dart';
import '../../wallet/models/wallet_models.dart';
import '../providers/investment_provider.dart';
import '../providers/fund_subscription_provider.dart';

class PaymentSummaryScreen extends ConsumerStatefulWidget {
  final Fund fund;
  final double amount;
  final String paymentMethod; // 'wallet' or 'invoice'
  final PaymentMethod? wallet;

  const PaymentSummaryScreen({
    super.key,
    required this.fund,
    required this.amount,
    required this.paymentMethod,
    this.wallet,
  });

  @override
  ConsumerState<PaymentSummaryScreen> createState() =>
      _PaymentSummaryScreenState();
}

class _PaymentSummaryScreenState extends ConsumerState<PaymentSummaryScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Payment Summary',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFundDetails(),
                  const SizedBox(height: 24),
                  _buildInvestmentDetails(),
                  const SizedBox(height: 24),
                  _buildPaymentMethodDetails(),
                  const SizedBox(height: 24),
                  _buildAmountBreakdown(),
                ],
              ),
            ),
          ),
          _buildBottomSection(),
        ],
      ),
    );
  }

  Widget _buildFundDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fund Details',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Fund Name', widget.fund.name),
          _buildDetailRow(
            'Minimum Investment',
            'GHS ${widget.fund.minimumInvestment.toStringAsFixed(2)}',
          ),
          _buildDetailRow(
            'Expected Return',
            '${widget.fund.returnRate.toStringAsFixed(1)}% annually',
          ),
          _buildDetailRow('Risk Level', widget.fund.riskLevel),
        ],
      ),
    );
  }

  Widget _buildInvestmentDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Investment Details',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            'Investment Amount',
            'GHS ${widget.amount.toStringAsFixed(2)}',
          ),
          _buildDetailRow('Investment Date', _formatDate(DateTime.now())),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Method',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          if (widget.paymentMethod == 'invoice') ...[
            _buildDetailRow('Payment Type', 'Manual Payment/Bank Transfer'),
            _buildDetailRow('Status', 'Invoice will be generated'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: const Text(
                'An invoice will be generated with payment instructions. You can pay via bank transfer or mobile money.',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: Colors.blue,
                ),
              ),
            ),
          ] else ...[
            _buildDetailRow('Payment Type', 'Saved Payment Method'),
            _buildDetailRow('Method', widget.wallet?.displayName ?? 'Unknown'),
            if (widget.wallet?.isDefault == true)
              _buildDetailRow('Status', 'Default Payment Method'),
          ],
        ],
      ),
    );
  }

  Widget _buildAmountBreakdown() {
    // Only show platform fee for non-manual payment methods
    final showPlatformFee = widget.paymentMethod != 'invoice';
    final platformFee = showPlatformFee
        ? widget.amount * 0.015
        : 0.0; // 1.5% platform fee
    final totalAmount = widget.amount + platformFee;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Amount Breakdown',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            'Investment Amount',
            'GHS ${widget.amount.toStringAsFixed(2)}',
          ),
          if (showPlatformFee) ...[
            _buildDetailRow(
              'Platform Fee (1.5%)',
              'GHS ${platformFee.toStringAsFixed(2)}',
            ),
            const Divider(height: 24),
            _buildDetailRow(
              'Total Amount',
              'GHS ${totalAmount.toStringAsFixed(2)}',
              isTotal: true,
            ),
          ] else ...[
            const Divider(height: 24),
            _buildDetailRow(
              'Total Amount',
              'GHS ${widget.amount.toStringAsFixed(2)}',
              isTotal: true,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.green[600],
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No platform fee for manual payments',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
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

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
                color: isTotal ? AppTheme.primaryColor : Colors.grey[700],
              ),
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
                color: isTotal ? AppTheme.primaryColor : Colors.black87,
              ),
              textAlign: TextAlign.right,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _processPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
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
                : const Text(
                    'Confirm & Proceed',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Create the investment through the investment provider
      final success = await ref
          .read(investmentProvider.notifier)
          .investInFund(widget.fund.id, widget.amount);

      if (success) {
        // Refresh subscription status after successful investment
        await ref
            .read(fundSubscriptionProvider.notifier)
            .refreshSubscriptionAfterInvestment(widget.fund.id);

        if (widget.paymentMethod == 'invoice') {
          _showSuccessDialog(
            'Invoice Generated',
            'Your investment invoice has been generated. Check your email for payment instructions.',
          );
        } else {
          _showSuccessDialog(
            'Investment Successful',
            'Your investment has been processed successfully. You are now subscribed to this fund.',
          );
        }
      } else {
        _showErrorDialog(
          'Investment Failed',
          'There was an error processing your investment. Please try again.',
        );
      }
    } catch (e) {
      _showErrorDialog(
        'Payment Failed',
        'There was an error processing your payment. Please try again.',
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to previous screen
              Navigator.of(context).pop(); // Go back to fund details
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
