import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? profilePictureUrl;
  final DateTime? dateOfBirth;
  final String? address;
  final KycStatus kycStatus;
  final AccountType accountType;
  final RiskProfile? riskProfile;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final bool isMfaEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.profilePictureUrl,
    this.dateOfBirth,
    this.address,
    this.kycStatus = KycStatus.pending,
    this.accountType = AccountType.individual,
    this.riskProfile,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.isMfaEnabled = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profilePictureUrl,
    DateTime? dateOfBirth,
    String? address,
    KycStatus? kycStatus,
    AccountType? accountType,
    RiskProfile? riskProfile,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    bool? isMfaEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      kycStatus: kycStatus ?? this.kycStatus,
      accountType: accountType ?? this.accountType,
      riskProfile: riskProfile ?? this.riskProfile,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isMfaEnabled: isMfaEnabled ?? this.isMfaEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get fullName => '$firstName $lastName';

  bool get isKycCompleted => kycStatus == KycStatus.approved;

  bool get canInvest => isKycCompleted && isEmailVerified;
}

enum KycStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('APPROVED')
  approved,
  @JsonValue('REJECTED')
  rejected,
  @JsonValue('UNDER_REVIEW')
  underReview,
}

enum AccountType {
  @JsonValue('INDIVIDUAL')
  individual,
  @JsonValue('CORPORATE')
  corporate,
}

enum RiskProfile {
  @JsonValue('CONSERVATIVE')
  conservative,
  @JsonValue('MODERATE')
  moderate,
  @JsonValue('AGGRESSIVE')
  aggressive,
}

@JsonSerializable()
class AuthResponse {
  final User user;
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  AuthResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

@JsonSerializable()
class SignUpRequest {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final AccountType accountType;

  SignUpRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.accountType = AccountType.individual,
  });

  factory SignUpRequest.fromJson(Map<String, dynamic> json) =>
      _$SignUpRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SignUpRequestToJson(this);
}

@JsonSerializable()
class SignInRequest {
  final String email;
  final String password;
  final bool rememberMe;

  SignInRequest({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  factory SignInRequest.fromJson(Map<String, dynamic> json) =>
      _$SignInRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SignInRequestToJson(this);
}
