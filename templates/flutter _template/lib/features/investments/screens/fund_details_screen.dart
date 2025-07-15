import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../models/investment_models.dart';
import '../widgets/terms_conditions_modal.dart';
import '../providers/fund_subscription_provider.dart';
import '../widgets/fund_performance_chart.dart';
import '../widgets/fund_info_card.dart';

class FundDetailsScreen extends ConsumerStatefulWidget {
  final Fund fund;

  const FundDetailsScreen({super.key, required this.fund});

  @override
  ConsumerState<FundDetailsScreen> createState() => _FundDetailsScreenState();
}

class _FundDetailsScreenState extends ConsumerState<FundDetailsScreen> {
  bool _showInvestmentSelector = false;

  @override
  void initState() {
    super.initState();
    // Load subscription status when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSubscriptionStatus();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh subscription status when returning to screen (e.g., after investment)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshSubscriptionStatus();
    });
  }

  /// Load subscription status on screen load
  void _loadSubscriptionStatus() {
    ref
        .read(fundSubscriptionProvider.notifier)
        .getFundSubscription(widget.fund.id);
  }

  /// Refresh subscription status when returning to screen
  void _refreshSubscriptionStatus() {
    ref
        .read(fundSubscriptionProvider.notifier)
        .refreshSubscriptionAfterInvestment(widget.fund.id);

    // Also invalidate the fund investment status provider to force refresh
    ref.invalidate(fundInvestmentStatusProvider(widget.fund.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // App Bar with Fund Header
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: AppTheme.primaryColor,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.white),
                    onPressed: () => _shareFund(context),
                  ),
                ],

                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.secondaryColor,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              widget.fund.name,
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.fund.category.toUpperCase(),
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                _buildHeaderMetric(
                                  'Return Rate',
                                  CurrencyFormatter.formatPercentage(
                                    widget.fund.returnRate,
                                  ),
                                ),
                                const SizedBox(width: 24),
                                _buildHeaderMetric(
                                  'Risk Level',
                                  widget.fund.riskLevel,
                                ),
                                const SizedBox(width: 24),
                                _buildHeaderMetric(
                                  'Min. Investment',
                                  CurrencyFormatter.formatAmountWithCurrency(
                                    widget.fund.minimumInvestment,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Add spacing after SliverAppBar
                      const SizedBox(height: 50),

                      // Performance Chart
                      FundPerformanceChart(fund: widget.fund),
                      const SizedBox(height: 20),

                      // Fund Information
                      FundInfoCard(fund: widget.fund),
                      const SizedBox(height: 20),

                      // Investment Amount Selector (Temporarily Disabled)
                      if (_showInvestmentSelector) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.2,
                              ),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Investment Feature',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Investment functionality will be available soon!',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 14,
                                  color: AppTheme.companyInfoColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _showInvestmentSelector = false;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Description
                      _buildDescriptionCard(),
                      const SizedBox(height: 20),

                      // Key Features
                      _buildKeyFeaturesCard(),
                      const SizedBox(height: 20),

                      // Risk Disclosure
                      _buildRiskDisclosureCard(),
                      const SizedBox(height: 150), // Space for floating button
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Floating Action Buttons for Active Investments
          Consumer(
            builder: (context, ref, child) {
              final investmentStatusAsync = ref.watch(
                fundInvestmentStatusProvider(widget.fund.id),
              );

              return investmentStatusAsync.when(
                data: (investmentStatus) {
                  if (investmentStatus?.hasActiveInvestment == true) {
                    return Positioned(
                      top: 280, // Position below the SliverAppBar
                      left: 16,
                      right: 16,
                      child: Container(
                        height: 72,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (investmentStatus!.canTopUp)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/wallet/top-up',
                                        arguments: {
                                          'fund': widget.fund,
                                          'isTopUp': true,
                                        },
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromRGBO(
                                        239,
                                        123,
                                        23,
                                        1,
                                      ),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    icon: const Icon(Icons.add, size: 18),
                                    label: const Text(
                                      'Top Up',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              if (investmentStatus.canWithdraw)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/wallet/withdraw',
                                        arguments: {
                                          'fund': widget.fund,
                                          'isWithdrawal': true,
                                        },
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: AppTheme.primaryColor,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 16,
                                      ),
                                      side: BorderSide(
                                        color: AppTheme.primaryColor,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    icon: const Icon(Icons.remove, size: 18),
                                    label: const Text(
                                      'Withdraw',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
                loading: () => const SizedBox.shrink(),
                error: (error, stack) => const SizedBox.shrink(),
              );
            },
          ),
        ],
      ),
      floatingActionButton: _showInvestmentSelector
          ? null
          : Consumer(
              builder: (context, ref, child) {
                // Check fund investment status using new API
                final investmentStatusAsync = ref.watch(
                  fundInvestmentStatusProvider(widget.fund.id),
                );

                return investmentStatusAsync.when(
                  data: (investmentStatus) {
                    if (investmentStatus == null) {
                      // Fallback to old subscription logic if new API fails
                      final subscription = ref.watch(
                        fundSubscriptionDetailsProvider(widget.fund.id),
                      );
                      final isLoading = ref.watch(
                        fundSubscriptionLoadingProvider,
                      );

                      final isSubscribed = subscription?.isSubscribed ?? false;
                      final buttonText = isSubscribed ? 'Top Up' : 'Invest Now';
                      final buttonIcon = isSubscribed
                          ? Icons.add
                          : Icons.add_circle_outline;

                      return FloatingActionButton.extended(
                        heroTag: "fallback_${widget.fund.id}",
                        onPressed: isLoading
                            ? null
                            : () {
                                if (isSubscribed) {
                                  Navigator.pushNamed(
                                    context,
                                    '/investment/amount',
                                    arguments: {
                                      'fund': widget.fund,
                                      'isTopUp': true,
                                    },
                                  );
                                } else {
                                  _showTermsAndConditions();
                                }
                              },
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        icon: Icon(buttonIcon),
                        label: Text(
                          buttonText,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }

                    // Use new investment status for enhanced UI
                    if (investmentStatus.hasActiveInvestment) {
                      // Active investment actions are now shown at the top of the screen
                      // Return null to hide floating action button for active investors
                      return const SizedBox.shrink();
                    } else {
                      // Show single invest button for new investments
                      return FloatingActionButton.extended(
                        heroTag: "invest_${widget.fund.id}",
                        onPressed: () {
                          if (investmentStatus.termsAccepted) {
                            Navigator.pushNamed(
                              context,
                              '/investment/amount',
                              arguments: {'fund': widget.fund},
                            );
                          } else {
                            _showTermsAndConditions();
                          }
                        },
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text(
                          'Invest Now',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }
                  },
                  loading: () => FloatingActionButton.extended(
                    heroTag: "loading_${widget.fund.id}",
                    onPressed: null,
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    icon: const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    label: const Text(
                      'Loading...',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  error: (error, stack) {
                    // Fallback to old subscription logic on error
                    final subscription = ref.watch(
                      fundSubscriptionDetailsProvider(widget.fund.id),
                    );
                    final isLoading = ref.watch(
                      fundSubscriptionLoadingProvider,
                    );

                    final isSubscribed = subscription?.isSubscribed ?? false;
                    final buttonText = isSubscribed ? 'Top Up' : 'Invest Now';
                    final buttonIcon = isSubscribed
                        ? Icons.add
                        : Icons.add_circle_outline;

                    return FloatingActionButton.extended(
                      heroTag: "error_${widget.fund.id}",
                      onPressed: isLoading
                          ? null
                          : () {
                              if (isSubscribed) {
                                Navigator.pushNamed(
                                  context,
                                  '/wallet/top-up',
                                  arguments: {
                                    'fund': widget.fund,
                                    'isTopUp': true,
                                  },
                                );
                              } else {
                                _showTermsAndConditions();
                              }
                            },
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      icon: Icon(buttonIcon),
                      label: Text(
                        buttonText,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildHeaderMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About This Fund',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.fund.description,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyFeaturesCard() {
    final features = [
      'Professional fund management',
      'Diversified portfolio',
      'Regular performance monitoring',
      'Transparent fee structure',
      'Easy liquidity options',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Key Features',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskDisclosureCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber,
                color: Colors.orange.shade700,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Risk Disclosure',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'All investments carry risk and may lose value. Past performance does not guarantee future results. Please read the fund prospectus carefully before investing.',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              color: Colors.orange.shade600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _showTermsAndConditions() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          return TermsConditionsModal(
            fund: widget.fund,
            onAccept: () async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              // Accept terms in backend
              final success = await ref
                  .read(fundSubscriptionProvider.notifier)
                  .acceptTerms(widget.fund.id);

              if (mounted) {
                if (success) {
                  navigator.pushNamed(
                    '/investment/amount',
                    arguments: {'fund': widget.fund},
                  );
                } else {
                  // Show error message
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Failed to accept terms. Please try again.',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          );
        },
      ),
    );
  }

  void _shareFund(BuildContext context) {
    // Generate fund information text
    final fundInfo = _generateFundInfoText();

    // Copy to clipboard as a simple share alternative
    Clipboard.setData(ClipboardData(text: fundInfo));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fund information copied to clipboard'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _generateFundInfoText() {
    final buffer = StringBuffer();
    buffer.writeln('INVESTMENT FUND INFORMATION');
    buffer.writeln('==========================');
    buffer.writeln();
    buffer.writeln('Fund Name: ${widget.fund.name}');
    buffer.writeln('Category: ${widget.fund.category}');
    buffer.writeln('Risk Level: ${widget.fund.riskLevel}');
    buffer.writeln();
    buffer.writeln('PERFORMANCE');
    buffer.writeln('-----------');
    buffer.writeln(
      'Current Price: GHS ${CurrencyFormatter.formatAmount(widget.fund.currentPrice)}',
    );
    buffer.writeln(
      'Return Rate: ${widget.fund.returnRate.toStringAsFixed(2)}%',
    );
    buffer.writeln();
    buffer.writeln('FUND DETAILS');
    buffer.writeln('------------');
    buffer.writeln(
      'Minimum Investment: GHS ${CurrencyFormatter.formatAmount(widget.fund.minimumInvestment)}',
    );
    buffer.writeln(
      'Management Fee: ${widget.fund.managementFee.toStringAsFixed(2)}%',
    );
    buffer.writeln(
      'Total Assets: GHS ${CurrencyFormatter.formatAmount(widget.fund.totalAssets)}',
    );
    buffer.writeln(
      'Inception Date: ${widget.fund.inceptionDate.toString().split(' ')[0]}',
    );
    buffer.writeln();
    buffer.writeln('DESCRIPTION');
    buffer.writeln('-----------');
    buffer.writeln(widget.fund.description);
    buffer.writeln();
    buffer.writeln('Shared from Seedit Mobile App');

    return buffer.toString();
  }
}
