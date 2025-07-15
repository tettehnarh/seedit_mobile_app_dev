import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_theme.dart';
import '../services/settings_service.dart';

class PaymentMethodsScreen extends ConsumerStatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  ConsumerState<PaymentMethodsScreen> createState() =>
      _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends ConsumerState<PaymentMethodsScreen> {
  List<Map<String, dynamic>> _paymentMethods = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    try {
      final settingsService = SettingsService();
      final methods = await settingsService.getPaymentMethods();

      setState(() {
        _paymentMethods = methods;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        // Provide fallback payment methods if API fails
        _paymentMethods = _getFallbackPaymentMethods();
      });
    }
  }

  List<Map<String, dynamic>> _getFallbackPaymentMethods() {
    return [
      {
        'id': '1',
        'type': 'bank_transfer',
        'name': 'Bank Transfer',
        'description': 'Transfer money directly from your bank account',
        'icon': Icons.account_balance,
        'is_enabled': true,
        'processing_time': '1-2 business days',
        'fees': 'Free',
      },
      {
        'id': '2',
        'type': 'mobile_money',
        'name': 'Mobile Money',
        'description':
            'Pay using MTN Mobile Money, Vodafone Cash, or AirtelTigo Money',
        'icon': Icons.phone_android,
        'is_enabled': true,
        'processing_time': 'Instant',
        'fees': '1.5% + GHS 1',
      },
      {
        'id': '3',
        'type': 'card',
        'name': 'Debit/Credit Card',
        'description': 'Pay with your Visa or Mastercard',
        'icon': Icons.credit_card,
        'is_enabled': true,
        'processing_time': 'Instant',
        'fees': '2.5%',
      },
      {
        'id': '4',
        'type': 'paypal',
        'name': 'PayPal',
        'description': 'Pay using your PayPal account',
        'icon': Icons.payment,
        'is_enabled': false,
        'processing_time': 'Instant',
        'fees': '3.5%',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Payment Methods',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Choose your preferred payment method for deposits and withdrawals.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue[700],
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Available Payment Methods
                  const Text(
                    'Available Payment Methods',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment Methods List
                  ...(_paymentMethods
                      .map((method) => _buildPaymentMethodCard(method))
                      .toList()),
                ],
              ),
            ),
    );
  }

  Widget _buildPaymentMethodCard(Map<String, dynamic> method) {
    final isEnabled = method['is_enabled'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isEnabled
                ? AppTheme.primaryColor.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            method['icon'] ?? Icons.payment,
            color: isEnabled ? AppTheme.primaryColor : Colors.grey,
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                method['name'] ?? '',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isEnabled ? AppTheme.primaryColor : Colors.grey,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
            if (!isEnabled)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Coming Soon',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[700],
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              method['description'] ?? '',
              style: TextStyle(
                fontSize: 14,
                color: isEnabled ? AppTheme.companyInfoColor : Colors.grey,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildInfoChip(
                  'Processing: ${method['processing_time'] ?? 'N/A'}',
                  isEnabled,
                ),
                const SizedBox(width: 8),
                _buildInfoChip('Fees: ${method['fees'] ?? 'N/A'}', isEnabled),
              ],
            ),
          ],
        ),
        trailing: isEnabled
            ? Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.companyInfoColor,
              )
            : null,
        onTap: isEnabled
            ? () {
                _showPaymentMethodDetails(method);
              }
            : null,
      ),
    );
  }

  Widget _buildInfoChip(String text, bool isEnabled) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isEnabled
            ? AppTheme.primaryColor.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: isEnabled ? AppTheme.primaryColor : Colors.grey,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showPaymentMethodDetails(Map<String, dynamic> method) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              method['name'] ?? '',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              method['description'] ?? '',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.companyInfoColor,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 24),

            // Details
            _buildDetailRow(
              'Processing Time',
              method['processing_time'] ?? 'N/A',
            ),
            _buildDetailRow('Fees', method['fees'] ?? 'N/A'),
            const SizedBox(height: 24),

            // Action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${method['name']} setup coming soon!'),
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Set Up Payment Method',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.companyInfoColor,
              fontFamily: 'Montserrat',
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }
}
