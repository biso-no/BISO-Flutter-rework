import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';
import 'appwrite_service.dart';
import '../../core/logging/app_logger.dart';

import '../../core/logging/print_migration.dart';
class AuthService {
  // Using simplified global Appwrite instances
  Account get _account => account;
  Databases get _databases => databases;
  Storage get _storage => storage;

  Future<String> sendOtp(String email) async {
    try {
      AppLogger.auth('Creating OTP for user', action: 'send_otp', extra: {
        'email': email.replaceAll(RegExp(r'(.{2}).*(@.*)'), r'\1***\2'), // Mask email for privacy
      });
      
      // Generate a unique ID for this OTP session
      final userId = ID.unique();
      
      final token = await _account.createEmailToken(
        userId: userId,
        email: email,
      );
      
      AppLogger.auth('OTP token created successfully', 
        userId: token.userId, 
        action: 'otp_created',
        extra: {
          'token_user_id': token.userId,
          'session_user_id': userId,
          'ids_match': userId == token.userId,
        },
      );
      
      return token.userId;
    } on AppwriteException catch (e) {
      throw AuthException('Failed to send OTP: ${e.message}');
    } catch (e) {
      throw AuthException('Network error occurred');
    }
  }

  Future<UserModel> verifyOtp(String userId, String secret) async {
    logPrint('🔥 DEBUG: Starting verifyOtp with userId: $userId, secret: $secret');
    try {
      // Create session with OTP
      logPrint('🔥 DEBUG: About to call _account.createSession...');
      logPrint('🔥 DEBUG: Parameters - userId: $userId, secret: $secret');
      final session = await _account.createSession(
        userId: userId,
        secret: secret,
      );
      logPrint('🔥 DEBUG: Session created successfully!');
      logPrint('🔥 DEBUG: Session ID: ${session.$id}');
      logPrint('🔥 DEBUG: Session userId: ${session.userId}');
      logPrint('🔥 DEBUG: Session provider: ${session.provider}');
      logPrint('🔥 DEBUG: Full session object: $session');

      // Get user account info
      final accountUser = await _account.get();

      // Check if user profile exists in database
      UserModel? userProfile;
      try {
        final doc = await _databases.getDocument(
          databaseId: AppConstants.databaseId,
          collectionId: 'user',
          documentId: accountUser.$id,
        );
        userProfile = UserModel.fromMap(doc.data);
      } catch (e) {
        // User profile doesn't exist, will need onboarding
      }

      return userProfile ?? UserModel(
        id: accountUser.$id,
        name: accountUser.name,
        email: accountUser.email,
      );
    } on AppwriteException catch (e) {
      logPrint('🔥 DEBUG: AppwriteException - Code: ${e.code}, Message: ${e.message}');
      logPrint('🔥 DEBUG: AppwriteException - Type: ${e.type}');
      logPrint('🔥 DEBUG: AppwriteException - Response: ${e.response}');
      throw AuthException('Invalid verification code: ${e.message}');
    } catch (e) {
      logPrint('🔥 DEBUG: General exception: $e');
      throw AuthException('Verification failed');
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final accountUser = await _account.get();
      
      try {
        final doc = await _databases.getDocument(
          databaseId: AppConstants.databaseId,
          collectionId: 'user',
          documentId: accountUser.$id,
          queries: [
            Query.select(['name', 'email', 'phone', 'address', 'city', 'zip', 'campus_id', 'avatar'])
          ]
        );
        return UserModel.fromMap(doc.data);
      } catch (e) {
        // User profile doesn't exist
        return UserModel(
          id: accountUser.$id,
          name: accountUser.name,
          email: accountUser.email,
        );
      }
    } on AppwriteException catch (e) {
      if (e.code == 401) {
        // User not authenticated
        return null;
      }
      throw AuthException('Failed to get current user: ${e.message}');
    } catch (e) {
      throw AuthException('Network error occurred');
    }
  }

  Future<void> logout() async {
    try {
      await _account.deleteSession(sessionId: 'current');
    } on AppwriteException catch (e) {
      throw AuthException('Logout failed: ${e.message}');
    } catch (e) {
      throw AuthException('Network error occurred');
    }
  }

  Future<void> clearSession() async {
    try {
      // Try to delete the current session
      await _account.deleteSession(sessionId: 'current');
    } catch (e) {
      // Session might not exist, which is fine
    }
    
    try {
      // Also try to delete all sessions to be thorough
      await _account.deleteSessions();
    } catch (e) {
      // Sessions might not exist, which is fine
    }
  }

  Future<UserModel> createUserProfile({
    required String name,
    String? phone,
    String? address,
    String? city,
    String? zipCode,
    String? campusId,
    List<String>? departments,
    String? bankAccount,
  }) async {
    try {
      final accountUser = await _account.get();
      
      final userData = {
        'name': name,
        'email': accountUser.email,
        'phone': phone,
        'address': address,
        'city': city,
        'zip': zipCode,
        'campus_id': campusId,
        'departments': departments ?? [],
        'bank_account': bankAccount,
      };

      final doc = await _databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: 'user',
        documentId: accountUser.$id,
        data: userData,
      );

      return UserModel.fromMap(doc.data);
    } on AppwriteException catch (e) {
      throw AuthException('Failed to create profile: ${e.message}');
    } catch (e) {
      throw AuthException('Network error occurred');
    }
  }

  Future<UserModel> updateUserProfile({
    String? name,
    String? phone,
    String? address,
    String? city,
    String? zipCode,
    String? campusId,
    List<String>? departments,
    dynamic avatarFile, // XFile or File
    String? bankAccount,
  }) async {
    try {
      // Get current user first
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        throw AuthException('User not authenticated');
      }

      // Handle avatar upload if provided
      String? avatarUrl = currentUser.avatarUrl;
      if (avatarFile != null) {
        try {
          avatarUrl = await _uploadAvatar(avatarFile, currentUser.id);
        } catch (e) {
          logPrint('🔴 Avatar upload failed: $e');
          // Continue with profile update even if avatar upload fails
        }
      }

      // Create updated user data
      final updatedData = {
        'name': name ?? currentUser.name,
        'phone': phone ?? currentUser.phone,
        'address': address ?? currentUser.address,
        'city': city ?? currentUser.city,
        'zip': zipCode ?? currentUser.zipCode,
        'campus_id': campusId ?? currentUser.campusId,
        'departments': departments ?? currentUser.departments,
        'avatar': avatarUrl,
        'bank_account': bankAccount ?? currentUser.bankAccount,
      };

      final doc = await _databases.updateDocument(
        databaseId: AppConstants.databaseId,
        collectionId: 'user',
        documentId: currentUser.id,
        data: updatedData,
      );

      return UserModel.fromMap(doc.data);
    } on AppwriteException catch (e) {
      throw AuthException('Failed to update profile: ${e.message}');
    } catch (e) {
      throw AuthException('Network error occurred: $e');
    }
  }

  /// Uploads an avatar image to Appwrite Storage and returns the file URL
  Future<String> _uploadAvatar(dynamic avatarFile, String userId) async {
    try {
      // Delete any existing avatar for this user
      try {
        final existingFiles = await _storage.listFiles(bucketId: 'avatars');
        final userAvatars = existingFiles.files.where((file) => file.name.startsWith('avatar_$userId'));
        for (final file in userAvatars) {
          await _storage.deleteFile(bucketId: 'avatars', fileId: file.$id);
        }
      } catch (e) {
        // Ignore errors when deleting old avatars
        logPrint('🟡 Could not delete existing avatar: $e');
      }

      // Create a unique file ID for this avatar
      final fileId = 'avatar_${userId}_${DateTime.now().millisecondsSinceEpoch}';
      
      // Prepare the file for upload
      InputFile inputFile;
      if (avatarFile is XFile) {
        inputFile = InputFile.fromPath(
          path: avatarFile.path,
          filename: '$fileId.jpg',
        );
      } else if (avatarFile is File) {
        inputFile = InputFile.fromPath(
          path: avatarFile.path,
          filename: '$fileId.jpg',
        );
      } else {
        throw AuthException('Invalid file type for avatar upload');
      }

      // Upload the file to Appwrite Storage
      final file = await _storage.createFile(
        bucketId: 'avatars',
        fileId: fileId,
        file: inputFile,
      );

      // Generate the file URL for viewing
      final fileUrl = '${AppConstants.appwriteEndpoint}/storage/buckets/avatars/files/${file.$id}/view?project=${AppConstants.appwriteProjectId}';
      
      logPrint('✅ Avatar uploaded successfully: $fileUrl');
      return fileUrl;
    } on AppwriteException catch (e) {
      logPrint('🔴 Appwrite avatar upload error: ${e.message}');
      throw AuthException('Failed to upload avatar: ${e.message}');
    } catch (e) {
      logPrint('🔴 General avatar upload error: $e');
      throw AuthException('Avatar upload failed: $e');
    }
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}