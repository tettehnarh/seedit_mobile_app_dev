import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/sip_provider.dart';
import '../../../shared/models/sip_model.dart';

class SIPCalculatorWidget extends ConsumerWidget {
  const SIPCalculatorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calculatorState = ref.watch(sipCalculatorProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calculator inputs
          _buildCalculatorInputs(context, ref, calculatorState),
          
          const SizedBox(height: 24),
          
          // Results
          _buildCalculatorResults(context, calculatorState),
          
          const SizedBox(height: 24),
          
          // Chart placeholder
          _buildResultsChart(context, calculatorState),
          
          const SizedBox(height: 24),
          
          // Action buttons
          _buildActionButtons(context, calculatorState),
        ],
      ),
    );
  }

  Widget _buildCalculatorInputs(BuildContext context, WidgetRef ref, SIPCalculatorState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SIP Calculator',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Investment amount
            _buildInputField(
              'Investment Amount (₦)',
              state.amount.toStringAsFixed(0),
              (value) {
                final amount = double.tryParse(value) ?? 0;
                ref.read(sipCalculatorProvider.notifier).updateAmount(amount);
              },
              TextInputType.number,
            ),
            
            const SizedBox(height: 16),
            
            // Frequency selector
            const Text(
              'Investment Frequency',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: SIPFrequency.values.map((frequency) {
                final isSelected = state.frequency == frequency;
                return FilterChip(
                  label: Text(_getFrequencyText(frequency)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      ref.read(sipCalculatorProvider.notifier).updateFrequency(frequency);
                    }
                  },
                  selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  checkmarkColor: Theme.of(context).primaryColor,
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
            
            // Duration slider
            const Text(
              'Investment Duration',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Slider(
              value: state.duration.toDouble(),
              min: 12,
              max: 360, // 30 years
              divisions: 29,
              label: '${(state.duration / 12).toStringAsFixed(1)} years',
              onChanged: (value) {
                ref.read(sipCalculatorProvider.notifier).updateDuration(value.toInt());
              },
            ),
            Text(
              '${(state.duration / 12).toStringAsFixed(1)} years (${state.duration} months)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Expected return slider
            const Text(
              'Expected Annual Return',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Slider(
              value: state.expectedReturn,
              min: 1.0,
              max: 25.0,
              divisions: 24,
              label: '${state.expectedReturn.toStringAsFixed(1)}%',
              onChanged: (value) {
                ref.read(sipCalculatorProvider.notifier).updateExpectedReturn(value);
              },
            ),
            Text(
              '${state.expectedReturn.toStringAsFixed(1)}% per annum',
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

  Widget _buildCalculatorResults(BuildContext context, SIPCalculatorState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Investment Results',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Maturity value
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Maturity Value',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '₦${state.maturityValue.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Investment breakdown
            Row(
              children: [
                Expanded(
                  child: _buildResultItem(
                    'Total Investment',
                    '₦${state.totalInvestment.toStringAsFixed(2)}',
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildResultItem(
                    'Total Returns',
                    '₦${state.totalReturns.toStringAsFixed(2)}',
                    Colors.green,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Return percentage
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Return %',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${state.totalInvestment > 0 ? ((state.totalReturns / state.totalInvestment) * 100).toStringAsFixed(1) : 0}%',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
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

  Widget _buildResultsChart(BuildContext context, SIPCalculatorState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Investment Growth',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Chart placeholder
            Container(
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
                      'SIP Growth Chart',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Investment vs Returns over time',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem('Investment', Colors.blue),
                _buildLegendItem('Returns', Colors.green),
                _buildLegendItem('Total Value', Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, SIPCalculatorState state) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: Navigate to SIP creation with pre-filled values
            },
            icon: const Icon(Icons.add),
            label: const Text('Create SIP with these values'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Share calculation results
                },
                icon: const Icon(Icons.share),
                label: const Text('Share'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Save calculation
                },
                icon: const Icon(Icons.bookmark),
                label: const Text('Save'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInputField(
    String label,
    String value,
    Function(String) onChanged,
    TextInputType keyboardType,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildResultItem(String label, String value, Color color) {
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

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
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
