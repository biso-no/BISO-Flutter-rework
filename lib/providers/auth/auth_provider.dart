import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/models/student_id_model.dart';
import '../../data/models/membership_model.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/membership_service.dart';
import '../../data/services/robust_document_service.dart';

import '../../core/logging/print_migration.dart';
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});

class AuthState {
  final UserModel? user;
  final StudentIdModel? studentRecord;
  final MembershipVerificationResult? membershipVerification;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;
  final String? pendingUserId; // Store userId from OTP send
  final bool hasProfile;
  final bool isProfileComplete;

  const AuthState({
    this.user,
    this.studentRecord,
    this.membershipVerification,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
    this.pendingUserId,
    this.hasProfile = false,
    this.isProfileComplete = false,
  });

  AuthState copyWith({
    UserModel? user,
    StudentIdModel? studentRecord,
    MembershipVerificationResult? membershipVerification,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
    String? pendingUserId,
    bool? hasProfile,
    bool? isProfileComplete,
  }) {
    return AuthState(
      user: user ?? this.user,
      studentRecord: studentRecord ?? this.studentRecord,
      membershipVerification: membershipVerification ?? this.membershipVerification,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      pendingUserId: pendingUserId ?? this.pendingUserId,
      hasProfile: hasProfile ?? this.hasProfile,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }

  // Computed properties
  bool get hasStudentId => studentRecord != null;
  String? get studentNumber => studentRecord?.studentNumber;
  bool get isStudentVerified => studentRecord?.isVerified ?? false;
  bool get isStudentMember => membershipVerification?.isMember ?? false;
  bool get hasValidMembership => membershipVerification?.isMember ?? false;
  MembershipModel? get membershipDetails => membershipVerification?.membership;
  String get membershipStatus {
    if (!hasStudentId) return 'No Student ID';
    if (!isStudentVerified) return 'Student ID Pending Verification';
    if (membershipVerification == null) return 'Membership Not Checked';
    if (membershipVerification!.isMember) return 'Active Member';
    return 'Not a Member';
  }
  bool get needsOnboarding => isAuthenticated && !isProfileComplete;
  bool get needsStudentId => isAuthenticated && !hasStudentId;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final MembershipService _membershipService = MembershipService();

  AuthNotifier(this._authService) : super(const AuthState()) {
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = await _authService.getCurrentUser();
      
      // If user exists, also load their complete profile
      if (user != null) {
        await _loadCompleteProfile(user.id);
      } else {
        state = state.copyWith(
          user: null,
          isAuthenticated: false,
          isLoading: false,
          hasProfile: false,
          isProfileComplete: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
        isAuthenticated: false,
        hasProfile: false,
        isProfileComplete: false,
      );
    }
  }

  /// Loads complete user profile from database using RobustDocumentService
  Future<void> _loadCompleteProfile(String userId) async {
    try {
      logPrint('🔐 AuthProvider: Loading complete profile for userId: $userId');
      
      // Use RobustDocumentService to handle SDK issues
      final documentData = await RobustDocumentService.getDocumentRobust(
        databaseId: 'app',
        collectionId: 'user',
        documentId: userId,
      );

      final profile = UserModel.fromMap(documentData);
      logPrint('🔐 AuthProvider: Profile loaded successfully: ${profile.name}');
      
      // Also load student record if available
      StudentIdModel? studentRecord;
      MembershipVerificationResult? membershipVerification;
      try {
        studentRecord = await _authService.getStudentIdRecord();
        logPrint('🔐 AuthProvider: Student record loaded: ${studentRecord?.studentNumber}');
        
        // If student record exists and is verified, check membership
        if (studentRecord != null && studentRecord.isVerified) {
          membershipVerification = await _membershipService.verifyMembership(studentRecord.studentNumber);
          logPrint('🔐 AuthProvider: Membership verified: ${membershipVerification.isMember}');
        }
      } catch (e) {
        logPrint('🔐 AuthProvider: No student record found or error: $e');
      }
      
      final hasProfile = true;
      final isProfileComplete = profile.campusId != null && profile.campusId!.isNotEmpty;
      
      state = state.copyWith(
        user: profile,
        studentRecord: studentRecord,
        membershipVerification: membershipVerification,
        isAuthenticated: true,
        isLoading: false,
        hasProfile: hasProfile,
        isProfileComplete: isProfileComplete,
      );
      
    } catch (e) {
      if (e.toString().contains('404')) {
        // Profile doesn't exist yet - user needs onboarding
        logPrint('🔐 AuthProvider: Profile not found (404) - user needs onboarding');
        
        // Get basic user info from auth service
        final basicUser = await _authService.getCurrentUser();
        
        state = state.copyWith(
          user: basicUser,
          isAuthenticated: true,
          isLoading: false,
          hasProfile: false,
          isProfileComplete: false,
        );
      } else {
        logPrint('🔐 AuthProvider: Error loading profile: $e');
        rethrow;
      }
    }
  }

  Future<void> sendOtp(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final userId = await _authService.sendOtp(email);
      state = state.copyWith(isLoading: false, pendingUserId: userId);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
        pendingUserId: null,
      );
      rethrow;
    }
  }

  Future<void> verifyOtp(String userId, String secret) async {
    logPrint('🔥 DEBUG: Starting verifyOtp with userId: $userId, secret: $secret');
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = await _authService.verifyOtp(userId, secret);
      logPrint('🔥 DEBUG: OTP verification successful, user: ${user.email}');
      
      // After successful OTP verification, load complete profile
      await _loadCompleteProfile(user.id);
      
      // Clear pending userId
      state = state.copyWith(pendingUserId: null);
    } catch (e) {
      logPrint('🔥 DEBUG: OTP verification failed: $e');
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }

  Future<void> createProfile({
    required String name,
    String? phone,
    String? address,
    String? city,
    String? zipCode,
    String? campusId,
    List<String>? departments,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = await _authService.createUserProfile(
        name: name,
        phone: phone,
        address: address,
        city: city,
        zipCode: zipCode,
        campusId: campusId,
        departments: departments,
      );
      
      final hasProfile = true;
      final isProfileComplete = campusId != null && campusId.isNotEmpty;
      
      state = state.copyWith(
        user: user,
        isLoading: false,
        hasProfile: hasProfile,
        isProfileComplete: isProfileComplete,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? address,
    String? city,
    String? zipCode,
    String? campusId,
    List<String>? departments,
    dynamic avatarFile, // XFile or File
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final updatedUser = await _authService.updateUserProfile(
        name: name,
        phone: phone,
        address: address,
        city: city,
        zipCode: zipCode,
        campusId: campusId,
        departments: departments,
        avatarFile: avatarFile,
      );
      
      final hasProfile = true;
      final isProfileComplete = updatedUser.campusId != null && updatedUser.campusId!.isNotEmpty;
      
      state = state.copyWith(
        user: updatedUser,
        isLoading: false,
        hasProfile: hasProfile,
        isProfileComplete: isProfileComplete,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }

  Future<void> signOut() async {
    await logout();
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _authService.logout();
      // Clear JWT cache when user signs out
      RobustDocumentService.clearJwtCache();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> clearSession() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _authService.clearSession();
      // Clear JWT cache when session is cleared
      RobustDocumentService.clearJwtCache();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Refresh complete profile (useful after updates)
  Future<void> refreshProfile() async {
    final currentUser = state.user;
    if (currentUser != null) {
      await _loadCompleteProfile(currentUser.id);
    }
  }

  /// Register student ID via OAuth
  Future<void> registerStudentIdViaOAuth() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final studentNumber = await _authService.registerStudentIdViaOAuth();
      
      // Reload profile to get updated student information
      final currentUser = state.user;
      if (currentUser != null) {
        await _loadCompleteProfile(currentUser.id);
      }
      
      // Check membership status
      final isMember = await _authService.checkMembershipStatus(studentNumber);
      if (state.studentRecord != null && isMember) {
        await _authService.updateMembershipStatus(
          studentId: state.studentRecord!.id,
          isMember: true,
        );
        // Reload again to get updated membership status
        if (currentUser != null) {
          await _loadCompleteProfile(currentUser.id);
        }
      }
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }


  /// Check and update membership status using proper membership verification
  Future<void> checkMembershipStatus() async {
    final studentRecord = state.studentRecord;
    if (studentRecord == null || !studentRecord.isVerified) {
      return;
    }
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final membershipVerification = await _membershipService.verifyMembership(studentRecord.studentNumber);
      
      // Update the membership status in the student record if needed
      if (membershipVerification.isMember != studentRecord.isMember) {
        final updatedRecord = await _authService.updateMembershipStatus(
          studentId: studentRecord.id,
          isMember: membershipVerification.isMember,
          membershipExpiry: membershipVerification.membership?.expiryDate,
          membershipDetails: membershipVerification.membership?.toMap(),
        );
        
        state = state.copyWith(
          studentRecord: updatedRecord,
          membershipVerification: membershipVerification,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          membershipVerification: membershipVerification,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Remove student ID
  Future<void> removeStudentId() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _authService.removeStudentId();
      
      state = state.copyWith(
        studentRecord: null,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }

  /// Launch membership purchase page
  Future<void> launchMembershipPurchase() async {
    try {
      await _authService.launchMembershipPurchase();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
}

// Helper providers for simplified access
final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.isAuthenticated;
});

final hasProfileProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.hasProfile;
});

final isProfileCompleteProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.isProfileComplete;
});

final hasStudentIdProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.hasStudentId;
});

final studentNumberProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.studentNumber;
});

final needsOnboardingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.needsOnboarding;
});

// Student-related providers
final studentRecordProvider = Provider<StudentIdModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.studentRecord;
});

final isStudentVerifiedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.isStudentVerified;
});

final isStudentMemberProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.isStudentMember;
});

final hasValidMembershipProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.hasValidMembership;
});

final membershipStatusProvider = Provider<String>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.membershipStatus;
});