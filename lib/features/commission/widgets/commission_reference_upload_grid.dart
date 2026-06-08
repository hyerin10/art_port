import 'dart:io';

import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/core/widgets/dashed_border.dart';
import 'package:flutter/material.dart';

/// 커미션 신청 — 참고 이미지 업로드 그리드 (최대 6장)
class CommissionReferenceUploadGrid extends StatelessWidget {
  const CommissionReferenceUploadGrid({
    super.key,
    required this.imagePaths,
    required this.onUploadTap,
    required this.onRemove,
    this.maxImages = 6,
  });

  final List<String> imagePaths;
  final VoidCallback onUploadTap;
  final ValueChanged<int> onRemove;
  final int maxImages;

  @override
  Widget build(BuildContext context) {
    final canUpload = imagePaths.length < maxImages;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (var i = 0; i < imagePaths.length; i++)
          _ImageThumbnail(
            path: imagePaths[i],
            onRemove: () => onRemove(i),
          ),
        if (canUpload)
          _UploadButton(
            onTap: onUploadTap,
            size: imagePaths.isEmpty ? 96 : 80,
          ),
      ],
    );
  }
}

class _UploadButton extends StatelessWidget {
  const _UploadButton({required this.onTap, required this.size});

  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: DashedBorder(
            color: AppColors.borderLight,
            radius: 12,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.file_upload_outlined,
                    size: 24,
                    color: AppColors.textMuted,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '업로드',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageThumbnail extends StatelessWidget {
  const _ImageThumbnail({required this.path, required this.onRemove});

  final String path;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(path),
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 80,
                height: 80,
                color: AppColors.chipBackground,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
          Positioned(
            top: -6,
            right: -6,
            child: Material(
              color: const Color(0xFFEF4444),
              shape: const CircleBorder(),
              elevation: 2,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onRemove,
                child: const SizedBox(
                  width: 22,
                  height: 22,
                  child: Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
