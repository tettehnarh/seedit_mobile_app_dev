import 'dart:io';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../shared/models/profile_model.dart';

class ProfileService {
  final ImagePicker _imagePicker = ImagePicker();
  static const String _profilePicturesPath = 'profile-pictures';

  // Get user profile
  Future<UserProfile> getUserProfile(String userId) async {
    try {
      // TODO: Replace with actual GraphQL query when backend is ready
      // For now, return mock data based on current user attributes
      final authUser = await Amplify.Auth.getCurrentUser();
      final attributes = await Amplify.Auth.fetchUserAttributes();

      final attributeMap = {
        for (var attr in attributes) attr.userAttributeKey.key: attr.value
      };

      return UserProfile(
        id: const Uuid().v4(),
        userId: authUser.userId,
        email: attributeMap['email'] ?? '',
        firstName: attributeMap['given_name'] ?? '',
        lastName: attributeMap['family_name'] ?? '',
        phoneNumber: attributeMap['phone_number'],
        profilePictureUrl: attributeMap['picture'],
        kycStatus: _parseKycStatus(attributeMap['custom:kyc_status']),
        accountType: _parseAccountType(attributeMap['custom:account_type']),
        riskProfile: _parseRiskProfile(attributeMap['custom:risk_profile']),
        isEmailVerified: attributeMap['email_verified'] == 'true',
        isPhoneVerified: attributeMap['phone_number_verified'] == 'true',
        isMfaEnabled: false, // TODO: Get from user preferences
        isProfileComplete: false, // TODO: Calculate based on profile data
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } on AuthException catch (e) {
      debugPrint('Get profile error: ${e.message}');
      throw Exception('Failed to get user profile.');
    } catch (e) {
      debugPrint('Unexpected get profile error: $e');
      throw Exception('Failed to get user profile.');
    }
  }

  // Update user profile
  Future<UserProfile> updateProfile(String userId, UpdateProfileRequest request) async {
    try {
      // Update Cognito user attributes
      final attributesToUpdate = <AuthUserAttribute>[];

      if (request.firstName != null) {
        attributesToUpdate.add(
          AuthUserAttribute(
            userAttributeKey: AuthUserAttributeKey.givenName,
            value: request.firstName!,
          ),
        );
      }

      if (request.lastName != null) {
        attributesToUpdate.add(
          AuthUserAttribute(
            userAttributeKey: AuthUserAttributeKey.familyName,
            value: request.lastName!,
          ),
        );
      }

      if (request.phoneNumber != null) {
        attributesToUpdate.add(
          AuthUserAttribute(
            userAttributeKey: AuthUserAttributeKey.phoneNumber,
            value: request.phoneNumber!,
          ),
        );
      }

      if (request.riskProfile != null) {
        attributesToUpdate.add(
          AuthUserAttribute(
            userAttributeKey: const CognitoUserAttributeKey.custom('risk_profile'),
            value: request.riskProfile!.name.toUpperCase(),
          ),
        );
      }

      if (attributesToUpdate.isNotEmpty) {
        await Amplify.Auth.updateUserAttributes(attributes: attributesToUpdate);
      }

      // TODO: Update additional profile data in DynamoDB via GraphQL
      // For now, return updated profile
      return await getUserProfile(userId);
    } on AuthException catch (e) {
      debugPrint('Update profile error: ${e.message}');
      throw Exception('Failed to update profile.');
    } catch (e) {
      debugPrint('Unexpected update profile error: $e');
      throw Exception('Failed to update profile.');
    }
  }

  // Upload profile picture
  Future<String> uploadProfilePicture(String userId, XFile imageFile) async {
    try {
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final key = '$_profilePicturesPath/$userId/$fileName';

      final uploadResult = await Amplify.Storage.uploadFile(
        localFile: AWSFile.fromPath(imageFile.path),
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

      // Update user's profile picture URL in Cognito
      await Amplify.Auth.updateUserAttributes(
        attributes: [
          AuthUserAttribute(
            userAttributeKey: AuthUserAttributeKey.picture,
            value: urlResult.url.toString(),
          ),
        ],
      );

      return urlResult.url.toString();
    } on StorageException catch (e) {
      debugPrint('Upload profile picture error: ${e.message}');
      throw Exception('Failed to upload profile picture.');
    } catch (e) {
      debugPrint('Unexpected upload error: $e');
      throw Exception('Failed to upload profile picture.');
    }
  }

  // Pick image from gallery
  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      debugPrint('Pick image from gallery error: $e');
      throw Exception('Failed to pick image from gallery.');
    }
  }

  // Pick image from camera
  Future<XFile?> pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      debugPrint('Pick image from camera error: $e');
      throw Exception('Failed to take picture.');
    }
  }

  // Delete profile picture
  Future<void> deleteProfilePicture(String userId) async {
    try {
      // List all profile pictures for the user
      final listResult = await Amplify.Storage.list(
        path: StoragePath.fromString('$_profilePicturesPath/$userId/'),
        options: const StorageListOptions(
          accessLevel: StorageAccessLevel.private,
        ),
      ).result;

      // Delete all profile pictures
      for (final item in listResult.items) {
        await Amplify.Storage.remove(
          key: item.key,
          options: const StorageRemoveOptions(
            accessLevel: StorageAccessLevel.private,
          ),
        ).result;
      }

      // Remove profile picture URL from Cognito
      await Amplify.Auth.updateUserAttributes(
        attributes: [
          const AuthUserAttribute(
            userAttributeKey: AuthUserAttributeKey.picture,
            value: '',
          ),
        ],
      );
    } on StorageException catch (e) {
      debugPrint('Delete profile picture error: ${e.message}');
      throw Exception('Failed to delete profile picture.');
    } catch (e) {
      debugPrint('Unexpected delete error: $e');
      throw Exception('Failed to delete profile picture.');
    }
  }

  // Validate profile completeness
  bool isProfileComplete(UserProfile profile) {
    return profile.firstName.isNotEmpty &&
        profile.lastName.isNotEmpty &&
        profile.email.isNotEmpty &&
        profile.phoneNumber?.isNotEmpty == true &&
        profile.dateOfBirth != null &&
        profile.address?.isNotEmpty == true &&
        profile.city?.isNotEmpty == true &&
        profile.state?.isNotEmpty == true &&
        profile.country?.isNotEmpty == true &&
        profile.occupation?.isNotEmpty == true &&
        profile.riskProfile != null;
  }

  // Helper methods
  KycStatus _parseKycStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'APPROVED':
        return KycStatus.approved;
      case 'REJECTED':
        return KycStatus.rejected;
      case 'UNDER_REVIEW':
        return KycStatus.underReview;
      default:
        return KycStatus.pending;
    }
  }

  AccountType _parseAccountType(String? type) {
    switch (type?.toUpperCase()) {
      case 'CORPORATE':
        return AccountType.corporate;
      default:
        return AccountType.individual;
    }
  }

  RiskProfile? _parseRiskProfile(String? profile) {
    switch (profile?.toUpperCase()) {
      case 'CONSERVATIVE':
        return RiskProfile.conservative;
      case 'MODERATE':
        return RiskProfile.moderate;
      case 'AGGRESSIVE':
        return RiskProfile.aggressive;
      default:
        return null;
    }
  }
}
