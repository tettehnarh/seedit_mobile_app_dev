enum Environment { development, staging, production }

class EnvironmentConfig {
  static const Environment _currentEnvironment = Environment.development;

  static Environment get currentEnvironment => _currentEnvironment;

  // AWS Configuration
  static String get awsRegion {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'us-east-1';
      case Environment.staging:
        return 'us-east-1';
      case Environment.production:
        return 'us-east-1';
    }
  }

  static String get userPoolId {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'your_dev_user_pool_id_here';
      case Environment.staging:
        return 'your_staging_user_pool_id_here';
      case Environment.production:
        return 'your_production_user_pool_id_here';
    }
  }

  static String get userPoolClientId {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'your_dev_user_pool_client_id_here';
      case Environment.staging:
        return 'your_staging_user_pool_client_id_here';
      case Environment.production:
        return 'your_production_user_pool_client_id_here';
    }
  }

  static String get identityPoolId {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'your_dev_identity_pool_id_here';
      case Environment.staging:
        return 'your_staging_identity_pool_id_here';
      case Environment.production:
        return 'your_production_identity_pool_id_here';
    }
  }

  static String get graphqlEndpoint {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'your_dev_graphql_endpoint_here';
      case Environment.staging:
        return 'your_staging_graphql_endpoint_here';
      case Environment.production:
        return 'your_production_graphql_endpoint_here';
    }
  }

  static String get storageBucket {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'your_dev_storage_bucket_here';
      case Environment.staging:
        return 'your_staging_storage_bucket_here';
      case Environment.production:
        return 'your_production_storage_bucket_here';
    }
  }

  // Application Configuration
  static String get appName {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'SeedIt (Dev)';
      case Environment.staging:
        return 'SeedIt (Staging)';
      case Environment.production:
        return 'SeedIt';
    }
  }

  static String get appVersion => '1.0.0';

  // API Configuration
  static String get apiBaseUrl {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'http://localhost:3000/api';
      case Environment.staging:
        return 'https://staging-api.seedit.com/api';
      case Environment.production:
        return 'https://api.seedit.com/api';
    }
  }

  static int get apiTimeout => 30000;

  // Payment Configuration (Paystack)
  static String get paystackPublicKey {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'your_paystack_test_public_key_here';
      case Environment.staging:
        return 'your_paystack_test_public_key_here';
      case Environment.production:
        return 'your_paystack_live_public_key_here';
    }
  }

  // Feature Flags
  static bool get enableBiometricAuth => true;
  static bool get enablePushNotifications => true;
  static bool get enableDarkMode => true;
  static bool get enableMultiLanguage {
    switch (_currentEnvironment) {
      case Environment.development:
        return false;
      case Environment.staging:
        return false;
      case Environment.production:
        return true;
    }
  }

  // Debug Configuration
  static bool get isDebugMode {
    switch (_currentEnvironment) {
      case Environment.development:
        return true;
      case Environment.staging:
        return true;
      case Environment.production:
        return false;
    }
  }

  static bool get enableLogging {
    switch (_currentEnvironment) {
      case Environment.development:
        return true;
      case Environment.staging:
        return true;
      case Environment.production:
        return false;
    }
  }
}
