import 'app_logger.dart';

/// Helper class to migrate existing print statements to structured logging
/// Use this as a drop-in replacement during migration
class MigrationHelper {
  /// Replace logPrint() calls with this during migration
  ///
  /// Usage:
  /// Before: logPrint('User logged in: $userId');
  /// After:  logPrint('User logged in: $userId');
  ///
  /// This provides a gradual migration path while maintaining existing code patterns
  static void logPrint(String message) {
    AppLogger.debug('[MIGRATED] $message');
  }

  /// Enhanced print with context
  ///
  /// Usage:
  /// logPrintWithContext('API call failed', context: 'AuthService', extra: {'endpoint': '/login'});
  static void logPrintWithContext(
    String message, {
    String? context,
    Map<String, dynamic>? extra,
  }) {
    AppLogger.debug(
      context != null ? '[$context] $message' : message,
      extra: extra,
    );
  }

  /// For debugging specific features during migration
  static void debugAuth(String message, {Map<String, dynamic>? extra}) {
    AppLogger.auth(message, extra: extra);
  }

  static void debugChat(String message, {Map<String, dynamic>? extra}) {
    AppLogger.chat(message, extra: extra);
  }

  static void debugExpense(String message, {Map<String, dynamic>? extra}) {
    AppLogger.expense(message, extra: extra);
  }

  static void debugApi(String message, {Map<String, dynamic>? extra}) {
    AppLogger.api(message, extra: extra);
  }
}

/// Global shorthand functions for easy migration
/// These can be used as direct logPrint() replacements

void logPrint(String message) => MigrationHelper.logPrint(message);

void logInfo(String message, {Map<String, dynamic>? extra}) {
  AppLogger.info(message, extra: extra);
}

void logWarning(String message, {Map<String, dynamic>? extra}) {
  AppLogger.warning(message, extra: extra);
}

void logError(
  String message, {
  Object? error,
  StackTrace? stackTrace,
  Map<String, dynamic>? extra,
}) {
  AppLogger.error(message, error: error, stackTrace: stackTrace, extra: extra);
}
