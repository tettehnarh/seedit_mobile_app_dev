import 'package:equatable/equatable.dart';

/// Investment Group model
class InvestmentGroup extends Equatable {
  final String id;
  final String name;
  final String description;
  final String? profileImage;
  final String investmentGoal;
  final double targetAmount;
  final double? minimumContribution;
  final String contributionFrequency;
  final DateTime startDate;
  final DateTime endDate;
  final Fund designatedFund;
  final String privacySetting; // 'public' or 'private'
  final String
  status; // 'pending_activation', 'active', 'suspended', 'dissolved'
  final User createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double totalContributions;
  final double? currentValue;
  final double? totalReturns;
  final double progressPercentage;
  final int memberCount;
  final GroupMembership? userMembership;
  final double userContributions;
  final bool canJoin;
  final bool canEdit;
  final bool isActive;
  final bool isCreator;
  final String statusDisplay;
  final List<GroupMembership> memberships;
  final List<GroupContribution> contributions;

  const InvestmentGroup({
    required this.id,
    required this.name,
    required this.description,
    this.profileImage,
    required this.investmentGoal,
    required this.targetAmount,
    this.minimumContribution,
    required this.contributionFrequency,
    required this.startDate,
    required this.endDate,
    required this.designatedFund,
    required this.privacySetting,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.totalContributions,
    this.currentValue,
    this.totalReturns,
    required this.progressPercentage,
    required this.memberCount,
    this.userMembership,
    required this.userContributions,
    required this.canJoin,
    required this.canEdit,
    required this.isActive,
    required this.isCreator,
    required this.statusDisplay,
    this.memberships = const [],
    this.contributions = const [],
  });

  factory InvestmentGroup.fromJson(Map<String, dynamic> json) {
    return InvestmentGroup(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      profileImage: json['profile_image'],
      investmentGoal: json['investment_goal'] ?? '',
      targetAmount:
          double.tryParse(json['target_amount']?.toString() ?? '0') ?? 0.0,
      minimumContribution: json['minimum_contribution'] != null
          ? double.tryParse(json['minimum_contribution'].toString())
          : null,
      contributionFrequency: json['contribution_frequency'] ?? '',
      startDate: DateTime.tryParse(json['start_date'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date'] ?? '') ?? DateTime.now(),
      designatedFund: Fund.fromJson(json['designated_fund'] ?? {}),
      privacySetting: json['privacy_setting'] ?? 'public',
      status: json['status'] ?? 'pending_activation',
      createdBy: User.fromJson(json['created_by'] ?? {}),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      totalContributions:
          double.tryParse(json['total_contributions']?.toString() ?? '0') ??
          0.0,
      currentValue: json.containsKey('current_value')
          ? double.tryParse(json['current_value']?.toString() ?? '0')
          : null,
      totalReturns: json.containsKey('total_returns')
          ? double.tryParse(json['total_returns']?.toString() ?? '0')
          : null,
      progressPercentage:
          double.tryParse(json['progress_percentage']?.toString() ?? '0') ??
          0.0,
      memberCount: json['member_count'] ?? 0,
      userMembership: json['user_membership'] != null
          ? GroupMembership.fromJson(json['user_membership'])
          : null,
      userContributions:
          double.tryParse(json['user_contributions']?.toString() ?? '0') ?? 0.0,
      canJoin: json['can_join'] ?? false,
      canEdit: json['can_edit'] ?? false,
      isActive: json['is_active'] ?? false,
      isCreator: json['is_creator'] ?? false,
      statusDisplay: json['status_display'] ?? 'Unknown',
      memberships: json['memberships'] != null
          ? (json['memberships'] as List)
                .map(
                  (item) =>
                      GroupMembership.fromJson(item as Map<String, dynamic>),
                )
                .toList()
          : [],
      contributions: json['contributions'] != null
          ? (json['contributions'] as List)
                .map(
                  (item) =>
                      GroupContribution.fromJson(item as Map<String, dynamic>),
                )
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'investment_goal': investmentGoal,
      'target_amount': targetAmount.toString(),
      'minimum_contribution': minimumContribution?.toString(),
      'contribution_frequency': contributionFrequency,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'designated_fund_id': int.tryParse(designatedFund.id) ?? 0,
      'privacy_setting': privacySetting,
      'status': status,
    };
  }

  InvestmentGroup copyWith({
    String? id,
    String? name,
    String? description,
    String? profileImage,
    String? investmentGoal,
    double? targetAmount,
    double? minimumContribution,
    String? contributionFrequency,
    DateTime? startDate,
    DateTime? endDate,
    Fund? designatedFund,
    String? privacySetting,
    String? status,
    User? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? totalContributions,
    double? currentValue,
    double? totalReturns,
    double? progressPercentage,
    int? memberCount,
    GroupMembership? userMembership,
    double? userContributions,
    bool? canJoin,
    bool? canEdit,
    bool? isActive,
    bool? isCreator,
    String? statusDisplay,
    List<GroupMembership>? memberships,
    List<GroupContribution>? contributions,
  }) {
    return InvestmentGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      profileImage: profileImage ?? this.profileImage,
      investmentGoal: investmentGoal ?? this.investmentGoal,
      targetAmount: targetAmount ?? this.targetAmount,
      minimumContribution: minimumContribution ?? this.minimumContribution,
      contributionFrequency:
          contributionFrequency ?? this.contributionFrequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      designatedFund: designatedFund ?? this.designatedFund,
      privacySetting: privacySetting ?? this.privacySetting,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalContributions: totalContributions ?? this.totalContributions,
      currentValue: currentValue ?? this.currentValue,
      totalReturns: totalReturns ?? this.totalReturns,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      memberCount: memberCount ?? this.memberCount,
      userMembership: userMembership ?? this.userMembership,
      userContributions: userContributions ?? this.userContributions,
      canJoin: canJoin ?? this.canJoin,
      canEdit: canEdit ?? this.canEdit,
      isActive: isActive ?? this.isActive,
      isCreator: isCreator ?? this.isCreator,
      statusDisplay: statusDisplay ?? this.statusDisplay,
      memberships: memberships ?? this.memberships,
      contributions: contributions ?? this.contributions,
    );
  }

  /// Check if the group can accept contributions
  bool get canAcceptContributions {
    return status == 'active';
  }

  /// Get the reason why contributions are restricted (if any)
  String? get contributionRestrictionReason {
    if (status != 'active') {
      return 'Group is $status. Only active groups accept contributions.';
    }

    if (totalContributions >= targetAmount) {
      return 'Group has reached its target amount.';
    }

    return null; // No restrictions
  }

  /// Check if the contribute button should be enabled
  bool get canContribute {
    return canAcceptContributions &&
        userMembership != null &&
        userMembership!.status == 'active';
  }

  /// Get user-friendly status display for contribution eligibility
  String get contributionStatusMessage {
    if (!canAcceptContributions) {
      return contributionRestrictionReason ?? 'Contributions not available';
    }

    if (userMembership == null) {
      return 'You must be a member to contribute';
    }

    if (userMembership!.status != 'active') {
      return 'Your membership is ${userMembership!.status}';
    }

    return 'Ready to contribute';
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    profileImage,
    investmentGoal,
    targetAmount,
    minimumContribution,
    contributionFrequency,
    startDate,
    endDate,
    designatedFund,
    privacySetting,
    status,
    createdBy,
    createdAt,
    updatedAt,
    totalContributions,
    currentValue,
    totalReturns,
    progressPercentage,
    memberCount,
    userMembership,
    userContributions,
    canJoin,
    canEdit,
    isActive,
    isCreator,
    statusDisplay,
    memberships,
    contributions,
  ];
}

/// Group Membership model
class GroupMembership extends Equatable {
  final String? id;
  final User user;
  final String role; // 'admin' or 'member'
  final String status; // 'pending', 'active', 'suspended', 'left'
  final DateTime invitedAt;
  final DateTime? joinedAt;
  final double totalContributions;
  final double contributionPercentage;

  const GroupMembership({
    this.id,
    required this.user,
    required this.role,
    required this.status,
    required this.invitedAt,
    this.joinedAt,
    required this.totalContributions,
    required this.contributionPercentage,
  });

  factory GroupMembership.fromJson(Map<String, dynamic> json) {
    return GroupMembership(
      id: json['id']?.toString(),
      user: User.fromJson(json['user'] ?? {}),
      role: json['role'] ?? 'member',
      status: json['status'] ?? 'pending',
      invitedAt: DateTime.tryParse(json['invited_at'] ?? '') ?? DateTime.now(),
      joinedAt: json['joined_at'] != null
          ? DateTime.tryParse(json['joined_at'])
          : null,
      totalContributions:
          double.tryParse(json['total_contributions']?.toString() ?? '0') ??
          0.0,
      contributionPercentage:
          double.tryParse(json['contribution_percentage']?.toString() ?? '0') ??
          0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user': user.toJson(),
      'role': role,
      'status': status,
      'invited_at': invitedAt.toIso8601String(),
      if (joinedAt != null) 'joined_at': joinedAt!.toIso8601String(),
      'total_contributions': totalContributions.toString(),
      'contribution_percentage': contributionPercentage.toString(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    user,
    role,
    status,
    invitedAt,
    joinedAt,
    totalContributions,
    contributionPercentage,
  ];
}

/// Group Contribution model
class GroupContribution extends Equatable {
  final String id;
  final User user;
  final String? groupName;
  final double amount;
  final String status; // 'pending', 'completed', 'failed', 'refunded'
  final String? paymentMethod;
  final String? paymentReference;
  final DateTime createdAt;
  final DateTime? completedAt;

  const GroupContribution({
    required this.id,
    required this.user,
    this.groupName,
    required this.amount,
    required this.status,
    this.paymentMethod,
    this.paymentReference,
    required this.createdAt,
    this.completedAt,
  });

  factory GroupContribution.fromJson(Map<String, dynamic> json) {
    return GroupContribution(
      id: json['id'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
      groupName: json['group_name'],
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      status: json['status'] ?? 'pending',
      paymentMethod: json['payment_method'],
      paymentReference: json['payment_reference'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      if (groupName != null) 'group_name': groupName,
      'amount': amount.toString(),
      'status': status,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (paymentReference != null) 'payment_reference': paymentReference,
      'created_at': createdAt.toIso8601String(),
      if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    user,
    groupName,
    amount,
    status,
    paymentMethod,
    paymentReference,
    createdAt,
    completedAt,
  ];
}

/// Group Statistics model
class GroupStats extends Equatable {
  final int groupsJoined;
  final double totalContributions;
  final int activeGroups;
  final int totalMembersAcrossGroups;

  const GroupStats({
    required this.groupsJoined,
    required this.totalContributions,
    required this.activeGroups,
    required this.totalMembersAcrossGroups,
  });

  factory GroupStats.fromJson(Map<String, dynamic> json) {
    return GroupStats(
      groupsJoined: json['groups_joined'] ?? 0,
      totalContributions:
          double.tryParse(json['total_contributions']?.toString() ?? '0') ??
          0.0,
      activeGroups: json['active_groups'] ?? 0,
      totalMembersAcrossGroups: json['total_members_across_groups'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [
    groupsJoined,
    totalContributions,
    activeGroups,
    totalMembersAcrossGroups,
  ];
}

/// Supporting models (simplified versions)
class User extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;

  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
    };
  }

  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [id, email, firstName, lastName];
}

class Fund extends Equatable {
  final String id;
  final String name;
  final String categoryName;
  final double minimumInvestment;

  const Fund({
    required this.id,
    required this.name,
    required this.categoryName,
    required this.minimumInvestment,
  });

  factory Fund.fromJson(Map<String, dynamic> json) {
    return Fund(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      categoryName: json['category_name'] ?? '',
      minimumInvestment:
          double.tryParse(json['minimum_investment']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category_name': categoryName,
      'minimum_investment': minimumInvestment.toString(),
    };
  }

  @override
  List<Object?> get props => [id, name, categoryName, minimumInvestment];
}

/// Admin Poll model for group admin voting
class AdminPoll extends Equatable {
  final String id;
  final String groupId;
  final String groupName;
  final User createdBy;
  final String pollType; // 'promote_admin', 'demote_admin', 'custom'
  final String title;
  final String description;
  final User? targetUser;
  final String status; // 'active', 'completed', 'cancelled'
  final DateTime expiresAt;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int totalVotes;
  final int yesVotes;
  final int noVotes;
  final bool isExpired;
  final bool isActive;
  final bool userCanVote;
  final String? userVote; // 'yes', 'no', or null

  const AdminPoll({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.createdBy,
    required this.pollType,
    required this.title,
    required this.description,
    this.targetUser,
    required this.status,
    required this.expiresAt,
    required this.createdAt,
    this.completedAt,
    required this.totalVotes,
    required this.yesVotes,
    required this.noVotes,
    required this.isExpired,
    required this.isActive,
    required this.userCanVote,
    this.userVote,
  });

  factory AdminPoll.fromJson(Map<String, dynamic> json) {
    return AdminPoll(
      id: json['id'] as String,
      groupId: json['group'] as String,
      groupName: json['group_name'] as String,
      createdBy: User.fromJson(json['created_by'] as Map<String, dynamic>),
      pollType: json['poll_type'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      targetUser: json['target_user'] != null
          ? User.fromJson(json['target_user'] as Map<String, dynamic>)
          : null,
      status: json['status'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      totalVotes: json['total_votes'] as int,
      yesVotes: json['yes_votes'] as int,
      noVotes: json['no_votes'] as int,
      isExpired: json['is_expired'] as bool,
      isActive: json['is_active'] as bool,
      userCanVote: json['user_can_vote'] as bool,
      userVote: json['user_vote'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group': groupId,
      'group_name': groupName,
      'created_by': createdBy.toJson(),
      'poll_type': pollType,
      'title': title,
      'description': description,
      'target_user': targetUser?.toJson(),
      'status': status,
      'expires_at': expiresAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'total_votes': totalVotes,
      'yes_votes': yesVotes,
      'no_votes': noVotes,
      'is_expired': isExpired,
      'is_active': isActive,
      'user_can_vote': userCanVote,
      'user_vote': userVote,
    };
  }

  AdminPoll copyWith({
    String? id,
    String? groupId,
    String? groupName,
    User? createdBy,
    String? pollType,
    String? title,
    String? description,
    User? targetUser,
    String? status,
    DateTime? expiresAt,
    DateTime? createdAt,
    DateTime? completedAt,
    int? totalVotes,
    int? yesVotes,
    int? noVotes,
    bool? isExpired,
    bool? isActive,
    bool? userCanVote,
    String? userVote,
  }) {
    return AdminPoll(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      createdBy: createdBy ?? this.createdBy,
      pollType: pollType ?? this.pollType,
      title: title ?? this.title,
      description: description ?? this.description,
      targetUser: targetUser ?? this.targetUser,
      status: status ?? this.status,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      totalVotes: totalVotes ?? this.totalVotes,
      yesVotes: yesVotes ?? this.yesVotes,
      noVotes: noVotes ?? this.noVotes,
      isExpired: isExpired ?? this.isExpired,
      isActive: isActive ?? this.isActive,
      userCanVote: userCanVote ?? this.userCanVote,
      userVote: userVote ?? this.userVote,
    );
  }

  @override
  List<Object?> get props => [
    id,
    groupId,
    groupName,
    createdBy,
    pollType,
    title,
    description,
    targetUser,
    status,
    expiresAt,
    createdAt,
    completedAt,
    totalVotes,
    yesVotes,
    noVotes,
    isExpired,
    isActive,
    userCanVote,
    userVote,
  ];
}

/// Admin Vote model for individual votes on polls
class AdminVote extends Equatable {
  final String id;
  final String pollId;
  final String pollTitle;
  final User voter;
  final String vote; // 'yes' or 'no'
  final DateTime createdAt;

  const AdminVote({
    required this.id,
    required this.pollId,
    required this.pollTitle,
    required this.voter,
    required this.vote,
    required this.createdAt,
  });

  factory AdminVote.fromJson(Map<String, dynamic> json) {
    return AdminVote(
      id: json['id'].toString(), // Convert to string since backend returns int
      pollId: json['poll'] as String,
      pollTitle: json['poll_title'] as String,
      voter: User.fromJson(json['voter'] as Map<String, dynamic>),
      vote: json['vote'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'poll': pollId,
      'poll_title': pollTitle,
      'voter': voter.toJson(),
      'vote': vote,
      'created_at': createdAt.toIso8601String(),
    };
  }

  AdminVote copyWith({
    String? id,
    String? pollId,
    String? pollTitle,
    User? voter,
    String? vote,
    DateTime? createdAt,
  }) {
    return AdminVote(
      id: id ?? this.id,
      pollId: pollId ?? this.pollId,
      pollTitle: pollTitle ?? this.pollTitle,
      voter: voter ?? this.voter,
      vote: vote ?? this.vote,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, pollId, pollTitle, voter, vote, createdAt];
}

/// Group Announcement model for group communications
class GroupAnnouncement extends Equatable {
  final String id;
  final String groupId;
  final String groupName;
  final User author;
  final String title;
  final String content;
  final bool isImportant;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GroupAnnouncement({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.author,
    required this.title,
    required this.content,
    required this.isImportant,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GroupAnnouncement.fromJson(Map<String, dynamic> json) {
    return GroupAnnouncement(
      id: json['id'] as String,
      groupId: json['group'] as String,
      groupName: json['group_name'] as String,
      author: User.fromJson(json['author'] as Map<String, dynamic>),
      title: json['title'] as String,
      content: json['content'] as String,
      isImportant: json['is_important'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group': groupId,
      'group_name': groupName,
      'author': author.toJson(),
      'title': title,
      'content': content,
      'is_important': isImportant,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  GroupAnnouncement copyWith({
    String? id,
    String? groupId,
    String? groupName,
    User? author,
    String? title,
    String? content,
    bool? isImportant,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GroupAnnouncement(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      author: author ?? this.author,
      title: title ?? this.title,
      content: content ?? this.content,
      isImportant: isImportant ?? this.isImportant,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    groupId,
    groupName,
    author,
    title,
    content,
    isImportant,
    createdAt,
    updatedAt,
  ];
}

/// Group Invitation model for email-based invitations
class GroupInvitation extends Equatable {
  final String id;
  final String groupId;
  final String groupName;
  final String groupDescription;
  final User? inviter;
  final User? invitee;
  final String inviteeEmail;
  final String status; // 'pending', 'accepted', 'declined', 'expired'
  final String? message;
  final DateTime createdAt;
  final DateTime? respondedAt;
  final DateTime expiresAt;
  final bool isExpired;

  const GroupInvitation({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.groupDescription,
    this.inviter,
    this.invitee,
    required this.inviteeEmail,
    required this.status,
    this.message,
    required this.createdAt,
    this.respondedAt,
    required this.expiresAt,
    required this.isExpired,
  });

  factory GroupInvitation.fromJson(Map<String, dynamic> json) {
    return GroupInvitation(
      id: json['id'] as String,
      groupId: json['group'] as String,
      groupName: json['group_name'] as String? ?? '',
      groupDescription: json['group_description'] as String? ?? '',
      inviter: json['inviter'] != null
          ? User.fromJson(json['inviter'] as Map<String, dynamic>)
          : null,
      invitee: json['invitee'] != null
          ? User.fromJson(json['invitee'] as Map<String, dynamic>)
          : null,
      inviteeEmail: json['invitee_email'] as String,
      status: json['status'] as String,
      message: json['message'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      respondedAt: json['responded_at'] != null
          ? DateTime.parse(json['responded_at'] as String)
          : null,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      isExpired: json['is_expired'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group': groupId,
      'group_name': groupName,
      'group_description': groupDescription,
      'inviter': inviter?.toJson(),
      'invitee': invitee?.toJson(),
      'invitee_email': inviteeEmail,
      'status': status,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'responded_at': respondedAt?.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'is_expired': isExpired,
    };
  }

  GroupInvitation copyWith({
    String? id,
    String? groupId,
    String? groupName,
    String? groupDescription,
    User? inviter,
    User? invitee,
    String? inviteeEmail,
    String? status,
    String? message,
    DateTime? createdAt,
    DateTime? respondedAt,
    DateTime? expiresAt,
    bool? isExpired,
  }) {
    return GroupInvitation(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      groupDescription: groupDescription ?? this.groupDescription,
      inviter: inviter ?? this.inviter,
      invitee: invitee ?? this.invitee,
      inviteeEmail: inviteeEmail ?? this.inviteeEmail,
      status: status ?? this.status,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isExpired: isExpired ?? this.isExpired,
    );
  }

  @override
  List<Object?> get props => [
    id,
    groupId,
    groupName,
    groupDescription,
    inviter,
    invitee,
    inviteeEmail,
    status,
    message,
    createdAt,
    respondedAt,
    expiresAt,
    isExpired,
  ];
}

/// Group Activity model for activity feed
class GroupActivity extends Equatable {
  final String id;
  final String activityType;
  final String title;
  final String description;
  final User user;
  final GroupContribution? contribution;
  final DateTime createdAt;

  const GroupActivity({
    required this.id,
    required this.activityType,
    required this.title,
    required this.description,
    required this.user,
    this.contribution,
    required this.createdAt,
  });

  factory GroupActivity.fromJson(Map<String, dynamic> json) {
    return GroupActivity(
      id: json['id'] as String,
      activityType: json['activity_type'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      contribution: json['contribution'] != null
          ? GroupContribution.fromJson(
              json['contribution'] as Map<String, dynamic>,
            )
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activity_type': activityType,
      'title': title,
      'description': description,
      'user': user.toJson(),
      'contribution': contribution?.toJson(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    activityType,
    title,
    description,
    user,
    contribution,
    createdAt,
  ];
}
