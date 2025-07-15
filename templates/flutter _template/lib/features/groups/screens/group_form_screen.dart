import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../core/utils/app_theme.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../providers/groups_provider.dart';
import '../models/group_models.dart';
import '../widgets/admin_email_invitation_widget.dart';
import '../../investments/models/investment_models.dart' as investment_models;
import '../../investments/providers/investment_provider.dart';

// Using real funds provider from investment module

class GroupFormScreen extends ConsumerStatefulWidget {
  final InvestmentGroup? group; // null for create, non-null for edit

  const GroupFormScreen({super.key, this.group});

  @override
  ConsumerState<GroupFormScreen> createState() => _GroupFormScreenState();
}

class _GroupFormScreenState extends ConsumerState<GroupFormScreen> {
  late final _formKey = GlobalKey<FormState>(
    debugLabel: 'group_form_${widget.group?.id ?? 'new'}',
  );
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _investmentGoalController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _minimumContributionController = TextEditingController();

  String _selectedPrivacySetting = 'public';
  String _selectedContributionFrequency = 'monthly';
  String? _selectedFundId;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 365));

  bool _isLoading = false;
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  // Admin invitation state
  List<String> _adminEmails = [];

  @override
  void initState() {
    super.initState();

    _initializeForm();
  }

  void _initializeForm() {
    if (widget.group != null) {
      // Edit mode - populate fields
      final group = widget.group!;
      _nameController.text = group.name;
      _descriptionController.text = group.description;
      _investmentGoalController.text = group.investmentGoal;
      _targetAmountController.text = group.targetAmount.toString();
      _minimumContributionController.text =
          group.minimumContribution?.toString() ?? '';
      _selectedPrivacySetting = group.privacySetting;
      _selectedContributionFrequency = group.contributionFrequency;
      _selectedFundId = group.designatedFund.id;
      _startDate = group.startDate;
      _endDate = group.endDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _investmentGoalController.dispose();
    _targetAmountController.dispose();
    _minimumContributionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final funds = ref.watch(availableFundsProvider);
    final isEditing = widget.group != null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Group' : 'Create Group',
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: _buildForm(funds),
    );
  }

  Widget _buildForm(List<investment_models.Fund> funds) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic Information Section
            _buildSectionCard('Basic Information', Icons.info_outline, [
              CustomTextField(
                controller: _nameController,
                label: 'Group Name',
                hint: 'Enter group name',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Group name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Group Profile Image
              _buildImagePicker(),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Describe your investment group',
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _investmentGoalController,
                label: 'Investment Goal',
                hint: 'What do you want to achieve?',
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Investment goal is required';
                  }
                  return null;
                },
              ),
            ]),

            const SizedBox(height: 20),

            // Financial Details Section
            _buildSectionCard(
              'Financial Details',
              Icons.account_balance_wallet,
              [
                CustomTextField(
                  controller: _targetAmountController,
                  label: 'Target Amount (GHS)',
                  hint: 'Enter target amount',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Target amount is required';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _minimumContributionController,
                  label: 'Minimum Contribution (GHS)',
                  hint: 'Optional minimum contribution',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Please enter a valid amount';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildDropdownField(
                  'Contribution Frequency',
                  _selectedContributionFrequency,
                  [
                    {'value': 'weekly', 'label': 'Weekly'},
                    {'value': 'monthly', 'label': 'Monthly'},
                    {'value': 'quarterly', 'label': 'Quarterly'},
                    {'value': 'annually', 'label': 'Annually'},
                    {'value': 'flexible', 'label': 'Flexible'},
                  ],
                  (value) =>
                      setState(() => _selectedContributionFrequency = value!),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Fund Selection Section
            _buildSectionCard('Fund Selection', Icons.account_balance, [
              _buildFundDropdown(funds),
            ]),

            const SizedBox(height: 20),

            // Timeline Section
            _buildSectionCard('Timeline', Icons.schedule, [
              _buildDateField(
                'Start Date',
                _startDate,
                (date) => setState(() => _startDate = date),
              ),
              const SizedBox(height: 16),
              _buildDateField(
                'End Date',
                _endDate,
                (date) => setState(() => _endDate = date),
              ),
            ]),

            const SizedBox(height: 20),

            // Admin Selection Section (only for new groups)
            if (widget.group == null) ...[
              _buildSectionCard(
                'Admin Management',
                Icons.admin_panel_settings,
                [
                  AdminEmailInvitationWidget(
                    adminEmails: _adminEmails,
                    onEmailsChanged: (emails) {
                      setState(() {
                        _adminEmails = emails;
                      });
                    },
                    isRequired: true,
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],

            // Settings Section
            _buildSectionCard('Settings', Icons.settings, [
              _buildDropdownField(
                'Privacy Setting',
                _selectedPrivacySetting,
                [
                  {'value': 'public', 'label': 'Public (Anyone can join)'},
                  {'value': 'private', 'label': 'Private (Invite only)'},
                ],
                (value) => setState(() => _selectedPrivacySetting = value!),
              ),
            ]),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: _isLoading
                    ? 'SAVING...'
                    : (widget.group != null ? 'UPDATE GROUP' : 'CREATE GROUP'),
                onPressed: _isLoading ? null : _submitForm,
                backgroundColor: AppTheme.primaryColor,
                height: 50,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 24, color: AppTheme.primaryColor),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    List<Map<String, String>> options,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              onChanged: onChanged,
              items: options.map((option) {
                return DropdownMenuItem<String>(
                  value: option['value'],
                  child: Text(
                    option['label']!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFundDropdown(List<investment_models.Fund> funds) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Designated Fund',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedFundId,
              isExpanded: true,
              hint: const Text(
                'Select a fund',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Montserrat',
                  color: Colors.grey,
                ),
              ),
              onChanged: (value) => setState(() => _selectedFundId = value),
              items: funds.map((fund) {
                return DropdownMenuItem<String>(
                  value: fund.id,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fund.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      Text(
                        fund.category,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.companyInfoColor,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(
    String label,
    DateTime date,
    ValueChanged<DateTime> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(date, onChanged),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 12),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(
    DateTime currentDate,
    ValueChanged<DateTime> onChanged,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)), // 10 years
    );
    if (picked != null && picked != currentDate) {
      onChanged(picked);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedFundId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a fund'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate admin emails for new groups
    if (widget.group == null && _adminEmails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide at least one admin email address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final groupData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'investment_goal': _investmentGoalController.text.trim(),
        'target_amount': _targetAmountController.text.trim(),
        'minimum_contribution':
            _minimumContributionController.text.trim().isNotEmpty
            ? _minimumContributionController.text.trim()
            : null,
        'contribution_frequency': _selectedContributionFrequency,
        'start_date': _startDate.toIso8601String().split('T')[0],
        'end_date': _endDate.toIso8601String().split('T')[0],
        'designated_fund_id': int.parse(_selectedFundId.toString()),
        'privacy_setting': _selectedPrivacySetting,
        // Add admin_emails for new groups
        if (widget.group == null) 'admin_emails': _adminEmails,
      };

      InvestmentGroup? result;
      if (widget.group != null) {
        // Update existing group
        result = await ref
            .read(groupsProvider.notifier)
            .updateGroup(widget.group!.id, groupData, _selectedImage);
      } else {
        // Create new group
        result = await ref
            .read(groupsProvider.notifier)
            .createGroup(groupData, _selectedImage);
      }

      if (mounted) {
        if (result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.group != null
                    ? 'Group updated successfully!'
                    : 'Group created successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, result);
        } else {
          final error = ref.read(groupsProvider).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error ?? 'Failed to save group'),
              backgroundColor: Colors.red,
            ),
          );
        }
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

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Group Profile Image',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: _selectedImage != null
              ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _selectedImage!,
                        width: double.infinity,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: _removeImage,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : InkWell(
                  onTap: _pickImage,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 40,
                          color: AppTheme.companyInfoColor,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add Group Image',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.companyInfoColor,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        Text(
                          'Tap to select from gallery',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.companyInfoColor,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      developer.log('❌ Error picking image: $e', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }
}
