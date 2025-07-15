import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/goal_provider.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/models/goal_model.dart';
import '../widgets/goal_card.dart';
import '../widgets/goal_summary_card.dart';
import '../widgets/goal_calculator_widget.dart';

class GoalsDashboardScreen extends ConsumerStatefulWidget {
  const GoalsDashboardScreen({super.key});

  @override
  ConsumerState<GoalsDashboardScreen> createState() => _GoalsDashboardScreenState();
}

class _GoalsDashboardScreenState extends ConsumerState<GoalsDashboardScreen>
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
    final goals = ref.watch(userGoalsProvider);

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in to view your financial goals'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Goals'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/goals/create'),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showGoalsMenu(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(userGoalsProvider);
        },
        child: Column(
          children: [
            // Goals Summary
            goals.when(
              data: (goalsList) => GoalSummaryCard(goals: goalsList),
              loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
              error: (error, stack) => const SizedBox(),
            ),

            const SizedBox(height: 16),

            // Tab bar
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'My Goals'),
                Tab(text: 'Progress'),
                Tab(text: 'Calculator'),
              ],
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // My Goals tab
                  _buildGoalsTab(goals),
                  
                  // Progress tab
                  _buildProgressTab(goals),
                  
                  // Calculator tab
                  const GoalCalculatorWidget(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/goals/create'),
        icon: const Icon(Icons.flag),
        label: const Text('Create Goal'),
      ),
    );
  }

  Widget _buildGoalsTab(AsyncValue<List<FinancialGoal>> goals) {
    return goals.when(
      data: (goalsList) {
        if (goalsList.isEmpty) {
          return _buildEmptyGoals();
        }

        // Group goals by status
        final activeGoals = goalsList.where((goal) => goal.status == GoalStatus.active).toList();
        final completedGoals = goalsList.where((goal) => goal.status == GoalStatus.completed).toList();
        final pausedGoals = goalsList.where((goal) => goal.status == GoalStatus.paused).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (activeGoals.isNotEmpty) ...[
              _buildGoalSection('Active Goals', activeGoals, Colors.green),
              const SizedBox(height: 16),
            ],
            
            if (pausedGoals.isNotEmpty) ...[
              _buildGoalSection('Paused Goals', pausedGoals, Colors.orange),
              const SizedBox(height: 16),
            ],
            
            if (completedGoals.isNotEmpty) ...[
              _buildGoalSection('Completed Goals', completedGoals, Colors.blue),
            ],
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error loading goals: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(userGoalsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTab(AsyncValue<List<FinancialGoal>> goals) {
    return goals.when(
      data: (goalsList) {
        if (goalsList.isEmpty) {
          return _buildEmptyGoals();
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Overall progress summary
            _buildOverallProgress(goalsList),
            
            const SizedBox(height: 16),
            
            // Individual goal progress
            ...goalsList.map((goal) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildGoalProgressCard(goal),
            )).toList(),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error loading progress: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(userGoalsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyGoals() {
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
                Icons.flag,
                size: 60,
                color: Colors.grey.shade400,
              ),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'Set Your Financial Goals',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Create specific financial goals and track your progress towards achieving them.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            ElevatedButton.icon(
              onPressed: () => context.push('/goals/create'),
              icon: const Icon(Icons.add),
              label: const Text('Create Your First Goal'),
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
              label: const Text('Use Goal Calculator'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalSection(String title, List<FinancialGoal> goals, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '${goals.length}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        ...goals.map((goal) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GoalCard(
            goal: goal,
            onTap: () => context.push('/goals/${goal.id}'),
            onPause: goal.status == GoalStatus.active ? () => _pauseGoal(goal.id) : null,
            onResume: goal.status == GoalStatus.paused ? () => _resumeGoal(goal.id) : null,
            onComplete: goal.isCompleted && goal.status != GoalStatus.completed 
                ? () => _completeGoal(goal.id) : null,
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildOverallProgress(List<FinancialGoal> goals) {
    final totalTarget = goals.fold<double>(0, (sum, goal) => sum + goal.targetAmount);
    final totalCurrent = goals.fold<double>(0, (sum, goal) => sum + goal.currentAmount);
    final overallProgress = totalTarget > 0 ? (totalCurrent / totalTarget) * 100 : 0.0;
    
    final activeGoals = goals.where((goal) => goal.status == GoalStatus.active).length;
    final completedGoals = goals.where((goal) => goal.status == GoalStatus.completed).length;
    final onTrackGoals = goals.where((goal) => goal.isOnTrack).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overall Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Progress bar
            LinearProgressIndicator(
              value: overallProgress / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                overallProgress >= 100 ? Colors.green : Theme.of(context).primaryColor,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              '${overallProgress.toStringAsFixed(1)}% of total goals achieved',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Stats
            Row(
              children: [
                Expanded(
                  child: _buildProgressStat('Active', '$activeGoals', Colors.green),
                ),
                Expanded(
                  child: _buildProgressStat('Completed', '$completedGoals', Colors.blue),
                ),
                Expanded(
                  child: _buildProgressStat('On Track', '$onTrackGoals', Colors.orange),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalProgressCard(FinancialGoal goal) {
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
                    goal.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: goal.isOnTrack ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    goal.isOnTrack ? 'On Track' : 'Behind',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: goal.isOnTrack ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            LinearProgressIndicator(
              value: goal.progressPercentage / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                goal.isCompleted ? Colors.green : Theme.of(context).primaryColor,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${goal.progressPercentage.toStringAsFixed(1)}% complete',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${goal.daysRemaining} days left',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  goal.formattedCurrentAmount,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'of ${goal.formattedTargetAmount}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _pauseGoal(String goalId) {
    ref.read(goalManagementProvider.notifier).pauseGoal(goalId).then((success) {
      if (success) {
        ref.refresh(userGoalsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Goal paused successfully')),
        );
      }
    });
  }

  void _resumeGoal(String goalId) {
    ref.read(goalManagementProvider.notifier).resumeGoal(goalId).then((success) {
      if (success) {
        ref.refresh(userGoalsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Goal resumed successfully')),
        );
      }
    });
  }

  void _completeGoal(String goalId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Goal'),
        content: const Text('Mark this goal as completed? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(goalManagementProvider.notifier).completeGoal(goalId).then((success) {
                if (success) {
                  ref.refresh(userGoalsProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Goal completed! Congratulations!')),
                  );
                }
              });
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  void _showGoalsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Create New Goal'),
              onTap: () {
                Navigator.pop(context);
                context.push('/goals/create');
              },
            ),
            ListTile(
              leading: const Icon(Icons.calculate),
              title: const Text('Goal Calculator'),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Goals Analytics'),
              onTap: () {
                Navigator.pop(context);
                context.push('/goals/analytics');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Goal Settings'),
              onTap: () {
                Navigator.pop(context);
                context.push('/goals/settings');
              },
            ),
          ],
        ),
      ),
    );
  }
}
