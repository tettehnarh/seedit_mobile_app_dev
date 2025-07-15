class KycDateFormatter {
  /// Format DateTime to YYYY-MM-DD string for backend submission
  static String formatForBackend(DateTime date) {
    return '${date.year}-${_pad(date.month)}-${_pad(date.day)}';
  }

  /// Format DateTime to DD/MM/YYYY string for display purposes
  static String formatForDisplay(DateTime date) {
    return '${_pad(date.day)}/${_pad(date.month)}/${date.year}';
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');

  /// Parse date string from various formats to DateTime
  static DateTime? parseDate(String dateString) {
    if (dateString.isEmpty) return null;

    // Normalize input
    dateString = dateString.trim();

    try {
      // Try ISO format first (YYYY-MM-DD)
      if (dateString.contains('-') && dateString.length >= 10) {
        final isoDate = dateString.substring(0, 10); // Take only date part
        final parsed = DateTime.tryParse(isoDate);
        if (parsed != null) {
          // developer.log('✅ Parsed as ISO format: $isoDate');
          return parsed;
        }
      }

      // Try DD/MM/YYYY or MM/DD/YYYY
      if (dateString.contains('/') && dateString.split('/').length == 3) {
        final parts = dateString.split('/');
        int day = int.tryParse(parts[0]) ?? 1;
        int month = int.tryParse(parts[1]) ?? 1;
        int year = int.tryParse(parts[2]) ?? 1900;

        try {
          final date = DateTime(year, month, day);
          // developer.log('✅ Parsed as DD/MM/YYYY: $dateString → $date');
          return date;
        } catch (e) {
          // developer.log('❌ Failed to parse DD/MM/YYYY: $dateString');
        }
      }

      // Try DD-MM-YYYY or MM-DD-YYYY
      if (dateString.contains('-') && dateString.split('-').length == 3) {
        final parts = dateString.split('-');
        int day = int.tryParse(parts[0]) ?? 1;
        int month = int.tryParse(parts[1]) ?? 1;
        int year = int.tryParse(parts[2]) ?? 1900;

        try {
          final date = DateTime(year, month, day);
          // developer.log('✅ Parsed as DD-MM-YYYY: $dateString → $date');
          return date;
        } catch (e) {
          // developer.log('❌ Failed to parse DD-MM-YYYY: $dateString');
        }
      }

      // Final fallback: let Dart try to parse it
      final fallback = DateTime.tryParse(dateString);
      if (fallback != null) {
        // developer.log('✅ Parsed using fallback: $dateString → $fallback');
        return fallback;
      }

      // developer.log('❌ Failed to parse date: "$dateString" - Unsupported format');
      return null;
    } catch (e) {
      // developer.log('💥 Exception while parsing date: "$dateString" → $e');
      return null;
    }
  }

  /// Validate that a date is at least 18 years ago (for age validation)
  static bool isAtLeast18YearsOld(DateTime birthDate) {
    final now = DateTime.now();
    final eighteenYearsAgo = DateTime(now.year - 18, now.month, now.day);
    return birthDate.isBefore(eighteenYearsAgo) ||
        birthDate.isAtSameMomentAs(eighteenYearsAgo);
  }

  /// Validate that a date is in the future (for ID expiry validation)
  static bool isFutureDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);
    return checkDate.isAfter(today);
  }

  /// Get age in years from birth date
  static int getAgeInYears(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;

    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  /// Format date for form field display (DD/MM/YYYY)
  static String formatForFormField(DateTime? date) {
    if (date == null) return '';
    return formatForDisplay(date);
  }

  /// Validate date string format
  static bool isValidDateFormat(
    String dateString, {
    bool isBackendFormat = true,
  }) {
    if (dateString.isEmpty) {
      return false;
    }

    try {
      if (isBackendFormat) {
        final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
        if (!regex.hasMatch(dateString)) {
          return false;
        }
        DateTime.parse(dateString);
      } else {
        final regex = RegExp(r'^\d{1,2}/\d{1,2}/\d{4}$');
        if (!regex.hasMatch(dateString)) {
          return false;
        }
        final parsedDate = parseDate(dateString);
        if (parsedDate == null) {
          return false;
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
