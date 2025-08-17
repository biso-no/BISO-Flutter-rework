import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/privacy_service.dart';

// Privacy service provider
final privacyServiceProvider = Provider<PrivacyService>((ref) {
  return PrivacyService();
});

// User privacy setting provider
final userPrivacyProvider = FutureProvider.family<bool?, String>((ref, userId) async {
  final privacyService = ref.read(privacyServiceProvider);
  return await privacyService.getUserPrivacySetting(userId);
});

// Privacy prompt check provider
final shouldPromptPrivacyProvider = FutureProvider.family<bool, String>((ref, userId) async {
  final privacyService = ref.read(privacyServiceProvider);
  return await privacyService.shouldPromptForPrivacy(userId);
});

// Privacy status description provider
final privacyStatusProvider = FutureProvider.family<String, String>((ref, userId) async {
  final privacyService = ref.read(privacyServiceProvider);
  return await privacyService.getPrivacyStatusDescription(userId);
});

// Update privacy setting notifier
class PrivacySettingNotifier extends StateNotifier<AsyncValue<bool>> {
  PrivacySettingNotifier(this._privacyService, this._userId) : super(const AsyncValue.loading());

  final PrivacyService _privacyService;
  final String _userId;

  Future<void> updatePrivacySetting(bool isPublic) async {
    state = const AsyncValue.loading();
    
    try {
      final success = await _privacyService.setUserPrivacySetting(_userId, isPublic);
      if (success) {
        state = AsyncValue.data(isPublic);
      } else {
        state = AsyncValue.error('Failed to update privacy setting', StackTrace.current);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> loadCurrentSetting() async {
    try {
      final setting = await _privacyService.getUserPrivacySetting(_userId);
      if (setting != null) {
        state = AsyncValue.data(setting);
      } else {
        state = const AsyncValue.data(false); // Default to private
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// Privacy setting notifier provider
final privacySettingProvider = StateNotifierProvider.family<PrivacySettingNotifier, AsyncValue<bool>, String>((ref, userId) {
  final privacyService = ref.read(privacyServiceProvider);
  return PrivacySettingNotifier(privacyService, userId);
});