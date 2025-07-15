/// Base class for API exceptions
abstract class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message';
}

/// Exception for network-related errors
class NetworkException extends ApiException {
  const NetworkException(super.message);
}

/// Exception for server errors (5xx)
class ServerException extends ApiException {
  const ServerException(super.message, [super.statusCode]);
}

/// Exception for client errors (4xx)
class ClientException extends ApiException {
  const ClientException(super.message, [super.statusCode]);
}

/// Exception for unauthorized access (401)
class UnauthorizedException extends ApiException {
  const UnauthorizedException(String message) : super(message, 401);
}

/// Exception for forbidden access (403)
class ForbiddenException extends ApiException {
  const ForbiddenException(String message) : super(message, 403);
}

/// Exception for not found errors (404)
class NotFoundException extends ApiException {
  const NotFoundException(String message) : super(message, 404);
}

/// Exception for bad request errors (400)
class BadRequestException extends ApiException {
  const BadRequestException(String message) : super(message, 400);
}

/// Exception for timeout errors
class TimeoutException extends ApiException {
  const TimeoutException(super.message);
}

/// Exception for parsing errors
class ParseException extends ApiException {
  const ParseException(super.message);
}
