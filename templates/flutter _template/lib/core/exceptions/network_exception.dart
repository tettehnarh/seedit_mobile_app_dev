/// Custom exception for network-related errors
class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  const NetworkException(
    this.message, {
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() {
    if (statusCode != null) {
      return 'NetworkException($statusCode): $message';
    }
    return 'NetworkException: $message';
  }
}

/// Exception for authentication-related errors
class AuthException extends NetworkException {
  const AuthException(
    super.message, {
    super.statusCode,
    super.originalError,
  });
}

/// Exception for validation errors
class ValidationException extends NetworkException {
  final Map<String, List<String>>? fieldErrors;

  const ValidationException(
    super.message, {
    super.statusCode,
    super.originalError,
    this.fieldErrors,
  });
}

/// Exception for server errors
class ServerException extends NetworkException {
  const ServerException(
    super.message, {
    super.statusCode,
    super.originalError,
  });
}
