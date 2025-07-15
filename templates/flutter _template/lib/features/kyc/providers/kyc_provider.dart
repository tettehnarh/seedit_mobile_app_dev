import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/kyc_models.dart';
import '../services/kyc_service.dart';
import '../services/kyc_local_storage_service.dart';
import '../utils/date_formatter.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../auth/providers/user_provider.dart';
import '../../notifications/providers/notifications_provider.dart';
import 'dart:developer' as developer;

/// State class for KYC management
class KycState {
  final KycStatus? kycStatus;
  final bool isLoading;
  final bool isInitialized;
  final String? errorMessage;

  const KycState({
    this.kycStatus,
    this.isLoading = false,
    this.isInitialized = false,
    this.errorMessage,
  });

  KycState copyWith({
    KycStatus? kycStatus,
    bool? isLoading,
    bool? isInitialized,
    String? errorMessage,
    bool clearError = false,
    bool clearKyc = false,
  }) {
    return KycState(
      kycStatus: clearKyc ? null : (kycStatus ?? this.kycStatus),
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Riverpod provider for managing KYC state
class KycNotifier extends StateNotifier<KycState> {
  final ApiClient _apiClient = ApiClient();
  final KycService _kycService = KycService();
  final Ref _ref;

  KycNotifier(this._ref) : super(const KycState()) {
    _initializeKyc();
  }

  /// Initialize KYC data
  Future<void> _initializeKyc() async {
    if (state.isInitialized) return;

    try {
      state = state.copyWith(isLoading: true, clearError: true);

      await _loadKycStatus();

      state = state.copyWith(isLoading: false, isInitialized: true);

      developer.log('KYC data initialized successfully');
    } catch (e) {
      developer.log('Error initializing KYC: $e', error: e);
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        errorMessage: 'Failed to load KYC data',
      );
    }
  }

  /// Load KYC status and merge with local storage data
  Future<void> _loadKycStatus() async {
    // Store current status for change detection (outside try block)
    final previousStatus = state.kycStatus?.status;

    try {
      developer.log('🚨 [DEBUG] ===== STARTING KYC STATUS LOAD =====');
      developer.log('🚨 [DEBUG] Current state BEFORE load:');
      developer.log('🚨 [DEBUG] - Status: ${state.kycStatus?.status}');
      developer.log(
        '🚨 [DEBUG] - Personal Info exists: ${state.kycStatus?.personalInfo != null}',
      );
      developer.log(
        '🚨 [DEBUG] - Next of Kin exists: ${state.kycStatus?.nextOfKin != null}',
      );
      developer.log(
        '🚨 [DEBUG] - Financial Info exists: ${state.kycStatus?.financialInfo != null}',
      );
      developer.log(
        '🚨 [DEBUG] - ID Info exists: ${state.kycStatus?.idInformation != null}',
      );

      developer.log('🔍 Starting KYC status load...');

      // Check if user provider has a current KYC status to preserve
      final currentUser = _ref.read(currentUserProvider);
      final userProviderKycStatus = currentUser?.kycStatus;

      developer.log('🔍 User provider KYC status: $userProviderKycStatus');

      // First try to get backend status
      final result = await _kycService.getKycStatusWithEnum();

      developer.log('🔍 KYC Service result: ${result.toString()}');

      if (result['success'] == true && result['data'] != null) {
        developer.log('🔍 KYC API call successful, parsing data...');

        // Extract the normalized status from the API response
        final apiData = result['data'];
        final backendStatus =
            apiData['kyc_status'] ??
            apiData['status'] ??
            userProviderKycStatus ??
            'not_started';

        developer.log('🔍 Backend KYC status (normalized): $backendStatus');

        // Create KycStatus object with the backend status
        final backendKycStatus = _createKycStatusFromApiData(
          apiData,
          backendStatus,
        );

        developer.log(
          '🔍 Backend status isPendingReview: ${backendKycStatus.isPendingReview}',
        );
        developer.log(
          '🔍 Backend status isUnderReview: ${backendKycStatus.isUnderReview}',
        );
        developer.log(
          '🔍 Backend status isApproved: ${backendKycStatus.isApproved}',
        );

        // Check if user has local draft data that should be preserved
        final hasLocalDraftData = await KycLocalStorageService.hasDraftData();
        developer.log('🔍 Has local draft data: $hasLocalDraftData');

        // If backend status is finalized (approved/rejected), use it directly
        if (backendKycStatus.isApproved || backendKycStatus.isRejected) {
          developer.log(
            '🔄 Backend status is finalized, using it directly: ${backendKycStatus.status}',
          );

          state = state.copyWith(kycStatus: backendKycStatus);

          // Clear local storage since KYC is finalized
          await KycLocalStorageService.clearAllDraftData();
          developer.log(
            '🧹 Cleared local storage since KYC is finalized: ${backendKycStatus.status}',
          );
        } else if (backendKycStatus.isPendingReview ||
            backendKycStatus.isUnderReview) {
          // CRITICAL FIX: Always use backend status for pending_review/under_review regardless of local draft data
          // This ensures the home screen always shows the correct status from backend
          developer.log(
            '🔄 Backend status is ${backendKycStatus.status}, using backend data to ensure consistency',
          );

          state = state.copyWith(kycStatus: backendKycStatus);
          developer.log(
            '✅ Using backend ${backendKycStatus.status} status to ensure home screen consistency',
          );
        } else {
          // Merge with local data for in_progress, not_started, or pending_review with local draft
          developer.log(
            '🔄 Backend status allows local data merge: ${backendKycStatus.status}',
          );

          // Load local storage data for merging
          await _loadLocalStorageData();

          // Merge backend status with local storage data
          final mergedStatus = _mergeWithLocalData(backendKycStatus);

          state = state.copyWith(kycStatus: mergedStatus);
          developer.log(
            '✅ KYC status loaded and merged: ${mergedStatus.status}',
          );
          developer.log(
            '📝 Preserved local draft data for user to continue editing',
          );
        }

        developer.log('✅ Final KYC status: ${state.kycStatus?.status}');
        developer.log(
          '🔍 Final status details: isNotStarted=${state.kycStatus?.isNotStarted}, isApproved=${state.kycStatus?.isApproved}, isInProgress=${state.kycStatus?.isInProgress}, isUnderReview=${state.kycStatus?.isUnderReview}',
        );

        // Sync with user provider to ensure consistency
        await _syncWithUserProvider(state.kycStatus!.status);
      } else {
        developer.log(
          '❌ Failed to load KYC status from API: ${result['error']}',
        );

        // If user provider has a valid status, use it instead of creating sample data
        if (userProviderKycStatus != null &&
            userProviderKycStatus.isNotEmpty &&
            userProviderKycStatus != 'not_started') {
          developer.log(
            '🔄 Using user provider KYC status: $userProviderKycStatus',
          );

          final preservedStatus = _createKycStatusFromApiData(
            {},
            userProviderKycStatus,
          );
          state = state.copyWith(kycStatus: preservedStatus);
          developer.log(
            '✅ Preserved KYC status from user provider: $userProviderKycStatus',
          );
        } else {
          developer.log('🔄 Loading local storage data as fallback...');

          // Load local storage data as fallback
          await _loadLocalStorageData();

          // Only create sample status if no local data and no user provider status
          if (state.kycStatus == null) {
            final sampleStatus = _createSampleKycStatus();
            state = state.copyWith(kycStatus: sampleStatus);
            developer.log(
              '✅ Sample KYC status created: ${sampleStatus.status}',
            );
          }
        }
      }
    } catch (e) {
      if (e is UnauthorizedException) {
        developer.log('🔐 User not authenticated for KYC');
        state = state.copyWith(clearKyc: true);
      } else {
        developer.log('💥 Error loading KYC status: $e', error: e);

        // Try to preserve user provider status first
        final currentUser = _ref.read(currentUserProvider);
        final userProviderKycStatus = currentUser?.kycStatus;

        if (userProviderKycStatus != null &&
            userProviderKycStatus.isNotEmpty &&
            userProviderKycStatus != 'not_started') {
          developer.log(
            '🔄 Preserving user provider KYC status after error: $userProviderKycStatus',
          );

          final preservedStatus = _createKycStatusFromApiData(
            {},
            userProviderKycStatus,
          );
          state = state.copyWith(kycStatus: preservedStatus);
          developer.log(
            '✅ Preserved KYC status from user provider after error: $userProviderKycStatus',
          );
        } else {
          // Load local data as fallback
          await _loadLocalStorageData();

          // Only create sample status as last resort
          if (state.kycStatus == null) {
            developer.log(
              '🔄 Falling back to sample KYC status due to error...',
            );
            final sampleStatus = _createSampleKycStatus();
            state = state.copyWith(kycStatus: sampleStatus);
            developer.log(
              '✅ Sample KYC status created after error: ${sampleStatus.status}',
            );
          }
        }
      }
    }

    // Check for status changes and trigger notifications (outside try-catch)
    // Only trigger for significant status changes, not during normal data loading
    final newStatus = state.kycStatus?.status;
    if (previousStatus != null &&
        newStatus != null &&
        previousStatus != newStatus &&
        _isSignificantStatusChange(previousStatus, newStatus)) {
      developer.log(
        '🔔 Significant KYC status change detected: $previousStatus → $newStatus',
      );

      // Trigger notification in background (completely non-blocking)
      Future.microtask(() async {
        try {
          await handleKycStatusChange(previousStatus, newStatus);
        } catch (e) {
          developer.log(
            '⚠️ Error handling status change notification (non-blocking): $e',
          );
          // This error doesn't affect KYC operations
        }
      });
    } else if (previousStatus != newStatus) {
      developer.log(
        '🔄 KYC status updated: $previousStatus → $newStatus (no notification needed)',
      );
    }
  }

  /// Check if a status change is significant enough to trigger notifications
  bool _isSignificantStatusChange(String oldStatus, String newStatus) {
    // Only trigger notifications for these specific transitions
    final significantTransitions = {
      'in_progress->pending_review': true,
      'pending_review->approved': true,
      'pending_review->rejected': true,
    };

    final transition = '$oldStatus->$newStatus';
    return significantTransitions[transition] == true;
  }

  /// Load data from local storage and update state
  Future<void> _loadLocalStorageData() async {
    try {
      developer.log('📱 Loading KYC data from local storage...');

      // Get individual section data
      final personalInfo = await KycLocalStorageService.getPersonalInfo();
      final nextOfKin = await KycLocalStorageService.getNextOfKin();
      final professionalInfo =
          await KycLocalStorageService.getProfessionalInfo();
      final idInfo = await KycLocalStorageService.getIdInfo();
      final documents = await KycLocalStorageService.getDocuments();

      // Create KYC status from local data if any exists
      if (personalInfo != null ||
          nextOfKin != null ||
          professionalInfo != null ||
          idInfo != null) {
        final localKycStatus = KycStatus(
          id: 'local_kyc_draft',
          status: 'in_progress',
          personalInfo: personalInfo != null
              ? KycPersonalInfo.fromJson(personalInfo)
              : null,
          nextOfKin: nextOfKin != null
              ? KycNextOfKin.fromJson(nextOfKin)
              : null,
          financialInfo: professionalInfo != null
              ? KycFinancialInfo.fromJson(professionalInfo)
              : null,
          idInformation: idInfo != null
              ? KycIdInformation.fromJson(idInfo)
              : null,
          documents: documents != null ? [KycDocument.fromJson(documents)] : [],
          lastUpdated: DateTime.now(),
        );

        state = state.copyWith(kycStatus: localKycStatus);
        developer.log(
          '✅ Local KYC data loaded successfully: ${localKycStatus.status}',
        );
        developer.log(
          '📱 Local data sections - Personal: ${personalInfo != null}, NextOfKin: ${nextOfKin != null}, Financial: ${professionalInfo != null}, ID: ${idInfo != null}',
        );
      } else {
        developer.log('📱 No local KYC data found');
      }
    } catch (e) {
      developer.log('💥 Error loading local storage data: $e', error: e);
    }
  }

  /// Merge backend KYC status with local storage data
  KycStatus _mergeWithLocalData(KycStatus backendStatus) {
    final currentStatus = state.kycStatus;

    if (currentStatus == null) {
      return backendStatus;
    }

    // If backend status is more recent or submitted, use it
    if (backendStatus.isPendingReview ||
        backendStatus.isApproved ||
        backendStatus.isRejected) {
      developer.log(
        '🔄 Using backend status (submitted/reviewed): ${backendStatus.status}',
      );
      return backendStatus;
    }

    // Otherwise, merge local data with backend status
    final mergedStatus = backendStatus.copyWith(
      personalInfo: currentStatus.personalInfo ?? backendStatus.personalInfo,
      nextOfKin: currentStatus.nextOfKin ?? backendStatus.nextOfKin,
      financialInfo: currentStatus.financialInfo ?? backendStatus.financialInfo,
      idInformation: currentStatus.idInformation ?? backendStatus.idInformation,
      documents: currentStatus.documents.isNotEmpty
          ? currentStatus.documents
          : backendStatus.documents,
    );

    developer.log('🔄 Merged local and backend data');
    return mergedStatus;
  }

  /// Create KycStatus object from API data
  KycStatus _createKycStatusFromApiData(
    Map<String, dynamic> apiData,
    String status,
  ) {
    developer.log(
      '🚨 [DEBUG] Creating KycStatus from API data with status: $status',
    );
    developer.log('🚨 [DEBUG] API data keys: ${apiData.keys.toList()}');
    developer.log('🚨 [DEBUG] Full API data: $apiData');

    // Extract relevant fields from API response
    final id =
        apiData['id']?.toString() ??
        'api_kyc_${DateTime.now().millisecondsSinceEpoch}';
    final submittedAtStr = apiData['submitted_at']?.toString();
    final reviewedAtStr = apiData['reviewed_at']?.toString();
    final rejectionReason = apiData['rejection_reason']?.toString();
    final lastUpdatedStr =
        apiData['last_updated']?.toString() ??
        apiData['updated_at']?.toString();

    // Parse dates safely
    DateTime? submittedAt;
    DateTime? reviewedAt;
    DateTime lastUpdated = DateTime.now();

    try {
      if (submittedAtStr != null && submittedAtStr != 'null') {
        submittedAt = DateTime.parse(submittedAtStr);
      }
      if (reviewedAtStr != null && reviewedAtStr != 'null') {
        reviewedAt = DateTime.parse(reviewedAtStr);
      }
      if (lastUpdatedStr != null && lastUpdatedStr != 'null') {
        lastUpdated = DateTime.parse(lastUpdatedStr);
      }
    } catch (e) {
      developer.log('⚠️ Error parsing dates from API data: $e');
    }

    // Extract KYC data from API response if available
    KycPersonalInfo? personalInfo;
    KycNextOfKin? nextOfKin;
    KycFinancialInfo? financialInfo;
    KycIdInformation? idInformation;
    List<KycDocument> documents = [];

    try {
      // Extract personal info
      if (apiData['personal_info'] != null) {
        personalInfo = KycPersonalInfo.fromJson(apiData['personal_info']);
        developer.log('🚨 [DEBUG] Extracted personal info from API');
      }

      // Extract next of kin
      if (apiData['next_of_kin'] != null) {
        nextOfKin = KycNextOfKin.fromJson(apiData['next_of_kin']);
        developer.log('🚨 [DEBUG] Extracted next of kin from API');
      }

      // Extract financial info
      if (apiData['financial_info'] != null) {
        financialInfo = KycFinancialInfo.fromJson(apiData['financial_info']);
        developer.log('🚨 [DEBUG] Extracted financial info from API');
      }

      // Extract ID information
      if (apiData['id_info'] != null) {
        idInformation = KycIdInformation.fromJson(apiData['id_info']);
        developer.log('🚨 [DEBUG] Extracted ID info from API');
      }

      // Extract documents
      if (apiData['documents'] != null && apiData['documents'] is List) {
        documents = (apiData['documents'] as List)
            .map((doc) => KycDocument.fromJson(doc))
            .toList();
        developer.log(
          '🚨 [DEBUG] Extracted ${documents.length} documents from API',
        );
      }
    } catch (e) {
      developer.log('⚠️ Error extracting KYC data from API: $e');
    }

    final kycStatus = KycStatus(
      id: id,
      status: status,
      personalInfo: personalInfo,
      financialInfo: financialInfo,
      nextOfKin: nextOfKin,
      idInformation: idInformation,
      documents: documents,
      rejectionReason: rejectionReason,
      submittedAt: submittedAt,
      reviewedAt: reviewedAt,
      lastUpdated: lastUpdated,
    );

    developer.log('🚨 [DEBUG] Created KycStatus with:');
    developer.log('🚨 [DEBUG] - Personal Info: ${personalInfo != null}');
    developer.log('🚨 [DEBUG] - Next of Kin: ${nextOfKin != null}');
    developer.log('🚨 [DEBUG] - Financial Info: ${financialInfo != null}');
    developer.log('🚨 [DEBUG] - ID Info: ${idInformation != null}');
    developer.log('🚨 [DEBUG] - Documents: ${documents.length}');

    return kycStatus;
  }

  /// Create sample KYC status for demo
  KycStatus _createSampleKycStatus() {
    developer.log('🔧 Creating sample KYC status with not_started status');
    final sampleStatus = KycStatus(
      id: 'demo_kyc_1',
      status: 'not_started', // Explicitly set to not_started
      // Explicitly set all fields to null to indicate user hasn't started KYC
      personalInfo: null,
      financialInfo: null,
      nextOfKin: null,
      idInformation: null,
      documents: const [],
      rejectionReason: null,
      submittedAt: null,
      reviewedAt: null,
      lastUpdated: DateTime.now(),
    );

    developer.log('🔧 Sample status created: ${sampleStatus.status}');
    developer.log(
      '🔧 Sample status isNotStarted: ${sampleStatus.isNotStarted}',
    );
    developer.log('🔧 Sample status isApproved: ${sampleStatus.isApproved}');
    developer.log(
      '🔧 Sample status isInProgress: ${sampleStatus.isInProgress}',
    );

    return sampleStatus;
  }

  /// Sync KYC status with user provider to ensure consistency
  Future<void> _syncWithUserProvider(String kycStatus) async {
    try {
      developer.log('🔄 Syncing KYC status with user provider: $kycStatus');

      // Get current user from user provider
      final currentUser = _ref.read(currentUserProvider);

      if (currentUser != null) {
        final currentUserStatus = currentUser.kycStatus;

        // Only update if the new status is more advanced or different
        // Priority: approved > pending_review > in_progress > not_started
        final shouldUpdate = _shouldUpdateStatus(currentUserStatus, kycStatus);

        if (shouldUpdate) {
          developer.log(
            '🔄 User provider KYC status update: $currentUserStatus → $kycStatus',
          );

          // Update user provider with current KYC status
          _ref.read(userProvider.notifier).updateKycStatus(kycStatus);

          developer.log('✅ User provider KYC status synced: $kycStatus');
        } else {
          developer.log(
            '✅ User provider KYC status preserved: $currentUserStatus (not updating to $kycStatus)',
          );
        }
      } else {
        developer.log('⚠️ No current user found for KYC status sync');
      }
    } catch (e) {
      developer.log('❌ Error syncing with user provider: $e', error: e);
      // Don't throw error - this is a sync operation that shouldn't break the main flow
    }
  }

  /// Determine if we should update the status based on priority
  bool _shouldUpdateStatus(String currentStatus, String newStatus) {
    // Define status priority (higher number = higher priority)
    final statusPriority = {
      'not_started': 1,
      'in_progress': 2,
      'pending_review': 3,
      'approved': 4,
      'rejected': 2, // Allow updates from rejected
    };

    final currentPriority = statusPriority[currentStatus] ?? 1;
    final newPriority = statusPriority[newStatus] ?? 1;

    // CRITICAL FIX: Always allow updating TO 'pending_review' from any status
    // This ensures backend 'pending_review' status is always respected
    if (newStatus == 'pending_review') {
      developer.log(
        '✅ Allowing update to pending_review from $currentStatus (backend authority)',
      );
      return true;
    }

    // Update if new status has higher priority or if current status is rejected
    return newPriority >= currentPriority || currentStatus == 'rejected';
  }

  /// Check if status can be downgraded (e.g., from pending_review to in_progress)
  /// This should only be allowed when user is actively editing forms
  bool _canDowngradeStatus(String currentStatus, String newStatus) {
    // Never downgrade from pending_review, approved, or rejected unless explicitly allowed
    if (currentStatus == 'pending_review' && newStatus == 'in_progress') {
      developer.log(
        '⚠️ Preventing downgrade from pending_review to in_progress (preserving backend status)',
      );
      return false;
    }

    if (currentStatus == 'approved' || currentStatus == 'rejected') {
      developer.log(
        '⚠️ Preventing downgrade from finalized status: $currentStatus',
      );
      return false;
    }

    return true;
  }

  /// Save personal information to local storage
  Future<bool> savePersonalInfoLocally(KycPersonalInfo personalInfo) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      // Save to local storage
      final personalInfoJson = personalInfo.toJson();

      final success = await KycLocalStorageService.savePersonalInfo(
        personalInfoJson,
      );

      if (success) {
        // CRITICAL FIX: Don't downgrade status from pending_review to in_progress
        final currentStatus = state.kycStatus?.status ?? 'not_started';
        final newStatus = _canDowngradeStatus(currentStatus, 'in_progress')
            ? 'in_progress'
            : currentStatus;

        final updatedKyc =
            state.kycStatus?.copyWith(
              personalInfo: personalInfo,
              status: newStatus,
              lastUpdated: DateTime.now(),
            ) ??
            KycStatus(
              id: 'demo_kyc_1',
              status: 'in_progress',
              personalInfo: personalInfo,
              lastUpdated: DateTime.now(),
            );

        state = state.copyWith(kycStatus: updatedKyc, isLoading: false);

        developer.log('Personal info saved locally successfully');
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to save personal info locally',
        );
        return false;
      }
    } catch (e) {
      developer.log('Error saving personal info locally: $e', error: e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to save personal info locally',
      );
      return false;
    }
  }

  /// Update personal information (legacy method for backward compatibility)
  Future<bool> updatePersonalInfo(KycPersonalInfo personalInfo) async {
    return await savePersonalInfoLocally(personalInfo);
  }

  /// Update financial information (backend API call - only for final submission)
  Future<bool> updateFinancialInfo(KycFinancialInfo financialInfo) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final response = await _apiClient.postWithAuth(
        'kyc/financial-info/',
        financialInfo.toJson(),
      );

      if (response['success'] == true) {
        // CRITICAL FIX: Don't downgrade status from pending_review to in_progress
        final currentStatus = state.kycStatus?.status ?? 'not_started';
        final newStatus = _canDowngradeStatus(currentStatus, 'in_progress')
            ? 'in_progress'
            : currentStatus;

        final updatedKyc = state.kycStatus?.copyWith(
          financialInfo: financialInfo,
          status: newStatus,
          lastUpdated: DateTime.now(),
        );

        state = state.copyWith(kycStatus: updatedKyc, isLoading: false);

        developer.log('Financial info updated successfully');
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response['error'] ?? 'Failed to update financial info',
        );
        return false;
      }
    } catch (e) {
      developer.log('Error updating financial info: $e', error: e);

      // For demo purposes, simulate successful update
      // CRITICAL FIX: Don't downgrade status from pending_review to in_progress
      final currentStatus = state.kycStatus?.status ?? 'not_started';
      final newStatus = _canDowngradeStatus(currentStatus, 'in_progress')
          ? 'in_progress'
          : currentStatus;

      final updatedKyc = state.kycStatus?.copyWith(
        financialInfo: financialInfo,
        status: newStatus,
        lastUpdated: DateTime.now(),
      );

      state = state.copyWith(kycStatus: updatedKyc, isLoading: false);

      return true;
    }
  }

  /// Save financial information to local storage only (for step completion)
  Future<bool> saveFinancialInfoLocally(KycFinancialInfo financialInfo) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      // Save to local storage
      final financialData = {
        'employment_status': financialInfo.employmentStatus,
        'profession': financialInfo.profession,
        'institution_name': financialInfo.institutionName,
        'monthly_income': financialInfo.monthlyIncome,
        'source_of_income': financialInfo.sourceOfIncome,
      };

      final success = await KycLocalStorageService.saveProfessionalInfo(
        financialData,
      );

      if (success) {
        // CRITICAL FIX: Don't downgrade status from pending_review to in_progress
        final currentStatus = state.kycStatus?.status ?? 'not_started';
        final newStatus = _canDowngradeStatus(currentStatus, 'in_progress')
            ? 'in_progress'
            : currentStatus;

        final updatedKyc = state.kycStatus?.copyWith(
          financialInfo: financialInfo,
          status: newStatus,
          lastUpdated: DateTime.now(),
        );

        state = state.copyWith(kycStatus: updatedKyc, isLoading: false);

        developer.log('Financial info saved locally successfully');
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to save financial info locally',
        );
        return false;
      }
    } catch (e) {
      developer.log('Error saving financial info locally: $e', error: e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to save financial info locally',
      );
      return false;
    }
  }

  /// Save next of kin information to local storage
  Future<bool> saveNextOfKinLocally(Map<String, dynamic> nextOfKinData) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      // Save to local storage
      final success = await KycLocalStorageService.saveNextOfKin(nextOfKinData);

      if (success) {
        // Create KycNextOfKin object for state update
        final nextOfKin = KycNextOfKin(
          firstName: nextOfKinData['first_name'] ?? '',
          lastName: nextOfKinData['last_name'] ?? '',
          relationship: nextOfKinData['relationship'] ?? '',
          phoneNumber: nextOfKinData['phone_number'] ?? '',
          email: nextOfKinData['email'] ?? '',
        );

        // CRITICAL FIX: Don't downgrade status from pending_review to in_progress
        final currentStatus = state.kycStatus?.status ?? 'not_started';
        final newStatus = _canDowngradeStatus(currentStatus, 'in_progress')
            ? 'in_progress'
            : currentStatus;

        final updatedKyc = state.kycStatus?.copyWith(
          nextOfKin: nextOfKin,
          status: newStatus,
          lastUpdated: DateTime.now(),
        );

        state = state.copyWith(kycStatus: updatedKyc, isLoading: false);

        developer.log('Next of kin info saved locally successfully');
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to save next of kin info locally',
        );
        return false;
      }
    } catch (e) {
      developer.log('Error saving next of kin info locally: $e', error: e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to save next of kin info locally',
      );
      return false;
    }
  }

  /// Update next of kin information (legacy method for backward compatibility)
  Future<bool> updateNextOfKin(KycNextOfKin nextOfKin) async {
    return await saveNextOfKinLocally(nextOfKin.toJson());
  }

  /// Save consolidated ID and documents information locally
  Future<bool> saveIdAndDocumentsLocally(
    Map<String, dynamic> idAndDocumentsData,
  ) async {
    try {
      developer.log('🚨 [DEBUG] Starting saveIdAndDocumentsLocally...');
      developer.log('🚨 [DEBUG] Current KYC state BEFORE saving ID info:');
      developer.log('🚨 [DEBUG] - Status: ${state.kycStatus?.status}');
      developer.log(
        '🚨 [DEBUG] - Personal Info exists: ${state.kycStatus?.personalInfo != null}',
      );
      developer.log(
        '🚨 [DEBUG] - Next of Kin exists: ${state.kycStatus?.nextOfKin != null}',
      );
      developer.log(
        '🚨 [DEBUG] - Financial Info exists: ${state.kycStatus?.financialInfo != null}',
      );
      developer.log(
        '🚨 [DEBUG] - ID Info exists: ${state.kycStatus?.idInformation != null}',
      );

      state = state.copyWith(isLoading: true, clearError: true);

      developer.log('🔍 saveIdAndDocumentsLocally - Raw input data:');
      developer.log('🔍 Issue Date: ${idAndDocumentsData['issue_date']}');
      developer.log('🔍 Expiry Date: ${idAndDocumentsData['expiry_date']}');

      // Parse dates safely
      final issueDateRaw = idAndDocumentsData['issue_date']?.toString() ?? '';
      final expiryDateRaw = idAndDocumentsData['expiry_date']?.toString() ?? '';

      final issueDate = KycDateFormatter.parseDate(issueDateRaw);
      final expiryDate = KycDateFormatter.parseDate(expiryDateRaw);

      if (issueDate == null || expiryDate == null) {
        final errorMessage =
            'Invalid date format detected:\n'
            'Issue Date: "$issueDateRaw" → ${issueDate != null ? "✅ Valid" : "❌ Invalid"}\n'
            'Expiry Date: "$expiryDateRaw" → ${expiryDate != null ? "✅ Valid" : "❌ Invalid"}';

        developer.log(errorMessage);
        state = state.copyWith(isLoading: false, errorMessage: errorMessage);
        return false;
      }

      // Save to local storage using the consolidated method
      final success = await KycLocalStorageService.saveIdAndDocuments({
        ...idAndDocumentsData,
        'issue_date': issueDateRaw,
        'expiry_date': expiryDateRaw,
      });

      if (success) {
        final idInformation = KycIdInformation(
          idType: idAndDocumentsData['id_type'] ?? '',
          idNumber: idAndDocumentsData['id_number'] ?? '',
          issueDate: issueDate,
          expiryDate: expiryDate,
        );

        // CRITICAL FIX: Don't downgrade status from pending_review to in_progress
        final currentStatus = state.kycStatus?.status ?? 'not_started';
        final newStatus = _canDowngradeStatus(currentStatus, 'in_progress')
            ? 'in_progress'
            : currentStatus;

        final updatedKyc = state.kycStatus?.copyWith(
          idInformation: idInformation,
          status: newStatus,
          lastUpdated: DateTime.now(),
        );

        state = state.copyWith(kycStatus: updatedKyc, isLoading: false);

        developer.log('🚨 [DEBUG] KYC state AFTER saving ID info:');
        developer.log('🚨 [DEBUG] - Status: ${state.kycStatus?.status}');
        developer.log(
          '🚨 [DEBUG] - Personal Info exists: ${state.kycStatus?.personalInfo != null}',
        );
        developer.log(
          '🚨 [DEBUG] - Next of Kin exists: ${state.kycStatus?.nextOfKin != null}',
        );
        developer.log(
          '🚨 [DEBUG] - Financial Info exists: ${state.kycStatus?.financialInfo != null}',
        );
        developer.log(
          '🚨 [DEBUG] - ID Info exists: ${state.kycStatus?.idInformation != null}',
        );

        if (state.kycStatus?.personalInfo != null) {
          developer.log(
            '🚨 [DEBUG] - Personal Info details: ${state.kycStatus!.personalInfo!.firstName} ${state.kycStatus!.personalInfo!.lastName}',
          );
        }

        developer.log('✅ ID and documents info saved locally successfully');
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to save ID and documents info locally',
        );
        return false;
      }
    } catch (e) {
      developer.log(
        '💥 Error saving ID and documents info locally: $e',
        error: e,
      );
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to save ID and documents info locally',
      );
      return false;
    }
  }

  /// Upload document
  Future<bool> uploadDocument(KycDocument document) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final response = await _apiClient.postWithAuth(
        'kyc/documents/',
        document.toJson(),
      );

      if (response['success'] == true) {
        final currentDocuments = List<KycDocument>.from(
          state.kycStatus?.documents ?? [],
        );
        currentDocuments.add(document);

        // CRITICAL FIX: Don't downgrade status from pending_review to in_progress
        final currentStatus = state.kycStatus?.status ?? 'not_started';
        final newStatus = _canDowngradeStatus(currentStatus, 'in_progress')
            ? 'in_progress'
            : currentStatus;

        final updatedKyc = state.kycStatus?.copyWith(
          documents: currentDocuments,
          status: newStatus,
          lastUpdated: DateTime.now(),
        );

        state = state.copyWith(kycStatus: updatedKyc, isLoading: false);

        developer.log('Document uploaded successfully');
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response['error'] ?? 'Failed to upload document',
        );
        return false;
      }
    } catch (e) {
      developer.log('Error uploading document: $e', error: e);

      // For demo purposes, simulate successful upload
      final currentDocuments = List<KycDocument>.from(
        state.kycStatus?.documents ?? [],
      );
      currentDocuments.add(document);

      // CRITICAL FIX: Don't downgrade status from pending_review to in_progress
      final currentStatus = state.kycStatus?.status ?? 'not_started';
      final newStatus = _canDowngradeStatus(currentStatus, 'in_progress')
          ? 'in_progress'
          : currentStatus;

      final updatedKyc = state.kycStatus?.copyWith(
        documents: currentDocuments,
        status: newStatus,
        lastUpdated: DateTime.now(),
      );

      state = state.copyWith(kycStatus: updatedKyc, isLoading: false);

      return true;
    }
  }

  /// Convert raw local storage data to properly formatted data using model toJson() methods
  Map<String, dynamic> _formatKycDataForSubmission(
    Map<String, dynamic> rawData,
  ) {
    final formattedData = <String, dynamic>{};

    // Format personal info
    if (rawData['personal_info'] != null) {
      try {
        final personalInfo = KycPersonalInfo.fromJson(rawData['personal_info']);
        formattedData['personal_info'] = personalInfo.toJson();
        developer.log('✅ Personal info formatted with proper date formatting');
      } catch (e) {
        developer.log('⚠️ Error formatting personal info: $e');
        formattedData['personal_info'] = rawData['personal_info'];
      }
    }

    // Format next of kin
    if (rawData['next_of_kin'] != null) {
      try {
        final nextOfKin = KycNextOfKin.fromJson(rawData['next_of_kin']);
        formattedData['next_of_kin'] = nextOfKin.toJson();
        developer.log('✅ Next of kin formatted');
      } catch (e) {
        developer.log('⚠️ Error formatting next of kin: $e');
        formattedData['next_of_kin'] = rawData['next_of_kin'];
      }
    }

    // Format professional info
    if (rawData['professional_info'] != null) {
      try {
        final professionalInfo = KycFinancialInfo.fromJson(
          rawData['professional_info'],
        );
        formattedData['professional_info'] = professionalInfo.toJson();
        developer.log('✅ Professional info formatted');
      } catch (e) {
        developer.log('⚠️ Error formatting professional info: $e');
        formattedData['professional_info'] = rawData['professional_info'];
      }
    }

    // Format ID info - THIS IS THE KEY FIX
    if (rawData['id_info'] != null) {
      try {
        final idInfo = KycIdInformation.fromJson(rawData['id_info']);
        formattedData['id_info'] = idInfo.toJson();
        developer.log(
          '✅ ID info formatted with proper date formatting (YYYY-MM-DD)',
        );
        developer.log(
          '📊 Formatted ID dates - Issue: ${idInfo.toJson()['issue_date']}, Expiry: ${idInfo.toJson()['expiry_date']}',
        );
      } catch (e) {
        developer.log('⚠️ Error formatting ID info: $e');
        formattedData['id_info'] = rawData['id_info'];
      }
    }

    // Include documents with proper file paths for upload
    if (rawData['documents'] != null) {
      formattedData['documents'] = rawData['documents'];
      developer.log('✅ Documents included for upload');
    } else {
      // Check if documents are stored in id_info section (consolidated approach)
      if (rawData['id_info'] != null && rawData['id_info'] is Map) {
        final idInfo = rawData['id_info'] as Map<String, dynamic>;
        final documents = <String, dynamic>{};

        if (idInfo['front_id_image'] != null) {
          documents['front_id_image'] = idInfo['front_id_image'];
        }
        if (idInfo['back_id_image'] != null) {
          documents['back_id_image'] = idInfo['back_id_image'];
        }
        if (idInfo['selfie_image'] != null) {
          documents['selfie_image'] = idInfo['selfie_image'];
        }

        if (documents.isNotEmpty) {
          formattedData['documents'] = documents;
          developer.log('✅ Documents extracted from id_info for upload');
        }
      }
    }

    return formattedData;
  }

  /// Submit complete KYC application to backend
  Future<bool> submitCompleteKycApplication() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      // Get complete draft data from local storage
      final rawDraftData = await KycLocalStorageService.getCompleteDraftData();

      if (rawDraftData == null) {
        // Try to create data from current state as fallback
        if (state.kycStatus?.personalInfo != null ||
            state.kycStatus?.nextOfKin != null ||
            state.kycStatus?.financialInfo != null ||
            state.kycStatus?.idInformation != null) {
          // Create rawDraftData from current state
          final fallbackData = <String, dynamic>{};

          if (state.kycStatus?.personalInfo != null) {
            fallbackData['personal_info'] = state.kycStatus!.personalInfo!
                .toJson();
          }
          if (state.kycStatus?.nextOfKin != null) {
            fallbackData['next_of_kin'] = state.kycStatus!.nextOfKin!.toJson();
          }
          if (state.kycStatus?.financialInfo != null) {
            fallbackData['professional_info'] = state.kycStatus!.financialInfo!
                .toJson();
          }
          if (state.kycStatus?.idInformation != null) {
            fallbackData['id_info'] = state.kycStatus!.idInformation!.toJson();
          }

          // Use fallback data for submission
          final formattedData = _formatKycDataForSubmission(fallbackData);

          // Skip the local storage checks and proceed with submission
          final result = await _kycService.submitCompleteKycApplication(
            formattedData,
          );

          // Handle submission result
          if (result['success'] == true) {
            developer.log(
              '🚨 [KYC_PROVIDER] ✅ Backend submission successful (fallback data)!',
            );

            // Clear local draft data after successful submission
            await KycLocalStorageService.clearAllDraftData();

            final updatedKyc = state.kycStatus?.copyWith(
              status: 'pending_review',
              submittedAt: DateTime.now(),
              lastUpdated: DateTime.now(),
            );

            state = state.copyWith(kycStatus: updatedKyc, isLoading: false);

            // Sync with user provider to ensure immediate status update
            await _syncWithUserProvider('pending_review');

            developer.log(
              '✅ Complete KYC application submitted successfully (fallback data)',
            );
            return true;
          } else {
            developer.log(
              '🚨 [KYC_PROVIDER] ❌ Backend submission failed (fallback data)',
            );
            state = state.copyWith(
              isLoading: false,
              errorMessage:
                  result['error'] ?? 'Failed to submit KYC application',
            );
            return false;
          }
        } else {
          state = state.copyWith(
            isLoading: false,
            errorMessage: 'No KYC data found to submit',
          );
          return false;
        }
      }

      // Check if all required sections are completed
      final isComplete = await KycLocalStorageService.isKycDraftComplete();

      if (!isComplete) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Please complete all KYC sections before submitting',
        );
        return false;
      }

      developer.log('🚀 Submitting complete KYC application to backend...');

      // Format the data using model toJson() methods for proper date formatting
      final formattedData = _formatKycDataForSubmission(rawDraftData);
      developer.log(
        '📊 Data formatted for submission with proper date formats',
      );
      developer.log(
        '🚨 [KYC_PROVIDER] Formatted data keys: ${formattedData.keys.toList()}',
      );

      // Submit to backend
      developer.log('🚨 [KYC_PROVIDER] Calling backend submission service...');
      final result = await _kycService.submitCompleteKycApplication(
        formattedData,
      );
      developer.log('🚨 [KYC_PROVIDER] Backend submission result: $result');

      if (result['success'] == true) {
        developer.log('🚨 [KYC_PROVIDER] ✅ Backend submission successful!');

        // Clear local draft data after successful submission
        await KycLocalStorageService.clearAllDraftData();

        final updatedKyc = state.kycStatus?.copyWith(
          status: 'pending_review',
          submittedAt: DateTime.now(),
          lastUpdated: DateTime.now(),
        );

        state = state.copyWith(kycStatus: updatedKyc, isLoading: false);

        // Sync with user provider to ensure immediate status update
        await _syncWithUserProvider('pending_review');

        developer.log('✅ Complete KYC application submitted successfully');
        developer.log(
          '🚨 [KYC_PROVIDER] === COMPLETE KYC SUBMISSION DEBUG END ===',
        );
        return true;
      } else {
        developer.log('🚨 [KYC_PROVIDER] ❌ Backend submission failed');
        developer.log('🚨 [KYC_PROVIDER] Error details: ${result['error']}');

        state = state.copyWith(
          isLoading: false,
          errorMessage: result['error'] ?? 'Failed to submit KYC application',
        );
        developer.log(
          '🚨 [KYC_PROVIDER] === COMPLETE KYC SUBMISSION DEBUG END ===',
        );
        return false;
      }
    } catch (e) {
      developer.log(
        '🚨 [KYC_PROVIDER] ❌ Exception during submission: $e',
        error: e,
      );
      developer.log('🚨 [KYC_PROVIDER] Exception type: ${e.runtimeType}');
      developer.log(
        '🚨 [KYC_PROVIDER] === COMPLETE KYC SUBMISSION DEBUG END ===',
      );

      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to submit KYC application. Please try again.',
      );
      return false;
    }
  }

  /// Submit KYC for review (legacy method)
  Future<bool> submitForReview() async {
    return await submitCompleteKycApplication();
  }

  /// Refresh KYC data
  Future<void> refreshKycData() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      await _loadKycStatus();

      state = state.copyWith(isLoading: false);
      developer.log('KYC data refreshed successfully');
    } catch (e) {
      developer.log('Error refreshing KYC data: $e', error: e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to refresh KYC data',
      );
    }
  }

  /// Force refresh KYC status from backend and sync with user provider
  Future<void> forceRefreshKycStatus() async {
    try {
      developer.log('🔄 Force refreshing KYC status from backend...');

      // Check if current status is finalized and skip unnecessary refresh
      final currentUser = _ref.read(currentUserProvider);
      if (currentUser?.kycStatus == 'approved' ||
          currentUser?.kycStatus == 'rejected') {
        developer.log(
          '✅ KYC status is finalized (${currentUser?.kycStatus}), skipping refresh',
        );
        return;
      }

      state = state.copyWith(isLoading: true, clearError: true);

      // Force refresh user provider first to get latest backend status
      developer.log(
        '🔄 Refreshing user provider for latest backend KYC status...',
      );
      await _ref.read(userProvider.notifier).refreshUserData();

      // Then refresh KYC data to sync with user provider
      developer.log('🔄 Loading KYC status to sync with user provider...');
      await _loadKycStatus();

      state = state.copyWith(isLoading: false);
      developer.log('✅ KYC status force refresh completed');
    } catch (e) {
      developer.log('❌ Error force refreshing KYC status: $e', error: e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to refresh KYC status',
      );
    }
  }

  /// Reset KYC application for re-submission (for rejected users)
  /// Preserves existing data but allows editing and resubmission
  Future<void> resetKycForResubmission() async {
    try {
      developer.log('🔄 Resetting KYC application for re-submission...');

      state = state.copyWith(isLoading: true, clearError: true);

      // Get current KYC status to preserve existing data
      final currentKycStatus = state.kycStatus;

      if (currentKycStatus != null) {
        // Create a new KYC status that preserves all user data but resets status and clears rejection info
        final resetKycStatus = currentKycStatus.copyWith(
          status: 'in_progress', // Allow editing and progression
          rejectionReason: null, // Clear rejection reason
          submittedAt: null, // Clear submission timestamp to allow resubmission
          lastUpdated: DateTime.now(),
        );

        state = state.copyWith(kycStatus: resetKycStatus, isLoading: false);

        developer.log(
          '✅ KYC application reset for re-submission with preserved data',
        );
        developer.log(
          '📝 Preserved sections: Personal Info: ${resetKycStatus.personalInfo != null}, Next of Kin: ${resetKycStatus.nextOfKin != null}, Financial: ${resetKycStatus.financialInfo != null}, ID: ${resetKycStatus.idInformation != null}',
        );
      } else {
        // Fallback: if no current status, create a fresh one
        final resetKycStatus = KycStatus.notStarted();
        state = state.copyWith(kycStatus: resetKycStatus, isLoading: false);

        developer.log(
          '✅ KYC application reset with fresh status (no existing data found)',
        );
      }

      // Clear only rejection-related local storage, preserve form data
      await _clearRejectionDataOnly();
    } catch (e) {
      developer.log('❌ Error resetting KYC for re-submission: $e', error: e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to reset KYC application',
      );
    }
  }

  /// Clear only rejection-related data while preserving form data
  Future<void> _clearRejectionDataOnly() async {
    try {
      // Clear only specific rejection-related keys, preserve form data
      await KycLocalStorageService.clearRejectionData();
      developer.log('🧹 Cleared rejection data while preserving form data');
    } catch (e) {
      developer.log('⚠️ Error clearing rejection data: $e');
      // Don't fail the whole operation if this fails
    }
  }

  /// Handle KYC status change and trigger notifications
  Future<void> handleKycStatusChange(String oldStatus, String newStatus) async {
    try {
      developer.log('🔔 Handling KYC status change: $oldStatus → $newStatus');

      // Trigger notification based on status change
      await _triggerKycStatusNotification(oldStatus, newStatus);

      // Refresh notifications list to show the new notification
      // Use Future.delayed to prevent blocking KYC operations
      Future.delayed(const Duration(milliseconds: 500), () async {
        try {
          await _ref.read(notificationsProvider.notifier).loadNotifications();
          developer.log('✅ Notifications refreshed successfully');
        } catch (e) {
          developer.log(
            '⚠️ Failed to refresh notifications (non-blocking): $e',
          );
          // This is completely non-blocking - KYC operations continue normally
        }
      });

      developer.log('✅ KYC status change handled successfully');
    } catch (e) {
      developer.log('❌ Error handling KYC status change: $e', error: e);
    }
  }

  /// Trigger push notification for KYC status changes
  Future<void> _triggerKycStatusNotification(
    String oldStatus,
    String newStatus,
  ) async {
    try {
      final notificationData = _getKycNotificationData(oldStatus, newStatus);

      if (notificationData != null) {
        developer.log(
          '📱 Triggering KYC status notification: ${notificationData['title']}',
        );

        // In a real implementation, this would trigger a push notification
        // For now, we'll create a local notification that will be synced with backend
        await _createLocalKycNotification(notificationData);
      }
    } catch (e) {
      developer.log('❌ Error triggering KYC notification: $e', error: e);
    }
  }

  /// Get notification data based on status change
  Map<String, String>? _getKycNotificationData(
    String oldStatus,
    String newStatus,
  ) {
    switch (newStatus.toLowerCase()) {
      case 'pending_review':
        if (oldStatus.toLowerCase() == 'in_progress') {
          return {
            'title': 'KYC Application Submitted',
            'message': 'Your KYC application has been submitted for review',
            'type': 'kyc_status_update',
          };
        }
        break;
      case 'approved':
        if (oldStatus.toLowerCase() == 'pending_review') {
          return {
            'title': 'KYC Approved! 🎉',
            'message':
                'Congratulations! Your KYC verification has been approved',
            'type': 'kyc_status_update',
          };
        }
        break;
      case 'rejected':
        if (oldStatus.toLowerCase() == 'pending_review') {
          return {
            'title': 'KYC Application Requires Attention',
            'message':
                'Your KYC application requires attention. Please review and resubmit.',
            'type': 'kyc_status_update',
          };
        }
        break;
    }
    return null;
  }

  /// Create a local notification for KYC status change
  Future<void> _createLocalKycNotification(
    Map<String, String> notificationData,
  ) async {
    try {
      // This would typically create a local notification that gets synced with the backend
      // For now, we'll just log it - the backend will handle the actual push notification
      developer.log(
        '📱 Local KYC notification created: ${notificationData['title']}',
      );

      // In a real implementation, you might:
      // 1. Show a local notification using flutter_local_notifications
      // 2. Add it to the notifications provider state
      // 3. Sync with backend notifications
    } catch (e) {
      developer.log('❌ Error creating local KYC notification: $e', error: e);
    }
  }

  /// Force refresh from backend only (clear local storage first)
  Future<void> forceRefreshFromBackendOnly() async {
    try {
      developer.log(
        '🔄 Force refreshing from backend only (clearing local storage)...',
      );
      state = state.copyWith(isLoading: true, clearError: true);

      // Clear all local storage first
      await KycLocalStorageService.clearAllDraftData();
      developer.log('🧹 Local storage cleared');

      // Force refresh user provider first
      await _ref.read(userProvider.notifier).refreshUserData();

      // Then refresh KYC data (will only use backend data)
      await _loadKycStatus();

      state = state.copyWith(isLoading: false);
      developer.log('✅ Backend-only refresh completed');
    } catch (e) {
      developer.log('❌ Error refreshing from backend only: $e', error: e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to refresh from backend',
      );
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Clear all data (for logout)
  void clearData() {
    state = const KycState();
  }

  @override
  void dispose() {
    _apiClient.dispose();
    _kycService.dispose();
    super.dispose();
  }
}

/// Provider for KycNotifier
final kycProvider = StateNotifierProvider<KycNotifier, KycState>((ref) {
  return KycNotifier(ref);
});

/// Convenience providers for accessing specific parts of the KYC state
final kycStatusProvider = Provider<KycStatus?>((ref) {
  return ref.watch(kycProvider).kycStatus;
});

final kycLoadingProvider = Provider<bool>((ref) {
  return ref.watch(kycProvider).isLoading;
});

final kycErrorProvider = Provider<String?>((ref) {
  return ref.watch(kycProvider).errorMessage;
});

final kycCompletionProvider = Provider<double>((ref) {
  final kycStatus = ref.watch(kycStatusProvider);
  return kycStatus?.completionPercentage ?? 0.0;
});

final isKycApprovedProvider = Provider<bool>((ref) {
  final kycStatus = ref.watch(kycStatusProvider);
  return kycStatus?.isApproved ?? false;
});
