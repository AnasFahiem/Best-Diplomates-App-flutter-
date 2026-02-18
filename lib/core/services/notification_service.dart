import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Initialize the notification plugin. Call once in main().
  Future<void> initialize() async {
    if (_initialized) return;

    // Skip initialization on platforms that aren't Android or iOS (e.g., Windows, Web)
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      debugPrint('NotificationService: Skipping initialization on this platform.');
      return;
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings: initSettings);
    _initialized = true;
  }

  // ── Preference helpers ──

  Future<bool> _isEnabled(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? true;
  }

  // ── Show a notification immediately ──

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) return; // Guard against uninitialized usage
    
    // Check master switch
    if (!await _isEnabled('push_notifications')) return;

    const androidDetails = AndroidNotificationDetails(
      'general_channel',
      'General Notifications',
      channelDescription: 'General app notifications',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  // ── Category-specific notifications ──

  /// Show a notification about an application status change.
  Future<void> showApplicationUpdate({
    required String title,
    required String body,
  }) async {
    if (!_initialized) return;

    if (!await _isEnabled('push_notifications')) return;
    if (!await _isEnabled('application_updates')) return;

    const androidDetails = AndroidNotificationDetails(
      'application_updates',
      'Application Updates',
      channelDescription: 'Notifications about your application status changes',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
    );

    await _plugin.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  /// Show a notification about a conference reminder.
  Future<void> showConferenceReminder({
    required String conferenceName,
    required String body,
  }) async {
    if (!_initialized) return;

    if (!await _isEnabled('push_notifications')) return;
    if (!await _isEnabled('conference_reminders')) return;

    const androidDetails = AndroidNotificationDetails(
      'conference_reminders',
      'Conference Reminders',
      channelDescription: 'Reminders for upcoming conferences',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
    );

    await _plugin.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: conferenceName,
      body: body,
      notificationDetails: details,
    );
  }

  /// Cancel a specific notification by ID.
  Future<void> cancelNotification(int id) async {
    if (!_initialized) return;
    await _plugin.cancel(id: id);
  }

  /// Cancel all scheduled and shown notifications.
  Future<void> cancelAllNotifications() async {
    if (!_initialized) return;
    await _plugin.cancelAll();
  }

  /// Send a test notification (useful for verifying the toggle works).
  Future<void> sendTestNotification() async {
    await showNotification(
      id: 9999,
      title: 'Future Diplomats',
      body: 'Notifications are enabled and working!',
    );
  }
}
