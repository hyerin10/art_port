import 'dart:io';

import 'package:art_port/core/network/api_client.dart';
import 'package:art_port/core/network/api_exception.dart';
import 'package:art_port/core/network/network_providers.dart';
import 'package:art_port/core/network/resource_ids.dart';
import 'package:art_port/core/network/upload_purpose.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final uploadRepositoryProvider = Provider<UploadRepository>((ref) {
  return UploadRepository(ref.watch(apiClientProvider));
});

/// presign → PUT → fileUrl 업로드.
class UploadRepository {
  UploadRepository(this._client);

  final ApiClient _client;

  Future<String> uploadLocalFile({
    required String localPath,
    required UploadPurpose purpose,
  }) async {
    final file = File(localPath);
    if (!await file.exists()) {
      throw ApiException.unexpected('업로드할 파일을 찾을 수 없습니다.');
    }

    final bytes = await file.readAsBytes();
    final fileName = _fileName(localPath);
    final contentType = _contentTypeFor(fileName);

    final ticket = await _client.post(
      '/uploads/presign',
      body: {
        'purpose': purpose.apiValue,
        'contentType': contentType,
        'fileName': fileName,
        'sizeBytes': bytes.length,
      },
    );

    final uploadUrl = ticket['uploadUrl'] as String?;
    final fileUrl = ticket['fileUrl'] as String?;
    if (uploadUrl == null ||
        uploadUrl.isEmpty ||
        fileUrl == null ||
        fileUrl.isEmpty) {
      throw ApiException.unexpected('업로드 티켓 응답이 올바르지 않습니다.');
    }

    await _client.putBytes(
      uploadUrl,
      bytes: bytes,
      contentType: contentType,
    );

    return fileUrl;
  }

  /// 이미 원격이면 그대로, 로컬 경로면 업로드 후 fileUrl 반환.
  Future<List<String>> resolveToRemoteUrls({
    required List<String> pathsOrUrls,
    required UploadPurpose purpose,
  }) async {
    final urls = <String>[];
    for (final item in pathsOrUrls) {
      final trimmed = item.trim();
      if (trimmed.isEmpty) continue;
      if (ResourceIds.isRemoteUrl(trimmed)) {
        urls.add(trimmed);
        continue;
      }
      urls.add(
        await uploadLocalFile(localPath: trimmed, purpose: purpose),
      );
    }
    return urls;
  }

  static String _fileName(String path) {
    final normalized = path.replaceAll('\\', '/');
    final parts = normalized.split('/');
    final name = parts.isEmpty ? '' : parts.last;
    return name.isEmpty ? 'file.bin' : name;
  }

  static String _contentTypeFor(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.pdf')) return 'application/pdf';
    return 'application/octet-stream';
  }
}
