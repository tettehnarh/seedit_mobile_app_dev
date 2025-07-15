import 'dart:developer' as developer;
import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../models/support_models.dart';

class SupportService {
  final ApiClient _apiClient;

  SupportService(this._apiClient);

  /// Create a new support ticket
  Future<SupportTicket> createTicket({
    required String subject,
    required String description,
    required String issueType,
    String? transactionId,
    String? fundId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      developer.log('Creating support ticket with subject: $subject');

      final requestData = {
        'subject': subject,
        'description': description,
        'issue_type': issueType,
        'status': 'open',
        if (transactionId != null) 'transaction_id': transactionId,
        if (fundId != null) 'fund_id': fundId,
        if (metadata != null) 'metadata': metadata,
      };

      final response = await _apiClient.postWithAuth(
        '/support/tickets/',
        requestData,
      );

      return SupportTicket.fromJson(response);
    } catch (e) {
      developer.log('Error creating support ticket: $e', error: e);
      if (e is ApiException) {
        rethrow;
      }
      throw ServerException('Failed to create support ticket');
    }
  }

  /// Get user's support tickets
  Future<List<SupportTicket>> getUserTickets({
    int page = 1,
    int pageSize = 20,
    String? status,
  }) async {
    try {
      developer.log('Fetching user support tickets - page: $page');

      final queryParams = <String, String>{
        'page': page.toString(),
        'page_size': pageSize.toString(),
      };

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await _apiClient.get('/support/tickets/?$queryString');

      final List<SupportTicket> tickets = [];

      if (response['results'] != null) {
        final List<dynamic> ticketsData = response['results'];
        tickets.addAll(
          ticketsData.map((ticket) => SupportTicket.fromJson(ticket)).toList(),
        );
      } else if (response is List) {
        tickets.addAll(
          response.map((ticket) => SupportTicket.fromJson(ticket)).toList(),
        );
      }

      return tickets;
    } catch (e) {
      developer.log('Error fetching support tickets: $e', error: e);
      if (e is ApiException) {
        rethrow;
      }
      throw ServerException('Failed to fetch support tickets');
    }
  }

  /// Get ticket by ID
  Future<SupportTicket?> getTicketById(String ticketId) async {
    try {
      developer.log('Fetching support ticket details for ID: $ticketId');

      final response = await _apiClient.get('/support/tickets/$ticketId/');

      return SupportTicket.fromJson(response);
    } catch (e) {
      developer.log('Error fetching support ticket details: $e', error: e);
      if (e is ApiException) {
        rethrow;
      }
      throw ServerException('Failed to fetch support ticket details');
    }
  }

  /// Add a message to a ticket
  Future<SupportMessage> addTicketMessage({
    required String ticketId,
    required String message,
  }) async {
    try {
      developer.log('Adding message to ticket: $ticketId');

      final requestData = {'message': message};

      final response = await _apiClient.postWithAuth(
        '/support/tickets/$ticketId/messages/',
        requestData,
      );

      return SupportMessage.fromJson(response);
    } catch (e) {
      developer.log('Error adding ticket message: $e', error: e);
      if (e is ApiException) {
        rethrow;
      }
      throw ServerException('Failed to add ticket message');
    }
  }

  /// Get messages for a ticket
  Future<List<SupportMessage>> getTicketMessages(String ticketId) async {
    try {
      developer.log('Fetching messages for ticket: $ticketId');

      final response = await _apiClient.get(
        '/support/tickets/$ticketId/messages/',
      );

      final List<SupportMessage> messages = [];

      if (response['results'] != null) {
        final List<dynamic> messagesData = response['results'];
        messages.addAll(
          messagesData
              .map((message) => SupportMessage.fromJson(message))
              .toList(),
        );
      } else if (response is List) {
        messages.addAll(
          response.map((message) => SupportMessage.fromJson(message)).toList(),
        );
      }

      return messages;
    } catch (e) {
      developer.log('Error fetching ticket messages: $e', error: e);
      if (e is ApiException) {
        rethrow;
      }
      throw ServerException('Failed to fetch ticket messages');
    }
  }

  /// Close a support ticket
  Future<SupportTicket> closeTicket(String ticketId) async {
    try {
      developer.log('Closing support ticket: $ticketId');

      final requestData = {'status': 'closed'};

      final response = await _apiClient.patchWithAuth(
        '/support/tickets/$ticketId/',
        requestData,
      );

      return SupportTicket.fromJson(response);
    } catch (e) {
      developer.log('Error closing support ticket: $e', error: e);
      if (e is ApiException) {
        rethrow;
      }
      throw ServerException('Failed to close support ticket');
    }
  }

  /// Create a transaction-related support ticket
  Future<SupportTicket> createTransactionReport({
    required String transactionId,
    required String issueType,
    required String description,
    required String fundName,
    required double amount,
    required String transactionType,
  }) async {
    try {
      developer.log(
        'Creating transaction report for transaction: $transactionId',
      );

      final requestData = {
        'transaction_id': transactionId,
        'issue_type': issueType,
        'description': description,
        'fund_name': fundName,
        'amount': amount,
        'transaction_type': transactionType,
      };

      final response = await _apiClient.postWithAuth(
        '/support/transaction-report/',
        requestData,
      );

      return SupportTicket.fromJson(response);
    } catch (e) {
      developer.log('Error creating transaction report: $e', error: e);
      if (e is ApiException) {
        rethrow;
      }
      throw ServerException('Failed to create transaction report');
    }
  }
}
