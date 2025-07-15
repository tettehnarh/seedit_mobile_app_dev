import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/goal_provider.dart';
import '../../../shared/models/goal_model.dart';

class GoalCalculatorWidget extends ConsumerWidget {
  const GoalCalculatorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calculatorState = ref.watch(goalCalculatorProvider);

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

  Widget _buildCalculatorInputs(BuildContext context, WidgetRef ref, GoalCalculatorState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Goal Calculator',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Target amount
            _buildInputField(
              'Target Amount (₦)',
              state.targetAmount.toStringAsFixed(0),
              (value) {
                final amount = double.tryParse(value) ?? 0;
                ref.read(goalCalculatorProvider.notifier).updateTargetAmount(amount);
              },
              TextInputType.number,
            ),
            
            const SizedBox(height: 16),
            
            // Current amount
            _buildInputField(
              'Current Amount (₦)',
              state.currentAmount.toStringAsFixed(0),
              (value) {
                final amount = double.tryParse(value) ?? 0;
                ref.read(goalCalculatorProvider.notifier).updateCurrentAmount(amount);
              },
              TextInputType.number,
            ),
            
            const SizedBox(height: 16),
            
            // Target date
            const Text(
              'Target Date',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: state.targetDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 30)), // 30 years
                );
                if (date != null) {
                  ref.read(goalCalculatorProvider.notifier).updateTargetDate(date);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(_formatDate(state.targetDate)),
                    const Spacer(),
                    Text(
                      '${state.targetDate.difference(DateTime.now()).inDays} days',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
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
                ref.read(goalCalculatorProvider.notifier).updateExpectedReturn(value);
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

  Widget _buildCalculatorResults(BuildContext context, GoalCalculatorState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Goal Requirements',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: state.isFeasible ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    state.isFeasible ? 'Feasible' : 'Challenging',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: state.isFeasible ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Monthly requirement
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Monthly Required',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '₦${state.monthlyRequired.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Investment options
            Row(
              children: [
                Expanded(
                  child: _buildResultItem(
                    'SIP Amount',
                    '₦${state.sipAmount.toStringAsFixed(2)}',
                    Colors.green,
                    'Recommended for systematic investing',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildResultItem(
                    'Lump Sum',
                    '₦${state.lumpSumRequired.toStringAsFixed(2)}',
                    Colors.orange,
                    'One-time investment required',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsChart(BuildContext context, GoalCalculatorState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Goal Progress Projection',
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
                      'Goal Progress Chart',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Monthly progress towards target',
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
            
            // Timeline info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTimelineItem('Start', '₦${state.currentAmount.toStringAsFixed(0)}'),
                _buildTimelineItem('Target', '₦${state.targetAmount.toStringAsFixed(0)}'),
                _buildTimelineItem('Duration', '${(state.targetDate.difference(DateTime.now()).inDays / 30).ceil()} months'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, GoalCalculatorState state) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: Navigate to goal creation with pre-filled values
            },
            icon: const Icon(Icons.flag),
            label: const Text('Create Goal with these values'),
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

  Widget _buildResultItem(String label, String value, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
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
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
