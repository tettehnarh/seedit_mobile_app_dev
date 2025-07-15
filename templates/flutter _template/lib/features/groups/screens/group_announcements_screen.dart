import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import '../../../core/utils/app_theme.dart';
import '../../../shared/widgets/custom_button.dart';
import '../models/group_models.dart';
import '../providers/groups_provider.dart';

class GroupAnnouncementsScreen extends ConsumerStatefulWidget {
  final InvestmentGroup group;

  const GroupAnnouncementsScreen({super.key, required this.group});

  @override
  ConsumerState<GroupAnnouncementsScreen> createState() =>
      _GroupAnnouncementsScreenState();
}

class _GroupAnnouncementsScreenState
    extends ConsumerState<GroupAnnouncementsScreen> {
  final List<GroupAnnouncement> _announcements = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    setState(() {
      _isLoading = true;
    });

    try {
      developer.log('🔄 Loading announcements for group: ${widget.group.id}');

      final announcements = await ref
          .read(groupsProvider.notifier)
          .loadGroupAnnouncements(widget.group.id);

      setState(() {
        _announcements.clear();
        _announcements.addAll(announcements);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      developer.log('❌ Error loading announcements: $e', error: e);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load announcements: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.group.userMembership?.role == 'admin';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Announcements',
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
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.add, color: AppTheme.primaryColor),
              onPressed: _createAnnouncement,
            ),
        ],
      ),
      body: Column(
        children: [
          // Group info header
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
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
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.campaign,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.group.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_announcements.length} announcements',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.companyInfoColor,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Announcements list
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                  )
                : _announcements.isEmpty
                ? _buildEmptyState(isAdmin)
                : RefreshIndicator(
                    onRefresh: _loadAnnouncements,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _announcements.length,
                      itemBuilder: (context, index) {
                        return _buildAnnouncementCard(_announcements[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              heroTag: "group_announcements_create",
              onPressed: _createAnnouncement,
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildEmptyState(bool isAdmin) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.campaign_outlined,
              size: 64,
              color: AppTheme.companyInfoColor,
            ),
            const SizedBox(height: 16),
            const Text(
              'No announcements yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isAdmin
                  ? 'Create the first announcement to keep your group informed!'
                  : 'Check back later for updates from group admins.',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.companyInfoColor,
                fontFamily: 'Montserrat',
              ),
              textAlign: TextAlign.center,
            ),
            if (isAdmin) ...[
              const SizedBox(height: 24),
              CustomButton(
                text: 'CREATE ANNOUNCEMENT',
                onPressed: _createAnnouncement,
                backgroundColor: AppTheme.primaryColor,
                width: 200,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementCard(GroupAnnouncement announcement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: announcement.isImportant
            ? Border.all(color: Colors.orange, width: 2)
            : null,
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
              color: announcement.isImportant
                  ? Colors.orange.withValues(alpha: 0.1)
                  : AppTheme.primaryColor.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                if (announcement.isImportant) ...[
                  const Icon(
                    Icons.priority_high,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    announcement.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: announcement.isImportant
                          ? Colors.orange
                          : AppTheme.primaryColor,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
                Text(
                  _formatDate(announcement.createdAt),
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
                  announcement.content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.companyInfoColor,
                    fontFamily: 'Montserrat',
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.person,
                      size: 16,
                      color: AppTheme.companyInfoColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'By ${announcement.author.firstName} ${announcement.author.lastName}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.companyInfoColor,
                        fontFamily: 'Montserrat',
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

  void _createAnnouncement() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CreateAnnouncementSheet(
        groupId: widget.group.id,
        onAnnouncementCreated: (announcement) {
          setState(() {
            _announcements.insert(0, announcement);
          });
        },
      ),
    );
  }
}

// Create announcement bottom sheet
class CreateAnnouncementSheet extends ConsumerStatefulWidget {
  final String groupId;
  final Function(GroupAnnouncement) onAnnouncementCreated;

  const CreateAnnouncementSheet({
    super.key,
    required this.groupId,
    required this.onAnnouncementCreated,
  });

  @override
  ConsumerState<CreateAnnouncementSheet> createState() =>
      _CreateAnnouncementSheetState();
}

class _CreateAnnouncementSheetState
    extends ConsumerState<CreateAnnouncementSheet> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isImportant = false;
  bool _isCreating = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Create Announcement',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: AppTheme.companyInfoColor,
                ),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Content',
                labelStyle: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: AppTheme.companyInfoColor,
                ),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _isImportant,
                  onChanged: (value) {
                    setState(() {
                      _isImportant = value ?? false;
                    });
                  },
                  activeColor: Colors.orange,
                ),
                const Text(
                  'Mark as important',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.companyInfoColor,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'CANCEL',
                    onPressed: () => Navigator.pop(context),
                    isOutlined: true,
                    height: 48,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: _isCreating ? 'CREATING...' : 'CREATE',
                    onPressed: _isCreating ? null : _createAnnouncement,
                    backgroundColor: AppTheme.primaryColor,
                    height: 48,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createAnnouncement() async {
    developer.log(
      '🔄 [ANNOUNCEMENTS_SCREEN] === CREATE ANNOUNCEMENT DEBUG START ===',
    );
    developer.log('🔍 [ANNOUNCEMENTS_SCREEN] Group ID: ${widget.groupId}');
    developer.log(
      '🔍 [ANNOUNCEMENTS_SCREEN] Title input: "${_titleController.text}"',
    );
    developer.log(
      '🔍 [ANNOUNCEMENTS_SCREEN] Content input: "${_contentController.text}"',
    );
    developer.log('🔍 [ANNOUNCEMENTS_SCREEN] Is important: $_isImportant');

    // Validate form inputs
    final titleTrimmed = _titleController.text.trim();
    final contentTrimmed = _contentController.text.trim();

    developer.log('🔍 [ANNOUNCEMENTS_SCREEN] Title trimmed: "$titleTrimmed"');
    developer.log(
      '🔍 [ANNOUNCEMENTS_SCREEN] Content trimmed: "$contentTrimmed"',
    );
    developer.log(
      '🔍 [ANNOUNCEMENTS_SCREEN] Title empty: ${titleTrimmed.isEmpty}',
    );
    developer.log(
      '🔍 [ANNOUNCEMENTS_SCREEN] Content empty: ${contentTrimmed.isEmpty}',
    );

    if (titleTrimmed.isEmpty || contentTrimmed.isEmpty) {
      developer.log(
        '❌ [ANNOUNCEMENTS_SCREEN] Validation failed - empty fields',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    developer.log(
      '✅ [ANNOUNCEMENTS_SCREEN] Validation passed, setting loading state',
    );
    setState(() {
      _isCreating = true;
    });

    try {
      final announcementData = {
        'title': titleTrimmed,
        'content': contentTrimmed,
        'is_important': _isImportant,
      };

      developer.log(
        '📋 [ANNOUNCEMENTS_SCREEN] Prepared announcement data: $announcementData',
      );
      developer.log(
        '🔍 [ANNOUNCEMENTS_SCREEN] Data types: ${announcementData.map((k, v) => MapEntry(k, '${v.runtimeType}: $v'))}',
      );
      developer.log(
        '🚀 [ANNOUNCEMENTS_SCREEN] Calling createGroupAnnouncement...',
      );

      final announcement = await ref
          .read(groupsProvider.notifier)
          .createGroupAnnouncement(widget.groupId, announcementData);

      developer.log(
        '✅ [ANNOUNCEMENTS_SCREEN] Announcement created successfully',
      );
      developer.log(
        '🎯 [ANNOUNCEMENTS_SCREEN] Created announcement: ${announcement.id}',
      );

      widget.onAnnouncementCreated(announcement);
      if (mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Announcement created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
      developer.log(
        '🔄 [ANNOUNCEMENTS_SCREEN] === CREATE ANNOUNCEMENT DEBUG END (SUCCESS) ===',
      );
    } catch (e) {
      developer.log(
        '❌ [ANNOUNCEMENTS_SCREEN] Error creating announcement: $e',
        error: e,
      );
      developer.log('🔍 [ANNOUNCEMENTS_SCREEN] Error type: ${e.runtimeType}');
      developer.log('🔍 [ANNOUNCEMENTS_SCREEN] Error details: ${e.toString()}');

      setState(() {
        _isCreating = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create announcement: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      developer.log(
        '🔄 [ANNOUNCEMENTS_SCREEN] === CREATE ANNOUNCEMENT DEBUG END (ERROR) ===',
      );
    }
  }
}
