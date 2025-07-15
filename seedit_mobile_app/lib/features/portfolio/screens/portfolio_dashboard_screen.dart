import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/investment_provider.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/models/investment_model.dart';
import '../widgets/portfolio_summary_card.dart';
import '../widgets/portfolio_holdings_list.dart';
import '../widgets/portfolio_performance_chart.dart';
import '../widgets/asset_allocation_chart.dart';
import '../widgets/portfolio_actions_bar.dart';

class PortfolioDashboardScreen extends ConsumerStatefulWidget {
  const PortfolioDashboardScreen({super.key});

  @override
  ConsumerState<PortfolioDashboardScreen> createState() => _PortfolioDashboardScreenState();
}

class _PortfolioDashboardScreenState extends ConsumerState<PortfolioDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final portfolio = ref.watch(userPortfolioProvider);
    final investments = ref.watch(userInvestmentsProvider);

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in to view your portfolio'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Portfolio'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.refresh(userPortfolioProvider);
              ref.refresh(userInvestmentsProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showPortfolioMenu(context);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(userPortfolioProvider);
          ref.refresh(userInvestmentsProvider);
        },
        child: portfolio.when(
          data: (portfolioData) {
            if (portfolioData == null) {
              return _buildEmptyPortfolio();
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Portfolio summary
                  PortfolioSummaryCard(portfolio: portfolioData),
                  
                  const SizedBox(height: 24),
                  
                  // Portfolio actions
                  PortfolioActionsBar(
                    onInvestMore: () => context.push('/funds'),
                    onWithdraw: () => context.push('/portfolio/withdraw'),
                    onRebalance: () => context.push('/portfolio/rebalance'),
                    onAnalytics: () => context.push('/portfolio/analytics'),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Tab bar for different views
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Holdings'),
                      Tab(text: 'Performance'),
                      Tab(text: 'Allocation'),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Tab content
                  SizedBox(
                    height: 400,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Holdings tab
                        investments.when(
                          data: (investmentData) => PortfolioHoldingsList(
                            holdings: portfolioData.holdings,
                            investments: investmentData,
                          ),
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (error, stack) => Center(
                            child: Text('Error loading holdings: $error'),
                          ),
                        ),
                        
                        // Performance tab
                        PortfolioPerformanceChart(
                          performance: portfolioData.performance,
                          totalValue: portfolioData.totalValue,
                        ),
                        
                        // Allocation tab
                        AssetAllocationChart(
                          allocations: portfolioData.assetAllocation,
                          totalValue: portfolioData.totalValue,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Recent activity section
                  _buildRecentActivitySection(),
                  
                  const SizedBox(height: 24),
                  
                  // Portfolio insights
                  _buildPortfolioInsights(portfolioData),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading portfolio: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(userPortfolioProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/funds'),
        icon: const Icon(Icons.add),
        label: const Text('Invest'),
      ),
    );
  }

  Widget _buildEmptyPortfolio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.pie_chart_outline,
                size: 60,
                color: Colors.grey.shade400,
              ),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'Start Your Investment Journey',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'You haven\'t made any investments yet. Explore our funds and start building your portfolio today.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            ElevatedButton.icon(
              onPressed: () => context.push('/funds'),
              icon: const Icon(Icons.explore),
              label: const Text('Explore Funds'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            
            const SizedBox(height: 16),
            
            OutlinedButton.icon(
              onPressed: () => context.push('/onboarding'),
              icon: const Icon(Icons.school),
              label: const Text('Learn About Investing'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/portfolio/activity'),
              child: const Text('View All'),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Recent activity list
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildActivityItem(
                  'Investment Purchase',
                  'SeedIt Equity Growth Fund',
                  '₦50,000',
                  DateTime.now().subtract(const Duration(days: 2)),
                  Icons.trending_up,
                  Colors.green,
                ),
                const Divider(),
                _buildActivityItem(
                  'Investment Purchase',
                  'SeedIt Bond Income Fund',
                  '₦25,000',
                  DateTime.now().subtract(const Duration(days: 5)),
                  Icons.trending_up,
                  Colors.green,
                ),
                const Divider(),
                _buildActivityItem(
                  'Wallet Deposit',
                  'Bank Transfer',
                  '₦100,000',
                  DateTime.now().subtract(const Duration(days: 7)),
                  Icons.account_balance_wallet,
                  Colors.blue,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    String title,
    String subtitle,
    String amount,
    DateTime date,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amount,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPortfolioInsights(Portfolio portfolio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Portfolio Insights',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInsightItem(
                  'Diversification Score',
                  '8.5/10',
                  'Your portfolio is well diversified across asset classes',
                  Icons.pie_chart,
                  Colors.green,
                ),
                const Divider(),
                _buildInsightItem(
                  'Risk Level',
                  'Moderate',
                  'Your portfolio has a balanced risk profile',
                  Icons.speed,
                  Colors.orange,
                ),
                const Divider(),
                _buildInsightItem(
                  'Performance',
                  'Above Average',
                  'Your portfolio is outperforming the market',
                  Icons.trending_up,
                  Colors.green,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightItem(
    String title,
    String value,
    String description,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showPortfolioMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Portfolio Analytics'),
              onTap: () {
                Navigator.pop(context);
                context.push('/portfolio/analytics');
              },
            ),
            ListTile(
              leading: const Icon(Icons.balance),
              title: const Text('Rebalance Portfolio'),
              onTap: () {
                Navigator.pop(context);
                context.push('/portfolio/rebalance');
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Download Statement'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement statement download
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Portfolio Settings'),
              onTap: () {
                Navigator.pop(context);
                context.push('/portfolio/settings');
              },
            ),
          ],
        ),
      ),
    );
  }
}
