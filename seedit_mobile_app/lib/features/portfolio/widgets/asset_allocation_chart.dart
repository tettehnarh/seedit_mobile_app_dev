import 'package:flutter/material.dart';
import '../../../shared/models/investment_model.dart';

class AssetAllocationChart extends StatelessWidget {
  final List<AssetAllocation> allocations;
  final double totalValue;

  const AssetAllocationChart({
    super.key,
    required this.allocations,
    required this.totalValue,
  });

  @override
  Widget build(BuildContext context) {
    if (allocations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No Asset Allocation Data',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pie chart placeholder
        _buildPieChartPlaceholder(),
        
        const SizedBox(height: 16),
        
        // Allocation breakdown
        _buildAllocationBreakdown(),
        
        const SizedBox(height: 16),
        
        // Allocation recommendations
        _buildAllocationRecommendations(),
      ],
    );
  }

  Widget _buildPieChartPlaceholder() {
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
            // Simulated pie chart
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: _getChartColors(),
                      stops: _getChartStops(),
                    ),
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${allocations.length}\nAssets',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Asset Allocation',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllocationBreakdown() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Allocation Breakdown',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 12),
            
            ...allocations.asMap().entries.map((entry) {
              final index = entry.key;
              final allocation = entry.value;
              final color = _getColorForIndex(index);
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildAllocationItem(allocation, color),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAllocationItem(AssetAllocation allocation, Color color) {
    return Row(
      children: [
        // Color indicator
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Asset class name
        Expanded(
          child: Text(
            allocation.assetClass,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        
        // Percentage and value
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              allocation.formattedPercentage,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              allocation.formattedValue,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAllocationRecommendations() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.amber.shade600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Allocation Insights',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            _buildRecommendationItem(
              'Diversification',
              _getDiversificationScore(),
              _getDiversificationMessage(),
              _getDiversificationColor(),
            ),
            
            const SizedBox(height: 8),
            
            _buildRecommendationItem(
              'Risk Balance',
              _getRiskScore(),
              _getRiskMessage(),
              _getRiskColor(),
            ),
            
            const SizedBox(height: 8),
            
            _buildRecommendationItem(
              'Rebalancing',
              _getRebalancingScore(),
              _getRebalancingMessage(),
              _getRebalancingColor(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(
    String title,
    String score,
    String message,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    score,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                message,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Color> _getChartColors() {
    return [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];
  }

  List<double> _getChartStops() {
    if (allocations.isEmpty) return [1.0];
    
    double cumulative = 0.0;
    List<double> stops = [];
    
    for (final allocation in allocations) {
      cumulative += allocation.percentage / 100;
      stops.add(cumulative);
    }
    
    return stops;
  }

  Color _getColorForIndex(int index) {
    final colors = _getChartColors();
    return colors[index % colors.length];
  }

  String _getDiversificationScore() {
    if (allocations.length >= 4) return 'Excellent';
    if (allocations.length >= 3) return 'Good';
    if (allocations.length >= 2) return 'Fair';
    return 'Poor';
  }

  String _getDiversificationMessage() {
    if (allocations.length >= 4) {
      return 'Your portfolio is well diversified across asset classes';
    } else if (allocations.length >= 3) {
      return 'Good diversification, consider adding more asset classes';
    } else if (allocations.length >= 2) {
      return 'Limited diversification, consider expanding your portfolio';
    } else {
      return 'Poor diversification, high concentration risk';
    }
  }

  Color _getDiversificationColor() {
    if (allocations.length >= 4) return Colors.green;
    if (allocations.length >= 3) return Colors.blue;
    if (allocations.length >= 2) return Colors.orange;
    return Colors.red;
  }

  String _getRiskScore() {
    // Simple risk assessment based on equity allocation
    final equityAllocation = allocations
        .where((a) => a.assetClass.toLowerCase().contains('equity'))
        .fold(0.0, (sum, a) => sum + a.percentage);
    
    if (equityAllocation > 80) return 'High';
    if (equityAllocation > 60) return 'Moderate-High';
    if (equityAllocation > 40) return 'Moderate';
    if (equityAllocation > 20) return 'Conservative';
    return 'Very Conservative';
  }

  String _getRiskMessage() {
    final equityAllocation = allocations
        .where((a) => a.assetClass.toLowerCase().contains('equity'))
        .fold(0.0, (sum, a) => sum + a.percentage);
    
    if (equityAllocation > 80) {
      return 'High equity exposure increases growth potential and risk';
    } else if (equityAllocation > 60) {
      return 'Balanced approach with growth focus';
    } else if (equityAllocation > 40) {
      return 'Moderate risk profile with balanced allocation';
    } else if (equityAllocation > 20) {
      return 'Conservative approach prioritizing capital preservation';
    } else {
      return 'Very conservative allocation with minimal equity exposure';
    }
  }

  Color _getRiskColor() {
    final equityAllocation = allocations
        .where((a) => a.assetClass.toLowerCase().contains('equity'))
        .fold(0.0, (sum, a) => sum + a.percentage);
    
    if (equityAllocation > 80) return Colors.red;
    if (equityAllocation > 60) return Colors.orange;
    if (equityAllocation > 40) return Colors.blue;
    if (equityAllocation > 20) return Colors.green;
    return Colors.teal;
  }

  String _getRebalancingScore() {
    // Check if any allocation is significantly over/under target
    bool needsRebalancing = allocations.any((a) => 
        a.percentage > 50 || (allocations.length > 2 && a.percentage < 10));
    
    return needsRebalancing ? 'Recommended' : 'Not Needed';
  }

  String _getRebalancingMessage() {
    bool needsRebalancing = allocations.any((a) => 
        a.percentage > 50 || (allocations.length > 2 && a.percentage < 10));
    
    if (needsRebalancing) {
      return 'Consider rebalancing to maintain target allocation';
    } else {
      return 'Your portfolio allocation is well balanced';
    }
  }

  Color _getRebalancingColor() {
    bool needsRebalancing = allocations.any((a) => 
        a.percentage > 50 || (allocations.length > 2 && a.percentage < 10));
    
    return needsRebalancing ? Colors.orange : Colors.green;
  }
}

class AllocationTargetCard extends StatelessWidget {
  final List<AssetAllocation> currentAllocations;
  final List<AssetAllocation> targetAllocations;

  const AllocationTargetCard({
    super.key,
    required this.currentAllocations,
    required this.targetAllocations,
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
              'Target vs Current Allocation',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            ...targetAllocations.map((target) {
              final current = currentAllocations
                  .where((c) => c.assetClass == target.assetClass)
                  .firstOrNull;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildTargetComparisonItem(target, current),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetComparisonItem(
    AssetAllocation target,
    AssetAllocation? current,
  ) {
    final currentPercentage = current?.percentage ?? 0.0;
    final difference = currentPercentage - target.percentage;
    final isOverAllocated = difference > 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          target.assetClass,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Target',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    '${target.percentage.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    '${currentPercentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isOverAllocated ? Colors.red : Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Difference',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    '${difference >= 0 ? '+' : ''}${difference.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: difference.abs() > 5 
                          ? (isOverAllocated ? Colors.red : Colors.orange)
                          : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Progress bar showing current vs target
        LinearProgressIndicator(
          value: currentPercentage / 100,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(
            difference.abs() > 5 
                ? (isOverAllocated ? Colors.red : Colors.orange)
                : Colors.green,
          ),
        ),
      ],
    );
  }
}
