enum NotificationCategory {
  important,
  news;

  String get displayName {
    switch (this) {
      case NotificationCategory.important:
        return 'Important';
      case NotificationCategory.news:
        return 'News';
    }
  }

  static NotificationCategory fromString(String? value) {
    if (value == null) return NotificationCategory.important;

    switch (value.toLowerCase()) {
      case 'important':
        return NotificationCategory.important;
      case 'news':
        return NotificationCategory.news;
      default:
        return NotificationCategory.important; // Default fallback
    }
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final NotificationCategory category;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.category,
    this.isRead = false,
    required this.createdAt,
    this.data,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    NotificationCategory? category,
    bool? isRead,
    DateTime? createdAt,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      category: category ?? this.category,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'category': category.name,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'data': data,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Determine category based on type if category is not provided (backward compatibility)
    String? categoryValue = json['category'];
    if (categoryValue == null) {
      // Map existing notification types to categories for backward compatibility
      final type = json['type'] ?? 'system';
      switch (type.toLowerCase()) {
        case 'news':
        case 'market_update':
        case 'education':
          categoryValue = 'news';
          break;
        default:
          categoryValue = 'important';
      }
    }

    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'system',
      category: NotificationCategory.fromString(categoryValue),
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      data: json['data'],
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, type: $type, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel &&
        other.id == id &&
        other.title == title &&
        other.message == message &&
        other.type == type &&
        other.isRead == isRead;
  }

  @override
  int get hashCode {
    return Object.hash(id, title, message, type, isRead);
  }

  // Helper methods for specific notification types
  bool get isKycApproved => type.toLowerCase() == 'kyc_approved';
  bool get isKycRejected => type.toLowerCase() == 'kyc_rejected';
  bool get isInvestmentRelated => type.toLowerCase() == 'investment';
  bool get isPaymentRelated => type.toLowerCase() == 'payment';
  bool get isSystemNotification => type.toLowerCase() == 'system';

  // Factory methods for creating specific notification types
  factory NotificationModel.kycApproved({
    required String id,
    required DateTime createdAt,
  }) {
    return NotificationModel(
      id: id,
      title: 'KYC Verification Approved! 🎉',
      message:
          'Congratulations! Your KYC verification has been approved. You now have full access to all investment features.',
      type: 'kyc_approved',
      category: NotificationCategory.important,
      createdAt: createdAt,
      data: {'action': 'kyc_approved'},
    );
  }

  factory NotificationModel.kycRejected({
    required String id,
    required DateTime createdAt,
    String? reason,
  }) {
    return NotificationModel(
      id: id,
      title: 'KYC Verification Requires Attention',
      message:
          reason ??
          'Your KYC verification needs to be updated. Please review and resubmit your documents.',
      type: 'kyc_rejected',
      category: NotificationCategory.important,
      createdAt: createdAt,
      data: {'action': 'kyc_rejected', 'reason': reason},
    );
  }

  factory NotificationModel.investmentUpdate({
    required String id,
    required String title,
    required String message,
    required DateTime createdAt,
    Map<String, dynamic>? additionalData,
  }) {
    return NotificationModel(
      id: id,
      title: title,
      message: message,
      type: 'investment',
      category: NotificationCategory.important,
      createdAt: createdAt,
      data: additionalData,
    );
  }

  factory NotificationModel.paymentUpdate({
    required String id,
    required String title,
    required String message,
    required DateTime createdAt,
    Map<String, dynamic>? additionalData,
  }) {
    return NotificationModel(
      id: id,
      title: title,
      message: message,
      type: 'payment',
      category: NotificationCategory.important,
      createdAt: createdAt,
      data: additionalData,
    );
  }

  factory NotificationModel.systemNotification({
    required String id,
    required String title,
    required String message,
    required DateTime createdAt,
    Map<String, dynamic>? additionalData,
  }) {
    return NotificationModel(
      id: id,
      title: title,
      message: message,
      type: 'system',
      category: NotificationCategory.important,
      createdAt: createdAt,
      data: additionalData,
    );
  }

  // Factory method for news notifications
  factory NotificationModel.newsNotification({
    required String id,
    required String title,
    required String message,
    required DateTime createdAt,
    Map<String, dynamic>? additionalData,
  }) {
    return NotificationModel(
      id: id,
      title: title,
      message: message,
      type: 'news',
      category: NotificationCategory.news,
      createdAt: createdAt,
      data: additionalData,
    );
  }
}
