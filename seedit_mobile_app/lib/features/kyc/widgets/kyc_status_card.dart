import 'package:flutter/material.dart';
import '../../../shared/models/kyc_model.dart';

class KycStatusCard extends StatelessWidget {
  final KycStatus status;
  final String? rejectionReason;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;

  const KycStatusCard({
    super.key,
    required this.status,
    this.rejectionReason,
    this.submittedAt,
    this.reviewedAt,
  });

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo(status);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusInfo.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusInfo.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusInfo.iconColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  statusInfo.icon,
                  color: statusInfo.iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusInfo.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: statusInfo.textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusInfo.subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: statusInfo.textColor.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusInfo.iconColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusDisplayText(status),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          if (rejectionReason != null && status == KycStatus.rejected) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.red.shade600,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Rejection Reason: $rejectionReason',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          if (submittedAt != null || reviewedAt != null) ...[
            const SizedBox(height: 16),
            _buildTimestamps(),
          ],
        ],
      ),
    );
  }

  Widget _buildTimestamps() {
    return Column(
      children: [
        if (submittedAt != null)
          _buildTimestamp(
            'Submitted',
            submittedAt!,
            Icons.upload,
          ),
        if (reviewedAt != null) ...[
          const SizedBox(height: 8),
          _buildTimestamp(
            'Reviewed',
            reviewedAt!,
            Icons.check_circle_outline,
          ),
        ],
      ],
    );
  }

  Widget _buildTimestamp(String label, DateTime dateTime, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 6),
        Text(
          '$label: ${_formatDateTime(dateTime)}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getStatusDisplayText(KycStatus status) {
    switch (status) {
      case KycStatus.draft:
        return 'Draft';
      case KycStatus.submitted:
        return 'Submitted';
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

  _StatusInfo _getStatusInfo(KycStatus status) {
    switch (status) {
      case KycStatus.draft:
        return _StatusInfo(
          title: 'Draft Application',
          subtitle: 'Complete your KYC application to submit for review',
          icon: Icons.edit_document,
          iconColor: Colors.blue,
          textColor: Colors.blue.shade800,
          backgroundColor: Colors.blue.shade50,
          borderColor: Colors.blue.shade200,
        );
      case KycStatus.submitted:
        return _StatusInfo(
          title: 'Application Submitted',
          subtitle: 'Your KYC application has been submitted for review',
          icon: Icons.upload_file,
          iconColor: Colors.orange,
          textColor: Colors.orange.shade800,
          backgroundColor: Colors.orange.shade50,
          borderColor: Colors.orange.shade200,
        );
      case KycStatus.underReview:
        return _StatusInfo(
          title: 'Under Review',
          subtitle: 'Our team is reviewing your application',
          icon: Icons.hourglass_empty,
          iconColor: Colors.orange,
          textColor: Colors.orange.shade800,
          backgroundColor: Colors.orange.shade50,
          borderColor: Colors.orange.shade200,
        );
      case KycStatus.approved:
        return _StatusInfo(
          title: 'Verification Complete',
          subtitle: 'Your identity has been successfully verified',
          icon: Icons.check_circle,
          iconColor: Colors.green,
          textColor: Colors.green.shade800,
          backgroundColor: Colors.green.shade50,
          borderColor: Colors.green.shade200,
        );
      case KycStatus.rejected:
        return _StatusInfo(
          title: 'Verification Failed',
          subtitle: 'Your application was rejected. Please review and resubmit',
          icon: Icons.cancel,
          iconColor: Colors.red,
          textColor: Colors.red.shade800,
          backgroundColor: Colors.red.shade50,
          borderColor: Colors.red.shade200,
        );
      case KycStatus.expired:
        return _StatusInfo(
          title: 'Application Expired',
          subtitle: 'Your KYC application has expired. Please start a new one',
          icon: Icons.access_time,
          iconColor: Colors.grey,
          textColor: Colors.grey.shade800,
          backgroundColor: Colors.grey.shade50,
          borderColor: Colors.grey.shade300,
        );
    }
  }
}

class _StatusInfo {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color textColor;
  final Color backgroundColor;
  final Color borderColor;

  _StatusInfo({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.textColor,
    required this.backgroundColor,
    required this.borderColor,
  });
}

class KycStatusBadge extends StatelessWidget {
  final KycStatus status;
  final double? fontSize;

  const KycStatusBadge({
    super.key,
    required this.status,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo(status);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusInfo.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusInfo.icon,
            size: (fontSize ?? 12) + 2,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            statusInfo.text,
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize ?? 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _BadgeInfo _getStatusInfo(KycStatus status) {
    switch (status) {
      case KycStatus.draft:
        return _BadgeInfo(
          text: 'Draft',
          icon: Icons.edit,
          color: Colors.grey,
        );
      case KycStatus.submitted:
        return _BadgeInfo(
          text: 'Submitted',
          icon: Icons.upload,
          color: Colors.blue,
        );
      case KycStatus.underReview:
        return _BadgeInfo(
          text: 'Under Review',
          icon: Icons.hourglass_empty,
          color: Colors.orange,
        );
      case KycStatus.approved:
        return _BadgeInfo(
          text: 'Approved',
          icon: Icons.check_circle,
          color: Colors.green,
        );
      case KycStatus.rejected:
        return _BadgeInfo(
          text: 'Rejected',
          icon: Icons.cancel,
          color: Colors.red,
        );
      case KycStatus.expired:
        return _BadgeInfo(
          text: 'Expired',
          icon: Icons.access_time,
          color: Colors.grey,
        );
    }
  }
}

class _BadgeInfo {
  final String text;
  final IconData icon;
  final Color color;

  _BadgeInfo({
    required this.text,
    required this.icon,
    required this.color,
  });
}

class KycLevelBadge extends StatelessWidget {
  final KycLevel level;

  const KycLevelBadge({
    super.key,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    final levelInfo = _getLevelInfo(level);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: levelInfo.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            levelInfo.icon,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            levelInfo.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  _LevelInfo _getLevelInfo(KycLevel level) {
    switch (level) {
      case KycLevel.tier1:
        return _LevelInfo(
          text: 'Tier 1',
          icon: Icons.star,
          colors: [Colors.blue, Colors.blue.shade700],
        );
      case KycLevel.tier2:
        return _LevelInfo(
          text: 'Tier 2',
          icon: Icons.star,
          colors: [Colors.purple, Colors.purple.shade700],
        );
      case KycLevel.tier3:
        return _LevelInfo(
          text: 'Tier 3',
          icon: Icons.star,
          colors: [Colors.amber, Colors.amber.shade700],
        );
    }
  }
}

class _LevelInfo {
  final String text;
  final IconData icon;
  final List<Color> colors;

  _LevelInfo({
    required this.text,
    required this.icon,
    required this.colors,
  });
}
