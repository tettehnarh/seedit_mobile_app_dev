import 'package:flutter/material.dart';
import '../../../shared/models/fund_model.dart';
import '../../../shared/models/wallet_model.dart';

class InvestmentSummaryCard extends StatelessWidget {
  final InvestmentFund fund;
  final double amount;
  final double units;
  final PaymentMethod? paymentMethod;

  const InvestmentSummaryCard({
    super.key,
    required this.fund,
    required this.amount,
    required this.units,
    this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.summarize,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Investment Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Investment details
            _buildSummaryRow('Fund', fund.name),
            const SizedBox(height: 8),
            _buildSummaryRow('Investment Amount', '₦${amount.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            _buildSummaryRow('NAV per Unit', '₦${fund.currentNAV.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            _buildSummaryRow('Units to Purchase', units.toStringAsFixed(4)),
            
            if (paymentMethod != null) ...[
              const SizedBox(height: 8),
              _buildSummaryRow('Payment Method', _getPaymentMethodText(paymentMethod!)),
            ],
            
            const SizedBox(height: 16),
            
            // Fees breakdown
            _buildFeesSection(),
            
            const SizedBox(height: 16),
            
            const Divider(),
            
            const SizedBox(height: 8),
            
            // Total
            _buildSummaryRow(
              'Total Amount',
              '₦${_calculateTotalAmount().toStringAsFixed(2)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black : Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal ? Colors.black : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildFeesSection() {
    final managementFee = amount * (fund.managementFee / 100);
    final processingFee = _calculateProcessingFee();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fees & Charges',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        _buildSummaryRow(
          'Management Fee (${fund.managementFee}%)',
          '₦${managementFee.toStringAsFixed(2)}',
        ),
        const SizedBox(height: 4),
        _buildSummaryRow(
          'Processing Fee',
          '₦${processingFee.toStringAsFixed(2)}',
        ),
      ],
    );
  }

  double _calculateProcessingFee() {
    // Calculate processing fee based on payment method
    switch (paymentMethod) {
      case PaymentMethod.wallet:
        return 0.0; // No fee for wallet
      case PaymentMethod.bankTransfer:
        return 50.0; // Fixed fee for bank transfer
      case PaymentMethod.card:
        return amount * 0.015; // 1.5% for card payments
      case PaymentMethod.mobileMoney:
        return amount * 0.01; // 1% for mobile money
      default:
        return 0.0;
    }
  }

  double _calculateTotalAmount() {
    final managementFee = amount * (fund.managementFee / 100);
    final processingFee = _calculateProcessingFee();
    return amount + managementFee + processingFee;
  }

  String _getPaymentMethodText(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.wallet:
        return 'SeedIt Wallet';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.card:
        return 'Debit/Credit Card';
      case PaymentMethod.mobileMoney:
        return 'Mobile Money';
      case PaymentMethod.directDebit:
        return 'Direct Debit';
    }
  }
}

class InvestmentConfirmationCard extends StatelessWidget {
  final InvestmentFund fund;
  final double amount;
  final double units;
  final PaymentMethod paymentMethod;
  final String orderReference;
  final DateTime orderDate;

  const InvestmentConfirmationCard({
    super.key,
    required this.fund,
    required this.amount,
    required this.units,
    required this.paymentMethod,
    required this.orderReference,
    required this.orderDate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success header
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green.shade600,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Placed Successfully',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                        Text(
                          'Reference: $orderReference',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Order details
            _buildDetailRow('Fund', fund.name),
            const SizedBox(height: 8),
            _buildDetailRow('Investment Amount', '₦${amount.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            _buildDetailRow('Units Purchased', units.toStringAsFixed(4)),
            const SizedBox(height: 8),
            _buildDetailRow('NAV per Unit', '₦${fund.currentNAV.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            _buildDetailRow('Payment Method', _getPaymentMethodText(paymentMethod)),
            const SizedBox(height: 8),
            _buildDetailRow('Order Date', _formatDate(orderDate)),
            
            const SizedBox(height: 16),
            
            // Next steps
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What happens next?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Your payment will be processed within 24 hours\n'
                    '• Units will be allocated at the next NAV\n'
                    '• You will receive a confirmation email\n'
                    '• Investment will appear in your portfolio',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
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

  String _getPaymentMethodText(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.wallet:
        return 'SeedIt Wallet';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.card:
        return 'Debit/Credit Card';
      case PaymentMethod.mobileMoney:
        return 'Mobile Money';
      case PaymentMethod.directDebit:
        return 'Direct Debit';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class InvestmentCalculatorCard extends StatefulWidget {
  final InvestmentFund fund;
  final Function(double amount, double units) onCalculationChanged;

  const InvestmentCalculatorCard({
    super.key,
    required this.fund,
    required this.onCalculationChanged,
  });

  @override
  State<InvestmentCalculatorCard> createState() => _InvestmentCalculatorCardState();
}

class _InvestmentCalculatorCardState extends State<InvestmentCalculatorCard> {
  final _amountController = TextEditingController();
  final _unitsController = TextEditingController();
  bool _isCalculatingFromAmount = true;

  @override
  void dispose() {
    _amountController.dispose();
    _unitsController.dispose();
    super.dispose();
  }

  void _calculateFromAmount(String value) {
    if (value.isEmpty) {
      _unitsController.clear();
      widget.onCalculationChanged(0, 0);
      return;
    }

    final amount = double.tryParse(value.replaceAll(',', ''));
    if (amount != null) {
      final units = amount / widget.fund.currentNAV;
      _unitsController.text = units.toStringAsFixed(4);
      widget.onCalculationChanged(amount, units);
    }
  }

  void _calculateFromUnits(String value) {
    if (value.isEmpty) {
      _amountController.clear();
      widget.onCalculationChanged(0, 0);
      return;
    }

    final units = double.tryParse(value);
    if (units != null) {
      final amount = units * widget.fund.currentNAV;
      _amountController.text = amount.toStringAsFixed(2);
      widget.onCalculationChanged(amount, units);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Investment Calculator',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Amount (₦)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      if (_isCalculatingFromAmount) {
                        _calculateFromAmount(value);
                      }
                    },
                    onTap: () {
                      setState(() {
                        _isCalculatingFromAmount = true;
                      });
                    },
                  ),
                ),
                
                const SizedBox(width: 16),
                
                Icon(
                  Icons.swap_horiz,
                  color: Colors.grey[600],
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: TextFormField(
                    controller: _unitsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Units',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      if (!_isCalculatingFromAmount) {
                        _calculateFromUnits(value);
                      }
                    },
                    onTap: () {
                      setState(() {
                        _isCalculatingFromAmount = false;
                      });
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Text(
              'Current NAV: ₦${widget.fund.currentNAV.toStringAsFixed(2)} per unit',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
