import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../shared/providers/profile_provider.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/profile_avatar.dart';
import '../widgets/profile_completion_card.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/profile_action_card.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  void _loadProfile() {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null) {
      ref.read(profileStateProvider.notifier).loadProfile(currentUser.id);
    }
  }

  void _showImagePickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ImagePickerBottomSheet(
        onGalleryTap: () async {
          Navigator.pop(context);
          await _uploadFromGallery();
        },
        onCameraTap: () async {
          Navigator.pop(context);
          await _uploadFromCamera();
        },
        onDeleteTap: () async {
          Navigator.pop(context);
          await _deleteProfilePicture();
        },
        hasProfilePicture: ref.read(currentUserProfileProvider)?.profilePictureUrl != null,
      ),
    );
  }

  Future<void> _uploadFromGallery() async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null) {
      try {
        await ref.read(profileStateProvider.notifier)
            .uploadProfilePictureFromGallery(currentUser.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _uploadFromCamera() async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null) {
      try {
        await ref.read(profileStateProvider.notifier)
            .uploadProfilePictureFromCamera(currentUser.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteProfilePicture() async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null) {
      try {
        await ref.read(profileStateProvider.notifier)
            .deleteProfilePicture(currentUser.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture removed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentUserProfileProvider);
    final isLoading = ref.watch(profileLoadingProvider);
    final isUploading = ref.watch(profileStateProvider.select((state) => state.isUploading));
    final completionPercentage = ref.watch(profileCompletionProvider);

    if (isLoading && profile == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.push('/profile/edit');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(profileStateProvider.notifier).refreshProfile();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile header with avatar
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        ProfileAvatar(
                          imageUrl: profile?.profilePictureUrl,
                          name: profile?.fullName ?? '',
                          radius: 50,
                        ),
                        if (isUploading)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _showImagePickerBottomSheet,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile?.fullName ?? 'User Name',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile?.email ?? '',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getKycStatusColor(profile?.kycStatus),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        profile?.kycStatusDisplayText ?? 'Pending Verification',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Profile completion card
              ProfileCompletionCard(
                completionPercentage: completionPercentage,
                onCompleteProfile: () {
                  context.push('/profile/edit');
                },
              ),
              
              const SizedBox(height: 24),
              
              // Profile information cards
              ProfileInfoCard(profile: profile),
              
              const SizedBox(height: 24),
              
              // Action cards
              ProfileActionCard(
                icon: Icons.security,
                title: 'Security Settings',
                subtitle: 'Manage password and security',
                onTap: () {
                  context.push('/profile/security');
                },
              ),
              
              const SizedBox(height: 16),
              
              ProfileActionCard(
                icon: Icons.verified_user,
                title: 'KYC Verification',
                subtitle: 'Complete identity verification',
                onTap: () {
                  context.push('/kyc');
                },
              ),
              
              const SizedBox(height: 16),
              
              ProfileActionCard(
                icon: Icons.notifications,
                title: 'Notifications',
                subtitle: 'Manage notification preferences',
                onTap: () {
                  context.push('/profile/notifications');
                },
              ),
              
              const SizedBox(height: 32),
              
              // Sign out button
              CustomButton(
                text: 'Sign Out',
                onPressed: () async {
                  await ref.read(authStateProvider.notifier).signOut();
                  if (mounted) {
                    context.go('/auth/sign-in');
                  }
                },
                isOutlined: true,
                textColor: Colors.red,
                backgroundColor: Colors.red,
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Color _getKycStatusColor(dynamic kycStatus) {
    switch (kycStatus?.toString()) {
      case 'KycStatus.approved':
        return Colors.green;
      case 'KycStatus.rejected':
        return Colors.red;
      case 'KycStatus.underReview':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

class _ImagePickerBottomSheet extends StatelessWidget {
  final VoidCallback onGalleryTap;
  final VoidCallback onCameraTap;
  final VoidCallback onDeleteTap;
  final bool hasProfilePicture;

  const _ImagePickerBottomSheet({
    required this.onGalleryTap,
    required this.onCameraTap,
    required this.onDeleteTap,
    required this.hasProfilePicture,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Profile Picture',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _BottomSheetOption(
                icon: Icons.photo_library,
                label: 'Gallery',
                onTap: onGalleryTap,
              ),
              _BottomSheetOption(
                icon: Icons.camera_alt,
                label: 'Camera',
                onTap: onCameraTap,
              ),
              if (hasProfilePicture)
                _BottomSheetOption(
                  icon: Icons.delete,
                  label: 'Remove',
                  onTap: onDeleteTap,
                  color: Colors.red,
                ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _BottomSheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _BottomSheetOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).primaryColor;
    
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: effectiveColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: effectiveColor,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: effectiveColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
