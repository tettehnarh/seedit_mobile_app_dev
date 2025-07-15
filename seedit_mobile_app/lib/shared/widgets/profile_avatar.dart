import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double radius;
  final VoidCallback? onTap;
  final bool showBorder;
  final Color? borderColor;
  final double borderWidth;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.radius = 30,
    this.onTap,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget avatar = CircleAvatar(
      radius: radius,
      backgroundColor: theme.primaryColor.withOpacity(0.1),
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: imageUrl!,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildInitialsAvatar(theme),
                errorWidget: (context, url, error) => _buildInitialsAvatar(theme),
              ),
            )
          : _buildInitialsAvatar(theme),
    );

    if (showBorder) {
      avatar = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor ?? theme.primaryColor,
            width: borderWidth,
          ),
        ),
        child: avatar,
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }

  Widget _buildInitialsAvatar(ThemeData theme) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            theme.primaryColor,
            theme.primaryColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          _getInitials(name),
          style: TextStyle(
            color: Colors.white,
            fontSize: radius * 0.6,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    
    final words = name.trim().split(' ');
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    } else if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    
    return name[0].toUpperCase();
  }
}

class ProfileAvatarWithStatus extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double radius;
  final bool isOnline;
  final VoidCallback? onTap;

  const ProfileAvatarWithStatus({
    super.key,
    this.imageUrl,
    required this.name,
    this.radius = 30,
    this.isOnline = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ProfileAvatar(
          imageUrl: imageUrl,
          name: name,
          radius: radius,
          onTap: onTap,
        ),
        if (isOnline)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: radius * 0.4,
              height: radius * 0.4,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class ProfileAvatarList extends StatelessWidget {
  final List<String> imageUrls;
  final List<String> names;
  final double radius;
  final int maxVisible;
  final VoidCallback? onTap;

  const ProfileAvatarList({
    super.key,
    required this.imageUrls,
    required this.names,
    this.radius = 20,
    this.maxVisible = 3,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visibleCount = maxVisible.clamp(1, names.length);
    final remainingCount = names.length - visibleCount;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: (visibleCount * radius * 1.5) + (remainingCount > 0 ? radius * 1.5 : 0),
        height: radius * 2,
        child: Stack(
          children: [
            // Visible avatars
            for (int i = 0; i < visibleCount; i++)
              Positioned(
                left: i * radius * 1.5,
                child: ProfileAvatar(
                  imageUrl: i < imageUrls.length ? imageUrls[i] : null,
                  name: names[i],
                  radius: radius,
                  showBorder: true,
                  borderColor: Colors.white,
                ),
              ),
            
            // Remaining count indicator
            if (remainingCount > 0)
              Positioned(
                left: visibleCount * radius * 1.5,
                child: CircleAvatar(
                  radius: radius,
                  backgroundColor: theme.primaryColor,
                  child: Text(
                    '+$remainingCount',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: radius * 0.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class EditableProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double radius;
  final VoidCallback onEdit;
  final bool isLoading;

  const EditableProfileAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.radius = 50,
    required this.onEdit,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Stack(
      children: [
        ProfileAvatar(
          imageUrl: imageUrl,
          name: name,
          radius: radius,
        ),
        if (isLoading)
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
            onTap: isLoading ? null : onEdit,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: radius * 0.3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
