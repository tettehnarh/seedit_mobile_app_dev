import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_theme.dart';
import '../providers/kyc_provider.dart';
import '../models/kyc_models.dart';
import '../services/kyc_local_storage_service.dart';
import '../widgets/read_only_components.dart';

class KycPersonalInfoScreen extends ConsumerStatefulWidget {
  const KycPersonalInfoScreen({super.key});

  @override
  ConsumerState<KycPersonalInfoScreen> createState() =>
      _KycPersonalInfoScreenState();
}

class _KycPersonalInfoScreenState extends ConsumerState<KycPersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>(debugLabel: 'kyc_personal_info_form');
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _gpsCodeController = TextEditingController();

  DateTime? _selectedDate;
  String _selectedGender = '';
  String _selectedNationality = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() async {
    // First try to load from local storage
    final localData = await KycLocalStorageService.getPersonalInfo();

    if (localData != null) {
      setState(() {
        _firstNameController.text = localData['first_name'] ?? '';
        _lastNameController.text = localData['last_name'] ?? '';
        _selectedGender = localData['gender'] ?? '';
        _selectedNationality = localData['nationality'] ?? '';
        _phoneController.text = localData['phone_number'] ?? '';
        _addressController.text = localData['address'] ?? '';
        _cityController.text = localData['city'] ?? '';
        _gpsCodeController.text = localData['gps_code'] ?? '';

        if (localData['date_of_birth'] != null) {
          _selectedDate = DateTime.parse(localData['date_of_birth']);
        }
      });
      return;
    }

    // Fallback to provider data if no local data
    final kycStatus = ref.read(kycStatusProvider);
    final personalInfo = kycStatus?.personalInfo;

    if (personalInfo != null) {
      setState(() {
        _firstNameController.text = personalInfo.firstName;
        _lastNameController.text = personalInfo.lastName;
        _selectedGender = personalInfo.gender;
        _selectedNationality = personalInfo.nationality;
        _phoneController.text = personalInfo.phoneNumber;
        _addressController.text = personalInfo.address;
        _cityController.text = personalInfo.city;
        _gpsCodeController.text = personalInfo.gpsCode ?? '';
        _selectedDate = personalInfo.dateOfBirth;
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
            const Text(
              'Personal Information',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
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

              // Form Card
              Container(
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
                      'Basic Information',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Name Fields
                    if (isReadOnly) ...[
                      ReadOnlyTextField(
                        label: 'First Name',
                        value: _firstNameController.text,
                        icon: Icons.person,
                      ),
                      ReadOnlyTextField(
                        label: 'Last Name',
                        value: _lastNameController.text,
                        icon: Icons.person,
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _firstNameController,
                              label: 'First Name',
                              isRequired: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _lastNameController,
                              label: 'Last Name',
                              isRequired: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Gender Dropdown
                    if (isReadOnly)
                      ReadOnlyDropdownField(
                        label: 'Gender',
                        value: _selectedGender,
                        displayValue: _getGenderDisplayValue(_selectedGender),
                        icon: Icons.person_outline,
                      )
                    else ...[
                      _buildGenderDropdown(),
                      const SizedBox(height: 16),
                    ],

                    // Date of Birth
                    if (isReadOnly)
                      ReadOnlyDateField(
                        label: 'Date of Birth',
                        date: _selectedDate,
                        icon: Icons.cake,
                      )
                    else ...[
                      _buildDateField(),
                      const SizedBox(height: 16),
                    ],

                    // Nationality Dropdown
                    if (isReadOnly)
                      ReadOnlyDropdownField(
                        label: 'Nationality',
                        value: _selectedNationality,
                        displayValue: _getNationalityDisplayValue(
                          _selectedNationality,
                        ),
                        icon: Icons.flag,
                        prefix: _getNationalityFlag(_selectedNationality),
                      )
                    else
                      _buildNationalityDropdown(),
                    const SizedBox(height: 20),

                    // Contact Information
                    const Text(
                      'Contact Information',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Phone Number
                    if (isReadOnly)
                      ReadOnlyTextField(
                        label: 'Phone Number',
                        value: _phoneController.text,
                        icon: Icons.phone,
                      )
                    else ...[
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        keyboardType: TextInputType.phone,
                        isRequired: true,
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Address Information
                    const Text(
                      'Address Information',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Address Fields
                    if (isReadOnly) ...[
                      ReadOnlyTextField(
                        label: 'Street Address',
                        value: _addressController.text,
                        icon: Icons.location_on,
                        isMultiline: true,
                      ),
                      ReadOnlyTextField(
                        label: 'City',
                        value: _cityController.text,
                        icon: Icons.location_city,
                      ),
                      ReadOnlyTextField(
                        label: 'GPS Code',
                        value: _gpsCodeController.text,
                        icon: Icons.gps_fixed,
                      ),
                    ] else ...[
                      _buildTextField(
                        controller: _addressController,
                        label: 'Street Address',
                        maxLines: 2,
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _cityController,
                              label: 'City',
                              isRequired: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _gpsCodeController,
                              label: 'GPS Code (Optional)',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Save Button (only show if not in read-only mode)
              if (!isReadOnly)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _savePersonalInfo,
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
            blurRadius: 8,
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
                '1',
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
                  'Step 1 of 4',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  'Personal Information',
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool isRequired = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14),
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

  Widget _buildDateField() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _selectedDate != null
                    ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                    : 'Date of Birth *',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: _selectedDate != null
                      ? Colors.black
                      : Colors.grey.shade600,
                ),
              ),
            ),
            Icon(Icons.calendar_today, color: Colors.grey.shade600, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime eighteenYearsAgo = DateTime.now().subtract(
      const Duration(days: 6570), // 18 years ago (365.25 * 18)
    );

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: eighteenYearsAgo,
      helpText: 'Select your date of birth',
      errorFormatText: 'Enter a valid date',
      errorInvalidText: 'You must be at least 18 years old',
    );

    if (picked != null && picked != _selectedDate) {
      // Additional validation to ensure user is 18 or older
      final age = DateTime.now().difference(picked).inDays / 365.25;
      if (age < 18) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You must be at least 18 years old to register'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _savePersonalInfo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your date of birth'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate age (must be 18 or older)
    final age = DateTime.now().difference(_selectedDate!).inDays / 365.25;
    if (age < 18) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be at least 18 years old to register'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    if (_selectedGender.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your gender'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (_selectedNationality.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your nationality'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final personalInfo = KycPersonalInfo(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      gender: _selectedGender,
      dateOfBirth: _selectedDate!,
      nationality: _selectedNationality,
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      gpsCode: _gpsCodeController.text.trim().isEmpty
          ? null
          : _gpsCodeController.text.trim(),
    );

    final success = await ref
        .read(kycProvider.notifier)
        .updatePersonalInfo(personalInfo);

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Personal information saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, '/kyc/next-of-kin');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save personal information'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender.isEmpty ? null : _selectedGender,
      decoration: InputDecoration(
        labelText: 'Gender *',
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
      items: KycChoices.genderChoices.map((choice) {
        return DropdownMenuItem<String>(
          value: choice['value'],
          child: Text(
            choice['label']!,
            style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedGender = value ?? '';
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Gender is required';
        }
        return null;
      },
    );
  }

  Widget _buildNationalityDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedNationality.isEmpty ? null : _selectedNationality,
      decoration: InputDecoration(
        labelText: 'Nationality *',
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
      items: KycChoices.countryChoices.map((country) {
        return DropdownMenuItem<String>(
          value: country['value'],
          child: Row(
            children: [
              Text(country['flag']!, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  country['label']!,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedNationality = value ?? '';
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Nationality is required';
        }
        return null;
      },
      menuMaxHeight: 300, // Limit dropdown height for better UX
    );
  }

  /// Get display value for gender
  String _getGenderDisplayValue(String genderValue) {
    final choice = KycChoices.genderChoices.firstWhere(
      (choice) => choice['value'] == genderValue,
      orElse: () => {'label': genderValue},
    );
    return choice['label'] ?? genderValue;
  }

  /// Get display value for nationality
  String _getNationalityDisplayValue(String nationalityValue) {
    final country = KycChoices.countryChoices.firstWhere(
      (country) => country['value'] == nationalityValue,
      orElse: () => {'label': nationalityValue},
    );
    return country['label'] ?? nationalityValue;
  }

  /// Get flag widget for nationality
  Widget? _getNationalityFlag(String nationalityValue) {
    try {
      final country = KycChoices.countryChoices.firstWhere(
        (country) => country['value'] == nationalityValue,
      );
      final flag = country['flag'];
      return flag != null
          ? Text(flag, style: const TextStyle(fontSize: 16))
          : null;
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _gpsCodeController.dispose();
    super.dispose();
  }
}
