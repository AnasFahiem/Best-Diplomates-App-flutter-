import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/datasources/admin_remote_data_source.dart';
import '../../../chat/data/models/chat_message_model.dart';

class AdminViewModel extends ChangeNotifier {
  final AdminRemoteDataSource _dataSource;
  StreamSubscription? _messagesSubscription;

  AdminViewModel({required AdminRemoteDataSource dataSource}) : _dataSource = dataSource {
    _subscribeToMessages();
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    super.dispose();
  }

  void _subscribeToMessages() {
    _messagesSubscription = _dataSource.messagesStream.listen((_) {
      // Refresh threads without showing loading spinner
      fetchThreads(showLoading: false);

      // If a chat is open, refresh messages
      if (_selectedUserId != null) {
        _refreshChat(_selectedUserId!);
      }
    });
  }

  Future<void> _refreshChat(String userId) async {
    try {
      final msgs = await _dataSource.getMessagesForUser(userId);
      _chatMessages = msgs;
      notifyListeners();
      // Mark as read since we are viewing it
      await _dataSource.markMessagesAsRead(userId);
    } catch (e) {
      debugPrint('Error refreshing chat: $e');
    }
  }

  // ── User threads state ──
  List<Map<String, dynamic>> _threads = [];
  bool _isLoadingThreads = false;
  String? _selectedUserId;
  String? _selectedUserName;

  // ── Chat state ──
  List<ChatMessageModel> _chatMessages = [];
  bool _isLoadingChat = false;

  // ── Announcements state ──
  List<ChatMessageModel> _announcements = [];
  bool _isLoadingAnnouncements = false;

  // ── Error state ──
  String? _error;

  // ── Getters ──
  List<Map<String, dynamic>> get threads => _threads;
  bool get isLoadingThreads => _isLoadingThreads;
  String? get selectedUserId => _selectedUserId;
  String? get selectedUserName => _selectedUserName;
  List<ChatMessageModel> get chatMessages => _chatMessages;
  bool get isLoadingChat => _isLoadingChat;
  List<ChatMessageModel> get announcements => _announcements;
  bool get isLoadingAnnouncements => _isLoadingAnnouncements;
  String? get error => _error;

  // ── Fetch user threads ──
  Future<void> fetchThreads({bool showLoading = true}) async {
    if (showLoading) {
      _isLoadingThreads = true;
      _error = null;
      notifyListeners();
    }

    try {
      _threads = await _dataSource.getUserThreads();
      _isLoadingThreads = false;
      notifyListeners();
    } catch (e) {
      debugPrint('AdminViewModel.fetchThreads error: $e');
      _error = 'Failed to load conversations';
      _isLoadingThreads = false;
      notifyListeners();
    }
  }

  // ── Select a user thread ──
  Future<void> selectUser(String userId, String userName) async {
    _selectedUserId = userId;
    _selectedUserName = userName;
    _isLoadingChat = true;
    _error = null;
    notifyListeners();

    try {
      _chatMessages = await _dataSource.getMessagesForUser(userId);
      _isLoadingChat = false;
      notifyListeners();

      // Mark messages as read
      await _dataSource.markMessagesAsRead(userId);
      
      // Update local threads state to clear unread count
      final threadIndex = _threads.indexWhere((t) => t['user_id'] == userId);
      if (threadIndex != -1) {
        _threads[threadIndex]['unread_count'] = 0;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('AdminViewModel.selectUser error: $e');
      _error = 'Failed to load chat';
      _isLoadingChat = false;
      notifyListeners();
    }
  }

  // ── Send reply to selected user ──
  Future<void> sendReply(String messageText) async {
    if (_selectedUserId == null || messageText.trim().isEmpty) return;

    try {
      final sent = await _dataSource.sendReply(
        userId: _selectedUserId!,
        messageText: messageText.trim(),
      );
      // Directly add the sent message locally to update UI immediately
      // The stream will also trigger a refresh, but this makes it feel instant
      _chatMessages.add(sent);
      notifyListeners();
      
      // No need to manually refresh threads here as stream listener will do it
    } catch (e) {
      debugPrint('AdminViewModel.sendReply error: $e');
      _error = 'Failed to send reply';
      notifyListeners();
    }
  }

  // ── Fetch announcements ──
  Future<void> fetchAnnouncements() async {
    _isLoadingAnnouncements = true;
    _error = null;
    notifyListeners();

    try {
      _announcements = await _dataSource.getAnnouncements();
      _isLoadingAnnouncements = false;
      notifyListeners();
    } catch (e) {
      debugPrint('AdminViewModel.fetchAnnouncements error: $e');
      _error = 'Failed to load announcements';
      _isLoadingAnnouncements = false;
      notifyListeners();
    }
  }

  // ── Send announcement ──
  Future<void> sendAnnouncement(String messageText) async {
    if (messageText.trim().isEmpty) return;

    try {
      final sent = await _dataSource.sendAnnouncement(messageText: messageText.trim());
      _announcements.insert(0, sent);
      notifyListeners();
    } catch (e) {
      debugPrint('AdminViewModel.sendAnnouncement error: $e');
      _error = 'Failed to send announcement';
      notifyListeners();
    }
  }
}
