import 'dart:convert';
import 'dart:developer' as developer;
import '../../../core/utils/storage_utils.dart';

/// Service for handling local KYC data persistence
/// Stores KYC form data locally until final submission
class KycLocalStorageService {
  // Storage keys for KYC sections
  static const String _kycPersonalInfoKey = 'kyc_personal_info_draft';
  static const String _kycNextOfKinKey = 'kyc_next_of_kin_draft';
  static const String _kycProfessionalInfoKey = 'kyc_professional_info_draft';
  static const String _kycIdInfoKey = 'kyc_id_info_draft';
  static const String _kycDocumentsKey = 'kyc_documents_draft';
  static const String _kycProgressKey = 'kyc_progress_status';
  static const String _kycLastSavedKey = 'kyc_last_saved_timestamp';

  /// Save personal information to local storage
  static Future<bool> savePersonalInfo(
    Map<String, dynamic> personalInfo,
  ) async {
    try {
      final jsonString = jsonEncode(personalInfo);
      await StorageUtils.setString(_kycPersonalInfoKey, jsonString);

      await _updateLastSaved();
      await _updateProgress('personal_info', true);

      developer.log('Personal info saved to local storage');
      return true;
    } catch (e) {
      developer.log('Error saving personal info locally: $e', error: e);
      return false;
    }
  }

  /// Get personal information from local storage
  static Future<Map<String, dynamic>?> getPersonalInfo() async {
    try {
      final jsonString = await StorageUtils.getString(_kycPersonalInfoKey);

      if (jsonString != null && jsonString.isNotEmpty) {
        final data = jsonDecode(jsonString) as Map<String, dynamic>;
        return data;
      }
      return null;
    } catch (e) {
      developer.log(
        'Error loading personal info from local storage: $e',
        error: e,
      );
      return null;
    }
  }

  /// Save next of kin information to local storage
  static Future<bool> saveNextOfKin(Map<String, dynamic> nextOfKin) async {
    try {
      final jsonString = jsonEncode(nextOfKin);
      await StorageUtils.setString(_kycNextOfKinKey, jsonString);
      await _updateLastSaved();
      await _updateProgress('next_of_kin', true);

      developer.log('Next of kin info saved to local storage');
      return true;
    } catch (e) {
      developer.log('Error saving next of kin info locally: $e', error: e);
      return false;
    }
  }

  /// Get next of kin information from local storage
  static Future<Map<String, dynamic>?> getNextOfKin() async {
    try {
      final jsonString = await StorageUtils.getString(_kycNextOfKinKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      developer.log(
        'Error loading next of kin info from local storage: $e',
        error: e,
      );
      return null;
    }
  }

  /// Save professional information to local storage
  static Future<bool> saveProfessionalInfo(
    Map<String, dynamic> professionalInfo,
  ) async {
    try {
      final jsonString = jsonEncode(professionalInfo);
      await StorageUtils.setString(_kycProfessionalInfoKey, jsonString);
      await _updateLastSaved();
      await _updateProgress('professional_info', true);

      developer.log('Professional info saved to local storage');
      return true;
    } catch (e) {
      developer.log('Error saving professional info locally: $e', error: e);
      return false;
    }
  }

  /// Get professional information from local storage
  static Future<Map<String, dynamic>?> getProfessionalInfo() async {
    try {
      final jsonString = await StorageUtils.getString(_kycProfessionalInfoKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      developer.log(
        'Error loading professional info from local storage: $e',
        error: e,
      );
      return null;
    }
  }

  /// Save ID information to local storage
  static Future<bool> saveIdInfo(Map<String, dynamic> idInfo) async {
    try {
      final jsonString = jsonEncode(idInfo);
      await StorageUtils.setString(_kycIdInfoKey, jsonString);
      await _updateLastSaved();
      await _updateProgress('id_info', true);

      developer.log('ID info saved to local storage');
      return true;
    } catch (e) {
      developer.log('Error saving ID info locally: $e', error: e);
      return false;
    }
  }

  /// Get ID information from local storage
  static Future<Map<String, dynamic>?> getIdInfo() async {
    try {
      final jsonString = await StorageUtils.getString(_kycIdInfoKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      developer.log('Error loading ID info from local storage: $e', error: e);
      return null;
    }
  }

  /// Save consolidated ID information and documents to local storage
  static Future<bool> saveIdAndDocuments(
    Map<String, dynamic> idAndDocuments,
  ) async {
    try {
      // Save both ID info and documents together
      await saveIdInfo({
        'id_type': idAndDocuments['id_type'],
        'id_number': idAndDocuments['id_number'],
        'issue_date': idAndDocuments['issue_date'],
        'expiry_date': idAndDocuments['expiry_date'],
      });

      await saveDocuments({
        'front_id_image': idAndDocuments['front_id_image'],
        'back_id_image': idAndDocuments['back_id_image'],
        'selfie_image': idAndDocuments['selfie_image'],
      });

      developer.log(
        'Consolidated ID and documents info saved to local storage',
      );
      return true;
    } catch (e) {
      developer.log(
        'Error saving consolidated ID and documents info locally: $e',
        error: e,
      );
      return false;
    }
  }

  /// Save document information to local storage
  static Future<bool> saveDocuments(Map<String, dynamic> documents) async {
    try {
      final jsonString = jsonEncode(documents);
      await StorageUtils.setString(_kycDocumentsKey, jsonString);
      await _updateLastSaved();
      await _updateProgress('documents', true);

      developer.log('Documents info saved to local storage');
      return true;
    } catch (e) {
      developer.log('Error saving documents info locally: $e', error: e);
      return false;
    }
  }

  /// Get document information from local storage
  static Future<Map<String, dynamic>?> getDocuments() async {
    try {
      final jsonString = await StorageUtils.getString(_kycDocumentsKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      developer.log(
        'Error loading documents info from local storage: $e',
        error: e,
      );
      return null;
    }
  }

  /// Get complete KYC draft data with documents consolidated into id_info
  static Future<Map<String, dynamic>?> getCompleteDraftData() async {
    try {
      final personalInfo = await getPersonalInfo();
      final nextOfKin = await getNextOfKin();
      final professionalInfo = await getProfessionalInfo();
      final idInfo = await getIdInfo();
      final documents = await getDocuments();

      if (personalInfo == null &&
          nextOfKin == null &&
          professionalInfo == null &&
          idInfo == null &&
          documents == null) {
        return null;
      }

      // Consolidate documents into id_info for proper submission workflow
      Map<String, dynamic>? consolidatedIdInfo = idInfo;
      if (idInfo != null && documents != null) {
        consolidatedIdInfo = Map<String, dynamic>.from(idInfo);

        // Add document file paths to id_info section
        if (documents['front_id_image'] != null) {
          consolidatedIdInfo['front_id_image'] = documents['front_id_image'];
        }
        if (documents['back_id_image'] != null) {
          consolidatedIdInfo['back_id_image'] = documents['back_id_image'];
        }
        if (documents['selfie_image'] != null) {
          consolidatedIdInfo['selfie_image'] = documents['selfie_image'];
        }

        developer.log('📁 Consolidated documents into id_info for submission');
      }

      return {
        'personal_info': personalInfo,
        'next_of_kin': nextOfKin,
        'professional_info': professionalInfo,
        'id_info': consolidatedIdInfo,
        'documents': documents, // Keep separate for backward compatibility
      };
    } catch (e) {
      developer.log('Error loading complete draft data: $e', error: e);
      return null;
    }
  }

  /// Check if all required sections are completed
  static Future<bool> isKycDraftComplete() async {
    try {
      final personalInfo = await getPersonalInfo();
      final nextOfKin = await getNextOfKin();
      final professionalInfo = await getProfessionalInfo();
      final idInfo = await getIdInfo();

      return personalInfo != null &&
          nextOfKin != null &&
          professionalInfo != null &&
          idInfo != null;
    } catch (e) {
      developer.log('Error checking KYC draft completion: $e', error: e);
      return false;
    }
  }

  /// Get KYC progress status
  static Future<Map<String, bool>> getKycProgress() async {
    try {
      final progressString = await StorageUtils.getString(_kycProgressKey);
      if (progressString != null && progressString.isNotEmpty) {
        final progressMap = jsonDecode(progressString) as Map<String, dynamic>;
        return progressMap.map((key, value) => MapEntry(key, value as bool));
      }

      return {
        'personal_info': false,
        'next_of_kin': false,
        'professional_info': false,
        'id_info': false,
        'documents': false,
      };
    } catch (e) {
      developer.log('Error loading KYC progress: $e', error: e);
      return {
        'personal_info': false,
        'next_of_kin': false,
        'professional_info': false,
        'id_info': false,
        'documents': false,
      };
    }
  }

  /// Update progress for a specific section
  static Future<void> _updateProgress(String section, bool completed) async {
    try {
      final currentProgress = await getKycProgress();
      currentProgress[section] = completed;

      final progressString = jsonEncode(currentProgress);
      await StorageUtils.setString(_kycProgressKey, progressString);

      developer.log('KYC progress updated: $section = $completed');
    } catch (e) {
      developer.log('Error updating KYC progress: $e', error: e);
    }
  }

  /// Update last saved timestamp
  static Future<void> _updateLastSaved() async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await StorageUtils.setInt(_kycLastSavedKey, timestamp);
    } catch (e) {
      developer.log('Error updating last saved timestamp: $e', error: e);
    }
  }

  /// Get last saved timestamp
  static Future<DateTime?> getLastSaved() async {
    try {
      final timestamp = await StorageUtils.getInt(_kycLastSavedKey);
      if (timestamp > 0) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
      return null;
    } catch (e) {
      developer.log('Error getting last saved timestamp: $e', error: e);
      return null;
    }
  }

  /// Clear all KYC draft data
  static Future<void> clearAllDraftData() async {
    try {
      await Future.wait([
        StorageUtils.remove(_kycPersonalInfoKey),
        StorageUtils.remove(_kycNextOfKinKey),
        StorageUtils.remove(_kycProfessionalInfoKey),
        StorageUtils.remove(_kycIdInfoKey),
        StorageUtils.remove(_kycDocumentsKey),
        StorageUtils.remove(_kycProgressKey),
        StorageUtils.remove(_kycLastSavedKey),
      ]);

      developer.log('All KYC draft data cleared');
    } catch (e) {
      developer.log('Error clearing KYC draft data: $e', error: e);
    }
  }

  /// Clear only rejection-related data while preserving form data
  /// This allows rejected users to edit their existing data for resubmission
  static Future<void> clearRejectionData() async {
    try {
      // Only clear progress status and last saved timestamp
      // This allows the forms to be editable again while preserving user data
      await Future.wait([
        StorageUtils.remove(_kycProgressKey),
        StorageUtils.remove(_kycLastSavedKey),
      ]);

      developer.log('KYC rejection data cleared, form data preserved');
    } catch (e) {
      developer.log('Error clearing KYC rejection data: $e', error: e);
    }
  }

  /// Check if there's any draft data available
  static Future<bool> hasDraftData() async {
    try {
      final draftData = await getCompleteDraftData();
      return draftData != null;
    } catch (e) {
      developer.log('Error checking for draft data: $e', error: e);
      return false;
    }
  }
}
