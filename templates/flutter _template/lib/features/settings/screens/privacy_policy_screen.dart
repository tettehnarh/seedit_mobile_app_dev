import 'package:flutter/material.dart';
import '../../../core/utils/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
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
                'Privacy Policy',
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
                'Information We Collect',
                'We collect information you provide directly to us, such as when you create an account, complete KYC verification, make investments, or contact us for support. This includes:\n\n• Personal identification information (name, email, phone number)\n• Financial information for KYC compliance\n• Investment preferences and transaction history\n• Device and usage information',
              ),

              _buildSection(
                'How We Use Your Information',
                'We use the information we collect to:\n\n• Provide and maintain our investment services\n• Process transactions and manage your account\n• Comply with legal and regulatory requirements\n• Communicate with you about your account and our services\n• Improve our platform and develop new features\n• Detect and prevent fraud and security threats',
              ),

              _buildSection(
                'Information Sharing',
                'We do not sell, trade, or rent your personal information to third parties. We may share your information only in the following circumstances:\n\n• With your consent\n• To comply with legal obligations\n• With service providers who assist in our operations\n• To protect our rights and prevent fraud\n• In connection with a business transfer or merger',
              ),

              _buildSection(
                'Data Security',
                'We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. This includes:\n\n• Encryption of sensitive data\n• Secure data transmission protocols\n• Regular security assessments\n• Access controls and authentication\n• Employee training on data protection',
              ),

              _buildSection(
                'Your Rights',
                'You have the right to:\n\n• Access your personal information\n• Correct inaccurate information\n• Request deletion of your information\n• Object to processing of your information\n• Data portability\n• Withdraw consent where applicable\n\nTo exercise these rights, please contact us using the information provided below.',
              ),

              _buildSection(
                'Cookies and Tracking',
                'We use cookies and similar technologies to enhance your experience, analyze usage patterns, and improve our services. You can control cookie settings through your browser preferences.',
              ),

              _buildSection(
                'Third-Party Services',
                'Our platform may contain links to third-party websites or services. We are not responsible for the privacy practices of these external sites. We encourage you to review their privacy policies.',
              ),

              _buildSection(
                'Changes to This Policy',
                'We may update this privacy policy from time to time. We will notify you of any material changes by posting the new policy on our platform and updating the "Last updated" date.',
              ),

              _buildSection(
                'Contact Us',
                'If you have any questions about this privacy policy or our data practices, please contact us:\n\nEmail: privacy@seedit.com\nPhone: +233 24 123 4567\nAddress: East Legon, Accra, Ghana',
              ),

              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This privacy policy is governed by the laws of Ghana and complies with applicable data protection regulations.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[700],
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
