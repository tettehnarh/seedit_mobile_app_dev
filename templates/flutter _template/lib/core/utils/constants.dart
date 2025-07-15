/// Constants used throughout the app
class AppConstants {
  // App information
  static const String appName = 'SeedIt';
  static const String appTagline = 'Grow your wealth naturally';
  static const String appCompanyInfo =
      'a product of the\nInvestiture Fund Managers';
  static const String appRegulationInfo =
      'regulated by\nThe Securities & Exchange Commission, Ghana';

  // Navigation
  static const int splashDuration = 3; // seconds

  // Assets
  static const String logoPath = 'assets/images/seedit_logo.png';

  // API Configuration - Django backend running on port 8001 (mapped from 8000)
  static const String apiBaseUrl = 'http://localhost:8001/api';
  static const String apiBaseUrlAndroid = 'http://10.0.2.2:8001/api';
  static const String apiBaseUrlIOS = 'http://localhost:8001/api';
}
