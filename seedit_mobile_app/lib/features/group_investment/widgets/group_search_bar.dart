import 'package:flutter/material.dart';

class GroupSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final String hintText;

  const GroupSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.onClear,
    this.hintText = 'Search investment groups...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey[500],
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey[500],
                  ),
                  onPressed: onClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}

class GroupSearchDelegate extends SearchDelegate<String> {
  final Function(String) onSearch;

  GroupSearchDelegate({required this.onSearch});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isNotEmpty) {
      onSearch(query);
    }
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = [
      'Tech investments',
      'Real estate',
      'Savings group',
      'Young professionals',
      'Long term growth',
      'Conservative investing',
    ];

    final filteredSuggestions = suggestions
        .where((suggestion) =>
            suggestion.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: filteredSuggestions.length,
      itemBuilder: (context, index) {
        final suggestion = filteredSuggestions[index];
        return ListTile(
          leading: const Icon(Icons.search),
          title: Text(suggestion),
          onTap: () {
            query = suggestion;
            showResults(context);
          },
        );
      },
    );
  }
}

class GroupSearchFilters extends StatefulWidget {
  final Function(Map<String, dynamic>) onFiltersChanged;

  const GroupSearchFilters({
    super.key,
    required this.onFiltersChanged,
  });

  @override
  State<GroupSearchFilters> createState() => _GroupSearchFiltersState();
}

class _GroupSearchFiltersState extends State<GroupSearchFilters> {
  String? selectedType;
  String? selectedPrivacy;
  RangeValues? targetAmountRange;
  int? maxMembers;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Filter Groups',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Group Type Filter
          const Text(
            'Group Type',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildFilterChip('Investment Club', 'investment_club'),
              _buildFilterChip('Savings Group', 'savings_group'),
              _buildFilterChip('Goal Based', 'goal_based'),
              _buildFilterChip('Challenge', 'challenge'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Privacy Filter
          const Text(
            'Privacy',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildPrivacyChip('Public', 'public'),
              _buildPrivacyChip('Invite Only', 'invite_only'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Target Amount Range
          const Text(
            'Target Amount Range',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          RangeSlider(
            values: targetAmountRange ?? const RangeValues(10000, 1000000),
            min: 10000,
            max: 5000000,
            divisions: 20,
            labels: RangeLabels(
              '₦${(targetAmountRange?.start ?? 10000).toStringAsFixed(0)}',
              '₦${(targetAmountRange?.end ?? 1000000).toStringAsFixed(0)}',
            ),
            onChanged: (values) {
              setState(() {
                targetAmountRange = values;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          // Max Members
          const Text(
            'Maximum Members',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: (maxMembers ?? 20).toDouble(),
            min: 5,
            max: 50,
            divisions: 9,
            label: '${maxMembers ?? 20} members',
            onChanged: (value) {
              setState(() {
                maxMembers = value.toInt();
              });
            },
          ),
          
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      selectedType = null;
                      selectedPrivacy = null;
                      targetAmountRange = null;
                      maxMembers = null;
                    });
                    widget.onFiltersChanged({});
                  },
                  child: const Text('Clear'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final filters = <String, dynamic>{};
                    if (selectedType != null) filters['type'] = selectedType;
                    if (selectedPrivacy != null) filters['privacy'] = selectedPrivacy;
                    if (targetAmountRange != null) {
                      filters['minAmount'] = targetAmountRange!.start;
                      filters['maxAmount'] = targetAmountRange!.end;
                    }
                    if (maxMembers != null) filters['maxMembers'] = maxMembers;
                    
                    widget.onFiltersChanged(filters);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = selectedType == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          selectedType = selected ? value : null;
        });
      },
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildPrivacyChip(String label, String value) {
    final isSelected = selectedPrivacy == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          selectedPrivacy = selected ? value : null;
        });
      },
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }
}

class GroupQuickSearch extends StatelessWidget {
  final Function(String) onQuickSearch;

  const GroupQuickSearch({
    super.key,
    required this.onQuickSearch,
  });

  @override
  Widget build(BuildContext context) {
    final quickSearches = [
      'Tech Groups',
      'Savings',
      'Real Estate',
      'Young Professionals',
      'Conservative',
      'High Growth',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Searches',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: quickSearches.map((search) {
            return ActionChip(
              label: Text(search),
              onPressed: () => onQuickSearch(search),
              backgroundColor: Colors.grey[100],
            );
          }).toList(),
        ),
      ],
    );
  }
}
