import 'dart:developer' as developer;
import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/constants/api_constants.dart';
import '../models/investment_models.dart';

/// Service for handling investment-related API calls
class InvestmentService {
  final ApiClient _apiClient = ApiClient();

  /// Get available funds for investment
  Future<List<Fund>> getAvailableFunds() async {
    try {
      developer.log(
        'Fetching available funds from: ${ApiConstants.baseUrl}${ApiConstants.fundsAvailableEndpoint}',
      );

      final response = await _apiClient.get(
        ApiConstants.fundsAvailableEndpoint,
      );

      developer.log('Available funds API response: $response');

      // Handle Django API response structure: {funds: [...], count: N}
      if (response['funds'] != null) {
        final List<dynamic> fundsData = response['funds'];
        developer.log('Found ${fundsData.length} funds in response');
        final funds = fundsData.map((fund) => Fund.fromJson(fund)).toList();
        developer.log('Successfully parsed ${funds.length} funds');
        return funds;
      } else if (response['results'] != null) {
        final List<dynamic> fundsData = response['results'];
        developer.log('Found ${fundsData.length} funds in results');
        return fundsData.map((fund) => Fund.fromJson(fund)).toList();
      } else if (response is List) {
        developer.log('Response is direct array with ${response.length} items');
        return response.map((fund) => Fund.fromJson(fund)).toList();
      }

      developer.log('No funds found in response structure');
      return [];
    } catch (e) {
      developer.log('Error fetching available funds: $e', error: e);
      if (e is ApiException) {
        developer.log('API Exception details: ${e.message}');
        // If it's an authentication error, we'll let the provider handle it with sample data
        if (e is UnauthorizedException) {
          developer.log('Authentication error - will use sample funds');
        }
        rethrow;
      }
      throw ServerException('Failed to fetch available funds');
    }
  }

  /// Get fund details by code
  Future<Fund> getFundDetails(String fundCode) async {
    try {
      developer.log('Fetching fund details for: $fundCode');

      final endpoint = ApiConstants.fundDetailsEndpoint.replaceAll(
        '{code}',
        fundCode,
      );
      final response = await _apiClient.get(endpoint);

      return Fund.fromJson(response);
    } catch (e) {
      developer.log('Error fetching fund details: $e', error: e);
      if (e is ApiException) {
        rethrow;
      }
      throw ServerException('Failed to fetch fund details');
    }
  }

  /// Get portfolio summary
  Future<PortfolioSummary> getPortfolioSummary() async {
    try {
      developer.log('Fetching portfolio summary');

      final response = await _apiClient.get(
        ApiConstants.portfolioSummaryEndpoint,
      );

      return PortfolioSummary.fromJson(response);
    } catch (e) {
      developer.log('Error fetching portfolio summary: $e', error: e);
      if (e is ApiException) {
        rethrow;
      }
      throw ServerException('Failed to fetch portfolio summary');
    }
  }

  /// Get portfolio overview for home screen
  Future<Map<String, dynamic>> getPortfolioOverview() async {
    try {
      developer.log('Fetching portfolio overview');

      final response = await _apiClient.get(
        ApiConstants.portfolioOverviewEndpoint,
      );

      return response;
    } catch (e) {
      developer.log('Error fetching portfolio overview: $e', error: e);
      if (e is ApiException) {
        rethrow;
      }
      throw ServerException('Failed to fetch portfolio overview');
    }
  }

  /// Get fund investment status for a specific fund
  Future<Map<String, dynamic>> getFundInvestmentStatus(String fundId) async {
    try {
      developer.log('Fetching fund investment status for fund: $fundId');

      final endpoint = ApiConstants.fundInvestmentStatusEndpoint.replaceAll(
        '{fundId}',
        fundId,
      );
      final response = await _apiClient.get(endpoint);

      return response;
    } catch (e) {
      developer.log('Error fetching fund investment status: $e', error: e);
      if (e is ApiException) {
        rethrow;
      }
      throw ServerException('Failed to fetch fund investment status');
    }
  }

  /// Get portfolio performance data
  Future<Map<String, dynamic>> getPortfolioPerformance({
    String period = '1Y',
  }) async {
    try {
      developer.log('Fetching portfolio performance for period: $period');

      final response = await _apiClient.get(
        '${ApiConstants.portfolioPerformanceEndpoint}?period=$period',
      );

      return response;
    } catch (e) {
      developer.log('Error fetching portfolio performance: $e', error: e);
      if (e is ApiException) {
        rethrow;
      }
      throw ServerException('Failed to fetch portfolio performance');
    }
  }

  /// Get transaction history
  Future<Map<String, dynamic>> getTransactionHistory({
    int page = 1,
    int pageSize = 20,
    String? transactionType,
    String? fundId,
    String? status,
    String? startDate,
    String? endDate,
    String? searchQuery,
  }) async {
    try {
      developer.log(
        'Fetching transaction history - page: $page, size: $pageSize',
      );

      final queryParams = <String, String>{
        'page': page.toString(),
        'page_size': pageSize.toString(),
      };

      if (transactionType != null && transactionType.isNotEmpty) {
        queryParams['type'] = transactionType;
      }

      if (fundId != null && fundId.isNotEmpty) {
        queryParams['fund_id'] = fundId;
      }

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      if (startDate != null && startDate.isNotEmpty) {
        queryParams['start_date'] = startDate;
      }

      if (endDate != null && endDate.isNotEmpty) {
        queryParams['end_date'] = endDate;
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await _apiClient.get(
        '${ApiConstants.transactionHistoryEndpoint}?$queryString',
      );

      final List<TransactionModel> transactions = [];

      if (response['results'] != null) {
        final List<dynamic> transactionsData = response['results'];
        transactions.addAll(
          transactionsData
              .map((transaction) => TransactionModel.fromJson(transaction))
              .toList(),
        );
      } else if (response is List) {
        transactions.addAll(
          response
              .map((transaction) => TransactionModel.fromJson(transaction))
              .toList(),
        );
      }

      return {
        'transactions': transactions,
        'pagination': response['pagination'] ?? {},
        'filters': response['filters'] ?? {},
        'count': response['count'] ?? transactions.length,
        'hasNext': response['next'] != null,
        'hasPrevious': response['previous'] != null,
      };
    } catch (e) {
      developer.log('Error fetching transaction history: $e', error: e);
      if (e is ApiException) {
        rethrow;
      }
      throw ServerException('Failed to fetch transaction history');
    }
  }

  /// Search transactions with query
  Future<List<TransactionModel>> searchTransactions(String query) async {
    try {
      developer.log('Searching transactions with query: $query');

      final result = await getTransactionHistory(
        searchQuery: query,
        pageSize: 50, // Get more results for search
      );

      return result['transactions'] as List<TransactionModel>;
    } catch (e) {
      developer.log('Error searching transactions: $e', error: e);
      if (e is ApiException) {
        rethrow;
      }
      throw ServerException('Failed to search transactions');
    }
  }

  /// Get transaction details by ID
  Future<TransactionModel?> getTransactionById(String transactionId) async {
    try {
      developer.log('Fetching transaction details for ID: $transactionId');

      final response = await _apiClient.get(
        '/investments/transactions/$transactionId/',
      );

      return TransactionModel.fromJson(response);
    } catch (e) {
      developer.log('Error fetching transaction details: $e', error: e);
      if (e is ApiException) {
        rethrow;
      }
      throw ServerException('Failed to fetch transaction details');
    }
  }

  /// Create new investment
  Future<Map<String, dynamic>> createInvestment({
    required String fundId,
    required double amount,
    String paymentMethod = 'wallet',
  }) async {
    try {
      developer.log('Creating investment - Fund: $fundId, Amount: $amount');

      final response = await _apiClient.postWithAuth(
        ApiConstants.investEndpoint,
        {'fund_id': fundId, 'amount': amount, 'payment_method': paymentMethod},
      );

      return {
        'success': true,
        'data': response,
        'message': 'Investment created successfully',
      };
    } catch (e) {
      developer.log('Error creating investment: $e', error: e);

      if (e is ApiException) {
        return {'success': false, 'error': e.message};
      }

      return {
        'success': false,
        'error': 'Failed to create investment. Please try again.',
      };
    }
  }

  /// Top up existing investment
  Future<Map<String, dynamic>> topUpInvestment({
    required String investmentId,
    required double amount,
    String paymentMethod = 'wallet',
  }) async {
    try {
      developer.log(
        'Topping up investment - ID: $investmentId, Amount: $amount',
      );

      final response = await _apiClient
          .postWithAuth(ApiConstants.topUpInvestmentEndpoint, {
            'investment_id': investmentId,
            'amount': amount,
            'payment_method': paymentMethod,
          });

      return {
        'success': true,
        'data': response,
        'message': 'Investment topped up successfully',
      };
    } catch (e) {
      developer.log('Error topping up investment: $e', error: e);

      if (e is ApiException) {
        return {'success': false, 'error': e.message};
      }

      return {
        'success': false,
        'error': 'Failed to top up investment. Please try again.',
      };
    }
  }

  /// Withdraw from investment
  Future<Map<String, dynamic>> withdrawFromInvestment({
    required String investmentId,
    required double amount,
    String withdrawalMethod = 'wallet',
  }) async {
    try {
      developer.log(
        'Withdrawing from investment - ID: $investmentId, Amount: $amount',
      );

      final response = await _apiClient
          .postWithAuth(ApiConstants.withdrawInvestmentEndpoint, {
            'investment_id': investmentId,
            'amount': amount,
            'withdrawal_method': withdrawalMethod,
          });

      return {
        'success': true,
        'data': response,
        'message': 'Withdrawal processed successfully',
      };
    } catch (e) {
      developer.log('Error withdrawing from investment: $e', error: e);

      if (e is ApiException) {
        return {'success': false, 'error': e.message};
      }

      return {
        'success': false,
        'error': 'Failed to process withdrawal. Please try again.',
      };
    }
  }

  /// Export transaction history
  Future<Map<String, dynamic>> exportTransactionHistory({
    required String format, // 'pdf' or 'csv'
    String? startDate,
    String? endDate,
  }) async {
    try {
      developer.log('Exporting transaction history - Format: $format');

      final data = <String, dynamic>{'format': format};

      if (startDate != null) data['start_date'] = startDate;
      if (endDate != null) data['end_date'] = endDate;

      final response = await _apiClient.postWithAuth(
        ApiConstants.exportHistoryEndpoint,
        data,
      );

      return {'success': true, 'data': response};
    } catch (e) {
      developer.log('Error exporting transaction history: $e', error: e);

      if (e is ApiException) {
        return {'success': false, 'error': e.message};
      }

      return {
        'success': false,
        'error': 'Failed to export transaction history. Please try again.',
      };
    }
  }

  /// Dispose resources
  void dispose() {
    _apiClient.dispose();
  }
}
