import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/sip_provider.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/models/sip_model.dart';
import '../widgets/sip_card.dart';
import '../widgets/sip_summary_card.dart';
import '../widgets/sip_calculator_widget.dart';

class SIPDashboardScreen extends ConsumerStatefulWidget {
  const SIPDashboardScreen({super.key});

  @override
  ConsumerState<SIPDashboardScreen> createState() => _SIPDashboardScreenState();
}

class _SIPDashboardScreenState extends ConsumerState<SIPDashboardScreen>
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
    final sipPlans = ref.watch(userSIPPlansProvider);
    final autoRules = ref.watch(autoInvestmentRulesProvider);

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in to view your SIP plans'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('SIP & Auto Invest'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/sip/create'),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showSIPMenu(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(userSIPPlansProvider);
          ref.refresh(autoInvestmentRulesProvider);
        },
        child: Column(
          children: [
            // SIP Summary
            sipPlans.when(
              data: (plans) => SIPSummaryCard(sipPlans: plans),
              loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
              error: (error, stack) => const SizedBox(),
            ),

            const SizedBox(height: 16),

            // Tab bar
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'My SIPs'),
                Tab(text: 'Auto Rules'),
                Tab(text: 'Calculator'),
              ],
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // My SIPs tab
                  _buildSIPsTab(sipPlans),
                  
                  // Auto Rules tab
                  _buildAutoRulesTab(autoRules),
                  
                  // Calculator tab
                  const SIPCalculatorWidget(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/sip/create'),
        icon: const Icon(Icons.add),
        label: const Text('Create SIP'),
      ),
    );
  }

  Widget _buildSIPsTab(AsyncValue<List<SIPPlan>> sipPlans) {
    return sipPlans.when(
      data: (plans) {
        if (plans.isEmpty) {
          return _buildEmptySIPs();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: plans.length,
          itemBuilder: (context, index) {
            final sip = plans[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SIPCard(
                sip: sip,
                onTap: () => context.push('/sip/${sip.id}'),
                onPause: sip.isActive ? () => _pauseSIP(sip.id) : null,
                onResume: sip.isPaused ? () => _resumeSIP(sip.id) : null,
                onCancel: () => _cancelSIP(sip.id),
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
            Text('Error loading SIP plans: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(userSIPPlansProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoRulesTab(AsyncValue<List<AutoInvestmentRule>> autoRules) {
    return autoRules.when(
      data: (rules) {
        if (rules.isEmpty) {
          return _buildEmptyAutoRules();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: rules.length,
          itemBuilder: (context, index) {
            final rule = rules[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildAutoRuleCard(rule),
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
            Text('Error loading auto rules: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(autoInvestmentRulesProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySIPs() {
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
                Icons.schedule,
                size: 60,
                color: Colors.grey.shade400,
              ),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'Start Your SIP Journey',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Create systematic investment plans to build wealth consistently over time.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            ElevatedButton.icon(
              onPressed: () => context.push('/sip/create'),
              icon: const Icon(Icons.add),
              label: const Text('Create Your First SIP'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            
            const SizedBox(height: 16),
            
            OutlinedButton.icon(
              onPressed: () {
                _tabController.animateTo(2); // Switch to calculator tab
              },
              icon: const Icon(Icons.calculate),
              label: const Text('Use SIP Calculator'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyAutoRules() {
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
                Icons.smart_toy,
                size: 60,
                color: Colors.grey.shade400,
              ),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'Automate Your Investments',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Set up smart rules to automatically invest based on your salary, wallet balance, or market conditions.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            ElevatedButton.icon(
              onPressed: () => context.push('/sip/auto-rules/create'),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Create Auto Rule'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoRuleCard(AutoInvestmentRule rule) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    rule.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: rule.isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    rule.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: rule.isActive ? Colors.green : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            
            if (rule.description != null) ...[
              const SizedBox(height: 8),
              Text(
                rule.description!,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Icon(
                  _getTriggerIcon(rule.trigger),
                  size: 16,
                  color: Colors.blue,
                ),
                const SizedBox(width: 4),
                Text(
                  _getTriggerText(rule.trigger),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  'Triggered ${rule.triggerCount} times',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTriggerIcon(AutoInvestmentTrigger trigger) {
    switch (trigger) {
      case AutoInvestmentTrigger.salaryCredit:
        return Icons.account_balance_wallet;
      case AutoInvestmentTrigger.walletBalance:
        return Icons.wallet;
      case AutoInvestmentTrigger.marketCondition:
        return Icons.trending_up;
      case AutoInvestmentTrigger.dateBased:
        return Icons.calendar_today;
      case AutoInvestmentTrigger.goalProgress:
        return Icons.flag;
    }
  }

  String _getTriggerText(AutoInvestmentTrigger trigger) {
    switch (trigger) {
      case AutoInvestmentTrigger.salaryCredit:
        return 'Salary Credit';
      case AutoInvestmentTrigger.walletBalance:
        return 'Wallet Balance';
      case AutoInvestmentTrigger.marketCondition:
        return 'Market Condition';
      case AutoInvestmentTrigger.dateBased:
        return 'Date Based';
      case AutoInvestmentTrigger.goalProgress:
        return 'Goal Progress';
    }
  }

  void _pauseSIP(String sipId) {
    ref.read(sipManagementProvider.notifier).pauseSIPPlan(sipId).then((success) {
      if (success) {
        ref.refresh(userSIPPlansProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('SIP paused successfully')),
        );
      }
    });
  }

  void _resumeSIP(String sipId) {
    ref.read(sipManagementProvider.notifier).resumeSIPPlan(sipId).then((success) {
      if (success) {
        ref.refresh(userSIPPlansProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('SIP resumed successfully')),
        );
      }
    });
  }

  void _cancelSIP(String sipId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel SIP'),
        content: const Text('Are you sure you want to cancel this SIP? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(sipManagementProvider.notifier).cancelSIPPlan(sipId).then((success) {
                if (success) {
                  ref.refresh(userSIPPlansProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('SIP cancelled successfully')),
                  );
                }
              });
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _showSIPMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Create New SIP'),
              onTap: () {
                Navigator.pop(context);
                context.push('/sip/create');
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_awesome),
              title: const Text('Create Auto Rule'),
              onTap: () {
                Navigator.pop(context);
                context.push('/sip/auto-rules/create');
              },
            ),
            ListTile(
              leading: const Icon(Icons.calculate),
              title: const Text('SIP Calculator'),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('SIP Analytics'),
              onTap: () {
                Navigator.pop(context);
                context.push('/sip/analytics');
              },
            ),
          ],
        ),
      ),
    );
  }
}
