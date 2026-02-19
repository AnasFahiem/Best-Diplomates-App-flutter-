class ChatMessageModel {
  final String id;
  final String? userId;
  final String senderRole; // 'admin' or 'user'
  final String messageText;
  final bool isAnnouncement;
  final bool isRead;
  final DateTime createdAt;

  ChatMessageModel({
    required this.id,
    this.userId,
    required this.senderRole,
    required this.messageText,
    this.isAnnouncement = false,
    this.isRead = false,
    required this.createdAt,
  });

  bool get isAdmin => senderRole == 'admin';
  bool get isUser => senderRole == 'user';

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      senderRole: json['sender_role']?.toString() ?? 'user',
      messageText: json['message_text']?.toString() ?? '',
      isAnnouncement: json['is_announcement'] == true,
      isRead: json['is_read'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'sender_role': senderRole,
      'message_text': messageText,
      'is_announcement': isAnnouncement,
      'is_read': isRead,
    };
  }

  ChatMessageModel copyWith({bool? isRead}) {
    return ChatMessageModel(
      id: id,
      userId: userId,
      senderRole: senderRole,
      messageText: messageText,
      isAnnouncement: isAnnouncement,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}
