import 'package:intl/intl.dart';

/// Utility class for formatting currency and monetary amounts
class CurrencyFormatter {
  // Private constructor to prevent instantiation
  CurrencyFormatter._();

  /// Default currency symbol for Ghana Cedis
  static const String defaultCurrency = 'GHS';

  /// Number formatter with comma thousands separator
  static final NumberFormat _numberFormatter = NumberFormat('#,##0.00');

  /// Number formatter without decimal places for whole numbers
  static final NumberFormat _wholeNumberFormatter = NumberFormat('#,##0');

  /// Formats a monetary amount with thousands separators and decimal places
  /// 
  /// Example: 10000.50 -> "10,000.50"
  static String formatAmount(dynamic amount) {
    if (amount == null) return '0.00';
    
    final double value = _parseToDouble(amount);
    return _numberFormatter.format(value);
  }

  /// Formats a monetary amount with currency prefix
  /// 
  /// Example: 10000.50 -> "GHS 10,000.50"
  static String formatAmountWithCurrency(dynamic amount, {String currency = defaultCurrency}) {
    if (amount == null) return '$currency 0.00';
    
    final double value = _parseToDouble(amount);
    return '$currency ${_numberFormatter.format(value)}';
  }

  /// Formats a monetary amount as a whole number (no decimal places)
  /// 
  /// Example: 10000.50 -> "10,001" (rounded)
  static String formatWholeAmount(dynamic amount) {
    if (amount == null) return '0';
    
    final double value = _parseToDouble(amount);
    return _wholeNumberFormatter.format(value.round());
  }

  /// Formats a monetary amount with currency prefix as whole number
  /// 
  /// Example: 10000.50 -> "GHS 10,001"
  static String formatWholeAmountWithCurrency(dynamic amount, {String currency = defaultCurrency}) {
    if (amount == null) return '$currency 0';
    
    final double value = _parseToDouble(amount);
    return '$currency ${_wholeNumberFormatter.format(value.round())}';
  }

  /// Formats percentage values with proper decimal places
  /// 
  /// Example: 12.5 -> "12.50%"
  static String formatPercentage(dynamic percentage) {
    if (percentage == null) return '0.00%';
    
    final double value = _parseToDouble(percentage);
    return '${_numberFormatter.format(value)}%';
  }

  /// Formats a monetary amount with hyphen for zero/null values
  /// Used for displaying unavailable or zero amounts
  /// 
  /// Example: null -> "-", 0 -> "-", 1000 -> "1,000.00"
  static String formatAmountOrHyphen(dynamic amount) {
    if (amount == null) return '-';
    
    final double value = _parseToDouble(amount);
    if (value == 0) return '-';
    
    return _numberFormatter.format(value);
  }

  /// Formats a monetary amount with currency prefix and hyphen for zero/null values
  /// 
  /// Example: null -> "-", 0 -> "-", 1000 -> "GHS 1,000.00"
  static String formatAmountWithCurrencyOrHyphen(dynamic amount, {String currency = defaultCurrency}) {
    if (amount == null) return '-';
    
    final double value = _parseToDouble(amount);
    if (value == 0) return '-';
    
    return '$currency ${_numberFormatter.format(value)}';
  }

  /// Formats investment gains/losses with proper sign and color indication
  /// 
  /// Returns a map with 'text' and 'isPositive' keys for UI styling
  static Map<String, dynamic> formatGainLoss(dynamic amount) {
    if (amount == null) {
      return {'text': '0.00', 'isPositive': true};
    }
    
    final double value = _parseToDouble(amount);
    final bool isPositive = value >= 0;
    final String sign = isPositive ? '+' : '';
    
    return {
      'text': '$sign${_numberFormatter.format(value)}',
      'isPositive': isPositive,
    };
  }

  /// Formats investment gains/losses with currency and proper sign
  /// 
  /// Returns a map with 'text' and 'isPositive' keys for UI styling
  static Map<String, dynamic> formatGainLossWithCurrency(dynamic amount, {String currency = defaultCurrency}) {
    if (amount == null) {
      return {'text': '$currency 0.00', 'isPositive': true};
    }
    
    final double value = _parseToDouble(amount);
    final bool isPositive = value >= 0;
    final String sign = isPositive ? '+' : '';
    
    return {
      'text': '$currency $sign${_numberFormatter.format(value)}',
      'isPositive': isPositive,
    };
  }

  /// Helper method to safely parse various types to double
  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    
    // Try to convert to string first, then parse
    return double.tryParse(value.toString()) ?? 0.0;
  }

  /// Formats compact amounts for large numbers (K, M, B notation)
  /// 
  /// Example: 1500000 -> "1.5M"
  static String formatCompactAmount(dynamic amount, {String currency = defaultCurrency}) {
    if (amount == null) return '$currency 0';
    
    final double value = _parseToDouble(amount);
    
    if (value >= 1000000000) {
      return '$currency ${(value / 1000000000).toStringAsFixed(1)}B';
    } else if (value >= 1000000) {
      return '$currency ${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '$currency ${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return '$currency ${_numberFormatter.format(value)}';
    }
  }
}
