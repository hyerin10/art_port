import 'package:art_port/core/network/api_client.dart';
import 'package:art_port/features/chat/data/dto/chat_message_dto.dart';

class ChatMessageRepository {
  ChatMessageRepository(this._client);

  final ApiClient _client;

  Future<List<ChatMessageDto>> getAll({
    required String roomId,
    required String userId,
  }) async {
    final json = await _client.getList(
      '/chat-rooms/$roomId/messages',
      queryParameters: {'userId': userId},
    );
    return json.map(ChatMessageDto.fromJson).toList();
  }

  Future<ChatMessageDto> send({
    required String roomId,
    required String userId,
    required String type,
    String? content,
    String? attachmentUrl,
  }) async {
    final json = await _client.post(
      '/chat-rooms/$roomId/messages',
      queryParameters: {'userId': userId},
      body: {
        'type': type,
        'content': content,
        'attachmentUrl': ?attachmentUrl,
      },
    );
    return ChatMessageDto.fromJson(json);
  }

  Future<void> delete({
    required String messageId,
    required String userId,
  }) async {
    await _client.delete(
      '/messages/$messageId',
      queryParameters: {'userId': userId},
    );
  }
}
