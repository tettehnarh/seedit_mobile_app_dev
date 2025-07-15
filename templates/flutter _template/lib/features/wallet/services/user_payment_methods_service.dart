import 'dart:developer' as developer;
import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../models/wallet_models.dart';

/// Service for managing user payment methods
class UserPaymentMethodsService {
  final ApiClient _apiClient = ApiClient();

  /// Get all user payment methods
  Future<List<PaymentMethod>> getUserPaymentMethods() async {
    try {
      final response = await _apiClient.get('/payments/user-payment-methods/');

      if (response != null && response['results'] != null) {
        final List<dynamic> methodsData = response['results'];
        return methodsData
            .map((item) => PaymentMethod.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      developer.log('Error loading user payment methods: $e', error: e);
      throw NetworkException('Failed to load payment methods');
    }
  }

  /// Create a new payment method
  Future<PaymentMethod> createPaymentMethod({
    required String name,
    required String type,
    required Map<String, dynamic> details,
    bool isDefault = false,
  }) async {
    try {
      final response = await _apiClient.postWithAuth(
        '/payments/user-payment-methods/',
        {
          'name': name,
          'method_type':
              type, // Changed from 'type' to 'method_type' to match DRF serializer
          'details': details,
          'is_default':
              isDefault, // Changed from 'isDefault' to 'is_default' to match DRF serializer
        },
      );

      if (response != null) {
        return PaymentMethod.fromJson(response);
      }

      throw ServerException('Invalid response from server');
    } catch (e) {
      developer.log('Error creating payment method: $e', error: e);
      throw NetworkException('Failed to create payment method');
    }
  }

  /// Update a payment method
  Future<PaymentMethod> updatePaymentMethod({
    required String id,
    String? name,
    Map<String, dynamic>? details,
    bool? isDefault,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (details != null) updateData['details'] = details;
      if (isDefault != null) {
        updateData['is_default'] =
            isDefault; // Changed from 'isDefault' to 'is_default'
      }

      final response = await _apiClient.patchWithAuth(
        '/payments/user-payment-methods/$id/',
        updateData,
      );

      if (response != null) {
        return PaymentMethod.fromJson(response);
      }

      throw ServerException('Invalid response from server');
    } catch (e) {
      developer.log('Error updating payment method: $e', error: e);
      throw NetworkException('Failed to update payment method');
    }
  }

  /// Delete a payment method
  Future<void> deletePaymentMethod(String id) async {
    try {
      await _apiClient.deleteWithAuth('/payments/user-payment-methods/$id/');
      developer.log('Payment method deleted successfully: $id');
    } catch (e) {
      developer.log('Error deleting payment method: $e', error: e);
      throw NetworkException('Failed to delete payment method');
    }
  }

  /// Get a specific payment method
  Future<PaymentMethod> getPaymentMethod(String id) async {
    try {
      final response = await _apiClient.get(
        '/payments/user-payment-methods/$id/',
      );

      if (response != null) {
        return PaymentMethod.fromJson(response);
      }

      throw NotFoundException('Payment method not found');
    } catch (e) {
      developer.log('Error getting payment method: $e', error: e);
      throw NetworkException('Failed to get payment method');
    }
  }

  /// Get available payment method types
  List<Map<String, String>> getAvailablePaymentMethodTypes() {
    return [
      {
        'type': 'bank_account',
        'name': 'Bank Account',
        'description': 'Add your bank account for transfers',
      },
      {
        'type': 'mobile_money',
        'name': 'Mobile Money',
        'description': 'Add your mobile money wallet',
      },
      {
        'type': 'card',
        'name': 'Credit/Debit Card',
        'description': 'Add your credit or debit card',
      },
      {
        'type': 'crypto_wallet',
        'name': 'Crypto Wallet',
        'description': 'Add your cryptocurrency wallet',
      },
    ];
  }

  /// Validate payment method details based on type
  Map<String, String>? validatePaymentMethodDetails(
    String type,
    Map<String, dynamic> details,
  ) {
    final errors = <String, String>{};

    switch (type) {
      case 'bank_account':
        if (details['bank_name'] == null ||
            details['bank_name'].toString().isEmpty) {
          errors['bank_name'] = 'Bank name is required';
        }
        if (details['account_number'] == null ||
            details['account_number'].toString().isEmpty) {
          errors['account_number'] = 'Account number is required';
        }
        if (details['account_name'] == null ||
            details['account_name'].toString().isEmpty) {
          errors['account_name'] = 'Account name is required';
        }
        break;

      case 'mobile_money':
        if (details['provider'] == null ||
            details['provider'].toString().isEmpty) {
          errors['provider'] = 'Provider is required';
        }
        if (details['phone_number'] == null ||
            details['phone_number'].toString().isEmpty) {
          errors['phone_number'] = 'Phone number is required';
        }
        if (details['account_name'] == null ||
            details['account_name'].toString().isEmpty) {
          errors['account_name'] = 'Account name is required';
        }
        break;

      case 'card':
        if (details['card_number'] == null ||
            details['card_number'].toString().isEmpty) {
          errors['card_number'] = 'Card number is required';
        }
        if (details['card_type'] == null ||
            details['card_type'].toString().isEmpty) {
          errors['card_type'] = 'Card type is required';
        }
        if (details['cardholder_name'] == null ||
            details['cardholder_name'].toString().isEmpty) {
          errors['cardholder_name'] = 'Cardholder name is required';
        }
        break;

      case 'crypto_wallet':
        if (details['currency'] == null ||
            details['currency'].toString().isEmpty) {
          errors['currency'] = 'Currency is required';
        }
        if (details['address'] == null ||
            details['address'].toString().isEmpty) {
          errors['address'] = 'Wallet address is required';
        }
        break;
    }

    return errors.isEmpty ? null : errors;
  }

  void dispose() {
    _apiClient.dispose();
  }
}
