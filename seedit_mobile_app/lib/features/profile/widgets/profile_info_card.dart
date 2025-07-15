import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/models/profile_model.dart';

class ProfileInfoCard extends StatelessWidget {
  final UserProfile? profile;

  const ProfileInfoCard({
    super.key,
    this.profile,
  });

  @override
  Widget build(BuildContext context) {
    if (profile == null) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Personal details
            _buildInfoRow(
              context,
              'Full Name',
              profile!.fullName,
              Icons.person,
            ),
            
            _buildInfoRow(
              context,
              'Email',
              profile!.email,
              Icons.email,
              trailing: profile!.isEmailVerified
                  ? const Icon(Icons.verified, color: Colors.green, size: 16)
                  : const Icon(Icons.warning, color: Colors.orange, size: 16),
            ),
            
            if (profile!.phoneNumber != null)
              _buildInfoRow(
                context,
                'Phone',
                profile!.phoneNumber!,
                Icons.phone,
                trailing: profile!.isPhoneVerified
                    ? const Icon(Icons.verified, color: Colors.green, size: 16)
                    : const Icon(Icons.warning, color: Colors.orange, size: 16),
              ),
            
            if (profile!.dateOfBirth != null)
              _buildInfoRow(
                context,
                'Date of Birth',
                DateFormat('MMM dd, yyyy').format(profile!.dateOfBirth!),
                Icons.cake,
              ),
            
            if (profile!.address != null)
              _buildInfoRow(
                context,
                'Address',
                _formatAddress(),
                Icons.location_on,
              ),
            
            if (profile!.occupation != null)
              _buildInfoRow(
                context,
                'Occupation',
                profile!.occupation!,
                Icons.work,
              ),
            
            if (profile!.employer != null)
              _buildInfoRow(
                context,
                'Employer',
                profile!.employer!,
                Icons.business,
              ),
            
            _buildInfoRow(
              context,
              'Account Type',
              profile!.accountTypeDisplayText,
              Icons.account_balance,
            ),
            
            if (profile!.riskProfile != null)
              _buildInfoRow(
                context,
                'Risk Profile',
                profile!.riskProfileDisplayText!,
                Icons.trending_up,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  String _formatAddress() {
    final parts = <String>[];
    
    if (profile!.address?.isNotEmpty == true) parts.add(profile!.address!);
    if (profile!.city?.isNotEmpty == true) parts.add(profile!.city!);
    if (profile!.state?.isNotEmpty == true) parts.add(profile!.state!);
    if (profile!.country?.isNotEmpty == true) parts.add(profile!.country!);
    
    return parts.join(', ');
  }
}

class ProfileInfoSection extends StatelessWidget {
  final String title;
  final List<ProfileInfoItem> items;
  final VoidCallback? onEdit;

  const ProfileInfoSection({
    super.key,
    required this.title,
    required this.items,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: onEdit,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((item) => _buildInfoItem(context, item)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, ProfileInfoItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              item.label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              item.value ?? 'Not provided',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: item.value != null ? null : Colors.grey[500],
              ),
            ),
          ),
          if (item.trailing != null) item.trailing!,
        ],
      ),
    );
  }
}

class ProfileInfoItem {
  final String label;
  final String? value;
  final Widget? trailing;

  ProfileInfoItem({
    required this.label,
    this.value,
    this.trailing,
  });
}

class ProfileStatsCard extends StatelessWidget {
  final UserProfile profile;

  const ProfileStatsCard({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Overview',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Profile Completion',
                    '${profile.profileCompletionPercentage.toInt()}%',
                    Icons.account_circle,
                    profile.profileCompletionPercentage >= 100
                        ? Colors.green
                        : theme.primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'KYC Status',
                    profile.kycStatusDisplayText,
                    Icons.verified_user,
                    _getKycStatusColor(profile.kycStatus),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Account Type',
                    profile.accountTypeDisplayText,
                    Icons.account_balance,
                    theme.primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Member Since',
                    DateFormat('MMM yyyy').format(profile.createdAt),
                    Icons.calendar_today,
                    theme.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getKycStatusColor(KycStatus status) {
    switch (status) {
      case KycStatus.approved:
        return Colors.green;
      case KycStatus.rejected:
        return Colors.red;
      case KycStatus.underReview:
        return Colors.orange;
      case KycStatus.pending:
        return Colors.grey;
    }
  }
}
