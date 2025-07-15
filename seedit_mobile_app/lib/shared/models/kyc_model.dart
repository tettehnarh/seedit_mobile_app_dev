import 'package:json_annotation/json_annotation.dart';

part 'kyc_model.g.dart';

@JsonSerializable()
class KycApplication {
  final String id;
  final String userId;
  final KycStatus status;
  final KycLevel level;
  final PersonalInfo personalInfo;
  final IdentityDocuments identityDocuments;
  final AddressVerification? addressVerification;
  final FinancialInfo? financialInfo;
  final NextOfKin? nextOfKin;
  final List<KycDocument> documents;
  final List<KycStatusHistory> statusHistory;
  final String? rejectionReason;
  final String? reviewNotes;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  KycApplication({
    required this.id,
    required this.userId,
    required this.status,
    required this.level,
    required this.personalInfo,
    required this.identityDocuments,
    this.addressVerification,
    this.financialInfo,
    this.nextOfKin,
    required this.documents,
    required this.statusHistory,
    this.rejectionReason,
    this.reviewNotes,
    this.submittedAt,
    this.reviewedAt,
    this.reviewedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory KycApplication.fromJson(Map<String, dynamic> json) => _$KycApplicationFromJson(json);
  Map<String, dynamic> toJson() => _$KycApplicationToJson(this);

  KycApplication copyWith({
    String? id,
    String? userId,
    KycStatus? status,
    KycLevel? level,
    PersonalInfo? personalInfo,
    IdentityDocuments? identityDocuments,
    AddressVerification? addressVerification,
    FinancialInfo? financialInfo,
    NextOfKin? nextOfKin,
    List<KycDocument>? documents,
    List<KycStatusHistory>? statusHistory,
    String? rejectionReason,
    String? reviewNotes,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    String? reviewedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return KycApplication(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      level: level ?? this.level,
      personalInfo: personalInfo ?? this.personalInfo,
      identityDocuments: identityDocuments ?? this.identityDocuments,
      addressVerification: addressVerification ?? this.addressVerification,
      financialInfo: financialInfo ?? this.financialInfo,
      nextOfKin: nextOfKin ?? this.nextOfKin,
      documents: documents ?? this.documents,
      statusHistory: statusHistory ?? this.statusHistory,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      reviewNotes: reviewNotes ?? this.reviewNotes,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double get completionPercentage {
    int completedSteps = 0;
    int totalSteps = 5;

    // Personal Info
    if (personalInfo.isComplete) completedSteps++;
    
    // Identity Documents
    if (identityDocuments.isComplete) completedSteps++;
    
    // Address Verification
    if (addressVerification?.isComplete == true) completedSteps++;
    
    // Financial Info
    if (financialInfo?.isComplete == true) completedSteps++;
    
    // Next of Kin
    if (nextOfKin?.isComplete == true) completedSteps++;

    return (completedSteps / totalSteps) * 100;
  }

  bool get canSubmit => completionPercentage >= 80 && status == KycStatus.draft;

  String get statusDisplayText {
    switch (status) {
      case KycStatus.draft:
        return 'Draft';
      case KycStatus.submitted:
        return 'Under Review';
      case KycStatus.underReview:
        return 'Under Review';
      case KycStatus.approved:
        return 'Approved';
      case KycStatus.rejected:
        return 'Rejected';
      case KycStatus.expired:
        return 'Expired';
    }
  }

  String get levelDisplayText {
    switch (level) {
      case KycLevel.tier1:
        return 'Tier 1 - Basic Verification';
      case KycLevel.tier2:
        return 'Tier 2 - Enhanced Verification';
      case KycLevel.tier3:
        return 'Tier 3 - Premium Verification';
    }
  }
}

@JsonSerializable()
class PersonalInfo {
  final String firstName;
  final String lastName;
  final String middleName;
  final DateTime dateOfBirth;
  final String gender;
  final String nationality;
  final String placeOfBirth;
  final String mothersMaidenName;
  final String phoneNumber;
  final String email;
  final String maritalStatus;

  PersonalInfo({
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.dateOfBirth,
    required this.gender,
    required this.nationality,
    required this.placeOfBirth,
    required this.mothersMaidenName,
    required this.phoneNumber,
    required this.email,
    required this.maritalStatus,
  });

  factory PersonalInfo.fromJson(Map<String, dynamic> json) => _$PersonalInfoFromJson(json);
  Map<String, dynamic> toJson() => _$PersonalInfoToJson(this);

  bool get isComplete {
    return firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        middleName.isNotEmpty &&
        gender.isNotEmpty &&
        nationality.isNotEmpty &&
        placeOfBirth.isNotEmpty &&
        mothersMaidenName.isNotEmpty &&
        phoneNumber.isNotEmpty &&
        email.isNotEmpty &&
        maritalStatus.isNotEmpty;
  }

  String get fullName => '$firstName $middleName $lastName';
}

@JsonSerializable()
class IdentityDocuments {
  final String bvn;
  final String nin;
  final String? passportNumber;
  final String? driversLicenseNumber;
  final String? votersCardNumber;

  IdentityDocuments({
    required this.bvn,
    required this.nin,
    this.passportNumber,
    this.driversLicenseNumber,
    this.votersCardNumber,
  });

  factory IdentityDocuments.fromJson(Map<String, dynamic> json) => _$IdentityDocumentsFromJson(json);
  Map<String, dynamic> toJson() => _$IdentityDocumentsToJson(this);

  bool get isComplete {
    return bvn.isNotEmpty && nin.isNotEmpty;
  }
}

@JsonSerializable()
class AddressVerification {
  final String streetAddress;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final String addressType;
  final DateTime residenceSince;

  AddressVerification({
    required this.streetAddress,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.addressType,
    required this.residenceSince,
  });

  factory AddressVerification.fromJson(Map<String, dynamic> json) => _$AddressVerificationFromJson(json);
  Map<String, dynamic> toJson() => _$AddressVerificationToJson(this);

  bool get isComplete {
    return streetAddress.isNotEmpty &&
        city.isNotEmpty &&
        state.isNotEmpty &&
        country.isNotEmpty &&
        postalCode.isNotEmpty &&
        addressType.isNotEmpty;
  }

  String get fullAddress => '$streetAddress, $city, $state, $country $postalCode';
}

@JsonSerializable()
class FinancialInfo {
  final String occupation;
  final String employer;
  final String employerAddress;
  final double monthlyIncome;
  final String sourceOfIncome;
  final String sourceOfWealth;
  final bool isPoliticallyExposed;
  final String? politicalExposureDetails;

  FinancialInfo({
    required this.occupation,
    required this.employer,
    required this.employerAddress,
    required this.monthlyIncome,
    required this.sourceOfIncome,
    required this.sourceOfWealth,
    required this.isPoliticallyExposed,
    this.politicalExposureDetails,
  });

  factory FinancialInfo.fromJson(Map<String, dynamic> json) => _$FinancialInfoFromJson(json);
  Map<String, dynamic> toJson() => _$FinancialInfoToJson(this);

  bool get isComplete {
    return occupation.isNotEmpty &&
        employer.isNotEmpty &&
        employerAddress.isNotEmpty &&
        monthlyIncome > 0 &&
        sourceOfIncome.isNotEmpty &&
        sourceOfWealth.isNotEmpty;
  }
}

@JsonSerializable()
class NextOfKin {
  final String firstName;
  final String lastName;
  final String relationship;
  final String phoneNumber;
  final String email;
  final String address;

  NextOfKin({
    required this.firstName,
    required this.lastName,
    required this.relationship,
    required this.phoneNumber,
    required this.email,
    required this.address,
  });

  factory NextOfKin.fromJson(Map<String, dynamic> json) => _$NextOfKinFromJson(json);
  Map<String, dynamic> toJson() => _$NextOfKinToJson(this);

  bool get isComplete {
    return firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        relationship.isNotEmpty &&
        phoneNumber.isNotEmpty &&
        email.isNotEmpty &&
        address.isNotEmpty;
  }

  String get fullName => '$firstName $lastName';
}

@JsonSerializable()
class KycDocument {
  final String id;
  final String kycApplicationId;
  final DocumentType type;
  final String fileName;
  final String fileUrl;
  final String mimeType;
  final int fileSize;
  final DocumentStatus status;
  final String? rejectionReason;
  final DateTime uploadedAt;
  final DateTime? verifiedAt;

  KycDocument({
    required this.id,
    required this.kycApplicationId,
    required this.type,
    required this.fileName,
    required this.fileUrl,
    required this.mimeType,
    required this.fileSize,
    required this.status,
    this.rejectionReason,
    required this.uploadedAt,
    this.verifiedAt,
  });

  factory KycDocument.fromJson(Map<String, dynamic> json) => _$KycDocumentFromJson(json);
  Map<String, dynamic> toJson() => _$KycDocumentToJson(this);

  String get typeDisplayText {
    switch (type) {
      case DocumentType.passport:
        return 'International Passport';
      case DocumentType.nationalId:
        return 'National ID Card';
      case DocumentType.driversLicense:
        return 'Driver\'s License';
      case DocumentType.votersCard:
        return 'Voter\'s Card';
      case DocumentType.utilityBill:
        return 'Utility Bill';
      case DocumentType.bankStatement:
        return 'Bank Statement';
      case DocumentType.proofOfAddress:
        return 'Proof of Address';
      case DocumentType.selfie:
        return 'Selfie Photo';
      case DocumentType.signature:
        return 'Signature Sample';
    }
  }

  String get statusDisplayText {
    switch (status) {
      case DocumentStatus.pending:
        return 'Pending Review';
      case DocumentStatus.verified:
        return 'Verified';
      case DocumentStatus.rejected:
        return 'Rejected';
    }
  }
}

@JsonSerializable()
class KycStatusHistory {
  final String id;
  final String kycApplicationId;
  final KycStatus fromStatus;
  final KycStatus toStatus;
  final String? reason;
  final String? notes;
  final String changedBy;
  final DateTime changedAt;

  KycStatusHistory({
    required this.id,
    required this.kycApplicationId,
    required this.fromStatus,
    required this.toStatus,
    this.reason,
    this.notes,
    required this.changedBy,
    required this.changedAt,
  });

  factory KycStatusHistory.fromJson(Map<String, dynamic> json) => _$KycStatusHistoryFromJson(json);
  Map<String, dynamic> toJson() => _$KycStatusHistoryToJson(this);
}

enum KycStatus {
  @JsonValue('DRAFT')
  draft,
  @JsonValue('SUBMITTED')
  submitted,
  @JsonValue('UNDER_REVIEW')
  underReview,
  @JsonValue('APPROVED')
  approved,
  @JsonValue('REJECTED')
  rejected,
  @JsonValue('EXPIRED')
  expired,
}

enum KycLevel {
  @JsonValue('TIER_1')
  tier1,
  @JsonValue('TIER_2')
  tier2,
  @JsonValue('TIER_3')
  tier3,
}

enum DocumentType {
  @JsonValue('PASSPORT')
  passport,
  @JsonValue('NATIONAL_ID')
  nationalId,
  @JsonValue('DRIVERS_LICENSE')
  driversLicense,
  @JsonValue('VOTERS_CARD')
  votersCard,
  @JsonValue('UTILITY_BILL')
  utilityBill,
  @JsonValue('BANK_STATEMENT')
  bankStatement,
  @JsonValue('PROOF_OF_ADDRESS')
  proofOfAddress,
  @JsonValue('SELFIE')
  selfie,
  @JsonValue('SIGNATURE')
  signature,
}

enum DocumentStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('VERIFIED')
  verified,
  @JsonValue('REJECTED')
  rejected,
}
