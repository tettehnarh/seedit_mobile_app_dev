/// Custom exception class for API-related errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? details;

  const ApiException({required this.message, this.statusCode, this.details});

  @override
  String toString() {
    if (details != null) {
      return 'ApiException: $message (Status: $statusCode) - $details';
    }
    return 'ApiException: $message (Status: $statusCode)';
  }
}

/// Exception for network connectivity issues
class NetworkException extends ApiException {
  const NetworkException({
    super.message = 'Network connection failed',
    super.statusCode,
    super.details,
  });
}

/// Exception for authentication/authorization issues
class AuthException extends ApiException {
  const AuthException({
    super.message = 'Authentication failed',
    super.statusCode,
    super.details,
  });
}

/// Exception for server errors (5xx)
class ServerException extends ApiException {
  const ServerException({
    super.message = 'Server error occurred',
    super.statusCode,
    super.details,
  });
}

/// Exception for client errors (4xx)
class ClientException extends ApiException {
  const ClientException({
    super.message = 'Client error occurred',
    super.statusCode,
    super.details,
  });
}

/// Exception for timeout errors
class TimeoutException extends ApiException {
  const TimeoutException({
    super.message = 'Request timeout',
    super.statusCode,
    super.details,
  });
}

/// Exception for validation errors
class ValidationException extends ApiException {
  const ValidationException({
    super.message = 'Validation failed',
    super.statusCode,
    super.details,
  });
}
