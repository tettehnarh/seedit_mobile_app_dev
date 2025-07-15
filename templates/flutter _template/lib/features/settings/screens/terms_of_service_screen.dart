import 'package:flutter/material.dart';
import '../../../core/utils/app_theme.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Terms of Service',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Terms of Service',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Last updated: ${DateTime.now().year}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 24),

              _buildSection(
                'Acceptance of Terms',
                'By accessing and using the SeedIt investment platform, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by the above, please do not use this service.',
              ),

              _buildSection(
                'Description of Service',
                'SeedIt provides an investment platform that allows users to:\n\n• Invest in various mutual funds and investment products\n• Track portfolio performance\n• Participate in group investments\n• Set and track financial goals\n• Access investment education and resources\n\nOur services are subject to regulatory approval and compliance requirements.',
              ),

              _buildSection(
                'User Accounts and KYC',
                'To use our services, you must:\n\n• Create an account with accurate information\n• Complete Know Your Customer (KYC) verification\n• Be at least 18 years old\n• Be a legal resident of Ghana\n• Maintain the security of your account credentials\n• Notify us immediately of any unauthorized access',
              ),

              _buildSection(
                'Investment Risks',
                'All investments carry risk, including the potential loss of principal. You acknowledge that:\n\n• Past performance does not guarantee future results\n• Investment values may fluctuate\n• You may lose some or all of your investment\n• We do not guarantee any specific returns\n• You should only invest what you can afford to lose',
              ),

              _buildSection(
                'Fees and Charges',
                'Our fee structure includes:\n\n• Management fees as disclosed in fund documents\n• Transaction fees for certain operations\n• Third-party payment processing fees\n• Currency conversion fees where applicable\n\nAll fees are clearly disclosed before you complete any transaction.',
              ),

              _buildSection(
                'User Responsibilities',
                'You agree to:\n\n• Provide accurate and complete information\n• Use the platform only for lawful purposes\n• Not attempt to manipulate or disrupt the service\n• Comply with all applicable laws and regulations\n• Report any suspicious activity\n• Keep your contact information updated',
              ),

              _buildSection(
                'Prohibited Activities',
                'You may not:\n\n• Use the platform for money laundering or fraud\n• Share your account with others\n• Attempt to hack or compromise the system\n• Provide false information during KYC\n• Engage in market manipulation\n• Violate any applicable laws or regulations',
              ),

              _buildSection(
                'Limitation of Liability',
                'To the maximum extent permitted by law, SeedIt shall not be liable for any indirect, incidental, special, consequential, or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses.',
              ),

              _buildSection(
                'Termination',
                'We may terminate or suspend your account immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms. Upon termination, your right to use the service will cease immediately.',
              ),

              _buildSection(
                'Governing Law',
                'These Terms shall be interpreted and governed by the laws of Ghana. Any disputes arising from these terms shall be subject to the exclusive jurisdiction of the courts of Ghana.',
              ),

              _buildSection(
                'Changes to Terms',
                'We reserve the right to modify or replace these Terms at any time. If a revision is material, we will try to provide at least 30 days notice prior to any new terms taking effect.',
              ),

              _buildSection(
                'Contact Information',
                'If you have any questions about these Terms, please contact us:\n\nEmail: legal@seedit.com\nPhone: +233 24 123 4567\nAddress: East Legon, Accra, Ghana',
              ),

              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Please read these terms carefully. By using our service, you agree to be bound by these terms and conditions.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange[700],
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.companyInfoColor,
            fontFamily: 'Montserrat',
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
