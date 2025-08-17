import '../../core/constants/app_constants.dart';
import 'robust_document_service.dart';

class PrivacyService {
  static final PrivacyService _instance = PrivacyService._internal();
  factory PrivacyService() => _instance;
  PrivacyService._internal();

  /// Check if user has set their privacy preference
  /// Returns null if not set, true if public, false if private
  Future<bool?> getUserPrivacySetting(String userId) async {
    try {
      final document = await RobustDocumentService.getDocumentRobust(
        databaseId: AppConstants.databaseId,
        collectionId: 'user',
        documentId: userId,
      );

      return document['is_public'] as bool?;
    } catch (e) {
      return null;
    }
  }

  /// Update user's privacy setting
  Future<bool> setUserPrivacySetting(String userId, bool isPublic) async {
    try {
      await RobustDocumentService.updateDocumentRobust(
        databaseId: AppConstants.databaseId,
        collectionId: 'user',
        documentId: userId,
        data: {'is_public': isPublic},
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if user should be prompted for privacy setting
  /// Returns true if user has null privacy setting (hasn't been asked)
  Future<bool> shouldPromptForPrivacy(String userId) async {
    final setting = await getUserPrivacySetting(userId);
    return setting == null;
  }

  /// Get a user's current privacy status with helpful description
  Future<String> getPrivacyStatusDescription(String userId) async {
    final isPublic = await getUserPrivacySetting(userId);
    
    if (isPublic == null) {
      return 'Privacy setting not configured';
    } else if (isPublic) {
      return 'Public - Others can find and message you';
    } else {
      return 'Private - Others cannot find you in search';
    }
  }
}