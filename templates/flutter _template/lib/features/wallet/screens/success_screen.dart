import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/custom_button.dart';
import '../models/wallet_models.dart';

class SuccessScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> transactionData;

  const SuccessScreen({super.key, required this.transactionData});

  @override
  ConsumerState<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends ConsumerState<SuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkmarkController;
  late AnimationController _fadeController;
  late Animation<double> _checkmarkAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _checkmarkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _checkmarkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkmarkController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Start animations
    _checkmarkController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _checkmarkController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.transactionData['type'] as String;
    final amount = widget.transactionData['amount'] as double;
    final title = widget.transactionData['title'] as String;
    final message = widget.transactionData['message'] as String;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                    (route) => false,
                  ),
                  icon: const Icon(
                    Icons.close,
                    color: AppTheme.companyInfoColor,
                    size: 24,
                  ),
                ),
              ),

              // Add some top spacing to center content vertically
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Success Animation
                  _buildSuccessAnimation(),
                  const SizedBox(height: 32),

                  // Success Title
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Success Message
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      message,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        color: AppTheme.companyInfoColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Transaction Details Card
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildTransactionDetailsCard(type, amount),
                  ),
                  const SizedBox(height: 32),

                  // Additional Details (if any)
                  if (widget.transactionData.containsKey('paymentMethod') ||
                      widget.transactionData.containsKey('bankAccount'))
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildAdditionalDetails(),
                    ),
                ],
              ),

              const SizedBox(height: 32),

              // Action Buttons
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildActionButtons(),
              ),

              // Bottom spacing
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessAnimation() {
    return ScaleTransition(
      scale: _checkmarkAnimation,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.green[500],
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.green.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 60),
      ),
    );
  }

  Widget _buildTransactionDetailsCard(String type, double amount) {
    final isTopUp = type == 'top_up';
    final color = isTopUp ? AppTheme.primaryColor : Colors.orange[600]!;
    final icon = isTopUp ? Icons.add_circle : Icons.remove_circle;
    final prefix = isTopUp ? '+' : '-';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Transaction Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 16),

          // Transaction Type
          Text(
            isTopUp ? 'Wallet Top Up' : 'Withdrawal Request',
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.companyInfoColor,
            ),
          ),
          const SizedBox(height: 8),

          // Amount
          Text(
            '$prefix${CurrencyFormatter.formatAmountWithCurrency(amount)}',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),

          // Transaction ID
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'ID: TXN${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.companyInfoColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalDetails() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transaction Details',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 12),

          if (widget.transactionData.containsKey('fund'))
            _buildDetailRow(
              'Fund',
              (widget.transactionData['fund'] as dynamic)?.name ??
                  'Unknown Fund',
            ),

          if (widget.transactionData.containsKey('paymentMethod'))
            _buildDetailRow(
              'Payment Method',
              (widget.transactionData['paymentMethod'] as PaymentMethod?)
                      ?.name ??
                  'Unknown Payment Method',
            ),

          if (widget.transactionData.containsKey('bankAccount'))
            ..._buildBankAccountDetails(),

          _buildDetailRow('Date & Time', _formatDateTime(DateTime.now())),

          _buildDetailRow(
            'Status',
            widget.transactionData['type'] == 'top_up' ||
                    widget.transactionData['type'] == 'fund_top_up'
                ? 'Completed'
                : 'Pending Review',
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBankAccountDetails() {
    final bankAccount =
        widget.transactionData['bankAccount'] as Map<String, dynamic>;
    return [
      _buildDetailRow('Account Name', bankAccount['accountName']),
      _buildDetailRow('Bank Name', bankAccount['bankName']),
      _buildDetailRow(
        'Account Number',
        _maskAccountNumber(bankAccount['accountNumber']),
      ),
    ];
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              color: AppTheme.companyInfoColor,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Primary Action Button
        CustomButton(
          text: 'Back to Home',
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
          ),
          backgroundColor: AppTheme.primaryColor,
          textColor: Colors.white,
          height: 56,
          borderRadius: 12,
        ),
        const SizedBox(height: 12),

        // Secondary Action Button
        CustomButton(
          text: 'View Transaction History',
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            '/transaction-history',
            (route) => route.settings.name == '/home',
          ),
          backgroundColor: Colors.transparent,
          textColor: AppTheme.primaryColor,
          height: 56,
          borderRadius: 12,
          isOutlined: true,
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _maskAccountNumber(String accountNumber) {
    if (accountNumber.length <= 4) return accountNumber;
    return '****${accountNumber.substring(accountNumber.length - 4)}';
  }
}
