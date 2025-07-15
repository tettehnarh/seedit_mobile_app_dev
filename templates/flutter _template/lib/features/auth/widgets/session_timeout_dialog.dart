import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_theme.dart';
import '../../../shared/widgets/custom_button.dart';
import '../providers/session_provider.dart';
import '../providers/auth_provider.dart';

/// Dialog to warn user about session timeout and allow extension
class SessionTimeoutDialog extends ConsumerStatefulWidget {
  final int timeUntilExpirySeconds;
  final VoidCallback? onSessionExpired;
  final VoidCallback? onSessionExtended;

  const SessionTimeoutDialog({
    super.key,
    required this.timeUntilExpirySeconds,
    this.onSessionExpired,
    this.onSessionExtended,
  });

  @override
  ConsumerState<SessionTimeoutDialog> createState() =>
      _SessionTimeoutDialogState();
}

class _SessionTimeoutDialogState extends ConsumerState<SessionTimeoutDialog> {
  late Timer _countdownTimer;
  late int _remainingSeconds;
  bool _isExtending = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.timeUntilExpirySeconds;
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _remainingSeconds--;
        });

        if (_remainingSeconds <= 0) {
          timer.cancel();
          _handleSessionExpired();
        }
      } else {
        timer.cancel();
      }
    });
  }

  void _handleSessionExpired() {
    if (mounted) {
      Navigator.of(context).pop();
      widget.onSessionExpired?.call();

      // Force logout
      ref.read(authProvider.notifier).signOut();

      // Navigate to login screen
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/sign-in',
        (route) => false,
        arguments: {
          'message': 'Your session has expired. Please sign in again.',
          'autoLogout': true,
        },
      );
    }
  }

  Future<void> _extendSession() async {
    setState(() {
      _isExtending = true;
    });

    try {
      final sessionNotifier = ref.read(sessionProvider.notifier);
      final success = await sessionNotifier.extendSession();

      if (success && mounted) {
        Navigator.of(context).pop();
        widget.onSessionExtended?.call();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session extended successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to extend session'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error extending session'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExtending = false;
        });
      }
    }
  }

  void _signOut() {
    Navigator.of(context).pop();
    ref.read(authProvider.notifier).signOut();

    Navigator.of(context).pushNamedAndRemoveUntil('/sign-in', (route) => false);
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent dismissing by back button
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.access_time, color: Colors.orange[700], size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Session Timeout Warning',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your session will expire in:',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),

            // Countdown display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timer, color: Colors.orange[700], size: 24),
                  const SizedBox(width: 8),
                  Text(
                    _formatTime(_remainingSeconds),
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Would you like to extend your session or sign out?',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        actions: [
          // Sign Out button
          TextButton(
            onPressed: _isExtending ? null : _signOut,
            child: Text(
              'Sign Out',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),

          // Extend Session button
          SizedBox(
            width: 120,
            child: CustomButton(
              text: 'Extend Session',
              onPressed: _isExtending ? null : _extendSession,
              isLoading: _isExtending,
              backgroundColor: AppTheme.primaryColor,
              textColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Service to show session timeout dialog
class SessionTimeoutDialogService {
  static bool _isDialogShowing = false;

  /// Show session timeout warning dialog
  static void showTimeoutWarning(
    BuildContext context,
    int timeUntilExpirySeconds, {
    VoidCallback? onSessionExpired,
    VoidCallback? onSessionExtended,
  }) {
    if (_isDialogShowing) return;

    _isDialogShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SessionTimeoutDialog(
        timeUntilExpirySeconds: timeUntilExpirySeconds,
        onSessionExpired: () {
          _isDialogShowing = false;
          onSessionExpired?.call();
        },
        onSessionExtended: () {
          _isDialogShowing = false;
          onSessionExtended?.call();
        },
      ),
    ).then((_) {
      _isDialogShowing = false;
    });
  }

  /// Check if dialog is currently showing
  static bool get isDialogShowing => _isDialogShowing;
}
