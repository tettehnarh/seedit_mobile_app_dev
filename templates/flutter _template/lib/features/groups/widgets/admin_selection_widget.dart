import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import '../../../core/utils/app_theme.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../models/group_models.dart';
import '../providers/groups_provider.dart';
import '../../auth/providers/auth_provider.dart';

class AdminSelectionWidget extends ConsumerStatefulWidget {
  final List<String> selectedAdminIds;
  final Function(List<String>) onAdminsChanged;
  final bool isRequired;

  const AdminSelectionWidget({
    super.key,
    required this.selectedAdminIds,
    required this.onAdminsChanged,
    this.isRequired = true,
  });

  @override
  ConsumerState<AdminSelectionWidget> createState() =>
      _AdminSelectionWidgetState();
}

class _AdminSelectionWidgetState extends ConsumerState<AdminSelectionWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _searchResults = [];
  List<User> _selectedAdmins = [];
  bool _isSearching = false;
  String? _searchError;

  @override
  void initState() {
    super.initState();
    _initializeSelectedAdmins();
  }

  void _initializeSelectedAdmins() {
    // Add current user as first admin if creating new group
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUserModel = ref.read(authProvider).user;
      if (currentUserModel != null &&
          widget.selectedAdminIds.isEmpty &&
          _selectedAdmins.isEmpty) {
        // Convert UserModel to User
        final currentUser = User(
          id: currentUserModel.id,
          email: currentUserModel.email,
          firstName: currentUserModel.firstName,
          lastName: currentUserModel.lastName,
        );
        setState(() {
          _selectedAdmins = [currentUser];
        });
        widget.onAdminsChanged([currentUser.id]);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _searchError = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    try {
      developer.log('🔍 [ADMIN_SELECTION] Searching users: $query');
      final users = await ref.read(groupsProvider.notifier).searchUsers(query);

      // Filter out already selected admins
      final filteredUsers = users.where((user) {
        return !_selectedAdmins.any((admin) => admin.id == user.id);
      }).toList();

      setState(() {
        _searchResults = filteredUsers;
        _isSearching = false;
      });

      developer.log('✅ [ADMIN_SELECTION] Found ${filteredUsers.length} users');
    } catch (e) {
      developer.log('❌ [ADMIN_SELECTION] Search error: $e', error: e);
      setState(() {
        _searchError = 'Failed to search users';
        _isSearching = false;
        _searchResults = [];
      });
    }
  }

  void _addAdmin(User user) {
    if (_selectedAdmins.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 3 admins allowed'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _selectedAdmins.add(user);
      _searchResults.remove(user);
      _searchController.clear();
    });

    widget.onAdminsChanged(_selectedAdmins.map((admin) => admin.id).toList());

    developer.log('✅ [ADMIN_SELECTION] Added admin: ${user.email}');
  }

  void _removeAdmin(User user) {
    // Don't allow removing the current user (group creator)
    final currentUserModel = ref.read(authProvider).user;
    if (currentUserModel != null && user.id == currentUserModel.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Group creator must be an admin'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _selectedAdmins.remove(user);
    });

    widget.onAdminsChanged(_selectedAdmins.map((admin) => admin.id).toList());

    developer.log('✅ [ADMIN_SELECTION] Removed admin: ${user.email}');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            const Text(
              'Group Admins',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
                fontFamily: 'Montserrat',
              ),
            ),
            if (widget.isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Requirement text
        Text(
          'Select exactly 3 admins (including yourself)',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 12),

        // Selected admins
        if (_selectedAdmins.isNotEmpty) ...[
          _buildSelectedAdmins(),
          const SizedBox(height: 16),
        ],

        // Add admin section (only show if less than 3 admins)
        if (_selectedAdmins.length < 3) ...[_buildAddAdminSection()],

        // Validation message
        if (widget.isRequired && _selectedAdmins.length != 3) ...[
          const SizedBox(height: 8),
          Text(
            _selectedAdmins.length < 3
                ? 'Please select ${3 - _selectedAdmins.length} more admin(s)'
                : 'Too many admins selected',
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSelectedAdmins() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected Admins (${_selectedAdmins.length}/3)',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 8),
          ...(_selectedAdmins.map((admin) => _buildAdminTile(admin, true))),
        ],
      ),
    );
  }

  Widget _buildAddAdminSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Search Users',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 8),

        // Search field
        CustomTextField(
          controller: _searchController,
          label: 'Search Users',
          hint: 'Search by email or name...',
          prefixIcon: const Icon(Icons.search),
          onChanged: (value) {
            _searchUsers(value);
          },
        ),

        const SizedBox(height: 12),

        // Search results
        if (_isSearching) ...[
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          ),
        ] else if (_searchError != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _searchError!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else if (_searchResults.isNotEmpty) ...[
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                return _buildAdminTile(_searchResults[index], false);
              },
            ),
          ),
        ] else if (_searchController.text.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            child: Text(
              'No users found',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAdminTile(User user, bool isSelected) {
    final currentUserModel = ref.read(authProvider).user;
    final isCurrentUser =
        currentUserModel != null && user.id == currentUserModel.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: AppTheme.primaryColor,
          child: Text(
            user.firstName.isNotEmpty
                ? user.firstName[0].toUpperCase()
                : user.email[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          '${user.firstName} ${user.lastName}'.trim().isNotEmpty
              ? '${user.firstName} ${user.lastName}'.trim()
              : user.email,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Montserrat',
          ),
        ),
        subtitle: Text(
          user.email,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontFamily: 'Montserrat',
          ),
        ),
        trailing: isSelected
            ? (isCurrentUser
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Creator',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => _removeAdmin(user),
                      iconSize: 20,
                    ))
            : IconButton(
                icon: const Icon(
                  Icons.add_circle,
                  color: AppTheme.primaryColor,
                ),
                onPressed: () => _addAdmin(user),
                iconSize: 20,
              ),
        onTap: isSelected ? null : () => _addAdmin(user),
      ),
    );
  }
}
