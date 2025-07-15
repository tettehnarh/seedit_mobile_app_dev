import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../services/support_service.dart';
import '../models/support_models.dart';

// Provider for the API client
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// Provider for the support service
final supportServiceProvider = Provider<SupportService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SupportService(apiClient);
});

// State class for support tickets
class SupportState {
  final List<SupportTicket> tickets;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final int currentPage;
  final bool hasMoreData;
  final SupportTicketFilter? activeFilter;

  const SupportState({
    this.tickets = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.currentPage = 1,
    this.hasMoreData = true,
    this.activeFilter,
  });

  SupportState copyWith({
    List<SupportTicket>? tickets,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
    int? currentPage,
    bool? hasMoreData,
    SupportTicketFilter? activeFilter,
  }) {
    return SupportState(
      tickets: tickets ?? this.tickets,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      currentPage: currentPage ?? this.currentPage,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }
}

// Support provider
class SupportNotifier extends StateNotifier<SupportState> {
  final SupportService _supportService;

  SupportNotifier(this._supportService) : super(const SupportState());

  /// Load user's support tickets
  Future<void> loadTickets({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(isLoading: true, clearError: true);
    } else {
      state = state.copyWith(isLoadingMore: true, clearError: true);
    }

    try {
      developer.log('Loading support tickets - refresh: $refresh');

      final tickets = await _supportService.getUserTickets(
        page: refresh ? 1 : state.currentPage,
        pageSize: 20,
        status: state.activeFilter?.status,
      );

      if (refresh) {
        state = state.copyWith(
          tickets: tickets,
          isLoading: false,
          currentPage: 2,
          hasMoreData: tickets.length == 20,
        );
      } else {
        final updatedTickets = [...state.tickets, ...tickets];
        state = state.copyWith(
          tickets: updatedTickets,
          isLoadingMore: false,
          currentPage: state.currentPage + 1,
          hasMoreData: tickets.length == 20,
        );
      }
    } catch (e) {
      developer.log('Error loading support tickets: $e', error: e);
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Create a new support ticket
  Future<SupportTicket?> createTicket({
    required String subject,
    required String description,
    required String issueType,
    String? transactionId,
    String? fundId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      developer.log('Creating support ticket: $subject');

      final ticket = await _supportService.createTicket(
        subject: subject,
        description: description,
        issueType: issueType,
        transactionId: transactionId,
        fundId: fundId,
        metadata: metadata,
      );

      // Add the new ticket to the beginning of the list
      final updatedTickets = [ticket, ...state.tickets];
      state = state.copyWith(tickets: updatedTickets);

      return ticket;
    } catch (e) {
      developer.log('Error creating support ticket: $e', error: e);
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  /// Create a transaction report
  Future<SupportTicket?> createTransactionReport({
    required String transactionId,
    required String issueType,
    required String description,
    required String fundName,
    required double amount,
    required String transactionType,
  }) async {
    try {
      developer.log('Creating transaction report for: $transactionId');

      final ticket = await _supportService.createTransactionReport(
        transactionId: transactionId,
        issueType: issueType,
        description: description,
        fundName: fundName,
        amount: amount,
        transactionType: transactionType,
      );

      // Add the new ticket to the beginning of the list
      final updatedTickets = [ticket, ...state.tickets];
      state = state.copyWith(tickets: updatedTickets);

      return ticket;
    } catch (e) {
      developer.log('Error creating transaction report: $e', error: e);
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  /// Get ticket by ID
  Future<SupportTicket?> getTicketById(String ticketId) async {
    try {
      developer.log('Fetching ticket details for ID: $ticketId');
      return await _supportService.getTicketById(ticketId);
    } catch (e) {
      developer.log('Error fetching ticket details: $e', error: e);
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  /// Add message to ticket
  Future<SupportMessage?> addTicketMessage({
    required String ticketId,
    required String message,
  }) async {
    try {
      developer.log('Adding message to ticket: $ticketId');
      return await _supportService.addTicketMessage(
        ticketId: ticketId,
        message: message,
      );
    } catch (e) {
      developer.log('Error adding ticket message: $e', error: e);
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  /// Get ticket messages
  Future<List<SupportMessage>> getTicketMessages(String ticketId) async {
    try {
      developer.log('Fetching messages for ticket: $ticketId');
      return await _supportService.getTicketMessages(ticketId);
    } catch (e) {
      developer.log('Error fetching ticket messages: $e', error: e);
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  /// Close ticket
  Future<SupportTicket?> closeTicket(String ticketId) async {
    try {
      developer.log('Closing ticket: $ticketId');
      
      final updatedTicket = await _supportService.closeTicket(ticketId);
      
      // Update the ticket in the list
      final updatedTickets = state.tickets.map((ticket) {
        return ticket.id == ticketId ? updatedTicket : ticket;
      }).toList();
      
      state = state.copyWith(tickets: updatedTickets);
      
      return updatedTicket;
    } catch (e) {
      developer.log('Error closing ticket: $e', error: e);
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  /// Apply filter to tickets
  void applyFilter(SupportTicketFilter filter) {
    state = state.copyWith(activeFilter: filter);
    loadTickets(refresh: true);
  }

  /// Clear filter
  void clearFilter() {
    state = state.copyWith(activeFilter: null);
    loadTickets(refresh: true);
  }

  /// Refresh tickets
  Future<void> refreshTickets() async {
    await loadTickets(refresh: true);
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// Provider for the support notifier
final supportProvider = StateNotifierProvider<SupportNotifier, SupportState>((ref) {
  final supportService = ref.watch(supportServiceProvider);
  return SupportNotifier(supportService);
});

// Provider for ticket messages
final ticketMessagesProvider = FutureProvider.family<List<SupportMessage>, String>((ref, ticketId) async {
  final supportService = ref.watch(supportServiceProvider);
  return supportService.getTicketMessages(ticketId);
});

// Provider for single ticket details
final ticketDetailsProvider = FutureProvider.family<SupportTicket?, String>((ref, ticketId) async {
  final supportService = ref.watch(supportServiceProvider);
  return supportService.getTicketById(ticketId);
});
