import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_theme.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../models/kyc_models.dart';
import '../providers/kyc_provider.dart';
import '../services/kyc_local_storage_service.dart';
import '../widgets/read_only_components.dart';

class KycNextOfKinScreen extends ConsumerStatefulWidget {
  const KycNextOfKinScreen({super.key});

  @override
  ConsumerState<KycNextOfKinScreen> createState() => _KycNextOfKinScreenState();
}

class _KycNextOfKinScreenState extends ConsumerState<KycNextOfKinScreen> {
  final _formKey = GlobalKey<FormState>(debugLabel: 'kyc_next_of_kin_form');
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  String _selectedRelationship = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() async {
    // First try to load from local storage
    final localData = await KycLocalStorageService.getNextOfKin();

    if (localData != null) {
      setState(() {
        _firstNameController.text = localData['first_name'] ?? '';
        _lastNameController.text = localData['last_name'] ?? '';
        _selectedRelationship = localData['relationship'] ?? '';
        _phoneController.text = localData['phone_number'] ?? '';
        _emailController.text = localData['email'] ?? '';
      });
      return;
    }

    // Fallback to provider data if no local data
    final kycState = ref.read(kycProvider);
    final nextOfKin = kycState.kycStatus?.nextOfKin;

    if (nextOfKin != null) {
      setState(() {
        _firstNameController.text = nextOfKin.firstName;
        _lastNameController.text = nextOfKin.lastName;
        _selectedRelationship = nextOfKin.relationship;
        _phoneController.text = nextOfKin.phoneNumber;
        _emailController.text = nextOfKin.email;
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveNextOfKin() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRelationship.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a relationship'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Create next of kin data for local storage
    final nextOfKinData = {
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'relationship': _selectedRelationship,
      'phone_number': _phoneController.text.trim(),
      'email': _emailController.text.trim(),
    };

    try {
      // Save to local storage and update provider state for immediate UI updates
      final success = await ref
          .read(kycProvider.notifier)
          .saveNextOfKinLocally(nextOfKinData);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Next of kin information saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate to professional info screen (next step in KYC flow)
        Navigator.pushReplacementNamed(context, '/kyc/financial-info');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to save next of kin information. Please try again.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Check if the screen should be in read-only mode
  bool get isReadOnly {
    final kycStatus = ref.watch(kycStatusProvider);
    return kycStatus?.isReadOnly ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final kycStatus = ref.watch(kycStatusProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Text(
              'Next of Kin',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
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
                      'Emergency Contact Information',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please provide details of your emergency contact person.',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Form Fields - Conditional rendering based on read-only mode
                    if (isReadOnly) ...[
                      // Read-only mode
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
                      ReadOnlyDropdownField(
                        label: 'Relationship',
                        value: _selectedRelationship,
                        displayValue: _getRelationshipDisplayValue(
                          _selectedRelationship,
                        ),
                        icon: Icons.family_restroom,
                      ),
                      ReadOnlyTextField(
                        label: 'Phone Number',
                        value: _phoneController.text,
                        icon: Icons.phone,
                      ),
                      ReadOnlyTextField(
                        label: 'Email Address',
                        value: _emailController.text,
                        icon: Icons.email,
                      ),
                    ] else ...[
                      // Editable mode
                      CustomTextField(
                        controller: _firstNameController,
                        label: 'First Name',
                        hint: 'Enter first name',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'First name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        controller: _lastNameController,
                        label: 'Last Name',
                        hint: 'Enter last name',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Last name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildRelationshipDropdown(),
                      const SizedBox(height: 16),

                      CustomTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        hint: 'Enter phone number',
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Phone number is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        hint: 'Enter email address',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email address is required';
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
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
                    onPressed: _isLoading ? null : _saveNextOfKin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
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
                '2',
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
                  'Step 2 of 4',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  'Next of Kin',
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

  Widget _buildRelationshipDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedRelationship.isEmpty ? null : _selectedRelationship,
      decoration: InputDecoration(
        labelText: 'Relationship *',
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
      items: KycChoices.relationshipChoices.map((choice) {
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
          _selectedRelationship = value ?? '';
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Relationship is required';
        }
        return null;
      },
    );
  }

  /// Get display value for relationship
  String _getRelationshipDisplayValue(String relationshipValue) {
    final choice = KycChoices.relationshipChoices.firstWhere(
      (choice) => choice['value'] == relationshipValue,
      orElse: () => {'label': relationshipValue},
    );
    return choice['label'] ?? relationshipValue;
  }
}
