class SupportTicket {
  final String id;
  final String subject;
  final String description;
  final String issueType;
  final String status;
  final String priority;
  final String? transactionId;
  final String? fundId;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;
  final String? assignedTo;
  final String? resolution;

  const SupportTicket({
    required this.id,
    required this.subject,
    required this.description,
    required this.issueType,
    required this.status,
    required this.priority,
    this.transactionId,
    this.fundId,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
    this.assignedTo,
    this.resolution,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id']?.toString() ?? '',
      subject: json['subject'] ?? '',
      description: json['description'] ?? '',
      issueType: json['issue_type'] ?? '',
      status: json['status'] ?? 'open',
      priority: json['priority'] ?? 'medium',
      transactionId: json['transaction_id']?.toString(),
      fundId: json['fund_id']?.toString(),
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      resolvedAt: json['resolved_at'] != null 
          ? DateTime.tryParse(json['resolved_at']) 
          : null,
      assignedTo: json['assigned_to'],
      resolution: json['resolution'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'description': description,
      'issue_type': issueType,
      'status': status,
      'priority': priority,
      'transaction_id': transactionId,
      'fund_id': fundId,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
      'assigned_to': assignedTo,
      'resolution': resolution,
    };
  }

  // Helper getters for UI display
  String get displayStatus {
    switch (status.toLowerCase()) {
      case 'open':
        return 'Open';
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      case 'closed':
        return 'Closed';
      default:
        return status.toUpperCase();
    }
  }

  String get displayPriority {
    switch (priority.toLowerCase()) {
      case 'low':
        return 'Low';
      case 'medium':
        return 'Medium';
      case 'high':
        return 'High';
      case 'urgent':
        return 'Urgent';
      default:
        return priority.toUpperCase();
    }
  }

  String get displayIssueType {
    switch (issueType.toLowerCase()) {
      case 'incorrect_amount':
        return 'Incorrect Amount';
      case 'unauthorized_transaction':
        return 'Unauthorized Transaction';
      case 'duplicate_transaction':
        return 'Duplicate Transaction';
      case 'failed_transaction':
        return 'Failed Transaction';
      case 'wrong_fund':
        return 'Wrong Fund';
      case 'processing_delay':
        return 'Processing Delay';
      case 'missing_units':
        return 'Missing Units';
      case 'other':
        return 'Other Issue';
      default:
        return issueType.replaceAll('_', ' ').toUpperCase();
    }
  }

  bool get isOpen => status.toLowerCase() == 'open';
  bool get isInProgress => status.toLowerCase() == 'in_progress';
  bool get isResolved => status.toLowerCase() == 'resolved';
  bool get isClosed => status.toLowerCase() == 'closed';

  bool get isHighPriority => priority.toLowerCase() == 'high' || priority.toLowerCase() == 'urgent';
}

class SupportMessage {
  final String id;
  final String ticketId;
  final String message;
  final String senderType; // 'user' or 'admin'
  final String? senderName;
  final DateTime createdAt;
  final bool isRead;

  const SupportMessage({
    required this.id,
    required this.ticketId,
    required this.message,
    required this.senderType,
    this.senderName,
    required this.createdAt,
    required this.isRead,
  });

  factory SupportMessage.fromJson(Map<String, dynamic> json) {
    return SupportMessage(
      id: json['id']?.toString() ?? '',
      ticketId: json['ticket_id']?.toString() ?? '',
      message: json['message'] ?? '',
      senderType: json['sender_type'] ?? 'user',
      senderName: json['sender_name'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      isRead: json['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_id': ticketId,
      'message': message,
      'sender_type': senderType,
      'sender_name': senderName,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
    };
  }

  bool get isFromUser => senderType.toLowerCase() == 'user';
  bool get isFromAdmin => senderType.toLowerCase() == 'admin';

  String get displaySenderName {
    if (senderName != null && senderName!.isNotEmpty) {
      return senderName!;
    }
    return isFromUser ? 'You' : 'Support Team';
  }
}

class SupportTicketFilter {
  final String? status;
  final String? issueType;
  final String? priority;
  final DateTime? startDate;
  final DateTime? endDate;

  const SupportTicketFilter({
    this.status,
    this.issueType,
    this.priority,
    this.startDate,
    this.endDate,
  });

  Map<String, String> toQueryParams() {
    final params = <String, String>{};
    
    if (status != null && status!.isNotEmpty) {
      params['status'] = status!;
    }
    
    if (issueType != null && issueType!.isNotEmpty) {
      params['issue_type'] = issueType!;
    }
    
    if (priority != null && priority!.isNotEmpty) {
      params['priority'] = priority!;
    }
    
    if (startDate != null) {
      params['start_date'] = startDate!.toIso8601String().split('T')[0];
    }
    
    if (endDate != null) {
      params['end_date'] = endDate!.toIso8601String().split('T')[0];
    }
    
    return params;
  }

  bool get hasActiveFilters {
    return status != null ||
           issueType != null ||
           priority != null ||
           startDate != null ||
           endDate != null;
  }
}

class CreateTicketRequest {
  final String subject;
  final String description;
  final String issueType;
  final String? transactionId;
  final String? fundId;
  final Map<String, dynamic>? metadata;

  const CreateTicketRequest({
    required this.subject,
    required this.description,
    required this.issueType,
    this.transactionId,
    this.fundId,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'description': description,
      'issue_type': issueType,
      'status': 'open',
      if (transactionId != null) 'transaction_id': transactionId,
      if (fundId != null) 'fund_id': fundId,
      if (metadata != null) 'metadata': metadata,
    };
  }
}
