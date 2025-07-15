import 'package:json_annotation/json_annotation.dart';

part 'profile_model.g.dart';

@JsonSerializable()
class UserProfile {
  final String id;
  final String userId;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? profilePictureUrl;
  final DateTime? dateOfBirth;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final String? occupation;
  final String? employer;
  final double? annualIncome;
  final String? bvn;
  final String? nin;
  final KycStatus kycStatus;
  final AccountType accountType;
  final RiskProfile? riskProfile;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final bool isMfaEnabled;
  final bool isProfileComplete;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.profilePictureUrl,
    this.dateOfBirth,
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.occupation,
    this.employer,
    this.annualIncome,
    this.bvn,
    this.nin,
    this.kycStatus = KycStatus.pending,
    this.accountType = AccountType.individual,
    this.riskProfile,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.isMfaEnabled = false,
    this.isProfileComplete = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

  UserProfile copyWith({
    String? id,
    String? userId,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profilePictureUrl,
    DateTime? dateOfBirth,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    String? occupation,
    String? employer,
    double? annualIncome,
    String? bvn,
    String? nin,
    KycStatus? kycStatus,
    AccountType? accountType,
    RiskProfile? riskProfile,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    bool? isMfaEnabled,
    bool? isProfileComplete,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      occupation: occupation ?? this.occupation,
      employer: employer ?? this.employer,
      annualIncome: annualIncome ?? this.annualIncome,
      bvn: bvn ?? this.bvn,
      nin: nin ?? this.nin,
      kycStatus: kycStatus ?? this.kycStatus,
      accountType: accountType ?? this.accountType,
      riskProfile: riskProfile ?? this.riskProfile,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isMfaEnabled: isMfaEnabled ?? this.isMfaEnabled,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get fullName => '$firstName $lastName';

  String get initials {
    final firstInitial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$firstInitial$lastInitial';
  }

  bool get isKycCompleted => kycStatus == KycStatus.approved;

  bool get canInvest => isKycCompleted && isEmailVerified && isProfileComplete;

  double get profileCompletionPercentage {
    int completedFields = 0;
    int totalFields = 15; // Total required fields for complete profile

    if (firstName.isNotEmpty) completedFields++;
    if (lastName.isNotEmpty) completedFields++;
    if (email.isNotEmpty) completedFields++;
    if (phoneNumber?.isNotEmpty == true) completedFields++;
    if (dateOfBirth != null) completedFields++;
    if (address?.isNotEmpty == true) completedFields++;
    if (city?.isNotEmpty == true) completedFields++;
    if (state?.isNotEmpty == true) completedFields++;
    if (country?.isNotEmpty == true) completedFields++;
    if (occupation?.isNotEmpty == true) completedFields++;
    if (employer?.isNotEmpty == true) completedFields++;
    if (annualIncome != null) completedFields++;
    if (bvn?.isNotEmpty == true) completedFields++;
    if (nin?.isNotEmpty == true) completedFields++;
    if (riskProfile != null) completedFields++;

    return (completedFields / totalFields) * 100;
  }

  String get kycStatusDisplayText {
    switch (kycStatus) {
      case KycStatus.pending:
        return 'Pending Verification';
      case KycStatus.approved:
        return 'Verified';
      case KycStatus.rejected:
        return 'Verification Failed';
      case KycStatus.underReview:
        return 'Under Review';
    }
  }

  String get accountTypeDisplayText {
    switch (accountType) {
      case AccountType.individual:
        return 'Individual Account';
      case AccountType.corporate:
        return 'Corporate Account';
    }
  }

  String? get riskProfileDisplayText {
    switch (riskProfile) {
      case RiskProfile.conservative:
        return 'Conservative Investor';
      case RiskProfile.moderate:
        return 'Moderate Investor';
      case RiskProfile.aggressive:
        return 'Aggressive Investor';
      case null:
        return null;
    }
  }
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
class UpdateProfileRequest {
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final String? occupation;
  final String? employer;
  final double? annualIncome;
  final String? bvn;
  final String? nin;
  final RiskProfile? riskProfile;

  UpdateProfileRequest({
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.dateOfBirth,
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.occupation,
    this.employer,
    this.annualIncome,
    this.bvn,
    this.nin,
    this.riskProfile,
  });

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateProfileRequestToJson(this);
}
