import 'package:flutter/foundation.dart';
import 'app_logger.dart';

/// Configuration for the logging system
class LoggingConfig {
  /// Initialize the complete logging system
  /// Should be called early in main()
  static Future<void> initialize() async {
    // Initialize core logger
    await AppLogger.initialize(
      enableConsole: kDebugMode,
    );

    AppLogger.info('Logging system initialized', extra: {
      'debug_mode': kDebugMode,
      'console_enabled': kDebugMode,
    });
  }

  /// Future: Initialize external service (Sentry, Crashlytics, etc.)
  /// Uncomment and implement when needed
  /*
  static Future<void> _initializeExternalService() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      
      // Example Sentry setup:
      // await SentryFlutter.init((options) {
      //   options.dsn = 'YOUR_DSN_HERE';
      //   options.environment = kDebugMode ? 'development' : 'production';
      // });
      
      AppLogger.info('External service initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize external service', error: e, stackTrace: stackTrace);
    }
  }
  */

  /// Show the Talker screen for debugging (debug builds only)
  static void showLoggerScreen() {
    if (kDebugMode) {
      // Note: In production apps, you'd typically use TalkerScreen widget directly
      // AppLogger.instance.show();
      debugPrint('Logger screen would be shown in debug mode');
    }
  }

  /// Export logs for debugging/support
  static Future<String> exportLogs() async {
    final history = AppLogger.instance.history;
    final buffer = StringBuffer();
    
    buffer.writeln('BISO App Logs Export');
    buffer.writeln('Generated: ${DateTime.now().toIso8601String()}');
    buffer.writeln('Total entries: ${history.length}');
    buffer.writeln('=' * 50);
    
    for (final log in history) {
      buffer.writeln('[${log.time}] [${log.logLevel?.toString().toUpperCase() ?? 'LOG'}] ${log.message}');
    }
    
    return buffer.toString();
  }

  /// Clear all logs
  static void clearLogs() {
    AppLogger.instance.cleanHistory();
    AppLogger.info('Log history cleared');
  }
}

/// Extension for easier context logging
extension LogContext on Object {
  void logInfo(String message, {Map<String, dynamic>? extra}) {
    AppLogger.info(message, extra: {
      'context': runtimeType.toString(),
      ...?extra,
    });
  }

  void logError(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? extra}) {
    AppLogger.error(message, 
      error: error, 
      stackTrace: stackTrace, 
      extra: {
        'context': runtimeType.toString(),
        ...?extra,
      },
    );
  }

  void logWarning(String message, {Map<String, dynamic>? extra}) {
    AppLogger.warning(message, extra: {
      'context': runtimeType.toString(),
      ...?extra,
    });
  }
}