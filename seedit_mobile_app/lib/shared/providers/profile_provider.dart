import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/profile_model.dart';
import '../../core/services/profile_service.dart';
import 'auth_provider.dart';

// Profile service provider
final profileServiceProvider = Provider<ProfileService>((ref) => ProfileService());

// Profile state provider
final profileStateProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(
    ref.read(profileServiceProvider),
    ref.read(authStateProvider.notifier),
  );
});

// Current user profile provider
final currentUserProfileProvider = Provider<UserProfile?>((ref) {
  final profileState = ref.watch(profileStateProvider);
  return profileState.profile;
});

// Profile loading provider
final profileLoadingProvider = Provider<bool>((ref) {
  final profileState = ref.watch(profileStateProvider);
  return profileState.isLoading;
});

// Profile error provider
final profileErrorProvider = Provider<String?>((ref) {
  final profileState = ref.watch(profileStateProvider);
  return profileState.error;
});

// Profile completion percentage provider
final profileCompletionProvider = Provider<double>((ref) {
  final profile = ref.watch(currentUserProfileProvider);
  return profile?.profileCompletionPercentage ?? 0.0;
});

class ProfileState {
  final UserProfile? profile;
  final bool isLoading;
  final bool isUploading;
  final String? error;

  ProfileState({
    this.profile,
    this.isLoading = false,
    this.isUploading = false,
    this.error,
  });

  ProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    bool? isUploading,
    String? error,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      isUploading: isUploading ?? this.isUploading,
      error: error,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileService _profileService;
  final AuthNotifier _authNotifier;

  ProfileNotifier(this._profileService, this._authNotifier) : super(ProfileState());

  // Load user profile
  Future<void> loadProfile(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final profile = await _profileService.getUserProfile(userId);
      state = state.copyWith(
        profile: profile,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('Load profile error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Update profile
  Future<void> updateProfile(String userId, UpdateProfileRequest request) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final updatedProfile = await _profileService.updateProfile(userId, request);
      state = state.copyWith(
        profile: updatedProfile,
        isLoading: false,
      );
      
      // Refresh auth user data
      await _authNotifier.refreshUser();
    } catch (e) {
      debugPrint('Update profile error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Upload profile picture from gallery
  Future<void> uploadProfilePictureFromGallery(String userId) async {
    try {
      final imageFile = await _profileService.pickImageFromGallery();
      if (imageFile != null) {
        await _uploadProfilePicture(userId, imageFile);
      }
    } catch (e) {
      debugPrint('Upload from gallery error: $e');
      state = state.copyWith(
        isUploading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Upload profile picture from camera
  Future<void> uploadProfilePictureFromCamera(String userId) async {
    try {
      final imageFile = await _profileService.pickImageFromCamera();
      if (imageFile != null) {
        await _uploadProfilePicture(userId, imageFile);
      }
    } catch (e) {
      debugPrint('Upload from camera error: $e');
      state = state.copyWith(
        isUploading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Private method to handle profile picture upload
  Future<void> _uploadProfilePicture(String userId, XFile imageFile) async {
    state = state.copyWith(isUploading: true, error: null);
    
    try {
      final imageUrl = await _profileService.uploadProfilePicture(userId, imageFile);
      
      // Update profile with new image URL
      if (state.profile != null) {
        final updatedProfile = state.profile!.copyWith(
          profilePictureUrl: imageUrl,
          updatedAt: DateTime.now(),
        );
        state = state.copyWith(
          profile: updatedProfile,
          isUploading: false,
        );
      }
      
      // Refresh auth user data
      await _authNotifier.refreshUser();
    } catch (e) {
      debugPrint('Upload profile picture error: $e');
      state = state.copyWith(
        isUploading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Delete profile picture
  Future<void> deleteProfilePicture(String userId) async {
    state = state.copyWith(isUploading: true, error: null);
    
    try {
      await _profileService.deleteProfilePicture(userId);
      
      // Update profile to remove image URL
      if (state.profile != null) {
        final updatedProfile = state.profile!.copyWith(
          profilePictureUrl: null,
          updatedAt: DateTime.now(),
        );
        state = state.copyWith(
          profile: updatedProfile,
          isUploading: false,
        );
      }
      
      // Refresh auth user data
      await _authNotifier.refreshUser();
    } catch (e) {
      debugPrint('Delete profile picture error: $e');
      state = state.copyWith(
        isUploading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Refresh profile data
  Future<void> refreshProfile() async {
    if (state.profile != null) {
      await loadProfile(state.profile!.userId);
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Update specific profile fields locally (for form state management)
  void updateProfileLocally(UserProfile updatedProfile) {
    state = state.copyWith(profile: updatedProfile);
  }

  // Check if profile is complete
  bool isProfileComplete() {
    if (state.profile == null) return false;
    return _profileService.isProfileComplete(state.profile!);
  }

  // Get missing profile fields
  List<String> getMissingProfileFields() {
    if (state.profile == null) return [];
    
    final List<String> missingFields = [];
    final profile = state.profile!;
    
    if (profile.firstName.isEmpty) missingFields.add('First Name');
    if (profile.lastName.isEmpty) missingFields.add('Last Name');
    if (profile.phoneNumber?.isEmpty != false) missingFields.add('Phone Number');
    if (profile.dateOfBirth == null) missingFields.add('Date of Birth');
    if (profile.address?.isEmpty != false) missingFields.add('Address');
    if (profile.city?.isEmpty != false) missingFields.add('City');
    if (profile.state?.isEmpty != false) missingFields.add('State');
    if (profile.country?.isEmpty != false) missingFields.add('Country');
    if (profile.occupation?.isEmpty != false) missingFields.add('Occupation');
    if (profile.riskProfile == null) missingFields.add('Risk Profile');
    
    return missingFields;
  }
}
