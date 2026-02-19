import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../chat/data/models/chat_message_model.dart';

abstract class AdminRemoteDataSource {
  /// Fetch list of unique users who have sent support messages.
  Future<List<Map<String, dynamic>>> getUserThreads();

  /// Fetch all messages for a specific user (both user & admin).
  Future<List<ChatMessageModel>> getMessagesForUser(String userId);

  /// Send a reply to a specific user as admin.
  Future<ChatMessageModel> sendReply({
    required String userId,
    required String messageText,
  });

  /// Broadcast an announcement to all users.
  Future<ChatMessageModel> sendAnnouncement({required String messageText});

  /// Fetch all announcements.
  Future<List<ChatMessageModel>> getAnnouncements();
  /// Stream of all support messages for real-time updates.
  Stream<List<Map<String, dynamic>>> get messagesStream;

  /// Mark all messages from a user as read.
  Future<void> markMessagesAsRead(String userId);
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final SupabaseClient supabaseClient;

  AdminRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Stream<List<Map<String, dynamic>>> get messagesStream {
    return supabaseClient
        .from('support_messages')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
  }

  @override
  Future<List<Map<String, dynamic>>> getUserThreads() async {
    // Get unique users who have messages, with their last message and unread count
    final response = await supabaseClient
        .from('support_messages')
        .select('user_id, message_text, created_at, sender_role, is_read')
        .eq('is_announcement', false)
        .order('created_at', ascending: false);

    final List<dynamic> rows = response as List;
    // Group by user_id and pick the latest message per user
    final Map<String, Map<String, dynamic>> threads = {};
    for (final row in rows) {
      final uid = row['user_id'].toString();
      if (!threads.containsKey(uid)) {
        threads[uid] = {
          'user_id': uid,
          'last_message': row['message_text'],
          'last_message_at': row['created_at'],
          'last_sender_role': row['sender_role'],
          'unread_count': 0,
        };
      }
      // Count unread messages FROM user (not read by admin)
      if (row['sender_role'] == 'user' && row['is_read'] == false) {
        threads[uid]!['unread_count'] = (threads[uid]!['unread_count'] as int) + 1;
      }
    }

    // Now fetch user profile details (name, email) for each thread
    final userIds = threads.keys.toList();
    if (userIds.isNotEmpty) {
      final profiles = await supabaseClient
          .from('profiles')
          .select('id, first_name, last_name, email')
          .inFilter('id', userIds);

      for (final profile in (profiles as List)) {
        final uid = profile['id'].toString();
        if (threads.containsKey(uid)) {
          final firstName = profile['first_name'] ?? '';
          final lastName = profile['last_name'] ?? '';
          threads[uid]!['user_name'] = '$firstName $lastName'.trim();
          threads[uid]!['user_email'] = profile['email'] ?? '';
        }
      }
    }

    // Sort by last message time (newest first)
    final list = threads.values.toList();
    list.sort((a, b) => (b['last_message_at'] as String).compareTo(a['last_message_at'] as String));
    return list;
  }

  @override
  Future<List<ChatMessageModel>> getMessagesForUser(String userId) async {
    final response = await supabaseClient
        .from('support_messages')
        .select()
        .eq('user_id', userId)
        .eq('is_announcement', false)
        .order('created_at', ascending: true);

    return (response as List).map((e) => ChatMessageModel.fromJson(e)).toList();
  }

  @override
  Future<ChatMessageModel> sendReply({
    required String userId,
    required String messageText,
  }) async {
    final response = await supabaseClient
        .from('support_messages')
        .insert({
          'user_id': userId,
          'sender_role': 'admin',
          'message_text': messageText,
          'is_announcement': false,
          'is_read': false,
        })
        .select()
        .single();

    return ChatMessageModel.fromJson(response);
  }

  @override
  Future<ChatMessageModel> sendAnnouncement({required String messageText}) async {
    final response = await supabaseClient
        .from('support_messages')
        .insert({
          'user_id': null,
          'sender_role': 'admin',
          'message_text': messageText,
          'is_announcement': true,
          'is_read': false,
        })
        .select()
        .single();

    return ChatMessageModel.fromJson(response);
  }

  @override
  Future<List<ChatMessageModel>> getAnnouncements() async {
    final response = await supabaseClient
        .from('support_messages')
        .select()
        .eq('is_announcement', true)
        .order('created_at', ascending: false);

    return (response as List).map((e) => ChatMessageModel.fromJson(e)).toList();
  }

  @override
  Future<void> markMessagesAsRead(String userId) async {
    await supabaseClient
        .from('support_messages')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('sender_role', 'user')
        .eq('is_read', false);
  }
}
