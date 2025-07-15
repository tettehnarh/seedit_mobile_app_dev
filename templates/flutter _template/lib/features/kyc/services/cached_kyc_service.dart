import 'dart:developer' as developer;
import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/storage_utils.dart';

/// Enhanced KYC Service with ETag-based caching support
/// Implements conditional requests for optimal performance
class CachedKycService {
  final ApiClient _apiClient = ApiClient();

  // Cache keys for ETag and data storage
  static const String _etagKey = 'kyc_etag';
  static const String _cacheDataKey = 'kyc_cache_data';
  static const String _cacheTimestampKey = 'kyc_cache_timestamp';
  static const String _cacheEnabledKey = 'kyc_cache_enabled';

  // Cache settings
  static const Duration _cacheTimeout = Duration(hours: 1);
  static const bool _defaultCacheEnabled = true;

  /// Check if caching is enabled (feature flag)
  Future<bool> get isCacheEnabled async {
    return await StorageUtils.getBool(
      _cacheEnabledKey,
      defaultValue: _defaultCacheEnabled,
    );
  }

  /// Enable or disable caching
  Future<void> setCacheEnabled(bool enabled) async {
    await StorageUtils.setBool(_cacheEnabledKey, enabled);
    developer.log('🔧 KYC Cache ${enabled ? 'ENABLED' : 'DISABLED'}');
  }

  /// Get cached ETag
  Future<String?> _getCachedETag() async {
    return await StorageUtils.getString(_etagKey);
  }

  /// Store ETag in cache
  Future<void> _storeCachedETag(String etag) async {
    await StorageUtils.setString(_etagKey, etag);
    developer.log('💾 Stored ETag: $etag');
  }

  /// Get cached KYC data
  Future<Map<String, dynamic>?> _getCachedData() async {
    if (!await isCacheEnabled) {
      developer.log('🚫 Cache disabled, skipping cache lookup');
      return null;
    }

    try {
      final dataJson = await StorageUtils.getString(_cacheDataKey);
      final timestampStr = await StorageUtils.getString(_cacheTimestampKey);

      if (dataJson == null || timestampStr == null) {
        developer.log('📭 No cached data found');
        return null;
      }

      // Check if cache is expired
      final timestamp = DateTime.parse(timestampStr);
      final now = DateTime.now();
      final age = now.difference(timestamp);

      if (age > _cacheTimeout) {
        developer.log('⏰ Cache expired (age: ${age.inMinutes} minutes)');
        await _clearCache();
        return null;
      }

      final data = StorageUtils.parseJson(dataJson);
      developer.log('✅ Cache HIT - Age: ${age.inMinutes} minutes');
      return data;
    } catch (e) {
      developer.log('❌ Error reading cached data: $e');
      await _clearCache();
      return null;
    }
  }

  /// Store KYC data in cache
  Future<void> _storeCachedData(Map<String, dynamic> data) async {
    if (!await isCacheEnabled) {
      developer.log('🚫 Cache disabled, skipping cache storage');
      return;
    }

    try {
      final dataJson = StorageUtils.toJson(data);
      final timestamp = DateTime.now().toIso8601String();

      await StorageUtils.setString(_cacheDataKey, dataJson);
      await StorageUtils.setString(_cacheTimestampKey, timestamp);

      developer.log('💾 Cached KYC data with timestamp: $timestamp');
    } catch (e) {
      developer.log('❌ Error storing cached data: $e');
    }
  }

  /// Clear all cached data
  Future<void> _clearCache() async {
    try {
      await StorageUtils.remove(_etagKey);
      await StorageUtils.remove(_cacheDataKey);
      await StorageUtils.remove(_cacheTimestampKey);
      developer.log('🗑️ Cache cleared');
    } catch (e) {
      developer.log('❌ Error clearing cache: $e');
    }
  }

  /// Get KYC status with ETag-based conditional requests
  Future<Map<String, dynamic>> getKycStatus({
    String operationType = 'login',
    bool forceRefresh = false,
  }) async {
    try {
      developer.log(
        '🔍 Cached KYC Service: Fetching status for $operationType',
      );

      // Check cache first (unless force refresh)
      if (!forceRefresh) {
        final cachedData = await _getCachedData();
        if (cachedData != null) {
          developer.log('✅ Returning cached KYC data');
          return {
            'success': true,
            'data': cachedData,
            'cached': true,
            'cache_hit': true,
          };
        }
      }

      // Prepare headers for conditional request
      final headers = <String, String>{};
      final cachedETag = await _getCachedETag();

      if (cachedETag != null && !forceRefresh) {
        headers['If-None-Match'] = cachedETag;
        developer.log(
          '📋 Using cached ETag for conditional request: $cachedETag',
        );
      }

      final endpoint =
          '${ApiConstants.kycEventStatusEndpoint}?operation_type=$operationType';
      developer.log('🌐 API endpoint: $endpoint');

      // Make conditional request
      final response = await _apiClient.getWithHeaders(endpoint, headers);

      // Check if we got a 304 Not Modified response
      if (response['statusCode'] == 304) {
        developer.log('✅ 304 Not Modified - using cached data');
        final cachedData = await _getCachedData();
        if (cachedData != null) {
          return {
            'success': true,
            'data': cachedData,
            'cached': true,
            'not_modified': true,
          };
        }
      }

      // Process fresh data
      final data = response['data'] ?? response;
      final responseHeaders = response['headers'] ?? {};

      // Extract and store new ETag
      final newETag = responseHeaders['etag'] ?? responseHeaders['ETag'];
      if (newETag != null) {
        await _storeCachedETag(newETag);
      }

      // Store fresh data in cache
      await _storeCachedData(data);

      // Update legacy cache for backward compatibility
      if (data['status'] != null || data['kyc_status'] != null) {
        final status = data['status'] ?? data['kyc_status'];
        await StorageUtils.setString('kyc_status', status);
      }

      developer.log('✅ Fresh KYC data received and cached');
      return {
        'success': true,
        'data': data,
        'cached': false,
        'cache_miss': true,
        'etag': newETag,
      };
    } catch (e) {
      developer.log('💥 Error in cached KYC service: $e');

      // Fallback to cached data on error
      final cachedData = await _getCachedData();
      if (cachedData != null) {
        developer.log('🔄 Using cached data as fallback');
        return {
          'success': true,
          'data': cachedData,
          'cached': true,
          'fallback': true,
        };
      }

      // Fallback to legacy cache
      final legacyStatus = await StorageUtils.getString('kyc_status');
      if (legacyStatus != null) {
        developer.log('🔄 Using legacy cached status: $legacyStatus');
        return {
          'success': true,
          'data': {'kyc_status': legacyStatus, 'status': legacyStatus},
          'cached': true,
          'legacy_fallback': true,
        };
      }

      if (e is ApiException) {
        return {'success': false, 'error': e.message};
      }

      return {
        'success': false,
        'error': 'Failed to fetch KYC status. Please try again.',
      };
    }
  }

  /// Force refresh KYC status (bypass cache)
  Future<Map<String, dynamic>> refreshKycStatus({
    String operationType = 'login',
  }) async {
    developer.log('🔄 Force refreshing KYC status');
    return await getKycStatus(operationType: operationType, forceRefresh: true);
  }

  /// Get cache statistics for monitoring
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final enabled = await isCacheEnabled;
      final etag = await _getCachedETag();
      final timestampStr = await StorageUtils.getString(_cacheTimestampKey);

      DateTime? cacheTime;
      Duration? cacheAge;

      if (timestampStr != null) {
        cacheTime = DateTime.parse(timestampStr);
        cacheAge = DateTime.now().difference(cacheTime);
      }

      return {
        'cache_enabled': enabled,
        'has_etag': etag != null,
        'etag': etag,
        'cache_time': cacheTime?.toIso8601String(),
        'cache_age_minutes': cacheAge?.inMinutes,
        'cache_expired': cacheAge != null && cacheAge > _cacheTimeout,
        'cache_timeout_hours': _cacheTimeout.inHours,
      };
    } catch (e) {
      developer.log('❌ Error getting cache stats: $e');
      return {'error': e.toString()};
    }
  }

  /// Clear cache manually (for testing/debugging)
  Future<void> clearCache() async {
    developer.log('🧹 Manually clearing KYC cache');
    await _clearCache();
  }

  /// Verify KYC for critical operations (no caching for security)
  Future<Map<String, dynamic>> verifyKycForOperation({
    required String operationType,
    Map<String, dynamic>? operationData,
  }) async {
    try {
      developer.log(
        '🔒 Verifying KYC for operation: $operationType (no cache)',
      );

      final data = {
        'operation_type': operationType,
        if (operationData != null) 'operation_data': operationData,
      };

      final response = await _apiClient.postWithAuth(
        ApiConstants.kycEventVerifyEndpoint,
        data,
      );

      return {'success': true, 'data': response};
    } catch (e) {
      developer.log('❌ Error verifying KYC for operation: $e');

      if (e is ApiException) {
        return {'success': false, 'error': e.message};
      }

      return {
        'success': false,
        'error': 'KYC verification failed. Please try again.',
      };
    }
  }

  /// Check if KYC is completed and approved
  Future<bool> isKycCompleted() async {
    try {
      final statusResult = await getKycStatus();

      if (statusResult['success'] == true) {
        final data = statusResult['data'];
        final status = data['status'] ?? data['kyc_status'];
        return status == 'approved';
      }

      return false;
    } catch (e) {
      developer.log('❌ Error checking KYC completion: $e');
      return false;
    }
  }
}
