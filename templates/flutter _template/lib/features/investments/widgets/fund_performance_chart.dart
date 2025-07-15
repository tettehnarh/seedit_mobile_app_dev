import 'package:flutter/material.dart';
import '../../../core/utils/app_theme.dart';
import '../models/investment_models.dart';

class FundPerformanceChart extends StatefulWidget {
  final Fund fund;

  const FundPerformanceChart({super.key, required this.fund});

  @override
  State<FundPerformanceChart> createState() => _FundPerformanceChartState();
}

class _FundPerformanceChartState extends State<FundPerformanceChart> {
  String _selectedPeriod = '1Y';
  final List<String> _periods = ['1M', '3M', '6M', '1Y', '3Y', '5Y'];

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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Performance',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
              Text(
                '+${widget.fund.returnRate.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: widget.fund.returnRate >= 0
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Chart Area (Placeholder)
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Stack(
              children: [
                // Chart placeholder with sample data visualization
                CustomPaint(
                  size: const Size(double.infinity, 200),
                  painter: _ChartPainter(
                    returnRate: widget.fund.returnRate,
                    period: _selectedPeriod,
                  ),
                ),
                // Chart overlay info
                Positioned(
                  top: 16,
                  left: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Value',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${(1000 * (1 + widget.fund.returnRate / 100)).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Period Selector
          Row(
            children: _periods.map((period) {
              final isSelected = period == _selectedPeriod;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPeriod = period;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      period,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Performance Metrics
          Row(
            children: [
              Expanded(
                child: _buildMetric(
                  'Volatility',
                  '${(widget.fund.returnRate * 0.3).toStringAsFixed(1)}%',
                ),
              ),
              Expanded(
                child: _buildMetric(
                  'Sharpe Ratio',
                  (widget.fund.returnRate / 10).toStringAsFixed(2),
                ),
              ),
              Expanded(
                child: _buildMetric(
                  'Max Drawdown',
                  '${(widget.fund.returnRate * -0.2).toStringAsFixed(1)}%',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }
}

class _ChartPainter extends CustomPainter {
  final double returnRate;
  final String period;

  _ChartPainter({required this.returnRate, required this.period});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = returnRate >= 0 ? Colors.green : Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Generate sample chart data based on return rate
    final points = <Offset>[];
    final dataPoints = 50;

    for (int i = 0; i < dataPoints; i++) {
      final x = (i / (dataPoints - 1)) * size.width;
      final baseY = size.height * 0.7;
      final variation = (returnRate / 100) * size.height * 0.3;
      final noise = (i % 7 - 3) * size.height * 0.05;
      final y = baseY - variation - noise;

      points.add(Offset(x, y.clamp(size.height * 0.1, size.height * 0.9)));
    }

    // Draw the chart line
    if (points.isNotEmpty) {
      path.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, paint);
    }

    // Draw area under the curve
    final areaPaint = Paint()
      ..color = (returnRate >= 0 ? Colors.green : Colors.red).withValues(
        alpha: 0.1,
      )
      ..style = PaintingStyle.fill;

    if (points.isNotEmpty) {
      final areaPath = Path();
      areaPath.moveTo(points.first.dx, size.height);
      areaPath.lineTo(points.first.dx, points.first.dy);

      for (int i = 1; i < points.length; i++) {
        areaPath.lineTo(points[i].dx, points[i].dy);
      }

      areaPath.lineTo(points.last.dx, size.height);
      areaPath.close();
      canvas.drawPath(areaPath, areaPaint);
    }

    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 0.5;

    // Horizontal grid lines
    for (int i = 1; i < 4; i++) {
      final y = (i / 4) * size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Vertical grid lines
    for (int i = 1; i < 6; i++) {
      final x = (i / 6) * size.width;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
