import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/notification_service.dart';

// Provider for the notification service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// Provider for checking if notifications are enabled
final notificationStatusProvider = FutureProvider<bool>((ref) async {
  final service = ref.read(notificationServiceProvider);
  return await service.areNotificationsEnabled();
});

// Provider for getting chat notification preference
final chatNotificationPreferenceProvider = FutureProvider<bool>((ref) async {
  final service = ref.read(notificationServiceProvider);
  return await service.getChatNotificationPreference();
});

// State notifier for managing notification preferences
class NotificationPreferencesNotifier extends StateNotifier<AsyncValue<Map<String, bool>>> {
  final NotificationService _notificationService;
  
  NotificationPreferencesNotifier(this._notificationService) : super(const AsyncValue.loading()) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      state = const AsyncValue.loading();
      final chatEnabled = await _notificationService.getChatNotificationPreference();
      state = AsyncValue.data({
        'chat_notifications': chatEnabled,
      });
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateChatNotifications(bool enabled) async {
    try {
      await _notificationService.updateChatNotificationPreference(enabled);
      
      // Update state
      final currentData = state.value ?? {};
      state = AsyncValue.data({
        ...currentData,
        'chat_notifications': enabled,
      });
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadPreferences();
  }
}

// Provider for notification preferences state notifier
final notificationPreferencesProvider = StateNotifierProvider<NotificationPreferencesNotifier, AsyncValue<Map<String, bool>>>((ref) {
  final service = ref.read(notificationServiceProvider);
  return NotificationPreferencesNotifier(service);
});