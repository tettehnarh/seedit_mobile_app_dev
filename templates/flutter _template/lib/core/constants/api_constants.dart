class ApiConstants {
  // Base URL for the Django backend
  // Use host machine IP for mobile device access (not localhost)
  static const String baseUrl = 'http://192.168.100.210:8001/api';

  // Media URL for file serving
  static const String mediaBaseUrl = 'http://192.168.100.210:8001';

  // Auth endpoints
  static const String loginEndpoint = '/auth/login/';
  static const String registerEndpoint = '/auth/register/';
  static const String logoutEndpoint = '/auth/logout/';
  static const String forgotPasswordEndpoint = '/auth/forgot-password/';
  static const String resetPasswordEndpoint = '/auth/reset-password/';
  static const String verifyPasswordResetOtpEndpoint =
      '/auth/verify-password-reset-otp/';
  static const String userProfileEndpoint = '/auth/profile/';
  static const String updateProfileEndpoint = '/auth/profile/update/';
  static const String changePasswordEndpoint = '/auth/change-password/';
  static const String checkUsernameEndpoint = '/auth/check-username/';

  // Email verification endpoints
  static const String verifyEmailEndpoint = '/auth/verify-email/';
  static const String resendVerificationEndpoint = '/auth/resend-verification/';

  // KYC endpoints
  static const String kycStatusEndpoint = '/kyc/status/';
  static const String kycSubmitEndpoint = '/kyc/submit/';
  static const String kycPersonalInfoEndpoint = '/kyc/personal-info/';
  static const String kycNextOfKinEndpoint = '/kyc/next-of-kin/';
  static const String kycProfessionalInfoEndpoint = '/kyc/professional-info/';
  static const String kycIdInfoEndpoint = '/kyc/id-info/';
  static const String kycEventStatusEndpoint = '/kyc/event/status/';
  static const String kycEventVerifyEndpoint = '/kyc/event/verify-operation/';

  // Investment endpoints
  static const String fundsAvailableEndpoint = '/funds/available/';
  static const String fundDetailsEndpoint = '/funds/{code}/details/';
  static const String fundPerformanceEndpoint = '/funds/{code}/performance/';
  static const String investEndpoint = '/investments/invest/';
  static const String topUpInvestmentEndpoint = '/investments/top-up/';
  static const String withdrawInvestmentEndpoint = '/investments/withdraw/';
  static const String portfolioSummaryEndpoint =
      '/investments/portfolio/summary/';
  static const String portfolioOverviewEndpoint =
      '/investments/portfolio/overview/';
  static const String portfolioPerformanceEndpoint =
      '/investments/portfolio/performance/';
  static const String fundInvestmentStatusEndpoint =
      '/investments/fund/{fundId}/status/';
  static const String transactionHistoryEndpoint = '/investments/history/';
  static const String exportHistoryEndpoint = '/investments/history/export/';

  // Wallet endpoints (Payment system)
  static const String walletEndpoint = '/payments/wallet/';
  static const String walletTransactionsEndpoint =
      '/payments/wallet/transactions/';
  static const String topUpWalletEndpoint = '/payments/wallet/top-up/';
  static const String withdrawWalletEndpoint = '/payments/wallet/withdraw/';

  // Groups endpoints
  static const String groupsEndpoint = '/groups/';
  static const String joinGroupEndpoint = '/groups/join/';
  static const String leaveGroupEndpoint = '/groups/leave/';
  static const String createGroupEndpoint = '/groups/create/';
  static const String groupMembersEndpoint = '/groups/members/';

  // Goals endpoints
  static const String goalsEndpoint = '/goals/';
  static const String createGoalEndpoint = '/goals/create/';
  static const String updateGoalEndpoint = '/goals/update/';
  static const String deleteGoalEndpoint = '/goals/delete/';

  // Notifications endpoints
  static const String notificationsEndpoint = '/notifications/';
  static const String markNotificationReadEndpoint =
      '/notifications/mark-read/';
  static const String markAllNotificationsReadEndpoint =
      '/notifications/mark-all-read/';
  static const String notificationPreferencesEndpoint =
      '/notifications/preferences/';

  // Support endpoints
  static const String supportTicketsEndpoint = '/support/tickets/';
  static const String createSupportTicketEndpoint = '/support/tickets/create/';
  static const String faqEndpoint = '/support/faq/';

  // Payment methods endpoints
  static const String paymentMethodsEndpoint = '/payments/methods/';

  // Request timeout
  static const Duration requestTimeout = Duration(seconds: 30);

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Error messages
  static const String networkErrorMessage =
      'Network error. Please check your connection.';
  static const String serverErrorMessage =
      'Server error. Please try again later.';
  static const String unauthorizedErrorMessage =
      'Unauthorized. Please sign in again.';
  static const String forbiddenErrorMessage = 'Access denied.';
  static const String notFoundErrorMessage = 'Resource not found.';
  static const String timeoutErrorMessage =
      'Request timeout. Please try again.';
  static const String unknownErrorMessage = 'An unknown error occurred.';

  // Status codes
  static const int statusOk = 200;
  static const int statusCreated = 201;
  static const int statusNoContent = 204;
  static const int statusBadRequest = 400;
  static const int statusUnauthorized = 401;
  static const int statusForbidden = 403;
  static const int statusNotFound = 404;
  static const int statusInternalServerError = 500;
  static const int statusBadGateway = 502;
  static const int statusServiceUnavailable = 503;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // File upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx'];

  /// Utility method to get full URL for avatar/media files
  static String getFullMediaUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) {
      return '';
    }

    // If it's already a full URL, return as is
    if (relativePath.startsWith('http://') ||
        relativePath.startsWith('https://')) {
      return relativePath;
    }

    // If it starts with /media/, prepend the media base URL
    if (relativePath.startsWith('/media/')) {
      return '$mediaBaseUrl$relativePath';
    }

    // If it doesn't start with /, add it
    if (!relativePath.startsWith('/')) {
      return '$mediaBaseUrl/media/$relativePath';
    }

    return '$mediaBaseUrl$relativePath';
  }
}
