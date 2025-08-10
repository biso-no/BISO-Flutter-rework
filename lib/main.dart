import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
// Appwrite services are now globally initialized
import 'generated/l10n/app_localizations.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/otp_verification_screen.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/explore/events_screen.dart';
import 'presentation/screens/explore/marketplace_screen.dart';
import 'presentation/screens/explore/jobs_screen.dart';
import 'presentation/screens/explore/expenses_screen.dart';
import 'presentation/screens/chat/chat_list_screen.dart';
import 'providers/auth/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const ProviderScope(child: BisoApp()));
}

class BisoApp extends ConsumerWidget {
  const BisoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch auth state and initialize user data when authenticated
    ref.watch(authStateProvider);
    
    // Auth state listener is now handled internally by AuthProvider
    // No need for external orchestration

    return MaterialApp.router(
      title: 'BISO',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('no'),
      ],
      routerConfig: _router,
    );
  }
}

// Create router as a static instance to prevent rebuilding
final _router = GoRouter(
  initialLocation: '/home',
  routes: [
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/verify-otp',
        name: 'verify-otp',
        builder: (context, state) => OtpVerificationScreen(
          email: state.extra as String? ?? '',
        ),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/explore/events',
        name: 'events',
        builder: (context, state) => const EventsScreen(),
      ),
      GoRoute(
        path: '/explore/products',
        name: 'products', 
        builder: (context, state) => const MarketplaceScreen(),
      ),
      GoRoute(
        path: '/explore/units',
        name: 'units',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Clubs & Units - Coming Soon')),
        ),
      ),
      GoRoute(
        path: '/explore/expenses',
        name: 'expenses',
        builder: (context, state) => const ExpensesScreen(),
      ),
      GoRoute(
        path: '/explore/volunteer',
        name: 'volunteer',
        builder: (context, state) => const JobsScreen(),
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) => const ChatListScreen(),
      ),
  ],
);
