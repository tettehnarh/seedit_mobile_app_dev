import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_theme.dart';
import '../models/kyc_models.dart';
import '../providers/kyc_provider.dart';
import '../services/kyc_local_storage_service.dart';
import '../widgets/read_only_components.dart';

class KycFinancialInfoScreen extends ConsumerStatefulWidget {
  const KycFinancialInfoScreen({super.key});

  @override
  ConsumerState<KycFinancialInfoScreen> createState() =>
      _KycFinancialInfoScreenState();
}

class _KycFinancialInfoScreenState
    extends ConsumerState<KycFinancialInfoScreen> {
  final _formKey = GlobalKey<FormState>(debugLabel: 'kyc_financial_info_form');
  final _professionController =
      TextEditingController(); // Renamed from occupation
  final _institutionNameController =
      TextEditingController(); // Renamed from employer

  String _selectedEmploymentStatus = '';
  String _selectedMonthlyIncome = '';
  String _selectedSourceOfIncome = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() async {
    // First try to load from local storage
    final localData = await KycLocalStorageService.getProfessionalInfo();

    if (localData != null) {
      setState(() {
        _selectedEmploymentStatus = localData['employment_status'] ?? '';
        _professionController.text =
            localData['profession'] ?? localData['occupation'] ?? '';
        _institutionNameController.text =
            localData['institution_name'] ?? localData['employer'] ?? '';
        _selectedMonthlyIncome =
            localData['monthly_income'] ??
            localData['annual_income']?.toString() ??
            '';
        _selectedSourceOfIncome = localData['source_of_income'] ?? '';
      });
      return;
    }

    // Fallback to provider data if no local data
    final kycStatus = ref.read(kycStatusProvider);
    final financialInfo = kycStatus?.financialInfo;

    if (financialInfo != null) {
      setState(() {
        _selectedEmploymentStatus = financialInfo.employmentStatus;
        _professionController.text = financialInfo.profession;
        _institutionNameController.text = financialInfo.institutionName;
        _selectedMonthlyIncome = financialInfo.monthlyIncome;
        _selectedSourceOfIncome = financialInfo.sourceOfIncome;
      });
    }
  }

  /// Check if the screen should be in read-only mode
  bool get isReadOnly {
    final kycStatus = ref.watch(kycStatusProvider);
    return kycStatus?.isReadOnly ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(kycLoadingProvider) || _isLoading;
    final kycStatus = ref.watch(kycStatusProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Expanded(
              child: Text(
                'Financial Information',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            if (isReadOnly) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: kycStatus?.isUnderReview == true
                      ? Colors.blue[100]
                      : Colors.green[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  kycStatus?.isUnderReview == true ? 'REVIEW' : 'APPROVED',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: kycStatus?.isUnderReview == true
                        ? Colors.blue[700]
                        : Colors.green[700],
                  ),
                ),
              ),
            ],
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Review Status Banner (if in read-only mode)
              if (isReadOnly && kycStatus != null)
                KycReviewStatusBanner(
                  status: kycStatus.status,
                  message: kycStatus.isUnderReview
                      ? 'Your KYC application is currently under review. You cannot make changes at this time.'
                      : 'Your KYC application has been approved. Information is displayed in read-only mode.',
                ),

              // Progress Indicator
              _buildProgressIndicator(),
              const SizedBox(height: 20),

              // Employment Information Card
              _buildEmploymentCard(),
              const SizedBox(height: 20),

              // Financial Information Card
              _buildFinancialCard(),
              const SizedBox(height: 20),

              // Save Button (only show if not in read-only mode)
              if (!isReadOnly)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _saveFinancialInfo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Save & Continue',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                '3',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step 3 of 4',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  'Financial Information',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmploymentCard() {
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
            'Employment Information',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 20),

          // Employment fields - conditional rendering
          if (isReadOnly) ...[
            ReadOnlyDropdownField(
              label: 'Employment Status',
              value: _selectedEmploymentStatus,
              displayValue: _getEmploymentStatusDisplayValue(
                _selectedEmploymentStatus,
              ),
              icon: Icons.work,
            ),
            ReadOnlyTextField(
              label: 'Profession/Job Title',
              value: _professionController.text,
              icon: Icons.badge,
            ),
            ReadOnlyTextField(
              label: 'Institution/Company Name',
              value: _institutionNameController.text,
              icon: Icons.business,
            ),
          ] else ...[
            _buildChoiceDropdownField(
              label: 'Employment Status',
              value: _selectedEmploymentStatus,
              choices: KycChoices.employmentStatusChoices,
              onChanged: (value) {
                setState(() {
                  _selectedEmploymentStatus = value!;
                });
              },
              isRequired: true,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _professionController,
              label: 'Profession/Job Title',
              isRequired: true,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _institutionNameController,
              label: 'Institution/Company Name',
              isRequired: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFinancialCard() {
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
            'Financial Information',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 20),

          // Financial fields - conditional rendering
          if (isReadOnly) ...[
            ReadOnlyDropdownField(
              label: 'Monthly Income (GHS)',
              value: _selectedMonthlyIncome,
              displayValue: _getMonthlyIncomeDisplayValue(
                _selectedMonthlyIncome,
              ),
              icon: Icons.attach_money,
            ),
            ReadOnlyDropdownField(
              label: 'Source of Income',
              value: _selectedSourceOfIncome,
              displayValue: _getSourceOfIncomeDisplayValue(
                _selectedSourceOfIncome,
              ),
              icon: Icons.source,
            ),
          ] else ...[
            _buildMonthlyIncomeDropdown(),
            const SizedBox(height: 16),

            _buildChoiceDropdownField(
              label: 'Source of Income',
              value: _selectedSourceOfIncome,
              choices: KycChoices.sourceOfIncomeChoices,
              onChanged: (value) {
                setState(() {
                  _selectedSourceOfIncome = value!;
                });
              },
              isRequired: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    bool isRequired = false,
    String? prefix,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
        labelStyle: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.primaryColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      validator: isRequired
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return '$label is required';
              }
              return null;
            }
          : null,
    );
  }

  Future<void> _saveFinancialInfo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedEmploymentStatus.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select employment status'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedMonthlyIncome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your monthly income range'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedSourceOfIncome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select source of income'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Save to local storage and update provider state for immediate UI updates
      final financialInfo = KycFinancialInfo(
        employmentStatus: _selectedEmploymentStatus,
        profession: _professionController.text.trim(),
        institutionName: _institutionNameController.text.trim(),
        monthlyIncome: _selectedMonthlyIncome,
        sourceOfIncome: _selectedSourceOfIncome,
      );
      final success = await ref
          .read(kycProvider.notifier)
          .saveFinancialInfoLocally(financialInfo);

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Financial information saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate to documents screen (next step in KYC flow)
          Navigator.pushReplacementNamed(context, '/kyc/documents');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save financial information'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildChoiceDropdownField({
    required String label,
    required String value,
    required List<Map<String, String>> choices,
    required ValueChanged<String?> onChanged,
    bool isRequired = false,
  }) {
    return DropdownButtonFormField<String>(
      value: value.isEmpty ? null : value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.primaryColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      items: choices.map((choice) {
        return DropdownMenuItem<String>(
          value: choice['value'],
          child: Text(
            choice['label']!,
            style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: isRequired
          ? (value) {
              if (value == null || value.isEmpty) {
                return '$label is required';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildMonthlyIncomeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedMonthlyIncome.isEmpty ? null : _selectedMonthlyIncome,
      decoration: InputDecoration(
        labelText: 'Monthly Income (GHS) *',
        labelStyle: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.primaryColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      isExpanded: true,
      items: KycChoices.monthlyIncomeChoices.map((income) {
        return DropdownMenuItem<String>(
          value: income['value'],
          child: Text(
            income['label']!,
            style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedMonthlyIncome = value ?? '';
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Monthly income is required';
        }
        return null;
      },
    );
  }

  /// Get display value for employment status
  String _getEmploymentStatusDisplayValue(String employmentStatusValue) {
    final choice = KycChoices.employmentStatusChoices.firstWhere(
      (choice) => choice['value'] == employmentStatusValue,
      orElse: () => {'label': employmentStatusValue},
    );
    return choice['label'] ?? employmentStatusValue;
  }

  /// Get display value for monthly income
  String _getMonthlyIncomeDisplayValue(String monthlyIncomeValue) {
    final choice = KycChoices.monthlyIncomeChoices.firstWhere(
      (choice) => choice['value'] == monthlyIncomeValue,
      orElse: () => {'label': monthlyIncomeValue},
    );
    return choice['label'] ?? monthlyIncomeValue;
  }

  /// Get display value for source of income
  String _getSourceOfIncomeDisplayValue(String sourceOfIncomeValue) {
    final choice = KycChoices.sourceOfIncomeChoices.firstWhere(
      (choice) => choice['value'] == sourceOfIncomeValue,
      orElse: () => {'label': sourceOfIncomeValue},
    );
    return choice['label'] ?? sourceOfIncomeValue;
  }

  @override
  void dispose() {
    _professionController.dispose();
    _institutionNameController.dispose();
    super.dispose();
  }
}
