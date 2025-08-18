import 'package:appwrite/appwrite.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';
import '../models/student_id_model.dart';
import 'membership_service.dart';
import 'robust_document_service.dart';
import '../../core/logging/app_logger.dart';

class StudentService {
  // Other Appwrite modules (auth/functions) are fine; database access uses RobustDocumentService

  /// Initiates OAuth2 flow with Microsoft Azure for BI student account
  /// Returns the student ID extracted from the email
  Future<String> registerStudentIdViaOAuth() async {
    try {
      AppLogger.info('Starting OAuth student ID registration');
      
      // TODO: Implement OAuth2 flow with Microsoft Azure
      // This requires proper Azure tenant configuration in Appwrite
      throw StudentException('OAuth registration is not yet implemented. Please use manual registration for now.');
      
      // Note: The OAuth flow will be implemented once Azure tenant is configured
      // It should:
      // 1. Create OAuth2 session for Microsoft
      // 2. Verify @bi.no domain
      // 3. Extract student number from email
      // 4. Create verified student record
      // 5. Update user profile relationship
      
    } catch (e) {
      AppLogger.error('Student registration failed', error: e.toString());
      if (e is StudentException) {
        rethrow;
      }
      throw StudentException('Student registration failed: $e');
    }
  }

  /// Creates a student ID record in the student_id collection
  Future<StudentIdModel> createStudentIdRecord({
    required String userId,
    required String studentNumber,
    bool isVerified = false,
  }) async {
    try {
      final studentData = {
        'user_id': userId,
        'student_number': studentNumber,
        'verified': isVerified,
        'is_member': false, // Will be updated after membership check
        'verified_at': isVerified ? DateTime.now().toIso8601String() : null,
      };

      final createdData = await RobustDocumentService.createDocumentRobust(
        databaseId: AppConstants.databaseId,
        collectionId: 'student_id',
        data: studentData,
      );

      return StudentIdModel.fromMap(createdData);
    } catch (e) {
      throw StudentException('Failed to create student ID record: $e');
    }
  }

  // Note: Previously had a helper to update user-student relationship. Keep logic within specific flows to avoid unused function warnings.

  /// Checks membership status using the existing MembershipService
  /// Returns true if the student is a member
  Future<bool> checkMembershipStatus(String studentNumber) async {
    try {
      AppLogger.info('Checking membership status for student', extra: {
        'studentNumber': studentNumber,
      });

      // Use the existing MembershipService which properly calls verify_biso_membership
      final membershipService = MembershipService();
      final verificationResult = await membershipService.verifyMembership(studentNumber);
      
      AppLogger.info('Membership check completed', extra: {
        'studentNumber': studentNumber,
        'isMember': verificationResult.isMember,
        'membershipName': verificationResult.membership?.name,
      });

      return verificationResult.isMember;
    } catch (e) {
      AppLogger.error('Membership check error', error: e.toString());
      throw StudentException('Membership check failed: $e');
    }
  }

  // Removed write-based membership status updates. Verification is read-only via MembershipService.

  /// Gets student ID record for a user
  Future<StudentIdModel?> getStudentIdRecord(String userId) async {
    try {
      final documents = await RobustDocumentService.listDocumentsRobust(
        databaseId: AppConstants.databaseId,
        collectionId: 'student_id',
        queries: [
          Query.equal('user_id', userId).toString(),
          Query.limit(1).toString(),
        ],
      );

      if (documents.isEmpty) {
        return null;
      }

      return StudentIdModel.fromMap(documents.first);
    } catch (e) {
      throw StudentException('Failed to get student ID record: $e');
    }
  }


  /// Removes student ID record
  Future<void> removeStudentId(String userId) async {
    try {
      // Get student ID record
      final studentRecord = await getStudentIdRecord(userId);
      if (studentRecord == null) {
        return; // Nothing to remove
      }

      // Remove from student_id collection
      await RobustDocumentService.deleteDocumentRobust(
        databaseId: AppConstants.databaseId,
        collectionId: 'student_id',
        documentId: studentRecord.id,
      );

      // Update user profile to remove relationship
      await RobustDocumentService.updateDocumentRobust(
        databaseId: AppConstants.databaseId,
        collectionId: 'user',
        documentId: userId,
        data: {
          'student_id': null,
          'student': null,
        },
      );

      AppLogger.info('Student ID removed successfully', extra: {
        'userId': userId,
        'studentNumber': studentRecord.studentNumber,
      });
    } catch (e) {
      throw StudentException('Failed to remove student ID: $e');
    }
  }

  /// Launch membership purchase using the existing MembershipService
  Future<void> launchMembershipPurchase() async {
    try {
      // Use the existing membership service to get available memberships
      final membershipService = MembershipService();
      final availableMemberships = await membershipService.getAvailableMemberships();
      
      if (availableMemberships.isEmpty) {
        throw StudentException('No membership options available at the moment');
      }
      
      // For now, we'll launch the purchase page URL directly
      // In a complete implementation, you would show a membership selection dialog
      // and then call membershipService.initiateMembershipCheckout()
      const membershipUrl = 'https://biso.no/membership';
      
      if (await canLaunchUrl(Uri.parse(membershipUrl))) {
        await launchUrl(
          Uri.parse(membershipUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw StudentException('Could not open membership purchase page');
      }
    } catch (e) {
      throw StudentException('Failed to open membership page: $e');
    }
  }
}

class StudentException implements Exception {
  final String message;
  StudentException(this.message);

  @override
  String toString() => message;
}