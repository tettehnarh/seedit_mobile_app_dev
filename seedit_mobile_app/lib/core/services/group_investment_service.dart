import 'package:flutter/foundation.dart';
import '../../shared/models/group_investment_model.dart';

class GroupInvestmentService {
  // Get all public groups
  Future<List<InvestmentGroup>> getPublicGroups({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 600));
      
      return _getMockPublicGroups();
    } catch (e) {
      debugPrint('Get public groups error: $e');
      throw Exception('Failed to load public groups');
    }
  }

  // Get user's groups
  Future<List<InvestmentGroup>> getUserGroups(String userId) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      return _getMockUserGroups(userId);
    } catch (e) {
      debugPrint('Get user groups error: $e');
      throw Exception('Failed to load user groups');
    }
  }

  // Get group by ID
  Future<InvestmentGroup?> getGroupById(String groupId) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 300));
      
      return _getMockGroup(groupId);
    } catch (e) {
      debugPrint('Get group by ID error: $e');
      return null;
    }
  }

  // Create new group
  Future<InvestmentGroup> createGroup({
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
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 800));
      
      final groupId = 'group_${DateTime.now().millisecondsSinceEpoch}';
      final now = DateTime.now();
      
      final group = InvestmentGroup(
        id: groupId,
        name: name,
        description: description,
        creatorId: creatorId,
        creatorName: 'John Doe', // TODO: Get from user service
        type: type,
        privacy: privacy,
        status: GroupStatus.active,
        targetAmount: targetAmount,
        currentAmount: 0.0,
        minimumContribution: minimumContribution,
        maximumContribution: maximumContribution,
        fundId: fundId,
        fundName: 'SeedIt Equity Growth Fund', // TODO: Get from fund service
        startDate: now,
        endDate: endDate,
        maxMembers: maxMembers,
        currentMembers: 1,
        memberIds: [creatorId],
        members: [
          GroupMember(
            userId: creatorId,
            userName: 'John Doe',
            role: GroupRole.creator,
            contributedAmount: 0.0,
            targetContribution: targetAmount / maxMembers,
            joinedAt: now,
          ),
        ],
        tags: tags,
        settings: settings ?? GroupSettings(),
        createdAt: now,
        updatedAt: now,
      );
      
      return group;
    } catch (e) {
      debugPrint('Create group error: $e');
      throw Exception('Failed to create group');
    }
  }

  // Join group
  Future<InvestmentGroup> joinGroup(String groupId, String userId) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 600));
      
      final group = await getGroupById(groupId);
      if (group == null) throw Exception('Group not found');
      
      if (group.isFull) throw Exception('Group is full');
      if (group.memberIds.contains(userId)) throw Exception('Already a member');
      
      final newMember = GroupMember(
        userId: userId,
        userName: 'New Member', // TODO: Get from user service
        role: GroupRole.member,
        contributedAmount: 0.0,
        targetContribution: group.targetAmount / group.maxMembers,
        joinedAt: DateTime.now(),
      );
      
      final updatedGroup = group.copyWith(
        currentMembers: group.currentMembers + 1,
        memberIds: [...group.memberIds, userId],
        members: [...group.members, newMember],
        updatedAt: DateTime.now(),
      );
      
      return updatedGroup;
    } catch (e) {
      debugPrint('Join group error: $e');
      throw Exception('Failed to join group');
    }
  }

  // Leave group
  Future<InvestmentGroup> leaveGroup(String groupId, String userId) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      final group = await getGroupById(groupId);
      if (group == null) throw Exception('Group not found');
      
      if (!group.memberIds.contains(userId)) throw Exception('Not a member');
      if (group.creatorId == userId) throw Exception('Creator cannot leave group');
      
      final updatedGroup = group.copyWith(
        currentMembers: group.currentMembers - 1,
        memberIds: group.memberIds.where((id) => id != userId).toList(),
        members: group.members.where((member) => member.userId != userId).toList(),
        updatedAt: DateTime.now(),
      );
      
      return updatedGroup;
    } catch (e) {
      debugPrint('Leave group error: $e');
      throw Exception('Failed to leave group');
    }
  }

  // Make contribution to group
  Future<GroupContribution> contributeToGroup({
    required String groupId,
    required String userId,
    required double amount,
    String? notes,
  }) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 700));
      
      final contributionId = 'contrib_${DateTime.now().millisecondsSinceEpoch}';
      final contribution = GroupContribution(
        id: contributionId,
        groupId: groupId,
        userId: userId,
        userName: 'John Doe', // TODO: Get from user service
        amount: amount,
        status: ContributionStatus.completed,
        paymentReference: 'PAY_${DateTime.now().millisecondsSinceEpoch}',
        notes: notes,
        contributionDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      return contribution;
    } catch (e) {
      debugPrint('Contribute to group error: $e');
      throw Exception('Failed to make contribution');
    }
  }

  // Get group contributions
  Future<List<GroupContribution>> getGroupContributions(String groupId) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 400));
      
      return _getMockContributions(groupId);
    } catch (e) {
      debugPrint('Get group contributions error: $e');
      throw Exception('Failed to load contributions');
    }
  }

  // Send group invitation
  Future<GroupInvitation> sendInvitation({
    required String groupId,
    required String inviterId,
    required String inviteeEmail,
    String? inviteePhone,
    String? message,
  }) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 600));
      
      final invitationId = 'invite_${DateTime.now().millisecondsSinceEpoch}';
      final invitation = GroupInvitation(
        id: invitationId,
        groupId: groupId,
        groupName: 'Investment Club Alpha', // TODO: Get from group
        inviterId: inviterId,
        inviterName: 'John Doe', // TODO: Get from user service
        inviteeId: 'user_${DateTime.now().millisecondsSinceEpoch}',
        inviteeEmail: inviteeEmail,
        inviteePhone: inviteePhone,
        status: InvitationStatus.pending,
        message: message,
        expiresAt: DateTime.now().add(const Duration(days: 7)),
        createdAt: DateTime.now(),
      );
      
      return invitation;
    } catch (e) {
      debugPrint('Send invitation error: $e');
      throw Exception('Failed to send invitation');
    }
  }

  // Get user invitations
  Future<List<GroupInvitation>> getUserInvitations(String userId) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 400));
      
      return _getMockInvitations(userId);
    } catch (e) {
      debugPrint('Get user invitations error: $e');
      throw Exception('Failed to load invitations');
    }
  }

  // Respond to invitation
  Future<GroupInvitation> respondToInvitation(
    String invitationId,
    InvitationStatus response,
  ) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      final invitation = _getMockInvitation(invitationId);
      return invitation.copyWith(
        status: response,
        respondedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Respond to invitation error: $e');
      throw Exception('Failed to respond to invitation');
    }
  }

  // Get group activities
  Future<List<GroupActivity>> getGroupActivities(String groupId) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 400));
      
      return _getMockActivities(groupId);
    } catch (e) {
      debugPrint('Get group activities error: $e');
      throw Exception('Failed to load activities');
    }
  }

  // Search groups
  Future<List<InvestmentGroup>> searchGroups(String query) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      final allGroups = _getMockPublicGroups();
      return allGroups
          .where((group) =>
              group.name.toLowerCase().contains(query.toLowerCase()) ||
              group.description.toLowerCase().contains(query.toLowerCase()) ||
              group.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase())))
          .toList();
    } catch (e) {
      debugPrint('Search groups error: $e');
      throw Exception('Failed to search groups');
    }
  }

  // Mock data methods
  List<InvestmentGroup> _getMockPublicGroups() {
    return [
      InvestmentGroup(
        id: 'group_001',
        name: 'Tech Investors Club',
        description: 'A group focused on technology sector investments',
        creatorId: 'user_001',
        creatorName: 'Alice Johnson',
        type: GroupType.investmentClub,
        privacy: GroupPrivacy.public,
        status: GroupStatus.active,
        targetAmount: 500000,
        currentAmount: 350000,
        minimumContribution: 10000,
        maximumContribution: 100000,
        fundId: 'fund_001',
        fundName: 'SeedIt Tech Growth Fund',
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now().add(const Duration(days: 60)),
        maxMembers: 10,
        currentMembers: 7,
        memberIds: ['user_001', 'user_002', 'user_003', 'user_004', 'user_005', 'user_006', 'user_007'],
        members: [],
        tags: ['technology', 'growth', 'long-term'],
        settings: GroupSettings(),
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      InvestmentGroup(
        id: 'group_002',
        name: 'Young Professionals Savings',
        description: 'Building wealth together as young professionals',
        creatorId: 'user_008',
        creatorName: 'Bob Smith',
        type: GroupType.savingsGroup,
        privacy: GroupPrivacy.public,
        status: GroupStatus.active,
        targetAmount: 1000000,
        currentAmount: 250000,
        minimumContribution: 5000,
        maximumContribution: 50000,
        fundId: 'fund_002',
        fundName: 'SeedIt Balanced Fund',
        startDate: DateTime.now().subtract(const Duration(days: 15)),
        endDate: DateTime.now().add(const Duration(days: 75)),
        maxMembers: 20,
        currentMembers: 5,
        memberIds: ['user_008', 'user_009', 'user_010', 'user_011', 'user_012'],
        members: [],
        tags: ['savings', 'young-professionals', 'balanced'],
        settings: GroupSettings(),
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    ];
  }

  List<InvestmentGroup> _getMockUserGroups(String userId) {
    return _getMockPublicGroups()
        .where((group) => group.memberIds.contains(userId))
        .toList();
  }

  InvestmentGroup _getMockGroup(String groupId) {
    return _getMockPublicGroups()
        .firstWhere((group) => group.id == groupId);
  }

  List<GroupContribution> _getMockContributions(String groupId) {
    return [
      GroupContribution(
        id: 'contrib_001',
        groupId: groupId,
        userId: 'user_001',
        userName: 'Alice Johnson',
        amount: 50000,
        status: ContributionStatus.completed,
        paymentReference: 'PAY_123456',
        contributionDate: DateTime.now().subtract(const Duration(days: 5)),
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      GroupContribution(
        id: 'contrib_002',
        groupId: groupId,
        userId: 'user_002',
        userName: 'Bob Smith',
        amount: 75000,
        status: ContributionStatus.completed,
        paymentReference: 'PAY_789012',
        contributionDate: DateTime.now().subtract(const Duration(days: 3)),
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }

  List<GroupInvitation> _getMockInvitations(String userId) {
    return [
      GroupInvitation(
        id: 'invite_001',
        groupId: 'group_003',
        groupName: 'Real Estate Investors',
        inviterId: 'user_020',
        inviterName: 'Carol Davis',
        inviteeId: userId,
        inviteeEmail: 'user@example.com',
        status: InvitationStatus.pending,
        message: 'Join our real estate investment group!',
        expiresAt: DateTime.now().add(const Duration(days: 5)),
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  GroupInvitation _getMockInvitation(String invitationId) {
    return GroupInvitation(
      id: invitationId,
      groupId: 'group_003',
      groupName: 'Real Estate Investors',
      inviterId: 'user_020',
      inviterName: 'Carol Davis',
      inviteeId: 'user_123',
      inviteeEmail: 'user@example.com',
      status: InvitationStatus.pending,
      expiresAt: DateTime.now().add(const Duration(days: 5)),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    );
  }

  List<GroupActivity> _getMockActivities(String groupId) {
    return [
      GroupActivity(
        id: 'activity_001',
        groupId: groupId,
        userId: 'user_001',
        userName: 'Alice Johnson',
        type: ActivityType.contributionMade,
        title: 'New Contribution',
        description: 'Alice Johnson contributed ₦50,000',
        data: {'amount': 50000},
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      GroupActivity(
        id: 'activity_002',
        groupId: groupId,
        userId: 'user_002',
        userName: 'Bob Smith',
        type: ActivityType.memberJoined,
        title: 'New Member',
        description: 'Bob Smith joined the group',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
}
