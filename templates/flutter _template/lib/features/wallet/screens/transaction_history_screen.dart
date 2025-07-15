import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_theme.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../investments/models/investment_models.dart';
import '../../investments/providers/investment_provider.dart';
import 'transaction_detail_screen.dart';

// Import standardized dialogs
import '../../../shared/widgets/dialogs/dialogs.dart';

// Import currency formatter
import '../../../core/utils/currency_formatter.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Investment', 'Top-up', 'Withdrawal'];
  final TextEditingController _searchController = TextEditingController();
  List<TransactionModel> _searchResults = [];
  bool _isSearching = false;
  bool _hasShownSuccessMessage = false;

  @override
  void initState() {
    super.initState();
    // Load transaction data and portfolio overview when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleInitialLoad();
    });
  }

  Future<void> _handleInitialLoad() async {
    // Check if we're coming from a successful payment
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final showSuccessMessage = args?['showSuccessMessage'] == true;
    final paymentData = args?['paymentData'] as Map<String, dynamic>?;

    // Force refresh transaction data and investment data to get the latest information
    await Future.wait([
      ref.read(transactionProvider.notifier).loadAllTransactions(refresh: true),
      ref
          .read(transactionProvider.notifier)
          .loadRecentTransactions(), // Also refresh recent transactions for home screen
      ref.read(investmentProvider.notifier).refreshInvestmentData(),
    ]);

    // Show success message if coming from payment completion
    if (showSuccessMessage &&
        paymentData != null &&
        !_hasShownSuccessMessage &&
        mounted) {
      _hasShownSuccessMessage = true;
      _showPaymentSuccessMessage(paymentData);
    }
  }

  void _showPaymentSuccessMessage(Map<String, dynamic> paymentData) {
    final amount = paymentData['amount'] as double?;
    final fundName = paymentData['fund_name'] as String?;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Payment Successful!',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  if (amount != null && fundName != null)
                    Text(
                      'GHS ${amount.toStringAsFixed(2)} invested in $fundName',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults.clear();
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await ref
          .read(transactionProvider.notifier)
          .searchTransactions(query.trim());

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
        _searchResults.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchResults.clear();
      _isSearching = false;
    });
  }

  void _navigateToTransactionDetail(TransactionModel transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionDetailScreen(
          transactionId: transaction.id,
          transaction: transaction,
        ),
      ),
    );
  }

  void _showSearchDialog() {
    BaseDialog.show(
      context: context,
      dialog: BaseDialog(
        title: 'Search Transactions',
        titleIcon: Icons.search,
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Enter fund name, amount, or transaction ID...',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          autofocus: true,
          style: const TextStyle(fontFamily: 'Montserrat'),
          onSubmitted: (value) {
            Navigator.pop(context);
            _performSearch(value);
          },
        ),
        actions: [
          DialogButton(
            text: 'Cancel',
            type: DialogButtonType.text,
            onPressed: () => Navigator.pop(context),
          ),
          DialogButton(
            text: 'Search',
            type: DialogButtonType.primary,
            icon: Icons.search,
            onPressed: () {
              Navigator.pop(context);
              _performSearch(_searchController.text);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionState = ref.watch(transactionProvider);
    final allTransactions = transactionState.allTransactions;
    final isLoading = transactionState.isLoading || _isSearching;
    final errorMessage = transactionState.errorMessage;

    // Use search results if searching, otherwise use all transactions
    final transactions =
        _searchResults.isNotEmpty || _searchController.text.isNotEmpty
        ? _searchResults
        : allTransactions;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Transaction History',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_searchController.text.isNotEmpty || _searchResults.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: AppTheme.primaryColor),
              onPressed: _clearSearch,
            ),
          IconButton(
            icon: const Icon(Icons.search, color: AppTheme.primaryColor),
            onPressed: _showSearchDialog,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh both transaction data and portfolio overview from backend
          await Future.wait([
            ref
                .read(transactionProvider.notifier)
                .loadAllTransactions(refresh: true),
            ref.read(investmentProvider.notifier).refreshInvestmentData(),
          ]);
        },
        child: CustomScrollView(
          slivers: [
            // Summary card
            SliverToBoxAdapter(child: _buildTransactionSummaryCard()),

            // Filter chips
            SliverToBoxAdapter(
              child: Container(
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final isSelected = filter == _selectedFilter;

                    return Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: FilterChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                        backgroundColor: Colors.white,
                        selectedColor: AppTheme.primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppTheme.companyInfoColor,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : Colors.grey[300]!,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Transactions list
            if (isLoading)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              )
            else if (errorMessage != null)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref
                              .read(transactionProvider.notifier)
                              .loadAllTransactions(refresh: true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (transactions.isEmpty)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No transactions yet',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Your transaction history will appear here',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final transaction = transactions[index];
                  return _buildRealTransactionCard(transaction);
                }, childCount: transactions.length),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "transaction_history_download",
        onPressed: _showDownloadDialog,
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.download, color: Colors.white),
        label: const Text(
          'Download',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionSummaryCard() {
    final portfolioOverview = ref.watch(portfolioOverviewProvider);
    final isLoading = ref.watch(investmentLoadingProvider);

    // Extract data from portfolio overview
    final portfolioSummary = portfolioOverview?['portfolio_summary'];
    final totalInvested = portfolioSummary != null
        ? double.tryParse(
                portfolioSummary['total_invested']?.toString() ?? '0',
              ) ??
              0.0
        : 0.0;

    final totalWithdrawn = portfolioSummary != null
        ? double.tryParse(
                portfolioSummary['total_withdrawn']?.toString() ?? '0',
              ) ??
              0.0
        : 0.0;

    final totalTransactionValue = totalInvested + totalWithdrawn;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Total Transactions',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.companyInfoColor,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isLoading
                ? 'Loading...'
                : CurrencyFormatter.formatAmountWithCurrency(
                    totalTransactionValue,
                  ),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Invested',
                  isLoading
                      ? 'Loading...'
                      : CurrencyFormatter.formatAmountWithCurrency(
                          totalInvested,
                        ),
                  Colors.green,
                  Icons.trending_up,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.grey[300]),
              Expanded(
                child: _buildSummaryItem(
                  'Withdrawn',
                  isLoading
                      ? 'Loading...'
                      : CurrencyFormatter.formatAmountWithCurrency(
                          totalWithdrawn,
                        ),
                  Colors.orange,
                  Icons.trending_down,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String amount,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
            fontFamily: 'Montserrat',
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.companyInfoColor,
            fontFamily: 'Montserrat',
          ),
        ),
      ],
    );
  }

  Widget _buildRealTransactionCard(TransactionModel transaction) {
    final amount = transaction.amount;
    final isPositive =
        transaction.transactionType == 'top_up' ||
        transaction.transactionType == 'dividend';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        onTap: () => _navigateToTransactionDetail(transaction),
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isPositive
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getTransactionIcon(transaction.transactionType),
            color: isPositive ? Colors.green : Colors.red,
            size: 24,
          ),
        ),
        title: Text(
          transaction.fundName.isNotEmpty
              ? transaction.fundName
              : _getTransactionDescription(transaction.transactionType),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
            fontFamily: 'Montserrat',
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              _getTransactionTypeDisplay(transaction.transactionType),
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.companyInfoColor,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _formatDate(transaction.createdAt),
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.companyInfoColor,
                fontFamily: 'Montserrat',
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 2),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStatusColor(
                    transaction.status,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _getStatusDisplay(transaction.status),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(transaction.status),
                    fontFamily: 'Montserrat',
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
        trailing: Text(
          '${isPositive ? '+' : ''}GHS ${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isPositive ? Colors.green : Colors.red,
            fontFamily: 'Montserrat',
          ),
        ),
      ),
    );
  }

  IconData _getTransactionIcon(String type) {
    switch (type.toLowerCase()) {
      case 'investment':
        return Icons.trending_up;
      case 'top_up':
        return Icons.add_circle;
      case 'withdrawal':
        return Icons.remove_circle;
      case 'dividend':
        return Icons.account_balance_wallet;
      default:
        return Icons.swap_horiz;
    }
  }

  String _getTransactionTypeDisplay(String type) {
    switch (type.toLowerCase()) {
      case 'investment':
        return 'Investment';
      case 'top_up':
        return 'Top-up';
      case 'withdrawal':
        return 'Withdrawal';
      case 'dividend':
        return 'Dividend';
      default:
        return type;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
      case 'pending_payment':
        return Colors.orange;
      case 'rejected':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusDisplay(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Completed';
      case 'pending':
        return 'Pending';
      case 'pending_payment':
        return 'Pending Payment';
      case 'rejected':
        return 'Rejected';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String _getTransactionDescription(String type) {
    switch (type.toLowerCase()) {
      case 'investment':
        return 'Investment';
      case 'top_up':
        return 'Wallet Top-up';
      case 'withdrawal':
        return 'Withdrawal';
      case 'dividend':
        return 'Dividend Payment';
      default:
        return 'Transaction';
    }
  }

  String _formatDate(DateTime date) {
    // Use more compact date format to prevent overflow
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString().substring(2)}';
  }

  void _showDownloadDialog() {
    final downloadOptions = [
      SelectionOption<String>(
        value: 'Last 30 Days',
        title: 'Last 30 Days',
        subtitle: 'Recent transactions',
        icon: Icons.calendar_today,
      ),
      SelectionOption<String>(
        value: 'Last 3 Months',
        title: 'Last 3 Months',
        subtitle: 'Quarterly report',
        icon: Icons.calendar_month,
      ),
      SelectionOption<String>(
        value: 'Last 6 Months',
        title: 'Last 6 Months',
        subtitle: 'Half-year report',
        icon: Icons.date_range,
      ),
      SelectionOption<String>(
        value: 'Last Year',
        title: 'Last Year',
        subtitle: 'Annual report',
        icon: Icons.calendar_today,
      ),
      SelectionOption<String>(
        value: 'All Time',
        title: 'All Time',
        subtitle: 'Complete history',
        icon: Icons.history,
      ),
    ];

    SelectionDialog.show<String>(
      context: context,
      title: 'Download Transactions',
      subtitle: 'Select the time period for your transaction history:',
      options: downloadOptions,
      icon: Icons.download,
    ).then((selectedPeriod) {
      if (selectedPeriod != null && mounted) {
        _downloadTransactions(selectedPeriod);
      }
    });
  }

  void _downloadTransactions(String period) async {
    // Show loading dialog
    LoadingDialogManager.show(
      context: context,
      title: 'Preparing Download',
      message: 'Generating transaction report for $period...',
      icon: Icons.download,
    );

    try {
      // Simulate download process - in real app, this would call API
      await Future.delayed(const Duration(seconds: 2));

      // Dismiss loading dialog
      LoadingDialogManager.dismiss();

      if (mounted) {
        await MessageDialog.showInfo(
          context: context,
          title: 'Download Feature Coming Soon',
          message:
              'Transaction download functionality is currently under development.',
          details:
              'We are working hard to bring you this feature. You will be able to download your transaction history for $period soon.',
        );
      }
    } catch (error) {
      // Dismiss loading dialog
      LoadingDialogManager.dismiss();

      if (mounted) {
        await MessageDialog.showError(
          context: context,
          title: 'Download Failed',
          message: 'Unable to download transaction history.',
          details: 'Please check your internet connection and try again.',
        );
      }
    }
  }
}
