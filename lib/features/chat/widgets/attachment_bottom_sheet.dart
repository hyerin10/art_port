import 'package:art_port/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 첨부 파일 선택 바텀시트 (시안 image_d16904)
class AttachmentBottomSheet extends StatelessWidget {
  const AttachmentBottomSheet({
    super.key,
    required this.onCamera,
    required this.onGallery,
    required this.onFile,
  });

  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onFile;

  static Future<void> show(
    BuildContext context, {
    VoidCallback? onCamera,
    VoidCallback? onGallery,
    VoidCallback? onFile,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return AttachmentBottomSheet(
          onCamera: () {
            Navigator.of(ctx).pop();
            onCamera?.call();
          },
          onGallery: () {
            Navigator.of(ctx).pop();
            onGallery?.call();
          },
          onFile: () {
            Navigator.of(ctx).pop();
            onFile?.call();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                '첨부 파일 선택',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 20),
              _AttachmentOptionCard(
                icon: Icons.photo_camera_outlined,
                iconColor: AppColors.primary,
                iconBackground: AppColors.attachmentCameraBg,
                title: '카메라',
                subtitle: '실시간 레퍼런스 촬영',
                onTap: onCamera,
              ),
              const SizedBox(height: 10),
              _AttachmentOptionCard(
                icon: Icons.photo_library_outlined,
                iconColor: const Color(0xFFDB2777),
                iconBackground: AppColors.attachmentGalleryBg,
                title: '갤러리',
                subtitle: '캐릭터 시트 및 이미지 업로드',
                onTap: onGallery,
              ),
              const SizedBox(height: 10),
              _AttachmentOptionCard(
                icon: Icons.description_outlined,
                iconColor: const Color(0xFF0D9488),
                iconBackground: AppColors.attachmentFileBg,
                title: '파일',
                subtitle: 'PSD, TXT, PDF 문서 첨부',
                onTap: onFile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttachmentOptionCard extends StatelessWidget {
  const _AttachmentOptionCard({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.chipBackground,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 26, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
