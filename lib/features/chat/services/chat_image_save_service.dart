import 'dart:io';

import 'package:art_port/features/chat/models/chat_image_attachment.dart';
import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;

/// 갤러리 저장 결과
enum ChatImageSaveResult {
  success,
  permissionDenied,
  noSource,
  failed,
}

/// 채팅 이미지를 기기 갤러리/사진첩에 저장
abstract final class ChatImageSaveService {
  static Future<ChatImageSaveResult> saveToGallery(
    ChatImageAttachment attachment,
  ) async {
    if (!attachment.hasDisplaySource) {
      return ChatImageSaveResult.noSource;
    }

    if (kIsWeb) {
      return ChatImageSaveResult.failed;
    }

    try {
      final granted = await _ensureGalleryAccess();
      if (!granted) {
        return ChatImageSaveResult.permissionDenied;
      }

      final localPath = attachment.localPath;
      if (localPath != null) {
        final file = File(localPath);
        if (file.existsSync()) {
          await Gal.putImage(localPath);
          return ChatImageSaveResult.success;
        }
      }

      final url = attachment.networkUrl;
      if (url != null) {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode != 200) {
          return ChatImageSaveResult.failed;
        }
        await Gal.putImageBytes(
          response.bodyBytes,
          name: _baseName(attachment.fileName),
        );
        return ChatImageSaveResult.success;
      }

      return ChatImageSaveResult.noSource;
    } on GalException catch (e) {
      if (kDebugMode) {
        debugPrint('[ChatImageSaveService] GalException: ${e.type} — ${e.platformException}');
      }
      if (e.type == GalExceptionType.accessDenied) {
        return ChatImageSaveResult.permissionDenied;
      }
      return ChatImageSaveResult.failed;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[ChatImageSaveService] $e\n$st');
      }
      return ChatImageSaveResult.failed;
    }
  }

  static Future<bool> _ensureGalleryAccess() async {
    if (await Gal.hasAccess()) return true;
    return Gal.requestAccess();
  }

  static String _baseName(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot <= 0) return fileName;
    return fileName.substring(0, dot);
  }

  static String messageFor(ChatImageSaveResult result) {
    return switch (result) {
      ChatImageSaveResult.success => '이미지가 갤러리에 저장되었습니다.',
      ChatImageSaveResult.permissionDenied =>
        '사진 보관함 접근 권한이 필요합니다. 설정에서 허용해 주세요.',
      ChatImageSaveResult.noSource => '저장할 이미지를 찾을 수 없습니다.',
      ChatImageSaveResult.failed => '이미지 저장에 실패했습니다. 다시 시도해 주세요.',
    };
  }
}
