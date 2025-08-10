import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/robust_document_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;
  final String? pendingUserId; // Store userId from OTP send
  final bool hasProfile;
  final bool isProfileComplete;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
    this.pendingUserId,
    this.hasProfile = false,
    this.isProfileComplete = false,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
    String? pendingUserId,
    bool? hasProfile,
    bool? isProfileComplete,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      pendingUserId: pendingUserId ?? this.pendingUserId,
      hasProfile: hasProfile ?? this.hasProfile,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }

  // Computed properties
  bool get hasStudentId => user?.studentId != null && user!.studentId!.isNotEmpty;
  String? get studentNumber => user?.studentId;
  bool get needsOnboarding => isAuthenticated && !isProfileComplete;
  bool get needsStudentId => isAuthenticated && !hasStudentId;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

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
      print('🔐 AuthProvider: Loading complete profile for userId: $userId');
      
      // Use RobustDocumentService to handle SDK issues
      final documentData = await RobustDocumentService.getDocumentRobust(
        databaseId: 'app',
        collectionId: 'user',
        documentId: userId,
      );

      final profile = UserModel.fromMap(documentData);
      print('🔐 AuthProvider: Profile loaded successfully: ${profile.name}');
      
      final hasProfile = true;
      final isProfileComplete = profile.campusId != null && profile.campusId!.isNotEmpty;
      
      state = state.copyWith(
        user: profile,
        isAuthenticated: true,
        isLoading: false,
        hasProfile: hasProfile,
        isProfileComplete: isProfileComplete,
      );
      
    } catch (e) {
      if (e.toString().contains('404')) {
        // Profile doesn't exist yet - user needs onboarding
        print('🔐 AuthProvider: Profile not found (404) - user needs onboarding');
        
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
        print('🔐 AuthProvider: Error loading profile: $e');
        throw e;
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
    print('🔥 DEBUG: Starting verifyOtp with userId: $userId, secret: $secret');
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = await _authService.verifyOtp(userId, secret);
      print('🔥 DEBUG: OTP verification successful, user: ${user.email}');
      
      // After successful OTP verification, load complete profile
      await _loadCompleteProfile(user.id);
      
      // Clear pending userId
      state = state.copyWith(pendingUserId: null);
    } catch (e) {
      print('🔥 DEBUG: OTP verification failed: $e');
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