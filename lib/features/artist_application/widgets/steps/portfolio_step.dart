import 'dart:io';

import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/artist_application/artist_application_providers.dart';
import 'package:art_port/features/artist_application/models/artist_application_data.dart';
import 'package:art_port/features/artist_application/widgets/artist_application_form_widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class PortfolioStep extends ConsumerWidget {
  const PortfolioStep({super.key});

  Future<void> _pickPortfolioImages(WidgetRef ref) async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(
      imageQuality: 85,
      limit: 5,
    );
    if (images.isEmpty) return;

    final notifier = ref.read(artistApplicationFormProvider.notifier);
    var count =
        ref.read(artistApplicationFormProvider).data.portfolioImagePaths.length;

    for (final image in images) {
      if (count >= 5) break;
      notifier.addPortfolioImage(image.path);
      count++;
    }
  }

  Future<void> _pickVerificationFiles(WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['psd', 'clip', 'mp4', 'mov', 'avi'],
    );
    if (result == null) return;

    final notifier = ref.read(artistApplicationFormProvider.notifier);
    for (final file in result.files) {
      if (file.path != null) {
        notifier.addVerificationFile(file.path!);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(artistApplicationFormProvider).data;
    final notifier = ref.read(artistApplicationFormProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ArtistApplicationStepTitle(
          titleKo: ArtistApplicationStep.portfolio.titleKo,
          titleEn: ArtistApplicationStep.portfolio.titleEn,
        ),
        const SizedBox(height: 24),
        const ArtistApplicationSectionHeader(
          title: '대표 포트폴리오 (3~5장)',
          icon: Icons.collections_outlined,
        ),
        const SizedBox(height: 12),
        if (data.portfolioImagePaths.isEmpty)
          ArtistApplicationUploadZone(
            title: '클릭하여 이미지 업로드',
            subtitle: 'PNG, JPG (최대 5장)',
            onTap: () => _pickPortfolioImages(ref),
          )
        else
          Column(
            children: [
              _PortfolioGrid(
                paths: data.portfolioImagePaths,
                onRemove: notifier.removePortfolioImage,
              ),
              if (data.portfolioImagePaths.length < 5) ...[
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () => _pickPortfolioImages(ref),
                  icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                  label: const Text('이미지 추가'),
                ),
              ],
            ],
          ),
        if (data.portfolioImagePaths.isNotEmpty &&
            data.portfolioImagePaths.length < 3)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '최소 3장 이상 업로드해 주세요. (${data.portfolioImagePaths.length}/3)',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.error,
              ),
            ),
          ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Expanded(
              child: ArtistApplicationSectionHeader(
                title: '레이어 분리 인증',
                icon: Icons.verified_outlined,
              ),
            ),
            IconButton(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('레이어 분리 인증'),
                    content: const Text(
                      'PSD, CLIP 원본 파일 또는 타임랩스 영상을 업로드하여 '
                      '본인이 직접 작업했음을 증명해 주세요.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('확인'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.info_outline, size: 20),
              color: AppColors.textMuted,
            ),
          ],
        ),
        const SizedBox(height: 12),
        ArtistApplicationUploadZone(
          title: data.verificationFilePaths.isEmpty
              ? 'PSD, CLIP, 타임랩스 영상'
              : '${data.verificationFilePaths.length}개 파일 업로드됨',
          subtitle: data.verificationFilePaths.isEmpty
              ? '클릭하여 파일 업로드'
              : null,
          icon: Icons.folder_open_outlined,
          onTap: () => _pickVerificationFiles(ref),
        ),
        const SizedBox(height: 24),
        const ArtistApplicationSectionHeader(
          title: '작업 영역 및 스타일 태그',
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ArtistApplicationData.styleTagOptions.map((tag) {
            final selected = data.styleTags.contains(tag);
            return FilterChip(
              label: Text(tag),
              selected: selected,
              onSelected: (_) => notifier.toggleStyleTag(tag),
              selectedColor: AppColors.primaryLight,
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
              side: BorderSide(
                color: selected ? AppColors.primary : AppColors.borderLight,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _PortfolioGrid extends StatelessWidget {
  const _PortfolioGrid({
    required this.paths,
    required this.onRemove,
  });

  final List<String> paths;
  final void Function(int index) onRemove;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: paths.length,
      itemBuilder: (context, index) {
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: kIsWeb
                  ? Image.network(paths[index], fit: BoxFit.cover)
                  : Image.file(File(paths[index]), fit: BoxFit.cover),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => onRemove(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
