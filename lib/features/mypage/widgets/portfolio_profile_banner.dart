import 'dart:io';

import 'package:art_port/core/constants/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 포트폴리오 편집 화면 상단 배경·프로필 이미지 배너
class PortfolioProfileBanner extends StatelessWidget {
  const PortfolioProfileBanner({
    super.key,
    required this.backgroundLocalPath,
    required this.backgroundNetworkUrl,
    required this.avatarLocalPath,
    required this.avatarNetworkUrl,
    required this.onBackgroundTap,
    required this.onAvatarTap,
  });

  final String? backgroundLocalPath;
  final String? backgroundNetworkUrl;
  final String? avatarLocalPath;
  final String? avatarNetworkUrl;
  final VoidCallback onBackgroundTap;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: onBackgroundTap,
              child: _PortfolioProfileImage(
                localPath: backgroundLocalPath,
                networkUrl: backgroundNetworkUrl,
                fit: BoxFit.cover,
                placeholder: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFE9E4FF),
                        Color(0xFFD4CBFF),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.photo_camera_outlined,
                          size: 20,
                          color: AppColors.primary.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '배경 이미지 변경',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            bottom: -36,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _PortfolioProfileImage(
                      localPath: avatarLocalPath,
                      networkUrl: avatarNetworkUrl,
                      fit: BoxFit.cover,
                      placeholder: const ColoredBox(
                        color: AppColors.chipBackground,
                        child: Icon(
                          Icons.person_rounded,
                          size: 40,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Material(
                    color: AppColors.primary,
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onAvatarTap,
                      child: const SizedBox(
                        width: 32,
                        height: 32,
                        child: Icon(
                          Icons.photo_camera_outlined,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PortfolioProfileImage extends StatelessWidget {
  const _PortfolioProfileImage({
    required this.localPath,
    required this.networkUrl,
    required this.fit,
    required this.placeholder,
  });

  final String? localPath;
  final String? networkUrl;
  final BoxFit fit;
  final Widget placeholder;

  @override
  Widget build(BuildContext context) {
    final source = localPath ?? networkUrl;
    if (source == null || source.isEmpty) return placeholder;

    if (source.startsWith('http')) {
      return Image.network(
        source,
        fit: fit,
        errorBuilder: (_, _, _) => placeholder,
      );
    }

    if (!kIsWeb) {
      return Image.file(
        File(source),
        fit: fit,
        errorBuilder: (_, _, _) => placeholder,
      );
    }

    return placeholder;
  }
}
