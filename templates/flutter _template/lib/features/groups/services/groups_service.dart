import 'dart:developer' as developer;
import 'dart:io';
import '../../../core/api/api_client.dart';
import '../../../core/exceptions/network_exception.dart';

import '../models/group_models.dart';

class GroupsService {
  final ApiClient _apiClient;
  GroupsService(this._apiClient);

  /// Get all groups (public + user's groups)
  Future<List<InvestmentGroup>> getAllGroups() async {
    try {
      developer.log('🔄 [GROUPS_SERVICE] Loading all groups...');
      final response = await _apiClient.get('groups/groups/');
      if (response != null && response['results'] != null) {
        final List<dynamic> groupsData = response['results'];
        final groups = groupsData
            .map(
              (item) => InvestmentGroup.fromJson(item as Map<String, dynamic>),
            )
            .toList();
        developer.log('✅ [GROUPS_SERVICE] Loaded ${groups.length} groups');
        return groups;
      }
      return [];
    } catch (e) {
      developer.log('❌ [GROUPS_SERVICE] Error loading groups: $e', error: e);
      throw NetworkException('Failed to load groups');
    }
  }

  /// Get user's groups (groups they are members of)
  Future<List<InvestmentGroup>> getMyGroups() async {
    try {
      developer.log('🔄 [GROUPS_SERVICE] Loading user groups...');
      final response = await _apiClient.get('groups/groups/my_groups/');
      if (response != null && response is List) {
        final groups = response
            .map(
              (item) => InvestmentGroup.fromJson(item as Map<String, dynamic>),
            )
            .toList();
        developer.log('✅ [GROUPS_SERVICE] Loaded ${groups.length} user groups');
        return groups;
      }
      return [];
    } catch (e) {
      developer.log(
        '❌ [GROUPS_SERVICE] Error loading user groups: $e',
        error: e,
      );
      throw NetworkException('Failed to load user groups');
    }
  }

  /// Get public groups available to join
  Future<List<InvestmentGroup>> getPublicGroups() async {
    try {
      developer.log('🔄 [GROUPS_SERVICE] Loading public groups...');
      final response = await _apiClient.get('groups/groups/public_groups/');
      if (response != null && response is List) {
        final groups = response
            .map(
              (item) => InvestmentGroup.fromJson(item as Map<String, dynamic>),
            )
            .toList();
        developer.log(
          '✅ [GROUPS_SERVICE] Loaded ${groups.length} public groups',
        );
        return groups;
      }
      return [];
    } catch (e) {
      developer.log(
        '❌ [GROUPS_SERVICE] Error loading public groups: $e',
        error: e,
      );
      throw NetworkException('Failed to load public groups');
    }
  }

  /// Get group details by ID
  Future<InvestmentGroup> getGroupDetails(String groupId) async {
    try {
      developer.log(
        '🔄 [GROUPS_SERVICE] Loading group details for ID: $groupId',
      );
      final response = await _apiClient.get('groups/groups/$groupId/');
      if (response != null) {
        final group = InvestmentGroup.fromJson(response);
        developer.log('✅ [GROUPS_SERVICE] Loaded group details: ${group.name}');
        return group;
      }
      throw NetworkException('Group not found');
    } catch (e) {
      developer.log(
        '❌ [GROUPS_SERVICE] Error loading group details: $e',
        error: e,
      );
      throw NetworkException('Failed to load group details');
    }
  }

  /// Get group activity feed
  Future<List<GroupActivity>> getGroupActivity(String groupId) async {
    try {
      developer.log(
        '🔄 [GROUPS_SERVICE] Loading group activity for ID: $groupId',
      );
      final response = await _apiClient.get('groups/groups/$groupId/activity/');

      // Handle both paginated and non-paginated responses for backward compatibility
      if (response != null) {
        List<dynamic> activitiesData;

        if (response is Map<String, dynamic> &&
            response.containsKey('results')) {
          // Paginated response
          activitiesData = response['results'] as List<dynamic>;
          developer.log(
            '📄 [GROUPS_SERVICE] Received paginated response with ${activitiesData.length} activities',
          );
        } else if (response is List) {
          // Non-paginated response (backward compatibility)
          activitiesData = response;
          developer.log(
            '📄 [GROUPS_SERVICE] Received non-paginated response with ${activitiesData.length} activities',
          );
        } else {
          developer.log('❌ [GROUPS_SERVICE] Unexpected response format');
          return [];
        }

        final activities = activitiesData
            .map((activityJson) => GroupActivity.fromJson(activityJson))
            .toList();
        developer.log(
          '✅ [GROUPS_SERVICE] Loaded ${activities.length} group activities',
        );
        return activities;
      }
      return [];
    } catch (e) {
      developer.log(
        '❌ [GROUPS_SERVICE] Error loading group activity: $e',
        error: e,
      );
      throw NetworkException('Failed to load group activity');
    }
  }

  /// Create a new group
  Future<InvestmentGroup> createGroup(
    Map<String, dynamic> groupData, [
    File? imageFile,
  ]) async {
    try {
      developer.log('🔄 [GROUPS_SERVICE] Creating group: ${groupData['name']}');
      developer.log('🔍 [GROUPS_SERVICE] === GROUP CREATION DEBUG START ===');

      // Log complete group data with types
      developer.log('🔍 [GROUPS_SERVICE] Complete group data:');
      groupData.forEach((key, value) {
        developer.log('  $key: $value (${value.runtimeType})');
      });

      // Special focus on admin_emails
      if (groupData.containsKey('admin_emails')) {
        final adminEmails = groupData['admin_emails'];
        developer.log('🔍 [GROUPS_SERVICE] Admin emails detailed analysis:');
        developer.log('  Type: ${adminEmails.runtimeType}');
        developer.log('  Value: $adminEmails');
        if (adminEmails is List) {
          developer.log('  List length: ${adminEmails.length}');
          for (int i = 0; i < adminEmails.length; i++) {
            developer.log(
              '    [$i]: ${adminEmails[i]} (${adminEmails[i].runtimeType})',
            );
          }
        }
      }

      // Check authentication headers
      final headers = await _apiClient.getAuthHeaders();
      developer.log('🔍 [GROUPS_SERVICE] Auth headers: $headers');

      // Log upload method decision
      final useMultipart = imageFile != null;
      developer.log(
        '🔍 [GROUPS_SERVICE] Upload method: ${useMultipart ? 'MULTIPART' : 'JSON'}',
      );

      if (useMultipart) {
        developer.log('🔍 [GROUPS_SERVICE] Image file: ${imageFile.path}');
        developer.log(
          '🔍 [GROUPS_SERVICE] Image exists: ${await imageFile.exists()}',
        );
      }

      Map<String, dynamic> response;
      if (imageFile != null) {
        // Use multipart upload for image
        developer.log('🔄 [GROUPS_SERVICE] Executing multipart upload...');
        response = await _apiClient.postMultipartWithAuth(
          'groups/groups/',
          groupData,
          {'profile_image': imageFile.path},
        );
      } else {
        // Regular JSON upload
        developer.log('🔄 [GROUPS_SERVICE] Executing JSON upload...');
        response = await _apiClient.postWithAuth('groups/groups/', groupData);
      }

      developer.log('🔍 [GROUPS_SERVICE] Raw API response: $response');
      developer.log(
        '🔍 [GROUPS_SERVICE] Response type: ${response.runtimeType}',
      );

      final group = InvestmentGroup.fromJson(response);
      developer.log(
        '✅ [GROUPS_SERVICE] Successfully created group: ${group.name}',
      );
      developer.log('🔍 [GROUPS_SERVICE] === GROUP CREATION DEBUG END ===');
      return group;
    } catch (e) {
      developer.log(
        '❌ [GROUPS_SERVICE] === GROUP CREATION ERROR DEBUG START ===',
      );
      developer.log('❌ [GROUPS_SERVICE] Error creating group: $e', error: e);
      developer.log('❌ [GROUPS_SERVICE] Error type: ${e.runtimeType}');
      developer.log('❌ [GROUPS_SERVICE] Error string: ${e.toString()}');

      // Log stack trace if available
      if (e is Error) {
        developer.log('❌ [GROUPS_SERVICE] Stack trace: ${e.stackTrace}');
      }
      developer.log(
        '❌ [GROUPS_SERVICE] === GROUP CREATION ERROR DEBUG END ===',
      );

      // Provide more specific error messages
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('401') || errorString.contains('unauthorized')) {
        throw NetworkException('Authentication failed. Please log in again.');
      } else if (errorString.contains('400') ||
          errorString.contains('bad request')) {
        // Extract more detailed error information for 400 errors
        String detailedError =
            'Invalid group data. Please check all required fields.';
        if (errorString.contains('admin_emails')) {
          detailedError =
              'Invalid admin email format. Please check the email addresses.';
        }
        throw NetworkException(detailedError);
      } else if (errorString.contains('403') ||
          errorString.contains('forbidden')) {
        throw NetworkException('You do not have permission to create groups.');
      } else {
        throw NetworkException('Failed to create group: ${e.toString()}');
      }
    }
  }

  /// Update a group
  Future<InvestmentGroup> updateGroup(
    String groupId,
    Map<String, dynamic> groupData, [
    File? imageFile,
  ]) async {
    try {
      developer.log('🔄 [GROUPS_SERVICE] Updating group: $groupId');
      Map<String, dynamic> response;
      if (imageFile != null) {
        // Use multipart PATCH for image updates
        response = await _apiClient.patchMultipartWithAuth(
          'groups/groups/$groupId/',
          groupData,
          {'profile_image': imageFile.path},
        );
      } else {
        // Regular JSON PATCH
        response = await _apiClient.patchWithAuth(
          'groups/groups/$groupId/',
          groupData,
        );
      }
      final group = InvestmentGroup.fromJson(response);
      developer.log('✅ [GROUPS_SERVICE] Updated group: ${group.name}');
      return group;
    } catch (e) {
      developer.log('❌ [GROUPS_SERVICE] Error updating group: $e', error: e);
      throw NetworkException('Failed to update group');
    }
  }

  /// Delete a group
  Future<void> deleteGroup(String groupId) async {
    try {
      developer.log('🔄 [GROUPS_SERVICE] Deleting group: $groupId');
      await _apiClient.deleteWithAuth('groups/groups/$groupId/');
      developer.log('✅ [GROUPS_SERVICE] Deleted group: $groupId');
    } catch (e) {
      developer.log('❌ [GROUPS_SERVICE] Error deleting group: $e', error: e);
      throw NetworkException('Failed to delete group');
    }
  }

  /// Join a group
  Future<GroupMembership> joinGroup(String groupId) async {
    try {
      developer.log('🔄 [GROUPS_SERVICE] === JOIN GROUP DEBUG START ===');
      developer.log('🔍 [GROUPS_SERVICE] Joining group: $groupId');
      developer.log(
        '🔍 [GROUPS_SERVICE] Group ID type: ${groupId.runtimeType}',
      );
      developer.log('🔍 [GROUPS_SERVICE] Group ID length: ${groupId.length}');

      // Validate group ID
      if (groupId.isEmpty) {
        developer.log('❌ [GROUPS_SERVICE] Group ID is empty');
        throw NetworkException('Invalid group ID');
      }

      // Check authentication headers
      final headers = await _apiClient.getAuthHeaders();
      final hasToken = headers.containsKey('Authorization');
      developer.log('🔍 [GROUPS_SERVICE] Has auth token: $hasToken');
      if (hasToken) {
        final authHeader = headers['Authorization'];
        developer.log(
          '🔍 [GROUPS_SERVICE] Auth header format: ${authHeader?.substring(0, 20)}...',
        );
      }

      // Enhanced debugging for the exact URL being called
      final endpoint = 'groups/groups/$groupId/join/';
      developer.log('🔍 [GROUPS_SERVICE] Full endpoint: $endpoint');
      developer.log('🔍 [GROUPS_SERVICE] Base URL: ${_apiClient.baseUrl}');
      developer.log(
        '🔍 [GROUPS_SERVICE] Complete URL: ${_apiClient.baseUrl}/$endpoint',
      );

      // Log request payload
      final requestPayload = <String, dynamic>{};
      developer.log('🔍 [GROUPS_SERVICE] Request payload: $requestPayload');
      developer.log(
        '🔍 [GROUPS_SERVICE] Payload type: ${requestPayload.runtimeType}',
      );

      developer.log('🔄 [GROUPS_SERVICE] Executing join group API call...');
      final response = await _apiClient.postWithAuth(endpoint, requestPayload);
      developer.log('✅ [GROUPS_SERVICE] API call completed');
      developer.log(
        '🔍 [GROUPS_SERVICE] Response type: ${response.runtimeType}',
      );

      if (response != null && response is Map<String, dynamic>) {
        developer.log('🔍 [GROUPS_SERVICE] Processing response...');
        developer.log('🔍 [GROUPS_SERVICE] Response keys: ${response.keys}');
        final membership = GroupMembership.fromJson(response);
        developer.log('✅ [GROUPS_SERVICE] Joined group successfully');
        developer.log(
          '🔍 [GROUPS_SERVICE] Created membership: ${membership.id}',
        );
        developer.log(
          '🔍 [GROUPS_SERVICE] Membership status: ${membership.status}',
        );
        developer.log(
          '🔍 [GROUPS_SERVICE] Membership role: ${membership.role}',
        );
        developer.log('🔄 [GROUPS_SERVICE] === JOIN GROUP DEBUG END ===');
        return membership;
      } else {
        developer.log('❌ [GROUPS_SERVICE] Response was null');
        throw NetworkException('Failed to join group');
      }
    } catch (e) {
      developer.log('❌ [GROUPS_SERVICE] === JOIN GROUP ERROR DEBUG START ===');
      developer.log('❌ [GROUPS_SERVICE] Error joining group: $e');
      developer.log('❌ [GROUPS_SERVICE] Error joining group: $e', error: e);
      developer.log('❌ [GROUPS_SERVICE] === JOIN GROUP ERROR DEBUG END ===');

      // Enhanced error handling with more specific messages
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('404') || errorString.contains('not found')) {
        throw NetworkException(
          'Group not found or you may not have permission to join this group.',
        );
      } else if (errorString.contains('401') ||
          errorString.contains('unauthorized')) {
        throw NetworkException(
          'You do not have permission to join this group. It may be private or require an invitation.',
        );
      } else if (errorString.contains('400') ||
          errorString.contains('bad request')) {
        throw NetworkException(
          'Unable to join group. You may already be a member or the group may not be accepting new members.',
        );
      } else {
        throw NetworkException('Failed to join group: ${e.toString()}');
      }
    }
  }

  /// Leave a group
  Future<void> leaveGroup(String groupId) async {
    try {
      developer.log('🔄 [GROUPS_SERVICE] Leaving group: $groupId');
      await _apiClient.postWithAuth('groups/groups/$groupId/leave/', {});
      developer.log('✅ [GROUPS_SERVICE] Left group successfully');
    } catch (e) {
      developer.log('❌ [GROUPS_SERVICE] Error leaving group: $e', error: e);
      throw NetworkException('Failed to leave group');
    }
  }

  /// Contribute to a group
  Future<GroupContribution> contributeToGroup(
    String groupId,
    Map<String, dynamic> contributionData,
  ) async {
    try {
      developer.log('🔄 [GROUPS_SERVICE] Contributing to group: $groupId');
      developer.log('🔍 [GROUPS_SERVICE] Contribution data: $contributionData');

      final response = await _apiClient.postWithAuth(
        'groups/groups/$groupId/contribute/',
        contributionData,
      );
      if (response != null) {
        final contribution = GroupContribution.fromJson(response);
        developer.log(
          '✅ [GROUPS_SERVICE] Contribution successful: ${contribution.amount}',
        );
        return contribution;
      }
      throw NetworkException('Failed to contribute to group');
    } catch (e) {
      developer.log(
        '❌ [GROUPS_SERVICE] Error contributing to group: $e',
        error: e,
      );

      // Enhanced error handling for contribution restrictions
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('403') || errorString.contains('forbidden')) {
        // Try to extract detailed error message from the response
        String detailedMessage =
            'This group is not currently accepting contributions.';

        if (errorString.contains('group_inactive') ||
            errorString.contains('pending_activation')) {
          detailedMessage =
              'This group is not yet active. Only active groups accept contributions.';
        } else if (errorString.contains('suspended')) {
          detailedMessage =
              'This group is suspended and cannot accept contributions.';
        } else if (errorString.contains('dissolved')) {
          detailedMessage =
              'This group has been dissolved and cannot accept contributions.';
        } else if (errorString.contains('target_reached')) {
          detailedMessage = 'This group has already reached its target amount.';
        }

        throw NetworkException(detailedMessage);
      } else if (errorString.contains('400') ||
          errorString.contains('bad request')) {
        throw NetworkException(
          'Invalid contribution data. Please check the amount and try again.',
        );
      } else if (errorString.contains('401') ||
          errorString.contains('unauthorized')) {
        throw NetworkException(
          'You must be logged in to contribute to groups.',
        );
      } else {
        throw NetworkException(
          'Failed to contribute to group: ${e.toString()}',
        );
      }
    }
  }

  /// Initialize Paystack payment for group contribution
  Future<Map<String, dynamic>> initializeGroupContributionPayment({
    required String groupId,
    required double contributionAmount,
    required String paymentMethodId,
    double? totalAmount, // Total amount including platform fee
  }) async {
    try {
      developer.log(
        '🔄 [GROUPS_SERVICE] Initializing group contribution payment for group: $groupId',
      );
      developer.log(
        '🔍 [GROUPS_SERVICE] Contribution amount: $contributionAmount, total: ${totalAmount ?? contributionAmount}',
      );

      final requestData = {
        'group_id': groupId,
        'contribution_amount': contributionAmount
            .toString(), // Original contribution amount
        'payment_method_id': paymentMethodId,
      };

      // Add total amount if provided (for non-manual payments with platform fee)
      if (totalAmount != null && totalAmount != contributionAmount) {
        requestData['total_amount'] = totalAmount.toString();
      } else {
        requestData['total_amount'] = contributionAmount.toString();
      }

      final response = await _apiClient.postWithAuth(
        'payments/paystack/group-contribution/initialize/',
        requestData,
      );

      developer.log(
        '✅ [GROUPS_SERVICE] Group contribution payment initialized successfully',
      );
      developer.log('🔍 [GROUPS_SERVICE] Response: $response');

      return {'success': true, 'data': response};
    } catch (e) {
      developer.log(
        '❌ [GROUPS_SERVICE] Error initializing group contribution payment: $e',
      );

      String errorMessage = 'Failed to initialize payment';
      final errorString = e.toString().toLowerCase();

      if (errorString.contains('403') || errorString.contains('forbidden')) {
        if (errorString.contains('contribution_restricted')) {
          errorMessage = 'This group is not currently accepting contributions.';
        } else if (errorString.contains('not.*member')) {
          errorMessage =
              'You must be an active member of this group to contribute.';
        } else {
          errorMessage = 'You are not authorized to contribute to this group.';
        }
      } else if (errorString.contains('400') ||
          errorString.contains('bad request')) {
        errorMessage =
            'Invalid contribution data. Please check the amount and try again.';
      } else if (errorString.contains('401') ||
          errorString.contains('unauthorized')) {
        errorMessage = 'You must be logged in to contribute to groups.';
      }

      return {'success': false, 'error': errorMessage};
    }
  }

  /// Verify Paystack payment for group contribution
  Future<Map<String, dynamic>> verifyGroupContributionPayment(
    String reference,
  ) async {
    try {
      developer.log(
        '🔄 [GROUPS_SERVICE] Verifying group contribution payment with reference: "$reference"',
      );
      developer.log(
        '🔄 [GROUPS_SERVICE] Reference length: ${reference.length}',
      );
      developer.log(
        '🔄 [GROUPS_SERVICE] Reference contains pipe: ${reference.contains('|')}',
      );

      // Clean the reference if it contains extra text (common issue with webhook processing)
      String cleanReference = reference;
      if (reference.contains('|')) {
        cleanReference = reference.split('|')[0].trim();
        developer.log(
          '🧹 [GROUPS_SERVICE] Cleaned reference from "$reference" to "$cleanReference"',
        );
      }

      final response = await _apiClient.postWithAuth(
        'payments/paystack/group-contribution/verify/',
        {'reference': cleanReference},
      );

      developer.log('🔍 [GROUPS_SERVICE] Verification response: $response');

      // Check if the backend verification was successful
      bool isSuccess = false;
      Map<String, dynamic>? responseData;
      String? errorMessage;

      if (response is Map<String, dynamic>) {
        // New format: {status: true/false, data: {...}, message: "..."}
        if (response.containsKey('status')) {
          isSuccess = response['status'] == true;
          responseData = response['data'];
          errorMessage = response['error'] ?? response['message'];
        }
        // Legacy format: direct data response (assume success if no error field)
        else if (!response.containsKey('error')) {
          isSuccess = true;
          responseData = response;
        }
        // Error response format
        else {
          isSuccess = false;
          errorMessage =
              response['error'] ??
              response['message'] ??
              'Payment verification failed';
        }
      }

      if (isSuccess) {
        developer.log(
          '✅ [GROUPS_SERVICE] Group contribution payment verified successfully',
        );
        return {'success': true, 'data': responseData ?? {}};
      } else {
        developer.log(
          '❌ [GROUPS_SERVICE] Group contribution payment verification failed: $errorMessage',
        );
        return {
          'success': false,
          'error': errorMessage ?? 'Payment verification failed',
        };
      }
    } catch (e) {
      developer.log(
        '❌ [GROUPS_SERVICE] Error verifying group contribution payment: $e',
      );

      String errorMessage = 'Failed to verify payment';
      final errorString = e.toString().toLowerCase();

      if (errorString.contains('400') || errorString.contains('bad request')) {
        errorMessage = 'Invalid payment reference. Please try again.';
      } else if (errorString.contains('401') ||
          errorString.contains('unauthorized')) {
        errorMessage = 'You must be logged in to verify payments.';
      } else if (errorString.contains('404') ||
          errorString.contains('not found')) {
        errorMessage =
            'Payment not found. Please check the reference and try again.';
      }

      return {'success': false, 'error': errorMessage};
    }
  }

  /// Get group performance data
  Future<Map<String, dynamic>> getGroupPerformance(String groupId) async {
    try {
      developer.log('🔄 [GROUPS_SERVICE] Loading group performance: $groupId');
      final response = await _apiClient.get(
        'groups/groups/$groupId/performance/',
      );
      if (response != null) {
        developer.log('✅ [GROUPS_SERVICE] Loaded group performance data');
        return response;
      }
      throw NetworkException('Failed to load group performance');
    } catch (e) {
      developer.log(
        '❌ [GROUPS_SERVICE] Error loading group performance: $e',
        error: e,
      );
      throw NetworkException('Failed to load group performance');
    }
  }

  /// Invite user to group
  Future<GroupMembership> inviteToGroup(String groupId, String email) async {
    try {
      developer.log('🔄 [GROUPS_SERVICE] === GROUP INVITATION DEBUG START ===');
      developer.log('🔍 [GROUPS_SERVICE] Inviting user to group: $groupId');
      developer.log('🔍 [GROUPS_SERVICE] Inviting email: $email');
      developer.log('🔍 [GROUPS_SERVICE] Email type: ${email.runtimeType}');

      // Validate inputs
      if (groupId.isEmpty) {
        developer.log('❌ [GROUPS_SERVICE] Group ID is empty');
        throw NetworkException('Group ID is required');
      }
      if (email.isEmpty) {
        developer.log('❌ [GROUPS_SERVICE] Email is empty');
        throw NetworkException('Email address is required');
      }

      final endpoint = 'groups/groups/$groupId/invite/';
      final requestPayload = {'email': email};
      developer.log('🔄 [GROUPS_SERVICE] Executing invitation API call...');
      developer.log('🔄 [GROUPS_SERVICE] About to call postWithAuth...');
      developer.log('🔍 [GROUPS_SERVICE] Endpoint: $endpoint');
      developer.log('🔍 [GROUPS_SERVICE] Payload: $requestPayload');

      final response = await _apiClient.postWithAuth(endpoint, requestPayload);

      if (response != null && response is Map<String, dynamic>) {
        // Check response type
        final responseType = response['type'] as String?;
        developer.log('🔍 [GROUPS_SERVICE] Response type: $responseType');

        if (responseType == 'membership') {
          // Existing user - GroupMembership created
          developer.log(
            '✅ [GROUPS_SERVICE] Processing membership response for existing user',
          );
          final membershipData = response['membership'] as Map<String, dynamic>;
          final membership = GroupMembership.fromJson(membershipData);
          developer.log('✅ [GROUPS_SERVICE] Invitation sent to existing user');
          developer.log(
            '🔍 [GROUPS_SERVICE] Created membership: ${membership.id}',
          );
          developer.log(
            '🔍 [GROUPS_SERVICE] === GROUP INVITATION DEBUG END ===',
          );
          return membership;
        } else if (responseType == 'invitation') {
          // Non-existing user - GroupInvitation created
          developer.log(
            '✅ [GROUPS_SERVICE] Processing invitation response for non-existing user',
          );
          // Create a placeholder GroupMembership for UI consistency
          // The actual invitation is stored in GroupInvitation model
          final placeholderUser = User(
            id: 'pending',
            email: email,
            firstName: '',
            lastName: '',
          );
          final placeholderMembership = GroupMembership(
            id: 'invitation-${DateTime.now().millisecondsSinceEpoch}',
            user: placeholderUser,
            role: 'member',
            status: 'invited', // Special status for email invitations
            invitedAt: DateTime.now(),
            joinedAt: null,
            totalContributions: 0.0,
            contributionPercentage: 0.0,
          );
          developer.log(
            '✅ [GROUPS_SERVICE] Email invitation sent to non-existing user',
          );
          developer.log(
            '🔍 [GROUPS_SERVICE] Created placeholder membership for UI',
          );
          developer.log(
            '🔍 [GROUPS_SERVICE] === GROUP INVITATION DEBUG END ===',
          );
          return placeholderMembership;
        } else {
          // Fallback for old response format (backward compatibility)
          developer.log('🔍 [GROUPS_SERVICE] Using fallback response parsing');
          final membership = GroupMembership.fromJson(response);
          developer.log(
            '✅ [GROUPS_SERVICE] Invitation sent successfully (fallback)',
          );
          developer.log(
            '🔍 [GROUPS_SERVICE] === GROUP INVITATION DEBUG END ===',
          );
          return membership;
        }
      } else {
        developer.log('❌ [GROUPS_SERVICE] Response was null or invalid format');
        throw NetworkException('Failed to send invitation');
      }
    } catch (e) {
      developer.log(
        '❌ [GROUPS_SERVICE] === GROUP INVITATION ERROR DEBUG START ===',
      );
      developer.log('❌ [GROUPS_SERVICE] Error sending invitation: $e');
      developer.log(
        '❌ [GROUPS_SERVICE] === GROUP INVITATION ERROR DEBUG START ===',
        error: e,
      );
      developer.log(
        '❌ [GROUPS_SERVICE] Error sending invitation: $e',
        error: e,
      );
      developer.log(
        '❌ [GROUPS_SERVICE] === GROUP INVITATION ERROR DEBUG END ===',
      );

      // Enhanced error handling with more specific messages
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('404') || errorString.contains('not found')) {
        throw NetworkException(
          'Group not found or you may not have admin permissions for this group. Please check your group membership status.',
        );
      } else if (errorString.contains('403') ||
          errorString.contains('forbidden')) {
        throw NetworkException(
          'You do not have admin permissions to invite users to this group. Only group admins can send invitations.',
        );
      } else if (errorString.contains('400') ||
          errorString.contains('bad request')) {
        throw NetworkException(
          'Invalid email address, user already invited, or user is already a member of this group.',
        );
      } else {
        throw NetworkException('Failed to send invitation: ${e.toString()}');
      }
    }
  }

  /// Get user's group statistics
  Future<GroupStats> getGroupStats() async {
    try {
      developer.log('🔄 [GROUPS_SERVICE] Loading group statistics...');
      final response = await _apiClient.get('groups/groups/stats/');
      if (response != null) {
        final stats = GroupStats.fromJson(response);
        developer.log('✅ [GROUPS_SERVICE] Loaded group statistics');
        return stats;
      }
      throw NetworkException('Failed to load group statistics');
    } catch (e) {
      developer.log(
        '❌ [GROUPS_SERVICE] Error loading group statistics: $e',
        error: e,
      );
      throw NetworkException('Failed to load group statistics');
    }
  }

  /// Get group memberships
  Future<List<GroupMembership>> getGroupMemberships() async {
    try {
      developer.log('🔄 [GROUPS_SERVICE] Loading group memberships...');
      final response = await _apiClient.get('groups/memberships/');
      if (response != null && response['results'] != null) {
        final List<dynamic> membershipsData = response['results'];
        final memberships = membershipsData
            .map(
              (item) => GroupMembership.fromJson(item as Map<String, dynamic>),
            )
            .toList();
        developer.log(
          '✅ [GROUPS_SERVICE] Loaded ${memberships.length} memberships',
        );
        return memberships;
      }
      return [];
    } catch (e) {
      developer.log(
        '❌ [GROUPS_SERVICE] Error loading memberships: $e',
        error: e,
      );
      throw NetworkException('Failed to load memberships');
    }
  }

  /// Get group contributions
  Future<List<GroupContribution>> getGroupContributions() async {
    try {
      developer.log('🔄 [GROUPS_SERVICE] Loading group contributions...');
      final response = await _apiClient.get('groups/contributions/');
      if (response != null && response['results'] != null) {
        final List<dynamic> contributionsData = response['results'];
        final contributions = contributionsData
            .map(
              (item) =>
                  GroupContribution.fromJson(item as Map<String, dynamic>),
            )
            .toList();
        developer.log(
          '✅ [GROUPS_SERVICE] Loaded ${contributions.length} contributions',
        );
        return contributions;
      }
      return [];
    } catch (e) {
      developer.log(
        '❌ [GROUPS_SERVICE] Error loading contributions: $e',
        error: e,
      );
      throw NetworkException('Failed to load contributions');
    }
  }

  // ============================================================================
  // ADMIN MANAGEMENT METHODS
  // ============================================================================

  /// Get group admins
  Future<List<GroupMembership>> getGroupAdmins(String groupId) async {
    try {
      developer.log(
        '🔄 [GROUPS_SERVICE] Loading group admins for group: $groupId',
      );
      final response = await _apiClient.get('groups/groups/$groupId/admins/');
      if (response != null && response is List) {
        final admins = response
            .map(
              (item) => GroupMembership.fromJson(item as Map<String, dynamic>),
            )
            .toList();
        developer.log(
          '✅ [GROUPS_SERVICE] Loaded ${admins.length} group admins',
        );
        return admins;
      }
      return [];
    } catch (e) {
      developer.log(
        '❌ [GROUPS_SERVICE] Error loading group admins: $e',
        error: e,
      );
      throw NetworkException('Failed to load group admins');
    }
  }

  /// Promote a member to admin
  Future<GroupMembership> promoteToAdmin(String groupId, String userId) async {
    try {
      developer.log(
        '🔄 [GROUPS_SERVICE] Promoting user $userId to admin in group $groupId',
      );
      final response = await _apiClient.postWithAuth(
        'groups/groups/$groupId/promote_admin/',
        {'user_id': userId},
      );
      if (response != null && response is Map<String, dynamic>) {
        final membership = GroupMembership.fromJson(response);
        developer.log('✅ [GROUPS_SERVICE] User promoted to admin successfully');
        return membership;
      }
      throw NetworkException('Invalid response format');
    } catch (e) {
      developer.log(
        '❌ [GROUPS_SERVICE] Error promoting user to admin: $e',
        error: e,
      );
      throw NetworkException('Failed to promote user to admin');
    }
  }

  /// Demote an admin to member
  Future<GroupMembership> demoteAdmin(String groupId, String userId) async {
    try {
      developer.log(
        '🔄 [GROUPS_SERVICE] Demoting admin $userId in group $groupId',
      );
      final response = await _apiClient.postWithAuth(
        'groups/groups/$groupId/demote_admin/',
        {'user_id': userId},
      );
      if (response != null && response is Map<String, dynamic>) {
        final membership = GroupMembership.fromJson(response);
        developer.log('✅ [GROUPS_SERVICE] Admin demoted successfully');
        return membership;
      }
      throw NetworkException('Invalid response format');
    } catch (e) {
      developer.log('❌ [GROUPS_SERVICE] Error demoting admin: $e', error: e);
      throw NetworkException('Failed to demote admin');
    }
  }

  // ============================================================================
  // ADMIN VOTING METHODS
  // ============================================================================

  /// Get active polls for a group
  Future<List<AdminPoll>> getGroupPolls(String groupId) async {
    try {
      developer.log('🔄 [GROUPS_SERVICE] Loading polls for group: $groupId');
      final response = await _apiClient.get('groups/groups/$groupId/polls/');
      if (response != null && response is List) {
        final polls = response
            .map((item) => AdminPoll.fromJson(item as Map<String, dynamic>))
            .toList();
        developer.log('✅ [GROUPS_SERVICE] Loaded ${polls.length} polls');
        return polls;
      }
      return [];
    } catch (e) {
      developer.log('❌ [GROUPS_SERVICE] Error loading polls: $e', error: e);
      throw NetworkException('Failed to load polls');
    }
  }

  /// Create a new admin poll
  Future<AdminPoll> createPoll(
    String groupId,
    Map<String, dynamic> pollData,
  ) async {
    try {
      developer.log('🔄 [GROUPS_SERVICE] Creating poll for group: $groupId');
      final response = await _apiClient.postWithAuth(
        'groups/groups/$groupId/create_poll/',
        pollData,
      );
      if (response != null && response is Map<String, dynamic>) {
        final poll = AdminPoll.fromJson(response);
        developer.log('✅ [GROUPS_SERVICE] Poll created successfully');
        return poll;
      }
      throw NetworkException('Invalid response format');
    } catch (e) {
      developer.log('❌ [GROUPS_SERVICE] Error creating poll: $e', error: e);
      throw NetworkException('Failed to create poll');
    }
  }

  /// Cast a vote on a poll
  Future<AdminVote> voteOnPoll(
    String groupId,
    String pollId,
    String vote,
  ) async {
    try {
      developer.log('🔄 [GROUPS_SERVICE] Casting vote on poll: $pollId');
      developer.log('🔍 [GROUPS_SERVICE] Group ID: $groupId');
      developer.log('🔍 [GROUPS_SERVICE] Poll ID: $pollId');
      developer.log('🔍 [GROUPS_SERVICE] Vote: $vote');
      developer.log(
        '🔍 [GROUPS_SERVICE] URL: groups/groups/$groupId/polls/$pollId/vote/',
      );
      developer.log('🔍 [GROUPS_SERVICE] Data: ${{'vote': vote}}');
      final response = await _apiClient.postWithAuth(
        'groups/groups/$groupId/polls/$pollId/vote/',
        {'vote': vote},
      );
      if (response != null && response is Map<String, dynamic>) {
        final adminVote = AdminVote.fromJson(response);
        developer.log('✅ [GROUPS_SERVICE] Vote cast successfully');
        return adminVote;
      }
      throw NetworkException('Invalid response format');
    } catch (e) {
      developer.log('❌ [GROUPS_SERVICE] Error casting vote: $e', error: e);
      if (e.toString().contains('400')) {
        developer.log(
          '❌ [GROUPS_SERVICE] 400 Bad Request - likely validation error',
        );
        throw NetworkException('Vote validation failed: ${e.toString()}');
      }
      throw NetworkException('Failed to cast vote: ${e.toString()}');
    }
  }

  // ============================================================================
  // ANNOUNCEMENT METHODS
  // ============================================================================

  /// Get announcements for a specific group
  Future<List<GroupAnnouncement>> getGroupAnnouncements(String groupId) async {
    try {
      developer.log(
        '🔄 [GROUPS_SERVICE] Loading announcements for group: $groupId',
      );
      final response = await _apiClient.get(
        'groups/groups/$groupId/announcements/',
      );
      if (response != null && response is List) {
        final announcements = response
            .map(
              (item) =>
                  GroupAnnouncement.fromJson(item as Map<String, dynamic>),
            )
            .toList();
        developer.log(
          '✅ [GROUPS_SERVICE] Loaded ${announcements.length} announcements',
        );
        return announcements;
      }
      return [];
    } catch (e) {
      developer.log(
        '❌ [GROUPS_SERVICE] Error loading announcements: $e',
        error: e,
      );
      throw NetworkException('Failed to load announcements: ${e.toString()}');
    }
  }

  /// Create a new announcement for a group
  Future<GroupAnnouncement> createGroupAnnouncement(
    String groupId,
    Map<String, dynamic> announcementData,
  ) async {
    try {
      developer.log(
        '🔄 [GROUPS_SERVICE] Creating announcement for group: $groupId',
      );
      developer.log(
        '🔍 [GROUPS_SERVICE] Raw announcement data: $announcementData',
      );
      developer.log(
        '🔍 [GROUPS_SERVICE] Data types: ${announcementData.map((k, v) => MapEntry(k, '${v.runtimeType}: $v'))}',
      );

      // Log the exact endpoint being called
      final endpoint = 'groups/groups/$groupId/create-announcement/';
      developer.log('🌐 [GROUPS_SERVICE] API endpoint: $endpoint');

      // Log request details before making the call
      developer.log(
        '📤 [GROUPS_SERVICE] Making POST request with authentication...',
      );
      developer.log(
        '📋 [GROUPS_SERVICE] Request payload: ${announcementData.toString()}',
      );

      final response = await _apiClient.postWithAuth(
        endpoint,
        announcementData,
      );

      developer.log('📥 [GROUPS_SERVICE] Raw response received');
      developer.log('📋 [GROUPS_SERVICE] Response data: $response');

      if (response != null && response is Map<String, dynamic>) {
        developer.log(
          '✅ [GROUPS_SERVICE] Response is valid Map, parsing announcement...',
        );
        final announcement = GroupAnnouncement.fromJson(response);
        developer.log('✅ [GROUPS_SERVICE] Announcement created successfully');
        developer.log(
          '🎯 [GROUPS_SERVICE] Created announcement ID: ${announcement.id}',
        );
        developer.log(
          '🎯 [GROUPS_SERVICE] Created announcement title: ${announcement.title}',
        );
        return announcement;
      } else {
        developer.log('❌ [GROUPS_SERVICE] Invalid response format - not a Map');
        developer.log('🔍 [GROUPS_SERVICE] Response details: $response');
        throw NetworkException(
          'Invalid response format: Expected Map but got ${response.runtimeType}',
        );
      }
    } catch (e) {
      developer.log(
        '❌ [GROUPS_SERVICE] Error creating announcement: $e',
        error: e,
      );
      developer.log('🔍 [GROUPS_SERVICE] Error type: ${e.runtimeType}');
      if (e is NetworkException) {
        developer.log(
          '🔍 [GROUPS_SERVICE] NetworkException details: ${e.toString()}',
        );
      }
      throw NetworkException('Failed to create announcement: ${e.toString()}');
    }
  }

  // ============================================================================
  // USER SEARCH METHODS
  // ============================================================================

  /// Search users for admin selection
  Future<List<User>> searchUsers(String query) async {
    try {
      developer.log('🔍 [GROUPS_SERVICE] Searching users: $query');
      final response = await _apiClient.get('groups/search-users/?q=$query');
      if (response != null && response is List) {
        final users = response
            .map((item) => User.fromJson(item as Map<String, dynamic>))
            .toList();
        developer.log('✅ [GROUPS_SERVICE] Found ${users.length} users');
        return users;
      }
      return [];
    } catch (e) {
      developer.log('❌ [GROUPS_SERVICE] Error searching users: $e', error: e);
      throw NetworkException('Failed to search users');
    }
  }

  // ============================================================================
  // INVITATION MANAGEMENT METHODS
  // ============================================================================

  /// Get pending invitations for current user
  Future<List<GroupInvitation>> getPendingInvitations() async {
    try {
      developer.log('🔄 [GROUPS_SERVICE] Loading pending invitations');
      final response = await _apiClient.get('groups/invitations/received/');
      if (response != null && response is List) {
        final List<dynamic> invitationsData = response;
        final invitations = invitationsData
            .map((invitationData) => GroupInvitation.fromJson(invitationData))
            .toList();
        developer.log(
          '✅ [GROUPS_SERVICE] Found ${invitations.length} pending invitations',
        );
        return invitations;
      }
      return [];
    } catch (e) {
      developer.log(
        '❌ [GROUPS_SERVICE] Error loading invitations: $e',
        error: e,
      );
      throw NetworkException('Failed to load invitations');
    }
  }

  /// Respond to a group invitation
  Future<bool> respondToInvitation(String invitationId, String action) async {
    try {
      developer.log(
        '🔄 [GROUPS_SERVICE] Responding to invitation: $invitationId with $action',
      );
      await _apiClient.postWithAuth(
        'groups/invitations/$invitationId/respond/',
        {'action': action},
      );
      developer.log('✅ [GROUPS_SERVICE] Successfully responded to invitation');
      return true;
    } catch (e) {
      developer.log(
        '❌ [GROUPS_SERVICE] Error responding to invitation: $e',
        error: e,
      );
      return false;
    }
  }

  /// Get sent invitations for a specific group
  Future<Map<String, dynamic>> getSentInvitations(String groupId) async {
    try {
      developer.log(
        '🔄 [GROUPS_SERVICE] === GET SENT INVITATIONS DEBUG START ===',
      );
      developer.log(
        '🔄 [GROUPS_SERVICE] === GET SENT INVITATIONS DEBUG START ===',
      );
      final endpoint = 'groups/groups/$groupId/sent-invitations/';
      developer.log(
        '🔍 [GROUPS_SERVICE] Fetching sent invitations for group: $groupId',
      );
      developer.log('🔄 [GROUPS_SERVICE] Executing API call...');
      final response = await _apiClient.get(endpoint);
      if (response != null && response is Map<String, dynamic>) {
        developer.log(
          '✅ [GROUPS_SERVICE] Sent invitations fetched successfully',
        );
        developer.log(
          '🔍 [GROUPS_SERVICE] Total invitations: ${response['total_invitations']}',
        );
        developer.log(
          '🔍 [GROUPS_SERVICE] Membership invitations: ${response['membership_invitations']}',
        );
        developer.log(
          '🔍 [GROUPS_SERVICE] Email invitations: ${response['email_invitations']}',
        );
        developer.log(
          '✅ [GROUPS_SERVICE] Sent invitations fetched successfully',
        );
        developer.log(
          '🔍 [GROUPS_SERVICE] === GET SENT INVITATIONS DEBUG END ===',
        );
        return response;
      }
      throw NetworkException('Failed to fetch sent invitations');
    } catch (e) {
      developer.log(
        '❌ [GROUPS_SERVICE] === GET SENT INVITATIONS ERROR DEBUG START ===',
      );
      developer.log('❌ [GROUPS_SERVICE] Error fetching sent invitations: $e');
      developer.log(
        '❌ [GROUPS_SERVICE] Error fetching sent invitations: $e',
        error: e,
      );
      developer.log(
        '❌ [GROUPS_SERVICE] === GET SENT INVITATIONS ERROR DEBUG END ===',
      );
      throw NetworkException('Failed to fetch sent invitations');
    }
  }

  /// Get all sent invitations by the current user (across all groups)
  Future<List<GroupInvitation>> getAllSentInvitations() async {
    try {
      developer.log(
        '🔄 [GROUPS_SERVICE] === GET ALL SENT INVITATIONS DEBUG START ===',
      );
      developer.log(
        '🔄 [GROUPS_SERVICE] === GET ALL SENT INVITATIONS DEBUG START ===',
      );
      final endpoint = 'groups/invitations/sent/';
      developer.log('🔍 [GROUPS_SERVICE] Fetching all sent invitations');
      final response = await _apiClient.get(endpoint);
      if (response != null && response is List) {
        final invitations = response
            .map(
              (item) => GroupInvitation.fromJson(item as Map<String, dynamic>),
            )
            .toList();
        developer.log(
          '✅ [GROUPS_SERVICE] All sent invitations fetched successfully',
        );
        developer.log(
          '🔍 [GROUPS_SERVICE] Total invitations: ${invitations.length}',
        );
        developer.log(
          '✅ [GROUPS_SERVICE] All sent invitations fetched successfully',
        );
        developer.log(
          '🔍 [GROUPS_SERVICE] Total invitations: ${invitations.length}',
        );
        developer.log(
          '🔍 [GROUPS_SERVICE] === GET ALL SENT INVITATIONS DEBUG END ===',
        );
        return invitations;
      } else {
        developer.log('❌ [GROUPS_SERVICE] Response was null or not a list');
        throw NetworkException('Failed to fetch sent invitations');
      }
    } catch (e) {
      developer.log(
        '❌ [GROUPS_SERVICE] === GET ALL SENT INVITATIONS ERROR DEBUG START ===',
      );
      developer.log(
        '❌ [GROUPS_SERVICE] Error fetching all sent invitations: $e',
      );
      developer.log(
        '❌ [GROUPS_SERVICE] Error fetching all sent invitations: $e',
        error: e,
      );
      developer.log(
        '❌ [GROUPS_SERVICE] === GET ALL SENT INVITATIONS ERROR DEBUG END ===',
      );
      throw NetworkException('Failed to fetch sent invitations');
    }
  }

  /// Resend a group invitation
  Future<GroupMembership> resendInvitation(String groupId, String email) async {
    try {
      developer.log(
        '🔄 [GROUPS_SERVICE] Resending invitation to $email for group: $groupId',
      );
      // Send a new invitation using the existing invite method
      final membership = await inviteToGroup(groupId, email);
      developer.log('✅ [GROUPS_SERVICE] Successfully resent invitation');
      return membership;
    } catch (e) {
      developer.log(
        '❌ [GROUPS_SERVICE] Error resending invitation: $e',
        error: e,
      );
      throw NetworkException('Failed to resend invitation: ${e.toString()}');
    }
  }

  /// Cancel a group invitation
  Future<bool> cancelInvitation(String invitationId) async {
    try {
      developer.log('🔄 [GROUPS_SERVICE] Canceling invitation: $invitationId');
      await _apiClient.deleteWithAuth('groups/invitations/$invitationId/');
      developer.log('✅ [GROUPS_SERVICE] Successfully canceled invitation');
      return true;
    } catch (e) {
      developer.log(
        '❌ [GROUPS_SERVICE] Error canceling invitation: $e',
        error: e,
      );
      throw NetworkException('Failed to cancel invitation: ${e.toString()}');
    }
  }
}
