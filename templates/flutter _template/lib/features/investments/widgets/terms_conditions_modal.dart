import 'package:flutter/material.dart';
import '../../../core/utils/app_theme.dart';
import '../models/investment_models.dart';

class TermsConditionsModal extends StatefulWidget {
  final Fund fund;
  final VoidCallback onAccept;

  const TermsConditionsModal({
    super.key,
    required this.fund,
    required this.onAccept,
  });

  @override
  State<TermsConditionsModal> createState() => _TermsConditionsModalState();
}

class _TermsConditionsModalState extends State<TermsConditionsModal> {
  bool _acceptTerms = false;
  bool _acceptRiskDisclosure = false;
  bool _acceptFeeStructure = false;
  bool _confirmAge = false;

  bool get _allTermsAccepted =>
      _acceptTerms &&
      _acceptRiskDisclosure &&
      _acceptFeeStructure &&
      _confirmAge;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.description, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Terms & Conditions',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          widget.fund.name,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fund Information
                    _buildInfoSection('Fund Information', [
                      'Fund Name: ${widget.fund.name}',
                      'Minimum Investment: GHS ${widget.fund.minimumInvestment.toStringAsFixed(0)}',
                      'Risk Level: ${widget.fund.riskLevel}',
                      'Current Price: GHS ${widget.fund.currentPrice.toStringAsFixed(2)}',
                    ]),
                    const SizedBox(height: 20),

                    // Terms & Conditions
                    _buildInfoSection('Investment Terms', [
                      'Investment funds are subject to market risks and may lose value',
                      'Past performance does not guarantee future results',
                      'Minimum investment period is 6 months',
                      'Early withdrawal may incur penalties',
                      'Fund management fees apply as per fee structure',
                    ]),
                    const SizedBox(height: 20),

                    // Risk Disclosure
                    _buildInfoSection('Risk Disclosure', [
                      'All investments carry inherent risks',
                      'Market volatility may affect fund performance',
                      'Currency fluctuations may impact returns',
                      'Liquidity risks may apply during market stress',
                      'Regulatory changes may affect fund operations',
                    ]),
                    const SizedBox(height: 20),

                    // Fee Structure
                    _buildInfoSection('Fee Structure', [
                      'Management Fee: 1.5% annually',
                      'Performance Fee: 10% of profits above benchmark',
                      'Entry Fee: 0.5% of investment amount',
                      'Exit Fee: 0.25% if withdrawn within 12 months',
                      'All fees are inclusive of applicable taxes',
                    ]),
                    const SizedBox(height: 24),

                    // Checkboxes
                    _buildCheckbox(
                      'I have read and accept the investment terms and conditions',
                      _acceptTerms,
                      (value) => setState(() => _acceptTerms = value ?? false),
                    ),
                    const SizedBox(height: 12),
                    _buildCheckbox(
                      'I understand and accept the risk disclosure',
                      _acceptRiskDisclosure,
                      (value) => setState(
                        () => _acceptRiskDisclosure = value ?? false,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildCheckbox(
                      'I agree to the fee structure',
                      _acceptFeeStructure,
                      (value) =>
                          setState(() => _acceptFeeStructure = value ?? false),
                    ),
                    const SizedBox(height: 12),
                    _buildCheckbox(
                      'I confirm that I am 18 years or older',
                      _confirmAge,
                      (value) => setState(() => _confirmAge = value ?? false),
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.companyInfoColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _allTermsAccepted
                          ? () {
                              Navigator.pop(context);
                              widget.onAccept();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Accept & Continue',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  Widget _buildInfoSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.only(top: 8),
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckbox(
    String text,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primaryColor,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!value),
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
