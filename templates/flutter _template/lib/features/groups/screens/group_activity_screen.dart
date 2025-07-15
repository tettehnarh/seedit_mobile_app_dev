import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_theme.dart';

import '../models/group_models.dart';
import '../providers/groups_provider.dart';

class GroupActivityScreen extends ConsumerWidget {
  final InvestmentGroup group;

  const GroupActivityScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the new paginated group activity provider
    final paginatedActivityState = ref.watch(
      paginatedGroupActivityProvider(group.id),
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Group Activity',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.primaryColor),
            onPressed: () {
              ref
                  .read(paginatedGroupActivityProvider(group.id).notifier)
                  .refresh();
            },
          ),
        ],
      ),
      body: _buildPaginatedActivityList(context, ref, paginatedActivityState),
    );
  }

  Widget _buildPaginatedActivityList(
    BuildContext context,
    WidgetRef ref,
    PaginatedGroupActivityState state,
  ) {
    if (state.error != null && state.activities.isEmpty) {
      return _buildErrorView(state.error!);
    }

    if (state.activities.isEmpty && state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    if (state.activities.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timeline_outlined,
              size: 64,
              color: AppTheme.companyInfoColor,
            ),
            SizedBox(height: 16),
            Text(
              'No activity yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.companyInfoColor,
                fontFamily: 'Montserrat',
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Group activities will appear here',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.companyInfoColor,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        // Load more when user scrolls to 80% of the list
        if (scrollInfo.metrics.pixels / scrollInfo.metrics.maxScrollExtent >
            0.8) {
          if (state.hasMore && !state.isLoading) {
            ref
                .read(paginatedGroupActivityProvider(group.id).notifier)
                .loadMoreActivities();
          }
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.activities.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.activities.length) {
            // Loading indicator at the bottom
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              ),
            );
          }

          final activity = state.activities[index];
          return _buildActivityCard(activity);
        },
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Error Loading Activity',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.companyInfoColor,
                fontFamily: 'Montserrat',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Retry loading activity
                // ref.invalidate(groupActivityProvider(group.id));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'RETRY',
                style: TextStyle(fontFamily: 'Montserrat'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(GroupActivity activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _getActivityTypeColor(
                activity.activityType,
              ).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              _getActivityTypeIcon(activity.activityType),
              color: _getActivityTypeColor(activity.activityType),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  activity.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (activity.contribution != null)
                      Text(
                        'GHS ${_formatAmount(activity.contribution!.amount)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  activity.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.companyInfoColor,
                    fontFamily: 'Montserrat',
                  ),
                ),

                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(activity.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.companyInfoColor,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getActivityTypeColor(
                          activity.activityType,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getActivityTypeDisplay(activity.activityType),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _getActivityTypeColor(activity.activityType),
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getActivityTypeColor(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'contribution':
        return Colors.green;
      case 'member_joined':
        return Colors.blue;
      case 'member_left':
        return Colors.orange;
      case 'admin_promoted':
        return Colors.purple;
      case 'admin_demoted':
        return Colors.grey;
      case 'group_activated':
        return Colors.teal;
      case 'announcement':
        return Colors.indigo;
      case 'withdrawal_request':
        return Colors.amber;
      case 'withdrawal_approved':
        return Colors.green;
      case 'withdrawal_rejected':
        return Colors.red;
      case 'investment_executed':
        return Colors.deepPurple;
      default:
        return AppTheme.companyInfoColor;
    }
  }

  IconData _getActivityTypeIcon(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'contribution':
        return Icons.account_balance_wallet;
      case 'member_joined':
        return Icons.person_add;
      case 'member_left':
        return Icons.person_remove;
      case 'admin_promoted':
        return Icons.admin_panel_settings;
      case 'admin_demoted':
        return Icons.remove_moderator;
      case 'group_activated':
        return Icons.check_circle;
      case 'announcement':
        return Icons.campaign;
      case 'withdrawal_request':
        return Icons.request_quote;
      case 'withdrawal_approved':
        return Icons.check_circle_outline;
      case 'withdrawal_rejected':
        return Icons.cancel_outlined;
      case 'investment_executed':
        return Icons.trending_up;
      default:
        return Icons.info;
    }
  }

  String _getActivityTypeDisplay(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'contribution':
        return 'CONTRIBUTION';
      case 'member_joined':
        return 'JOINED';
      case 'member_left':
        return 'LEFT';
      case 'admin_promoted':
        return 'PROMOTED';
      case 'admin_demoted':
        return 'DEMOTED';
      case 'group_activated':
        return 'ACTIVATED';
      case 'announcement':
        return 'ANNOUNCEMENT';
      case 'withdrawal_request':
        return 'WITHDRAWAL';
      case 'withdrawal_approved':
        return 'APPROVED';
      case 'withdrawal_rejected':
        return 'REJECTED';
      case 'investment_executed':
        return 'INVESTED';
      default:
        return activityType.toUpperCase();
    }
  }

  String _formatAmount(double amount) {
    return amount
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
