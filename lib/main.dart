import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/premium_theme.dart';
import 'core/logging/logging_config.dart';
// Appwrite services are now globally initialized
import 'generated/l10n/app_localizations.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/otp_verification_screen.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/explore/events_screen.dart';
// marketplace screen imported as alias below
import 'presentation/screens/explore/marketplace_screen.dart' as market;
import 'presentation/screens/explore/sell_product_screen.dart';
import 'presentation/screens/explore/product_detail_screen.dart';
import 'presentation/screens/explore/jobs_screen.dart';
import 'presentation/screens/explore/expenses_screen.dart';
import 'presentation/screens/chat/chat_list_screen.dart';
import 'presentation/screens/ai_chat/ai_chat_screen.dart';
import 'providers/auth/auth_provider.dart';
import 'presentation/screens/events/large_event_screen.dart';
import 'data/models/large_event_model.dart';
import 'data/services/large_event_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize logging system early
  await LoggingConfig.initialize();
  
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
      theme: PremiumTheme.lightTheme,
      darkTheme: PremiumTheme.darkTheme,
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
        builder: (context, state) => const market.MarketplaceScreen(),
        routes: [
          GoRoute(
            path: 'new',
            name: 'product-new',
            builder: (context, state) => const SellProductScreen(),
          ),
          GoRoute(
            path: ':productId',
            name: 'product-detail',
            builder: (context, state) => ProductDetailScreen(
              productId: state.pathParameters['productId']!,
            ),
          ),
        ],  
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
      GoRoute(
        path: '/ai-chat',
        name: 'ai-chat',
        builder: (context, state) => const AiChatScreen(),
      ),
      GoRoute(
        path: '/events/large/:slug',
        name: 'large-event',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is LargeEventModel) {
            return LargeEventScreen(event: extra);
          }
          // Deep link fallback: fetch by slug
          final slug = state.pathParameters['slug'] ?? '';
          return _LargeEventLoader(slug: slug);
        },
      ),
  ],
);

class _LargeEventLoader extends StatefulWidget {
  final String slug;
  const _LargeEventLoader({required this.slug});
  @override
  State<_LargeEventLoader> createState() => _LargeEventLoaderState();
}

class _LargeEventLoaderState extends State<_LargeEventLoader> {
  LargeEventModel? _event;
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final service = LargeEventService();
      final result = await service.fetchEventBySlug(widget.slug);
      if (!mounted) return;
      if (result != null) {
        setState(() {
          _event = result;
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Event not found';
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Event')),
        body: Center(child: Text('Failed to load: $_error')),
      );
    }
    return LargeEventScreen(event: _event!);
  }
}
