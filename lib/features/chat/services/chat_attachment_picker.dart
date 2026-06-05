import 'package:art_port/features/chat/models/pending_attachment.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

/// 카메라·갤러리·파일 선택 (즉시 전송 없음 → 대기 목록에 추가)
abstract final class ChatAttachmentPicker {
  static final _imagePicker = ImagePicker();

  static Future<List<PendingAttachment>> pickFromCamera() async {
    final photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (photo == null) return [];

    return [
      _imageAttachment(photo),
    ];
  }

  static Future<List<PendingAttachment>> pickFromGallery() async {
    final photos = await _imagePicker.pickMultiImage(imageQuality: 85);
    final base = DateTime.now().microsecondsSinceEpoch;
    return [
      for (var i = 0; i < photos.length; i++)
        _imageAttachment(photos[i], idSuffix: '$base-$i'),
    ];
  }

  static Future<List<PendingAttachment>> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: const ['psd', 'txt', 'pdf', 'png', 'jpg', 'jpeg'],
    );
    if (result == null || result.files.isEmpty) return [];

    final items = <PendingAttachment>[];
    for (final file in result.files) {
      final name = file.name;
      if (name.isEmpty) continue;

      final isImage = _isImageFileName(name);
      items.add(
        PendingAttachment(
          id: 'pending-${DateTime.now().microsecondsSinceEpoch}-${items.length}',
          fileName: name,
          kind: isImage ? PendingAttachmentKind.image : PendingAttachmentKind.file,
          localPath: file.path,
          sizeBytes: file.size,
        ),
      );
    }
    return items;
  }

  static PendingAttachment _imageAttachment(
    XFile file, {
    String? idSuffix,
  }) {
    return PendingAttachment(
      id: 'pending-${idSuffix ?? DateTime.now().microsecondsSinceEpoch}',
      fileName: _fileNameFromPath(file.name, file.path),
      kind: PendingAttachmentKind.image,
      localPath: file.path,
      sizeBytes: null,
    );
  }

  static String _fileNameFromPath(String name, String? path) {
    if (name.isNotEmpty) return name;
    if (path == null || path.isEmpty) return 'image.jpg';
    final segments = path.split(RegExp(r'[/\\]'));
    return segments.isNotEmpty ? segments.last : 'image.jpg';
  }

  static bool _isImageFileName(String name) {
    final lower = name.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif');
  }
}
