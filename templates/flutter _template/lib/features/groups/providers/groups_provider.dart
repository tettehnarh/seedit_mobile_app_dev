import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import 'dart:io';
import '../../../core/api/api_client.dart';
import '../services/groups_service.dart';
import '../models/group_models.dart';

// API Client provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// Service provider
final groupsServiceProvider = Provider<GroupsService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return GroupsService(apiClient);
});

// Groups state
class GroupsState {
  final List<InvestmentGroup> allGroups;
  final List<InvestmentGroup> myGroups;
  final List<InvestmentGroup> publicGroups;
  final GroupStats? stats;
  final bool isLoading;
  final String? error;

  // Admin management state
  final Map<String, List<GroupMembership>> groupAdmins;
  final bool isLoadingAdmins;
  final String? adminError;

  // Voting system state
  final Map<String, List<AdminPoll>> groupPolls;
  final bool isLoadingPolls;
  final String? pollError;

  const GroupsState({
    this.allGroups = const [],
    this.myGroups = const [],
    this.publicGroups = const [],
    this.stats,
    this.isLoading = false,
    this.error,
    this.groupAdmins = const {},
    this.isLoadingAdmins = false,
    this.adminError,
    this.groupPolls = const {},
    this.isLoadingPolls = false,
    this.pollError,
  });

  GroupsState copyWith({
    List<InvestmentGroup>? allGroups,
    List<InvestmentGroup>? myGroups,
    List<InvestmentGroup>? publicGroups,
    GroupStats? stats,
    bool? isLoading,
    String? error,
    Map<String, List<GroupMembership>>? groupAdmins,
    bool? isLoadingAdmins,
    String? adminError,
    Map<String, List<AdminPoll>>? groupPolls,
    bool? isLoadingPolls,
    String? pollError,
  }) {
    return GroupsState(
      allGroups: allGroups ?? this.allGroups,
      myGroups: myGroups ?? this.myGroups,
      publicGroups: publicGroups ?? this.publicGroups,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      groupAdmins: groupAdmins ?? this.groupAdmins,
      isLoadingAdmins: isLoadingAdmins ?? this.isLoadingAdmins,
      adminError: adminError,
      groupPolls: groupPolls ?? this.groupPolls,
      isLoadingPolls: isLoadingPolls ?? this.isLoadingPolls,
      pollError: pollError,
    );
  }
}

// Groups provider
class GroupsNotifier extends StateNotifier<GroupsState> {
  final GroupsService _groupsService;

  GroupsNotifier(this._groupsService) : super(const GroupsState());

  /// Load all groups data
  Future<void> loadAllGroupsData() async {
    try {
      developer.log('🔄 [GROUPS_PROVIDER] Loading all groups data...');
      state = state.copyWith(isLoading: true, error: null);

      // Load all data concurrently
      final futures = await Future.wait([
        _groupsService.getAllGroups(),
        _groupsService.getMyGroups(),
        _groupsService.getPublicGroups(),
        _groupsService.getGroupStats(),
      ]);

      state = state.copyWith(
        allGroups: futures[0] as List<InvestmentGroup>,
        myGroups: futures[1] as List<InvestmentGroup>,
        publicGroups: futures[2] as List<InvestmentGroup>,
        stats: futures[3] as GroupStats,
        isLoading: false,
      );

      developer.log('✅ [GROUPS_PROVIDER] Loaded all groups data successfully');
    } catch (e) {
      developer.log(
        '❌ [GROUPS_PROVIDER] Error loading groups data: $e',
        error: e,
      );
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Refresh groups data
  Future<void> refreshGroups() async {
    await loadAllGroupsData();
  }

  /// Load user's groups only
  Future<void> loadMyGroups() async {
    try {
      developer.log('🔄 [GROUPS_PROVIDER] Loading user groups...');
      final myGroups = await _groupsService.getMyGroups();

      state = state.copyWith(myGroups: myGroups);
      developer.log('✅ [GROUPS_PROVIDER] Loaded user groups successfully');
    } catch (e) {
      developer.log(
        '❌ [GROUPS_PROVIDER] Error loading user groups: $e',
        error: e,
      );
      state = state.copyWith(error: e.toString());
    }
  }

  /// Load public groups only
  Future<void> loadPublicGroups() async {
    try {
      developer.log('🔄 [GROUPS_PROVIDER] Loading public groups...');
      final publicGroups = await _groupsService.getPublicGroups();

      state = state.copyWith(publicGroups: publicGroups);
      developer.log('✅ [GROUPS_PROVIDER] Loaded public groups successfully');
    } catch (e) {
      developer.log(
        '❌ [GROUPS_PROVIDER] Error loading public groups: $e',
        error: e,
      );
      state = state.copyWith(error: e.toString());
    }
  }

  /// Create a new group
  Future<InvestmentGroup?> createGroup(
    Map<String, dynamic> groupData, [
    File? imageFile,
  ]) async {
    try {
      developer.log('🔄 [GROUPS_PROVIDER] Creating group...');
      final newGroup = await _groupsService.createGroup(groupData, imageFile);

      // Add to state
      state = state.copyWith(
        allGroups: [...state.allGroups, newGroup],
        myGroups: [...state.myGroups, newGroup],
      );

      developer.log('✅ [GROUPS_PROVIDER] Group created successfully');
      return newGroup;
    } catch (e) {
      developer.log('❌ [GROUPS_PROVIDER] Error creating group: $e', error: e);
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Update a group
  Future<InvestmentGroup?> updateGroup(
    String groupId,
    Map<String, dynamic> groupData, [
    File? imageFile,
  ]) async {
    try {
      developer.log('🔄 [GROUPS_PROVIDER] Updating group...');
      final updatedGroup = await _groupsService.updateGroup(
        groupId,
        groupData,
        imageFile,
      );

      // Update in state
      state = state.copyWith(
        allGroups: state.allGroups
            .map((g) => g.id == groupId ? updatedGroup : g)
            .toList(),
        myGroups: state.myGroups
            .map((g) => g.id == groupId ? updatedGroup : g)
            .toList(),
      );

      developer.log('✅ [GROUPS_PROVIDER] Group updated successfully');
      return updatedGroup;
    } catch (e) {
      developer.log('❌ [GROUPS_PROVIDER] Error updating group: $e', error: e);
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Delete a group
  Future<bool> deleteGroup(String groupId) async {
    try {
      developer.log('🔄 [GROUPS_PROVIDER] Deleting group...');
      await _groupsService.deleteGroup(groupId);

      // Remove from state
      state = state.copyWith(
        allGroups: state.allGroups.where((g) => g.id != groupId).toList(),
        myGroups: state.myGroups.where((g) => g.id != groupId).toList(),
        publicGroups: state.publicGroups.where((g) => g.id != groupId).toList(),
      );

      developer.log('✅ [GROUPS_PROVIDER] Group deleted successfully');
      return true;
    } catch (e) {
      developer.log('❌ [GROUPS_PROVIDER] Error deleting group: $e', error: e);
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Join a group
  Future<bool> joinGroup(String groupId) async {
    try {
      developer.log(
        '🔄 [GROUPS_PROVIDER] === JOIN GROUP PROVIDER DEBUG START ===',
      );

      developer.log('🔍 [GROUPS_PROVIDER] Joining group: $groupId');
      developer.log(
        '🔍 [GROUPS_PROVIDER] Group ID type: ${groupId.runtimeType}',
      );
      developer.log('🔍 [GROUPS_PROVIDER] Group ID length: ${groupId.length}');

      // Log current state
      developer.log(
        '🔍 [GROUPS_PROVIDER] Current state - My groups: ${state.myGroups.length}',
      );
      developer.log(
        '🔍 [GROUPS_PROVIDER] Current state - Public groups: ${state.publicGroups.length}',
      );
      developer.log(
        '🔍 [GROUPS_PROVIDER] Current state - All groups: ${state.allGroups.length}',
      );
      developer.log(
        '🔍 [GROUPS_PROVIDER] Current state - My groups: ${state.myGroups.length}',
      );
      developer.log(
        '🔍 [GROUPS_PROVIDER] Current state - Public groups: ${state.publicGroups.length}',
      );
      developer.log(
        '🔍 [GROUPS_PROVIDER] Current state - All groups: ${state.allGroups.length}',
      );

      // Find the group to join
      developer.log(
        '🔍 [GROUPS_PROVIDER] Looking for group in public groups...',
      );

      InvestmentGroup? targetGroup;
      try {
        targetGroup = state.publicGroups.firstWhere((g) => g.id == groupId);
        developer.log(
          '✅ [GROUPS_PROVIDER] Found group in public groups: ${targetGroup.name}',
        );
      } catch (e) {
        developer.log(
          '❌ [GROUPS_PROVIDER] Group not found in public groups: $e',
        );

        // Try to find in all groups
        try {
          targetGroup = state.allGroups.firstWhere((g) => g.id == groupId);
          developer.log(
            '✅ [GROUPS_PROVIDER] Found group in all groups: ${targetGroup.name}',
          );
        } catch (e2) {
          developer.log('❌ [GROUPS_PROVIDER] Group not found in any list: $e2');
          throw Exception('Group not found in local state');
        }
      }

      developer.log('🔄 [GROUPS_PROVIDER] Calling groups service...');

      final membership = await _groupsService.joinGroup(groupId);

      developer.log('✅ [GROUPS_PROVIDER] Groups service call successful');
      developer.log(
        '🔍 [GROUPS_PROVIDER] Received membership: ${membership.id}',
      );
      developer.log(
        '🔍 [GROUPS_PROVIDER] Membership status: ${membership.status}',
      );
      developer.log('🔍 [GROUPS_PROVIDER] Membership role: ${membership.role}');

      // Update group with actual membership data
      developer.log(
        '🔍 [GROUPS_PROVIDER] Updating group with membership data...',
      );

      final updatedGroup = targetGroup.copyWith(
        userMembership: membership,
        canJoin: false,
      );

      state = state.copyWith(
        myGroups: [...state.myGroups, updatedGroup],
        publicGroups: state.publicGroups.where((g) => g.id != groupId).toList(),
        allGroups: state.allGroups
            .map((g) => g.id == groupId ? updatedGroup : g)
            .toList(),
      );

      developer.log('✅ [GROUPS_PROVIDER] State updated successfully');
      developer.log(
        '🔍 [GROUPS_PROVIDER] New state - My groups: ${state.myGroups.length}',
      );
      developer.log(
        '🔍 [GROUPS_PROVIDER] New state - Public groups: ${state.publicGroups.length}',
      );
      developer.log(
        '🔍 [GROUPS_PROVIDER] New state - All groups: ${state.allGroups.length}',
      );

      developer.log('✅ [GROUPS_PROVIDER] Joined group successfully');
      developer.log(
        '🔄 [GROUPS_PROVIDER] === JOIN GROUP PROVIDER DEBUG END ===',
      );
      return true;
    } catch (e) {
      developer.log(
        '❌ [GROUPS_PROVIDER] === JOIN GROUP PROVIDER ERROR DEBUG END ===',
      );

      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Leave a group
  Future<bool> leaveGroup(String groupId) async {
    try {
      developer.log('🔄 [GROUPS_PROVIDER] Leaving group...');
      await _groupsService.leaveGroup(groupId);

      // Move group from my groups to public (if it's public)
      final group = state.myGroups.firstWhere((g) => g.id == groupId);

      state = state.copyWith(
        myGroups: state.myGroups.where((g) => g.id != groupId).toList(),
      );

      // Add to public groups if it's a public group
      if (group.privacySetting == 'public') {
        final updatedGroup = group.copyWith(
          userMembership: null,
          canJoin: true,
        );

        state = state.copyWith(
          publicGroups: [...state.publicGroups, updatedGroup],
          allGroups: state.allGroups
              .map((g) => g.id == groupId ? updatedGroup : g)
              .toList(),
        );
      } else {
        // Remove from all groups if private
        state = state.copyWith(
          allGroups: state.allGroups.where((g) => g.id != groupId).toList(),
        );
      }

      developer.log('✅ [GROUPS_PROVIDER] Left group successfully');
      return true;
    } catch (e) {
      developer.log('❌ [GROUPS_PROVIDER] Error leaving group: $e', error: e);
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Contribute to a group
  Future<bool> contributeToGroup(
    String groupId,
    Map<String, dynamic> contributionData,
  ) async {
    try {
      developer.log('🔄 [GROUPS_PROVIDER] Contributing to group...');

      // Check if the group can accept contributions before making the API call
      final group = state.allGroups.firstWhere(
        (g) => g.id == groupId,
        orElse: () => state.myGroups.firstWhere((g) => g.id == groupId),
      );

      if (!group.canContribute) {
        developer.log('❌ [GROUPS_PROVIDER] Group cannot accept contributions');
        state = state.copyWith(error: group.contributionStatusMessage);
        return false;
      }

      await _groupsService.contributeToGroup(groupId, contributionData);

      // Refresh the specific group data to get updated contribution amounts
      await loadAllGroupsData();

      developer.log('✅ [GROUPS_PROVIDER] Contribution successful');
      return true;
    } catch (e) {
      developer.log(
        '❌ [GROUPS_PROVIDER] Error contributing to group: $e',
        error: e,
      );

      // Extract more user-friendly error messages
      String errorMessage = e.toString();
      if (errorMessage.contains('NetworkException:')) {
        errorMessage = errorMessage.replaceFirst('NetworkException: ', '');
      }

      state = state.copyWith(error: errorMessage);
      return false;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // ============================================================================
  // ADMIN MANAGEMENT METHODS
  // ============================================================================

  /// Load group admins
  Future<void> loadGroupAdmins(String groupId) async {
    try {
      developer.log('🔄 [GROUPS_PROVIDER] Loading admins for group: $groupId');
      state = state.copyWith(isLoadingAdmins: true, adminError: null);

      final admins = await _groupsService.getGroupAdmins(groupId);

      final updatedAdmins = Map<String, List<GroupMembership>>.from(
        state.groupAdmins,
      );
      updatedAdmins[groupId] = admins;

      state = state.copyWith(
        groupAdmins: updatedAdmins,
        isLoadingAdmins: false,
      );

      developer.log('✅ [GROUPS_PROVIDER] Loaded admins for group: $groupId');
    } catch (e) {
      developer.log('❌ [GROUPS_PROVIDER] Error loading admins: $e', error: e);
      state = state.copyWith(isLoadingAdmins: false, adminError: e.toString());
    }
  }

  /// Promote member to admin
  Future<bool> promoteToAdmin(String groupId, String userId) async {
    try {
      developer.log('🔄 [GROUPS_PROVIDER] Promoting user to admin...');

      await _groupsService.promoteToAdmin(groupId, userId);

      // Refresh group admins and group data
      await Future.wait([loadGroupAdmins(groupId), loadAllGroupsData()]);

      developer.log('✅ [GROUPS_PROVIDER] User promoted to admin successfully');
      return true;
    } catch (e) {
      developer.log('❌ [GROUPS_PROVIDER] Error promoting user: $e', error: e);
      state = state.copyWith(adminError: e.toString());
      return false;
    }
  }

  /// Demote admin to member
  Future<bool> demoteAdmin(String groupId, String userId) async {
    try {
      developer.log('🔄 [GROUPS_PROVIDER] Demoting admin...');

      await _groupsService.demoteAdmin(groupId, userId);

      // Refresh group admins and group data
      await Future.wait([loadGroupAdmins(groupId), loadAllGroupsData()]);

      developer.log('✅ [GROUPS_PROVIDER] Admin demoted successfully');
      return true;
    } catch (e) {
      developer.log('❌ [GROUPS_PROVIDER] Error demoting admin: $e', error: e);
      state = state.copyWith(adminError: e.toString());
      return false;
    }
  }

  // ============================================================================
  // VOTING SYSTEM METHODS
  // ============================================================================

  /// Load group polls
  Future<void> loadGroupPolls(String groupId) async {
    try {
      developer.log('🔄 [GROUPS_PROVIDER] Loading polls for group: $groupId');
      state = state.copyWith(isLoadingPolls: true, pollError: null);

      final polls = await _groupsService.getGroupPolls(groupId);

      final updatedPolls = Map<String, List<AdminPoll>>.from(state.groupPolls);
      updatedPolls[groupId] = polls;

      state = state.copyWith(groupPolls: updatedPolls, isLoadingPolls: false);

      developer.log('✅ [GROUPS_PROVIDER] Loaded polls for group: $groupId');
    } catch (e) {
      developer.log('❌ [GROUPS_PROVIDER] Error loading polls: $e', error: e);
      state = state.copyWith(isLoadingPolls: false, pollError: e.toString());
    }
  }

  /// Create a new poll
  Future<AdminPoll?> createPoll(
    String groupId,
    Map<String, dynamic> pollData,
  ) async {
    try {
      developer.log('🔄 [GROUPS_PROVIDER] Creating poll...');

      final poll = await _groupsService.createPoll(groupId, pollData);

      // Refresh polls
      await loadGroupPolls(groupId);

      developer.log('✅ [GROUPS_PROVIDER] Poll created successfully');
      return poll;
    } catch (e) {
      developer.log('❌ [GROUPS_PROVIDER] Error creating poll: $e', error: e);
      state = state.copyWith(pollError: e.toString());
      return null;
    }
  }

  /// Vote on a poll
  Future<bool> voteOnPoll(String groupId, String pollId, String vote) async {
    try {
      developer.log('🔄 [GROUPS_PROVIDER] Casting vote...');

      await _groupsService.voteOnPoll(groupId, pollId, vote);

      // Refresh polls to get updated vote counts
      await loadGroupPolls(groupId);

      developer.log('✅ [GROUPS_PROVIDER] Vote cast successfully');
      return true;
    } catch (e) {
      developer.log('❌ [GROUPS_PROVIDER] Error casting vote: $e', error: e);
      state = state.copyWith(pollError: e.toString());
      return false;
    }
  }

  /// Load announcements for a specific group
  Future<List<GroupAnnouncement>> loadGroupAnnouncements(String groupId) async {
    try {
      developer.log(
        '🔄 [GROUPS_PROVIDER] Loading announcements for group: $groupId',
      );

      final announcements = await _groupsService.getGroupAnnouncements(groupId);

      developer.log(
        '✅ [GROUPS_PROVIDER] Loaded ${announcements.length} announcements',
      );
      return announcements;
    } catch (e) {
      developer.log(
        '❌ [GROUPS_PROVIDER] Error loading announcements: $e',
        error: e,
      );
      rethrow;
    }
  }

  /// Create a new announcement for a group
  Future<GroupAnnouncement> createGroupAnnouncement(
    String groupId,
    Map<String, dynamic> announcementData,
  ) async {
    try {
      developer.log('🔄 [GROUPS_PROVIDER] Creating announcement...');

      final announcement = await _groupsService.createGroupAnnouncement(
        groupId,
        announcementData,
      );

      developer.log('✅ [GROUPS_PROVIDER] Announcement created successfully');
      return announcement;
    } catch (e) {
      developer.log(
        '❌ [GROUPS_PROVIDER] Error creating announcement: $e',
        error: e,
      );
      rethrow;
    }
  }

  /// Clear admin error
  void clearAdminError() {
    state = state.copyWith(adminError: null);
  }

  /// Clear poll error
  void clearPollError() {
    state = state.copyWith(pollError: null);
  }

  /// Search users for admin selection
  Future<List<User>> searchUsers(String query) async {
    try {
      developer.log('🔍 [GROUPS_PROVIDER] Searching users: $query');
      final users = await _groupsService.searchUsers(query);
      developer.log('✅ [GROUPS_PROVIDER] Found ${users.length} users');
      return users;
    } catch (e) {
      developer.log('❌ [GROUPS_PROVIDER] Error searching users: $e', error: e);
      rethrow;
    }
  }

  /// Respond to a group invitation
  Future<bool> respondToInvitation(String invitationId, bool accept) async {
    try {
      developer.log(
        '🔄 [GROUPS_PROVIDER] ${accept ? 'Accepting' : 'Declining'} invitation: $invitationId',
      );

      final action = accept ? 'accept' : 'decline';
      final success = await _groupsService.respondToInvitation(
        invitationId,
        action,
      );

      if (success) {
        developer.log(
          '✅ [GROUPS_PROVIDER] Successfully ${accept ? 'accepted' : 'declined'} invitation',
        );

        // Refresh groups data if invitation was accepted
        if (accept) {
          await loadMyGroups();
        }
      } else {
        developer.log(
          '❌ [GROUPS_PROVIDER] Failed to ${accept ? 'accept' : 'decline'} invitation',
        );
      }

      return success;
    } catch (e) {
      developer.log(
        '❌ [GROUPS_PROVIDER] Error responding to invitation: $e',
        error: e,
      );
      rethrow;
    }
  }

  /// Get pending invitations for current user
  Future<List<GroupInvitation>> getPendingInvitations() async {
    try {
      developer.log('🔄 [GROUPS_PROVIDER] Loading pending invitations');
      final invitations = await _groupsService.getPendingInvitations();
      developer.log(
        '✅ [GROUPS_PROVIDER] Loaded ${invitations.length} pending invitations',
      );
      return invitations;
    } catch (e) {
      developer.log(
        '❌ [GROUPS_PROVIDER] Error loading pending invitations: $e',
        error: e,
      );
      rethrow;
    }
  }
}

final groupsProvider = StateNotifierProvider<GroupsNotifier, GroupsState>((
  ref,
) {
  final groupsService = ref.watch(groupsServiceProvider);
  return GroupsNotifier(groupsService);
});

// Individual group provider
final groupDetailProvider = FutureProvider.family<InvestmentGroup, String>((
  ref,
  groupId,
) async {
  final groupsService = ref.watch(groupsServiceProvider);
  return groupsService.getGroupDetails(groupId);
});

// Group performance provider
final groupPerformanceProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, groupId) async {
      final groupsService = ref.watch(groupsServiceProvider);
      return groupsService.getGroupPerformance(groupId);
    });

// Group memberships provider
final groupMembershipsProvider = FutureProvider<List<GroupMembership>>((
  ref,
) async {
  final groupsService = ref.watch(groupsServiceProvider);
  return groupsService.getGroupMemberships();
});

// Group contributions provider
final groupContributionsProvider = FutureProvider<List<GroupContribution>>((
  ref,
) async {
  final groupsService = ref.watch(groupsServiceProvider);
  return groupsService.getGroupContributions();
});

// Group activity provider (legacy - for backward compatibility)
final groupActivityProvider =
    FutureProvider.family<List<GroupActivity>, String>((ref, groupId) async {
      final groupsService = ref.watch(groupsServiceProvider);
      return groupsService.getGroupActivity(groupId);
    });

// Paginated group activity state
class PaginatedGroupActivityState {
  final List<GroupActivity> activities;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final String? error;

  const PaginatedGroupActivityState({
    this.activities = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.error,
  });

  PaginatedGroupActivityState copyWith({
    List<GroupActivity>? activities,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    String? error,
  }) {
    return PaginatedGroupActivityState(
      activities: activities ?? this.activities,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: error ?? this.error,
    );
  }
}

// Paginated group activity provider
final paginatedGroupActivityProvider =
    StateNotifierProvider.family<
      PaginatedGroupActivityNotifier,
      PaginatedGroupActivityState,
      String
    >((ref, groupId) {
      return PaginatedGroupActivityNotifier(ref, groupId);
    });

class PaginatedGroupActivityNotifier
    extends StateNotifier<PaginatedGroupActivityState> {
  final Ref _ref;
  final String _groupId;

  PaginatedGroupActivityNotifier(this._ref, this._groupId)
    : super(const PaginatedGroupActivityState()) {
    loadInitialActivities();
  }

  Future<void> loadInitialActivities() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final groupsService = _ref.read(groupsServiceProvider);
      final activities = await groupsService.getGroupActivity(_groupId);

      state = state.copyWith(
        activities: activities,
        isLoading: false,
        hasMore: false,
        currentPage: 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMoreActivities() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    try {
      // Since we don't have pagination anymore, just return
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void refresh() {
    state = const PaginatedGroupActivityState();
    loadInitialActivities();
  }
}
