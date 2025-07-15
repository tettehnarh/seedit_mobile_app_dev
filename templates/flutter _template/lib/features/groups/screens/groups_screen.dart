import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;

// Import standardized dialogs
import '../../../shared/widgets/dialogs/dialogs.dart';
import '../../../core/utils/app_theme.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../auth/providers/user_provider.dart';
import '../providers/groups_provider.dart';
import '../models/group_models.dart';
import 'group_detail_screen.dart';
import 'group_form_screen.dart';
import 'group_invitations_screen.dart';
import '../widgets/group_status_badge.dart';

class GroupsScreen extends ConsumerStatefulWidget {
  const GroupsScreen({super.key});

  @override
  ConsumerState<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends ConsumerState<GroupsScreen> {
  String _selectedTab = 'All Groups';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final List<String> _tabs = ['All Groups', 'My Groups', 'Public Groups'];

  @override
  void initState() {
    super.initState();
    // Load data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Load initial data (user data + groups data)
  Future<void> _loadInitialData() async {
    try {
      developer.log('🔄 Loading initial data for groups screen...');

      // Load user data and groups data concurrently
      await Future.wait([
        ref.read(userProvider.notifier).refreshUserData(),
        ref.read(groupsProvider.notifier).loadAllGroupsData(),
      ]);

      developer.log('✅ Initial data loaded for groups screen');
    } catch (e) {
      developer.log('❌ Error loading initial data: $e', error: e);
    }
  }

  /// Refresh all data
  Future<void> _refreshAllData() async {
    try {
      developer.log('🔄 Refreshing all data for groups screen...');

      await Future.wait([
        ref.read(userProvider.notifier).refreshUserData(),
        ref.read(groupsProvider.notifier).refreshGroups(),
      ]);

      developer.log('✅ All data refreshed for groups screen');
    } catch (e) {
      developer.log('❌ Error refreshing data: $e', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final user = userState.user;
    final isUserLoading = userState.isLoading;
    final isKycApproved = user?.isKycCompleted ?? false;

    // Debug logging for KYC status
    developer.log('🔍 Groups Screen - User: ${user?.email}');
    developer.log('🔍 Groups Screen - KYC Status: ${user?.kycStatus}');
    developer.log('🔍 Groups Screen - Is KYC Approved: $isKycApproved');
    developer.log('🔍 Groups Screen - Is User Loading: $isUserLoading');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Investment Groups',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading:
            false, // Remove back button for main navigation screen
        actions: [
          IconButton(
            icon: const Icon(Icons.mail_outline, color: AppTheme.primaryColor),
            onPressed: _viewInvitations,
          ),
        ],
      ),
      body: _buildBody(isUserLoading, isKycApproved),
      floatingActionButton: (!isUserLoading && isKycApproved)
          ? FloatingActionButton(
              heroTag: "groups_create",
              onPressed: () async {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GroupFormScreen(),
                  ),
                );

                // Refresh groups list if a new group was created
                if (result != null && mounted) {
                  await ref.read(groupsProvider.notifier).loadAllGroupsData();
                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Group created successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  /// Build the main body content based on loading and KYC status
  Widget _buildBody(bool isUserLoading, bool isKycApproved) {
    // Show loading indicator while user data is being loaded
    if (isUserLoading) {
      return _buildLoadingView();
    }

    // Show appropriate content based on KYC status
    return isKycApproved ? _buildGroupsContent() : _buildKycRequiredView();
  }

  /// Build loading view to prevent flashing
  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.primaryColor),
          SizedBox(height: 16),
          Text(
            'Loading...',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.companyInfoColor,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKycRequiredView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.group,
                size: 60,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'KYC Verification Required',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
                fontFamily: 'Montserrat',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Complete your KYC verification to access investment groups and start investing with others.',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.companyInfoColor,
                fontFamily: 'Montserrat',
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'COMPLETE KYC',
              onPressed: () => Navigator.pushNamed(context, '/kyc'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupsContent() {
    final groupsState = ref.watch(groupsProvider);

    return RefreshIndicator(
      onRefresh: _refreshAllData,
      child: CustomScrollView(
        slivers: [
          // Search bar
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search groups...',
                  hintStyle: const TextStyle(
                    fontFamily: 'Montserrat',
                    color: AppTheme.companyInfoColor,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppTheme.companyInfoColor,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: AppTheme.companyInfoColor,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryColor),
                  ),
                ),
              ),
            ),
          ),

          // Header stats
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                  Expanded(
                    child: _buildStatColumn(
                      '${groupsState.stats?.groupsJoined ?? 0}',
                      'Groups Joined',
                      Icons.group,
                    ),
                  ),
                  Container(width: 1, height: 40, color: Colors.grey[300]),
                  Expanded(
                    child: _buildStatColumn(
                      '${groupsState.stats?.totalMembersAcrossGroups ?? 0}',
                      'Total Members',
                      Icons.people,
                    ),
                  ),
                  Container(width: 1, height: 40, color: Colors.grey[300]),
                  Expanded(
                    child: _buildStatColumn(
                      'GHS ${_formatAmount(groupsState.stats?.totalContributions ?? 0)}',
                      'Total Invested',
                      Icons.account_balance_wallet,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Tab filters
          SliverToBoxAdapter(
            child: Container(
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _tabs.length,
                itemBuilder: (context, index) {
                  final tab = _tabs[index];
                  final isSelected = tab == _selectedTab;

                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: FilterChip(
                      label: Text(tab),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedTab = tab;
                        });
                      },
                      backgroundColor: Colors.white,
                      selectedColor: AppTheme.primaryColor,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppTheme.companyInfoColor,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Colors.grey[300]!,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Groups list
          if (groupsState.isLoading)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            )
          else if (groupsState.error != null)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Error loading groups',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        groupsState.error!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.companyInfoColor,
                          fontFamily: 'Montserrat',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: 'RETRY',
                        onPressed: _refreshAllData,
                        height: 40,
                        width: 120,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            _buildGroupsList(groupsState),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildGroupsList(GroupsState groupsState) {
    // Filter groups based on selected tab
    List<InvestmentGroup> filteredGroups = [];

    switch (_selectedTab) {
      case 'All Groups':
        filteredGroups = groupsState.allGroups;
        break;
      case 'My Groups':
        filteredGroups = groupsState.myGroups;
        break;
      case 'Public Groups':
        filteredGroups = groupsState.publicGroups;
        break;
      default:
        filteredGroups = groupsState.allGroups;
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredGroups = filteredGroups.where((group) {
        final query = _searchQuery.toLowerCase();
        return group.name.toLowerCase().contains(query) ||
            group.description.toLowerCase().contains(query) ||
            group.designatedFund.name.toLowerCase().contains(query) ||
            group.designatedFund.categoryName.toLowerCase().contains(query);
      }).toList();
    }

    if (filteredGroups.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Icon(
                  Icons.group_outlined,
                  size: 64,
                  color: AppTheme.companyInfoColor,
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isNotEmpty
                      ? 'No groups found for "$_searchQuery"'
                      : _selectedTab == 'All Groups'
                      ? 'No groups available'
                      : 'No groups found in $_selectedTab',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                    fontFamily: 'Montserrat',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _searchQuery.isNotEmpty
                      ? 'Try searching with different keywords'
                      : 'Check back later or create your own group!',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.companyInfoColor,
                    fontFamily: 'Montserrat',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        return _buildGroupCard(filteredGroups[index]);
      }, childCount: filteredGroups.length),
    );
  }

  Widget _buildGroupCard(InvestmentGroup group) {
    final isJoined =
        group.userMembership != null &&
        group.userMembership!.status == 'active';

    // Apply visual styling for inactive groups
    final isInactive = !group.isActive;
    final cardOpacity = isInactive ? 0.6 : 1.0;
    final cardColor = isInactive ? Colors.grey.shade50 : Colors.white;

    return Opacity(
      opacity: cardOpacity,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isInactive ? 0.04 : 0.08),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with gradient background
              Container(
                padding: const EdgeInsets.all(20),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                group.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                group.designatedFund.categoryName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              // Status badge for inactive groups (only for creators)
                              if (!group.isActive && group.isCreator) ...[
                                const SizedBox(height: 8),
                                GroupStatusBadge(
                                  status: group.status,
                                  statusDisplay: group.statusDisplay,
                                  isActive: group.isActive,
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isJoined
                                ? Colors.green.withValues(alpha: 0.2)
                                : Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isJoined ? Colors.lime : Colors.white,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            isJoined ? 'Joined' : 'Available',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isJoined ? Colors.white : Colors.white,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Progress bar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Progress',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            Text(
                              '${group.progressPercentage.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: group.progressPercentage / 100,
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Content section
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Stats row
                    Row(
                      children: [
                        Expanded(
                          child: _buildCardStatItem(
                            '${group.memberCount}',
                            'Members',
                            Icons.people_outline,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey[200],
                        ),
                        Expanded(
                          child: _buildCardStatItem(
                            'GHS ${_formatAmount(group.totalContributions)}',
                            'Invested',
                            Icons.account_balance_wallet_outlined,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey[200],
                        ),
                        Expanded(
                          child: _buildCardStatItem(
                            'GHS ${_formatAmount(group.targetAmount)}',
                            'Target',
                            Icons.flag_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: _getButtonText(group, isJoined),
                            onPressed: _canInteractWithGroup(group, isJoined)
                                ? () => _handleGroupAction(group, isJoined)
                                : null,
                            height: 44,
                            backgroundColor: _getButtonColor(group, isJoined),
                          ),
                        ),
                        if (!isJoined) ...[
                          const SizedBox(width: 12),
                          Container(
                            height: 44,
                            width: 44,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppTheme.primaryColor,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.info_outline,
                                color: AppTheme.primaryColor,
                                size: 20,
                              ),
                              onPressed: () => _showGroupInfo(group),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
            fontFamily: 'Montserrat',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.companyInfoColor,
            fontFamily: 'Montserrat',
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCardStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryColor),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
            fontFamily: 'Montserrat',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.companyInfoColor,
            fontFamily: 'Montserrat',
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Format amount with comma separators
  String _formatAmount(double amount) {
    return amount
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  /// Handle group action (join/view)
  Future<void> _handleGroupAction(InvestmentGroup group, bool isJoined) async {
    if (isJoined) {
      // Navigate to group detail screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GroupDetailScreen(groupId: group.id),
          ),
        );
      }
    } else {
      // Handle different actions based on group status
      if (!group.isActive &&
          group.isCreator &&
          group.status == 'pending_activation') {
        _showActivationDialog(group);
      } else if (group.isActive && group.canJoin) {
        // Join the group
        final success = await ref
            .read(groupsProvider.notifier)
            .joinGroup(group.id);

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Successfully joined ${group.name}!'),
                backgroundColor: Colors.green,
              ),
            );
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
      } else {
        _showUnavailableGroupDialog(group);
      }
    }
  }

  /// Show group information dialog using standardized dialog
  void _showGroupInfo(InvestmentGroup group) {
    BaseDialog.show(
      context: context,
      dialog: BaseDialog(
        title: group.name,
        titleIcon: Icons.info_outline,
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoSection('Description', group.description),
              const SizedBox(height: 16),
              _buildInfoSection('Investment Goal', group.investmentGoal),
              const SizedBox(height: 16),
              _buildInfoSection(
                'Target Amount',
                'GHS ${_formatAmount(group.targetAmount)}',
              ),
              const SizedBox(height: 16),
              _buildInfoSection('Fund Type', group.designatedFund.name),
            ],
          ),
        ),
        actions: [
          DialogButton(
            text: 'CLOSE',
            type: DialogButtonType.primary,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  /// Helper method to build info sections
  Widget _buildInfoSection(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
            fontSize: 14.0,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16.0,
            color: label == 'Target Amount'
                ? AppTheme.primaryColor
                : Colors.black87,
            fontWeight: label == 'Target Amount'
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  void _viewInvitations() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GroupInvitationsScreen()),
    );
  }

  /// Get button text based on group status and user membership
  String _getButtonText(InvestmentGroup group, bool isJoined) {
    if (isJoined) {
      return 'VIEW DETAILS';
    }

    if (!group.isActive) {
      if (group.isCreator) {
        switch (group.status) {
          case 'pending_activation':
            return 'ACTIVATE GROUP';
          case 'suspended':
            return 'SUSPENDED';
          case 'dissolved':
            return 'DISSOLVED';
          default:
            return 'UNAVAILABLE';
        }
      } else {
        return 'UNAVAILABLE';
      }
    }

    return 'JOIN GROUP';
  }

  /// Check if user can interact with the group
  bool _canInteractWithGroup(InvestmentGroup group, bool isJoined) {
    // Always allow viewing details if already joined
    if (isJoined) {
      return true;
    }

    // For inactive groups, only creators can interact (to activate)
    if (!group.isActive) {
      return group.isCreator && group.status == 'pending_activation';
    }

    // For active groups, allow joining if it's public and user can join
    return group.canJoin;
  }

  /// Get button color based on group status and user membership
  Color _getButtonColor(InvestmentGroup group, bool isJoined) {
    if (isJoined) {
      return AppTheme.primaryColor;
    }

    if (!group.isActive) {
      if (group.isCreator && group.status == 'pending_activation') {
        return Colors.orange; // Activation button
      } else {
        return Colors.grey; // Disabled state
      }
    }

    return AppTheme.primaryColor; // Join button
  }

  /// Show activation dialog for pending groups using standardized dialog
  void _showActivationDialog(InvestmentGroup group) {
    BaseDialog.show(
      context: context,
      dialog: BaseDialog(
        title: 'Activate Group',
        titleIcon: Icons.play_circle_outline,
        titleColor: Colors.orange,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To activate "${group.name}", you need:',
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16.0,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _buildRequirementItem('Exactly 3 group admins'),
            _buildRequirementItem('At least one completed contribution'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.3),
                  width: 1.0,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 20.0),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      'Once activated, members can join your group and start contributing.',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14.0,
                        color: Colors.orange[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          DialogButton(
            text: 'CANCEL',
            type: DialogButtonType.text,
            onPressed: () => Navigator.pop(context),
          ),
          DialogButton(
            text: 'MANAGE GROUP',
            type: DialogButtonType.primary,
            icon: Icons.settings,
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupDetailScreen(groupId: group.id),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Helper method to build requirement items
  Widget _buildRequirementItem(String requirement) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6.0, right: 8.0),
            width: 4.0,
            height: 4.0,
            decoration: const BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              requirement,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14.0,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show dialog for unavailable groups using standardized dialog
  void _showUnavailableGroupDialog(InvestmentGroup group) {
    String message;
    String title;
    MessageType messageType;

    if (!group.isActive) {
      switch (group.status) {
        case 'pending_activation':
          title = 'Group Not Active';
          message =
              'This group is still being set up and is not yet accepting members.';
          messageType = MessageType.warning;
          break;
        case 'suspended':
          title = 'Group Suspended';
          message =
              'This group has been temporarily suspended and is not accepting new members.';
          messageType = MessageType.warning;
          break;
        case 'dissolved':
          title = 'Group Dissolved';
          message =
              'This group has been permanently closed and is no longer available.';
          messageType = MessageType.error;
          break;
        default:
          title = 'Group Unavailable';
          message = 'This group is currently not available for joining.';
          messageType = MessageType.warning;
      }
    } else if (group.privacySetting == 'private') {
      title = 'Private Group';
      message = 'This is a private group. You need an invitation to join.';
      messageType = MessageType.info;
    } else {
      title = 'Cannot Join';
      message = 'You cannot join this group at the moment.';
      messageType = MessageType.info;
    }

    // Use appropriate static method based on message type
    switch (messageType) {
      case MessageType.error:
        MessageDialog.showError(
          context: context,
          title: title,
          message: message,
          buttonText: 'OK',
        );
        break;
      case MessageType.warning:
        MessageDialog.showWarning(
          context: context,
          title: title,
          message: message,
          buttonText: 'OK',
        );
        break;
      case MessageType.info:
        MessageDialog.showInfo(
          context: context,
          title: title,
          message: message,
          buttonText: 'OK',
        );
        break;
      case MessageType.success:
        MessageDialog.showSuccess(
          context: context,
          title: title,
          message: message,
          buttonText: 'OK',
        );
        break;
    }
  }
}
