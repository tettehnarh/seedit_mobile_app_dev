import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/fund_model.dart';
import '../../../shared/providers/fund_provider.dart';

class FundCategoryChips extends ConsumerWidget {
  final Function(FundCategory)? onCategorySelected;
  final bool showCounts;

  const FundCategoryChips({
    super.key,
    this.onCategorySelected,
    this.showCounts = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildCategoryChip(
            context,
            ref,
            'All',
            Icons.apps,
            null,
            Colors.blue,
          ),
          const SizedBox(width: 8),
          _buildCategoryChip(
            context,
            ref,
            'Equity',
            Icons.trending_up,
            FundCategory.equity,
            Colors.green,
          ),
          const SizedBox(width: 8),
          _buildCategoryChip(
            context,
            ref,
            'Bonds',
            Icons.account_balance,
            FundCategory.bond,
            Colors.orange,
          ),
          const SizedBox(width: 8),
          _buildCategoryChip(
            context,
            ref,
            'Mixed',
            Icons.pie_chart,
            FundCategory.mixed,
            Colors.purple,
          ),
          const SizedBox(width: 8),
          _buildCategoryChip(
            context,
            ref,
            'Money Market',
            Icons.savings,
            FundCategory.moneyMarket,
            Colors.teal,
          ),
          const SizedBox(width: 8),
          _buildCategoryChip(
            context,
            ref,
            'Real Estate',
            Icons.home,
            FundCategory.realEstate,
            Colors.brown,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    WidgetRef ref,
    String label,
    IconData icon,
    FundCategory? category,
    Color color,
  ) {
    return FutureBuilder<int>(
      future: _getFundCount(ref, category),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        
        return ActionChip(
          avatar: Icon(
            icon,
            size: 16,
            color: color,
          ),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
              if (showCounts && count > 0) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ],
          ),
          backgroundColor: color.withOpacity(0.1),
          side: BorderSide(color: color.withOpacity(0.3)),
          onPressed: () {
            if (onCategorySelected != null && category != null) {
              onCategorySelected!(category);
            } else if (category != null) {
              context.push('/funds/category/${category.name}');
            } else {
              // Show all funds
              context.push('/funds');
            }
          },
        );
      },
    );
  }

  Future<int> _getFundCount(WidgetRef ref, FundCategory? category) async {
    try {
      if (category == null) {
        final allFunds = await ref.read(allFundsProvider.future);
        return allFunds.length;
      } else {
        final categoryFunds = await ref.read(fundsByCategoryProvider(category).future);
        return categoryFunds.length;
      }
    } catch (e) {
      return 0;
    }
  }
}

class FundCategoryGrid extends ConsumerWidget {
  final Function(FundCategory)? onCategorySelected;

  const FundCategoryGrid({
    super.key,
    this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = [
      _CategoryData(
        category: FundCategory.equity,
        name: 'Equity Funds',
        description: 'Growth-focused investments',
        icon: Icons.trending_up,
        color: Colors.green,
      ),
      _CategoryData(
        category: FundCategory.bond,
        name: 'Bond Funds',
        description: 'Stable income investments',
        icon: Icons.account_balance,
        color: Colors.orange,
      ),
      _CategoryData(
        category: FundCategory.mixed,
        name: 'Mixed Funds',
        description: 'Balanced portfolios',
        icon: Icons.pie_chart,
        color: Colors.purple,
      ),
      _CategoryData(
        category: FundCategory.moneyMarket,
        name: 'Money Market',
        description: 'Short-term investments',
        icon: Icons.savings,
        color: Colors.teal,
      ),
      _CategoryData(
        category: FundCategory.realEstate,
        name: 'Real Estate',
        description: 'Property investments',
        icon: Icons.home,
        color: Colors.brown,
      ),
      _CategoryData(
        category: FundCategory.commodity,
        name: 'Commodities',
        description: 'Raw material investments',
        icon: Icons.grain,
        color: Colors.amber,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final categoryData = categories[index];
        return _buildCategoryCard(context, ref, categoryData);
      },
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    WidgetRef ref,
    _CategoryData categoryData,
  ) {
    return FutureBuilder<int>(
      future: _getFundCount(ref, categoryData.category),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              if (onCategorySelected != null) {
                onCategorySelected!(categoryData.category);
              } else {
                context.push('/funds/category/${categoryData.category.name}');
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: categoryData.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      categoryData.icon,
                      color: categoryData.color,
                      size: 24,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Text(
                    categoryData.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    categoryData.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  if (count > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: categoryData.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$count fund${count == 1 ? '' : 's'}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: categoryData.color,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<int> _getFundCount(WidgetRef ref, FundCategory category) async {
    try {
      final categoryFunds = await ref.read(fundsByCategoryProvider(category).future);
      return categoryFunds.length;
    } catch (e) {
      return 0;
    }
  }
}

class FundCategorySelector extends StatefulWidget {
  final List<FundCategory> selectedCategories;
  final Function(List<FundCategory>) onSelectionChanged;
  final bool multiSelect;

  const FundCategorySelector({
    super.key,
    required this.selectedCategories,
    required this.onSelectionChanged,
    this.multiSelect = true,
  });

  @override
  State<FundCategorySelector> createState() => _FundCategorySelectorState();
}

class _FundCategorySelectorState extends State<FundCategorySelector> {
  late List<FundCategory> _selectedCategories;

  @override
  void initState() {
    super.initState();
    _selectedCategories = List.from(widget.selectedCategories);
  }

  void _toggleCategory(FundCategory category) {
    setState(() {
      if (widget.multiSelect) {
        if (_selectedCategories.contains(category)) {
          _selectedCategories.remove(category);
        } else {
          _selectedCategories.add(category);
        }
      } else {
        _selectedCategories = [category];
      }
    });
    widget.onSelectionChanged(_selectedCategories);
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      _CategoryData(
        category: FundCategory.equity,
        name: 'Equity',
        description: 'Growth investments',
        icon: Icons.trending_up,
        color: Colors.green,
      ),
      _CategoryData(
        category: FundCategory.bond,
        name: 'Bonds',
        description: 'Income investments',
        icon: Icons.account_balance,
        color: Colors.orange,
      ),
      _CategoryData(
        category: FundCategory.mixed,
        name: 'Mixed',
        description: 'Balanced funds',
        icon: Icons.pie_chart,
        color: Colors.purple,
      ),
      _CategoryData(
        category: FundCategory.moneyMarket,
        name: 'Money Market',
        description: 'Short-term',
        icon: Icons.savings,
        color: Colors.teal,
      ),
      _CategoryData(
        category: FundCategory.realEstate,
        name: 'Real Estate',
        description: 'Property funds',
        icon: Icons.home,
        color: Colors.brown,
      ),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((categoryData) {
        final isSelected = _selectedCategories.contains(categoryData.category);
        
        return FilterChip(
          avatar: Icon(
            categoryData.icon,
            size: 16,
            color: isSelected ? Colors.white : categoryData.color,
          ),
          label: Text(
            categoryData.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : categoryData.color,
            ),
          ),
          selected: isSelected,
          selectedColor: categoryData.color,
          backgroundColor: categoryData.color.withOpacity(0.1),
          side: BorderSide(
            color: isSelected ? categoryData.color : categoryData.color.withOpacity(0.3),
          ),
          onSelected: (_) => _toggleCategory(categoryData.category),
        );
      }).toList(),
    );
  }
}

class _CategoryData {
  final FundCategory category;
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  _CategoryData({
    required this.category,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });
}
