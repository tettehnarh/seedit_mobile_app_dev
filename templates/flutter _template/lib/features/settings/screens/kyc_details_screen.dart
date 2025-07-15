import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_theme.dart';
import '../../auth/providers/auth_provider.dart';

class KycDetailsScreen extends ConsumerWidget {
  const KycDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Custom app bar with gradient
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppTheme.primaryColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppTheme.primaryColor, Color(0xFF06756C)],
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 40),
                      Icon(Icons.verified_user, size: 60, color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'KYC Information',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Verified Account',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
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
                  // Status card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'KYC Status: Verified',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Your account has been successfully verified',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.green[700],
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Personal Information
                  _buildSection('Personal Information', [
                    _buildInfoRow('Full Name', user?.fullName ?? 'N/A'),
                    _buildInfoRow('Email', user?.email ?? 'N/A'),
                    _buildInfoRow('Phone Number', user?.phoneNumber ?? 'N/A'),
                    _buildInfoRow(
                      'Date of Birth',
                      'January 15, 1990',
                    ), // Mock data
                    _buildInfoRow('Gender', 'Male'), // Mock data
                    _buildInfoRow('Nationality', 'Nigerian'), // Mock data
                  ]),
                  const SizedBox(height: 24),

                  // Next of Kin Information
                  _buildSection('Next of Kin Information', [
                    _buildInfoRow('Full Name', 'Jane Doe'), // Mock data
                    _buildInfoRow('Relationship', 'Spouse'), // Mock data
                    _buildInfoRow(
                      'Phone Number',
                      '+234 801 234 5678',
                    ), // Mock data
                    _buildInfoRow('Email', 'jane.doe@example.com'), // Mock data
                    _buildInfoRow(
                      'Address',
                      '123 Lagos Street, Victoria Island',
                    ), // Mock data
                  ]),
                  const SizedBox(height: 24),

                  // Professional Information
                  _buildSection('Professional & Financial Information', [
                    _buildInfoRow(
                      'Occupation',
                      'Software Engineer',
                    ), // Mock data
                    _buildInfoRow('Employer', 'Tech Company Ltd'), // Mock data
                    _buildInfoRow(
                      'Annual Income',
                      '₦5,000,000 - ₦10,000,000',
                    ), // Mock data
                    _buildInfoRow(
                      'Source of Income',
                      'Employment',
                    ), // Mock data
                    _buildInfoRow(
                      'Investment Experience',
                      'Intermediate',
                    ), // Mock data
                  ]),
                  const SizedBox(height: 24),

                  // ID Information
                  _buildSection('ID Information', [
                    _buildInfoRow('ID Type', 'National ID Card'), // Mock data
                    _buildInfoRow('ID Number', 'NIN12345678901'), // Mock data
                    _buildInfoRow('Issue Date', 'January 1, 2020'), // Mock data
                    _buildInfoRow(
                      'Expiry Date',
                      'January 1, 2030',
                    ), // Mock data
                  ]),
                  const SizedBox(height: 24),

                  // Bank Information
                  _buildSection('Bank Information', [
                    _buildInfoRow(
                      'Bank Name',
                      'First Bank of Nigeria',
                    ), // Mock data
                    _buildInfoRow('Account Number', '1234567890'), // Mock data
                    _buildInfoRow('Account Name', user?.fullName ?? 'N/A'),
                    _buildInfoRow('BVN', 'BVN12345678901'), // Mock data
                  ]),
                  const SizedBox(height: 24),

                  // Note
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppTheme.primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Important Note',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'This information is read-only as your KYC has been verified. If you need to update any information, please contact our support team.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.companyInfoColor,
                            fontFamily: 'Montserrat',
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.companyInfoColor,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
