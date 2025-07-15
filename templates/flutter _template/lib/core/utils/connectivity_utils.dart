import 'package:flutter/material.dart';

/// Utility class for checking internet connectivity
class ConnectivityUtils {
  /// Checks if the device has an internet connection
  /// Returns true if connected, false otherwise
  /// Shows a snackbar if there's no connection
  static Future<bool> checkInternetConnection(BuildContext context) async {
    // In a real app, you would use a package like connectivity_plus
    // to check for actual internet connectivity

    // For this demo, we'll always return true (connected)
    // In production, replace this with actual connectivity check
    return true;
  }

  /// Show no connection message
  static void showNoConnectionMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'No internet connection. Please check your network settings.',
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }
}
