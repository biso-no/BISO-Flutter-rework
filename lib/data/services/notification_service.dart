import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;
import 'package:appwrite/appwrite.dart';

import 'appwrite_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final Account _account = account;

  String? _fcmToken;
  bool _isInitialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Configure Firebase Messaging
      await _configureFirebaseMessaging();

      // Get FCM token
      await _getFCMToken();

      _isInitialized = true;
      debugPrint('NotificationService initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize NotificationService: $e');
    }
  }

  /// Configure Firebase Messaging settings
  Future<void> _configureFirebaseMessaging() async {
    // Set foreground notification presentation options
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Listen to when user taps notification to open app
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Handle notification when app is launched from terminated state
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  /// Get FCM token for this device
  Future<String?> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $_fcmToken');

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        _updateTokenInAppwrite(newToken);
      });

      return _fcmToken;
    } catch (e) {
      debugPrint('Failed to get FCM token: $e');
      return null;
    }
  }

  /// Request notification permissions from the user
  Future<bool> requestPermission() async {
    try {
      // First check system permission
      final systemPermission = await permission_handler.Permission.notification
          .request();
      if (systemPermission != permission_handler.PermissionStatus.granted) {
        debugPrint('System notification permission denied');
        return false;
      }

      // Then request Firebase messaging permission
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      final isGranted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;

      debugPrint(
        'Firebase notification permission: ${settings.authorizationStatus}',
      );

      if (isGranted && _fcmToken != null) {
        await _updateTokenInAppwrite(_fcmToken!);
      }

      return isGranted;
    } catch (e) {
      debugPrint('Failed to request notification permission: $e');
      return false;
    }
  }

  /// Check if notifications are currently enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      final settings = await _firebaseMessaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      debugPrint('Failed to check notification status: $e');
      return false;
    }
  }

  /// Store FCM token in Appwrite user preferences
  Future<void> _updateTokenInAppwrite(String token) async {
    try {
      // Get current user preferences
      final prefs = await _account.getPrefs();

      // Update with new FCM token
      final updatedPrefs = Map<String, dynamic>.from(prefs.data);
      updatedPrefs['fcm_token'] = token;
      updatedPrefs['fcm_token_updated_at'] = DateTime.now().toIso8601String();

      // Save updated preferences
      await _account.updatePrefs(prefs: updatedPrefs);
      debugPrint('FCM token stored in Appwrite preferences');
    } catch (e) {
      debugPrint('Failed to store FCM token in Appwrite: $e');
    }
  }

  /// Update chat notification preference in Appwrite
  Future<void> updateChatNotificationPreference(bool enabled) async {
    try {
      // Get current user preferences
      final prefs = await _account.getPrefs();

      // Update chat notification preference
      final updatedPrefs = Map<String, dynamic>.from(prefs.data);
      updatedPrefs['chat_notifications'] = enabled;
      updatedPrefs['chat_notifications_updated_at'] = DateTime.now()
          .toIso8601String();

      // Save updated preferences
      await _account.updatePrefs(prefs: updatedPrefs);
      debugPrint('Chat notification preference updated: $enabled');
    } catch (e) {
      debugPrint('Failed to update chat notification preference: $e');
      rethrow;
    }
  }

  /// Get chat notification preference from Appwrite
  Future<bool> getChatNotificationPreference() async {
    try {
      final prefs = await _account.getPrefs();
      // Default to true if not set (opt-in for notifications)
      return prefs.data['chat_notifications'] ?? true;
    } catch (e) {
      debugPrint('Failed to get chat notification preference: $e');
      return true; // Default to enabled
    }
  }

  /// Get FCM token for current user
  String? get fcmToken => _fcmToken;

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Received foreground message: ${message.messageId}');
    debugPrint('Message data: ${message.data}');

    if (message.notification != null) {
      debugPrint('Message notification: ${message.notification!.title}');
      debugPrint('Message body: ${message.notification!.body}');
    }

    // You can show custom in-app notification here
    // For now, just log it
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.messageId}');
    debugPrint('Message data: ${message.data}');

    // Handle navigation based on message data
    final data = message.data;
    if (data.containsKey('chat_id')) {
      // Navigate to specific chat
      debugPrint('Navigating to chat: ${data['chat_id']}');
      // TODO: Implement navigation to chat
    }
  }

  /// Remove FCM token (on logout)
  Future<void> clearToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      _fcmToken = null;

      // Remove from Appwrite preferences
      final prefs = await _account.getPrefs();
      final updatedPrefs = Map<String, dynamic>.from(prefs.data);
      updatedPrefs.remove('fcm_token');
      updatedPrefs.remove('fcm_token_updated_at');

      await _account.updatePrefs(prefs: updatedPrefs);
      debugPrint('FCM token cleared');
    } catch (e) {
      debugPrint('Failed to clear FCM token: $e');
    }
  }
}
