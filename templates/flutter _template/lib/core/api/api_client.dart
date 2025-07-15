import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../utils/storage_utils.dart';
import '../utils/secure_storage_utils.dart';
import '../utils/constants.dart';
import '../events/auth_events.dart';
import 'api_exception.dart';
import 'dart:developer' as developer;

/// API Client for handling HTTP requests to the Django backend
class ApiClient {
  // TEMPORARY DEBUG FLAG: Set to false to disable automatic logout on 401/403
  static const bool enableAutomaticLogout = false;

  // Track logout attempts to prevent excessive logouts
  static int _logoutAttempts = 0;
  static DateTime? _lastLogoutTime;

  // Default base URLs for different platforms
  static String getDefaultBaseUrl() {
    // For web
    if (kIsWeb) {
      return AppConstants.apiBaseUrl;
    }

    // For mobile platforms
    if (Platform.isAndroid) {
      return AppConstants.apiBaseUrlAndroid; // Android emulator
    } else if (Platform.isIOS) {
      return AppConstants.apiBaseUrlIOS; // iOS simulator
    }

    // Default
    return AppConstants.apiBaseUrl;
  }

  // Static variable to store custom base URL
  static String? _customBaseUrl;

  // Set a custom base URL
  static void setCustomBaseUrl(String url) {
    _customBaseUrl = url;
  }

  // Reset to default base URL
  static void resetToDefaultBaseUrl() {
    _customBaseUrl = null;
  }

  // Get the current base URL (custom or default)
  static String getCurrentBaseUrl() {
    return _customBaseUrl ?? getDefaultBaseUrl();
  }

  // Base URL for this instance
  final String baseUrl;

  // HTTP client instance
  final http.Client _client = http.Client();

  // Constructor
  ApiClient() : baseUrl = getCurrentBaseUrl();

  // Headers for the requests
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Headers with authorization token (private)
  Future<Map<String, String>> get _authHeaders async {
    final token = await StorageUtils.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Token $token',
    };
  }

  // Public method to get auth headers
  Future<Map<String, String>> getAuthHeaders() async {
    return _authHeaders;
  }

  // Helper method to format the endpoint
  String _formatEndpoint(String endpoint) {
    return endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
  }

  // GET request
  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    final url = Uri.parse('$baseUrl/${_formatEndpoint(endpoint)}');

    try {
      // Use provided headers or default auth headers
      final requestHeaders = headers ?? await _authHeaders;

      // Debug logging
      developer.log('GET Request to: $url');
      developer.log('Headers: $requestHeaders');

      final response = await _client
          .get(url, headers: requestHeaders)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException('Request timed out. Please try again.');
            },
          );

      // Debug logging
      developer.log('Response status: ${response.statusCode}');
      developer.log('Response body: ${response.body}');

      return _processResponse(response);
    } catch (e) {
      developer.log('Error in GET request: $e', error: e);
      if (e is TimeoutException) {
        throw NetworkException(
          'Request timed out. Please check your connection and try again.',
        );
      }
      throw NetworkException('Failed to perform GET request: $e');
    }
  }

  // GET request with custom headers and response metadata (for conditional requests)
  Future<Map<String, dynamic>> getWithHeaders(
    String endpoint,
    Map<String, String> customHeaders,
  ) async {
    final url = Uri.parse('$baseUrl/${_formatEndpoint(endpoint)}');

    try {
      // Merge auth headers with custom headers
      final authHeaders = await _authHeaders;
      final requestHeaders = {...authHeaders, ...customHeaders};

      // Debug logging
      developer.log('GET with Headers Request to: $url');
      developer.log('Headers: $requestHeaders');

      final response = await _client
          .get(url, headers: requestHeaders)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException('Request timed out. Please try again.');
            },
          );

      // Debug logging
      developer.log('Response status: ${response.statusCode}');
      developer.log('Response headers: ${response.headers}');
      developer.log('Response body: ${response.body}');

      // Handle 304 Not Modified specially
      if (response.statusCode == 304) {
        return {
          'statusCode': 304,
          'headers': response.headers,
          'data': null,
          'notModified': true,
        };
      }

      // Process normal response
      final data = _processResponse(response);

      return {
        'statusCode': response.statusCode,
        'headers': response.headers,
        'data': data,
        'notModified': false,
      };
    } catch (e) {
      developer.log('Error in GET with headers request: $e', error: e);
      if (e is TimeoutException) {
        throw NetworkException(
          'Request timed out. Please check your connection and try again.',
        );
      }
      throw NetworkException('Failed to perform GET request with headers: $e');
    }
  }

  // POST request
  Future<dynamic> post(String endpoint, dynamic data) async {
    final url = Uri.parse('$baseUrl/${_formatEndpoint(endpoint)}');

    // Enhanced debug logging
    developer.log('==== API REQUEST START ====');
    developer.log('POST Request to: $url');
    developer.log('Full URL: ${url.toString()}');
    developer.log('Headers: $_headers');
    developer.log('Body: ${json.encode(data)}');
    developer.log('Base URL: $baseUrl');
    developer.log('Endpoint: ${_formatEndpoint(endpoint)}');
    developer.log('Current platform: ${Platform.operatingSystem}');
    developer.log('Is web: $kIsWeb');
    developer.log('==== API REQUEST END ====');

    try {
      final response = await _client
          .post(url, headers: _headers, body: json.encode(data))
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              developer.log('POST request timed out: $url');
              throw TimeoutException('Request timed out. Please try again.');
            },
          );

      // Enhanced debug logging
      developer.log('==== API RESPONSE START ====');
      developer.log('Response status: ${response.statusCode}');
      developer.log('Response body: ${response.body}');
      developer.log('Response headers: ${response.headers}');
      developer.log('==== API RESPONSE END ====');

      return _processResponse(response);
    } catch (e) {
      developer.log('==== API ERROR START ====');
      developer.log('Error in POST request to: $url');
      developer.log('Request data: ${json.encode(data)}');
      developer.log('Error details: $e');
      developer.log('Error type: ${e.runtimeType}');
      developer.log('==== API ERROR END ====');

      if (e is TimeoutException) {
        throw NetworkException(
          'Request timed out. Please check your connection and try again.',
        );
      }

      // Don't wrap ApiExceptions (BadRequestException, UnauthorizedException, etc.)
      // as they already contain clean error messages
      if (e is ApiException) {
        developer.log(
          'Re-throwing ApiException without wrapping: ${e.message}',
        );
        rethrow;
      }

      throw NetworkException('Failed to perform POST request: $e');
    }
  }

  // POST request with authorization
  Future<dynamic> postWithAuth(String endpoint, dynamic data) async {
    final url = Uri.parse('$baseUrl/${_formatEndpoint(endpoint)}');

    try {
      final headers = await _authHeaders;

      // Enhanced debug logging
      developer.log('🔄 [API_CLIENT] === POST WITH AUTH DEBUG START ===');
      developer.log('🔍 [API_CLIENT] POST with Auth Request to: $url');
      developer.log('🔍 [API_CLIENT] Endpoint: $endpoint');
      developer.log('🔍 [API_CLIENT] Base URL: $baseUrl');
      developer.log(
        '🔍 [API_CLIENT] Formatted endpoint: ${_formatEndpoint(endpoint)}',
      );
      developer.log('🔍 [API_CLIENT] Headers: $headers');
      developer.log('🔍 [API_CLIENT] Request data: $data');
      developer.log('🔍 [API_CLIENT] Request data type: ${data.runtimeType}');
      developer.log('🔍 [API_CLIENT] JSON body: ${json.encode(data)}');

      final response = await _client
          .post(url, headers: headers, body: json.encode(data))
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              developer.log('POST with Auth request timed out: $url');
              throw TimeoutException('Request timed out. Please try again.');
            },
          );

      // Enhanced response logging
      developer.log('🔍 [API_CLIENT] Response status: ${response.statusCode}');
      developer.log('🔍 [API_CLIENT] Response headers: ${response.headers}');
      developer.log('🔍 [API_CLIENT] Response body: ${response.body}');
      developer.log('🔍 [API_CLIENT] === POST WITH AUTH DEBUG END ===');

      return _processResponse(response);
    } catch (e) {
      developer.log('❌ [API_CLIENT] === POST WITH AUTH ERROR DEBUG START ===');
      developer.log(
        '❌ [API_CLIENT] Error in POST with Auth request: $e',
        error: e,
      );
      developer.log('❌ [API_CLIENT] Error type: ${e.runtimeType}');
      developer.log('❌ [API_CLIENT] URL: $url');
      developer.log('❌ [API_CLIENT] Data: $data');
      developer.log('❌ [API_CLIENT] === POST WITH AUTH ERROR DEBUG END ===');

      if (e is TimeoutException) {
        throw NetworkException(
          'Request timed out. Please check your connection and try again.',
        );
      }

      // Don't wrap ApiExceptions (BadRequestException, UnauthorizedException, etc.)
      // as they already contain clean error messages
      if (e is ApiException) {
        developer.log(
          'Re-throwing ApiException without wrapping: ${e.message}',
        );
        rethrow;
      }

      throw NetworkException(
        'Failed to perform authenticated POST request: $e',
      );
    }
  }

  // PUT request with authorization
  Future<dynamic> putWithAuth(String endpoint, dynamic data) async {
    final url = Uri.parse('$baseUrl/${_formatEndpoint(endpoint)}');

    try {
      final headers = await _authHeaders;
      final response = await _client
          .put(url, headers: headers, body: json.encode(data))
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException('Request timed out. Please try again.');
            },
          );
      return _processResponse(response);
    } catch (e) {
      if (e is TimeoutException) {
        throw NetworkException(
          'Request timed out. Please check your connection and try again.',
        );
      }
      throw NetworkException('Failed to perform authenticated PUT request: $e');
    }
  }

  // PATCH request with authorization
  Future<dynamic> patchWithAuth(String endpoint, dynamic data) async {
    final url = Uri.parse('$baseUrl/${_formatEndpoint(endpoint)}');

    try {
      final headers = await _authHeaders;
      final response = await _client
          .patch(url, headers: headers, body: json.encode(data))
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException('Request timed out. Please try again.');
            },
          );
      return _processResponse(response);
    } catch (e) {
      if (e is TimeoutException) {
        throw NetworkException(
          'Request timed out. Please check your connection and try again.',
        );
      }
      throw NetworkException(
        'Failed to perform authenticated PATCH request: $e',
      );
    }
  }

  // DELETE request with authorization
  Future<dynamic> deleteWithAuth(String endpoint) async {
    final url = Uri.parse('$baseUrl/${_formatEndpoint(endpoint)}');

    try {
      final headers = await _authHeaders;
      final response = await _client
          .delete(url, headers: headers)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException('Request timed out. Please try again.');
            },
          );
      return _processResponse(response);
    } catch (e) {
      if (e is TimeoutException) {
        throw NetworkException(
          'Request timed out. Please check your connection and try again.',
        );
      }
      throw NetworkException(
        'Failed to perform authenticated DELETE request: $e',
      );
    }
  }

  // Multipart POST request with authorization (for file uploads)
  Future<dynamic> postMultipartWithAuth(
    String endpoint,
    Map<String, dynamic> data,
    Map<String, String> filePaths,
  ) async {
    final url = Uri.parse('$baseUrl/${_formatEndpoint(endpoint)}');

    try {
      final token = await StorageUtils.getAccessToken();

      // Create multipart request
      final request = http.MultipartRequest('POST', url);

      // Add authorization header
      if (token != null) {
        request.headers['Authorization'] = 'Token $token';
      }

      // Add text fields with proper nested object handling
      data.forEach((key, value) {
        if (value != null) {
          // Handle nested objects by converting to JSON
          if (value is Map<String, dynamic>) {
            request.fields[key] = json.encode(value);
            developer.log(
              'Added nested object as JSON: $key -> ${json.encode(value)}',
            );
          } else if (value is List) {
            request.fields[key] = json.encode(value);
            developer.log(
              'Added list field as JSON: $key -> ${json.encode(value)}',
            );
          } else {
            request.fields[key] = value.toString();
            developer.log('Added field: $key -> ${value.toString()}');
          }
        }
      });

      // Add file fields
      for (final entry in filePaths.entries) {
        final fieldName = entry.key;
        final filePath = entry.value;

        if (filePath.isNotEmpty) {
          final file = File(filePath);
          if (await file.exists()) {
            final multipartFile = await http.MultipartFile.fromPath(
              fieldName,
              filePath,
            );
            request.files.add(multipartFile);
            developer.log('Added file: $fieldName -> $filePath');
          } else {
            developer.log('File not found: $filePath');
          }
        }
      }

      // Enhanced debug logging
      developer.log('🔄 [API_CLIENT] === MULTIPART POST DEBUG START ===');
      developer.log('🔍 [API_CLIENT] Multipart POST Request to: $url');
      developer.log('🔍 [API_CLIENT] Endpoint: $endpoint');
      developer.log('🔍 [API_CLIENT] Base URL: $baseUrl');
      developer.log('🔍 [API_CLIENT] Request fields: ${request.fields}');
      developer.log('🔍 [API_CLIENT] Request headers: ${request.headers}');
      developer.log(
        '🔍 [API_CLIENT] Files: ${request.files.map((f) => '${f.field}: ${f.filename}').toList()}',
      );

      // Log each field with its type
      request.fields.forEach((key, value) {
        developer.log('🔍 [API_CLIENT] Field $key: $value');
      });

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60), // Longer timeout for file uploads
        onTimeout: () {
          throw TimeoutException('File upload timed out. Please try again.');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);

      // Enhanced response logging
      developer.log(
        '🔍 [API_CLIENT] Multipart response status: ${response.statusCode}',
      );
      developer.log(
        '🔍 [API_CLIENT] Multipart response headers: ${response.headers}',
      );
      developer.log(
        '🔍 [API_CLIENT] Multipart response body: ${response.body}',
      );
      developer.log('🔍 [API_CLIENT] === MULTIPART POST DEBUG END ===');

      return _processResponse(response);
    } catch (e) {
      developer.log('❌ [API_CLIENT] === MULTIPART POST ERROR DEBUG START ===');
      developer.log(
        '❌ [API_CLIENT] Error in multipart POST request: $e',
        error: e,
      );
      developer.log('❌ [API_CLIENT] Error type: ${e.runtimeType}');
      developer.log('❌ [API_CLIENT] URL: $url');
      developer.log('❌ [API_CLIENT] === MULTIPART POST ERROR DEBUG END ===');

      if (e is TimeoutException) {
        throw NetworkException(
          'File upload timed out. Please check your connection and try again.',
        );
      }
      throw NetworkException('Failed to upload files: $e');
    }
  }

  // Multipart PATCH request with authorization (for file uploads in updates)
  Future<dynamic> patchMultipartWithAuth(
    String endpoint,
    Map<String, dynamic> data,
    Map<String, String> filePaths,
  ) async {
    final url = Uri.parse('$baseUrl/${_formatEndpoint(endpoint)}');

    try {
      final token = await StorageUtils.getAccessToken();

      // Create multipart request with PATCH method
      final request = http.MultipartRequest('PATCH', url);

      // Add authorization header
      if (token != null) {
        request.headers['Authorization'] = 'Token $token';
      }

      // Add text fields with proper nested object handling
      data.forEach((key, value) {
        if (value != null) {
          // Handle nested objects by converting to JSON
          if (value is Map<String, dynamic>) {
            request.fields[key] = json.encode(value);
            developer.log(
              'Added nested object as JSON: $key -> ${json.encode(value)}',
            );
          } else if (value is List) {
            request.fields[key] = json.encode(value);
            developer.log(
              'Added list field as JSON: $key -> ${json.encode(value)}',
            );
          } else {
            request.fields[key] = value.toString();
            developer.log('Added field: $key -> ${value.toString()}');
          }
        }
      });

      // Add file fields
      for (final entry in filePaths.entries) {
        final fieldName = entry.key;
        final filePath = entry.value;

        if (filePath.isNotEmpty) {
          final file = File(filePath);
          if (await file.exists()) {
            final multipartFile = await http.MultipartFile.fromPath(
              fieldName,
              filePath,
            );
            request.files.add(multipartFile);
            developer.log('Added file: $fieldName -> $filePath');
          } else {
            developer.log('File not found: $filePath');
          }
        }
      }

      // Debug logging
      developer.log('Multipart PATCH Request to: $url');
      developer.log('Fields: ${request.fields}');
      developer.log(
        'Files: ${request.files.map((f) => '${f.field}: ${f.filename}').toList()}',
      );

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60), // Longer timeout for file uploads
        onTimeout: () {
          throw TimeoutException('File upload timed out. Please try again.');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);

      // Debug logging
      developer.log('Multipart PATCH response status: ${response.statusCode}');
      developer.log('Multipart PATCH response body: ${response.body}');

      return _processResponse(response);
    } catch (e) {
      developer.log('Error in multipart PATCH request: $e', error: e);
      if (e is TimeoutException) {
        throw NetworkException(
          'File upload timed out. Please check your connection and try again.',
        );
      }
      throw NetworkException('Failed to upload files: $e');
    }
  }

  // Process the HTTP response
  dynamic _processResponse(http.Response response) {
    developer.log('🔍 [API_CLIENT] === RESPONSE PROCESSING DEBUG START ===');
    developer.log(
      '🔍 [API_CLIENT] Processing response with status: ${response.statusCode}',
    );
    developer.log('🔍 [API_CLIENT] Response headers: ${response.headers}');
    developer.log('🔍 [API_CLIENT] Raw response body: ${response.body}');

    try {
      final responseData = json.decode(response.body);
      developer.log('🔍 [API_CLIENT] Parsed response data: $responseData');
      developer.log(
        '🔍 [API_CLIENT] Response data type: ${responseData.runtimeType}',
      );

      switch (response.statusCode) {
        case 200:
        case 201:
          developer.log(
            '✅ [API_CLIENT] Success response: ${response.statusCode}',
          );
          developer.log(
            '🔍 [API_CLIENT] === RESPONSE PROCESSING DEBUG END ===',
          );
          return responseData;
        case 400:
          developer.log('❌ [API_CLIENT] Bad Request (400) detected');
          // Try to extract more detailed error message
          String errorMessage = 'Bad request';

          if (responseData is Map) {
            developer.log(
              '🔍 [API_CLIENT] Response is Map, analyzing error structure...',
            );
            // Check for Django REST Framework error format
            if (responseData.containsKey('non_field_errors')) {
              errorMessage = responseData['non_field_errors'].join(', ');
              developer.log(
                '🔍 [API_CLIENT] Found non_field_errors: $errorMessage',
              );
            } else if (responseData.containsKey('detail')) {
              errorMessage = responseData['detail'];
              developer.log(
                '🔍 [API_CLIENT] Found detail error: $errorMessage',
              );
            } else {
              // Try to build error message from all fields
              final errorMessages = <String>[];
              developer.log(
                '🔍 [API_CLIENT] Processing field-specific errors...',
              );
              responseData.forEach((key, value) {
                developer.log(
                  '🔍 [API_CLIENT] Error field $key: $value (${value.runtimeType})',
                );
                if (value is List) {
                  errorMessages.add('$key: ${value.join(', ')}');
                } else {
                  errorMessages.add('$key: $value');
                }
              });

              if (errorMessages.isNotEmpty) {
                errorMessage = errorMessages.join('; ');
                developer.log(
                  '🔍 [API_CLIENT] Compiled error message: $errorMessage',
                );
              }
            }
          }
          developer.log(
            '❌ [API_CLIENT] Final 400 error message: $errorMessage',
          );
          developer.log(
            '🔍 [API_CLIENT] === RESPONSE PROCESSING DEBUG END ===',
          );
          throw BadRequestException(errorMessage);
        case 401:
          // DEBUGGING: Log 401 responses to understand why users are being logged out
          developer.log('🚨 [DEBUG] 401 UNAUTHORIZED RESPONSE RECEIVED');
          developer.log('🚨 [DEBUG] URL: ${response.request?.url}');
          developer.log('🚨 [DEBUG] Response: $responseData');

          if (enableAutomaticLogout) {
            developer.log('🚨 [DEBUG] This will trigger automatic logout');
            // Handle token expiration or other authentication failures
            _handleAuthenticationFailure(responseData);
          } else {
            developer.log('⚠️ [DEBUG] Automatic logout DISABLED for debugging');
          }

          throw UnauthorizedException(responseData['detail'] ?? 'Unauthorized');
        case 403:
          // DEBUGGING: Log 403 responses
          developer.log('🚨 [DEBUG] 403 FORBIDDEN RESPONSE RECEIVED');
          developer.log('🚨 [DEBUG] URL: ${response.request?.url}');
          developer.log('🚨 [DEBUG] Response: $responseData');

          // Check if this is an email verification response
          if (responseData['requires_verification'] == true) {
            // Return the full response data for email verification handling
            return responseData;
          }
          throw ForbiddenException(responseData['detail'] ?? 'Forbidden');
        case 404:
          throw NotFoundException(responseData['detail'] ?? 'Not found');
        case 500:
        default:
          throw ServerException('Server error: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      // If JSON parsing fails, return the raw response
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'message': 'Operation successful'};
      } else {
        throw ServerException('Error processing response: ${response.body}');
      }
    }
  }

  // Handle authentication failure (token expiration, etc.)
  Future<void> _handleAuthenticationFailure(
    Map<String, dynamic>? responseData,
  ) async {
    developer.log(
      '🚨 [API_CLIENT] Authentication failure detected. Processing logout...',
    );
    developer.log('🔍 [API_CLIENT] Response data: $responseData');
    developer.log(
      '🔍 [API_CLIENT] Current URL: ${responseData?['url'] ?? 'unknown'}',
    );

    // TEMPORARY: Add more logging to debug frequent logouts
    developer.log(
      '⚠️ [DEBUG] AUTOMATIC LOGOUT TRIGGERED - CHECK IF THIS IS EXPECTED',
    );
    developer.log(
      '⚠️ [DEBUG] If you are seeing this frequently, there may be an issue with token validation',
    );

    try {
      // Clear storage data
      await StorageUtils.clearAuthData();
      await SecureStorageUtils.clearAuthData();

      // Use the new event system to notify the app
      _notifyAuthFailure(responseData);
    } catch (e) {
      developer.log(
        '❌ [API_CLIENT] Error during automatic logout: $e',
        error: e,
      );
    }
  }

  // Notify the app about authentication failure using the event system
  void _notifyAuthFailure(Map<String, dynamic>? responseData) {
    developer.log(
      '📡 [API_CLIENT] Sending authentication failure notification...',
    );

    final errorCode = responseData?['error_code'];
    final detail = responseData?['detail'] ?? 'Unauthorized';

    // Check if this is a KYC approval related session invalidation
    if (detail.toLowerCase().contains('kyc') ||
        detail.toLowerCase().contains('approval') ||
        detail.toLowerCase().contains('re-authentication') ||
        detail.toLowerCase().contains('updated permissions')) {
      developer.log('🎯 [API_CLIENT] KYC approval logout detected');
      AuthEventBus().fireKycApprovalLogout(
        reason: detail,
        data: {
          'errorCode': errorCode,
          'responseData': responseData,
          'source': 'api_client',
        },
      );
    } else if (errorCode == 'INVALID_TOKEN' ||
        detail.toLowerCase().contains('invalid token')) {
      developer.log('🔑 [API_CLIENT] Session invalidation detected');
      AuthEventBus().fireSessionInvalidated(
        reason: detail,
        data: {
          'errorCode': errorCode,
          'responseData': responseData,
          'source': 'api_client',
        },
      );
    } else {
      developer.log('⏰ [API_CLIENT] Token expiration detected');
      AuthEventBus().fireTokenExpired(
        reason: detail,
        data: {
          'errorCode': errorCode,
          'responseData': responseData,
          'source': 'api_client',
        },
      );
    }
  }

  // Test API connection
  Future<bool> testConnection() async {
    try {
      developer.log('Testing API connection to: $baseUrl');

      // Try to make a simple GET request to the server
      final response = await _client
          .get(Uri.parse('$baseUrl/'), headers: _headers)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              developer.log('Connection test timed out');
              return http.Response('{"error": "timeout"}', 408);
            },
          );

      developer.log('Connection test response: ${response.statusCode}');
      return response.statusCode <
          500; // Consider anything below 500 as "connected"
    } catch (e) {
      developer.log('Connection test failed: $e', error: e);
      return false;
    }
  }

  // Dispose the client
  void dispose() {
    _client.close();
  }
}

// Riverpod provider for ApiClient
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});
