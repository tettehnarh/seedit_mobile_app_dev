import 'dart:developer' as developer;
import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/storage_utils.dart';

/// Service for handling KYC-related API calls
class KycService {
  final ApiClient _apiClient = ApiClient();

  /// Get KYC status using event-driven approach
  Future<Map<String, dynamic>> getKycStatus({
    String operationType = 'login',
  }) async {
    try {
      developer.log(
        '🔍 KYC Service: Fetching KYC status for operation: $operationType',
      );

      final endpoint =
          '${ApiConstants.kycEventStatusEndpoint}?operation_type=$operationType';
      developer.log('🔍 KYC Service: API endpoint: $endpoint');

      final response = await _apiClient.get(endpoint);

      developer.log(
        '🔍 KYC Service: API response received: ${response.toString()}',
      );

      // Normalize the response to ensure consistent field names
      final normalizedResponse = _normalizeKycStatusResponse(response);

      // Cache the KYC status locally using the normalized status
      final statusValue =
          normalizedResponse['kyc_status'] ?? normalizedResponse['status'];
      if (statusValue != null) {
        await StorageUtils.setString('kyc_status', statusValue);
        developer.log('✅ KYC status cached: $statusValue');
      } else {
        developer.log('⚠️ No status field in API response');
      }

      final result = {'success': true, 'data': normalizedResponse};
      developer.log(
        '✅ KYC Service: Returning successful result: ${result.toString()}',
      );
      return result;
    } catch (e) {
      developer.log('💥 Error fetching KYC status: $e', error: e);

      // Return cached status if API fails
      final cachedStatus = await StorageUtils.getString('kyc_status');
      if (cachedStatus != null) {
        developer.log('🔄 Using cached KYC status: $cachedStatus');
        return {
          'success': true,
          'data': {
            'kyc_status': cachedStatus,
            'status': cachedStatus,
            'cached': true,
          },
        };
      }

      developer.log('❌ No cached status available');

      if (e is ApiException) {
        developer.log('❌ API Exception: ${e.message}');
        return {'success': false, 'error': e.message};
      }

      developer.log('❌ Generic error occurred');
      return {
        'success': false,
        'error': 'Failed to fetch KYC status. Please try again.',
      };
    }
  }

  /// Verify KYC for critical operations
  Future<Map<String, dynamic>> verifyKycForOperation({
    required String operationType,
    Map<String, dynamic>? operationData,
  }) async {
    try {
      developer.log('Verifying KYC for operation: $operationType');

      final data = {
        'operation_type': operationType,
        if (operationData != null) 'operation_data': operationData,
      };

      final response = await _apiClient.postWithAuth(
        ApiConstants.kycEventVerifyEndpoint,
        data,
      );

      return {'success': true, 'data': response};
    } catch (e) {
      developer.log('Error verifying KYC for operation: $e', error: e);

      if (e is ApiException) {
        return {'success': false, 'error': e.message};
      }

      return {
        'success': false,
        'error': 'KYC verification failed. Please try again.',
      };
    }
  }

  /// Submit personal information
  Future<Map<String, dynamic>> submitPersonalInfo(
    Map<String, dynamic> personalData,
  ) async {
    try {
      developer.log('Submitting personal information');

      final response = await _apiClient.postWithAuth(
        ApiConstants.kycPersonalInfoEndpoint,
        personalData,
      );

      return {
        'success': true,
        'data': response,
        'message': 'Personal information saved successfully',
      };
    } catch (e) {
      developer.log('Error submitting personal info: $e', error: e);

      if (e is ApiException) {
        return {'success': false, 'error': e.message};
      }

      return {
        'success': false,
        'error': 'Failed to save personal information. Please try again.',
      };
    }
  }

  /// Submit next of kin information
  Future<Map<String, dynamic>> submitNextOfKin(
    Map<String, dynamic> nextOfKinData,
  ) async {
    try {
      developer.log('Submitting next of kin information');

      final response = await _apiClient.postWithAuth(
        ApiConstants.kycNextOfKinEndpoint,
        nextOfKinData,
      );

      return {
        'success': true,
        'data': response,
        'message': 'Next of kin information saved successfully',
      };
    } catch (e) {
      developer.log('Error submitting next of kin info: $e', error: e);

      if (e is ApiException) {
        return {'success': false, 'error': e.message};
      }

      return {
        'success': false,
        'error': 'Failed to save next of kin information. Please try again.',
      };
    }
  }

  /// Submit professional and financial information
  Future<Map<String, dynamic>> submitProfessionalInfo(
    Map<String, dynamic> professionalData,
  ) async {
    try {
      developer.log('Submitting professional and financial information');

      final response = await _apiClient.postWithAuth(
        ApiConstants.kycProfessionalInfoEndpoint,
        professionalData,
      );

      return {
        'success': true,
        'data': response,
        'message': 'Professional information saved successfully',
      };
    } catch (e) {
      developer.log('Error submitting professional info: $e', error: e);

      if (e is ApiException) {
        return {'success': false, 'error': e.message};
      }

      return {
        'success': false,
        'error': 'Failed to save professional information. Please try again.',
      };
    }
  }

  /// Submit ID information and documents
  Future<Map<String, dynamic>> submitIdInfo(Map<String, dynamic> idData) async {
    try {
      developer.log('Submitting ID information');

      final response = await _apiClient.postWithAuth(
        ApiConstants.kycIdInfoEndpoint,
        idData,
      );

      return {
        'success': true,
        'data': response,
        'message': 'ID information saved successfully',
      };
    } catch (e) {
      developer.log('Error submitting ID info: $e', error: e);

      if (e is ApiException) {
        return {'success': false, 'error': e.message};
      }

      return {
        'success': false,
        'error': 'Failed to save ID information. Please try again.',
      };
    }
  }

  /// Submit complete KYC application
  Future<Map<String, dynamic>> submitKycApplication() async {
    try {
      developer.log('Submitting complete KYC application');

      final response = await _apiClient.postWithAuth(
        ApiConstants.kycSubmitEndpoint,
        {},
      );

      // Update cached KYC status
      await StorageUtils.setString('kyc_status', 'pending_review');

      return {
        'success': true,
        'data': response,
        'message': 'KYC application submitted successfully',
      };
    } catch (e) {
      developer.log('Error submitting KYC application: $e', error: e);

      if (e is ApiException) {
        return {'success': false, 'error': e.message};
      }

      return {
        'success': false,
        'error': 'Failed to submit KYC application. Please try again.',
      };
    }
  }

  /// Get KYC application data (for read-only display)
  Future<Map<String, dynamic>> getKycApplicationData() async {
    try {
      developer.log('Fetching KYC application data');

      // Get data from all KYC sections
      final personalInfo = await _apiClient.get(
        ApiConstants.kycPersonalInfoEndpoint,
      );
      final nextOfKin = await _apiClient.get(ApiConstants.kycNextOfKinEndpoint);
      final professionalInfo = await _apiClient.get(
        ApiConstants.kycProfessionalInfoEndpoint,
      );
      final idInfo = await _apiClient.get(ApiConstants.kycIdInfoEndpoint);

      return {
        'success': true,
        'data': {
          'personal_info': personalInfo,
          'next_of_kin': nextOfKin,
          'professional_info': professionalInfo,
          'id_info': idInfo,
        },
      };
    } catch (e) {
      developer.log('Error fetching KYC application data: $e', error: e);

      if (e is ApiException) {
        return {'success': false, 'error': e.message};
      }

      return {
        'success': false,
        'error': 'Failed to fetch KYC data. Please try again.',
      };
    }
  }

  /// Upload document with file
  Future<Map<String, dynamic>> uploadDocument({
    required String documentType,
    required String filePath,
    required Map<String, dynamic> documentData,
  }) async {
    try {
      developer.log('Uploading document: $documentType');

      // For now, simulate file upload by including file path in data
      final uploadData = {
        ...documentData,
        'document_type': documentType,
        'file_path': filePath,
      };

      final response = await _apiClient.postWithAuth(
        '${ApiConstants.kycIdInfoEndpoint}upload/',
        uploadData,
      );

      return {
        'success': true,
        'data': response,
        'message': 'Document uploaded successfully',
      };
    } catch (e) {
      developer.log('Error uploading document: $e', error: e);

      if (e is ApiException) {
        return {'success': false, 'error': e.message};
      }

      return {
        'success': false,
        'error': 'Failed to upload document. Please try again.',
      };
    }
  }

  /// Check if KYC is completed and approved
  Future<bool> isKycCompleted() async {
    try {
      final statusResult = await getKycStatus();

      if (statusResult['success'] == true) {
        final status = statusResult['data']['kyc_status'];
        return status == 'approved';
      }

      return false;
    } catch (e) {
      developer.log('Error checking KYC completion: $e', error: e);
      return false;
    }
  }

  /// Get KYC status with proper enum mapping
  Future<Map<String, dynamic>> getKycStatusWithEnum() async {
    try {
      developer.log('🔍 KYC Service: Getting status with enum mapping...');
      final result = await getKycStatus();

      developer.log(
        '🔍 KYC Service: Raw result from getKycStatus: ${result.toString()}',
      );

      // The getKycStatus method already normalizes the response,
      // so we can return it directly
      if (result['success'] == true && result['data'] != null) {
        developer.log(
          '✅ KYC Service: Status already normalized by getKycStatus',
        );
        return result;
      } else {
        developer.log('❌ KYC Service: API call was not successful or no data');
        return result;
      }
    } catch (e) {
      developer.log('💥 Error getting KYC status with enum: $e', error: e);
      return {'success': false, 'error': 'Failed to get KYC status'};
    }
  }

  /// Submit complete KYC application with all sections and file uploads
  Future<Map<String, dynamic>> submitCompleteKycApplication(
    Map<String, dynamic> completeKycData,
  ) async {
    try {
      developer.log('🚨 [KYC_SERVICE] === BACKEND SUBMISSION DEBUG START ===');
      developer.log('🚀 Submitting complete KYC application with file uploads');
      developer.log(
        '🚨 [KYC_SERVICE] Input data keys: ${completeKycData.keys.toList()}',
      );

      // Validate that all required sections are present
      final requiredSections = [
        'personal_info',
        'next_of_kin',
        'professional_info',
        'id_info',
      ];
      developer.log('🚨 [KYC_SERVICE] Validating required sections...');

      for (final section in requiredSections) {
        final hasSection = completeKycData.containsKey(section);
        final isNotNull = completeKycData[section] != null;
        developer.log(
          '🚨 [KYC_SERVICE] Section $section: exists=$hasSection, notNull=$isNotNull',
        );

        if (!hasSection || !isNotNull) {
          developer.log(
            '🚨 [KYC_SERVICE] ❌ Missing required section: $section',
          );
          return {
            'success': false,
            'error': 'Missing required section: $section',
          };
        }
      }

      developer.log('✅ All required sections present, preparing submission...');

      // Extract file paths from documents section or id_info section
      final Map<String, String> filePaths = {};
      final Map<String, dynamic> dataWithoutFiles = Map.from(completeKycData);

      developer.log('🚨 [KYC_SERVICE] Extracting file paths...');

      // Check for documents in the data (separate documents section)
      if (completeKycData.containsKey('documents')) {
        developer.log('🚨 [KYC_SERVICE] Found documents section');
        final documents = completeKycData['documents'];
        if (documents is Map) {
          // Extract file paths for multipart upload
          if (documents['front_id_image'] != null) {
            filePaths['id_document_front'] = documents['front_id_image'];
            developer.log(
              '🚨 [KYC_SERVICE] Added front ID from documents: ${documents['front_id_image']}',
            );
          }
          if (documents['back_id_image'] != null) {
            filePaths['id_document_back'] = documents['back_id_image'];
            developer.log(
              '🚨 [KYC_SERVICE] Added back ID from documents: ${documents['back_id_image']}',
            );
          }
          if (documents['selfie_image'] != null) {
            filePaths['selfie_document'] = documents['selfie_image'];
            developer.log(
              '🚨 [KYC_SERVICE] Added selfie from documents: ${documents['selfie_image']}',
            );
          }
        }
        // Remove documents section from data as files will be uploaded separately
        dataWithoutFiles.remove('documents');
      }

      // Also check for documents in id_info section (consolidated local storage format)
      if (completeKycData.containsKey('id_info')) {
        final idInfo = completeKycData['id_info'];
        if (idInfo is Map) {
          // Extract file paths from id_info section
          if (idInfo['front_id_image'] != null &&
              idInfo['front_id_image'].toString().isNotEmpty) {
            filePaths['id_document_front'] = idInfo['front_id_image'];
            developer.log(
              '📁 Found front ID image in id_info: ${idInfo['front_id_image']}',
            );
          }
          if (idInfo['back_id_image'] != null &&
              idInfo['back_id_image'].toString().isNotEmpty) {
            filePaths['id_document_back'] = idInfo['back_id_image'];
            developer.log(
              '📁 Found back ID image in id_info: ${idInfo['back_id_image']}',
            );
          }
          if (idInfo['selfie_image'] != null &&
              idInfo['selfie_image'].toString().isNotEmpty) {
            filePaths['selfie_document'] = idInfo['selfie_image'];
            developer.log(
              '📁 Found selfie image in id_info: ${idInfo['selfie_image']}',
            );
          }

          // Remove file paths from id_info data to avoid sending them as regular fields
          final cleanedIdInfo = Map<String, dynamic>.from(idInfo);
          cleanedIdInfo.remove('front_id_image');
          cleanedIdInfo.remove('back_id_image');
          cleanedIdInfo.remove('selfie_image');
          dataWithoutFiles['id_info'] = cleanedIdInfo;
        }
      }

      // Debug logging
      developer.log('📊 Data being sent (without files): $dataWithoutFiles');
      developer.log('📊 Files to upload: $filePaths');
      developer.log('🚨 [KYC_SERVICE] File paths count: ${filePaths.length}');

      // Submit using multipart if there are files, otherwise use regular JSON
      final dynamic response;
      if (filePaths.isNotEmpty) {
        developer.log('🚨 [KYC_SERVICE] 📤 Using multipart upload for files');
        developer.log(
          '🚨 [KYC_SERVICE] Endpoint: ${ApiConstants.kycSubmitEndpoint}',
        );

        response = await _apiClient.postMultipartWithAuth(
          ApiConstants.kycSubmitEndpoint,
          dataWithoutFiles,
          filePaths,
        );
      } else {
        developer.log('🚨 [KYC_SERVICE] 📤 Using JSON upload (no files)');
        developer.log(
          '🚨 [KYC_SERVICE] Endpoint: ${ApiConstants.kycSubmitEndpoint}',
        );

        response = await _apiClient.postWithAuth(
          ApiConstants.kycSubmitEndpoint,
          dataWithoutFiles,
        );
      }

      developer.log('🚨 [KYC_SERVICE] API response received: $response');
      developer.log('🚨 [KYC_SERVICE] Response type: ${response.runtimeType}');

      developer.log(
        '🚨 [KYC_SERVICE] ✅ Complete KYC application submitted successfully',
      );
      developer.log('🚨 [KYC_SERVICE] === BACKEND SUBMISSION DEBUG END ===');

      return {
        'success': true,
        'data': response,
        'message': 'KYC application submitted successfully',
      };
    } catch (e) {
      developer.log(
        '🚨 [KYC_SERVICE] ❌ Error submitting complete KYC application: $e',
        error: e,
      );
      developer.log('🚨 [KYC_SERVICE] Error type: ${e.runtimeType}');
      developer.log('🚨 [KYC_SERVICE] === BACKEND SUBMISSION DEBUG END ===');

      if (e is ApiException) {
        developer.log('🚨 [KYC_SERVICE] ApiException details: ${e.message}');
        return {'success': false, 'error': e.message};
      }

      return {
        'success': false,
        'error': 'Failed to submit KYC application. Please try again.',
      };
    }
  }

  /// Normalize KYC status response to ensure consistent field names
  Map<String, dynamic> _normalizeKycStatusResponse(
    Map<String, dynamic> response,
  ) {
    developer.log('🔧 Normalizing KYC status response: ${response.toString()}');

    // Create a copy of the response
    final normalized = Map<String, dynamic>.from(response);

    // Ensure both 'status' and 'kyc_status' fields are present
    final statusValue =
        response['status'] ??
        response['kyc_status'] ??
        response['user_kyc_status'];

    if (statusValue != null) {
      final normalizedStatus = _normalizeStatusValue(statusValue.toString());
      normalized['status'] = normalizedStatus;
      normalized['kyc_status'] =
          normalizedStatus; // Flutter app expects this field

      developer.log('✅ Normalized status: $normalizedStatus');
    } else {
      developer.log('⚠️ No status field found in response');
    }

    return normalized;
  }

  /// Normalize status values to ensure consistency
  String _normalizeStatusValue(String status) {
    final lowercaseStatus = status.toLowerCase();

    // Map old/inconsistent status values to standardized ones
    switch (lowercaseStatus) {
      case 'pending':
        return 'pending_review';
      case 'draft':
        return 'in_progress';
      case 'in_review':
      case 'inreview':
      case 'under_review':
        return 'pending_review';
      case 'not_started':
      case 'in_progress':
      case 'pending_review':
      case 'approved':
      case 'rejected':
        return lowercaseStatus; // Already standardized
      default:
        developer.log(
          '⚠️ Unknown status value: $status, defaulting to not_started',
        );
        return 'not_started';
    }
  }

  /// Dispose resources
  void dispose() {
    _apiClient.dispose();
  }
}
