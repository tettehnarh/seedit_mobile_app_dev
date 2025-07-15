import 'package:flutter/material.dart';
import '../../../shared/models/investment_model.dart';

class PortfolioSummaryCard extends StatelessWidget {
  final Portfolio portfolio;

  const PortfolioSummaryCard({
    super.key,
    required this.portfolio,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Portfolio Value',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  Icons.visibility,
                  color: Colors.white70,
                  size: 20,
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Total value
            Text(
              portfolio.formattedTotalValue,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Gain/Loss
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: portfolio.isProfit 
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        portfolio.isProfit ? Icons.trending_up : Icons.trending_down,
                        color: portfolio.isProfit ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        portfolio.formattedTotalGainLoss,
                        style: TextStyle(
                          color: portfolio.isProfit ? Colors.green : Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 8),
                
                Text(
                  '(${portfolio.formattedTotalGainLossPercentage})',
                  style: TextStyle(
                    color: portfolio.isProfit ? Colors.green : Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Portfolio metrics
            Row(
              children: [
                Expanded(
                  child: _buildMetric(
                    'Invested',
                    portfolio.formattedTotalInvested,
                    Icons.account_balance_wallet,
                  ),
                ),
                Expanded(
                  child: _buildMetric(
                    'Holdings',
                    '${portfolio.holdings.length} funds',
                    Icons.pie_chart,
                  ),
                ),
                Expanded(
                  child: _buildMetric(
                    'Today',
                    '${portfolio.performance.dailyReturn >= 0 ? '+' : ''}${portfolio.performance.dailyReturn.toStringAsFixed(2)}%',
                    Icons.today,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: Colors.white70,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class PortfolioQuickStats extends StatelessWidget {
  final Portfolio portfolio;

  const PortfolioQuickStats({
    super.key,
    required this.portfolio,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Stats',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Return',
                    '${portfolio.performance.totalReturn >= 0 ? '+' : ''}${portfolio.performance.totalReturn.toStringAsFixed(2)}%',
                    portfolio.performance.totalReturn >= 0 ? Colors.green : Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Annual Return',
                    '${portfolio.performance.yearlyReturn >= 0 ? '+' : ''}${portfolio.performance.yearlyReturn.toStringAsFixed(2)}%',
                    portfolio.performance.yearlyReturn >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Volatility',
                    '${portfolio.performance.volatility.toStringAsFixed(2)}%',
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Sharpe Ratio',
                    portfolio.performance.sharpeRatio.toStringAsFixed(2),
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class PortfolioPerformanceSummary extends StatelessWidget {
  final Portfolio portfolio;

  const PortfolioPerformanceSummary({
    super.key,
    required this.portfolio,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            _buildPerformanceRow('1 Day', portfolio.performance.dailyReturn),
            const SizedBox(height: 8),
            _buildPerformanceRow('1 Week', portfolio.performance.weeklyReturn),
            const SizedBox(height: 8),
            _buildPerformanceRow('1 Month', portfolio.performance.monthlyReturn),
            const SizedBox(height: 8),
            _buildPerformanceRow('3 Months', portfolio.performance.quarterlyReturn),
            const SizedBox(height: 8),
            _buildPerformanceRow('1 Year', portfolio.performance.yearlyReturn),
            const SizedBox(height: 8),
            _buildPerformanceRow('Total', portfolio.performance.totalReturn),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceRow(String period, double return_) {
    final isPositive = return_ >= 0;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          period,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Row(
          children: [
            Icon(
              isPositive ? Icons.trending_up : Icons.trending_down,
              color: isPositive ? Colors.green : Colors.red,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              '${isPositive ? '+' : ''}${return_.toStringAsFixed(2)}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isPositive ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class PortfolioValueCard extends StatelessWidget {
  final Portfolio portfolio;
  final bool showDetails;

  const PortfolioValueCard({
    super.key,
    required this.portfolio,
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portfolio value
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Portfolio Value',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      portfolio.formattedTotalValue,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: portfolio.isProfit 
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    portfolio.isProfit ? Icons.trending_up : Icons.trending_down,
                    color: portfolio.isProfit ? Colors.green : Colors.red,
                    size: 24,
                  ),
                ),
              ],
            ),
            
            if (showDetails) ...[
              const SizedBox(height: 16),
              
              // Gain/Loss details
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Gain/Loss',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          portfolio.formattedTotalGainLoss,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: portfolio.isProfit ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      portfolio.formattedTotalGainLossPercentage,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: portfolio.isProfit ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Investment details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Invested: ${portfolio.formattedTotalInvested}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    'Last Updated: ${_formatDate(portfolio.lastUpdated)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
