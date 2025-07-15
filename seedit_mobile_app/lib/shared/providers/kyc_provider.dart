import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/kyc_model.dart';
import '../../core/services/kyc_service.dart';
import 'auth_provider.dart';

// KYC service provider
final kycServiceProvider = Provider<KycService>((ref) => KycService());

// KYC state provider
final kycStateProvider = StateNotifierProvider<KycNotifier, KycState>((ref) {
  return KycNotifier(
    ref.read(kycServiceProvider),
    ref.read(authStateProvider.notifier),
  );
});

// Current KYC application provider
final currentKycApplicationProvider = Provider<KycApplication?>((ref) {
  final kycState = ref.watch(kycStateProvider);
  return kycState.application;
});

// KYC loading provider
final kycLoadingProvider = Provider<bool>((ref) {
  final kycState = ref.watch(kycStateProvider);
  return kycState.isLoading;
});

// KYC error provider
final kycErrorProvider = Provider<String?>((ref) {
  final kycState = ref.watch(kycStateProvider);
  return kycState.error;
});

// KYC completion percentage provider
final kycCompletionProvider = Provider<double>((ref) {
  final application = ref.watch(currentKycApplicationProvider);
  return application?.completionPercentage ?? 0.0;
});

// KYC status provider
final kycStatusProvider = Provider<KycStatus?>((ref) {
  final application = ref.watch(currentKycApplicationProvider);
  return application?.status;
});

// Required documents provider
final requiredDocumentsProvider = Provider<List<DocumentType>>((ref) {
  final application = ref.watch(currentKycApplicationProvider);
  if (application == null) return [];
  
  final kycService = ref.read(kycServiceProvider);
  return kycService.getRequiredDocuments(application.level);
});

class KycState {
  final KycApplication? application;
  final bool isLoading;
  final bool isUploading;
  final String? error;
  final Map<DocumentType, bool> uploadingDocuments;

  KycState({
    this.application,
    this.isLoading = false,
    this.isUploading = false,
    this.error,
    this.uploadingDocuments = const {},
  });

  KycState copyWith({
    KycApplication? application,
    bool? isLoading,
    bool? isUploading,
    String? error,
    Map<DocumentType, bool>? uploadingDocuments,
  }) {
    return KycState(
      application: application ?? this.application,
      isLoading: isLoading ?? this.isLoading,
      isUploading: isUploading ?? this.isUploading,
      error: error,
      uploadingDocuments: uploadingDocuments ?? this.uploadingDocuments,
    );
  }
}

class KycNotifier extends StateNotifier<KycState> {
  final KycService _kycService;
  final AuthNotifier _authNotifier;

  KycNotifier(this._kycService, this._authNotifier) : super(KycState());

  // Load KYC application
  Future<void> loadKycApplication(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final application = await _kycService.getKycApplication(userId);
      state = state.copyWith(
        application: application,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('Load KYC application error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Create new KYC application
  Future<void> createKycApplication(String userId, KycLevel level) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final application = await _kycService.createKycApplication(userId, level);
      state = state.copyWith(
        application: application,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('Create KYC application error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Update personal info
  Future<void> updatePersonalInfo(PersonalInfo personalInfo) async {
    if (state.application == null) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final updatedApplication = state.application!.copyWith(
        personalInfo: personalInfo,
        updatedAt: DateTime.now(),
      );
      
      final savedApplication = await _kycService.updateKycApplication(updatedApplication);
      state = state.copyWith(
        application: savedApplication,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('Update personal info error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Update identity documents
  Future<void> updateIdentityDocuments(IdentityDocuments identityDocuments) async {
    if (state.application == null) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final updatedApplication = state.application!.copyWith(
        identityDocuments: identityDocuments,
        updatedAt: DateTime.now(),
      );
      
      final savedApplication = await _kycService.updateKycApplication(updatedApplication);
      state = state.copyWith(
        application: savedApplication,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('Update identity documents error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Update address verification
  Future<void> updateAddressVerification(AddressVerification addressVerification) async {
    if (state.application == null) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final updatedApplication = state.application!.copyWith(
        addressVerification: addressVerification,
        updatedAt: DateTime.now(),
      );
      
      final savedApplication = await _kycService.updateKycApplication(updatedApplication);
      state = state.copyWith(
        application: savedApplication,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('Update address verification error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Update financial info
  Future<void> updateFinancialInfo(FinancialInfo financialInfo) async {
    if (state.application == null) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final updatedApplication = state.application!.copyWith(
        financialInfo: financialInfo,
        updatedAt: DateTime.now(),
      );
      
      final savedApplication = await _kycService.updateKycApplication(updatedApplication);
      state = state.copyWith(
        application: savedApplication,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('Update financial info error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Update next of kin
  Future<void> updateNextOfKin(NextOfKin nextOfKin) async {
    if (state.application == null) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final updatedApplication = state.application!.copyWith(
        nextOfKin: nextOfKin,
        updatedAt: DateTime.now(),
      );
      
      final savedApplication = await _kycService.updateKycApplication(updatedApplication);
      state = state.copyWith(
        application: savedApplication,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('Update next of kin error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Upload document from camera
  Future<void> uploadDocumentFromCamera(DocumentType type) async {
    if (state.application == null) return;
    
    try {
      final imageFile = await _kycService.pickImageFromCamera();
      if (imageFile != null) {
        await _uploadDocument(type, imageFile);
      }
    } catch (e) {
      debugPrint('Upload from camera error: $e');
      _setDocumentUploading(type, false);
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  // Upload document from gallery
  Future<void> uploadDocumentFromGallery(DocumentType type) async {
    if (state.application == null) return;
    
    try {
      final imageFile = await _kycService.pickImageFromGallery();
      if (imageFile != null) {
        await _uploadDocument(type, imageFile);
      }
    } catch (e) {
      debugPrint('Upload from gallery error: $e');
      _setDocumentUploading(type, false);
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  // Upload document from file picker
  Future<void> uploadDocumentFromFile(DocumentType type) async {
    if (state.application == null) return;
    
    try {
      final file = await _kycService.pickFile();
      if (file != null) {
        await _uploadDocument(type, file);
      }
    } catch (e) {
      debugPrint('Upload from file error: $e');
      _setDocumentUploading(type, false);
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  // Private method to handle document upload
  Future<void> _uploadDocument(DocumentType type, XFile file) async {
    _setDocumentUploading(type, true);
    
    try {
      final document = await _kycService.uploadDocument(
        state.application!.id,
        type,
        file,
      );
      
      // Add document to application
      final updatedDocuments = [...state.application!.documents];
      
      // Remove existing document of same type
      updatedDocuments.removeWhere((doc) => doc.type == type);
      
      // Add new document
      updatedDocuments.add(document);
      
      final updatedApplication = state.application!.copyWith(
        documents: updatedDocuments,
        updatedAt: DateTime.now(),
      );
      
      state = state.copyWith(application: updatedApplication);
      _setDocumentUploading(type, false);
    } catch (e) {
      debugPrint('Upload document error: $e');
      _setDocumentUploading(type, false);
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  // Submit KYC application
  Future<void> submitKycApplication() async {
    if (state.application == null) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final submittedApplication = await _kycService.submitKycApplication(
        state.application!.id,
      );
      
      state = state.copyWith(
        application: submittedApplication,
        isLoading: false,
      );
      
      // Refresh auth user data
      await _authNotifier.refreshUser();
    } catch (e) {
      debugPrint('Submit KYC application error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Delete document
  Future<void> deleteDocument(String documentId, DocumentType type) async {
    if (state.application == null) return;
    
    try {
      await _kycService.deleteDocument(state.application!.id, documentId);
      
      // Remove document from application
      final updatedDocuments = state.application!.documents
          .where((doc) => doc.id != documentId)
          .toList();
      
      final updatedApplication = state.application!.copyWith(
        documents: updatedDocuments,
        updatedAt: DateTime.now(),
      );
      
      state = state.copyWith(application: updatedApplication);
    } catch (e) {
      debugPrint('Delete document error: $e');
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  // Helper methods
  void _setDocumentUploading(DocumentType type, bool uploading) {
    final updatedUploading = Map<DocumentType, bool>.from(state.uploadingDocuments);
    if (uploading) {
      updatedUploading[type] = true;
    } else {
      updatedUploading.remove(type);
    }
    
    state = state.copyWith(
      uploadingDocuments: updatedUploading,
      isUploading: updatedUploading.isNotEmpty,
    );
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Refresh KYC application
  Future<void> refreshKycApplication() async {
    if (state.application != null) {
      await loadKycApplication(state.application!.userId);
    }
  }

  // Check if document is uploaded
  bool isDocumentUploaded(DocumentType type) {
    if (state.application == null) return false;
    return state.application!.documents.any((doc) => doc.type == type);
  }

  // Check if document is uploading
  bool isDocumentUploading(DocumentType type) {
    return state.uploadingDocuments[type] == true;
  }

  // Get document by type
  KycDocument? getDocument(DocumentType type) {
    if (state.application == null) return null;
    
    try {
      return state.application!.documents.firstWhere((doc) => doc.type == type);
    } catch (e) {
      return null;
    }
  }
}
