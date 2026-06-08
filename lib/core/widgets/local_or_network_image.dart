import 'dart:io';

import 'package:art_port/core/constants/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 로컬 파일 또는 네트워크 URL 이미지
class LocalOrNetworkImage extends StatelessWidget {
  const LocalOrNetworkImage({
    super.key,
    required this.source,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorPlaceholder,
  });

  final String? source;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorPlaceholder;

  static Widget get defaultPlaceholder => const ColoredBox(
        color: AppColors.chipBackground,
        child: Icon(Icons.image_outlined, color: AppColors.textMuted),
      );

  static Widget get defaultErrorPlaceholder => const ColoredBox(
        color: AppColors.chipBackground,
        child: Icon(Icons.broken_image_outlined, color: AppColors.textMuted),
      );

  @override
  Widget build(BuildContext context) {
    final emptyPlaceholder = placeholder ?? defaultPlaceholder;
    final failedPlaceholder = errorPlaceholder ?? defaultErrorPlaceholder;

    if (source == null || source!.isEmpty) {
      return emptyPlaceholder;
    }

    if (source!.startsWith('http')) {
      return Image.network(
        source!,
        fit: fit,
        errorBuilder: (_, _, _) => failedPlaceholder,
      );
    }

    if (!kIsWeb) {
      return Image.file(
        File(source!),
        fit: fit,
        errorBuilder: (_, _, _) => failedPlaceholder,
      );
    }

    return emptyPlaceholder;
  }
}
