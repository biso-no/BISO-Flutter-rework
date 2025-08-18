/// Base class for all application exceptions
abstract class AppException implements Exception {
  final String message;
  final int? code;
  
  const AppException(this.message, {this.code});
  
  @override
  String toString() => 'AppException: $message';
}

/// Exception thrown when network operations fail
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code});
  
  @override
  String toString() => 'NetworkException: $message';
}

/// Exception thrown when authentication fails
class AuthException extends AppException {
  const AuthException(super.message, {super.code});
  
  @override
  String toString() => 'AuthException: $message';
}

/// Exception thrown during validation operations
class ValidationException extends AppException {
  const ValidationException(super.message, {super.code});
  
  @override
  String toString() => 'ValidationException: $message';
}

/// Exception thrown when data parsing fails
class DataException extends AppException {
  const DataException(super.message, {super.code});
  
  @override
  String toString() => 'DataException: $message';
}

/// Exception thrown when permissions are insufficient
class PermissionException extends AppException {
  const PermissionException(super.message, {super.code});
  
  @override
  String toString() => 'PermissionException: $message';
}