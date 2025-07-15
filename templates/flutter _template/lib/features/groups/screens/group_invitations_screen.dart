import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import '../../../core/utils/app_theme.dart';
import '../../../shared/widgets/custom_button.dart';
import '../models/group_models.dart';
import '../providers/groups_provider.dart';

class GroupInvitationsScreen extends ConsumerStatefulWidget {
  const GroupInvitationsScreen({super.key});

  @override
  ConsumerState<GroupInvitationsScreen> createState() =>
      _GroupInvitationsScreenState();
}

class _GroupInvitationsScreenState extends ConsumerState<GroupInvitationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Real data from API
  List<GroupInvitation> _pendingInvitations = [];
  List<Map<String, dynamic>> _sentInvitations = [];
  bool _isLoading = false;

  // Loading states for individual invitations
  final Set<String> _resendingInvitations = {};
  final Set<String> _cancelingInvitations = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInvitations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInvitations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      developer.log('🔄 Loading all group invitations...');

      final groupsService = ref.read(groupsServiceProvider);

      // Load both received and sent invitations concurrently
      final results = await Future.wait([
        groupsService.getPendingInvitations(),
        groupsService.getAllSentInvitations(),
      ]);

      final receivedInvitations = results[0];
      final sentInvitations = results[1];

      setState(() {
        _pendingInvitations = receivedInvitations;
        // Convert GroupInvitation objects to Map for consistency with the UI
        _sentInvitations = sentInvitations
            .map(
              (invitation) => {
                'id': invitation.id,
                'group_id': invitation.groupId,
                'invitee_email': invitation.inviteeEmail,
                'invitee_name':
                    invitation.invitee?.fullName ??
                    '', // Use invitee name if available
                'status': invitation.status,
                'type': 'invitation', // All from this API are email invitations
                'invited_at': invitation.createdAt.toIso8601String(),
                'expires_at': invitation.expiresAt.toIso8601String(),
                'can_resend':
                    invitation.status == 'pending' && !invitation.isExpired,
                'can_cancel': invitation.status == 'pending',
                'group_name': invitation.groupName,
              },
            )
            .toList();
        _isLoading = false;
      });

      developer.log(
        '✅ Loaded ${_pendingInvitations.length} received and ${_sentInvitations.length} sent invitations',
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      developer.log('❌ Error loading invitations: $e', error: e);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load invitations: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Group Invitations',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Tab bar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: AppTheme.companyInfoColor,
              labelStyle: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  width: 3.0,
                  color: AppTheme.primaryColor,
                ),
                insets: EdgeInsets.symmetric(
                  horizontal: 40.0, // This controls the width of the indicator
                ),
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 4),
                      Text('Received (${_pendingInvitations.length})'),
                    ],
                  ),
                ),
                Tab(text: 'Sent (${_sentInvitations.length})'),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildReceivedInvitationsTab(),
                      _buildSentInvitationsTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceivedInvitationsTab() {
    if (_pendingInvitations.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.mail_outline,
                size: 64,
                color: AppTheme.companyInfoColor,
              ),
              SizedBox(height: 16),
              Text(
                'No pending invitations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                  fontFamily: 'Montserrat',
                ),
              ),
              SizedBox(height: 8),
              Text(
                'You\'ll see group invitations here when you receive them.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.companyInfoColor,
                  fontFamily: 'Montserrat',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInvitations,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pendingInvitations.length,
        itemBuilder: (context, index) {
          return _buildInvitationCard(_pendingInvitations[index], true);
        },
      ),
    );
  }

  Widget _buildSentInvitationsTab() {
    if (_sentInvitations.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.send_outlined,
                size: 64,
                color: AppTheme.companyInfoColor,
              ),
              SizedBox(height: 16),
              Text(
                'No sent invitations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                  fontFamily: 'Montserrat',
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Invitations you send to others will appear here.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.companyInfoColor,
                  fontFamily: 'Montserrat',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInvitations,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _sentInvitations.length,
        itemBuilder: (context, index) {
          return _buildSentInvitationItem(_sentInvitations[index]);
        },
      ),
    );
  }

  Widget _buildInvitationCard(GroupInvitation invitation, bool isReceived) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.group,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invitation.groupName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isReceived
                            ? 'Invited by ${invitation.inviter?.fullName ?? 'Unknown'}'
                            : 'Invited: ${invitation.inviteeEmail}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.companyInfoColor,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatDate(invitation.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.companyInfoColor,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invitation.groupDescription,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.companyInfoColor,
                    fontFamily: 'Montserrat',
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                if (isReceived && invitation.status == 'pending') ...[
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'DECLINE',
                          onPressed: () => _handleInvitation(invitation, false),
                          isOutlined: true,
                          height: 40,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          text: 'ACCEPT',
                          onPressed: () => _handleInvitation(invitation, true),
                          backgroundColor: AppTheme.primaryColor,
                          height: 40,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        invitation.status,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      invitation.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(invitation.status),
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'declined':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return AppTheme.companyInfoColor;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _handleInvitation(
    GroupInvitation invitation,
    bool accept,
  ) async {
    try {
      developer.log(
        '🔄 ${accept ? 'Accepting' : 'Declining'} invitation: ${invitation.id}',
      );

      // Handle invitation via API
      final success = await ref
          .read(groupsProvider.notifier)
          .respondToInvitation(invitation.id, accept);

      if (!success) {
        throw Exception(
          'Failed to ${accept ? 'accept' : 'decline'} invitation',
        );
      }

      // Note: The invitation status is updated on the backend
      // The UI will refresh to reflect the new status

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              accept
                  ? 'Invitation accepted! Welcome to ${invitation.groupName}'
                  : 'Invitation declined',
            ),
            backgroundColor: accept ? Colors.green : Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      developer.log('❌ Error handling invitation: $e', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to process invitation'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildSentInvitationItem(Map<String, dynamic> invitation) {
    final String email = invitation['invitee_email'] ?? '';
    final String name = invitation['invitee_name'] ?? '';
    final String groupName = invitation['group_name'] ?? '';
    final String status = invitation['status'] ?? 'pending';
    final String type = invitation['type'] ?? 'membership';
    final String invitedAt = invitation['invited_at'] ?? '';
    final String? expiresAt = invitation['expires_at'];
    final bool canResend = invitation['can_resend'] ?? false;
    final bool canCancel = invitation['can_cancel'] ?? false;

    // Parse dates for display
    DateTime? invitedDate;
    DateTime? expiryDate;
    try {
      if (invitedAt.isNotEmpty) {
        invitedDate = DateTime.parse(invitedAt);
      }
      if (expiresAt != null && expiresAt.isNotEmpty) {
        expiryDate = DateTime.parse(expiresAt);
      }
    } catch (e) {
      developer.log('Error parsing dates: $e');
    }

    // Determine status color and icon
    Color statusColor;
    IconData statusIcon;
    switch (status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
      case 'active':
      case 'accepted':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'declined':
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'expired':
        statusColor = Colors.grey;
        statusIcon = Icons.access_time;
        break;
      case 'invited':
        statusColor = Colors.blue;
        statusIcon = Icons.email;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with email and status
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    if (name.isNotEmpty)
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    if (groupName.isNotEmpty)
                      Text(
                        'Group: $groupName',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                          fontFamily: 'Montserrat',
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Details row
          Row(
            children: [
              Icon(
                type == 'invitation' ? Icons.email : Icons.person_add,
                size: 14,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                type == 'invitation' ? 'Email Invitation' : 'Direct Invitation',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                invitedDate != null ? _formatDate(invitedDate) : 'Unknown',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),

          // Expiry info for email invitations
          if (expiryDate != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.event, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Expires: ${_formatDate(expiryDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ],

          // Action buttons
          if (canResend || canCancel) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (canResend)
                  Expanded(
                    child: CustomButton(
                      text: _resendingInvitations.contains(invitation['id'])
                          ? 'RESENDING...'
                          : 'RESEND',
                      onPressed:
                          _resendingInvitations.contains(invitation['id'])
                          ? null
                          : () => _resendInvitation(invitation),
                      isOutlined: true,
                      height: 36,
                    ),
                  ),
                if (canResend && canCancel) const SizedBox(width: 12),
                if (canCancel)
                  Expanded(
                    child: CustomButton(
                      text: _cancelingInvitations.contains(invitation['id'])
                          ? 'CANCELING...'
                          : 'CANCEL',
                      onPressed:
                          _cancelingInvitations.contains(invitation['id'])
                          ? null
                          : () => _cancelInvitation(invitation),
                      backgroundColor: Colors.red,
                      height: 36,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _resendInvitation(Map<String, dynamic> invitation) async {
    final String invitationId = invitation['id'] ?? '';
    final String email = invitation['invitee_email'] ?? '';
    final String groupId = invitation['group_id'] ?? '';

    if (invitationId.isEmpty || email.isEmpty || groupId.isEmpty) {
      _showErrorSnackBar('Invalid invitation data');
      return;
    }

    setState(() {
      _resendingInvitations.add(invitationId);
    });

    try {
      developer.log('🔄 Resending invitation: $invitationId to $email');

      final groupsService = ref.read(groupsServiceProvider);

      // First, cancel the existing invitation
      await groupsService.cancelInvitation(invitationId);

      // Then send a new invitation to the same email
      await groupsService.resendInvitation(groupId, email);

      setState(() {
        _resendingInvitations.remove(invitationId);
      });

      // Refresh the invitations list to show updated data
      await _loadInvitations();

      _showSuccessSnackBar('Invitation resent to $email');

      developer.log('✅ Successfully resent invitation to $email');
    } catch (e) {
      setState(() {
        _resendingInvitations.remove(invitationId);
      });

      String errorMessage = 'Failed to resend invitation. Please try again.';
      if (e.toString().contains('403') || e.toString().contains('forbidden')) {
        errorMessage = 'Only group admins can resend invitations.';
      } else if (e.toString().contains('404') ||
          e.toString().contains('not found')) {
        errorMessage = 'Invitation not found or already processed.';
      } else if (e.toString().contains('already a member')) {
        errorMessage = 'User is already a member of this group.';
      } else if (e.toString().contains('already invited')) {
        errorMessage = 'User has already been invited to this group.';
      }

      _showErrorSnackBar(errorMessage);
      developer.log('❌ Error resending invitation: $e', error: e);
    }
  }

  Future<void> _cancelInvitation(Map<String, dynamic> invitation) async {
    final String invitationId = invitation['id'] ?? '';
    final String email = invitation['invitee_email'] ?? '';

    if (invitationId.isEmpty || email.isEmpty) {
      _showErrorSnackBar('Invalid invitation data');
      return;
    }

    // Show confirmation dialog
    final bool? shouldCancel = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Cancel Invitation',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          content: Text(
            'Are you sure you want to cancel the invitation sent to $email?',
            style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'No',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: AppTheme.companyInfoColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Yes, Cancel',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldCancel != true) return;

    setState(() {
      _cancelingInvitations.add(invitationId);
    });

    try {
      developer.log('🔄 Canceling invitation: $invitationId to $email');

      final groupsService = ref.read(groupsServiceProvider);
      await groupsService.cancelInvitation(invitationId);

      setState(() {
        _cancelingInvitations.remove(invitationId);
      });

      // Refresh the invitations list to show updated data
      await _loadInvitations();

      _showSuccessSnackBar('Invitation to $email has been canceled');

      developer.log('✅ Successfully canceled invitation to $email');
    } catch (e) {
      setState(() {
        _cancelingInvitations.remove(invitationId);
      });

      String errorMessage = 'Failed to cancel invitation. Please try again.';
      if (e.toString().contains('403') || e.toString().contains('forbidden')) {
        errorMessage = 'Only group admins can cancel invitations.';
      } else if (e.toString().contains('404') ||
          e.toString().contains('not found')) {
        errorMessage = 'Invitation not found or already processed.';
      }

      _showErrorSnackBar(errorMessage);
      developer.log('❌ Error canceling invitation: $e', error: e);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
