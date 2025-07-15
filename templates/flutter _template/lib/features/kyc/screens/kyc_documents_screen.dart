import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart' as picker;
import 'dart:io';

// Import standardized dialogs
import '../../../shared/widgets/dialogs/dialogs.dart';
import '../../../core/utils/app_theme.dart';
import '../models/kyc_models.dart';
import '../providers/kyc_provider.dart';
import '../services/kyc_local_storage_service.dart';
import '../utils/date_formatter.dart';
import '../widgets/read_only_components.dart';

class KycDocumentsScreen extends ConsumerStatefulWidget {
  const KycDocumentsScreen({super.key});

  @override
  ConsumerState<KycDocumentsScreen> createState() => _KycDocumentsScreenState();
}

class _KycDocumentsScreenState extends ConsumerState<KycDocumentsScreen> {
  String _pad(int n) => n.toString().padLeft(2, '0');
  final _formKey = GlobalKey<FormState>(debugLabel: 'kyc_documents_form');
  final _idNumberController = TextEditingController();
  final _issueDateController = TextEditingController();
  final _expiryDateController = TextEditingController();

  String _selectedIdType = '';
  File? _frontIdImage;
  File? _backIdImage;
  File? _selfieImage;
  String? _frontIdImageUrl;
  String? _backIdImageUrl;
  String? _selfieImageUrl;
  bool _isLoading = false;

  final picker.ImagePicker _picker = picker.ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  /// Format date string for display in DD/MM/YYYY format with zero-padding
  String _formatDateForDisplay(String dateString) {
    if (dateString.isEmpty) return '';

    try {
      // Try to parse the date using KycDateFormatter
      final date = KycDateFormatter.parseDate(dateString);
      if (date != null) {
        // Always format as zero-padded DD/MM/YYYY for display
        return KycDateFormatter.formatForDisplay(date);
      }
    } catch (e) {
      // Error formatting date
    }

    // If parsing fails, try to normalize the format if it's a valid date pattern
    if (dateString.contains('/')) {
      final parts = dateString.split('/');
      if (parts.length == 3) {
        try {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          final normalizedDate = DateTime(year, month, day);
          return KycDateFormatter.formatForDisplay(normalizedDate);
        } catch (e) {
          // Error normalizing date format
        }
      }
    }

    // If all else fails, return the original string
    return dateString;
  }

  void _loadExistingData() async {
    // First try to load from local storage
    final idData = await KycLocalStorageService.getIdInfo();
    final documentsData = await KycLocalStorageService.getDocuments();

    if (idData != null) {
      setState(() {
        _selectedIdType = idData['id_type'] ?? '';
        _idNumberController.text = idData['id_number'] ?? '';

        // Format dates properly for display (DD/MM/YYYY format)
        final issueDate = idData['issue_date'] ?? '';
        final expiryDate = idData['expiry_date'] ?? '';

        _issueDateController.text = _formatDateForDisplay(issueDate);
        _expiryDateController.text = _formatDateForDisplay(expiryDate);
      });
    }

    if (documentsData != null) {
      setState(() {
        // Load image paths if they exist
        if (documentsData['front_id_image'] != null) {
          _frontIdImage = File(documentsData['front_id_image']);
        }
        if (documentsData['back_id_image'] != null) {
          _backIdImage = File(documentsData['back_id_image']);
        }
        if (documentsData['selfie_image'] != null) {
          _selfieImage = File(documentsData['selfie_image']);
        }
      });
    }

    // Always check provider data for backend-stored documents
    final kycStatus = ref.read(kycStatusProvider);
    final idInformation = kycStatus?.idInformation;
    final documents = kycStatus?.documents ?? [];

    // Load ID information from provider if not already loaded from local storage
    if (idInformation != null && idData == null) {
      setState(() {
        _selectedIdType = idInformation.idType;
        _idNumberController.text = idInformation.idNumber;
        _issueDateController.text =
            '${idInformation.issueDate.day}/${idInformation.issueDate.month}/${idInformation.issueDate.year}';
        _expiryDateController.text =
            '${idInformation.expiryDate.day}/${idInformation.expiryDate.month}/${idInformation.expiryDate.year}';
      });
    }

    // Load document images from provider if not already loaded from local storage
    if (documents.isNotEmpty) {
      for (final doc in documents) {
        // Handle different document types and image paths
        if (doc.type == 'id_document_front' && doc.frontImagePath != null) {
          // This is a front ID document from backend
          _loadImageFromUrl(doc.frontImagePath!, 'front');
        } else if (doc.type == 'id_document_back' &&
            doc.frontImagePath != null) {
          // This is a back ID document from backend
          _loadImageFromUrl(doc.frontImagePath!, 'back');
        } else if (doc.type == 'selfie_document' &&
            doc.frontImagePath != null) {
          // This is a selfie document from backend
          _loadImageFromUrl(doc.frontImagePath!, 'selfie');
        }
      }
    }
  }

  /// Load image from URL (for backend-stored images)
  void _loadImageFromUrl(String imageUrl, String type) {
    // Validate URL format before setting
    final validatedUrl = _validateAndFixImageUrl(imageUrl);
    if (validatedUrl == null) {
      return;
    }

    setState(() {
      switch (type) {
        case 'front':
          _frontIdImageUrl = validatedUrl;
          break;
        case 'back':
          _backIdImageUrl = validatedUrl;
          break;
        case 'selfie':
          _selfieImageUrl = validatedUrl;
          break;
      }
    });
  }

  /// Validate and fix image URL format
  String? _validateAndFixImageUrl(String imageUrl) {
    try {
      // Check if it's already a valid HTTP/HTTPS URL
      if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
        final uri = Uri.parse(imageUrl);
        if (uri.hasScheme && uri.hasAuthority) {
          return imageUrl;
        }
      }

      // Check if it's a relative path that needs to be converted to absolute URL
      if (imageUrl.startsWith('/media/') || imageUrl.startsWith('media/')) {
        final baseUrl = 'http://192.168.100.210:8001';
        final absoluteUrl = imageUrl.startsWith('/')
            ? '$baseUrl$imageUrl'
            : '$baseUrl/$imageUrl';

        // Validate the constructed URL
        final uri = Uri.parse(absoluteUrl);
        if (uri.hasScheme && uri.hasAuthority) {
          return absoluteUrl;
        }
      }

      // Check for file:// URLs which are invalid for network loading
      if (imageUrl.startsWith('file://')) {
        return null;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Build network image widget with enhanced error handling
  Widget _buildNetworkImage(String imageUrl) {
    // Validate URL before attempting to load
    final uri = Uri.tryParse(imageUrl);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return _buildImageErrorWidget('Invalid URL format');
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        final progress = loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
            : null;

        return Container(
          color: Colors.grey.shade100,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 8),
                Text(
                  'Loading image...',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        // Determine error type for better user feedback
        String errorMessage = 'Failed to load image';
        if (error.toString().contains('No host specified')) {
          errorMessage = 'Invalid URL format';
        } else if (error.toString().contains('Network')) {
          errorMessage = 'Network error';
        } else if (error.toString().contains('404')) {
          errorMessage = 'Image not found';
        } else if (error.toString().contains('timeout')) {
          errorMessage = 'Loading timeout';
        }

        return _buildImageErrorWidget(errorMessage);
      },
    );
  }

  /// Build error widget for failed image loading
  Widget _buildImageErrorWidget([String? errorMessage]) {
    return Container(
      color: Colors.grey.shade200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 32, color: Colors.red),
          const SizedBox(height: 8),
          Text(
            errorMessage ?? 'Failed to load image',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _idNumberController.dispose();
    _issueDateController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String type) async {
    try {
      // Show image source selection dialog using standardized dialog
      final ImageSource? source = await SelectionDialog.showImageSource(
        context: context,
      );
      if (source == null) return;

      // Convert our ImageSource to picker.ImageSource
      final picker.ImageSource pickerSource = source == ImageSource.camera
          ? picker.ImageSource.camera
          : picker.ImageSource.gallery;

      final picker.XFile? image = await _picker.pickImage(
        source: pickerSource,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        // Verify the file exists and is readable
        final file = File(image.path);
        if (await file.exists()) {
          // Check file size (max 10MB)
          final fileSize = await file.length();
          if (fileSize > 10 * 1024 * 1024) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Image file is too large. Please select a smaller image (max 10MB).',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }

          setState(() {
            switch (type) {
              case 'front':
                _frontIdImage = file;
                break;
              case 'back':
                _backIdImage = file;
                break;
              case 'selfie':
                _selfieImage = file;
                break;
            }
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image uploaded successfully!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Failed to access the selected image. Please try again.',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitDocuments() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedIdType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select ID type'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if required documents are available (either as File objects or URLs)
    final hasFrontId =
        _frontIdImage != null ||
        (_frontIdImageUrl != null && _frontIdImageUrl!.isNotEmpty);
    final hasSelfie =
        _selfieImage != null ||
        (_selfieImageUrl != null && _selfieImageUrl!.isNotEmpty);

    if (!hasFrontId || !hasSelfie) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload required documents'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate expiry date is in the future
    if (_expiryDateController.text.trim().isNotEmpty) {
      try {
        final parts = _expiryDateController.text.trim().split('/');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          final expiryDate = DateTime(year, month, day);

          if (expiryDate.isBefore(DateTime.now())) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('ID expiry date must be in the future'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid expiry date format'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final isValidIssueDate = KycDateFormatter.isValidDateFormat(
      _issueDateController.text,
      isBackendFormat: false,
    );

    if (!isValidIssueDate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid issue date format'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final isValidExpiryDate = KycDateFormatter.isValidDateFormat(
      _expiryDateController.text,
      isBackendFormat: false,
    );

    if (!isValidExpiryDate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid expiry date format'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Save consolidated ID and document info to local storage
      final idAndDocumentsData = {
        'id_type': _selectedIdType,
        'id_number': _idNumberController.text.trim(),
        'issue_date': _issueDateController.text.trim(),
        'expiry_date': _expiryDateController.text.trim(),
        'front_id_image': _frontIdImage?.path,
        'back_id_image': _backIdImage?.path,
        'selfie_image': _selfieImage?.path,
      };

      // Save to local storage and update provider state for immediate UI updates
      final success = await ref
          .read(kycProvider.notifier)
          .saveIdAndDocumentsLocally(idAndDocumentsData);

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Documents saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate to verification screen (not final submission)
          Navigator.pushReplacementNamed(context, '/kyc');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save documents. Please try again.'),
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
              'ID Information',
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

              // ID Information Card
              _buildIdInformationCard(),
              const SizedBox(height: 20),

              // Document Upload Card
              _buildDocumentUploadCard(),
              const SizedBox(height: 20),

              // Save Button (only show if not in read-only mode)
              if (!isReadOnly)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submitDocuments,
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

              // Note
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Important Tips',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Ensure all text is clearly visible\n'
                      '• Photos should be well-lit and in focus\n'
                      '• Documents should be valid and not expired\n'
                      '• Selfie should show your face clearly',
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
                '4',
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
                  'Step 4 of 4',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  'ID Information',
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

  Widget _buildIdInformationCard() {
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
            'ID Information',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 20),

          // ID Information Fields - conditional rendering
          if (isReadOnly) ...[
            ReadOnlyDropdownField(
              label: 'ID Type',
              value: _selectedIdType,
              displayValue: _getIdTypeDisplayValue(_selectedIdType),
              icon: Icons.credit_card,
            ),
            ReadOnlyTextField(
              label: 'ID Number',
              value: _idNumberController.text,
              icon: Icons.numbers,
            ),
            ReadOnlyDateField(
              label: 'Issue Date',
              date: _parseDate(_issueDateController.text),
              icon: Icons.calendar_today,
            ),
            ReadOnlyDateField(
              label: 'Expiry Date',
              date: _parseDate(_expiryDateController.text),
              icon: Icons.event,
            ),
          ] else ...[
            // Editable mode
            _buildChoiceDropdownField(
              label: 'ID Type',
              value: _selectedIdType,
              choices: KycChoices.idTypeChoices,
              onChanged: (value) {
                setState(() {
                  _selectedIdType = value!;
                });
              },
              isRequired: true,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _idNumberController,
              label: 'ID Number',
              isRequired: true,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    controller: _issueDateController,
                    label: 'Issue Date',
                    isRequired: true,
                    isIssueDate: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateField(
                    controller: _expiryDateController,
                    label: 'Expiry Date',
                    isRequired: true,
                    isIssueDate: false,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDocumentUploadCard() {
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
            'Document Upload',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 20),

          // Document Upload Fields - conditional rendering
          if (isReadOnly) ...[
            ReadOnlyDocumentField(
              label: 'Front of ID',
              documentPath: _frontIdImage?.path,
              onView: _frontIdImage != null
                  ? () => _viewDocument(_frontIdImage!)
                  : null,
              icon: Icons.credit_card,
            ),
            if (_selectedIdType != 'passport')
              ReadOnlyDocumentField(
                label: 'Back of ID',
                documentPath: _backIdImage?.path,
                onView: _backIdImage != null
                    ? () => _viewDocument(_backIdImage!)
                    : null,
                icon: Icons.credit_card,
              ),
            ReadOnlyDocumentField(
              label: 'Selfie with ID',
              documentPath: _selfieImage?.path,
              onView: _selfieImage != null
                  ? () => _viewDocument(_selfieImage!)
                  : null,
              icon: Icons.person,
            ),
          ] else ...[
            // Editable mode
            _buildDocumentUpload(
              'Front of ID',
              'Upload a clear photo of the front of your ID',
              _frontIdImage,
              () => _pickImage('front'),
              isRequired: true,
              imageUrl: _frontIdImageUrl,
            ),
            const SizedBox(height: 16),

            // Back of ID (if applicable)
            if (_selectedIdType != 'passport') ...[
              _buildDocumentUpload(
                'Back of ID',
                'Upload a clear photo of the back of your ID',
                _backIdImage,
                () => _pickImage('back'),
                imageUrl: _backIdImageUrl,
              ),
              const SizedBox(height: 16),
            ],

            // Selfie with ID
            _buildDocumentUpload(
              'Selfie with ID',
              'Take a selfie holding your ID next to your face',
              _selfieImage,
              () => _pickImage('selfie'),
              isRequired: true,
              imageUrl: _selfieImageUrl,
            ),
          ],
        ],
      ),
    );
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
        labelText: label + (isRequired ? ' *' : ''),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? prefix,
    Widget? suffixIcon,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label + (isRequired ? ' *' : ''),
        labelStyle: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
        prefixText: prefix,
        suffixIcon: suffixIcon,
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
      style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14),
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

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    bool isIssueDate = true,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label + (isRequired ? ' *' : ''),
        labelStyle: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
        suffixIcon: const Icon(Icons.calendar_today),
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
      style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: isIssueDate
              ? DateTime.now()
              : DateTime.now().add(const Duration(days: 365)),
          firstDate: isIssueDate ? DateTime(1900) : DateTime.now(),
          lastDate: isIssueDate ? DateTime.now() : DateTime(2050),
        );
        if (date != null) {
          controller.text =
              '${_pad(date.day)}/${_pad(date.month)}/${date.year}';
        }
      },
      validator: isRequired
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return '$label is required';
              }

              // Additional validation for expiry date
              if (!isIssueDate && value.trim().isNotEmpty) {
                try {
                  final parts = value.trim().split('/');
                  if (parts.length == 3) {
                    final day = int.parse(parts[0]);
                    final month = int.parse(parts[1]);
                    final year = int.parse(parts[2]);
                    final expiryDate = DateTime(year, month, day);

                    if (expiryDate.isBefore(DateTime.now())) {
                      return 'ID must not be expired';
                    }
                  }
                } catch (e) {
                  return 'Invalid date format';
                }
              }

              return null;
            }
          : null,
    );
  }

  Widget _buildDocumentUpload(
    String title,
    String description,
    File? image,
    VoidCallback onTap, {
    bool isRequired = false,
    String? imageUrl,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),

        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: (image != null || imageUrl != null)
                    ? AppTheme.primaryColor
                    : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: (image != null || imageUrl != null)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: image != null
                        ? Image.file(
                            image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildImageErrorWidget();
                            },
                          )
                        : _buildNetworkImage(imageUrl!),
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 32, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Tap to take photo',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
          ),
        ),

        if (image != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 16),
              const SizedBox(width: 4),
              const Text(
                'Image uploaded',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 12,
                  color: Colors.green,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onTap,
                child: const Text(
                  'Retake',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// Get display value for ID type
  String _getIdTypeDisplayValue(String idTypeValue) {
    final choice = KycChoices.idTypeChoices.firstWhere(
      (choice) => choice['value'] == idTypeValue,
      orElse: () => {'label': idTypeValue},
    );
    return choice['label'] ?? idTypeValue;
  }

  /// Parse date string in DD/MM/YYYY format to DateTime
  DateTime? _parseDate(String dateString) {
    if (dateString.isEmpty) return null;
    try {
      final parts = dateString.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      // Return null if parsing fails
    }
    return null;
  }

  /// View document in full screen
  void _viewDocument(File document) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.file(
                  document,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Failed to load document',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 16,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
