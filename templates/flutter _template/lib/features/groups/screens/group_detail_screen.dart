import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;

// Import standardized dialogs
import '../../../shared/widgets/dialogs/dialogs.dart';
import '../../../core/utils/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/custom_button.dart';
import '../providers/groups_provider.dart';
import '../models/group_models.dart';
import '../widgets/group_status_badge.dart';
import 'group_announcements_screen.dart';
import 'group_form_screen.dart';
import 'group_contribution_screen.dart';
import 'group_overview_screen.dart';
import 'group_members_screen.dart';
import 'group_financial_statement_screen.dart';
import 'group_activity_screen.dart';
import 'group_admin_voting_screen.dart';

class GroupDetailScreen extends ConsumerStatefulWidget {
  final String groupId;

  const GroupDetailScreen({super.key, required this.groupId});

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen> {
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final groupDetailAsync = ref.watch(groupDetailProvider(widget.groupId));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: groupDetailAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
        error: (error, stack) => _buildErrorView(error.toString()),
        data: (group) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(groupDetailProvider(widget.groupId));
            await ref.read(groupDetailProvider(widget.groupId).future);
          },
          color: AppTheme.primaryColor,
          child: _buildGroupDetailView(group),
        ),
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
              'Error Loading Group',
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
            CustomButton(
              text: 'RETRY',
              onPressed: () {
                ref.invalidate(groupDetailProvider(widget.groupId));
              },
              height: 40,
              width: 120,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupDetailView(InvestmentGroup group) {
    final isJoined =
        group.userMembership != null &&
        group.userMembership!.status == 'active';
    final isAdmin = group.userMembership?.role == 'admin';

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.primaryColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (isAdmin)
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () => _editGroup(group),
                ),
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () => _shareGroup(group),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () => _showMoreOptions(group),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                group.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(48),
                        child:
                            group.profileImage != null &&
                                group.profileImage!.isNotEmpty
                            ? Image.network(
                                group.profileImage!,
                                width: 96,
                                height: 96,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.group,
                                    size: 50,
                                    color: Colors.white,
                                  );
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      );
                                    },
                              )
                            : const Icon(
                                Icons.group,
                                size: 50,
                                color: Colors.white,
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        group.designatedFund.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      group.designatedFund.categoryName,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ];
      },
      body: Column(
        children: [
          // Progress and stats section
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Progress section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryColor.withValues(alpha: 0.1),
                        AppTheme.primaryColor.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Flexible(
                                child: Text(
                                  'Investment Progress',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${group.progressPercentage.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (!group.isActive) ...[
                            const SizedBox(height: 4),
                            GroupStatusBadge(
                              status: group.status,
                              statusDisplay: group.statusDisplay,
                              isActive: group.isActive,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: group.progressPercentage / 100,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryColor,
                          ),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'GHS ${_formatAmount(group.totalContributions)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          Text(
                            'GHS ${_formatAmount(group.targetAmount)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.companyInfoColor,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Stats section
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          'Target',
                          'GHS ${_formatAmount(group.targetAmount)}',
                          Icons.flag_outlined,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 50,
                        color: Colors.grey[200],
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Raised',
                          'GHS ${_formatAmount(group.totalContributions)}',
                          Icons.account_balance_wallet_outlined,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 50,
                        color: Colors.grey[200],
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Members',
                          '${group.memberCount}',
                          Icons.people_outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: isJoined
                ? Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Tooltip(
                          message: group.canContribute
                              ? 'Contribute to this group'
                              : group.contributionStatusMessage,
                          child: CustomButton(
                            text: 'CONTRIBUTE',
                            onPressed: group.canContribute
                                ? () => _contributeToGroup(group)
                                : null,
                            backgroundColor: group.canContribute
                                ? AppTheme.primaryColor
                                : Colors.grey[400]!,
                            height: 48,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red, width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.exit_to_app,
                            color: Colors.red,
                            size: 20,
                          ),
                          onPressed: () => _leaveGroup(group),
                        ),
                      ),
                    ],
                  )
                : group.canJoin
                ? CustomButton(
                    text: 'JOIN GROUP',
                    onPressed: () => _joinGroup(group),
                    backgroundColor: AppTheme.primaryColor,
                    height: 48,
                  )
                : Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          color: AppTheme.companyInfoColor,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Private Group',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.companyInfoColor,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 12),

          // Contribution status message for joined members
          if (isJoined && !group.canContribute)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      group.contributionStatusMessage,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange[700],
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: AppTheme.primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.companyInfoColor,
            fontFamily: 'Montserrat',
          ),
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    return amount
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  // Action methods
  Future<void> _joinGroup(InvestmentGroup group) async {
    final success = await ref.read(groupsProvider.notifier).joinGroup(group.id);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully joined ${group.name}!'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh the group data
        ref.invalidate(groupDetailProvider(widget.groupId));
      } else {
        final error = ref.read(groupsProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Failed to join group'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _leaveGroup(InvestmentGroup group) async {
    final confirmed = await ConfirmationDialog.showDestructive(
      context: context,
      title: 'Leave Group',
      message: 'Are you sure you want to leave ${group.name}?',
      confirmText: 'Leave',
      cancelText: 'Cancel',
      details: 'You will lose access to group activities and contributions.',
    );

    if (confirmed && mounted) {
      // Show loading dialog
      LoadingDialogManager.show(
        context: context,
        title: 'Leaving Group',
        message: 'Please wait...',
        icon: Icons.exit_to_app,
      );

      try {
        final success = await ref
            .read(groupsProvider.notifier)
            .leaveGroup(group.id);

        // Dismiss loading dialog
        LoadingDialogManager.dismiss();

        if (mounted) {
          if (success) {
            await MessageDialog.showSuccess(
              context: context,
              title: 'Left Group',
              message: 'You have successfully left the group.',
            );
            if (mounted) {
              Navigator.pop(context);
            }
          } else {
            final error = ref.read(groupsProvider).error;
            await MessageDialog.showError(
              context: context,
              title: 'Failed to Leave',
              message: error ?? 'Failed to leave group. Please try again.',
            );
          }
        }
      } catch (error) {
        // Dismiss loading dialog
        LoadingDialogManager.dismiss();

        if (mounted) {
          await MessageDialog.showError(
            context: context,
            title: 'Error',
            message: 'An error occurred while leaving the group.',
            details: 'Please check your internet connection and try again.',
          );
        }
      }
    }
  }

  void _contributeToGroup(InvestmentGroup group) {
    // Prevent multiple navigation calls
    if (_isNavigating || ModalRoute.of(context)?.isCurrent != true) return;

    setState(() => _isNavigating = true);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupContributionScreen(group: group),
      ),
    ).then((result) {
      // Reset navigation flag
      if (mounted) {
        setState(() => _isNavigating = false);

        // Refresh group data if contribution was made
        if (result == true) {
          // Invalidate both group detail and activity providers to ensure fresh data
          ref.invalidate(groupDetailProvider(widget.groupId));
          // Also refresh the groups list to update cached data
          ref.read(groupsProvider.notifier).refreshGroups();
        }
      }
    });
  }

  void _editGroup(InvestmentGroup group) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GroupFormScreen(group: group)),
    ).then((result) {
      // Refresh group data if updated
      if (result != null && mounted) {
        ref.invalidate(groupDetailProvider(widget.groupId));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Group updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _shareGroup(InvestmentGroup group) {
    // Create shareable content about the group
    final shareText =
        '''
🏦 Investment Group: ${group.name}

📊 Target Amount: ${CurrencyFormatter.formatAmountWithCurrency(group.targetAmount)}
💰 Raised: ${CurrencyFormatter.formatAmountWithCurrency(group.totalContributions)}
📈 Progress: ${group.progressPercentage.toStringAsFixed(1)}%
👥 Members: ${group.memberCount}
🎯 Fund: ${group.designatedFund.name}

${group.description}

Join us in achieving our investment goals together!
''';

    // Copy to clipboard and show feedback
    Clipboard.setData(ClipboardData(text: shareText)).then((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Group details copied to clipboard!',
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'SHARE',
            textColor: Colors.white,
            onPressed: () {
              // Show share options dialog
              _showShareOptionsDialog(group, shareText);
            },
          ),
        ),
      );
    });
  }

  void _showShareOptionsDialog(InvestmentGroup group, String shareText) {
    final shareOptions = [
      SelectionOption<String>(
        value: 'messages',
        title: 'Messages',
        subtitle: 'Share via messaging apps',
        icon: Icons.message,
      ),
      SelectionOption<String>(
        value: 'email',
        title: 'Email',
        subtitle: 'Share via email',
        icon: Icons.email,
      ),
      SelectionOption<String>(
        value: 'other',
        title: 'Other Apps',
        subtitle: 'Share via other apps',
        icon: Icons.share,
      ),
    ];

    SelectionDialog.show<String>(
      context: context,
      title: 'Share Group',
      subtitle:
          'Group details have been copied to your clipboard. Choose how to share:',
      options: shareOptions,
      icon: Icons.share,
    ).then((selectedOption) {
      if (selectedOption != null && mounted) {
        String message;
        switch (selectedOption) {
          case 'messages':
            message = 'Open your messaging app and paste the group details';
            break;
          case 'email':
            message = 'Open your email app and paste the group details';
            break;
          case 'other':
            message = 'Use any app to share the copied group details';
            break;
          default:
            message = 'Group details copied to clipboard';
        }
        _showInfoSnackBar(message);
      }
    });
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Montserrat'),
        ),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showMoreOptions(InvestmentGroup group) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Group Sections
                      ListTile(
                        leading: const Icon(
                          Icons.info_outline,
                          color: AppTheme.primaryColor,
                        ),
                        title: const Text(
                          'Overview',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: const Text(
                          'Group details and investment information',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 12,
                            color: AppTheme.companyInfoColor,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _navigateToOverview(group);
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.people_outline,
                          color: AppTheme.primaryColor,
                        ),
                        title: const Text(
                          'Members',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          '${group.memberCount} active members',
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 12,
                            color: AppTheme.companyInfoColor,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _navigateToMembers(group);
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.account_balance_outlined,
                          color: AppTheme.primaryColor,
                        ),
                        title: const Text(
                          'Financial Statement',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: const Text(
                          'View detailed financial reports',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 12,
                            color: AppTheme.companyInfoColor,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _navigateToFinancialStatement(group);
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.timeline_outlined,
                          color: AppTheme.primaryColor,
                        ),
                        title: const Text(
                          'Activity',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: const Text(
                          'Recent contributions and transactions',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 12,
                            color: AppTheme.companyInfoColor,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _navigateToActivity(group);
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.campaign_outlined,
                          color: AppTheme.primaryColor,
                        ),
                        title: const Text(
                          'Announcements',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: const Text(
                          'Important updates and news',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 12,
                            color: AppTheme.companyInfoColor,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _navigateToAnnouncements(group);
                        },
                      ),

                      // Admin Voting section (only for admins)
                      if (group.userMembership?.role == 'admin') ...[
                        ListTile(
                          leading: const Icon(
                            Icons.how_to_vote,
                            color: AppTheme.primaryColor,
                          ),
                          title: const Text(
                            'Admin Voting',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: const Text(
                            'Create polls and vote on admin decisions',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12,
                              color: AppTheme.companyInfoColor,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            _navigateToAdminVoting(group);
                          },
                        ),
                      ],

                      const Divider(height: 32),

                      // Additional Options
                      ListTile(
                        leading: const Icon(
                          Icons.share,
                          color: AppTheme.primaryColor,
                        ),
                        title: const Text(
                          'Share Group',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _shareGroup(group);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.report, color: Colors.orange),
                        title: const Text(
                          'Report Group',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _showReportDialog(group);
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Navigation methods for section cards
  void _navigateToOverview(InvestmentGroup group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupOverviewScreen(group: group),
      ),
    );
  }

  void _navigateToMembers(InvestmentGroup group) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GroupMembersScreen(group: group)),
    );
  }

  void _navigateToFinancialStatement(InvestmentGroup group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupFinancialStatementScreen(group: group),
      ),
    );
  }

  void _navigateToActivity(InvestmentGroup group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupActivityScreen(group: group),
      ),
    ).then((_) {
      // Refresh group data when returning from activity screen
      ref.invalidate(groupDetailProvider(widget.groupId));
    });
  }

  void _navigateToAnnouncements(InvestmentGroup group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupAnnouncementsScreen(group: group),
      ),
    );
  }

  void _navigateToAdminVoting(InvestmentGroup group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupAdminVotingScreen(group: group),
      ),
    );
  }

  void _showReportDialog(InvestmentGroup group) {
    final TextEditingController reasonController = TextEditingController();
    String selectedReason = 'Inappropriate content';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Report Group',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Why are you reporting "${group.name}"?',
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedReason,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items:
                        [
                          'Inappropriate content',
                          'Spam or misleading',
                          'Fraudulent activity',
                          'Harassment',
                          'Other',
                        ].map((String reason) {
                          return DropdownMenuItem<String>(
                            value: reason,
                            child: Text(
                              reason,
                              style: const TextStyle(fontFamily: 'Montserrat'),
                            ),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedReason = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: reasonController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Additional details (optional)',
                      hintStyle: const TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.grey,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _submitReport(group, selectedReason, reasonController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Submit Report',
                    style: TextStyle(fontFamily: 'Montserrat'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _submitReport(
    InvestmentGroup group,
    String reason,
    String details,
  ) async {
    // Show loading dialog
    LoadingDialogManager.show(
      context: context,
      title: 'Submitting Report',
      message: 'Please wait...',
      icon: Icons.report,
    );

    try {
      // Simulate API call - in a real app, this would send the report to the backend
      await Future.delayed(const Duration(seconds: 1));

      // Log the report for debugging
      developer.log('Report submitted for group: ${group.name}');
      developer.log('Reason: $reason');
      developer.log('Details: $details');

      // Dismiss loading dialog
      LoadingDialogManager.dismiss();

      if (mounted) {
        await MessageDialog.showSuccess(
          context: context,
          title: 'Report Submitted',
          message: 'Thank you for helping keep our community safe.',
          details: 'We will review your report and take appropriate action.',
        );
      }
    } catch (error) {
      // Dismiss loading dialog
      LoadingDialogManager.dismiss();

      if (mounted) {
        await MessageDialog.showError(
          context: context,
          title: 'Report Failed',
          message: 'Unable to submit your report. Please try again.',
          details: 'Check your internet connection and try again.',
        );
      }
    }
  }
}
