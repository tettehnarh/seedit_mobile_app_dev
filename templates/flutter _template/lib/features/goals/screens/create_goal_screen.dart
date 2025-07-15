import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';

import '../providers/goals_provider.dart';
import '../models/goal_models.dart';
import '../widgets/goals_loading_states.dart';
import 'dart:developer' as developer;

class CreateGoalScreen extends ConsumerStatefulWidget {
  final PersonalGoal? goalToEdit;

  const CreateGoalScreen({super.key, this.goalToEdit});

  @override
  ConsumerState<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends ConsumerState<CreateGoalScreen> {
  final _formKey = GlobalKey<FormState>(debugLabel: 'create_goal_form');
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetAmountController = TextEditingController();

  DateTime? _selectedTargetDate;
  InvestmentFrequency _selectedFrequency = InvestmentFrequency.monthly;
  Fund? _selectedFund;
  bool _reminderEnabled = true;
  bool _isLoading = false;
  double _allocationPercentage = 100.0;

  @override
  void initState() {
    super.initState();

    // Add listeners to text controllers for real-time updates
    _targetAmountController.addListener(_onFieldChanged);

    // If editing, populate fields
    if (widget.goalToEdit != null) {
      _populateFieldsForEdit();
    }
  }

  /// Called when any field that affects the calculation changes
  void _onFieldChanged() {
    setState(() {
      // This will trigger a rebuild and recalculate the amount
    });
  }

  void _populateFieldsForEdit() {
    final goal = widget.goalToEdit!;
    _nameController.text = goal.name;
    _descriptionController.text = goal.description ?? '';
    _targetAmountController.text = goal.targetAmount.toString();
    _selectedTargetDate = DateTime.parse(goal.targetDate);
    _reminderEnabled = goal.reminderEnabled;
    _allocationPercentage = goal.allocationPercentage;

    // Set frequency
    switch (goal.investmentFrequency) {
      case 'daily':
        _selectedFrequency = InvestmentFrequency.daily;
        break;
      case 'weekly':
        _selectedFrequency = InvestmentFrequency.weekly;
        break;
      case 'monthly':
        _selectedFrequency = InvestmentFrequency.monthly;
        break;
      case 'quarterly':
        _selectedFrequency = InvestmentFrequency.quarterly;
        break;
    }
  }

  @override
  void dispose() {
    _targetAmountController.removeListener(_onFieldChanged);
    _nameController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final availableFundsAsync = ref.watch(availableFundsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.goalToEdit != null ? 'Edit Goal' : 'Create Goal',
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const ContributionFormLoading()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Goal Name
                    _buildSectionTitle('Goal Details'),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _nameController,
                      label: 'Goal Name',
                      hint: 'e.g., Emergency Fund, New Car, Vacation',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a goal name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Description
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description (Optional)',
                      hint: 'Add more details about your goal',
                      maxLines: 3,
                    ),

                    const SizedBox(height: 24),

                    // Target Amount
                    _buildSectionTitle('Financial Target'),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _targetAmountController,
                      label: 'Target Amount (GHS)',
                      hint: '0.00',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter target amount';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Target Date
                    _buildDateField(),

                    const SizedBox(height: 24),

                    // Investment Planning
                    _buildSectionTitle('Investment Planning'),
                    const SizedBox(height: 16),
                    _buildFrequencySelector(),

                    const SizedBox(height: 16),

                    // Calculated Amount Per Period
                    _buildCalculatedAmountField(),

                    const SizedBox(height: 16),

                    // Fund Selection
                    availableFundsAsync.when(
                      data: (funds) => _buildFundSelector(funds),
                      loading: () => _buildFundSelectorLoading(),
                      error: (error, stack) => _buildFundSelectorError(),
                    ),

                    const SizedBox(height: 16),

                    // Investment Allocation Slider (only show if fund is selected)
                    if (_selectedFund != null) ...[
                      _buildAllocationSlider(),
                      const SizedBox(height: 16),
                      _buildProgressPreview(),
                      const SizedBox(height: 24),
                    ] else
                      const SizedBox(height: 24),

                    // Reminder Settings
                    _buildSectionTitle('Reminder Settings'),
                    const SizedBox(height: 16),
                    _buildReminderSwitch(),

                    const SizedBox(height: 32),

                    // Create/Update Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                widget.goalToEdit != null
                                    ? 'Update Goal'
                                    : 'Create Goal',
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              color: Colors.grey[500],
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.primaryColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Target Date',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectTargetDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedTargetDate != null
                      ? '${_selectedTargetDate!.day}/${_selectedTargetDate!.month}/${_selectedTargetDate!.year}'
                      : 'Select target date',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    color: _selectedTargetDate != null
                        ? Colors.black87
                        : Colors.grey[500],
                  ),
                ),
                Icon(Icons.calendar_today, color: Colors.grey[600], size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFrequencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Investment Frequency',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<InvestmentFrequency>(
              value: _selectedFrequency,
              isExpanded: true,
              onChanged: (InvestmentFrequency? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedFrequency = newValue;
                  });
                  _onFieldChanged(); // Trigger calculation update
                }
              },
              items: InvestmentFrequency.values.map((
                InvestmentFrequency frequency,
              ) {
                return DropdownMenuItem<InvestmentFrequency>(
                  value: frequency,
                  child: Text(
                    frequency.displayName,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  /// Calculate the amount needed per investment period
  double? _calculateAmountPerPeriod() {
    // Check if all required fields have valid values
    if (_selectedTargetDate == null ||
        _targetAmountController.text.trim().isEmpty) {
      return null;
    }

    final targetAmount = double.tryParse(_targetAmountController.text.trim());
    if (targetAmount == null || targetAmount <= 0) {
      return null;
    }

    // Get current amount (0 for new goals, existing amount for edits)
    final currentAmount = widget.goalToEdit?.currentAmount ?? 0.0;

    // Calculate remaining amount needed
    final remainingAmount = targetAmount - currentAmount;
    if (remainingAmount <= 0) {
      return 0.0; // Goal already achieved
    }

    // Calculate number of periods between now and target date
    final now = DateTime.now();
    final targetDate = _selectedTargetDate!;

    // Handle past target dates
    if (targetDate.isBefore(now) || targetDate.isAtSameMomentAs(now)) {
      return null; // Invalid target date
    }

    final daysDifference = targetDate.difference(now).inDays;

    // Calculate number of periods based on frequency
    int numberOfPeriods;
    switch (_selectedFrequency) {
      case InvestmentFrequency.daily:
        numberOfPeriods = daysDifference;
        break;
      case InvestmentFrequency.weekly:
        numberOfPeriods = (daysDifference / 7).ceil();
        break;
      case InvestmentFrequency.monthly:
        numberOfPeriods = (daysDifference / 30.44)
            .ceil(); // Average days per month
        break;
      case InvestmentFrequency.quarterly:
        numberOfPeriods = (daysDifference / 91.31)
            .ceil(); // Average days per quarter
        break;
    }

    if (numberOfPeriods <= 0) {
      return null;
    }

    return remainingAmount / numberOfPeriods;
  }

  Widget _buildCalculatedAmountField() {
    final calculatedAmount = _calculateAmountPerPeriod();

    // Don't show if calculation is not possible
    if (calculatedAmount == null) {
      return const SizedBox.shrink();
    }

    // Handle case where goal is already achieved
    if (calculatedAmount == 0.0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Goal Status',
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              border: Border.all(color: Colors.green.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green.shade600,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Goal already achieved!',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount needed per ${_selectedFrequency.displayName.toLowerCase()}',
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.calculate, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  CurrencyFormatter.formatAmountWithCurrency(calculatedAmount),
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFundSelector(List<Fund> funds) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Link to Fund (Optional)',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Fund?>(
              value: _selectedFund,
              isExpanded: true,
              hint: const Text(
                'Select a fund (optional)',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              onChanged: (Fund? newValue) {
                setState(() {
                  _selectedFund = newValue;
                });
              },
              items: [
                const DropdownMenuItem<Fund?>(
                  value: null,
                  child: Text(
                    'No fund selected',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
                ...funds.map((Fund fund) {
                  return DropdownMenuItem<Fund?>(
                    value: fund,
                    child: Text(
                      fund.name,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFundSelectorLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Link to Fund (Optional)',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Loading funds...',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFundSelectorError() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Link to Fund (Optional)',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            border: Border.all(color: Colors.red.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Failed to load funds',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              color: Colors.red.shade700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAllocationSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Investment Allocation',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Percentage of fund investments for this goal',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_allocationPercentage.toInt()}%',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppTheme.primaryColor,
                  inactiveTrackColor: Colors.grey.shade300,
                  thumbColor: AppTheme.primaryColor,
                  overlayColor: AppTheme.primaryColor.withOpacity(0.2),
                  valueIndicatorColor: AppTheme.primaryColor,
                  valueIndicatorTextStyle: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                child: Slider(
                  value: _allocationPercentage,
                  min: 0.0,
                  max: 100.0,
                  divisions: 20, // 5% increments
                  label: '${_allocationPercentage.toInt()}%',
                  onChanged: (double value) {
                    setState(() {
                      _allocationPercentage = value;
                    });
                    _onFieldChanged(); // Trigger calculation update
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '0%',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '100%',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressPreview() {
    if (_selectedFund == null || _targetAmountController.text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final targetAmount = double.tryParse(_targetAmountController.text.trim());
    if (targetAmount == null || targetAmount <= 0) {
      return const SizedBox.shrink();
    }

    final fundInvestmentsAsync = ref.watch(userFundInvestmentsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Progress Preview',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        fundInvestmentsAsync.when(
          data: (investmentsData) =>
              _buildProgressPreviewContent(targetAmount, investmentsData),
          loading: () => _buildProgressPreviewLoading(),
          error: (error, stack) => _buildProgressPreviewError(),
        ),
      ],
    );
  }

  Widget _buildProgressPreviewContent(
    double targetAmount,
    Map<String, dynamic> investmentsData,
  ) {
    final fundInvestments =
        investmentsData['fund_investments'] as Map<String, dynamic>? ?? {};
    final selectedFundId = _selectedFund!.id;
    final fundData = fundInvestments[selectedFundId] as Map<String, dynamic>?;

    final totalInvested = fundData?['total_invested'] as double? ?? 0.0;
    final allocatedAmount = totalInvested * (_allocationPercentage / 100.0);
    final remainingAmount = targetAmount - allocatedAmount;
    final progressPercentage = targetAmount > 0
        ? (allocatedAmount / targetAmount * 100).clamp(0, 100)
        : 0.0;

    developer.log(
      '🎯 [CREATE_GOAL_SCREEN] Progress calculation: '
      'Total invested: GHS $totalInvested, '
      'Allocation: ${_allocationPercentage}%, '
      'Allocated amount: GHS $allocatedAmount, '
      'Target: GHS $targetAmount, '
      'Progress: ${progressPercentage.toStringAsFixed(1)}%',
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: Colors.blue.shade600, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Current Progress in ${_selectedFund!.name}',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progressPercentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: progressPercentage >= 100
                      ? Colors.green
                      : AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Progress details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current: ${CurrencyFormatter.formatAmountWithCurrency(allocatedAmount)}',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 12,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${progressPercentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 12,
                  color: progressPercentage >= 100
                      ? Colors.green
                      : AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Text(
            'Target: ${CurrencyFormatter.formatAmountWithCurrency(targetAmount)}',
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              color: Colors.black87,
            ),
          ),

          if (remainingAmount > 0) ...[
            Text(
              'Remaining: ${CurrencyFormatter.formatAmountWithCurrency(remainingAmount)}',
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ] else ...[
            Text(
              'Goal achieved! 🎉',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12,
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],

          const SizedBox(height: 8),

          Text(
            'Based on ${_allocationPercentage.toInt()}% of your GHS ${totalInvested.toStringAsFixed(2)} investment',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 11,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressPreviewLoading() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Loading investment data...',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressPreviewError() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Unable to load investment data',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12,
                color: Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderSwitch() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enable Reminders',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Get notified based on your investment frequency',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _reminderEnabled,
            onChanged: (bool value) {
              setState(() {
                _reminderEnabled = value;
              });
            },
            activeColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Future<void> _selectTargetDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedTargetDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTargetDate) {
      setState(() {
        _selectedTargetDate = picked;
      });
      _onFieldChanged(); // Trigger calculation update
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedTargetDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a target date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Clear any existing error state before starting
    ref.read(goalsProvider.notifier).clearError();

    try {
      final request = CreateGoalRequest(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        targetAmount: double.parse(_targetAmountController.text),
        targetDate: _selectedTargetDate!.toIso8601String().split('T')[0],
        investmentFrequency: _selectedFrequency.value,
        linkedFund: _selectedFund?.id,
        reminderEnabled: _reminderEnabled,
        allocationPercentage: double.parse(
          _allocationPercentage.toStringAsFixed(2),
        ),
      );

      PersonalGoal? result;
      String operation = widget.goalToEdit != null ? 'update' : 'create';

      developer.log(
        '🎯 [CREATE_GOAL_SCREEN] Starting $operation goal operation',
      );

      if (widget.goalToEdit != null) {
        result = await ref
            .read(goalsProvider.notifier)
            .updateGoal(widget.goalToEdit!.id, request);
      } else {
        result = await ref.read(goalsProvider.notifier).createGoal(request);
      }

      developer.log(
        '🎯 [CREATE_GOAL_SCREEN] $operation result: ${result != null ? "success" : "null"}',
      );

      if (result != null) {
        developer.log(
          '🎯 [CREATE_GOAL_SCREEN] Goal ${operation}d successfully: ${result.id}',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.goalToEdit != null
                    ? 'Goal updated successfully!'
                    : 'Goal created successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to investments screen and refresh goals data
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/investments',
            (route) => route.settings.name == '/home' || route.isFirst,
          );
        }
      } else {
        // Check if there's an error in the provider state
        final goalsState = ref.read(goalsProvider);
        final errorMessage =
            goalsState.error ??
            (widget.goalToEdit != null
                ? 'Failed to update goal'
                : 'Failed to create goal');

        developer.log(
          '🎯 [CREATE_GOAL_SCREEN] Goal $operation failed: $errorMessage',
        );
        developer.log(
          '🎯 [CREATE_GOAL_SCREEN] Provider error state: ${goalsState.error}',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      developer.log('Error submitting goal: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
