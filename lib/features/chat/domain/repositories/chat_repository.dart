import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/chat_message_model.dart';

abstract class ChatRepository {
  Future<List<ChatMessageModel>> getMessages(String userId);
  Future<ChatMessageModel> sendMessage({required String userId, required String messageText});
  Future<void> markAllAsRead(String userId);
  RealtimeChannel subscribeToMessages({
    required String userId,
    required void Function(ChatMessageModel message) onNewMessage,
  });
  Future<void> unsubscribe(RealtimeChannel channel);
}
