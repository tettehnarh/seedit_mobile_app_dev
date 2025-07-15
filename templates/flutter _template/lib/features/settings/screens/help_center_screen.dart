import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_theme.dart';
import '../services/settings_service.dart';

class HelpCenterScreen extends ConsumerStatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  ConsumerState<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends ConsumerState<HelpCenterScreen> {
  List<Map<String, dynamic>> _faqs = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadFAQs();
  }

  Future<void> _loadFAQs() async {
    try {
      final settingsService = SettingsService();
      final faqs = await settingsService.getFAQs();

      setState(() {
        _faqs = faqs;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        // Provide fallback FAQs if API fails
        _faqs = _getFallbackFAQs();
      });
    }
  }

  List<Map<String, dynamic>> _getFallbackFAQs() {
    return [
      {
        'question': 'How do I start investing?',
        'answer':
            'To start investing, you need to complete your KYC verification first. Once approved, you can browse available funds and make your first investment.',
        'category': 'Getting Started',
      },
      {
        'question': 'What is KYC verification?',
        'answer':
            'KYC (Know Your Customer) is a verification process required by law. You\'ll need to provide personal information and identity documents to verify your account.',
        'category': 'Account',
      },
      {
        'question': 'How do I add money to my wallet?',
        'answer':
            'You can add money to your wallet through bank transfer, mobile money, or card payment. Go to Wallet > Top Up to see available options.',
        'category': 'Payments',
      },
      {
        'question': 'Can I withdraw my investments anytime?',
        'answer':
            'Most funds allow withdrawals, but some may have minimum holding periods or fees. Check the fund details for specific terms.',
        'category': 'Investments',
      },
      {
        'question': 'How are investment returns calculated?',
        'answer':
            'Returns are calculated based on the fund\'s Net Asset Value (NAV) performance. You can view detailed performance history in each fund\'s details.',
        'category': 'Investments',
      },
      {
        'question': 'What are investment groups?',
        'answer':
            'Investment groups allow you to pool money with other investors to access funds with higher minimum investments or to invest collectively.',
        'category': 'Groups',
      },
      {
        'question': 'How do I reset my password?',
        'answer':
            'Use the "Forgot Password" option on the login screen. You\'ll receive an OTP via email to reset your password.',
        'category': 'Account',
      },
      {
        'question': 'Is my money safe?',
        'answer':
            'Yes, we use bank-level security and all funds are managed by licensed fund managers. Your investments are also protected by regulatory frameworks.',
        'category': 'Security',
      },
    ];
  }

  List<Map<String, dynamic>> get _filteredFAQs {
    if (_searchQuery.isEmpty) {
      return _faqs;
    }

    return _faqs.where((faq) {
      final question = faq['question']?.toString().toLowerCase() ?? '';
      final answer = faq['answer']?.toString().toLowerCase() ?? '';
      final category = faq['category']?.toString().toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();

      return question.contains(query) ||
          answer.contains(query) ||
          category.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Help Center',
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
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search for help...',
                hintStyle: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: AppTheme.companyInfoColor,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppTheme.companyInfoColor,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primaryColor),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ),

          // FAQ List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredFAQs.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredFAQs.length,
                    itemBuilder: (context, index) {
                      final faq = _filteredFAQs[index];
                      return _buildFAQCard(faq);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "help_center_contact_support",
        onPressed: () {
          Navigator.pushNamed(context, '/contact-support');
        },
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.support_agent, color: Colors.white),
        label: const Text(
          'Contact Support',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with different keywords',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQCard(Map<String, dynamic> faq) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ExpansionTile(
        title: Text(
          faq['question'] ?? '',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
            fontFamily: 'Montserrat',
          ),
        ),
        subtitle: faq['category'] != null
            ? Container(
                margin: const EdgeInsets.only(top: 4),
                child: Text(
                  faq['category'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontFamily: 'Montserrat',
                  ),
                ),
              )
            : null,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              faq['answer'] ?? '',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.companyInfoColor,
                fontFamily: 'Montserrat',
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
