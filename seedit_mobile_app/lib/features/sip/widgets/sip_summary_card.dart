import 'package:flutter/material.dart';
import '../../../shared/models/sip_model.dart';

class SIPSummaryCard extends StatelessWidget {
  final List<SIPPlan> sipPlans;

  const SIPSummaryCard({
    super.key,
    required this.sipPlans,
  });

  @override
  Widget build(BuildContext context) {
    final totalInvested = sipPlans.fold<double>(0, (sum, sip) => sum + sip.totalInvested);
    final activeSIPs = sipPlans.where((sip) => sip.isActive).length;
    final totalSIPs = sipPlans.length;
    final monthlyInvestment = sipPlans
        .where((sip) => sip.isActive && sip.frequency == SIPFrequency.monthly)
        .fold<double>(0, (sum, sip) => sum + sip.amount);

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
                  'SIP Portfolio',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  Icons.schedule,
                  color: Colors.white70,
                  size: 20,
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Total invested
            Text(
              '₦${totalInvested.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 4),
            
            const Text(
              'Total Invested',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // SIP metrics
            Row(
              children: [
                Expanded(
                  child: _buildMetric(
                    'Active SIPs',
                    '$activeSIPs of $totalSIPs',
                    Icons.play_circle_outline,
                  ),
                ),
                Expanded(
                  child: _buildMetric(
                    'Monthly Investment',
                    '₦${monthlyInvestment.toStringAsFixed(0)}',
                    Icons.calendar_month,
                  ),
                ),
                Expanded(
                  child: _buildMetric(
                    'Avg. Amount',
                    totalSIPs > 0 ? '₦${(totalInvested / totalSIPs).toStringAsFixed(0)}' : '₦0',
                    Icons.trending_up,
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

class SIPQuickStats extends StatelessWidget {
  final List<SIPPlan> sipPlans;

  const SIPQuickStats({
    super.key,
    required this.sipPlans,
  });

  @override
  Widget build(BuildContext context) {
    final activeSIPs = sipPlans.where((sip) => sip.isActive).toList();
    final pausedSIPs = sipPlans.where((sip) => sip.isPaused).toList();
    final completedSIPs = sipPlans.where((sip) => sip.isCompleted).toList();
    
    final nextExecution = activeSIPs
        .where((sip) => sip.nextExecutionDate != null)
        .map((sip) => sip.nextExecutionDate!)
        .fold<DateTime?>(null, (earliest, date) {
          if (earliest == null || date.isBefore(earliest)) {
            return date;
          }
          return earliest;
        });

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
                    'Active',
                    '${activeSIPs.length}',
                    Colors.green,
                    Icons.play_circle,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Paused',
                    '${pausedSIPs.length}',
                    Colors.orange,
                    Icons.pause_circle,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Completed',
                    '${completedSIPs.length}',
                    Colors.blue,
                    Icons.check_circle,
                  ),
                ),
              ],
            ),
            
            if (nextExecution != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: Colors.blue[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Next SIP Execution',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _formatDate(nextExecution),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference < 7) {
      return 'In $difference days';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class SIPPerformanceCard extends StatelessWidget {
  final List<SIPPlan> sipPlans;

  const SIPPerformanceCard({
    super.key,
    required this.sipPlans,
  });

  @override
  Widget build(BuildContext context) {
    final totalInvested = sipPlans.fold<double>(0, (sum, sip) => sum + sip.totalInvested);
    final totalUnits = sipPlans.fold<double>(0, (sum, sip) => sum + sip.totalUnits);
    final averageNAV = totalUnits > 0 ? totalInvested / totalUnits : 0.0;
    
    // Mock current value calculation (would come from actual NAV data)
    final currentValue = totalInvested * 1.08; // Assuming 8% growth
    final totalGain = currentValue - totalInvested;
    final gainPercentage = totalInvested > 0 ? (totalGain / totalInvested) * 100 : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SIP Performance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildPerformanceItem(
                    'Current Value',
                    '₦${currentValue.toStringAsFixed(2)}',
                    totalGain >= 0 ? Colors.green : Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildPerformanceItem(
                    'Total Gain',
                    '₦${totalGain.toStringAsFixed(2)}',
                    totalGain >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildPerformanceItem(
                    'Gain %',
                    '${gainPercentage >= 0 ? '+' : ''}${gainPercentage.toStringAsFixed(2)}%',
                    gainPercentage >= 0 ? Colors.green : Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildPerformanceItem(
                    'Avg NAV',
                    '₦${averageNAV.toStringAsFixed(2)}',
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

  Widget _buildPerformanceItem(String label, String value, Color color) {
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
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class SIPFrequencyChart extends StatelessWidget {
  final List<SIPPlan> sipPlans;

  const SIPFrequencyChart({
    super.key,
    required this.sipPlans,
  });

  @override
  Widget build(BuildContext context) {
    final frequencyCount = <SIPFrequency, int>{};
    
    for (final sip in sipPlans) {
      frequencyCount[sip.frequency] = (frequencyCount[sip.frequency] ?? 0) + 1;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SIP Frequency Distribution',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            ...frequencyCount.entries.map((entry) {
              final percentage = sipPlans.isNotEmpty ? (entry.value / sipPlans.length) * 100 : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildFrequencyItem(
                  _getFrequencyText(entry.key),
                  entry.value,
                  percentage,
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencyItem(String frequency, int count, double percentage) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            frequency,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$count (${percentage.toStringAsFixed(0)}%)',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _getFrequencyText(SIPFrequency frequency) {
    switch (frequency) {
      case SIPFrequency.daily:
        return 'Daily';
      case SIPFrequency.weekly:
        return 'Weekly';
      case SIPFrequency.monthly:
        return 'Monthly';
      case SIPFrequency.quarterly:
        return 'Quarterly';
      case SIPFrequency.yearly:
        return 'Yearly';
    }
  }
}
