import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/auth/auth_provider.dart';

class MagicLinkVerifyScreen extends ConsumerStatefulWidget {
  final String userId;
  final String secret;

  const MagicLinkVerifyScreen({
    super.key,
    required this.userId,
    required this.secret,
  });

  @override
  ConsumerState<MagicLinkVerifyScreen> createState() => _MagicLinkVerifyScreenState();
}

class _MagicLinkVerifyScreenState extends ConsumerState<MagicLinkVerifyScreen> {
  bool _isVerifying = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Start verification immediately when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verifyMagicLink();
    });
  }

  Future<void> _verifyMagicLink() async {
    if (_isVerifying) return;
    
    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authStateProvider.notifier).verifyMagicLink(
        widget.userId,
        widget.secret,
      );

      if (mounted) {
        // Navigate to appropriate screen based on auth state
        final authState = ref.read(authStateProvider);
        if (authState.needsOnboarding) {
          context.go('/onboarding');
        } else {
          context.go('/');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isVerifying = false;
        });
      }
    }
  }

  Future<void> _clearSessionAndRetry() async {
    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authStateProvider.notifier).clearSession();
      // Wait a moment for session to clear
      await Future.delayed(const Duration(milliseconds: 500));
      await _verifyMagicLink();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isVerifying = false;
        });
      }
    }
  }

  void _requestFallbackCode() {
    // Navigate back to login with a flag to use OTP fallback
    context.go('/auth/login', extra: {'useFallback': true});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),

              // Logo/Title Section
              Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: AppColors.defaultBlue,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _errorMessage != null ? Icons.error : Icons.link,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _errorMessage != null 
                        ? 'Sign In Failed'
                        : _isVerifying 
                            ? 'Signing You In...'
                            : 'Welcome Back!',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: AppColors.strongBlue,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  if (_isVerifying && _errorMessage == null)
                    Text(
                      'Please wait while we verify your magic link...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),

              const SizedBox(height: 80),

              // Loading indicator or error message
              if (_isVerifying && _errorMessage == null)
                const Center(
                  child: CircularProgressIndicator(),
                ),

              if (_errorMessage != null) ...[
                // Error message
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getErrorMessage(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Clear Session and Retry button
                if (_shouldShowClearSession())
                  ElevatedButton.icon(
                    onPressed: _clearSessionAndRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Clear Session & Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.defaultBlue,
                      foregroundColor: Colors.white,
                    ),
                  ),

                const SizedBox(height: 16),

                // Fallback to OTP button
                OutlinedButton.icon(
                  onPressed: _requestFallbackCode,
                  icon: const Icon(Icons.mail_outline),
                  label: const Text('Get a Code Instead'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.defaultBlue,
                    side: const BorderSide(color: AppColors.defaultBlue),
                  ),
                ),
              ],

              const Spacer(),

              // Footer
              Text(
                'Norwegian Business School (BI)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getErrorMessage() {
    if (_errorMessage == null) return '';
    
    if (_errorMessage!.contains('expired') || _errorMessage!.contains('invalid')) {
      return 'This magic link has expired or is invalid. Please request a new one.';
    } else if (_errorMessage!.contains('active session')) {
      return 'You may already be signed in. Try clearing your session and signing in again.';
    } else {
      return 'Something went wrong while signing you in. Please try again.';
    }
  }

  bool _shouldShowClearSession() {
    return _errorMessage != null && 
           (_errorMessage!.contains('active session') || 
            _errorMessage!.contains('User (role: guests) missing scope') ||
            _errorMessage!.contains('Invalid credentials'));
  }
}