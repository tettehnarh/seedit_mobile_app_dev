class KycPersonalInfo {
  final String firstName;
  final String lastName;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? nationality;
  final String? phoneNumber;
  final String? address;
  final String? city;
  final String? gpsCode;
  final String? status;

  const KycPersonalInfo({
    required this.firstName,
    required this.lastName,
    this.gender,
    this.dateOfBirth,
    this.nationality,
    this.phoneNumber,
    this.address,
    this.city,
    this.gpsCode,
    this.status,
  });

  factory KycPersonalInfo.fromJson(Map<String, dynamic> json) {
    return KycPersonalInfo(
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      gender: json['gender'],
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'])
          : null,
      nationality: json['nationality'],
      phoneNumber: json['phone_number'],
      address: json['address'],
      city: json['city'],
      gpsCode: json['gps_code'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'gender': gender,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'nationality': nationality,
      'phone_number': phoneNumber,
      'address': address,
      'city': city,
      'gps_code': gpsCode,
      'status': status,
    };
  }
}

class UserModel {
  final String id;
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final bool isEmailVerified;
  final String kycStatus;
  final bool requiresPasswordChange; // Indicates if user must change password
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? nameSource; // 'kyc' or 'user' - indicates source of name data
  final String? avatar; // Profile picture URL
  final KycPersonalInfo?
  kycPersonalInfo; // KYC personal information when available

  const UserModel({
    required this.id,
    required this.email,
    required this.username,
    this.firstName = '',
    this.lastName = '',
    this.phoneNumber,
    this.isEmailVerified = false,
    this.kycStatus = 'not_started',
    this.requiresPasswordChange = false,
    this.createdAt,
    this.updatedAt,
    this.nameSource,
    this.avatar,
    this.kycPersonalInfo,
  });

  String get fullName => '$firstName $lastName'.trim();

  String get displayName => username.isNotEmpty
      ? username
      : (fullName.isNotEmpty ? fullName : email.split('@')[0]);

  bool get isKycCompleted => kycStatus.toLowerCase() == 'approved';

  bool get isKycPending =>
      ['pending_review', 'in_progress'].contains(kycStatus.toLowerCase());

  bool get isKycRejected => kycStatus.toLowerCase() == 'rejected';

  bool get isKycNotStarted => kycStatus.toLowerCase() == 'not_started';

  /// Get the authoritative first name based on KYC status
  String get authoritativeFirstName {
    if (nameSource == 'kyc' && kycPersonalInfo != null) {
      return kycPersonalInfo!.firstName;
    }
    return firstName;
  }

  /// Get the authoritative last name based on KYC status
  String get authoritativeLastName {
    if (nameSource == 'kyc' && kycPersonalInfo != null) {
      return kycPersonalInfo!.lastName;
    }
    return lastName;
  }

  /// Get the authoritative full name based on KYC status
  String get authoritativeFullName =>
      '$authoritativeFirstName $authoritativeLastName'.trim();

  /// Check if personal information should be read-only (KYC is authoritative source)
  bool get isPersonalInfoReadOnly =>
      nameSource == 'kyc' &&
      [
        'approved',
        'pending_review',
        'rejected',
      ].contains(kycStatus.toLowerCase());

  /// Check if user should be prompted to complete KYC
  bool get shouldPromptKyc =>
      ['not_started', 'in_progress'].contains(kycStatus.toLowerCase()) &&
      kycPersonalInfo == null;

  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    bool? isEmailVerified,
    String? kycStatus,
    bool? requiresPasswordChange,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? nameSource,
    String? avatar,
    KycPersonalInfo? kycPersonalInfo,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      kycStatus: kycStatus ?? this.kycStatus,
      requiresPasswordChange:
          requiresPasswordChange ?? this.requiresPasswordChange,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      nameSource: nameSource ?? this.nameSource,
      avatar: avatar ?? this.avatar,
      kycPersonalInfo: kycPersonalInfo ?? this.kycPersonalInfo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'is_email_verified': isEmailVerified,
      'kyc_status': kycStatus,
      'requires_password_change': requiresPasswordChange,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'name_source': nameSource,
      'avatar': avatar,
      'kyc_personal_info': kycPersonalInfo?.toJson(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phoneNumber: json['phone_number'],
      isEmailVerified: json['is_email_verified'] ?? false,
      kycStatus: json['kyc_status'] ?? 'not_started',
      requiresPasswordChange: json['requires_password_change'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      nameSource: json['name_source'],
      avatar: json['avatar'],
      kycPersonalInfo: json['kyc_personal_info'] != null
          ? KycPersonalInfo.fromJson(json['kyc_personal_info'])
          : null,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, username: $username, fullName: $fullName, kycStatus: $kycStatus)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.email == email &&
        other.username == username &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.phoneNumber == phoneNumber &&
        other.isEmailVerified == isEmailVerified &&
        other.kycStatus == kycStatus &&
        other.requiresPasswordChange == requiresPasswordChange;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      email,
      username,
      firstName,
      lastName,
      phoneNumber,
      isEmailVerified,
      kycStatus,
      requiresPasswordChange,
    );
  }
}
