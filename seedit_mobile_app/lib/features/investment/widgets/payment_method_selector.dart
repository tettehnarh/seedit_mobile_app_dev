import 'package:flutter/material.dart';
import '../../../shared/models/wallet_model.dart';

class PaymentMethodSelector extends StatelessWidget {
  final List<PaymentMethod> paymentMethods;
  final PaymentMethod? selectedMethod;
  final Function(PaymentMethod) onMethodSelected;

  const PaymentMethodSelector({
    super.key,
    required this.paymentMethods,
    this.selectedMethod,
    required this.onMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Add wallet as default option
    final allMethods = [
      PaymentMethod.wallet,
      PaymentMethod.bankTransfer,
      PaymentMethod.card,
      PaymentMethod.mobileMoney,
    ];

    return Column(
      children: allMethods.map((method) {
        final isSelected = selectedMethod == method;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: PaymentMethodCard(
            method: method,
            isSelected: isSelected,
            onTap: () => onMethodSelected(method),
          ),
        );
      }).toList(),
    );
  }
}

class PaymentMethodCard extends StatelessWidget {
  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentMethodCard({
    super.key,
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected 
              ? Theme.of(context).primaryColor 
              : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Payment method icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getMethodColor(method).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getMethodIcon(method),
                  color: _getMethodColor(method),
                  size: 20,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Method details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getMethodName(method),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getMethodDescription(method),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (_getMethodFee(method).isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        _getMethodFee(method),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.orange[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Selection indicator
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                )
              else
                Icon(
                  Icons.radio_button_unchecked,
                  color: Colors.grey[400],
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.wallet:
        return Icons.account_balance_wallet;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance;
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.mobileMoney:
        return Icons.phone_android;
      case PaymentMethod.directDebit:
        return Icons.sync;
    }
  }

  Color _getMethodColor(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.wallet:
        return Colors.blue;
      case PaymentMethod.bankTransfer:
        return Colors.green;
      case PaymentMethod.card:
        return Colors.purple;
      case PaymentMethod.mobileMoney:
        return Colors.orange;
      case PaymentMethod.directDebit:
        return Colors.teal;
    }
  }

  String _getMethodName(PaymentMethod method) {
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

  String _getMethodDescription(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.wallet:
        return 'Pay instantly from your SeedIt wallet balance';
      case PaymentMethod.bankTransfer:
        return 'Transfer from your bank account';
      case PaymentMethod.card:
        return 'Pay with your debit or credit card';
      case PaymentMethod.mobileMoney:
        return 'Pay with mobile money (MTN, Airtel, etc.)';
      case PaymentMethod.directDebit:
        return 'Automatic deduction from your account';
    }
  }

  String _getMethodFee(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.wallet:
        return 'No fees';
      case PaymentMethod.bankTransfer:
        return 'Fee: ₦50';
      case PaymentMethod.card:
        return 'Fee: 1.5%';
      case PaymentMethod.mobileMoney:
        return 'Fee: 1.0%';
      case PaymentMethod.directDebit:
        return 'No fees';
    }
  }
}

class PaymentMethodBottomSheet extends StatefulWidget {
  final List<PaymentMethod> paymentMethods;
  final PaymentMethod? selectedMethod;
  final Function(PaymentMethod) onMethodSelected;

  const PaymentMethodBottomSheet({
    super.key,
    required this.paymentMethods,
    this.selectedMethod,
    required this.onMethodSelected,
  });

  @override
  State<PaymentMethodBottomSheet> createState() => _PaymentMethodBottomSheetState();
}

class _PaymentMethodBottomSheetState extends State<PaymentMethodBottomSheet> {
  PaymentMethod? _selectedMethod;

  @override
  void initState() {
    super.initState();
    _selectedMethod = widget.selectedMethod;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Payment Method',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          const Divider(),

          // Payment methods
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                PaymentMethod.wallet,
                PaymentMethod.bankTransfer,
                PaymentMethod.card,
                PaymentMethod.mobileMoney,
              ].map((method) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PaymentMethodCard(
                    method: method,
                    isSelected: _selectedMethod == method,
                    onTap: () {
                      setState(() {
                        _selectedMethod = method;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Confirm button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedMethod != null
                    ? () {
                        widget.onMethodSelected(_selectedMethod!);
                        Navigator.of(context).pop();
                      }
                    : null,
                child: const Text('Confirm Selection'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentMethodChip extends StatelessWidget {
  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentMethodChip({
    super.key,
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      avatar: Icon(
        _getMethodIcon(method),
        size: 16,
        color: isSelected ? Colors.white : _getMethodColor(method),
      ),
      label: Text(
        _getMethodName(method),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : _getMethodColor(method),
        ),
      ),
      selected: isSelected,
      selectedColor: _getMethodColor(method),
      backgroundColor: _getMethodColor(method).withOpacity(0.1),
      side: BorderSide(
        color: isSelected ? _getMethodColor(method) : _getMethodColor(method).withOpacity(0.3),
      ),
      onSelected: (_) => onTap(),
    );
  }

  IconData _getMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.wallet:
        return Icons.account_balance_wallet;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance;
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.mobileMoney:
        return Icons.phone_android;
      case PaymentMethod.directDebit:
        return Icons.sync;
    }
  }

  Color _getMethodColor(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.wallet:
        return Colors.blue;
      case PaymentMethod.bankTransfer:
        return Colors.green;
      case PaymentMethod.card:
        return Colors.purple;
      case PaymentMethod.mobileMoney:
        return Colors.orange;
      case PaymentMethod.directDebit:
        return Colors.teal;
    }
  }

  String _getMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.wallet:
        return 'Wallet';
      case PaymentMethod.bankTransfer:
        return 'Bank';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.mobileMoney:
        return 'Mobile';
      case PaymentMethod.directDebit:
        return 'Direct Debit';
    }
  }
}
