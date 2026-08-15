import 'package:art_port/core/network/api_client.dart';
import 'package:art_port/features/chat/data/dto/chat_room_dto.dart';

class ChatRoomRepository {
  ChatRoomRepository(this._client);

  final ApiClient _client;

  Future<List<ChatRoomDto>> getAll() async {
    final json = await _client.getList('/chat-rooms');
    return json.map(ChatRoomDto.fromJson).toList();
  }

  Future<ChatRoomDto> getById(String roomId) async {
    final json = await _client.get('/chat-rooms/$roomId');
    return ChatRoomDto.fromJson(json);
  }

  Future<ChatRoomDto> findOrCreate({
    required String clientId,
    required String artistId,
  }) async {
    final json = await _client.post(
      '/chat-rooms',
      body: {'clientId': clientId, 'artistId': artistId},
    );
    return ChatRoomDto.fromJson(json);
  }

  Future<ChatRoomDto> markRead(String roomId) async {
    final json = await _client.patch('/chat-rooms/$roomId/read');
    return ChatRoomDto.fromJson(json);
  }

  Future<void> delete(String roomId) async {
    await _client.delete('/chat-rooms/$roomId');
  }
}
