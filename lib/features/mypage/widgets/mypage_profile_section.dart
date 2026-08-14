import 'package:art_port/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class MyPageProfileSection extends StatelessWidget {
  const MyPageProfileSection({
    super.key,
    required this.avatarUrl,
    required this.onEditPhoto,
    required this.name,
    required this.onOpenSettings,
    required this.subtitle,
    required this.subtitleStyle,
  });

  final String avatarUrl;
  final VoidCallback onEditPhoto;
  final String name;
  final VoidCallback onOpenSettings;
  final String subtitle;
  final TextStyle subtitleStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderLight, width: 3),
              ),
              child: CircleAvatar(
                radius: 52,
                backgroundColor: AppColors.chipBackground,
                backgroundImage: avatarUrl.isEmpty ? null : NetworkImage(avatarUrl),
              ),
            ),
            Positioned(
              right: 4,
              bottom: 4,
              child: GestureDetector(
                onTap: onEditPhoto,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onOpenSettings,
              child: const Icon(
                Icons.settings_outlined,
                size: 20,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(subtitle, style: subtitleStyle),
      ],
    );
  }
}
