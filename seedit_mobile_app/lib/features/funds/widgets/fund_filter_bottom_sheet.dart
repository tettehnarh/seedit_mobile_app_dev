import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/fund_model.dart';
import '../../../shared/providers/fund_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import 'fund_category_chips.dart';

class FundFilterBottomSheet extends ConsumerStatefulWidget {
  const FundFilterBottomSheet({super.key});

  @override
  ConsumerState<FundFilterBottomSheet> createState() => _FundFilterBottomSheetState();
}

class _FundFilterBottomSheetState extends ConsumerState<FundFilterBottomSheet> {
  late List<FundCategory> _selectedCategories;
  late List<RiskLevel> _selectedRiskLevels;
  double _minInvestment = 0;
  double _maxInvestment = 10000000;
  double _minReturn = 0;
  late List<String> _selectedTags;

  @override
  void initState() {
    super.initState();
    final filterState = ref.read(fundFilterProvider);
    _selectedCategories = List.from(filterState.selectedCategories);
    _selectedRiskLevels = List.from(filterState.selectedRiskLevels);
    _minInvestment = filterState.minInvestment ?? 0;
    _maxInvestment = filterState.maxInvestment ?? 10000000;
    _minReturn = filterState.minReturn ?? 0;
    _selectedTags = List.from(filterState.selectedTags);
  }

  void _applyFilters() {
    final filterNotifier = ref.read(fundFilterProvider.notifier);
    
    filterNotifier.updateCategories(_selectedCategories);
    filterNotifier.updateRiskLevels(_selectedRiskLevels);
    filterNotifier.updateInvestmentRange(
      _minInvestment > 0 ? _minInvestment : null,
      _maxInvestment < 10000000 ? _maxInvestment : null,
    );
    filterNotifier.updateMinReturn(_minReturn > 0 ? _minReturn : null);
    filterNotifier.updateTags(_selectedTags);
    
    Navigator.of(context).pop();
  }

  void _clearFilters() {
    setState(() {
      _selectedCategories.clear();
      _selectedRiskLevels.clear();
      _minInvestment = 0;
      _maxInvestment = 10000000;
      _minReturn = 0;
      _selectedTags.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter Funds',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text('Clear All'),
                ),
              ],
            ),
          ),

          const Divider(),

          // Filter content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categories
                  _buildSectionTitle('Categories'),
                  const SizedBox(height: 12),
                  FundCategorySelector(
                    selectedCategories: _selectedCategories,
                    onSelectionChanged: (categories) {
                      setState(() {
                        _selectedCategories = categories;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  // Risk Levels
                  _buildSectionTitle('Risk Level'),
                  const SizedBox(height: 12),
                  _buildRiskLevelSelector(),

                  const SizedBox(height: 24),

                  // Investment Range
                  _buildSectionTitle('Investment Range'),
                  const SizedBox(height: 12),
                  _buildInvestmentRangeSlider(),

                  const SizedBox(height: 24),

                  // Minimum Return
                  _buildSectionTitle('Minimum Annual Return'),
                  const SizedBox(height: 12),
                  _buildMinReturnSlider(),

                  const SizedBox(height: 24),

                  // Popular Tags
                  _buildSectionTitle('Popular Tags'),
                  const SizedBox(height: 12),
                  _buildTagSelector(),
                ],
              ),
            ),
          ),

          // Action buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Reset',
                    onPressed: _clearFilters,
                    isOutlined: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: 'Apply Filters',
                    onPressed: _applyFilters,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildRiskLevelSelector() {
    final riskLevels = [
      _RiskLevelData(RiskLevel.low, 'Low Risk', Colors.green),
      _RiskLevelData(RiskLevel.moderate, 'Moderate Risk', Colors.orange),
      _RiskLevelData(RiskLevel.high, 'High Risk', Colors.red),
      _RiskLevelData(RiskLevel.veryHigh, 'Very High Risk', Colors.purple),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: riskLevels.map((riskData) {
        final isSelected = _selectedRiskLevels.contains(riskData.level);
        
        return FilterChip(
          label: Text(
            riskData.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : riskData.color,
            ),
          ),
          selected: isSelected,
          selectedColor: riskData.color,
          backgroundColor: riskData.color.withOpacity(0.1),
          side: BorderSide(
            color: isSelected ? riskData.color : riskData.color.withOpacity(0.3),
          ),
          onSelected: (_) {
            setState(() {
              if (isSelected) {
                _selectedRiskLevels.remove(riskData.level);
              } else {
                _selectedRiskLevels.add(riskData.level);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildInvestmentRangeSlider() {
    return Column(
      children: [
        RangeSlider(
          values: RangeValues(_minInvestment, _maxInvestment),
          min: 0,
          max: 10000000,
          divisions: 100,
          labels: RangeLabels(
            _formatCurrency(_minInvestment),
            _formatCurrency(_maxInvestment),
          ),
          onChanged: (values) {
            setState(() {
              _minInvestment = values.start;
              _maxInvestment = values.end;
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Min: ${_formatCurrency(_minInvestment)}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              'Max: ${_formatCurrency(_maxInvestment)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMinReturnSlider() {
    return Column(
      children: [
        Slider(
          value: _minReturn,
          min: 0,
          max: 30,
          divisions: 30,
          label: '${_minReturn.toStringAsFixed(0)}%',
          onChanged: (value) {
            setState(() {
              _minReturn = value;
            });
          },
        ),
        Text(
          'Minimum: ${_minReturn.toStringAsFixed(0)}% annual return',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildTagSelector() {
    final popularTags = [
      'growth',
      'income',
      'conservative',
      'aggressive',
      'diversified',
      'long-term',
      'short-term',
      'stable',
      'high-yield',
      'low-fee',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: popularTags.map((tag) {
        final isSelected = _selectedTags.contains(tag);
        
        return FilterChip(
          label: Text(
            tag.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
          ),
          selected: isSelected,
          selectedColor: Theme.of(context).primaryColor,
          backgroundColor: Colors.grey[100],
          side: BorderSide(
            color: isSelected 
                ? Theme.of(context).primaryColor 
                : Colors.grey[300]!,
          ),
          onSelected: (_) {
            setState(() {
              if (isSelected) {
                _selectedTags.remove(tag);
              } else {
                _selectedTags.add(tag);
              }
            });
          },
        );
      }).toList(),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '₦${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '₦${(amount / 1000).toStringAsFixed(0)}K';
    }
    return '₦${amount.toStringAsFixed(0)}';
  }
}

class _RiskLevelData {
  final RiskLevel level;
  final String name;
  final Color color;

  _RiskLevelData(this.level, this.name, this.color);
}
