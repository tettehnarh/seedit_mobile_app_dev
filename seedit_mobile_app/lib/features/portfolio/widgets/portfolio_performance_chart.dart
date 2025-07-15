import 'package:flutter/material.dart';
import '../../../shared/models/investment_model.dart';

class PortfolioPerformanceChart extends StatefulWidget {
  final PortfolioPerformance performance;
  final double totalValue;

  const PortfolioPerformanceChart({
    super.key,
    required this.performance,
    required this.totalValue,
  });

  @override
  State<PortfolioPerformanceChart> createState() => _PortfolioPerformanceChartState();
}

class _PortfolioPerformanceChartState extends State<PortfolioPerformanceChart> {
  String _selectedPeriod = '1M';
  
  final List<String> _periods = ['1D', '1W', '1M', '3M', '1Y', 'ALL'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Period selector
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _periods.map((period) {
              final isSelected = period == _selectedPeriod;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(period),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedPeriod = period;
                      });
                    }
                  },
                  selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  checkmarkColor: Theme.of(context).primaryColor,
                ),
              );
            }).toList(),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Performance metrics for selected period
        _buildPerformanceMetrics(),
        
        const SizedBox(height: 16),
        
        // Chart placeholder (would integrate with actual charting library)
        _buildChartPlaceholder(),
        
        const SizedBox(height: 16),
        
        // Performance summary
        _buildPerformanceSummary(),
      ],
    );
  }

  Widget _buildPerformanceMetrics() {
    final return_ = _getReturnForPeriod(_selectedPeriod);
    final isPositive = return_ >= 0;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMetric(
              'Return',
              '${isPositive ? '+' : ''}${return_.toStringAsFixed(2)}%',
              isPositive ? Colors.green : Colors.red,
            ),
            _buildMetric(
              'Value',
              '₦${widget.totalValue.toStringAsFixed(2)}',
              Colors.blue,
            ),
            _buildMetric(
              'Volatility',
              '${widget.performance.volatility.toStringAsFixed(2)}%',
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
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

  Widget _buildChartPlaceholder() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              'Portfolio Performance Chart',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Period: $_selectedPeriod',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 16),
            // Simulated chart line
            Container(
              width: 200,
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.shade300,
                    Colors.green.shade600,
                    Colors.blue.shade600,
                  ],
                ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Breakdown',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 12),
            
            _buildPerformanceRow('Daily', widget.performance.dailyReturn),
            _buildPerformanceRow('Weekly', widget.performance.weeklyReturn),
            _buildPerformanceRow('Monthly', widget.performance.monthlyReturn),
            _buildPerformanceRow('Quarterly', widget.performance.quarterlyReturn),
            _buildPerformanceRow('Yearly', widget.performance.yearlyReturn),
            
            const Divider(),
            
            _buildPerformanceRow('Total Return', widget.performance.totalReturn, isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceRow(String period, double return_, {bool isBold = false}) {
    final isPositive = return_ >= 0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            period,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
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
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                  color: isPositive ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _getReturnForPeriod(String period) {
    switch (period) {
      case '1D':
        return widget.performance.dailyReturn;
      case '1W':
        return widget.performance.weeklyReturn;
      case '1M':
        return widget.performance.monthlyReturn;
      case '3M':
        return widget.performance.quarterlyReturn;
      case '1Y':
        return widget.performance.yearlyReturn;
      case 'ALL':
        return widget.performance.totalReturn;
      default:
        return widget.performance.monthlyReturn;
    }
  }
}

class PerformanceMetricsCard extends StatelessWidget {
  final PortfolioPerformance performance;

  const PerformanceMetricsCard({
    super.key,
    required this.performance,
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
              'Risk Metrics',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildRiskMetric(
                    'Volatility',
                    '${performance.volatility.toStringAsFixed(2)}%',
                    'Measure of price fluctuation',
                    Icons.speed,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildRiskMetric(
                    'Sharpe Ratio',
                    performance.sharpeRatio.toStringAsFixed(2),
                    'Risk-adjusted return',
                    Icons.balance,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            _buildRiskMetric(
              'Max Drawdown',
              '${performance.maxDrawdown.toStringAsFixed(2)}%',
              'Largest peak-to-trough decline',
              Icons.trending_down,
              Colors.red,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskMetric(
    String title,
    String value,
    String description,
    IconData icon,
    Color color, {
    bool isFullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isFullWidth ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class PerformanceComparisonCard extends StatelessWidget {
  final PortfolioPerformance performance;
  final double benchmarkReturn;
  final String benchmarkName;

  const PerformanceComparisonCard({
    super.key,
    required this.performance,
    this.benchmarkReturn = 8.5,
    this.benchmarkName = 'Market Index',
  });

  @override
  Widget build(BuildContext context) {
    final portfolioReturn = performance.yearlyReturn;
    final outperforming = portfolioReturn > benchmarkReturn;
    final difference = portfolioReturn - benchmarkReturn;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance vs Benchmark',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildComparisonItem(
                    'Your Portfolio',
                    '${portfolioReturn >= 0 ? '+' : ''}${portfolioReturn.toStringAsFixed(2)}%',
                    portfolioReturn >= 0 ? Colors.green : Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildComparisonItem(
                    benchmarkName,
                    '${benchmarkReturn >= 0 ? '+' : ''}${benchmarkReturn.toStringAsFixed(2)}%',
                    Colors.grey,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: outperforming 
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    outperforming ? Icons.trending_up : Icons.trending_down,
                    color: outperforming ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      outperforming
                          ? 'Outperforming by ${difference.toStringAsFixed(2)}%'
                          : 'Underperforming by ${difference.abs().toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: outperforming ? Colors.green : Colors.red,
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

  Widget _buildComparisonItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
