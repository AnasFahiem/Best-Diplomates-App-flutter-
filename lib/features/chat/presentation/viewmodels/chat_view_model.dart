import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/chat_message_model.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../../../core/services/notification_service.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatRepository _repository;

  ChatViewModel({required ChatRepository repository}) : _repository = repository;

  List<ChatMessageModel> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;
  RealtimeChannel? _realtimeChannel;
  String? _currentUserId;
  bool _isChatOpen = false;

  // ── Getters ──
  List<ChatMessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isChatOpen => _isChatOpen;

  int get unreadCount => _messages.where((m) => m.isAdmin && !m.isRead).length;

  // ── Chat open/close state ──
  void setChatOpen(bool open) {
    _isChatOpen = open;
    if (open && _currentUserId != null) {
      markAllAsRead();
    }
    notifyListeners();
  }

  // ── Fetch messages ──
  Future<void> fetchMessages(String userId) async {
    _currentUserId = userId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _messages = await _repository.getMessages(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load messages';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Send a message ──
  Future<void> sendMessage(String messageText) async {
    if (_currentUserId == null || messageText.trim().isEmpty) return;

    try {
      final sent = await _repository.sendMessage(
        userId: _currentUserId!,
        messageText: messageText.trim(),
      );
      _messages.add(sent);
      notifyListeners();
    } catch (e) {
      debugPrint('ChatViewModel.sendMessage error: $e');
      _errorMessage = 'Failed to send message';
      notifyListeners();
    }
  }

  // ── Mark all admin messages as read ──
  Future<void> markAllAsRead() async {
    if (_currentUserId == null) return;

    try {
      await _repository.markAllAsRead(_currentUserId!);
      // Update local state
      _messages = _messages.map((m) {
        if (m.isAdmin && !m.isRead) {
          return m.copyWith(isRead: true);
        }
        return m;
      }).toList();
      notifyListeners();
    } catch (_) {
      // Silently fail – not critical
    }
  }

  // ── Real-time subscription ──
  void subscribeToRealtime(String userId) {
    _currentUserId = userId;

    // Unsubscribe from any existing channel first
    if (_realtimeChannel != null) {
      _repository.unsubscribe(_realtimeChannel!);
      _realtimeChannel = null;
    }

    _realtimeChannel = _repository.subscribeToMessages(
      userId: userId,
      onNewMessage: (message) {
        // Avoid duplicates
        final exists = _messages.any((m) => m.id == message.id);
        if (!exists) {
          _messages.add(message);
          notifyListeners();

          // If the chat is closed and the message is from admin, trigger notification
          if (message.isAdmin && !_isChatOpen) {
            _triggerNotification(message);
          }

          // If the chat is open, auto-mark as read
          if (_isChatOpen && message.isAdmin) {
            markAllAsRead();
          }
        }
      },
    );
  }

  void _triggerNotification(ChatMessageModel message) {
    final title = message.isAnnouncement ? '📢 Announcement' : '💬 Support Reply';
    NotificationService.instance.showChatMessage(
      title: title,
      body: message.messageText,
    );
  }

  // ── Initialize (call after login) ──
  void initialize(String userId) {
    fetchMessages(userId);
    subscribeToRealtime(userId);
  }

  // ── Cleanup ──
  @override
  void dispose() {
    if (_realtimeChannel != null) {
      _repository.unsubscribe(_realtimeChannel!);
    }
    super.dispose();
  }
}
