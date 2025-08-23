import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;
import 'package:appwrite/appwrite.dart';

import 'appwrite_service.dart';
import 'deep_link_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final Account _account = account;
  static final Messaging _messaging = messaging;

  String? _fcmToken;
  String? _pushTargetId;
  bool _isInitialized = false;
  final Map<String, bool> _topicSubscriptions = {};

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
        _createPushTarget(newToken);
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
        await _createPushTarget(_fcmToken!);
        await _loadTopicSubscriptions();
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

  /// Create push target in Appwrite
  Future<void> _createPushTarget(String token) async {
    try {
      // First try to create the push target
      final target = await _account.createPushTarget(
        targetId: ID.unique(),
        identifier: token,
        providerId: 'fcm',
      );
      
      _pushTargetId = target.$id;
      debugPrint('Push target created successfully: $_pushTargetId');

      // Also store in user preferences for reference
      await _updateTokenInAppwrite(token);
    } catch (e) {
      debugPrint('Failed to create push target: $e');
      // Fallback to storing in preferences only
      await _updateTokenInAppwrite(token);
    }
  }

  /// Store FCM token in Appwrite user preferences (backup method)
  Future<void> _updateTokenInAppwrite(String token) async {
    try {
      // Get current user preferences
      final prefs = await _account.getPrefs();

      // Update with new FCM token
      final updatedPrefs = Map<String, dynamic>.from(prefs.data);
      updatedPrefs['fcm_token'] = token;
      updatedPrefs['fcm_token_updated_at'] = DateTime.now().toIso8601String();
      if (_pushTargetId != null) {
        updatedPrefs['push_target_id'] = _pushTargetId;
      }

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

  /// Get push target ID
  String? get pushTargetId => _pushTargetId;

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topicId) async {
    try {
      if (_pushTargetId == null) {
        debugPrint('No push target available for topic subscription');
        return;
      }

      await _messaging.createSubscriber(
        topicId: topicId,
        subscriberId: ID.unique(),
        targetId: _pushTargetId!,
      );

      _topicSubscriptions[topicId] = true;
      await _saveTopicSubscriptions();
      debugPrint('Subscribed to topic: $topicId');
    } catch (e) {
      debugPrint('Failed to subscribe to topic $topicId: $e');
      rethrow;
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topicId) async {
    try {
      // We need to find the subscriber ID first
      // For now, we'll track the subscription status in preferences
      _topicSubscriptions[topicId] = false;
      await _saveTopicSubscriptions();
      debugPrint('Unsubscribed from topic: $topicId');
    } catch (e) {
      debugPrint('Failed to unsubscribe from topic $topicId: $e');
      rethrow;
    }
  }

  /// Get topic subscription status
  bool isSubscribedToTopic(String topicId) {
    return _topicSubscriptions[topicId] ?? false;
  }

  /// Get all topic subscriptions
  Map<String, bool> get topicSubscriptions => Map.from(_topicSubscriptions);

  /// Load topic subscriptions from user preferences
  Future<void> _loadTopicSubscriptions() async {
    try {
      final prefs = await _account.getPrefs();
      final subscriptions = prefs.data['topic_subscriptions'] as Map<String, dynamic>?;
      
      if (subscriptions != null) {
        _topicSubscriptions.clear();
        subscriptions.forEach((key, value) {
          _topicSubscriptions[key] = value as bool;
        });
      } else {
        // Set default subscriptions
        _topicSubscriptions.addAll({
          'events': true,
          'products': true,
          'jobs': true,
          'expenses': false,
        });
        await _saveTopicSubscriptions();
      }
      
      debugPrint('Loaded topic subscriptions: $_topicSubscriptions');
    } catch (e) {
      debugPrint('Failed to load topic subscriptions: $e');
    }
  }

  /// Save topic subscriptions to user preferences
  Future<void> _saveTopicSubscriptions() async {
    try {
      final prefs = await _account.getPrefs();
      final updatedPrefs = Map<String, dynamic>.from(prefs.data);
      updatedPrefs['topic_subscriptions'] = _topicSubscriptions;
      updatedPrefs['topic_subscriptions_updated_at'] = DateTime.now().toIso8601String();

      await _account.updatePrefs(prefs: updatedPrefs);
      debugPrint('Topic subscriptions saved');
    } catch (e) {
      debugPrint('Failed to save topic subscriptions: $e');
    }
  }

  /// Update notification preference for a specific topic
  Future<void> updateTopicSubscription(String topicId, bool enabled) async {
    try {
      if (enabled) {
        await subscribeToTopic(topicId);
      } else {
        await unsubscribeFromTopic(topicId);
      }
    } catch (e) {
      debugPrint('Failed to update topic subscription for $topicId: $e');
      rethrow;
    }
  }

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
    final type = data['type'] as String?;
    
    switch (type) {
      case 'chat':
        _handleChatNotification(data);
        break;
      case 'event':
        _handleEventNotification(data);
        break;
      case 'product':
        _handleProductNotification(data);
        break;
      case 'job':
        _handleJobNotification(data);
        break;
      case 'expense':
        _handleExpenseNotification(data);
        break;
      default:
        debugPrint('Unknown notification type: $type');
    }
  }

  /// Handle chat notification tap
  void _handleChatNotification(Map<String, dynamic> data) {
    final chatId = data['chat_id'] as String?;
    if (chatId != null) {
      debugPrint('Navigating to chat: $chatId');
      final uri = Uri.parse('biso://chat?id=$chatId');
      final deepLinkService = DeepLinkService();
      deepLinkService.handleDeepLink(uri);
    }
  }

  /// Handle event notification tap
  void _handleEventNotification(Map<String, dynamic> data) {
    final eventId = data['event_id'] as String?;
    if (eventId != null) {
      debugPrint('Navigating to event: $eventId');
      final uri = Uri.parse('biso://event?id=$eventId');
      final deepLinkService = DeepLinkService();
      deepLinkService.handleDeepLink(uri);
    }
  }

  /// Handle product notification tap
  void _handleProductNotification(Map<String, dynamic> data) {
    final productId = data['product_id'] as String?;
    if (productId != null) {
      debugPrint('Navigating to product: $productId');
      final uri = Uri.parse('biso://product?id=$productId');
      final deepLinkService = DeepLinkService();
      deepLinkService.handleDeepLink(uri);
    }
  }

  /// Handle job notification tap
  void _handleJobNotification(Map<String, dynamic> data) {
    final jobId = data['job_id'] as String?;
    if (jobId != null) {
      debugPrint('Navigating to job: $jobId');
      final uri = Uri.parse('biso://job?id=$jobId');
      final deepLinkService = DeepLinkService();
      deepLinkService.handleDeepLink(uri);
    }
  }

  /// Handle expense notification tap
  void _handleExpenseNotification(Map<String, dynamic> data) {
    final expenseId = data['expense_id'] as String?;
    if (expenseId != null) {
      debugPrint('Navigating to expense: $expenseId');
      final uri = Uri.parse('biso://expense?id=$expenseId');
      final deepLinkService = DeepLinkService();
      deepLinkService.handleDeepLink(uri);
    }
  }

  /// Remove FCM token (on logout)
  Future<void> clearToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      _fcmToken = null;
      _pushTargetId = null;
      _topicSubscriptions.clear();

      // Remove from Appwrite preferences
      final prefs = await _account.getPrefs();
      final updatedPrefs = Map<String, dynamic>.from(prefs.data);
      updatedPrefs.remove('fcm_token');
      updatedPrefs.remove('fcm_token_updated_at');
      updatedPrefs.remove('push_target_id');
      updatedPrefs.remove('topic_subscriptions');
      updatedPrefs.remove('topic_subscriptions_updated_at');

      await _account.updatePrefs(prefs: updatedPrefs);
      debugPrint('FCM token and push target cleared');
    } catch (e) {
      debugPrint('Failed to clear FCM token: $e');
    }
  }
}
