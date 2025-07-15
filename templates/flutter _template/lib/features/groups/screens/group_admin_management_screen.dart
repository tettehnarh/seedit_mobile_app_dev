import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_theme.dart';
import '../models/group_models.dart';
import '../providers/groups_provider.dart';
import '../../auth/providers/auth_provider.dart';

class GroupAdminManagementScreen extends ConsumerStatefulWidget {
  final InvestmentGroup group;

  const GroupAdminManagementScreen({super.key, required this.group});

  @override
  ConsumerState<GroupAdminManagementScreen> createState() =>
      _GroupAdminManagementScreenState();
}

class _GroupAdminManagementScreenState
    extends ConsumerState<GroupAdminManagementScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAdmins();
  }

  Future<void> _loadAdmins() async {
    await ref.read(groupsProvider.notifier).loadGroupAdmins(widget.group.id);
  }

  Future<void> _promoteToAdmin(User user) async {
    final confirmed = await _showConfirmationDialog(
      title: 'Promote to Admin',
      message:
          'Are you sure you want to promote ${user.firstName} ${user.lastName} to admin?',
      confirmText: 'Promote',
    );

    if (confirmed) {
      setState(() => _isLoading = true);

      final success = await ref
          .read(groupsProvider.notifier)
          .promoteToAdmin(widget.group.id, user.id);

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'User promoted to admin successfully'
                  : 'Failed to promote user to admin',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _demoteAdmin(User user) async {
    final confirmed = await _showConfirmationDialog(
      title: 'Demote Admin',
      message:
          'Are you sure you want to demote ${user.firstName} ${user.lastName} from admin?',
      confirmText: 'Demote',
      isDestructive: true,
    );

    if (confirmed) {
      setState(() => _isLoading = true);

      final success = await ref
          .read(groupsProvider.notifier)
          .demoteAdmin(widget.group.id, user.id);

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Admin demoted successfully' : 'Failed to demote admin',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _showConfirmationDialog({
    required String title,
    required String message,
    required String confirmText,
    bool isDestructive = false,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              message,
              style: const TextStyle(fontFamily: 'Montserrat'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.grey,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  confirmText,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: isDestructive ? Colors.red : AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final groupsState = ref.watch(groupsProvider);
    final currentUser = ref.watch(authProvider).user;
    final admins = groupsState.groupAdmins[widget.group.id] ?? [];
    final members = widget.group.memberships
        .where((m) => m.role != 'admin')
        .toList();

    // Check if current user is an admin
    final isCurrentUserAdmin =
        currentUser != null &&
        admins.any((admin) => admin.user.id == currentUser.id);

    if (!isCurrentUserAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Admin Management',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppTheme.primaryColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.admin_panel_settings, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Access Denied',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                    fontFamily: 'Montserrat',
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Only group admins can access admin management',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontFamily: 'Montserrat',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Admin Management',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadAdmins,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Group info
              _buildGroupInfoCard(),
              const SizedBox(height: 20),

              // Current admins section
              _buildAdminsSection(admins),
              const SizedBox(height: 20),

              // Regular members section
              _buildMembersSection(members),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(25),
            ),
            child: widget.group.profileImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.network(
                      widget.group.profileImage!,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(Icons.group, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.group.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.group.memberCount} members',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminsSection(List<GroupMembership> admins) {
    final groupsState = ref.watch(groupsProvider);

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.admin_panel_settings,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Current Admins (${admins.length}/3)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (groupsState.isLoadingAdmins) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            ),
          ] else if (admins.isEmpty) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'No admins found',
                  style: TextStyle(
                    color: Colors.grey,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
            ),
          ] else ...[
            ...admins.map((admin) => _buildAdminTile(admin)),
          ],
        ],
      ),
    );
  }

  Widget _buildMembersSection(List<GroupMembership> members) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.people, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Regular Members (${members.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (members.isEmpty) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'No regular members found',
                  style: TextStyle(
                    color: Colors.grey,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
            ),
          ] else ...[
            ...members.map((member) => _buildMemberTile(member)),
          ],
        ],
      ),
    );
  }

  Widget _buildAdminTile(GroupMembership admin) {
    final currentUser = ref.watch(authProvider).user;
    final isCurrentUser =
        currentUser != null && admin.user.id == currentUser.id;
    final groupsState = ref.watch(groupsProvider);
    final admins = groupsState.groupAdmins[widget.group.id] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.green,
            child: Text(
              admin.user.firstName.isNotEmpty
                  ? admin.user.firstName[0].toUpperCase()
                  : admin.user.email[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${admin.user.firstName} ${admin.user.lastName}'
                          .trim()
                          .isNotEmpty
                      ? '${admin.user.firstName} ${admin.user.lastName}'.trim()
                      : admin.user.email,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                  ),
                ),
                Text(
                  admin.user.email,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ),
          if (isCurrentUser) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'You',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ] else if (admins.length > 3) ...[
            IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.red),
              onPressed: _isLoading ? null : () => _demoteAdmin(admin.user),
              iconSize: 20,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMemberTile(GroupMembership member) {
    final groupsState = ref.watch(groupsProvider);
    final admins = groupsState.groupAdmins[widget.group.id] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[400],
            child: Text(
              member.user.firstName.isNotEmpty
                  ? member.user.firstName[0].toUpperCase()
                  : member.user.email[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${member.user.firstName} ${member.user.lastName}'
                          .trim()
                          .isNotEmpty
                      ? '${member.user.firstName} ${member.user.lastName}'
                            .trim()
                      : member.user.email,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                  ),
                ),
                Text(
                  member.user.email,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ),
          if (admins.length < 3) ...[
            IconButton(
              icon: const Icon(Icons.add_circle, color: AppTheme.primaryColor),
              onPressed: _isLoading ? null : () => _promoteToAdmin(member.user),
              iconSize: 20,
            ),
          ],
        ],
      ),
    );
  }
}
