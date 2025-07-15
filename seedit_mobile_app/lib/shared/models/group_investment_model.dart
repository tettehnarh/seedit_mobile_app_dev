import 'package:json_annotation/json_annotation.dart';

part 'group_investment_model.g.dart';

@JsonSerializable()
class InvestmentGroup {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final String creatorId;
  final String creatorName;
  final GroupType type;
  final GroupPrivacy privacy;
  final GroupStatus status;
  final double targetAmount;
  final double currentAmount;
  final double minimumContribution;
  final double maximumContribution;
  final String fundId;
  final String fundName;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? maturityDate;
  final int maxMembers;
  final int currentMembers;
  final List<String> memberIds;
  final List<GroupMember> members;
  final List<String> tags;
  final GroupSettings settings;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  InvestmentGroup({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.creatorId,
    required this.creatorName,
    required this.type,
    required this.privacy,
    required this.status,
    required this.targetAmount,
    required this.currentAmount,
    required this.minimumContribution,
    required this.maximumContribution,
    required this.fundId,
    required this.fundName,
    required this.startDate,
    this.endDate,
    this.maturityDate,
    required this.maxMembers,
    required this.currentMembers,
    required this.memberIds,
    required this.members,
    required this.tags,
    required this.settings,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory InvestmentGroup.fromJson(Map<String, dynamic> json) => _$InvestmentGroupFromJson(json);
  Map<String, dynamic> toJson() => _$InvestmentGroupToJson(this);

  InvestmentGroup copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? creatorId,
    String? creatorName,
    GroupType? type,
    GroupPrivacy? privacy,
    GroupStatus? status,
    double? targetAmount,
    double? currentAmount,
    double? minimumContribution,
    double? maximumContribution,
    String? fundId,
    String? fundName,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? maturityDate,
    int? maxMembers,
    int? currentMembers,
    List<String>? memberIds,
    List<GroupMember>? members,
    List<String>? tags,
    GroupSettings? settings,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InvestmentGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      type: type ?? this.type,
      privacy: privacy ?? this.privacy,
      status: status ?? this.status,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      minimumContribution: minimumContribution ?? this.minimumContribution,
      maximumContribution: maximumContribution ?? this.maximumContribution,
      fundId: fundId ?? this.fundId,
      fundName: fundName ?? this.fundName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      maturityDate: maturityDate ?? this.maturityDate,
      maxMembers: maxMembers ?? this.maxMembers,
      currentMembers: currentMembers ?? this.currentMembers,
      memberIds: memberIds ?? this.memberIds,
      members: members ?? this.members,
      tags: tags ?? this.tags,
      settings: settings ?? this.settings,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Calculated properties
  double get progressPercentage => targetAmount > 0 ? (currentAmount / targetAmount) * 100 : 0.0;
  double get remainingAmount => targetAmount - currentAmount;
  bool get isTargetReached => currentAmount >= targetAmount;
  bool get isFull => currentMembers >= maxMembers;
  bool get isActive => status == GroupStatus.active;
  bool get canJoin => isActive && !isFull && privacy != GroupPrivacy.private;
  
  String get formattedTargetAmount => '₦${targetAmount.toStringAsFixed(2)}';
  String get formattedCurrentAmount => '₦${currentAmount.toStringAsFixed(2)}';
  String get formattedRemainingAmount => '₦${remainingAmount.toStringAsFixed(2)}';
  String get formattedMinContribution => '₦${minimumContribution.toStringAsFixed(2)}';
  String get formattedMaxContribution => '₦${maximumContribution.toStringAsFixed(2)}';
}

@JsonSerializable()
class GroupMember {
  final String userId;
  final String userName;
  final String? userImageUrl;
  final GroupRole role;
  final double contributedAmount;
  final double targetContribution;
  final DateTime joinedAt;
  final bool isActive;
  final Map<String, dynamic> metadata;

  GroupMember({
    required this.userId,
    required this.userName,
    this.userImageUrl,
    required this.role,
    required this.contributedAmount,
    required this.targetContribution,
    required this.joinedAt,
    this.isActive = true,
    this.metadata = const {},
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) => _$GroupMemberFromJson(json);
  Map<String, dynamic> toJson() => _$GroupMemberToJson(this);

  GroupMember copyWith({
    String? userId,
    String? userName,
    String? userImageUrl,
    GroupRole? role,
    double? contributedAmount,
    double? targetContribution,
    DateTime? joinedAt,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return GroupMember(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userImageUrl: userImageUrl ?? this.userImageUrl,
      role: role ?? this.role,
      contributedAmount: contributedAmount ?? this.contributedAmount,
      targetContribution: targetContribution ?? this.targetContribution,
      joinedAt: joinedAt ?? this.joinedAt,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }

  double get contributionPercentage => targetContribution > 0 ? (contributedAmount / targetContribution) * 100 : 0.0;
  double get remainingContribution => targetContribution - contributedAmount;
  bool get hasMetTarget => contributedAmount >= targetContribution;
  
  String get formattedContributedAmount => '₦${contributedAmount.toStringAsFixed(2)}';
  String get formattedTargetContribution => '₦${targetContribution.toStringAsFixed(2)}';
  String get formattedRemainingContribution => '₦${remainingContribution.toStringAsFixed(2)}';
}

@JsonSerializable()
class GroupContribution {
  final String id;
  final String groupId;
  final String userId;
  final String userName;
  final double amount;
  final ContributionStatus status;
  final String? paymentReference;
  final String? notes;
  final DateTime contributionDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  GroupContribution({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.userName,
    required this.amount,
    required this.status,
    this.paymentReference,
    this.notes,
    required this.contributionDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GroupContribution.fromJson(Map<String, dynamic> json) => _$GroupContributionFromJson(json);
  Map<String, dynamic> toJson() => _$GroupContributionToJson(this);

  String get formattedAmount => '₦${amount.toStringAsFixed(2)}';
  bool get isCompleted => status == ContributionStatus.completed;
  bool get isPending => status == ContributionStatus.pending;
}

@JsonSerializable()
class GroupSettings {
  final bool allowPublicJoin;
  final bool requireApproval;
  final bool allowMemberInvites;
  final bool enableChat;
  final bool enableNotifications;
  final bool autoInvestOnTarget;
  final int contributionReminders;
  final List<String> allowedPaymentMethods;

  GroupSettings({
    this.allowPublicJoin = true,
    this.requireApproval = false,
    this.allowMemberInvites = true,
    this.enableChat = true,
    this.enableNotifications = true,
    this.autoInvestOnTarget = true,
    this.contributionReminders = 3,
    this.allowedPaymentMethods = const ['wallet', 'bank_transfer', 'card'],
  });

  factory GroupSettings.fromJson(Map<String, dynamic> json) => _$GroupSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$GroupSettingsToJson(this);
}

@JsonSerializable()
class GroupInvitation {
  final String id;
  final String groupId;
  final String groupName;
  final String inviterId;
  final String inviterName;
  final String inviteeId;
  final String inviteeEmail;
  final String? inviteePhone;
  final InvitationStatus status;
  final String? message;
  final DateTime expiresAt;
  final DateTime? respondedAt;
  final DateTime createdAt;

  GroupInvitation({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.inviterId,
    required this.inviterName,
    required this.inviteeId,
    required this.inviteeEmail,
    this.inviteePhone,
    required this.status,
    this.message,
    required this.expiresAt,
    this.respondedAt,
    required this.createdAt,
  });

  factory GroupInvitation.fromJson(Map<String, dynamic> json) => _$GroupInvitationFromJson(json);
  Map<String, dynamic> toJson() => _$GroupInvitationToJson(this);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isPending => status == InvitationStatus.pending && !isExpired;
  bool get isAccepted => status == InvitationStatus.accepted;
  bool get isDeclined => status == InvitationStatus.declined;
}

@JsonSerializable()
class GroupActivity {
  final String id;
  final String groupId;
  final String userId;
  final String userName;
  final ActivityType type;
  final String title;
  final String description;
  final Map<String, dynamic> data;
  final DateTime createdAt;

  GroupActivity({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.userName,
    required this.type,
    required this.title,
    required this.description,
    this.data = const {},
    required this.createdAt,
  });

  factory GroupActivity.fromJson(Map<String, dynamic> json) => _$GroupActivityFromJson(json);
  Map<String, dynamic> toJson() => _$GroupActivityToJson(this);
}

enum GroupType {
  @JsonValue('INVESTMENT_CLUB')
  investmentClub,
  @JsonValue('SAVINGS_GROUP')
  savingsGroup,
  @JsonValue('GOAL_BASED')
  goalBased,
  @JsonValue('CHALLENGE')
  challenge,
}

enum GroupPrivacy {
  @JsonValue('PUBLIC')
  public,
  @JsonValue('PRIVATE')
  private,
  @JsonValue('INVITE_ONLY')
  inviteOnly,
}

enum GroupStatus {
  @JsonValue('DRAFT')
  draft,
  @JsonValue('ACTIVE')
  active,
  @JsonValue('PAUSED')
  paused,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('CANCELLED')
  cancelled,
}

enum GroupRole {
  @JsonValue('CREATOR')
  creator,
  @JsonValue('ADMIN')
  admin,
  @JsonValue('MEMBER')
  member,
}

enum ContributionStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('PROCESSING')
  processing,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('FAILED')
  failed,
  @JsonValue('CANCELLED')
  cancelled,
}

enum InvitationStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('ACCEPTED')
  accepted,
  @JsonValue('DECLINED')
  declined,
  @JsonValue('EXPIRED')
  expired,
}

enum ActivityType {
  @JsonValue('GROUP_CREATED')
  groupCreated,
  @JsonValue('MEMBER_JOINED')
  memberJoined,
  @JsonValue('MEMBER_LEFT')
  memberLeft,
  @JsonValue('CONTRIBUTION_MADE')
  contributionMade,
  @JsonValue('TARGET_REACHED')
  targetReached,
  @JsonValue('INVESTMENT_MADE')
  investmentMade,
  @JsonValue('GROUP_COMPLETED')
  groupCompleted,
  @JsonValue('SETTINGS_UPDATED')
  settingsUpdated,
}
