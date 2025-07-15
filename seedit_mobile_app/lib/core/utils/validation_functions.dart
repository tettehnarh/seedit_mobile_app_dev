class ValidationFunctions {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    
    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    
    // Check for at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    
    // Check for at least one digit
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    
    // Check for at least one special character
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    
    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.length < 2) {
      return 'Name must be at least 2 characters long';
    }
    
    if (value.length > 50) {
      return 'Name must be less than 50 characters';
    }
    
    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(value)) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }
    
    return null;
  }

  // Phone number validation
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove all non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    
    // Check for Nigerian phone number format
    if (digitsOnly.length == 11 && digitsOnly.startsWith('0')) {
      return null; // Valid Nigerian number (e.g., 08012345678)
    }
    
    if (digitsOnly.length == 13 && digitsOnly.startsWith('234')) {
      return null; // Valid Nigerian number with country code (e.g., 2348012345678)
    }
    
    if (digitsOnly.length >= 10 && digitsOnly.length <= 15) {
      return null; // Valid international number
    }
    
    return 'Please enter a valid phone number';
  }

  // Required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Numeric validation
  static String? validateNumeric(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    if (double.tryParse(value) == null) {
      return '$fieldName must be a valid number';
    }
    
    return null;
  }

  // Amount validation
  static String? validateAmount(String? value, {double? minAmount, double? maxAmount}) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }
    
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid amount';
    }
    
    if (amount <= 0) {
      return 'Amount must be greater than zero';
    }
    
    if (minAmount != null && amount < minAmount) {
      return 'Amount must be at least ₦${minAmount.toStringAsFixed(2)}';
    }
    
    if (maxAmount != null && amount > maxAmount) {
      return 'Amount cannot exceed ₦${maxAmount.toStringAsFixed(2)}';
    }
    
    return null;
  }

  // Date validation
  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date is required';
    }
    
    try {
      final date = DateTime.parse(value);
      final now = DateTime.now();
      
      // Check if date is in the future
      if (date.isAfter(now)) {
        return 'Date cannot be in the future';
      }
      
      // Check if date is too far in the past (e.g., more than 100 years ago)
      final hundredYearsAgo = DateTime(now.year - 100, now.month, now.day);
      if (date.isBefore(hundredYearsAgo)) {
        return 'Date cannot be more than 100 years ago';
      }
      
      return null;
    } catch (e) {
      return 'Please enter a valid date';
    }
  }

  // Age validation (for date of birth)
  static String? validateAge(String? value, {int? minAge, int? maxAge}) {
    if (value == null || value.isEmpty) {
      return 'Date of birth is required';
    }
    
    try {
      final birthDate = DateTime.parse(value);
      final now = DateTime.now();
      
      if (birthDate.isAfter(now)) {
        return 'Date of birth cannot be in the future';
      }
      
      final age = now.year - birthDate.year;
      final hasHadBirthdayThisYear = now.month > birthDate.month ||
          (now.month == birthDate.month && now.day >= birthDate.day);
      
      final actualAge = hasHadBirthdayThisYear ? age : age - 1;
      
      if (minAge != null && actualAge < minAge) {
        return 'You must be at least $minAge years old';
      }
      
      if (maxAge != null && actualAge > maxAge) {
        return 'Age cannot exceed $maxAge years';
      }
      
      return null;
    } catch (e) {
      return 'Please enter a valid date of birth';
    }
  }

  // BVN validation (Bank Verification Number for Nigeria)
  static String? validateBVN(String? value) {
    if (value == null || value.isEmpty) {
      return 'BVN is required';
    }
    
    // Remove all non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.length != 11) {
      return 'BVN must be exactly 11 digits';
    }
    
    return null;
  }

  // NIN validation (National Identification Number for Nigeria)
  static String? validateNIN(String? value) {
    if (value == null || value.isEmpty) {
      return 'NIN is required';
    }
    
    // Remove all non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.length != 11) {
      return 'NIN must be exactly 11 digits';
    }
    
    return null;
  }

  // Address validation
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }
    
    if (value.length < 10) {
      return 'Please provide a more detailed address';
    }
    
    if (value.length > 200) {
      return 'Address is too long';
    }
    
    return null;
  }

  // Confirmation code validation
  static String? validateConfirmationCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirmation code is required';
    }
    
    // Remove all non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.length != 6) {
      return 'Confirmation code must be 6 digits';
    }
    
    return null;
  }

  // Custom validation for matching fields
  static String? validateMatch(String? value, String? compareValue, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    if (value != compareValue) {
      return '${fieldName}s do not match';
    }
    
    return null;
  }
}
