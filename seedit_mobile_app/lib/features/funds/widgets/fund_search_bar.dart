import 'package:flutter/material.dart';

class FundSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final VoidCallback? onClear;
  final String hintText;
  final bool autofocus;

  const FundSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onClear,
    this.hintText = 'Search funds...',
    this.autofocus = false,
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
        autofocus: autofocus,
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

class FundSearchDelegate extends SearchDelegate<String?> {
  final Function(String) onSearch;
  final List<String> suggestions;

  FundSearchDelegate({
    required this.onSearch,
    this.suggestions = const [],
  });

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
        close(context, null);
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
    final filteredSuggestions = suggestions
        .where((suggestion) => suggestion.toLowerCase().contains(query.toLowerCase()))
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

class FundSearchFilters extends StatelessWidget {
  final List<String> selectedCategories;
  final List<String> selectedRiskLevels;
  final Function(List<String>) onCategoriesChanged;
  final Function(List<String>) onRiskLevelsChanged;
  final VoidCallback? onClearFilters;

  const FundSearchFilters({
    super.key,
    required this.selectedCategories,
    required this.selectedRiskLevels,
    required this.onCategoriesChanged,
    required this.onRiskLevelsChanged,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final hasFilters = selectedCategories.isNotEmpty || selectedRiskLevels.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (hasFilters)
                TextButton(
                  onPressed: onClearFilters,
                  child: const Text('Clear All'),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Category filters
          const Text(
            'Categories',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Equity',
              'Bond',
              'Mixed',
              'Money Market',
              'Real Estate',
            ].map((category) {
              final isSelected = selectedCategories.contains(category);
              return FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  final newCategories = List<String>.from(selectedCategories);
                  if (selected) {
                    newCategories.add(category);
                  } else {
                    newCategories.remove(category);
                  }
                  onCategoriesChanged(newCategories);
                },
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          
          // Risk level filters
          const Text(
            'Risk Level',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Low Risk',
              'Moderate Risk',
              'High Risk',
              'Very High Risk',
            ].map((riskLevel) {
              final isSelected = selectedRiskLevels.contains(riskLevel);
              return FilterChip(
                label: Text(riskLevel),
                selected: isSelected,
                onSelected: (selected) {
                  final newRiskLevels = List<String>.from(selectedRiskLevels);
                  if (selected) {
                    newRiskLevels.add(riskLevel);
                  } else {
                    newRiskLevels.remove(riskLevel);
                  }
                  onRiskLevelsChanged(newRiskLevels);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class QuickSearchChips extends StatelessWidget {
  final Function(String) onChipTap;

  const QuickSearchChips({
    super.key,
    required this.onChipTap,
  });

  @override
  Widget build(BuildContext context) {
    final quickSearches = [
      'High Return',
      'Low Risk',
      'Equity Funds',
      'Bond Funds',
      'New Funds',
      'Popular',
    ];

    return Container(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: quickSearches.length,
        itemBuilder: (context, index) {
          final search = quickSearches[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(
                search,
                style: const TextStyle(fontSize: 12),
              ),
              onPressed: () => onChipTap(search),
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              side: BorderSide(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SearchHistory extends StatelessWidget {
  final List<String> history;
  final Function(String) onHistoryTap;
  final Function(String) onHistoryRemove;
  final VoidCallback? onClearHistory;

  const SearchHistory({
    super.key,
    required this.history,
    required this.onHistoryTap,
    required this.onHistoryRemove,
    this.onClearHistory,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Searches',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (onClearHistory != null)
                TextButton(
                  onPressed: onClearHistory,
                  child: const Text('Clear'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ...history.take(5).map((search) {
            return ListTile(
              leading: const Icon(Icons.history, size: 20),
              title: Text(search),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 16),
                onPressed: () => onHistoryRemove(search),
              ),
              onTap: () => onHistoryTap(search),
              contentPadding: EdgeInsets.zero,
              dense: true,
            );
          }).toList(),
        ],
      ),
    );
  }
}

class SearchSuggestions extends StatelessWidget {
  final List<String> suggestions;
  final Function(String) onSuggestionTap;

  const SearchSuggestions({
    super.key,
    required this.suggestions,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Suggestions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...suggestions.take(5).map((suggestion) {
            return ListTile(
              leading: const Icon(Icons.search, size: 20),
              title: Text(suggestion),
              onTap: () => onSuggestionTap(suggestion),
              contentPadding: EdgeInsets.zero,
              dense: true,
            );
          }).toList(),
        ],
      ),
    );
  }
}
