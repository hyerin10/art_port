/// 업로드 대기 중인 첨부 파일
enum PendingAttachmentKind { image, file }

class PendingAttachment {
  const PendingAttachment({
    required this.id,
    required this.fileName,
    required this.kind,
    this.localPath,
    this.sizeBytes,
  });

  final String id;
  final String fileName;
  final PendingAttachmentKind kind;
  final String? localPath;
  final int? sizeBytes;

  String? get sizeLabel {
    final bytes = sizeBytes;
    if (bytes == null) return null;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
