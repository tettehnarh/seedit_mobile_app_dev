import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_theme.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../models/group_models.dart';
import '../providers/groups_provider.dart';

class GroupAdminVotingScreen extends ConsumerStatefulWidget {
  final InvestmentGroup group;

  const GroupAdminVotingScreen({super.key, required this.group});

  @override
  ConsumerState<GroupAdminVotingScreen> createState() =>
      _GroupAdminVotingScreenState();
}

class _GroupAdminVotingScreenState
    extends ConsumerState<GroupAdminVotingScreen> {
  bool _isLoading = false;
  bool _showCreatePoll = false;

  // Poll creation form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedPollType = 'custom';
  User? _selectedTargetUser;
  DateTime? _selectedExpiryDate;

  @override
  void initState() {
    super.initState();
    // Load polls on demand when needed rather than in initState
    // This avoids provider modification during widget lifecycle
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadPolls() async {
    await ref.read(groupsProvider.notifier).loadGroupPolls(widget.group.id);
  }

  Future<void> _voteOnPoll(AdminPoll poll, String vote) async {
    setState(() => _isLoading = true);

    final success = await ref
        .read(groupsProvider.notifier)
        .voteOnPoll(widget.group.id, poll.id, vote);

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Vote cast successfully' : 'Failed to cast vote',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );

      // Refresh polls if vote was successful
      if (success) {
        await ref.read(groupsProvider.notifier).loadGroupPolls(widget.group.id);
      }
    }
  }

  Future<void> _createPoll() async {
    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty ||
        _selectedExpiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final pollData = {
      'poll_type': _selectedPollType,
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'expires_at': _selectedExpiryDate!.toIso8601String(),
      if (_selectedTargetUser != null)
        'target_user_id': _selectedTargetUser!.id,
    };

    final poll = await ref
        .read(groupsProvider.notifier)
        .createPoll(widget.group.id, pollData);

    setState(() => _isLoading = false);

    if (mounted) {
      if (poll != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Poll created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _resetForm();
        setState(() => _showCreatePoll = false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create poll'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    _selectedPollType = 'custom';
    _selectedTargetUser = null;
    _selectedExpiryDate = null;
  }

  @override
  Widget build(BuildContext context) {
    final groupsState = ref.watch(groupsProvider);
    final polls = groupsState.groupPolls[widget.group.id] ?? [];

    // Load polls on first build if not already loaded
    if (polls.isEmpty && !_isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadPolls();
      });
    }

    // Check if current user is an admin using the same logic as navigation
    final isCurrentUserAdmin = widget.group.userMembership?.role == 'admin';

    if (!isCurrentUserAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Admin Voting',
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
                Icon(Icons.how_to_vote, size: 64, color: Colors.grey),
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
                  'Only group admins can access voting',
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
          'Admin Voting',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              setState(() {
                _showCreatePoll = !_showCreatePoll;
              });
            },
          ),
        ],
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadPolls,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Group info
              _buildGroupInfoCard(),
              const SizedBox(height: 20),

              // Create poll section
              if (_showCreatePoll) ...[
                _buildCreatePollSection(),
                const SizedBox(height: 20),
              ],

              // Active polls section
              _buildPollsSection(polls),
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
                  'Admin Voting & Polls',
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

  Widget _buildCreatePollSection() {
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
                Icons.add_circle,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Create New Poll',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                  fontFamily: 'Montserrat',
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () {
                  setState(() {
                    _showCreatePoll = false;
                  });
                },
                iconSize: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Poll Type Selection
          const Text(
            'Poll Type',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedPollType,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'custom', child: Text('Custom Poll')),
              DropdownMenuItem(
                value: 'promote_admin',
                child: Text('Promote Member to Admin'),
              ),
              DropdownMenuItem(
                value: 'demote_admin',
                child: Text('Demote Admin to Member'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedPollType = value!;
                _selectedTargetUser =
                    null; // Reset target user when type changes
              });
            },
          ),
          const SizedBox(height: 16),

          // Title Field
          const Text(
            'Poll Title',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 8),
          CustomTextField(
            controller: _titleController,
            label: 'Poll Title',
            hint: 'Enter poll title',
            maxLines: 1,
          ),
          const SizedBox(height: 16),

          // Description Field
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 8),
          CustomTextField(
            controller: _descriptionController,
            label: 'Description',
            hint: 'Enter poll description',
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          // Target User Selection (for promotion/demotion polls)
          if (_selectedPollType == 'promote_admin' ||
              _selectedPollType == 'demote_admin') ...[
            Text(
              _selectedPollType == 'promote_admin'
                  ? 'Select Member to Promote'
                  : 'Select Admin to Demote',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 8),
            _buildUserSelectionField(),
            const SizedBox(height: 16),
          ],

          // Expiry Date Selection
          const Text(
            'Expiry Date',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 8),
          _buildDateSelectionField(),
          const SizedBox(height: 20),

          // Create Poll Button
          CustomButton(
            text: 'CREATE POLL',
            onPressed: _isLoading ? null : _createPoll,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildPollTile(AdminPoll poll) {
    final isExpired = poll.isExpired;
    final hasVoted = poll.userVote != null;
    final canVote = poll.userCanVote && !_isLoading;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isExpired ? Colors.grey[100] : Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpired ? Colors.grey[300]! : Colors.blue[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poll header
          Row(
            children: [
              Icon(
                _getPollIcon(poll.pollType),
                color: isExpired ? Colors.grey : AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  poll.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isExpired ? Colors.grey : AppTheme.primaryColor,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPollStatusColor(poll),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getPollStatusText(poll),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Poll description
          Text(
            poll.description,
            style: TextStyle(
              fontSize: 14,
              color: isExpired ? Colors.grey : Colors.black87,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 12),

          // Target user (for promotion/demotion polls)
          if (poll.targetUser != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppTheme.primaryColor,
                    child: Text(
                      poll.targetUser!.firstName.isNotEmpty
                          ? poll.targetUser!.firstName.characters.first
                                .toUpperCase()
                          : poll.targetUser!.email.isNotEmpty
                          ? poll.targetUser!.email.characters.first
                                .toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${poll.targetUser!.firstName} ${poll.targetUser!.lastName}'
                              .trim()
                              .isNotEmpty
                          ? '${poll.targetUser!.firstName} ${poll.targetUser!.lastName}'
                                .trim()
                          : poll.targetUser!.email,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Vote counts
          Row(
            children: [
              _buildVoteCount('Yes', poll.yesVotes, Colors.green),
              const SizedBox(width: 16),
              _buildVoteCount('No', poll.noVotes, Colors.red),
              const SizedBox(width: 16),
              Text(
                'Total: ${poll.totalVotes}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Voting buttons or status
          if (hasVoted) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: poll.userVote == 'yes'
                    ? Colors.green[100]
                    : Colors.red[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    poll.userVote == 'yes' ? Icons.thumb_up : Icons.thumb_down,
                    color: poll.userVote == 'yes' ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'You voted: ${poll.userVote?.toUpperCase()}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: poll.userVote == 'yes' ? Colors.green : Colors.red,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
            ),
          ] else if (canVote && !isExpired) ...[
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'YES',
                    onPressed: () => _voteOnPoll(poll, 'yes'),
                    backgroundColor: Colors.green,
                    height: 36,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'NO',
                    onPressed: () => _voteOnPoll(poll, 'no'),
                    backgroundColor: Colors.red,
                    height: 36,
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    isExpired ? Icons.timer_off : Icons.block,
                    color: Colors.grey,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isExpired ? 'Poll expired' : 'Cannot vote',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Expiry info
          const SizedBox(height: 8),
          Text(
            'Expires: ${_formatDateTime(poll.expiresAt)}',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoteCount(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: $count',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
            fontFamily: 'Montserrat',
          ),
        ),
      ],
    );
  }

  IconData _getPollIcon(String pollType) {
    switch (pollType) {
      case 'promote_admin':
        return Icons.arrow_upward;
      case 'demote_admin':
        return Icons.arrow_downward;
      default:
        return Icons.poll;
    }
  }

  Color _getPollStatusColor(AdminPoll poll) {
    if (poll.isExpired) return Colors.grey;
    if (poll.status == 'completed') return Colors.blue;
    return AppTheme.primaryColor;
  }

  String _getPollStatusText(AdminPoll poll) {
    if (poll.isExpired) return 'EXPIRED';
    if (poll.status == 'completed') return 'COMPLETED';
    return 'ACTIVE';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildPollsSection(List<AdminPoll> polls) {
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
                Icons.how_to_vote,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Active Polls (${polls.length})',
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

          if (groupsState.isLoadingPolls) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            ),
          ] else if (polls.isEmpty) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'No active polls',
                  style: TextStyle(
                    color: Colors.grey,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
            ),
          ] else ...[
            ...polls.map((poll) => _buildPollTile(poll)),
          ],
        ],
      ),
    );
  }

  Widget _buildUserSelectionField() {
    final groupMemberships = widget.group.memberships;

    final filteredMemberships = _selectedPollType == 'promote_admin'
        ? groupMemberships
              .where(
                (membership) =>
                    membership.role != 'admin' &&
                    membership.user.firstName.trim().isNotEmpty &&
                    membership.user.lastName.trim().isNotEmpty,
              )
              .toList()
        : groupMemberships
              .where(
                (membership) =>
                    membership.role == 'admin' &&
                    membership.user.firstName.trim().isNotEmpty &&
                    membership.user.lastName.trim().isNotEmpty,
              )
              .toList();

    // If no valid users, return empty container
    if (filteredMemberships.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _selectedPollType == 'promote_admin'
              ? 'No members available for promotion'
              : 'No admins available for demotion',
          style: TextStyle(color: Colors.grey[600], fontFamily: 'Montserrat'),
        ),
      );
    }

    return DropdownButtonFormField<User>(
      value: _selectedTargetUser,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        hintText: _selectedPollType == 'promote_admin'
            ? 'Select member to promote'
            : 'Select admin to demote',
      ),
      items: filteredMemberships.map((membership) {
        final firstName = membership.user.firstName.trim();
        final lastName = membership.user.lastName.trim();
        final displayName = '$firstName $lastName'.trim();

        String initial = '?';
        if (firstName.isNotEmpty) {
          try {
            initial = firstName.characters.first.toUpperCase();
          } catch (e) {
            initial = '?';
          }
        }

        return DropdownMenuItem<User>(
          value: membership.user,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  displayName.isNotEmpty ? displayName : 'Unknown User',
                  style: const TextStyle(fontFamily: 'Montserrat'),
                ),
              ],
            ),
          ),
        );
      }).toList(),
      onChanged: (user) {
        setState(() {
          _selectedTargetUser = user;
        });
      },
    );
  }

  Widget _buildDateSelectionField() {
    return GestureDetector(
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now().add(const Duration(days: 7)),
          firstDate: DateTime.now().add(const Duration(days: 1)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );

        if (selectedDate != null) {
          setState(() {
            _selectedExpiryDate = selectedDate;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              color: AppTheme.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedExpiryDate != null
                    ? '${_selectedExpiryDate!.day}/${_selectedExpiryDate!.month}/${_selectedExpiryDate!.year}'
                    : 'Select expiry date',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: _selectedExpiryDate != null
                      ? Colors.black
                      : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
