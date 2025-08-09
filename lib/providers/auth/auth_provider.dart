import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';

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

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
    this.pendingUserId,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
    String? pendingUserId,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      pendingUserId: pendingUserId ?? this.pendingUserId,
    );
  }
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
      state = state.copyWith(
        user: user,
        isAuthenticated: user != null,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
        isAuthenticated: false,
      );
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
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
        pendingUserId: null, // Clear pending userId after successful verification
      );
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
      state = state.copyWith(
        user: user,
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
      state = state.copyWith(
        user: updatedUser,
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

  Future<void> signOut() async {
    await logout();
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _authService.logout();
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
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }
}