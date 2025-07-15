import 'dart:io';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../../shared/models/kyc_model.dart';

class KycService {
  final ImagePicker _imagePicker = ImagePicker();
  static const String _kycDocumentsPath = 'kyc-documents';

  // Get KYC application for user
  Future<KycApplication?> getKycApplication(String userId) async {
    try {
      // TODO: Replace with actual GraphQL query when backend is ready
      // For now, return mock data or null if no application exists
      
      // Check if user has existing KYC application
      final authUser = await Amplify.Auth.getCurrentUser();
      final attributes = await Amplify.Auth.fetchUserAttributes();
      
      final attributeMap = {
        for (var attr in attributes) attr.userAttributeKey.key: attr.value
      };
      
      final kycStatus = _parseKycStatus(attributeMap['custom:kyc_status']);
      
      if (kycStatus == KycStatus.draft && attributeMap['custom:kyc_status'] == null) {
        // No KYC application exists
        return null;
      }
      
      // Return mock KYC application
      return KycApplication(
        id: const Uuid().v4(),
        userId: authUser.userId,
        status: kycStatus,
        level: KycLevel.tier1,
        personalInfo: PersonalInfo(
          firstName: attributeMap['given_name'] ?? '',
          lastName: attributeMap['family_name'] ?? '',
          middleName: '',
          dateOfBirth: DateTime(1990, 1, 1),
          gender: '',
          nationality: 'Nigerian',
          placeOfBirth: '',
          mothersMaidenName: '',
          phoneNumber: attributeMap['phone_number'] ?? '',
          email: attributeMap['email'] ?? '',
          maritalStatus: '',
        ),
        identityDocuments: IdentityDocuments(
          bvn: '',
          nin: '',
        ),
        documents: [],
        statusHistory: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } on AuthException catch (e) {
      debugPrint('Get KYC application error: ${e.message}');
      throw Exception('Failed to get KYC application.');
    } catch (e) {
      debugPrint('Unexpected get KYC application error: $e');
      throw Exception('Failed to get KYC application.');
    }
  }

  // Create new KYC application
  Future<KycApplication> createKycApplication(String userId, KycLevel level) async {
    try {
      final authUser = await Amplify.Auth.getCurrentUser();
      final attributes = await Amplify.Auth.fetchUserAttributes();
      
      final attributeMap = {
        for (var attr in attributes) attr.userAttributeKey.key: attr.value
      };
      
      final kycApplication = KycApplication(
        id: const Uuid().v4(),
        userId: authUser.userId,
        status: KycStatus.draft,
        level: level,
        personalInfo: PersonalInfo(
          firstName: attributeMap['given_name'] ?? '',
          lastName: attributeMap['family_name'] ?? '',
          middleName: '',
          dateOfBirth: DateTime(1990, 1, 1),
          gender: '',
          nationality: 'Nigerian',
          placeOfBirth: '',
          mothersMaidenName: '',
          phoneNumber: attributeMap['phone_number'] ?? '',
          email: attributeMap['email'] ?? '',
          maritalStatus: '',
        ),
        identityDocuments: IdentityDocuments(
          bvn: '',
          nin: '',
        ),
        documents: [],
        statusHistory: [
          KycStatusHistory(
            id: const Uuid().v4(),
            kycApplicationId: const Uuid().v4(),
            fromStatus: KycStatus.draft,
            toStatus: KycStatus.draft,
            reason: 'Application created',
            changedBy: 'system',
            changedAt: DateTime.now(),
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // TODO: Save to backend via GraphQL
      
      return kycApplication;
    } catch (e) {
      debugPrint('Create KYC application error: $e');
      throw Exception('Failed to create KYC application.');
    }
  }

  // Update KYC application
  Future<KycApplication> updateKycApplication(KycApplication application) async {
    try {
      // TODO: Update via GraphQL when backend is ready
      
      final updatedApplication = application.copyWith(
        updatedAt: DateTime.now(),
      );
      
      return updatedApplication;
    } catch (e) {
      debugPrint('Update KYC application error: $e');
      throw Exception('Failed to update KYC application.');
    }
  }

  // Submit KYC application for review
  Future<KycApplication> submitKycApplication(String applicationId) async {
    try {
      // TODO: Submit via GraphQL when backend is ready
      
      // Update Cognito user attributes
      await Amplify.Auth.updateUserAttributes(
        attributes: [
          const AuthUserAttribute(
            userAttributeKey: CognitoUserAttributeKey.custom('kyc_status'),
            value: 'SUBMITTED',
          ),
        ],
      );
      
      // Return updated application (mock)
      final application = await getKycApplication('');
      return application!.copyWith(
        status: KycStatus.submitted,
        submittedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Submit KYC application error: $e');
      throw Exception('Failed to submit KYC application.');
    }
  }

  // Upload KYC document
  Future<KycDocument> uploadDocument(
    String applicationId,
    DocumentType type,
    XFile file,
  ) async {
    try {
      final fileName = '${type.name}_${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}';
      final key = '$_kycDocumentsPath/$applicationId/$fileName';

      final uploadResult = await Amplify.Storage.uploadFile(
        localFile: AWSFile.fromPath(file.path),
        key: key,
        options: const StorageUploadFileOptions(
          accessLevel: StorageAccessLevel.private,
        ),
      ).result;

      // Get the uploaded file URL
      final urlResult = await Amplify.Storage.getUrl(
        key: uploadResult.uploadedItem.key,
        options: const StorageGetUrlOptions(
          accessLevel: StorageAccessLevel.private,
        ),
      ).result;

      final document = KycDocument(
        id: const Uuid().v4(),
        kycApplicationId: applicationId,
        type: type,
        fileName: fileName,
        fileUrl: urlResult.url.toString(),
        mimeType: _getMimeType(file.path),
        fileSize: await file.length(),
        status: DocumentStatus.pending,
        uploadedAt: DateTime.now(),
      );

      // TODO: Save document metadata to backend

      return document;
    } on StorageException catch (e) {
      debugPrint('Upload document error: ${e.message}');
      throw Exception('Failed to upload document.');
    } catch (e) {
      debugPrint('Unexpected upload error: $e');
      throw Exception('Failed to upload document.');
    }
  }

  // Pick image from camera
  Future<XFile?> pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      debugPrint('Pick image from camera error: $e');
      throw Exception('Failed to take picture.');
    }
  }

  // Pick image from gallery
  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      debugPrint('Pick image from gallery error: $e');
      throw Exception('Failed to pick image from gallery.');
    }
  }

  // Pick file (for documents like PDFs)
  Future<XFile?> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        return XFile(file.path!);
      }
      
      return null;
    } catch (e) {
      debugPrint('Pick file error: $e');
      throw Exception('Failed to pick file.');
    }
  }

  // Delete KYC document
  Future<void> deleteDocument(String applicationId, String documentId) async {
    try {
      // TODO: Delete from backend and S3
      
      // For now, just delete from S3
      await Amplify.Storage.remove(
        key: '$_kycDocumentsPath/$applicationId/$documentId',
        options: const StorageRemoveOptions(
          accessLevel: StorageAccessLevel.private,
        ),
      ).result;
    } on StorageException catch (e) {
      debugPrint('Delete document error: ${e.message}');
      throw Exception('Failed to delete document.');
    } catch (e) {
      debugPrint('Unexpected delete error: $e');
      throw Exception('Failed to delete document.');
    }
  }

  // Get required documents for KYC level
  List<DocumentType> getRequiredDocuments(KycLevel level) {
    switch (level) {
      case KycLevel.tier1:
        return [
          DocumentType.nationalId,
          DocumentType.selfie,
          DocumentType.proofOfAddress,
        ];
      case KycLevel.tier2:
        return [
          DocumentType.nationalId,
          DocumentType.passport,
          DocumentType.selfie,
          DocumentType.proofOfAddress,
          DocumentType.utilityBill,
          DocumentType.signature,
        ];
      case KycLevel.tier3:
        return [
          DocumentType.nationalId,
          DocumentType.passport,
          DocumentType.driversLicense,
          DocumentType.selfie,
          DocumentType.proofOfAddress,
          DocumentType.utilityBill,
          DocumentType.bankStatement,
          DocumentType.signature,
        ];
    }
  }

  // Validate document requirements
  bool validateDocumentRequirements(KycApplication application) {
    final requiredDocs = getRequiredDocuments(application.level);
    final uploadedDocTypes = application.documents.map((doc) => doc.type).toSet();
    
    return requiredDocs.every((type) => uploadedDocTypes.contains(type));
  }

  // Helper methods
  KycStatus _parseKycStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'SUBMITTED':
        return KycStatus.submitted;
      case 'UNDER_REVIEW':
        return KycStatus.underReview;
      case 'APPROVED':
        return KycStatus.approved;
      case 'REJECTED':
        return KycStatus.rejected;
      case 'EXPIRED':
        return KycStatus.expired;
      default:
        return KycStatus.draft;
    }
  }

  String _getMimeType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }
}
