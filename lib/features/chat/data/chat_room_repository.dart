import 'package:art_port/core/network/api_client.dart';
import 'package:art_port/features/chat/data/dto/chat_room_dto.dart';

class ChatRoomRepository {
  ChatRoomRepository(this._client);

  final ApiClient _client;

  Future<List<ChatRoomDto>> getAll(String userId) async {
    final json = await _client.getList(
      '/chat-rooms',
      queryParameters: {'userId': userId},
    );
    return json.map(ChatRoomDto.fromJson).toList();
  }

  Future<ChatRoomDto> getById({
    required String roomId,
    required String userId,
  }) async {
    final json = await _client.get(
      '/chat-rooms/$roomId',
      queryParameters: {'userId': userId},
    );
    return ChatRoomDto.fromJson(json);
  }

  Future<ChatRoomDto> findOrCreate({
    required String userId,
    required String clientId,
    required String artistId,
  }) async {
    final json = await _client.post(
      '/chat-rooms',
      queryParameters: {'userId': userId},
      body: {'clientId': clientId, 'artistId': artistId},
    );
    return ChatRoomDto.fromJson(json);
  }

  Future<ChatRoomDto> markRead({
    required String roomId,
    required String userId,
  }) async {
    final json = await _client.patch(
      '/chat-rooms/$roomId/read',
      queryParameters: {'userId': userId},
    );
    return ChatRoomDto.fromJson(json);
  }
}
