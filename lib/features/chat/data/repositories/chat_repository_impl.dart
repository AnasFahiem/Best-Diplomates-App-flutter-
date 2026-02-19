import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';
import '../models/chat_message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ChatMessageModel>> getMessages(String userId) {
    return remoteDataSource.getMessages(userId);
  }

  @override
  Future<ChatMessageModel> sendMessage({required String userId, required String messageText}) {
    return remoteDataSource.sendMessage(userId: userId, messageText: messageText);
  }

  @override
  Future<void> markAllAsRead(String userId) {
    return remoteDataSource.markAllAsRead(userId);
  }

  @override
  RealtimeChannel subscribeToMessages({
    required String userId,
    required void Function(ChatMessageModel message) onNewMessage,
  }) {
    return remoteDataSource.subscribeToMessages(userId: userId, onNewMessage: onNewMessage);
  }

  @override
  Future<void> unsubscribe(RealtimeChannel channel) {
    return remoteDataSource.unsubscribe(channel);
  }
}
