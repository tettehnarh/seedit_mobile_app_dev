/// Validation functions for form inputs
class ValidationFunctions {
  /// Validate email format
  static bool isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(email);
  }

  /// Validate password strength
  static bool isValidPassword(String password) {
    // At least 8 characters, contains uppercase, lowercase, number
    final passwordRegExp = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$');
    return passwordRegExp.hasMatch(password);
  }

  /// Validate phone number format
  static bool isValidPhoneNumber(String phoneNumber) {
    // Basic phone number validation (can be enhanced based on requirements)
    final phoneRegExp = RegExp(r'^\+?[1-9]\d{1,14}$');
    return phoneRegExp.hasMatch(phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), ''));
  }

  /// Validate PIN format (6 digits)
  static bool isValidPin(String pin) {
    final pinRegExp = RegExp(r'^\d{6}$');
    return pinRegExp.hasMatch(pin);
  }

  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate email field
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!isValidEmail(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validate password field
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Validate confirm password field
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validate phone number field
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (!isValidPhoneNumber(value.trim())) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Validate PIN field
  static String? validatePin(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'PIN is required';
    }
    if (!isValidPin(value.trim())) {
      return 'PIN must be 6 digits';
    }
    return null;
  }

  /// Validate amount field
  static String? validateAmount(String? value, {double? minAmount, double? maxAmount}) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }
    
    final amount = double.tryParse(value.trim());
    if (amount == null) {
      return 'Please enter a valid amount';
    }
    
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    
    if (minAmount != null && amount < minAmount) {
      return 'Amount must be at least \$${minAmount.toStringAsFixed(2)}';
    }
    
    if (maxAmount != null && amount > maxAmount) {
      return 'Amount cannot exceed \$${maxAmount.toStringAsFixed(2)}';
    }
    
    return null;
  }
}

/// Global validation functions for backward compatibility
bool isValidEmail(String email) => ValidationFunctions.isValidEmail(email);
bool isValidPassword(String password) => ValidationFunctions.isValidPassword(password);
bool isValidPhoneNumber(String phoneNumber) => ValidationFunctions.isValidPhoneNumber(phoneNumber);
bool isValidPin(String pin) => ValidationFunctions.isValidPin(pin);
