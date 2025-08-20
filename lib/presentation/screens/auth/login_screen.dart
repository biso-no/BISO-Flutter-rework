import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../../providers/auth/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final bool useFallback;
  
  const LoginScreen({super.key, this.useFallback = false});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  late bool _useMagicLink;

  @override
  void initState() {
    super.initState();
    // Use fallback mode if specified, otherwise default to magic link
    _useMagicLink = !widget.useFallback;
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final l10n = AppLocalizations.of(context);

    if (value == null || value.isEmpty) {
      return l10n.enterValidEmail;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return l10n.enterValidEmail;
    }

    return null;
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_useMagicLink) {
        await ref.read(authStateProvider.notifier).sendMagicLink(_emailController.text);
        
        if (mounted) {
          // Show success message and instructions
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Magic link sent! Check your email and click the link to sign in.'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 5),
            ),
          );
        }
      } else {
        await ref.read(authStateProvider.notifier).sendOtp(_emailController.text);

        if (mounted) {
          // Navigate to OTP verification
          context.go('/auth/verify-otp', extra: _emailController.text);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
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
                      child: const Icon(
                        Icons.school,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.welcomeToBiso,
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: AppColors.strongBlue,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                const SizedBox(height: 80),

                // Email Input
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  validator: _validateEmail,
                  decoration: InputDecoration(
                    labelText: l10n.email,
                    hintText: l10n.enterEmail,
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  onFieldSubmitted: (_) => _handleLogin(),
                ),

                const SizedBox(height: 32),

                // Login Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(_useMagicLink ? 'Send Magic Link' : l10n.continueButton),
                ),

                const SizedBox(height: 16),

                // Toggle between magic link and OTP
                if (!widget.useFallback)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _useMagicLink = !_useMagicLink;
                      });
                    },
                    icon: Icon(_useMagicLink ? Icons.mail_outline : Icons.link),
                    label: Text(_useMagicLink 
                        ? 'Use verification code instead' 
                        : 'Use magic link instead'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.defaultBlue,
                    ),
                  ),

                const SizedBox(height: 24),

                // Clear Session
                TextButton(
                  onPressed: () async {
                    // Clear any existing session
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    await ref.read(authStateProvider.notifier).clearSession();
                    if (mounted) {
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Session cleared - OTP flow should work now',
                          ),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                  child: const Text('Clear Session'),
                ),

                const Spacer(),

                const SizedBox(height: 8),

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
      ),
    );
  }
}
