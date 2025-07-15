import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/group_investment_provider.dart';
import '../../../shared/models/group_investment_model.dart';
import '../widgets/group_card.dart';
import '../widgets/group_search_bar.dart';
import '../widgets/group_filter_chips.dart';

class GroupDiscoveryScreen extends ConsumerStatefulWidget {
  const GroupDiscoveryScreen({super.key});

  @override
  ConsumerState<GroupDiscoveryScreen> createState() => _GroupDiscoveryScreenState();
}

class _GroupDiscoveryScreenState extends ConsumerState<GroupDiscoveryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final publicGroups = ref.watch(publicGroupsProvider);
    final userGroups = ref.watch(userGroupsProvider);
    final searchState = ref.watch(groupSearchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Investment Groups'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/groups/create'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: GroupSearchBar(
              controller: _searchController,
              onChanged: (query) {
                ref.read(groupSearchProvider.notifier).searchGroups(query);
              },
              onClear: () {
                _searchController.clear();
                ref.read(groupSearchProvider.notifier).clearSearch();
              },
            ),
          ),

          // Filter chips
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: GroupFilterChips(),
          ),

          const SizedBox(height: 16),

          // Tab bar
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Discover'),
              Tab(text: 'My Groups'),
              Tab(text: 'Invitations'),
            ],
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Discover tab
                _buildDiscoverTab(publicGroups, searchState),
                
                // My Groups tab
                _buildMyGroupsTab(userGroups),
                
                // Invitations tab
                _buildInvitationsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/groups/create'),
        icon: const Icon(Icons.group_add),
        label: const Text('Create Group'),
      ),
    );
  }

  Widget _buildDiscoverTab(
    AsyncValue<List<InvestmentGroup>> publicGroups,
    GroupSearchState searchState,
  ) {
    // Show search results if searching
    if (searchState.query.isNotEmpty) {
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
              Text('Error: ${searchState.error}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(groupSearchProvider.notifier).searchGroups(searchState.query);
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
                'No groups found for "${searchState.query}"',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Try different keywords or create a new group',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          ref.read(groupSearchProvider.notifier).searchGroups(searchState.query);
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: searchState.results.length,
          itemBuilder: (context, index) {
            final group = searchState.results[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GroupCard(
                group: group,
                onTap: () => context.push('/groups/${group.id}'),
              ),
            );
          },
        ),
      );
    }

    // Show public groups
    return publicGroups.when(
      data: (groups) {
        if (groups.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.group_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No Public Groups Yet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                Text(
                  'Be the first to create an investment group!',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.refresh(publicGroupsProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GroupCard(
                  group: group,
                  onTap: () => context.push('/groups/${group.id}'),
                ),
              );
            },
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
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(publicGroupsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyGroupsTab(AsyncValue<List<InvestmentGroup>> userGroups) {
    return userGroups.when(
      data: (groups) {
        if (groups.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.group_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No Groups Yet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Join or create your first investment group',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => context.push('/groups/create'),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Group'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.refresh(userGroupsProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GroupCard(
                  group: group,
                  showMemberBadge: true,
                  onTap: () => context.push('/groups/${group.id}'),
                ),
              );
            },
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
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(userGroupsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvitationsTab() {
    final invitations = ref.watch(userInvitationsProvider);

    return invitations.when(
      data: (invites) {
        if (invites.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mail_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No Invitations',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                Text(
                  'You have no pending group invitations',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.refresh(userInvitationsProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: invites.length,
            itemBuilder: (context, index) {
              final invitation = invites[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildInvitationCard(invitation),
              );
            },
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
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(userInvitationsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvitationCard(GroupInvitation invitation) {
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
                    invitation.groupName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (invitation.isExpired)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Expired',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Invited by ${invitation.inviterName}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            
            if (invitation.message != null) ...[
              const SizedBox(height: 8),
              Text(
                invitation.message!,
                style: const TextStyle(fontSize: 14),
              ),
            ],
            
            const SizedBox(height: 16),
            
            if (invitation.isPending) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ref.read(groupManagementProvider.notifier)
                            .respondToInvitation(invitation.id, InvitationStatus.declined);
                      },
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ref.read(groupManagementProvider.notifier)
                            .respondToInvitation(invitation.id, InvitationStatus.accepted);
                      },
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Text(
                invitation.isAccepted ? 'Accepted' : 'Declined',
                style: TextStyle(
                  color: invitation.isAccepted ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
