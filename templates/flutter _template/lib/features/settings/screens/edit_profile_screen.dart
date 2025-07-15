import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart' as picker;
import 'dart:developer' as developer;
import '../../../core/utils/app_theme.dart';
import '../../../core/constants/api_constants.dart';
import '../../../shared/widgets/dialogs/dialogs.dart';
import '../../auth/providers/user_provider.dart';
import '../services/settings_service.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  File? _selectedImage;
  bool _isLoading = false;
  final picker.ImagePicker _picker = picker.ImagePicker();
  final SettingsService _settingsService = SettingsService();

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final user = userState.user;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: Text(
              'Save',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                color: _isLoading ? Colors.grey : AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Picture Section
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: AppTheme.primaryColor.withValues(
                                alpha: 0.1,
                              ),
                              backgroundImage: _getProfileImage(),
                              child: _getProfileImage() == null
                                  ? Text(
                                      _getInitials(user),
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryColor,
                                        fontFamily: 'Montserrat',
                                      ),
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _showImagePickerOptions,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tap to change profile picture',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Personal Information Section
                  _buildSectionTitle('Personal Information'),
                  const SizedBox(height: 16),

                  // KYC Notice (if applicable)
                  if (user?.kycPersonalInfo != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue[700], size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Your personal information is verified through KYC and cannot be edited here.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue[700],
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // First Name Field
                  _buildReadOnlyField(
                    label: 'First Name',
                    value: user?.authoritativeFirstName ?? '',
                  ),
                  const SizedBox(height: 16),

                  // Last Name Field
                  _buildReadOnlyField(
                    label: 'Last Name',
                    value: user?.authoritativeLastName ?? '',
                  ),
                  const SizedBox(height: 16),

                  // Email Field
                  _buildReadOnlyField(label: 'Email', value: user?.email ?? ''),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryColor,
        fontFamily: 'Montserrat',
      ),
    );
  }

  Widget _buildReadOnlyField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            value.isNotEmpty ? value : 'Not provided',
            style: TextStyle(
              fontSize: 16,
              color: value.isNotEmpty ? Colors.grey[700] : Colors.grey[500],
              fontFamily: 'Montserrat',
            ),
          ),
        ),
      ],
    );
  }

  ImageProvider? _getProfileImage() {
    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    }

    // Check if user has an existing profile picture
    final user = ref.watch(currentUserProvider);
    if (user?.avatar != null && user!.avatar!.isNotEmpty) {
      // Use the utility function to get the full URL
      final avatarUrl = ApiConstants.getFullMediaUrl(user.avatar);
      if (avatarUrl.isNotEmpty) {
        return NetworkImage(avatarUrl);
      }
    }

    return null;
  }

  String _getInitials(user) {
    if (user?.authoritativeFirstName.isNotEmpty == true) {
      return user!.authoritativeFirstName[0].toUpperCase();
    }
    return 'S'; // For "Seedit"
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Profile Picture',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () => _pickImage(picker.ImageSource.camera),
                ),
                _buildImageOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () => _pickImage(picker.ImageSource.gallery),
                ),
                if (_selectedImage != null)
                  _buildImageOption(
                    icon: Icons.delete,
                    label: 'Remove',
                    onTap: _removeImage,
                  ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        // Add a small delay to ensure the bottom sheet is fully closed
        // before opening the image picker to prevent navigation conflicts
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          onTap();
        }
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontFamily: 'Montserrat'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(picker.ImageSource source) async {
    try {
      // Ensure we're in a stable state before opening image picker
      if (!mounted) return;

      final picker.XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        MessageDialog.showError(
          context: context,
          title: 'Error',
          message: 'Failed to pick image. Please try again.',
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _saveProfile() async {
    if (_selectedImage == null) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload profile picture to backend
      final success = await _uploadProfilePicture(_selectedImage!);

      if (success && mounted) {
        await MessageDialog.showSuccess(
          context: context,
          title: 'Success',
          message: 'Profile picture updated successfully!',
        );
        // Add a small delay to ensure any state changes are completed
        // before navigating to prevent Hero widget conflicts
        await Future.delayed(const Duration(milliseconds: 200));
        if (mounted) {
          Navigator.pop(context);
        }
      } else if (mounted) {
        MessageDialog.showError(
          context: context,
          title: 'Error',
          message: 'Failed to update profile picture. Please try again.',
        );
      }
    } catch (e) {
      if (mounted) {
        MessageDialog.showError(
          context: context,
          title: 'Error',
          message: 'Failed to update profile picture. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _uploadProfilePicture(File imageFile) async {
    try {
      // Upload profile picture using settings service
      final response = await _settingsService.uploadProfilePicture(imageFile);

      // Check if upload was successful
      if (response['message'] != null || response['user'] != null) {
        // Add a small delay to ensure upload is fully processed
        await Future.delayed(const Duration(milliseconds: 100));
        // Refresh user data to get updated profile picture URL
        await ref.read(userProvider.notifier).refreshUserData();
        return true;
      }

      return false;
    } catch (e) {
      developer.log('Error uploading profile picture: $e', error: e);
      return false;
    }
  }
}
