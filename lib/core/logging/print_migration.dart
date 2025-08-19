import 'app_logger.dart';

/// Global replacement functions for gradual logPrint() migration
///
/// MIGRATION STRATEGY:
/// 1. Global find-replace: logPrint( -> logPrint(
/// 2. Gradually replace logPrint with structured logging
/// 3. Remove this file when migration is complete

// PHASE 1: Drop-in replacement (no code changes needed)
void logPrint(dynamic message) {
  AppLogger.debug('[MIGRATED] ${message.toString()}');
}

// PHASE 2: Enhanced replacements (optional context)
void logInfo(String message, {Map<String, dynamic>? context}) {
  AppLogger.info(message, extra: context);
}

void logWarning(String message, {Map<String, dynamic>? context}) {
  AppLogger.warning(message, extra: context);
}

void logError(
  String message, {
  Object? error,
  StackTrace? stackTrace,
  Map<String, dynamic>? context,
}) {
  AppLogger.error(
    message,
    error: error,
    stackTrace: stackTrace,
    extra: context,
  );
}

// PHASE 3: Feature-specific migrations (when you know the context)
void logAuth(String message, {String? userId, String? action}) {
  AppLogger.auth(message, userId: userId, action: action);
}

void logChat(String message, {String? chatId, String? userId}) {
  AppLogger.chat(message, chatId: chatId, userId: userId);
}

void logExpense(String message, {String? expenseId, String? userId}) {
  AppLogger.expense(message, expenseId: expenseId, userId: userId);
}

void logApi(
  String message, {
  String? endpoint,
  String? method,
  int? statusCode,
}) {
  AppLogger.api(
    message,
    endpoint: endpoint,
    method: method,
    statusCode: statusCode,
  );
}

/// Development helpers for specific debugging patterns
class DevLog {
  /// Debug API responses
  static void apiResponse(
    String endpoint,
    dynamic response, {
    int? statusCode,
  }) {
    AppLogger.api(
      'API Response',
      endpoint: endpoint,
      statusCode: statusCode,
      extra: {
        'response_type': response.runtimeType.toString(),
        'response_length': response.toString().length,
      },
    );
  }

  /// Debug user actions
  static void userAction(
    String action, {
    String? userId,
    Map<String, dynamic>? data,
  }) {
    AppLogger.info(
      '[USER_ACTION] $action',
      extra: {'user_id': userId, 'action': action, ...?data},
    );
  }

  /// Debug navigation
  static void navigation(String from, String to) {
    AppLogger.info(
      '[NAVIGATION] $from → $to',
      extra: {'from_route': from, 'to_route': to},
    );
  }

  /// Debug state changes
  static void stateChange(String component, String from, String to) {
    AppLogger.debug(
      '[STATE] $component: $from → $to',
      extra: {'component': component, 'from_state': from, 'to_state': to},
    );
  }
}

/// Quick debugging - remove after fixing
void debugHere(String location) {
  AppLogger.debug('🔍 DEBUG CHECKPOINT: $location');
}

void debugValue(String name, dynamic value) {
  AppLogger.debug('🔍 DEBUG VALUE: $name = $value');
}
