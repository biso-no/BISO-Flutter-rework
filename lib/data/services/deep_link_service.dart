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
        case 'event':
          _handleEventDeepLink(uri);
          break;
        case 'product':
          _handleProductDeepLink(uri);
          break;
        case 'job':
          _handleJobDeepLink(uri);
          break;
        case 'expense':
          _handleExpenseDeepLink(uri);
          break;
        case 'chat':
          _handleChatDeepLink(uri);
          break;
        default:
          logPrint('🔴 Unknown deep link host: ${uri.host}');
      }
    } else if (uri.scheme == 'https' || uri.scheme == 'http') {
      // Magic link via https is disabled (OTP-only flow). Ignore auth verify links.
      logPrint('ℹ️ Ignoring https link for auth: ${uri.toString()}');
    } else {
      logPrint('🔴 Unknown deep link scheme: ${uri.scheme}');
    }
  }

  void _handleAuthDeepLink(Uri uri) {
    final path = uri.path;
    final queryParams = uri.queryParameters;
    
    logPrint('🔗 Auth deep link path: $path');
    logPrint('🔗 Auth deep link params: $queryParams');

    if (path == '/magic-link' || path == '/verify') {
      // Magic link scheme disabled (OTP-only). Do nothing.
      logPrint('ℹ️ Magic link deep links disabled. Ignoring: $uri');
    } else {
      logPrint('🔴 Unknown auth deep link path: $path');
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }

  /// Handle event deep links
  void _handleEventDeepLink(Uri uri) {
    final eventId = uri.queryParameters['id'];
    
    logPrint('🔗 Event deep link - ID: $eventId');
    
    if (eventId != null) {
      final context = navigatorKey.currentContext;
      if (context != null) {
        // Navigate to events screen and then open the event modal
        context.go('/explore/events', extra: {'eventId': eventId});
      } else {
        logPrint('🔴 No navigation context available for event deep link');
      }
    } else {
      logPrint('🔴 Missing event ID in deep link');
    }
  }

  /// Handle product deep links
  void _handleProductDeepLink(Uri uri) {
    final productId = uri.queryParameters['id'];
    
    logPrint('🔗 Product deep link - ID: $productId');
    
    if (productId != null) {
      final context = navigatorKey.currentContext;
      if (context != null) {
        // Navigate to product detail screen
        context.go('/explore/marketplace/product/$productId');
      } else {
        logPrint('🔴 No navigation context available for product deep link');
      }
    } else {
      logPrint('🔴 Missing product ID in deep link');
    }
  }

  /// Handle job deep links
  void _handleJobDeepLink(Uri uri) {
    final jobId = uri.queryParameters['id'];
    
    logPrint('🔗 Job deep link - ID: $jobId');
    
    if (jobId != null) {
      final context = navigatorKey.currentContext;
      if (context != null) {
        // Navigate to jobs screen and then open the job modal
        context.go('/explore/jobs', extra: {'jobId': jobId});
      } else {
        logPrint('🔴 No navigation context available for job deep link');
      }
    } else {
      logPrint('🔴 Missing job ID in deep link');
    }
  }

  /// Handle expense deep links
  void _handleExpenseDeepLink(Uri uri) {
    final expenseId = uri.queryParameters['id'];
    
    logPrint('🔗 Expense deep link - ID: $expenseId');
    
    if (expenseId != null) {
      final context = navigatorKey.currentContext;
      if (context != null) {
        // Navigate to expenses screen
        context.go('/explore/expenses', extra: {'expenseId': expenseId});
      } else {
        logPrint('🔴 No navigation context available for expense deep link');
      }
    } else {
      logPrint('🔴 Missing expense ID in deep link');
    }
  }

  /// Handle chat deep links
  void _handleChatDeepLink(Uri uri) {
    final chatId = uri.queryParameters['id'];
    
    logPrint('🔗 Chat deep link - ID: $chatId');
    
    if (chatId != null) {
      final context = navigatorKey.currentContext;
      if (context != null) {
        // Navigate to chat conversation
        context.go('/chat/conversation/$chatId');
      } else {
        logPrint('🔴 No navigation context available for chat deep link');
      }
    } else {
      logPrint('🔴 Missing chat ID in deep link');
    }
  }

  /// Public method to handle programmatic deep links
  void handleDeepLink(Uri uri) {
    _handleDeepLink(uri);
  }
}

// Global navigator key for deep link navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();