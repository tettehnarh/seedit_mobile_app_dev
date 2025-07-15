import '../utils/date_formatter.dart';

/// Django Model Choice Constants
class KycChoices {
  // Gender choices (PersonalInformation.gender)
  static const List<Map<String, String>> genderChoices = [
    {'value': 'male', 'label': 'Male'},
    {'value': 'female', 'label': 'Female'},
  ];

  // Relationship choices (NextOfKin.relationship)
  static const List<Map<String, String>> relationshipChoices = [
    {'value': 'parent', 'label': 'Parent'},
    {'value': 'spouse', 'label': 'Spouse'},
    {'value': 'sibling', 'label': 'Sibling'},
    {'value': 'child', 'label': 'Child'},
    {'value': 'other_relative', 'label': 'Other Relative'},
    {'value': 'friend', 'label': 'Friend'},
    {'value': 'other', 'label': 'Other'},
  ];

  // Employment status choices (ProfessionalInformation.employment_status)
  static const List<Map<String, String>> employmentStatusChoices = [
    {'value': 'employed', 'label': 'Employed'},
    {'value': 'self_employed', 'label': 'Self-Employed'},
    {'value': 'unemployed', 'label': 'Unemployed'},
    {'value': 'student', 'label': 'Student'},
    {'value': 'retired', 'label': 'Retired'},
    {'value': 'other', 'label': 'Other'},
  ];

  // Source of income choices (ProfessionalInformation.source_of_income)
  static const List<Map<String, String>> sourceOfIncomeChoices = [
    {'value': 'salary', 'label': 'Salary'},
    {'value': 'business', 'label': 'Business'},
    {'value': 'investments', 'label': 'Investments'},
    {'value': 'pension', 'label': 'Pension'},
    {'value': 'allowance', 'label': 'Allowance'},
    {'value': 'other', 'label': 'Other'},
  ];

  // ID type choices (IDInformation.id_type)
  static const List<Map<String, String>> idTypeChoices = [
    {'value': 'passport', 'label': 'Passport'},
    {'value': 'national_id', 'label': 'National ID'},
    {'value': 'drivers_license', 'label': 'Driver\'s License'},
  ];

  // Monthly income choices in GHS currency
  static const List<Map<String, String>> monthlyIncomeChoices = [
    {'value': 'below_1000', 'label': 'Below GHS 1,000'},
    {'value': '1000_5000', 'label': 'Between GHS 1,000 - 5,000'},
    {'value': '5000_10000', 'label': 'Between GHS 5,000 - 10,000'},
    {'value': 'above_10000', 'label': 'Above GHS 10,000'},
  ];

  // World countries with flag emojis for nationality dropdown
  static const List<Map<String, String>> countryChoices = [
    {'value': 'afghanistan', 'label': 'Afghanistan', 'flag': '🇦🇫'},
    {'value': 'albania', 'label': 'Albania', 'flag': '🇦🇱'},
    {'value': 'algeria', 'label': 'Algeria', 'flag': '🇩🇿'},
    {'value': 'andorra', 'label': 'Andorra', 'flag': '🇦🇩'},
    {'value': 'angola', 'label': 'Angola', 'flag': '🇦🇴'},
    {
      'value': 'antigua_and_barbuda',
      'label': 'Antigua and Barbuda',
      'flag': '🇦🇬',
    },
    {'value': 'argentina', 'label': 'Argentina', 'flag': '🇦🇷'},
    {'value': 'armenia', 'label': 'Armenia', 'flag': '🇦🇲'},
    {'value': 'australia', 'label': 'Australia', 'flag': '🇦🇺'},
    {'value': 'austria', 'label': 'Austria', 'flag': '🇦🇹'},
    {'value': 'azerbaijan', 'label': 'Azerbaijan', 'flag': '🇦🇿'},
    {'value': 'bahamas', 'label': 'Bahamas', 'flag': '🇧🇸'},
    {'value': 'bahrain', 'label': 'Bahrain', 'flag': '🇧🇭'},
    {'value': 'bangladesh', 'label': 'Bangladesh', 'flag': '🇧🇩'},
    {'value': 'barbados', 'label': 'Barbados', 'flag': '🇧🇧'},
    {'value': 'belarus', 'label': 'Belarus', 'flag': '🇧🇾'},
    {'value': 'belgium', 'label': 'Belgium', 'flag': '🇧🇪'},
    {'value': 'belize', 'label': 'Belize', 'flag': '🇧🇿'},
    {'value': 'benin', 'label': 'Benin', 'flag': '🇧🇯'},
    {'value': 'bhutan', 'label': 'Bhutan', 'flag': '🇧🇹'},
    {'value': 'bolivia', 'label': 'Bolivia', 'flag': '🇧🇴'},
    {
      'value': 'bosnia_and_herzegovina',
      'label': 'Bosnia and Herzegovina',
      'flag': '🇧🇦',
    },
    {'value': 'botswana', 'label': 'Botswana', 'flag': '🇧🇼'},
    {'value': 'brazil', 'label': 'Brazil', 'flag': '🇧🇷'},
    {'value': 'brunei', 'label': 'Brunei', 'flag': '🇧🇳'},
    {'value': 'bulgaria', 'label': 'Bulgaria', 'flag': '🇧🇬'},
    {'value': 'burkina_faso', 'label': 'Burkina Faso', 'flag': '🇧🇫'},
    {'value': 'burundi', 'label': 'Burundi', 'flag': '🇧🇮'},
    {'value': 'cabo_verde', 'label': 'Cabo Verde', 'flag': '🇨🇻'},
    {'value': 'cambodia', 'label': 'Cambodia', 'flag': '🇰🇭'},
    {'value': 'cameroon', 'label': 'Cameroon', 'flag': '🇨🇲'},
    {'value': 'canada', 'label': 'Canada', 'flag': '🇨🇦'},
    {
      'value': 'central_african_republic',
      'label': 'Central African Republic',
      'flag': '🇨🇫',
    },
    {'value': 'chad', 'label': 'Chad', 'flag': '🇹🇩'},
    {'value': 'chile', 'label': 'Chile', 'flag': '🇨🇱'},
    {'value': 'china', 'label': 'China', 'flag': '🇨🇳'},
    {'value': 'colombia', 'label': 'Colombia', 'flag': '🇨🇴'},
    {'value': 'comoros', 'label': 'Comoros', 'flag': '🇰🇲'},
    {
      'value': 'congo_brazzaville',
      'label': 'Congo (Brazzaville)',
      'flag': '🇨🇬',
    },
    {'value': 'congo_kinshasa', 'label': 'Congo (Kinshasa)', 'flag': '🇨🇩'},
    {'value': 'costa_rica', 'label': 'Costa Rica', 'flag': '🇨🇷'},
    {'value': 'cote_divoire', 'label': 'Côte d\'Ivoire', 'flag': '🇨🇮'},
    {'value': 'croatia', 'label': 'Croatia', 'flag': '🇭🇷'},
    {'value': 'cuba', 'label': 'Cuba', 'flag': '🇨🇺'},
    {'value': 'cyprus', 'label': 'Cyprus', 'flag': '🇨🇾'},
    {'value': 'czech_republic', 'label': 'Czech Republic', 'flag': '🇨🇿'},
    {'value': 'denmark', 'label': 'Denmark', 'flag': '🇩🇰'},
    {'value': 'djibouti', 'label': 'Djibouti', 'flag': '🇩🇯'},
    {'value': 'dominica', 'label': 'Dominica', 'flag': '🇩🇲'},
    {
      'value': 'dominican_republic',
      'label': 'Dominican Republic',
      'flag': '🇩🇴',
    },
    {'value': 'ecuador', 'label': 'Ecuador', 'flag': '🇪🇨'},
    {'value': 'egypt', 'label': 'Egypt', 'flag': '🇪🇬'},
    {'value': 'el_salvador', 'label': 'El Salvador', 'flag': '🇸🇻'},
    {
      'value': 'equatorial_guinea',
      'label': 'Equatorial Guinea',
      'flag': '🇬🇶',
    },
    {'value': 'eritrea', 'label': 'Eritrea', 'flag': '🇪🇷'},
    {'value': 'estonia', 'label': 'Estonia', 'flag': '🇪🇪'},
    {'value': 'eswatini', 'label': 'Eswatini', 'flag': '🇸🇿'},
    {'value': 'ethiopia', 'label': 'Ethiopia', 'flag': '🇪🇹'},
    {'value': 'fiji', 'label': 'Fiji', 'flag': '🇫🇯'},
    {'value': 'finland', 'label': 'Finland', 'flag': '🇫🇮'},
    {'value': 'france', 'label': 'France', 'flag': '🇫🇷'},
    {'value': 'gabon', 'label': 'Gabon', 'flag': '🇬🇦'},
    {'value': 'gambia', 'label': 'Gambia', 'flag': '🇬🇲'},
    {'value': 'georgia', 'label': 'Georgia', 'flag': '🇬🇪'},
    {'value': 'germany', 'label': 'Germany', 'flag': '🇩🇪'},
    {'value': 'ghana', 'label': 'Ghana', 'flag': '🇬🇭'},
    {'value': 'greece', 'label': 'Greece', 'flag': '🇬🇷'},
    {'value': 'grenada', 'label': 'Grenada', 'flag': '🇬🇩'},
    {'value': 'guatemala', 'label': 'Guatemala', 'flag': '🇬🇹'},
    {'value': 'guinea', 'label': 'Guinea', 'flag': '🇬🇳'},
    {'value': 'guinea_bissau', 'label': 'Guinea-Bissau', 'flag': '🇬🇼'},
    {'value': 'guyana', 'label': 'Guyana', 'flag': '🇬🇾'},
    {'value': 'haiti', 'label': 'Haiti', 'flag': '🇭🇹'},
    {'value': 'honduras', 'label': 'Honduras', 'flag': '🇭🇳'},
    {'value': 'hungary', 'label': 'Hungary', 'flag': '🇭🇺'},
    {'value': 'iceland', 'label': 'Iceland', 'flag': '🇮🇸'},
    {'value': 'india', 'label': 'India', 'flag': '🇮🇳'},
    {'value': 'indonesia', 'label': 'Indonesia', 'flag': '🇮🇩'},
    {'value': 'iran', 'label': 'Iran', 'flag': '🇮🇷'},
    {'value': 'iraq', 'label': 'Iraq', 'flag': '🇮🇶'},
    {'value': 'ireland', 'label': 'Ireland', 'flag': '🇮🇪'},
    {'value': 'israel', 'label': 'Israel', 'flag': '🇮🇱'},
    {'value': 'italy', 'label': 'Italy', 'flag': '🇮🇹'},
    {'value': 'jamaica', 'label': 'Jamaica', 'flag': '🇯🇲'},
    {'value': 'japan', 'label': 'Japan', 'flag': '🇯🇵'},
    {'value': 'jordan', 'label': 'Jordan', 'flag': '🇯🇴'},
    {'value': 'kazakhstan', 'label': 'Kazakhstan', 'flag': '🇰🇿'},
    {'value': 'kenya', 'label': 'Kenya', 'flag': '🇰🇪'},
    {'value': 'kiribati', 'label': 'Kiribati', 'flag': '🇰🇮'},
    {'value': 'korea_north', 'label': 'Korea (North)', 'flag': '🇰🇵'},
    {'value': 'korea_south', 'label': 'Korea (South)', 'flag': '🇰🇷'},
    {'value': 'kuwait', 'label': 'Kuwait', 'flag': '🇰🇼'},
    {'value': 'kyrgyzstan', 'label': 'Kyrgyzstan', 'flag': '🇰🇬'},
    {'value': 'laos', 'label': 'Laos', 'flag': '🇱🇦'},
    {'value': 'latvia', 'label': 'Latvia', 'flag': '🇱🇻'},
    {'value': 'lebanon', 'label': 'Lebanon', 'flag': '🇱🇧'},
    {'value': 'lesotho', 'label': 'Lesotho', 'flag': '🇱🇸'},
    {'value': 'liberia', 'label': 'Liberia', 'flag': '🇱🇷'},
    {'value': 'libya', 'label': 'Libya', 'flag': '🇱🇾'},
    {'value': 'liechtenstein', 'label': 'Liechtenstein', 'flag': '🇱🇮'},
    {'value': 'lithuania', 'label': 'Lithuania', 'flag': '🇱🇹'},
    {'value': 'luxembourg', 'label': 'Luxembourg', 'flag': '🇱🇺'},
    {'value': 'madagascar', 'label': 'Madagascar', 'flag': '🇲🇬'},
    {'value': 'malawi', 'label': 'Malawi', 'flag': '🇲🇼'},
    {'value': 'malaysia', 'label': 'Malaysia', 'flag': '🇲🇾'},
    {'value': 'maldives', 'label': 'Maldives', 'flag': '🇲🇻'},
    {'value': 'mali', 'label': 'Mali', 'flag': '🇲🇱'},
    {'value': 'malta', 'label': 'Malta', 'flag': '🇲🇹'},
    {'value': 'marshall_islands', 'label': 'Marshall Islands', 'flag': '🇲🇭'},
    {'value': 'mauritania', 'label': 'Mauritania', 'flag': '🇲🇷'},
    {'value': 'mauritius', 'label': 'Mauritius', 'flag': '🇲🇺'},
    {'value': 'mexico', 'label': 'Mexico', 'flag': '🇲🇽'},
    {'value': 'micronesia', 'label': 'Micronesia', 'flag': '🇫🇲'},
    {'value': 'moldova', 'label': 'Moldova', 'flag': '🇲🇩'},
    {'value': 'monaco', 'label': 'Monaco', 'flag': '🇲🇨'},
    {'value': 'mongolia', 'label': 'Mongolia', 'flag': '🇲🇳'},
    {'value': 'montenegro', 'label': 'Montenegro', 'flag': '🇲🇪'},
    {'value': 'morocco', 'label': 'Morocco', 'flag': '🇲🇦'},
    {'value': 'mozambique', 'label': 'Mozambique', 'flag': '🇲🇿'},
    {'value': 'myanmar', 'label': 'Myanmar', 'flag': '🇲🇲'},
    {'value': 'namibia', 'label': 'Namibia', 'flag': '🇳🇦'},
    {'value': 'nauru', 'label': 'Nauru', 'flag': '🇳🇷'},
    {'value': 'nepal', 'label': 'Nepal', 'flag': '🇳🇵'},
    {'value': 'netherlands', 'label': 'Netherlands', 'flag': '🇳🇱'},
    {'value': 'new_zealand', 'label': 'New Zealand', 'flag': '🇳🇿'},
    {'value': 'nicaragua', 'label': 'Nicaragua', 'flag': '🇳🇮'},
    {'value': 'niger', 'label': 'Niger', 'flag': '🇳🇪'},
    {'value': 'nigeria', 'label': 'Nigeria', 'flag': '🇳🇬'},
    {'value': 'north_macedonia', 'label': 'North Macedonia', 'flag': '🇲🇰'},
    {'value': 'norway', 'label': 'Norway', 'flag': '🇳🇴'},
    {'value': 'oman', 'label': 'Oman', 'flag': '🇴🇲'},
    {'value': 'pakistan', 'label': 'Pakistan', 'flag': '🇵🇰'},
    {'value': 'palau', 'label': 'Palau', 'flag': '🇵🇼'},
    {'value': 'panama', 'label': 'Panama', 'flag': '🇵🇦'},
    {'value': 'papua_new_guinea', 'label': 'Papua New Guinea', 'flag': '🇵🇬'},
    {'value': 'paraguay', 'label': 'Paraguay', 'flag': '🇵🇾'},
    {'value': 'peru', 'label': 'Peru', 'flag': '🇵🇪'},
    {'value': 'philippines', 'label': 'Philippines', 'flag': '🇵🇭'},
    {'value': 'poland', 'label': 'Poland', 'flag': '🇵🇱'},
    {'value': 'portugal', 'label': 'Portugal', 'flag': '🇵🇹'},
    {'value': 'qatar', 'label': 'Qatar', 'flag': '🇶🇦'},
    {'value': 'romania', 'label': 'Romania', 'flag': '🇷🇴'},
    {'value': 'russia', 'label': 'Russia', 'flag': '🇷🇺'},
    {'value': 'rwanda', 'label': 'Rwanda', 'flag': '🇷🇼'},
    {
      'value': 'saint_kitts_and_nevis',
      'label': 'Saint Kitts and Nevis',
      'flag': '🇰🇳',
    },
    {'value': 'saint_lucia', 'label': 'Saint Lucia', 'flag': '🇱🇨'},
    {
      'value': 'saint_vincent_and_the_grenadines',
      'label': 'Saint Vincent and the Grenadines',
      'flag': '🇻🇨',
    },
    {'value': 'samoa', 'label': 'Samoa', 'flag': '🇼🇸'},
    {'value': 'san_marino', 'label': 'San Marino', 'flag': '🇸🇲'},
    {
      'value': 'sao_tome_and_principe',
      'label': 'São Tomé and Príncipe',
      'flag': '🇸🇹',
    },
    {'value': 'saudi_arabia', 'label': 'Saudi Arabia', 'flag': '🇸🇦'},
    {'value': 'senegal', 'label': 'Senegal', 'flag': '🇸🇳'},
    {'value': 'serbia', 'label': 'Serbia', 'flag': '🇷🇸'},
    {'value': 'seychelles', 'label': 'Seychelles', 'flag': '🇸🇨'},
    {'value': 'sierra_leone', 'label': 'Sierra Leone', 'flag': '🇸🇱'},
    {'value': 'singapore', 'label': 'Singapore', 'flag': '🇸🇬'},
    {'value': 'slovakia', 'label': 'Slovakia', 'flag': '🇸🇰'},
    {'value': 'slovenia', 'label': 'Slovenia', 'flag': '🇸🇮'},
    {'value': 'solomon_islands', 'label': 'Solomon Islands', 'flag': '🇸🇧'},
    {'value': 'somalia', 'label': 'Somalia', 'flag': '🇸🇴'},
    {'value': 'south_africa', 'label': 'South Africa', 'flag': '🇿🇦'},
    {'value': 'south_sudan', 'label': 'South Sudan', 'flag': '🇸🇸'},
    {'value': 'spain', 'label': 'Spain', 'flag': '🇪🇸'},
    {'value': 'sri_lanka', 'label': 'Sri Lanka', 'flag': '🇱🇰'},
    {'value': 'sudan', 'label': 'Sudan', 'flag': '🇸🇩'},
    {'value': 'suriname', 'label': 'Suriname', 'flag': '🇸🇷'},
    {'value': 'sweden', 'label': 'Sweden', 'flag': '🇸🇪'},
    {'value': 'switzerland', 'label': 'Switzerland', 'flag': '🇨🇭'},
    {'value': 'syria', 'label': 'Syria', 'flag': '🇸🇾'},
    {'value': 'taiwan', 'label': 'Taiwan', 'flag': '🇹🇼'},
    {'value': 'tajikistan', 'label': 'Tajikistan', 'flag': '🇹🇯'},
    {'value': 'tanzania', 'label': 'Tanzania', 'flag': '🇹🇿'},
    {'value': 'thailand', 'label': 'Thailand', 'flag': '🇹🇭'},
    {'value': 'timor_leste', 'label': 'Timor-Leste', 'flag': '🇹🇱'},
    {'value': 'togo', 'label': 'Togo', 'flag': '🇹🇬'},
    {'value': 'tonga', 'label': 'Tonga', 'flag': '🇹🇴'},
    {
      'value': 'trinidad_and_tobago',
      'label': 'Trinidad and Tobago',
      'flag': '🇹🇹',
    },
    {'value': 'tunisia', 'label': 'Tunisia', 'flag': '🇹🇳'},
    {'value': 'turkey', 'label': 'Turkey', 'flag': '🇹🇷'},
    {'value': 'turkmenistan', 'label': 'Turkmenistan', 'flag': '🇹🇲'},
    {'value': 'tuvalu', 'label': 'Tuvalu', 'flag': '🇹🇻'},
    {'value': 'uganda', 'label': 'Uganda', 'flag': '🇺🇬'},
    {'value': 'ukraine', 'label': 'Ukraine', 'flag': '🇺🇦'},
    {
      'value': 'united_arab_emirates',
      'label': 'United Arab Emirates',
      'flag': '🇦🇪',
    },
    {'value': 'united_kingdom', 'label': 'United Kingdom', 'flag': '🇬🇧'},
    {'value': 'united_states', 'label': 'United States', 'flag': '🇺🇸'},
    {'value': 'uruguay', 'label': 'Uruguay', 'flag': '🇺🇾'},
    {'value': 'uzbekistan', 'label': 'Uzbekistan', 'flag': '🇺🇿'},
    {'value': 'vanuatu', 'label': 'Vanuatu', 'flag': '🇻🇺'},
    {'value': 'vatican_city', 'label': 'Vatican City', 'flag': '🇻🇦'},
    {'value': 'venezuela', 'label': 'Venezuela', 'flag': '🇻🇪'},
    {'value': 'vietnam', 'label': 'Vietnam', 'flag': '🇻🇳'},
    {'value': 'yemen', 'label': 'Yemen', 'flag': '🇾🇪'},
    {'value': 'zambia', 'label': 'Zambia', 'flag': '🇿🇲'},
    {'value': 'zimbabwe', 'label': 'Zimbabwe', 'flag': '🇿🇼'},
  ];
}

/// KYC Status Enum - Aligned with Django backend STATUS_CHOICES
enum KycStatusEnum {
  notStarted,
  inProgress,
  pendingReview,
  approved,
  rejected;

  factory KycStatusEnum.fromString(String status) {
    switch (status.toLowerCase()) {
      case 'not_started':
        return KycStatusEnum.notStarted;
      case 'in_progress':
        return KycStatusEnum.inProgress;
      case 'pending_review':
      case 'pending':
      case 'under_review': // Map under_review to pending_review for backward compatibility
        return KycStatusEnum.pendingReview;
      case 'approved':
        return KycStatusEnum.approved;
      case 'rejected':
        return KycStatusEnum.rejected;
      default:
        return KycStatusEnum.notStarted;
    }
  }

  String toDisplayString() {
    switch (this) {
      case KycStatusEnum.notStarted:
        return 'Not Started';
      case KycStatusEnum.inProgress:
        return 'In Progress';
      case KycStatusEnum.pendingReview:
        return 'Pending Review';
      case KycStatusEnum.approved:
        return 'Approved';
      case KycStatusEnum.rejected:
        return 'Rejected';
    }
  }

  String toBackendString() {
    switch (this) {
      case KycStatusEnum.notStarted:
        return 'not_started';
      case KycStatusEnum.inProgress:
        return 'in_progress';
      case KycStatusEnum.pendingReview:
        return 'pending_review';
      case KycStatusEnum.approved:
        return 'approved';
      case KycStatusEnum.rejected:
        return 'rejected';
    }
  }
}

class KycDocument {
  final String id;
  final String type; // 'passport', 'national_id', 'driver_license'
  final String documentNumber;
  final String? frontImagePath;
  final String? backImagePath;
  final DateTime? expiryDate;
  final String status; // 'pending', 'approved', 'rejected'
  final String? rejectionReason;
  final DateTime uploadedAt;

  const KycDocument({
    required this.id,
    required this.type,
    required this.documentNumber,
    this.frontImagePath,
    this.backImagePath,
    this.expiryDate,
    this.status = 'pending',
    this.rejectionReason,
    required this.uploadedAt,
  });

  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isRejected => status.toLowerCase() == 'rejected';

  KycDocument copyWith({
    String? id,
    String? type,
    String? documentNumber,
    String? frontImagePath,
    String? backImagePath,
    DateTime? expiryDate,
    String? status,
    String? rejectionReason,
    DateTime? uploadedAt,
  }) {
    return KycDocument(
      id: id ?? this.id,
      type: type ?? this.type,
      documentNumber: documentNumber ?? this.documentNumber,
      frontImagePath: frontImagePath ?? this.frontImagePath,
      backImagePath: backImagePath ?? this.backImagePath,
      expiryDate: expiryDate ?? this.expiryDate,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }

  factory KycDocument.fromJson(Map<String, dynamic> json) {
    return KycDocument(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? '',
      documentNumber: json['document_number'] ?? '',
      // Handle both backend format (url) and frontend format (front_image_path)
      frontImagePath: json['url'] ?? json['front_image_path'],
      backImagePath: json['back_image_path'],
      expiryDate: json['expiry_date'] != null
          ? DateTime.tryParse(json['expiry_date'])
          : null,
      status: json['status'] ?? 'pending',
      rejectionReason: json['rejection_reason'],
      uploadedAt:
          DateTime.tryParse(json['uploaded_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'document_number': documentNumber,
      'front_image_path': frontImagePath,
      'back_image_path': backImagePath,
      'expiry_date': expiryDate?.toIso8601String(),
      'status': status,
      'rejection_reason': rejectionReason,
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }
}

class KycPersonalInfo {
  final String firstName;
  final String lastName;
  final String gender; // Added to match Django PersonalInformation.gender
  final DateTime dateOfBirth;
  final String nationality;
  final String phoneNumber;
  final String address;
  final String city;
  final String? gpsCode; // Added to match Django PersonalInformation.gps_code

  const KycPersonalInfo({
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.dateOfBirth,
    required this.nationality,
    required this.phoneNumber,
    required this.address,
    required this.city,
    this.gpsCode,
  });

  KycPersonalInfo copyWith({
    String? firstName,
    String? lastName,
    String? gender,
    DateTime? dateOfBirth,
    String? nationality,
    String? phoneNumber,
    String? address,
    String? city,
    String? gpsCode,
  }) {
    return KycPersonalInfo(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      nationality: nationality ?? this.nationality,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      city: city ?? this.city,
      gpsCode: gpsCode ?? this.gpsCode,
    );
  }

  factory KycPersonalInfo.fromJson(Map<String, dynamic> json) {
    return KycPersonalInfo(
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      gender: json['gender'] ?? '',
      dateOfBirth:
          KycDateFormatter.parseDate(json['date_of_birth'] ?? '') ??
          DateTime.now(),
      nationality: json['nationality'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      gpsCode: json['gps_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'gender': gender,
      'date_of_birth': KycDateFormatter.formatForBackend(dateOfBirth),
      'nationality': nationality,
      'phone_number': phoneNumber,
      'address': address,
      'city': city,
      'gps_code': gpsCode,
    };
  }

  factory KycPersonalInfo.empty() {
    return KycPersonalInfo(
      firstName: '',
      lastName: '',
      gender: '',
      dateOfBirth: DateTime.now(),
      nationality: '',
      phoneNumber: '',
      address: '',
      city: '',
    );
  }
}

class KycFinancialInfo {
  final String employmentStatus;
  final String profession; // Renamed from occupation to match Django
  final String institutionName; // Renamed from employer to match Django
  final String
  monthlyIncome; // Changed from double annualIncome to String monthlyIncome
  final String sourceOfIncome;
  // Removed: netWorth, investmentExperience, riskTolerance (not in Django model)

  const KycFinancialInfo({
    required this.employmentStatus,
    required this.profession,
    required this.institutionName,
    required this.monthlyIncome,
    required this.sourceOfIncome,
  });

  KycFinancialInfo copyWith({
    String? employmentStatus,
    String? profession,
    String? institutionName,
    String? monthlyIncome,
    String? sourceOfIncome,
  }) {
    return KycFinancialInfo(
      employmentStatus: employmentStatus ?? this.employmentStatus,
      profession: profession ?? this.profession,
      institutionName: institutionName ?? this.institutionName,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      sourceOfIncome: sourceOfIncome ?? this.sourceOfIncome,
    );
  }

  factory KycFinancialInfo.fromJson(Map<String, dynamic> json) {
    return KycFinancialInfo(
      employmentStatus: json['employment_status'] ?? '',
      profession:
          json['profession'] ??
          json['occupation'] ??
          '', // Support both field names
      institutionName:
          json['institution_name'] ??
          json['employer'] ??
          '', // Support both field names
      monthlyIncome:
          json['monthly_income'] ?? json['annual_income']?.toString() ?? '',
      sourceOfIncome: json['source_of_income'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employment_status': employmentStatus,
      'profession': profession,
      'institution_name': institutionName,
      'monthly_income': monthlyIncome,
      'source_of_income': sourceOfIncome,
    };
  }

  factory KycFinancialInfo.empty() {
    return const KycFinancialInfo(
      employmentStatus: '',
      profession: '',
      institutionName: '',
      monthlyIncome: '',
      sourceOfIncome: '',
    );
  }
}

/// Next of Kin Information Model - Aligned with Django NextOfKin
class KycNextOfKin {
  final String firstName;
  final String lastName;
  final String relationship;
  final String phoneNumber;
  final String email;
  // Removed address field - not in Django NextOfKin model

  const KycNextOfKin({
    required this.firstName,
    required this.lastName,
    required this.relationship,
    required this.phoneNumber,
    required this.email,
  });

  KycNextOfKin copyWith({
    String? firstName,
    String? lastName,
    String? relationship,
    String? phoneNumber,
    String? email,
  }) {
    return KycNextOfKin(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      relationship: relationship ?? this.relationship,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
    );
  }

  factory KycNextOfKin.fromJson(Map<String, dynamic> json) {
    return KycNextOfKin(
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      relationship: json['relationship'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'relationship': relationship,
      'phone_number': phoneNumber,
      'email': email,
    };
  }

  factory KycNextOfKin.empty() {
    return const KycNextOfKin(
      firstName: '',
      lastName: '',
      relationship: '',
      phoneNumber: '',
      email: '',
    );
  }
}

/// ID Information Model - Aligned with Django IDInformation
class KycIdInformation {
  final String idType;
  final String idNumber;
  final DateTime issueDate; // Changed to DateTime to match Django DateField
  final DateTime expiryDate; // Changed to DateTime to match Django DateField
  final String? idDocumentFront;
  final String? idDocumentBack;
  final String? selfieDocument;

  const KycIdInformation({
    required this.idType,
    required this.idNumber,
    required this.issueDate,
    required this.expiryDate,
    this.idDocumentFront,
    this.idDocumentBack,
    this.selfieDocument,
  });

  KycIdInformation copyWith({
    String? idType,
    String? idNumber,
    DateTime? issueDate,
    DateTime? expiryDate,
    String? idDocumentFront,
    String? idDocumentBack,
    String? selfieDocument,
  }) {
    return KycIdInformation(
      idType: idType ?? this.idType,
      idNumber: idNumber ?? this.idNumber,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      idDocumentFront: idDocumentFront ?? this.idDocumentFront,
      idDocumentBack: idDocumentBack ?? this.idDocumentBack,
      selfieDocument: selfieDocument ?? this.selfieDocument,
    );
  }

  factory KycIdInformation.fromJson(Map<String, dynamic> json) {
    return KycIdInformation(
      idType: json['id_type'] ?? '',
      idNumber: json['id_number'] ?? '',
      issueDate:
          KycDateFormatter.parseDate(json['issue_date'] ?? '') ??
          DateTime.now(),
      expiryDate:
          KycDateFormatter.parseDate(json['expiry_date'] ?? '') ??
          DateTime.now(),
      idDocumentFront: json['id_document_front'],
      idDocumentBack: json['id_document_back'],
      selfieDocument:
          json['selfie_document'] ??
          json['selfie_with_id'], // Support both field names
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_type': idType,
      'id_number': idNumber,
      'issue_date': KycDateFormatter.formatForBackend(issueDate),
      'expiry_date': KycDateFormatter.formatForBackend(expiryDate),
      'id_document_front': idDocumentFront,
      'id_document_back': idDocumentBack,
      'selfie_document': selfieDocument, // Use Django field name
    };
  }

  factory KycIdInformation.empty() {
    return KycIdInformation(
      idType: '',
      idNumber: '',
      issueDate: DateTime.now(),
      expiryDate: DateTime.now(),
    );
  }
}

class KycStatus {
  final String id;
  final String
  status; // 'not_started', 'in_progress', 'pending_review', 'approved', 'rejected'
  final KycPersonalInfo? personalInfo;
  final KycFinancialInfo? financialInfo;
  final KycNextOfKin? nextOfKin; // Added Next of Kin
  final KycIdInformation? idInformation; // Added ID Information
  final List<KycDocument> documents;
  final String? rejectionReason;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final DateTime lastUpdated;

  const KycStatus({
    required this.id,
    required this.status,
    this.personalInfo,
    this.financialInfo,
    this.nextOfKin,
    this.idInformation,
    this.documents = const [],
    this.rejectionReason,
    this.submittedAt,
    this.reviewedAt,
    required this.lastUpdated,
  });

  bool get isNotStarted => status.toLowerCase() == 'not_started';
  bool get isInProgress => status.toLowerCase() == 'in_progress';
  bool get isPendingReview => status.toLowerCase() == 'pending_review';
  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isRejected => status.toLowerCase() == 'rejected';

  /// Check if KYC is in any review state (pending_review, under_review)
  bool get isUnderReview =>
      isPendingReview || status.toLowerCase() == 'under_review';

  /// Check if KYC should be in read-only mode
  bool get isReadOnly => isUnderReview || isApproved;

  double get completionPercentage {
    int completed = 0;
    int total =
        5; // personal info, financial info, next of kin, id info, documents

    if (personalInfo != null) completed++;
    if (financialInfo != null) completed++;
    if (nextOfKin != null) completed++;
    if (idInformation != null) completed++;
    if (documents.isNotEmpty) completed++;

    return completed / total;
  }

  // Convenience getters for status enum
  KycStatusEnum get statusEnum => KycStatusEnum.fromString(status);

  KycStatus copyWith({
    String? id,
    String? status,
    KycPersonalInfo? personalInfo,
    KycFinancialInfo? financialInfo,
    KycNextOfKin? nextOfKin,
    KycIdInformation? idInformation,
    List<KycDocument>? documents,
    String? rejectionReason,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    DateTime? lastUpdated,
  }) {
    return KycStatus(
      id: id ?? this.id,
      status: status ?? this.status,
      personalInfo: personalInfo ?? this.personalInfo,
      financialInfo: financialInfo ?? this.financialInfo,
      nextOfKin: nextOfKin ?? this.nextOfKin,
      idInformation: idInformation ?? this.idInformation,
      documents: documents ?? this.documents,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  factory KycStatus.fromJson(Map<String, dynamic> json) {
    final documentsList = (json['documents'] as List<dynamic>? ?? [])
        .map((item) => KycDocument.fromJson(item as Map<String, dynamic>))
        .toList();

    return KycStatus(
      id: json['id']?.toString() ?? '',
      status: json['status'] ?? 'not_started',
      personalInfo: json['personal_info'] != null
          ? KycPersonalInfo.fromJson(json['personal_info'])
          : null,
      financialInfo: json['financial_info'] != null
          ? KycFinancialInfo.fromJson(json['financial_info'])
          : null,
      nextOfKin: json['next_of_kin'] != null
          ? KycNextOfKin.fromJson(json['next_of_kin'])
          : null,
      idInformation: json['id_information'] != null
          ? KycIdInformation.fromJson(json['id_information'])
          : null,
      documents: documentsList,
      rejectionReason: json['rejection_reason'],
      submittedAt: json['submitted_at'] != null
          ? DateTime.tryParse(json['submitted_at'])
          : null,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.tryParse(json['reviewed_at'])
          : null,
      lastUpdated:
          DateTime.tryParse(json['last_updated'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'personal_info': personalInfo?.toJson(),
      'financial_info': financialInfo?.toJson(),
      'next_of_kin': nextOfKin?.toJson(),
      'id_information': idInformation?.toJson(),
      'documents': documents.map((d) => d.toJson()).toList(),
      'rejection_reason': rejectionReason,
      'submitted_at': submittedAt?.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  factory KycStatus.notStarted() {
    return KycStatus(
      id: '',
      status: 'not_started',
      lastUpdated: DateTime.now(),
    );
  }
}
