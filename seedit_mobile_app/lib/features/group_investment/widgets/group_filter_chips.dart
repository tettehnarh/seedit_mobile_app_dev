import 'package:flutter/material.dart';

class GroupFilterChips extends StatefulWidget {
  final Function(Map<String, dynamic>)? onFiltersChanged;

  const GroupFilterChips({
    super.key,
    this.onFiltersChanged,
  });

  @override
  State<GroupFilterChips> createState() => _GroupFilterChipsState();
}

class _GroupFilterChipsState extends State<GroupFilterChips> {
  String? selectedType;
  String? selectedStatus;
  String? selectedSize;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Group Type Filters
          _buildFilterChip(
            'Investment Club',
            'investment_club',
            selectedType,
            (value) {
              setState(() {
                selectedType = selectedType == value ? null : value;
              });
              _notifyFiltersChanged();
            },
            Colors.purple,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            'Savings',
            'savings_group',
            selectedType,
            (value) {
              setState(() {
                selectedType = selectedType == value ? null : value;
              });
              _notifyFiltersChanged();
            },
            Colors.green,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            'Goal Based',
            'goal_based',
            selectedType,
            (value) {
              setState(() {
                selectedType = selectedType == value ? null : value;
              });
              _notifyFiltersChanged();
            },
            Colors.orange,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            'Challenge',
            'challenge',
            selectedType,
            (value) {
              setState(() {
                selectedType = selectedType == value ? null : value;
              });
              _notifyFiltersChanged();
            },
            Colors.red,
          ),
          
          const SizedBox(width: 16),
          
          // Status Filters
          _buildFilterChip(
            'Active',
            'active',
            selectedStatus,
            (value) {
              setState(() {
                selectedStatus = selectedStatus == value ? null : value;
              });
              _notifyFiltersChanged();
            },
            Colors.blue,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            'Joining',
            'joining',
            selectedStatus,
            (value) {
              setState(() {
                selectedStatus = selectedStatus == value ? null : value;
              });
              _notifyFiltersChanged();
            },
            Colors.teal,
          ),
          
          const SizedBox(width: 16),
          
          // Size Filters
          _buildFilterChip(
            'Small (≤10)',
            'small',
            selectedSize,
            (value) {
              setState(() {
                selectedSize = selectedSize == value ? null : value;
              });
              _notifyFiltersChanged();
            },
            Colors.indigo,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            'Large (>20)',
            'large',
            selectedSize,
            (value) {
              setState(() {
                selectedSize = selectedSize == value ? null : value;
              });
              _notifyFiltersChanged();
            },
            Colors.deepPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
    String? selectedValue,
    Function(String) onSelected,
    Color color,
  ) {
    final isSelected = selectedValue == value;
    
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isSelected ? color : Colors.grey[700],
        ),
      ),
      selected: isSelected,
      onSelected: (selected) => onSelected(value),
      selectedColor: color.withOpacity(0.2),
      backgroundColor: Colors.grey[100],
      checkmarkColor: color,
      side: BorderSide(
        color: isSelected ? color : Colors.grey[300]!,
        width: 1,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  void _notifyFiltersChanged() {
    if (widget.onFiltersChanged != null) {
      final filters = <String, dynamic>{};
      
      if (selectedType != null) {
        filters['type'] = selectedType;
      }
      
      if (selectedStatus != null) {
        filters['status'] = selectedStatus;
      }
      
      if (selectedSize != null) {
        filters['size'] = selectedSize;
      }
      
      widget.onFiltersChanged!(filters);
    }
  }
}

class GroupSortChips extends StatefulWidget {
  final Function(String)? onSortChanged;

  const GroupSortChips({
    super.key,
    this.onSortChanged,
  });

  @override
  State<GroupSortChips> createState() => _GroupSortChipsState();
}

class _GroupSortChipsState extends State<GroupSortChips> {
  String selectedSort = 'newest';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildSortChip('Newest', 'newest'),
          const SizedBox(width: 8),
          _buildSortChip('Most Funded', 'most_funded'),
          const SizedBox(width: 8),
          _buildSortChip('Most Members', 'most_members'),
          const SizedBox(width: 8),
          _buildSortChip('Ending Soon', 'ending_soon'),
          const SizedBox(width: 8),
          _buildSortChip('Target Amount', 'target_amount'),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = selectedSort == value;
    
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : Colors.grey[700],
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            selectedSort = value;
          });
          widget.onSortChanged?.call(value);
        }
      },
      selectedColor: Theme.of(context).primaryColor,
      backgroundColor: Colors.grey[100],
      side: BorderSide(
        color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
        width: 1,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}

class GroupCategoryChips extends StatelessWidget {
  final Function(String)? onCategorySelected;

  const GroupCategoryChips({
    super.key,
    this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'label': 'Technology', 'icon': Icons.computer, 'color': Colors.blue},
      {'label': 'Real Estate', 'icon': Icons.home, 'color': Colors.brown},
      {'label': 'Healthcare', 'icon': Icons.local_hospital, 'color': Colors.red},
      {'label': 'Education', 'icon': Icons.school, 'color': Colors.green},
      {'label': 'Energy', 'icon': Icons.bolt, 'color': Colors.orange},
      {'label': 'Finance', 'icon': Icons.account_balance, 'color': Colors.purple},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Popular Categories',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((category) {
            return ActionChip(
              avatar: Icon(
                category['icon'] as IconData,
                size: 16,
                color: category['color'] as Color,
              ),
              label: Text(
                category['label'] as String,
                style: const TextStyle(fontSize: 12),
              ),
              onPressed: () {
                onCategorySelected?.call(category['label'] as String);
              },
              backgroundColor: (category['color'] as Color).withOpacity(0.1),
              side: BorderSide(
                color: (category['color'] as Color).withOpacity(0.3),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class GroupTagChips extends StatelessWidget {
  final List<String> tags;
  final Function(String)? onTagSelected;
  final int maxTags;

  const GroupTagChips({
    super.key,
    required this.tags,
    this.onTagSelected,
    this.maxTags = 5,
  });

  @override
  Widget build(BuildContext context) {
    final displayTags = tags.take(maxTags).toList();
    
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: displayTags.map((tag) {
        return ActionChip(
          label: Text(
            tag,
            style: const TextStyle(fontSize: 10),
          ),
          onPressed: () => onTagSelected?.call(tag),
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          side: BorderSide(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      }).toList(),
    );
  }
}

class GroupFilterBottomSheet extends StatefulWidget {
  final Map<String, dynamic> initialFilters;
  final Function(Map<String, dynamic>) onFiltersApplied;

  const GroupFilterBottomSheet({
    super.key,
    this.initialFilters = const {},
    required this.onFiltersApplied,
  });

  @override
  State<GroupFilterBottomSheet> createState() => _GroupFilterBottomSheetState();
}

class _GroupFilterBottomSheetState extends State<GroupFilterBottomSheet> {
  late Map<String, dynamic> filters;

  @override
  void initState() {
    super.initState();
    filters = Map.from(widget.initialFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          const Text(
            'Filter Groups',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Group Type Section
          const Text(
            'Group Type',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          GroupFilterChips(
            onFiltersChanged: (newFilters) {
              setState(() {
                filters.addAll(newFilters);
              });
            },
          ),
          
          const SizedBox(height: 20),
          
          // Sort Section
          const Text(
            'Sort By',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          GroupSortChips(
            onSortChanged: (sort) {
              setState(() {
                filters['sort'] = sort;
              });
            },
          ),
          
          const SizedBox(height: 20),
          
          // Categories Section
          GroupCategoryChips(
            onCategorySelected: (category) {
              setState(() {
                filters['category'] = category;
              });
            },
          ),
          
          const SizedBox(height: 30),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      filters.clear();
                    });
                  },
                  child: const Text('Clear All'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onFiltersApplied(filters);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
