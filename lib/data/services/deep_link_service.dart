import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/logging/print_migration.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  Future<void> initialize() async {
    _appLinks = AppLinks();
    
    // Handle links when app is already running
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        logPrint('🔗 Deep link received: $uri');
        _handleDeepLink(uri);
      },
      onError: (Object err) {
        logPrint('🔴 Deep link error: $err');
      },
    );

    // Handle initial link when app is launched from closed state
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        logPrint('🔗 Initial deep link: $initialUri');
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      logPrint('🔴 Failed to get initial link: $e');
    }
  }

  void _handleDeepLink(Uri uri) {
    logPrint('🔗 Handling deep link: ${uri.toString()}');
    
    if (uri.scheme == 'biso') {
      switch (uri.host) {
        case 'auth':
          _handleAuthDeepLink(uri);
          break;
        default:
          logPrint('🔴 Unknown deep link host: ${uri.host}');
      }
    } else {
      logPrint('🔴 Unknown deep link scheme: ${uri.scheme}');
    }
  }

  void _handleAuthDeepLink(Uri uri) {
    final path = uri.path;
    final queryParams = uri.queryParameters;
    
    logPrint('🔗 Auth deep link path: $path');
    logPrint('🔗 Auth deep link params: $queryParams');

    if (path == '/magic-link') {
      final userId = queryParams['userId'];
      final secret = queryParams['secret'];
      
      if (userId != null && secret != null) {
        logPrint('🔗 Magic link params found: userId=$userId, secret=***');
        
        // Navigate to magic link verification screen
        final context = navigatorKey.currentContext;
        if (context != null) {
          context.go('/auth/magic-link-verify', extra: {
            'userId': userId,
            'secret': secret,
          });
        } else {
          logPrint('🔴 No navigation context available');
        }
      } else {
        logPrint('🔴 Missing magic link parameters: userId=$userId, secret=$secret');
      }
    } else {
      logPrint('🔴 Unknown auth deep link path: $path');
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}

// Global navigator key for deep link navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();