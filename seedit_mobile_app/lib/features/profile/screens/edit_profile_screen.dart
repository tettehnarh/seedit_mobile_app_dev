import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../shared/providers/profile_provider.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/models/profile_model.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_dropdown_field.dart';
import '../../../core/utils/validation_functions.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _occupationController = TextEditingController();
  final _employerController = TextEditingController();
  final _annualIncomeController = TextEditingController();
  final _bvnController = TextEditingController();
  final _ninController = TextEditingController();

  DateTime? _selectedDateOfBirth;
  RiskProfile? _selectedRiskProfile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
    });
  }

  void _loadProfileData() {
    final profile = ref.read(currentUserProfileProvider);
    if (profile != null) {
      _firstNameController.text = profile.firstName;
      _lastNameController.text = profile.lastName;
      _phoneController.text = profile.phoneNumber ?? '';
      _addressController.text = profile.address ?? '';
      _cityController.text = profile.city ?? '';
      _stateController.text = profile.state ?? '';
      _countryController.text = profile.country ?? '';
      _postalCodeController.text = profile.postalCode ?? '';
      _occupationController.text = profile.occupation ?? '';
      _employerController.text = profile.employer ?? '';
      _annualIncomeController.text = profile.annualIncome?.toString() ?? '';
      _bvnController.text = profile.bvn ?? '';
      _ninController.text = profile.nin ?? '';
      _selectedDateOfBirth = profile.dateOfBirth;
      _selectedRiskProfile = profile.riskProfile;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    _occupationController.dispose();
    _employerController.dispose();
    _annualIncomeController.dispose();
    _bvnController.dispose();
    _ninController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // 18 years ago
      helpText: 'Select Date of Birth',
    );
    
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    final request = UpdateProfileRequest(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phoneNumber: _phoneController.text.trim().isNotEmpty 
          ? _phoneController.text.trim() 
          : null,
      dateOfBirth: _selectedDateOfBirth,
      address: _addressController.text.trim().isNotEmpty 
          ? _addressController.text.trim() 
          : null,
      city: _cityController.text.trim().isNotEmpty 
          ? _cityController.text.trim() 
          : null,
      state: _stateController.text.trim().isNotEmpty 
          ? _stateController.text.trim() 
          : null,
      country: _countryController.text.trim().isNotEmpty 
          ? _countryController.text.trim() 
          : null,
      postalCode: _postalCodeController.text.trim().isNotEmpty 
          ? _postalCodeController.text.trim() 
          : null,
      occupation: _occupationController.text.trim().isNotEmpty 
          ? _occupationController.text.trim() 
          : null,
      employer: _employerController.text.trim().isNotEmpty 
          ? _employerController.text.trim() 
          : null,
      annualIncome: _annualIncomeController.text.trim().isNotEmpty 
          ? double.tryParse(_annualIncomeController.text.trim()) 
          : null,
      bvn: _bvnController.text.trim().isNotEmpty 
          ? _bvnController.text.trim() 
          : null,
      nin: _ninController.text.trim().isNotEmpty 
          ? _ninController.text.trim() 
          : null,
      riskProfile: _selectedRiskProfile,
    );

    try {
      await ref.read(profileStateProvider.notifier).updateProfile(
        currentUser.id,
        request,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(profileLoadingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: isLoading ? null : _saveProfile,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Personal Information Section
              _buildSectionHeader('Personal Information'),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _firstNameController,
                      label: 'First Name',
                      validator: ValidationFunctions.validateName,
                      enabled: !isLoading,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _lastNameController,
                      label: 'Last Name',
                      validator: ValidationFunctions.validateName,
                      enabled: !isLoading,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _phoneController,
                label: 'Phone Number',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value?.isNotEmpty == true) {
                    return ValidationFunctions.validatePhoneNumber(value);
                  }
                  return null;
                },
                enabled: !isLoading,
              ),
              
              const SizedBox(height: 16),
              
              GestureDetector(
                onTap: isLoading ? null : _selectDateOfBirth,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date of Birth',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedDateOfBirth != null
                                  ? DateFormat('MMM dd, yyyy').format(_selectedDateOfBirth!)
                                  : 'Select date of birth',
                              style: TextStyle(
                                fontSize: 16,
                                color: _selectedDateOfBirth != null
                                    ? Colors.black
                                    : Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Address Information Section
              _buildSectionHeader('Address Information'),
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _addressController,
                label: 'Street Address',
                maxLines: 2,
                enabled: !isLoading,
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _cityController,
                      label: 'City',
                      enabled: !isLoading,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _stateController,
                      label: 'State',
                      enabled: !isLoading,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _countryController,
                      label: 'Country',
                      enabled: !isLoading,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _postalCodeController,
                      label: 'Postal Code',
                      enabled: !isLoading,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Professional Information Section
              _buildSectionHeader('Professional Information'),
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _occupationController,
                label: 'Occupation',
                enabled: !isLoading,
              ),
              
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _employerController,
                label: 'Employer',
                enabled: !isLoading,
              ),
              
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _annualIncomeController,
                label: 'Annual Income (₦)',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isNotEmpty == true) {
                    return ValidationFunctions.validateNumeric(value, 'Annual Income');
                  }
                  return null;
                },
                enabled: !isLoading,
              ),
              
              const SizedBox(height: 32),
              
              // Investment Profile Section
              _buildSectionHeader('Investment Profile'),
              const SizedBox(height: 16),
              
              CustomDropdownField<RiskProfile>(
                label: 'Risk Profile',
                value: _selectedRiskProfile,
                items: RiskProfile.values.map((profile) {
                  return DropdownMenuItem(
                    value: profile,
                    child: Text(_getRiskProfileDisplayText(profile)),
                  );
                }).toList(),
                onChanged: isLoading ? null : (value) {
                  setState(() {
                    _selectedRiskProfile = value;
                  });
                },
              ),
              
              const SizedBox(height: 32),
              
              // Identity Information Section
              _buildSectionHeader('Identity Information'),
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _bvnController,
                label: 'BVN (Bank Verification Number)',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isNotEmpty == true) {
                    return ValidationFunctions.validateBVN(value);
                  }
                  return null;
                },
                enabled: !isLoading,
              ),
              
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _ninController,
                label: 'NIN (National Identification Number)',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isNotEmpty == true) {
                    return ValidationFunctions.validateNIN(value);
                  }
                  return null;
                },
                enabled: !isLoading,
              ),
              
              const SizedBox(height: 32),
              
              // Save button
              CustomButton(
                text: 'Save Changes',
                onPressed: isLoading ? null : _saveProfile,
                isLoading: isLoading,
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  String _getRiskProfileDisplayText(RiskProfile profile) {
    switch (profile) {
      case RiskProfile.conservative:
        return 'Conservative - Low risk, stable returns';
      case RiskProfile.moderate:
        return 'Moderate - Balanced risk and returns';
      case RiskProfile.aggressive:
        return 'Aggressive - High risk, high returns';
    }
  }
}
