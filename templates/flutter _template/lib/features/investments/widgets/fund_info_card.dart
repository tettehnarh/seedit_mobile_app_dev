import 'package:flutter/material.dart';
import '../../../core/utils/app_theme.dart';
import '../models/investment_models.dart';

class FundInfoCard extends StatelessWidget {
  final Fund fund;

  const FundInfoCard({super.key, required this.fund});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
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
            'Fund Information',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 20),

          // Fund Metrics Grid
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Fund Size',
                  '\$${_formatLargeNumber(fund.totalAssets)}',
                  Icons.account_balance_wallet,
                  AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoItem(
                  'Inception Date',
                  _formatDate(fund.inceptionDate),
                  Icons.calendar_today,
                  AppTheme.secondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Management Fee',
                  '${fund.managementFee.toStringAsFixed(2)}%',
                  Icons.percent,
                  AppTheme.accentColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoItem(
                  'Expense Ratio',
                  '${(fund.managementFee * 1.2).toStringAsFixed(2)}%',
                  Icons.trending_down,
                  AppTheme.companyInfoColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Investment Strategy
          _buildStrategySection(),
          const SizedBox(height: 20),

          // Top Holdings
          _buildTopHoldingsSection(),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrategySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Investment Strategy',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            _getStrategyDescription(),
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopHoldingsSection() {
    final holdings = _getTopHoldings();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Holdings',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        ...holdings.map(
          (holding) =>
              _buildHoldingItem(holding['name']!, holding['percentage']!),
        ),
      ],
    );
  }

  Widget _buildHoldingItem(String name, String percentage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.business, color: AppTheme.primaryColor, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          Text(
            percentage,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  String _formatLargeNumber(double number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toStringAsFixed(0);
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _getStrategyDescription() {
    switch (fund.category.toLowerCase()) {
      case 'equity':
        return 'This fund invests primarily in equity securities of companies across various market capitalizations. The strategy focuses on long-term capital appreciation through diversified stock holdings.';
      case 'bond':
        return 'This fund invests in a diversified portfolio of fixed-income securities including government and corporate bonds. The strategy aims to provide steady income with capital preservation.';
      case 'mixed':
        return 'This balanced fund invests in a mix of equity and fixed-income securities. The strategy provides diversification across asset classes to balance growth potential with risk management.';
      default:
        return 'This fund follows a diversified investment strategy designed to meet specific investment objectives while managing risk through professional portfolio management.';
    }
  }

  List<Map<String, String>> _getTopHoldings() {
    switch (fund.category.toLowerCase()) {
      case 'equity':
        return [
          {'name': 'Apple Inc.', 'percentage': '8.5%'},
          {'name': 'Microsoft Corp.', 'percentage': '7.2%'},
          {'name': 'Amazon.com Inc.', 'percentage': '6.8%'},
          {'name': 'Alphabet Inc.', 'percentage': '5.9%'},
          {'name': 'Tesla Inc.', 'percentage': '4.3%'},
        ];
      case 'bond':
        return [
          {'name': 'US Treasury 10Y', 'percentage': '15.2%'},
          {'name': 'Corporate AAA Bonds', 'percentage': '12.8%'},
          {'name': 'Municipal Bonds', 'percentage': '10.5%'},
          {'name': 'International Bonds', 'percentage': '8.7%'},
          {'name': 'High-Yield Bonds', 'percentage': '6.9%'},
        ];
      case 'mixed':
        return [
          {'name': 'Equity Portfolio', 'percentage': '60.0%'},
          {'name': 'Bond Portfolio', 'percentage': '35.0%'},
          {'name': 'Cash & Equivalents', 'percentage': '3.5%'},
          {'name': 'Alternative Investments', 'percentage': '1.5%'},
        ];
      default:
        return [
          {'name': 'Diversified Holdings', 'percentage': '25.0%'},
          {'name': 'Growth Securities', 'percentage': '20.0%'},
          {'name': 'Value Securities', 'percentage': '18.0%'},
          {'name': 'International Exposure', 'percentage': '15.0%'},
          {'name': 'Cash & Equivalents', 'percentage': '5.0%'},
        ];
    }
  }
}
