import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/fund_provider.dart';
import '../../../shared/models/fund_model.dart';
import '../widgets/fund_card.dart';
import '../widgets/fund_search_bar.dart';
import '../widgets/fund_category_chips.dart';
import '../widgets/fund_filter_bottom_sheet.dart';

class FundDiscoveryScreen extends ConsumerStatefulWidget {
  const FundDiscoveryScreen({super.key});

  @override
  ConsumerState<FundDiscoveryScreen> createState() => _FundDiscoveryScreenState();
}

class _FundDiscoveryScreenState extends ConsumerState<FundDiscoveryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FundFilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(fundSearchProvider);
    final filterState = ref.watch(fundFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Funds'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.filter_list),
                if (filterState.hasActiveFilters)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: FundSearchBar(
              controller: _searchController,
              onChanged: (query) {
                ref.read(fundSearchProvider.notifier).searchFunds(query);
              },
              onClear: () {
                _searchController.clear();
                ref.read(fundSearchProvider.notifier).clearSearch();
              },
            ),
          ),

          // Show search results if searching
          if (searchState.query.isNotEmpty) ...[
            Expanded(
              child: _buildSearchResults(searchState),
            ),
          ] else if (filterState.hasActiveFilters) ...[
            // Show filtered results
            Expanded(
              child: _buildFilteredResults(filterState),
            ),
          ] else ...[
            // Category chips
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: FundCategoryChips(),
            ),

            const SizedBox(height: 16),

            // Tab bar
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: const [
                Tab(text: 'All Funds'),
                Tab(text: 'Trending'),
                Tab(text: 'Recommended'),
                Tab(text: 'Categories'),
              ],
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAllFundsTab(),
                  _buildTrendingFundsTab(),
                  _buildRecommendedFundsTab(),
                  _buildCategoriesTab(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchResults(FundSearchState searchState) {
    if (searchState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (searchState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: ${searchState.error}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(fundSearchProvider.notifier).searchFunds(searchState.query);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (searchState.results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No funds found for "${searchState.query}"',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your search terms',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: searchState.results.length,
      itemBuilder: (context, index) {
        final fund = searchState.results[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: FundCard(
            fund: fund,
            onTap: () => context.push('/funds/${fund.id}'),
          ),
        );
      },
    );
  }

  Widget _buildFilteredResults(FundFilterState filterState) {
    if (filterState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filterState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: ${filterState.error}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(fundFilterProvider.notifier).applyFilters();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (filterState.filteredFunds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.filter_list_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No funds match your filters',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your filter criteria',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(fundFilterProvider.notifier).clearFilters();
              },
              child: const Text('Clear Filters'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filterState.filteredFunds.length,
      itemBuilder: (context, index) {
        final fund = filterState.filteredFunds[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: FundCard(
            fund: fund,
            onTap: () => context.push('/funds/${fund.id}'),
          ),
        );
      },
    );
  }

  Widget _buildAllFundsTab() {
    final allFunds = ref.watch(allFundsProvider);

    return allFunds.when(
      data: (funds) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: funds.length,
        itemBuilder: (context, index) {
          final fund = funds[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: FundCard(
              fund: fund,
              onTap: () => context.push('/funds/${fund.id}'),
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(allFundsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingFundsTab() {
    final trendingFunds = ref.watch(trendingFundsProvider);

    return trendingFunds.when(
      data: (funds) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: funds.length,
        itemBuilder: (context, index) {
          final fund = funds[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: FundCard(
              fund: fund,
              onTap: () => context.push('/funds/${fund.id}'),
              showTrendingBadge: true,
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(trendingFundsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedFundsTab() {
    final recommendedFunds = ref.watch(recommendedFundsProvider);

    return recommendedFunds.when(
      data: (funds) {
        if (funds.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.recommend, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No recommendations available',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Complete your profile to get personalized recommendations',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: funds.length,
          itemBuilder: (context, index) {
            final fund = funds[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: FundCard(
                fund: fund,
                onTap: () => context.push('/funds/${fund.id}'),
                showRecommendedBadge: true,
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(recommendedFundsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategorySection('Equity Funds', FundCategory.equity),
          const SizedBox(height: 24),
          _buildCategorySection('Bond Funds', FundCategory.bond),
          const SizedBox(height: 24),
          _buildCategorySection('Mixed Funds', FundCategory.mixed),
          const SizedBox(height: 24),
          _buildCategorySection('Money Market', FundCategory.moneyMarket),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String title, FundCategory category) {
    final categoryFunds = ref.watch(fundsByCategoryProvider(category));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to category-specific screen
                context.push('/funds/category/${category.name}');
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        categoryFunds.when(
          data: (funds) {
            if (funds.isEmpty) {
              return const Text(
                'No funds available in this category',
                style: TextStyle(color: Colors.grey),
              );
            }

            return SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: funds.take(5).length,
                itemBuilder: (context, index) {
                  final fund = funds[index];
                  return Container(
                    width: 300,
                    margin: const EdgeInsets.only(right: 16),
                    child: FundCard(
                      fund: fund,
                      onTap: () => context.push('/funds/${fund.id}'),
                      isCompact: true,
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => SizedBox(
            height: 200,
            child: Center(
              child: Text(
                'Error loading $title',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
