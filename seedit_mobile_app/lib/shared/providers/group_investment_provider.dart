import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../models/group_investment_model.dart';
import '../../core/services/group_investment_service.dart';
import 'auth_provider.dart';

// Service provider
final groupInvestmentServiceProvider = Provider<GroupInvestmentService>((ref) => GroupInvestmentService());

// Public groups provider
final publicGroupsProvider = FutureProvider<List<InvestmentGroup>>((ref) async {
  final service = ref.read(groupInvestmentServiceProvider);
  return await service.getPublicGroups();
});

// User groups provider
final userGroupsProvider = FutureProvider<List<InvestmentGroup>>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return [];
  
  final service = ref.read(groupInvestmentServiceProvider);
  return await service.getUserGroups(currentUser.id);
});

// Group by ID provider
final groupByIdProvider = FutureProvider.family<InvestmentGroup?, String>((ref, groupId) async {
  final service = ref.read(groupInvestmentServiceProvider);
  return await service.getGroupById(groupId);
});

// Group contributions provider
final groupContributionsProvider = FutureProvider.family<List<GroupContribution>, String>((ref, groupId) async {
  final service = ref.read(groupInvestmentServiceProvider);
  return await service.getGroupContributions(groupId);
});

// User invitations provider
final userInvitationsProvider = FutureProvider<List<GroupInvitation>>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return [];
  
  final service = ref.read(groupInvestmentServiceProvider);
  return await service.getUserInvitations(currentUser.id);
});

// Group activities provider
final groupActivitiesProvider = FutureProvider.family<List<GroupActivity>, String>((ref, groupId) async {
  final service = ref.read(groupInvestmentServiceProvider);
  return await service.getGroupActivities(groupId);
});

// Group search provider
final groupSearchProvider = StateNotifierProvider<GroupSearchNotifier, GroupSearchState>((ref) {
  return GroupSearchNotifier(ref.read(groupInvestmentServiceProvider));
});

class GroupSearchState {
  final String query;
  final List<InvestmentGroup> results;
  final bool isLoading;
  final String? error;

  GroupSearchState({
    this.query = '',
    this.results = const [],
    this.isLoading = false,
    this.error,
  });

  GroupSearchState copyWith({
    String? query,
    List<InvestmentGroup>? results,
    bool? isLoading,
    String? error,
  }) {
    return GroupSearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class GroupSearchNotifier extends StateNotifier<GroupSearchState> {
  final GroupInvestmentService _service;

  GroupSearchNotifier(this._service) : super(GroupSearchState());

  Future<void> searchGroups(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(query: '', results: [], error: null);
      return;
    }

    state = state.copyWith(query: query, isLoading: true, error: null);

    try {
      final results = await _service.searchGroups(query);
      state = state.copyWith(
        results: results,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('Search groups error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearSearch() {
    state = GroupSearchState();
  }
}

// Group management state provider
final groupManagementProvider = StateNotifierProvider<GroupManagementNotifier, GroupManagementState>((ref) {
  return GroupManagementNotifier(ref.read(groupInvestmentServiceProvider));
});

class GroupManagementState {
  final bool isLoading;
  final String? error;
  final InvestmentGroup? currentGroup;
  final GroupContribution? currentContribution;
  final GroupInvitation? currentInvitation;

  GroupManagementState({
    this.isLoading = false,
    this.error,
    this.currentGroup,
    this.currentContribution,
    this.currentInvitation,
  });

  GroupManagementState copyWith({
    bool? isLoading,
    String? error,
    InvestmentGroup? currentGroup,
    GroupContribution? currentContribution,
    GroupInvitation? currentInvitation,
  }) {
    return GroupManagementState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentGroup: currentGroup ?? this.currentGroup,
      currentContribution: currentContribution ?? this.currentContribution,
      currentInvitation: currentInvitation ?? this.currentInvitation,
    );
  }
}

class GroupManagementNotifier extends StateNotifier<GroupManagementState> {
  final GroupInvestmentService _service;

  GroupManagementNotifier(this._service) : super(GroupManagementState());

  // Create group
  Future<InvestmentGroup?> createGroup({
    required String creatorId,
    required String name,
    required String description,
    required GroupType type,
    required GroupPrivacy privacy,
    required double targetAmount,
    required double minimumContribution,
    required double maximumContribution,
    required String fundId,
    required int maxMembers,
    DateTime? endDate,
    List<String> tags = const [],
    GroupSettings? settings,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final group = await _service.createGroup(
        creatorId: creatorId,
        name: name,
        description: description,
        type: type,
        privacy: privacy,
        targetAmount: targetAmount,
        minimumContribution: minimumContribution,
        maximumContribution: maximumContribution,
        fundId: fundId,
        maxMembers: maxMembers,
        endDate: endDate,
        tags: tags,
        settings: settings,
      );

      state = state.copyWith(
        isLoading: false,
        currentGroup: group,
      );

      return group;
    } catch (e) {
      debugPrint('Create group error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  // Join group
  Future<bool> joinGroup(String groupId, String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final group = await _service.joinGroup(groupId, userId);
      
      state = state.copyWith(
        isLoading: false,
        currentGroup: group,
      );

      return true;
    } catch (e) {
      debugPrint('Join group error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Leave group
  Future<bool> leaveGroup(String groupId, String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final group = await _service.leaveGroup(groupId, userId);
      
      state = state.copyWith(
        isLoading: false,
        currentGroup: group,
      );

      return true;
    } catch (e) {
      debugPrint('Leave group error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Contribute to group
  Future<GroupContribution?> contributeToGroup({
    required String groupId,
    required String userId,
    required double amount,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final contribution = await _service.contributeToGroup(
        groupId: groupId,
        userId: userId,
        amount: amount,
        notes: notes,
      );

      state = state.copyWith(
        isLoading: false,
        currentContribution: contribution,
      );

      return contribution;
    } catch (e) {
      debugPrint('Contribute to group error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  // Send invitation
  Future<GroupInvitation?> sendInvitation({
    required String groupId,
    required String inviterId,
    required String inviteeEmail,
    String? inviteePhone,
    String? message,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final invitation = await _service.sendInvitation(
        groupId: groupId,
        inviterId: inviterId,
        inviteeEmail: inviteeEmail,
        inviteePhone: inviteePhone,
        message: message,
      );

      state = state.copyWith(
        isLoading: false,
        currentInvitation: invitation,
      );

      return invitation;
    } catch (e) {
      debugPrint('Send invitation error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  // Respond to invitation
  Future<bool> respondToInvitation(String invitationId, InvitationStatus response) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final invitation = await _service.respondToInvitation(invitationId, response);
      
      state = state.copyWith(
        isLoading: false,
        currentInvitation: invitation,
      );

      return true;
    } catch (e) {
      debugPrint('Respond to invitation error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Clear current group
  void clearCurrentGroup() {
    state = state.copyWith(currentGroup: null);
  }

  // Clear current contribution
  void clearCurrentContribution() {
    state = state.copyWith(currentContribution: null);
  }

  // Clear current invitation
  void clearCurrentInvitation() {
    state = state.copyWith(currentInvitation: null);
  }
}
