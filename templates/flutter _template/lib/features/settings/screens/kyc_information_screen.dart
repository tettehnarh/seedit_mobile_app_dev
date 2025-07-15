import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_theme.dart';
import '../../auth/providers/user_provider.dart';
import '../../kyc/services/kyc_service.dart';
import 'dart:developer' as developer;

class KycInformationScreen extends ConsumerStatefulWidget {
  const KycInformationScreen({super.key});

  @override
  ConsumerState<KycInformationScreen> createState() =>
      _KycInformationScreenState();
}

class _KycInformationScreenState extends ConsumerState<KycInformationScreen> {
  final KycService _kycService = KycService();
  bool _isLoading = true;
  Map<String, dynamic>? _kycData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadKycData();
  }

  Future<void> _loadKycData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      developer.log('🔍 [KYC_INFO] Loading comprehensive KYC data...');

      // Get comprehensive KYC data from the service
      final result = await _kycService.getKycApplicationData();

      if (result['success'] == true && result['data'] != null) {
        setState(() {
          _kycData = result['data'];
          _isLoading = false;
        });
        developer.log('✅ [KYC_INFO] KYC data loaded successfully');
      } else {
        setState(() {
          _errorMessage = 'Failed to load KYC information';
          _isLoading = false;
        });
        developer.log(
          '❌ [KYC_INFO] Failed to load KYC data: ${result['error']}',
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading KYC information: $e';
        _isLoading = false;
      });
      developer.log('❌ [KYC_INFO] Error loading KYC data: $e', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'KYC Information',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
      ),
      body: _isLoading
          ? _buildLoadingView()
          : _errorMessage != null
          ? _buildErrorView()
          : _kycData == null
          ? _buildNoDataView()
          : RefreshIndicator(
              onRefresh: _loadKycData,
              color: AppTheme.primaryColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // KYC Status Card
                    _buildStatusCard(user!),
                    const SizedBox(height: 24),

                    // Personal Information Section
                    if (_kycData!['personal_info'] != null)
                      _buildSectionCard(
                        'Personal Information',
                        Icons.person,
                        _buildPersonalInfoContent(_kycData!['personal_info']),
                      ),
                    if (_kycData!['personal_info'] != null)
                      const SizedBox(height: 16),

                    // Next of Kin Section
                    if (_kycData!['next_of_kin'] != null)
                      _buildSectionCard(
                        'Next of Kin',
                        Icons.family_restroom,
                        _buildNextOfKinContent(_kycData!['next_of_kin']),
                      ),
                    if (_kycData!['next_of_kin'] != null)
                      const SizedBox(height: 16),

                    // Professional Information Section
                    if (_kycData!['professional_info'] != null)
                      _buildSectionCard(
                        'Professional Information',
                        Icons.work,
                        _buildProfessionalInfoContent(
                          _kycData!['professional_info'],
                        ),
                      ),
                    if (_kycData!['professional_info'] != null)
                      const SizedBox(height: 16),

                    // ID Information Section
                    if (_kycData!['id_info'] != null)
                      _buildSectionCard(
                        'ID Information',
                        Icons.badge,
                        _buildIdInfoContent(_kycData!['id_info']),
                      ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.primaryColor),
          SizedBox(height: 16),
          Text(
            'Loading KYC Information...',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.primaryColor,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error Loading KYC Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.red,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'An unexpected error occurred',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadKycData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No KYC Information Available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete your KYC verification to view your information here.',
            textAlign: TextAlign.center,
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

  Widget _buildStatusCard(user) {
    final kycStatus = user.kycStatus.toLowerCase();
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (kycStatus) {
      case 'approved':
        statusColor = Colors.green;
        statusText = 'Verified';
        statusIcon = Icons.verified;
        break;
      case 'pending_review':
        statusColor = Colors.orange;
        statusText = 'Under Review';
        statusIcon = Icons.pending;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = 'Rejected';
        statusIcon = Icons.error;
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Unknown';
        statusIcon = Icons.help;
    }

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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(statusIcon, color: statusColor, size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              'KYC Verification Status',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, Widget content) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppTheme.primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoContent(dynamic kycInfo) {
    if (kycInfo == null) return const SizedBox.shrink();

    return Column(
      children: [
        if (kycInfo['first_name'] != null && kycInfo['last_name'] != null)
          _buildInfoRow(
            'Full Name',
            '${kycInfo['first_name']} ${kycInfo['last_name']}',
          ),
        if (kycInfo['date_of_birth'] != null)
          _buildInfoRow(
            'Date of Birth',
            _formatDateString(kycInfo['date_of_birth']),
          ),
        if (kycInfo['nationality']?.isNotEmpty == true)
          _buildInfoRow('Nationality', kycInfo['nationality']),
        if (kycInfo['gender']?.isNotEmpty == true)
          _buildInfoRow('Gender', _capitalizeFirst(kycInfo['gender'])),
        if (kycInfo['phone_number']?.isNotEmpty == true)
          _buildInfoRow('Phone Number', kycInfo['phone_number']),
        if (kycInfo['address']?.isNotEmpty == true)
          _buildInfoRow('Address', kycInfo['address']),
        if (kycInfo['city']?.isNotEmpty == true)
          _buildInfoRow('City', kycInfo['city']),
        if (kycInfo['gps_code']?.isNotEmpty == true)
          _buildInfoRow('GPS Code', kycInfo['gps_code']),
      ],
    );
  }

  Widget _buildNextOfKinContent(dynamic kycInfo) {
    if (kycInfo == null) return const SizedBox.shrink();

    return Column(
      children: [
        if (kycInfo['first_name'] != null && kycInfo['last_name'] != null)
          _buildInfoRow(
            'Full Name',
            '${kycInfo['first_name']} ${kycInfo['last_name']}',
          ),
        if (kycInfo['relationship']?.isNotEmpty == true)
          _buildInfoRow(
            'Relationship',
            _capitalizeFirst(kycInfo['relationship'].replaceAll('_', ' ')),
          ),
        if (kycInfo['phone_number']?.isNotEmpty == true)
          _buildInfoRow('Phone Number', kycInfo['phone_number']),
        if (kycInfo['email']?.isNotEmpty == true)
          _buildInfoRow('Email', kycInfo['email']),
      ],
    );
  }

  Widget _buildProfessionalInfoContent(dynamic kycInfo) {
    if (kycInfo == null) return const SizedBox.shrink();

    return Column(
      children: [
        if (kycInfo['profession']?.isNotEmpty == true)
          _buildInfoRow('Profession', kycInfo['profession']),
        if (kycInfo['employment_status']?.isNotEmpty == true)
          _buildInfoRow(
            'Employment Status',
            _capitalizeFirst(kycInfo['employment_status'].replaceAll('_', ' ')),
          ),
        if (kycInfo['institution_name']?.isNotEmpty == true)
          _buildInfoRow('Institution', kycInfo['institution_name']),
        if (kycInfo['monthly_income']?.isNotEmpty == true)
          _buildInfoRow(
            'Monthly Income',
            _formatIncomeRange(kycInfo['monthly_income']),
          ),
        if (kycInfo['source_of_income']?.isNotEmpty == true)
          _buildInfoRow(
            'Source of Income',
            _capitalizeFirst(kycInfo['source_of_income'].replaceAll('_', ' ')),
          ),
      ],
    );
  }

  Widget _buildIdInfoContent(dynamic kycInfo) {
    if (kycInfo == null) return const SizedBox.shrink();

    return Column(
      children: [
        if (kycInfo['id_type']?.isNotEmpty == true)
          _buildInfoRow(
            'ID Type',
            _capitalizeFirst(kycInfo['id_type'].replaceAll('_', ' ')),
          ),
        if (kycInfo['id_number']?.isNotEmpty == true)
          _buildInfoRow('ID Number', kycInfo['id_number']),
        if (kycInfo['issue_date'] != null)
          _buildInfoRow('Issue Date', _formatDateString(kycInfo['issue_date'])),
        if (kycInfo['expiry_date'] != null)
          _buildInfoRow(
            'Expiry Date',
            _formatDateString(kycInfo['expiry_date']),
          ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontFamily: 'Montserrat',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryColor,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateString(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString; // Return original string if parsing fails
    }
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  String _formatIncomeRange(String incomeCode) {
    switch (incomeCode) {
      case 'below_1000':
        return 'Below GHS 1,000';
      case '1000_5000':
        return 'GHS 1,000 - 5,000';
      case '5000_10000':
        return 'GHS 5,000 - 10,000';
      case '10000_20000':
        return 'GHS 10,000 - 20,000';
      case 'above_20000':
        return 'Above GHS 20,000';
      default:
        return _capitalizeFirst(incomeCode.replaceAll('_', ' '));
    }
  }
}
