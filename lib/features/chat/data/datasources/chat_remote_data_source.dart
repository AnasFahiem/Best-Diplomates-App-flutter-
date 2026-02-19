import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_message_model.dart';

abstract class ChatRemoteDataSource {
  /// Fetch messages for this user + global announcements, ordered by time.
  Future<List<ChatMessageModel>> getMessages(String userId);

  /// Send a message from the user.
  Future<ChatMessageModel> sendMessage({
    required String userId,
    required String messageText,
  });

  /// Mark all unread messages as read for this user.
  Future<void> markAllAsRead(String userId);

  /// Subscribe to real-time inserts. Returns a StreamSubscription-like cancel callback.
  RealtimeChannel subscribeToMessages({
    required String userId,
    required void Function(ChatMessageModel message) onNewMessage,
  });

  /// Unsubscribe from real-time channel.
  Future<void> unsubscribe(RealtimeChannel channel);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final SupabaseClient supabaseClient;

  ChatRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<ChatMessageModel>> getMessages(String userId) async {
    final response = await supabaseClient
        .from('support_messages')
        .select()
        .or('user_id.eq.$userId,is_announcement.eq.true')
        .order('created_at', ascending: true);

    return (response as List)
        .map((e) => ChatMessageModel.fromJson(e))
        .toList();
  }

  @override
  Future<ChatMessageModel> sendMessage({
    required String userId,
    required String messageText,
  }) async {
    final response = await supabaseClient
        .from('support_messages')
        .insert({
          'user_id': userId,
          'sender_role': 'user',
          'message_text': messageText,
          'is_announcement': false,
          'is_read': false,
        })
        .select()
        .single();

    return ChatMessageModel.fromJson(response);
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    await supabaseClient
        .from('support_messages')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('sender_role', 'admin')
        .eq('is_read', false);
  }

  @override
  RealtimeChannel subscribeToMessages({
    required String userId,
    required void Function(ChatMessageModel message) onNewMessage,
  }) {
    final channel = supabaseClient.channel('support_messages_$userId');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'support_messages',
          callback: (payload) {
            final newRecord = payload.newRecord;
            if (newRecord.isNotEmpty) {
              final msg = ChatMessageModel.fromJson(newRecord);
              // Only deliver if it's for this user or an announcement
              if (msg.userId == userId || msg.isAnnouncement) {
                onNewMessage(msg);
              }
            }
          },
        )
        .subscribe();

    return channel;
  }

  @override
  Future<void> unsubscribe(RealtimeChannel channel) async {
    await supabaseClient.removeChannel(channel);
  }
}
