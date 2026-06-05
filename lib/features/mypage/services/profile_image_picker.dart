import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// 프로필/포트폴리오 편집용 이미지 선택
abstract final class ProfileImagePicker {
  static final _imagePicker = ImagePicker();

  static Future<String?> pickFromCamera() async {
    final photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    return photo?.path;
  }

  static Future<String?> pickFromGallery() async {
    final photo = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    return photo?.path;
  }

  static Future<List<String>> pickMultipleFromGallery() async {
    final photos = await _imagePicker.pickMultiImage(imageQuality: 85);
    return [for (final photo in photos) photo.path];
  }
}

enum _ImagePickAction { camera, gallery }

/// 카메라 / 갤러리 선택 Bottom Sheet
Future<String?> showImageSourceBottomSheet(
  BuildContext context, {
  bool galleryOnly = false,
}) async {
  final action = await showModalBottomSheet<_ImagePickAction>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (!galleryOnly)
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('카메라로 촬영'),
                  onTap: () =>
                      Navigator.pop(context, _ImagePickAction.camera),
                ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(galleryOnly ? '갤러리에서 선택' : '갤러리에서 선택'),
                onTap: () => Navigator.pop(context, _ImagePickAction.gallery),
              ),
            ],
          ),
        ),
      );
    },
  );

  if (action == null) return null;

  switch (action) {
    case _ImagePickAction.camera:
      return ProfileImagePicker.pickFromCamera();
    case _ImagePickAction.gallery:
      return ProfileImagePicker.pickFromGallery();
  }
}

/// 포트폴리오 추가용 갤러리 선택 Bottom Sheet
Future<List<String>> showPortfolioGalleryBottomSheet(BuildContext context) async {
  final shouldPick = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('갤러리에서 선택'),
                onTap: () => Navigator.pop(context, true),
              ),
            ],
          ),
        ),
      );
    },
  );

  if (shouldPick != true) return [];
  return ProfileImagePicker.pickMultipleFromGallery();
}
