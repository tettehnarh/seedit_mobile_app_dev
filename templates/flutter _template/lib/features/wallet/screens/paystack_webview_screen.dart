import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import 'dart:developer' as developer;
import '../../../core/utils/app_theme.dart';
import '../services/paystack_service.dart';
import '../../investments/providers/investment_provider.dart';
import '../../groups/services/groups_service.dart';
import '../../../core/api/api_client.dart';

class PaystackWebViewScreen extends ConsumerStatefulWidget {
  final String authorizationUrl;
  final String reference;
  final String transactionId;
  final Function(Map<String, dynamic>) onPaymentComplete;
  final VoidCallback? onPaymentCancelled;
  final String? paymentType; // 'investment' or 'group_contribution'

  const PaystackWebViewScreen({
    super.key,
    required this.authorizationUrl,
    required this.reference,
    required this.transactionId,
    required this.onPaymentComplete,
    this.onPaymentCancelled,
    this.paymentType =
        'investment', // Default to investment for backward compatibility
  });

  @override
  ConsumerState<PaystackWebViewScreen> createState() =>
      _PaystackWebViewScreenState();
}

class _PaystackWebViewScreenState extends ConsumerState<PaystackWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  Timer? _paymentTimeoutTimer;
  Timer? _statusPollingTimer;
  String? _errorMessage;
  final PaystackService _paystackService = PaystackService();
  late final GroupsService _groupsService;
  bool _isPolling = false;
  bool _isProcessingPayment = false;
  bool _isProcessingSuccess = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _groupsService = GroupsService(ApiClient());
    _initializeWebView();
    _startPaymentTimeout();
    _startStatusPolling();
  }

  Future<Map<String, dynamic>> _verifyPaymentByType(String reference) async {
    if (widget.paymentType == 'group_contribution') {
      return await _groupsService.verifyGroupContributionPayment(reference);
    } else {
      return await _paystackService.verifyPayment(reference);
    }
  }

  void _startPaymentTimeout() {
    // Auto-verify payment after 5 minutes if no callback is detected
    _paymentTimeoutTimer = Timer(const Duration(minutes: 5), () {
      developer.log(
        '⏰ [PAYSTACK_WEBVIEW] Payment timeout reached, attempting verification',
      );
      _handlePaymentCallback('timeout://auto-verify');
    });
  }

  void _startStatusPolling() {
    // Start polling for payment status every 10 seconds after 30 seconds
    Timer(const Duration(seconds: 30), () {
      if (!_isPolling && mounted) {
        _isPolling = true;
        developer.log('🔄 [PAYSTACK_WEBVIEW] Starting status polling');

        _statusPollingTimer = Timer.periodic(const Duration(seconds: 10), (
          timer,
        ) async {
          if (!mounted) {
            timer.cancel();
            return;
          }

          try {
            developer.log(
              '🔍 [PAYSTACK_WEBVIEW] Polling payment status for ${widget.reference}',
            );
            final result = await _verifyPaymentByType(widget.reference);

            developer.log('🔍 [PAYSTACK_WEBVIEW] Polling result: $result');
            developer.log(
              '🔍 [PAYSTACK_WEBVIEW] Polling success: ${result['success']}',
            );
            developer.log(
              '🔍 [PAYSTACK_WEBVIEW] Polling data: ${result['data']}',
            );
            developer.log(
              '🔍 [PAYSTACK_WEBVIEW] Polling error: ${result['error']}',
            );

            if (result['success'] == true) {
              // Prevent double processing
              if (_isProcessingPayment) {
                developer.log(
                  '⚠️ [PAYSTACK_WEBVIEW] Payment already being processed, stopping polling',
                );
                timer.cancel();
                return;
              }

              _isProcessingPayment = true;
              developer.log(
                '✅ [PAYSTACK_WEBVIEW] Payment verified via polling! Closing WebView...',
              );
              timer.cancel();
              _statusPollingTimer = null;

              // Trigger global investment refresh before calling completion callback
              try {
                await ref.read(globalInvestmentRefreshProvider)();
                developer.log(
                  '✅ [PAYSTACK_WEBVIEW] Investment data refreshed after payment',
                );
              } catch (e) {
                developer.log(
                  '⚠️ [PAYSTACK_WEBVIEW] Error refreshing investment data: $e',
                );
              }

              // Call the completion callback directly
              widget.onPaymentComplete(result['data'] ?? {});

              // Close the WebView
              if (mounted) {
                Navigator.of(context).pop();
              }
            } else {
              developer.log(
                '⏳ [PAYSTACK_WEBVIEW] Payment not yet verified, continuing to poll...',
              );
            }
          } catch (e) {
            developer.log('❌ [PAYSTACK_WEBVIEW] Polling error: $e');
          }
        });
      }
    });
  }

  @override
  void dispose() {
    developer.log(
      '🔄 [PAYSTACK_WEBVIEW_DEBUG] Disposing PaystackWebViewScreen...',
    );

    // Set disposed flag first
    _isDisposed = true;

    // Cancel all timers
    _paymentTimeoutTimer?.cancel();
    _statusPollingTimer?.cancel();

    // Set flags to prevent further processing
    _isProcessingPayment = true; // Prevent new payment processing
    _isProcessingSuccess = true; // Prevent success processing

    developer.log('✅ [PAYSTACK_WEBVIEW_DEBUG] PaystackWebViewScreen disposed');
    super.dispose();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            developer.log('🔄 [PAYSTACK_WEBVIEW] Loading progress: $progress%');
          },
          onPageStarted: (String url) {
            developer.log('🔄 [PAYSTACK_WEBVIEW] Page started loading: $url');
            if (mounted && !_isProcessingPayment) {
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
            }
          },
          onPageFinished: (String url) {
            developer.log('✅ [PAYSTACK_WEBVIEW] Page finished loading: $url');
            if (mounted && !_isProcessingPayment) {
              setState(() {
                _isLoading = false;
              });
            }
            _handleUrlChange(url);
          },
          onWebResourceError: (WebResourceError error) {
            developer.log(
              '❌ [PAYSTACK_WEBVIEW] Web resource error: ${error.description}',
            );
            if (mounted && !_isProcessingPayment) {
              setState(() {
                _isLoading = false;
                _hasError = true;
                _errorMessage = error.description;
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            developer.log(
              '🔄 [PAYSTACK_WEBVIEW] Navigation request: ${request.url}',
            );
            _handleUrlChange(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.authorizationUrl));
  }

  void _handleUrlChange(String url) {
    developer.log('🔍 [PAYSTACK_WEBVIEW] Handling URL change: $url');

    // Don't process URL changes if disposed
    if (_isDisposed) {
      developer.log(
        '⚠️ [PAYSTACK_WEBVIEW_DEBUG] Widget disposed, ignoring URL change',
      );
      return;
    }

    // Show processing overlay immediately when we detect ngrok or success URLs
    if (url.contains('ngrok') ||
        url.contains('/payment/success') ||
        url.startsWith('seedit://') ||
        url.contains('callback')) {
      if (!_isProcessingSuccess && mounted && !_isDisposed) {
        setState(() {
          _isProcessingSuccess = true;
        });
        developer.log(
          '🔄 [PAYSTACK_WEBVIEW] Showing processing overlay for URL: $url',
        );
      }
    }

    // Only trigger payment processing on our success page or explicit callback URLs
    if (url.contains('/payment/success') ||
        url.startsWith('seedit://') ||
        url.contains('callback')) {
      developer.log(
        '🔍 [PAYSTACK_WEBVIEW] Payment callback detected for URL: $url',
      );

      // Process payment callback
      _handlePaymentCallback(url);
    }
  }

  Future<void> _handlePaymentCallback(String callbackUrl) async {
    developer.log(
      '🔍 [PAYSTACK_WEBVIEW_DEBUG] ===== HANDLING PAYMENT CALLBACK =====',
    );
    developer.log('🔍 [PAYSTACK_WEBVIEW_DEBUG] Callback URL: $callbackUrl');
    developer.log('🔍 [PAYSTACK_WEBVIEW_DEBUG] Reference: ${widget.reference}');
    developer.log(
      '🔍 [PAYSTACK_WEBVIEW_DEBUG] Payment type: ${widget.paymentType}',
    );
    developer.log(
      '🔍 [PAYSTACK_WEBVIEW_DEBUG] Is processing: $_isProcessingPayment',
    );
    developer.log('🔍 [PAYSTACK_WEBVIEW_DEBUG] Is mounted: $mounted');
    developer.log('🔍 [PAYSTACK_WEBVIEW_DEBUG] Is disposed: $_isDisposed');

    // Prevent processing if disposed or already processing
    if (_isDisposed || _isProcessingPayment) {
      developer.log(
        '⚠️ [PAYSTACK_WEBVIEW_DEBUG] Widget disposed or payment already being processed, ignoring callback',
      );
      return;
    }

    _isProcessingPayment = true;
    developer.log(
      '🔄 [PAYSTACK_WEBVIEW_DEBUG] Setting processing flag to true',
    );
    developer.log(
      '🔄 [PAYSTACK_WEBVIEW] Processing payment callback: $callbackUrl',
    );

    // Cancel timers since we're processing a callback
    developer.log('🔄 [PAYSTACK_WEBVIEW_DEBUG] Cancelling timers...');
    _paymentTimeoutTimer?.cancel();
    _statusPollingTimer?.cancel();

    try {
      // Show loading indicator
      developer.log('🔄 [PAYSTACK_WEBVIEW_DEBUG] Setting loading state...');
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      } else {
        developer.log(
          '⚠️ [PAYSTACK_WEBVIEW_DEBUG] Widget not mounted, skipping setState',
        );
      }

      // Verify payment with backend
      developer.log(
        '🔄 [PAYSTACK_WEBVIEW_DEBUG] Starting payment verification...',
      );
      final verificationResult = await _verifyPaymentByType(widget.reference);
      developer.log('🔍 [PAYSTACK_WEBVIEW_DEBUG] Verification completed');

      developer.log(
        '🔍 [PAYSTACK_WEBVIEW] Verification result: $verificationResult',
      );
      developer.log(
        '🔍 [PAYSTACK_WEBVIEW] Verification success status: ${verificationResult['success']}',
      );
      developer.log(
        '🔍 [PAYSTACK_WEBVIEW] Verification data: ${verificationResult['data']}',
      );
      developer.log(
        '🔍 [PAYSTACK_WEBVIEW] Verification error: ${verificationResult['error']}',
      );

      if (verificationResult['success'] == true) {
        developer.log(
          '✅ [PAYSTACK_WEBVIEW] Payment verified successfully - calling callback and closing',
        );

        // Trigger global investment refresh before calling completion callback
        developer.log(
          '🔄 [PAYSTACK_WEBVIEW_DEBUG] Triggering global investment refresh...',
        );
        try {
          await ref.read(globalInvestmentRefreshProvider)();
          developer.log(
            '✅ [PAYSTACK_WEBVIEW_DEBUG] Investment data refreshed after payment verification',
          );
        } catch (e) {
          developer.log(
            '❌ [PAYSTACK_WEBVIEW_DEBUG] Error refreshing investment data: $e',
          );
          // Continue with callback even if refresh fails
        }

        // Call the completion callback with error handling
        developer.log(
          '🔄 [PAYSTACK_WEBVIEW_DEBUG] Calling payment completion callback...',
        );
        developer.log(
          '🔍 [PAYSTACK_WEBVIEW_DEBUG] Callback data: ${verificationResult['data']}',
        );
        try {
          widget.onPaymentComplete(verificationResult['data'] ?? {});
          developer.log(
            '✅ [PAYSTACK_WEBVIEW_DEBUG] Payment completion callback executed successfully',
          );
        } catch (e) {
          developer.log(
            '❌ [PAYSTACK_WEBVIEW_DEBUG] Error in payment callback: $e',
          );
          developer.log(
            '❌ [PAYSTACK_WEBVIEW_DEBUG] Error type: ${e.runtimeType}',
          );
          developer.log(
            '❌ [PAYSTACK_WEBVIEW_DEBUG] Stack trace: ${StackTrace.current}',
          );
        }

        // Close the WebView
        developer.log(
          '🔄 [PAYSTACK_WEBVIEW_DEBUG] Attempting to close WebView...',
        );
        if (mounted) {
          developer.log(
            '🚪 [PAYSTACK_WEBVIEW_DEBUG] Widget is mounted, closing WebView...',
          );
          try {
            Navigator.of(context).pop();
            developer.log(
              '✅ [PAYSTACK_WEBVIEW_DEBUG] WebView closed successfully',
            );
          } catch (e) {
            developer.log(
              '❌ [PAYSTACK_WEBVIEW_DEBUG] Error closing WebView: $e',
            );
          }
        } else {
          developer.log(
            '⚠️ [PAYSTACK_WEBVIEW_DEBUG] Widget not mounted, cannot close WebView',
          );
        }
      } else {
        developer.log(
          '❌ [PAYSTACK_WEBVIEW] Payment verification failed: ${verificationResult['error']}',
        );

        // Check if payment was already processed (common race condition)
        if (verificationResult['error']?.toString().contains(
              'already verified',
            ) ==
            true) {
          developer.log(
            'ℹ️ [PAYSTACK_WEBVIEW] Payment already processed, treating as success',
          );

          // Trigger global investment refresh for already processed payments too
          try {
            await ref.read(globalInvestmentRefreshProvider)();
            developer.log(
              '✅ [PAYSTACK_WEBVIEW] Investment data refreshed for already-processed payment',
            );
          } catch (e) {
            developer.log(
              '⚠️ [PAYSTACK_WEBVIEW] Error refreshing investment data: $e',
            );
          }

          // Call the completion callback anyway since payment was successful
          try {
            widget.onPaymentComplete({});
          } catch (e) {
            developer.log('❌ [PAYSTACK_WEBVIEW] Error in payment callback: $e');
          }

          // Close the WebView
          if (mounted) {
            developer.log(
              '🚪 [PAYSTACK_WEBVIEW] Closing WebView after already-verified payment...',
            );
            Navigator.of(context).pop();
          }
        } else {
          _showErrorDialog(
            'Payment verification failed: ${verificationResult['error']}',
          );
        }
      }
    } catch (e) {
      developer.log(
        '❌ [PAYSTACK_WEBVIEW] Error processing payment callback: $e',
      );
      _showErrorDialog(
        'An error occurred while processing your payment. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Payment Error',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close WebView
              widget.onPaymentCancelled?.call();
            },
            child: const Text(
              'OK',
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleBackButton() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Cancel Payment?',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        content: const Text(
          'Are you sure you want to cancel this payment? Your transaction will not be processed.',
          style: TextStyle(fontFamily: 'Montserrat', fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Continue Payment',
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close WebView
              widget.onPaymentCancelled?.call();
            },
            child: const Text(
              'Cancel Payment',
              style: TextStyle(fontFamily: 'Montserrat', color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: const Text(
          'Complete Payment',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _handleBackButton,
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          if (_hasError)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to Load Payment Page',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage ??
                        'An error occurred while loading the payment page.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (mounted) {
                        setState(() {
                          _hasError = false;
                          _isLoading = true;
                        });
                      }
                      _controller.loadRequest(
                        Uri.parse(widget.authorizationUrl),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            WebViewWidget(controller: _controller),

          // Loading overlay
          if (_isLoading && !_hasError)
            Container(
              color: Colors.white.withValues(alpha: 0.8),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppTheme.primaryColor),
                    SizedBox(height: 16),
                    Text(
                      'Loading payment page...',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Success processing overlay - completely covers the WebView
          if (_isProcessingSuccess)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Success icon animation
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.green[500],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Processing payment...',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please wait while we confirm your transaction',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
