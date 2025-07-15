import 'dart:developer' as developer;
import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../models/wallet_models.dart';

/// Service for handling Paystack payment operations
class PaystackService {
  final ApiClient _apiClient = ApiClient();

  /// Initialize a Paystack payment for fund investment
  ///
  /// Returns a Map containing payment initialization data including:
  /// - authorization_url: URL to redirect user for payment
  /// - access_code: Paystack access code
  /// - reference: Payment reference
  /// - transaction_id: Backend transaction ID
  /// - public_key: Paystack public key
  Future<Map<String, dynamic>> initializePayment({
    required String fundId,
    required double amount,
    required String paymentMethodId,
    double? totalAmount, // Total amount including platform fee
  }) async {
    try {
      developer.log(
        '🔄 [PAYSTACK] Initializing payment for fund: $fundId, investment: $amount, total: ${totalAmount ?? amount}',
      );

      final requestData = {
        'fund_id': fundId,
        'investment_amount': amount.toString(), // Original investment amount
        'payment_method_id': paymentMethodId,
      };

      // Add total amount if provided (for non-manual payments with platform fee)
      if (totalAmount != null && totalAmount != amount) {
        requestData['total_amount'] = totalAmount.toString();
      } else {
        requestData['total_amount'] = amount.toString();
      }

      final response = await _apiClient.postWithAuth(
        '/payments/paystack/initialize/',
        requestData,
      );

      developer.log('✅ [PAYSTACK] Payment initialized successfully');
      developer.log('🔍 [PAYSTACK] Response: $response');

      return {'success': true, 'data': response};
    } catch (e) {
      developer.log('❌ [PAYSTACK] Error initializing payment: $e');

      String errorMessage = 'Failed to initialize payment';
      if (e is ApiException) {
        errorMessage = e.message;
      }

      return {'success': false, 'error': errorMessage};
    }
  }

  /// Verify a Paystack payment
  ///
  /// Returns a Map containing verification result
  Future<Map<String, dynamic>> verifyPayment(String reference) async {
    try {
      developer.log(
        '🔄 [PAYSTACK] Verifying payment with reference: "$reference"',
      );
      developer.log('🔄 [PAYSTACK] Reference length: ${reference.length}');
      developer.log(
        '🔄 [PAYSTACK] Reference contains pipe: ${reference.contains('|')}',
      );

      // Clean the reference if it contains extra text (common issue with webhook processing)
      String cleanReference = reference;
      if (reference.contains('|')) {
        cleanReference = reference.split('|')[0].trim();
        developer.log(
          '🧹 [PAYSTACK] Cleaned reference from "$reference" to "$cleanReference"',
        );
      }

      final response = await _apiClient.postWithAuth(
        '/payments/paystack/verify/',
        {'reference': cleanReference},
      );

      developer.log('🔍 [PAYSTACK] Verification response: $response');

      // Check if the backend verification was successful
      // Handle both new format (with status field) and legacy format
      bool isSuccess = false;
      Map<String, dynamic>? responseData;
      String? errorMessage;

      if (response is Map<String, dynamic>) {
        // New format: {status: true/false, data: {...}, message: "..."}
        if (response.containsKey('status')) {
          isSuccess = response['status'] == true;
          responseData = response['data'];
          errorMessage = response['error'] ?? response['message'];
        }
        // Legacy format: direct data response (assume success if no error field)
        else if (!response.containsKey('error')) {
          isSuccess = true;
          responseData = response;
        }
        // Error response format
        else {
          isSuccess = false;
          errorMessage =
              response['error'] ??
              response['message'] ??
              'Payment verification failed';
        }
      }

      if (isSuccess) {
        developer.log('✅ [PAYSTACK] Payment verified successfully');
        return {'success': true, 'data': responseData ?? {}};
      } else {
        developer.log(
          '❌ [PAYSTACK] Payment verification failed: $errorMessage',
        );
        return {
          'success': false,
          'error': errorMessage ?? 'Payment verification failed',
        };
      }
    } catch (e) {
      developer.log('❌ [PAYSTACK] Error verifying payment: $e');

      String errorMessage = 'Failed to verify payment';
      if (e is ApiException) {
        errorMessage = e.message;
      }

      return {'success': false, 'error': errorMessage};
    }
  }

  /// Get available Paystack payment methods
  Future<Map<String, dynamic>> getPaymentMethods() async {
    try {
      developer.log('🔄 [PAYSTACK] Fetching available payment methods');

      final response = await _apiClient.get(
        '/payments/paystack/payment-methods/',
      );

      developer.log('✅ [PAYSTACK] Payment methods fetched successfully');
      developer.log('🔍 [PAYSTACK] Response: $response');

      return {'success': true, 'data': response};
    } catch (e) {
      developer.log('❌ [PAYSTACK] Error fetching payment methods: $e');

      String errorMessage = 'Failed to fetch payment methods';
      if (e is ApiException) {
        errorMessage = e.message;
      }

      return {'success': false, 'error': errorMessage};
    }
  }

  /// Create a user payment method
  Future<Map<String, dynamic>> createUserPaymentMethod({
    required String name,
    required String methodType,
    required Map<String, dynamic> details,
    bool isDefault = false,
  }) async {
    try {
      developer.log('🔄 [PAYSTACK] Creating user payment method: $name');

      final response = await _apiClient
          .postWithAuth('/payments/user-payment-methods/', {
            'name': name,
            'method_type': methodType,
            'details': details,
            'is_default': isDefault,
          });

      developer.log('✅ [PAYSTACK] User payment method created successfully');
      developer.log('🔍 [PAYSTACK] Response: $response');

      return {'success': true, 'data': response};
    } catch (e) {
      developer.log('❌ [PAYSTACK] Error creating user payment method: $e');

      String errorMessage = 'Failed to create payment method';
      if (e is ApiException) {
        errorMessage = e.message;

        // Handle specific duplicate name error
        if (errorMessage.toLowerCase().contains(
              'already have a payment method',
            ) ||
            errorMessage.toLowerCase().contains('duplicate') ||
            errorMessage.toLowerCase().contains('unique constraint')) {
          errorMessage =
              'You already have a payment method with this name. Please choose a different name.';
        }
      }

      return {'success': false, 'error': errorMessage};
    }
  }

  /// Update a user payment method
  Future<Map<String, dynamic>> updateUserPaymentMethod({
    required String paymentMethodId,
    String? name,
    Map<String, dynamic>? details,
    bool? isDefault,
  }) async {
    try {
      developer.log(
        '🔄 [PAYSTACK] Updating user payment method: $paymentMethodId',
      );

      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (details != null) updateData['details'] = details;
      if (isDefault != null) updateData['is_default'] = isDefault;

      final response = await _apiClient.patchWithAuth(
        '/payments/user-payment-methods/$paymentMethodId/',
        updateData,
      );

      developer.log('✅ [PAYSTACK] User payment method updated successfully');
      developer.log('🔍 [PAYSTACK] Response: $response');

      return {'success': true, 'data': response};
    } catch (e) {
      developer.log('❌ [PAYSTACK] Error updating user payment method: $e');

      String errorMessage = 'Failed to update payment method';
      if (e is ApiException) {
        errorMessage = e.message;
      }

      return {'success': false, 'error': errorMessage};
    }
  }

  /// Delete a user payment method
  Future<Map<String, dynamic>> deleteUserPaymentMethod(
    String paymentMethodId,
  ) async {
    try {
      developer.log(
        '🔄 [PAYSTACK] Deleting user payment method: $paymentMethodId',
      );

      await _apiClient.deleteWithAuth(
        '/payments/user-payment-methods/$paymentMethodId/',
      );

      developer.log('✅ [PAYSTACK] User payment method deleted successfully');

      return {
        'success': true,
        'message': 'Payment method deleted successfully',
      };
    } catch (e) {
      developer.log('❌ [PAYSTACK] Error deleting user payment method: $e');

      String errorMessage = 'Failed to delete payment method';
      if (e is ApiException) {
        errorMessage = e.message;
      }

      return {'success': false, 'error': errorMessage};
    }
  }

  /// Get user's payment methods
  Future<Map<String, dynamic>> getUserPaymentMethods() async {
    try {
      developer.log('🔄 [PAYSTACK] Fetching user payment methods');

      final response = await _apiClient.get('/payments/user-payment-methods/');

      developer.log('✅ [PAYSTACK] User payment methods fetched successfully');
      developer.log('🔍 [PAYSTACK] Response: $response');

      // Parse the response into PaymentMethod objects
      final List<dynamic> results = response['results'] ?? response ?? [];
      final List<PaymentMethod> paymentMethods = results
          .map((item) => PaymentMethod.fromJson(item as Map<String, dynamic>))
          .toList();

      return {'success': true, 'data': paymentMethods};
    } catch (e) {
      developer.log('❌ [PAYSTACK] Error fetching user payment methods: $e');

      String errorMessage = 'Failed to fetch payment methods';
      if (e is ApiException) {
        errorMessage = e.message;
      }

      return {'success': false, 'error': errorMessage};
    }
  }

  /// Generate payment reference
  String generatePaymentReference() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'PAY_$timestamp';
  }

  /// Validate payment amount
  bool isValidAmount(double amount) {
    return amount > 0 && amount >= 1.0; // Minimum 1 GHS
  }

  /// Format amount for display
  String formatAmount(double amount, {String currency = 'GHS'}) {
    return '$currency ${amount.toStringAsFixed(2)}';
  }
}
