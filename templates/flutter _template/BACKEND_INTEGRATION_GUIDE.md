# Backend Integration Guide

## 🔗 **Django Backend Integration**

### **1. API Configuration**

Update the API base URL in `lib/core/constants/api_constants.dart`:

```dart
class ApiConstants {
  // Update this to your Django backend URL
  static const String baseUrl = 'http://your-django-backend.com/api';
  
  // Or for local development:
  // static const String baseUrl = 'http://localhost:8000/api';
}
```

### **2. Authentication Integration**

The auth service in `lib/features/auth/services/auth_service.dart` is ready for Django integration:

```dart
// Current endpoints expected:
POST /api/auth/login/
POST /api/auth/register/
POST /api/auth/forgot-password/
GET  /api/auth/user/
POST /api/auth/refresh/
```

**Expected Request/Response Format:**

```json
// Login Request
{
  "email": "user@example.com",
  "password": "password123"
}

// Login Response
{
  "success": true,
  "user": {
    "id": "123",
    "email": "user@example.com",
    "first_name": "John",
    "last_name": "Doe",
    "phone_number": "+1234567890",
    "kyc_status": "approved"
  },
  "access_token": "jwt_token_here",
  "refresh_token": "refresh_token_here"
}
```

### **3. KYC Integration**

KYC endpoints expected:

```dart
POST /api/kyc/personal-info/
POST /api/kyc/financial-info/
POST /api/kyc/documents/
GET  /api/kyc/status/
```

### **4. Investment Data Integration**

Investment endpoints expected:

```dart
GET  /api/funds/
GET  /api/investments/portfolio/
GET  /api/investments/transactions/
POST /api/investments/invest/
```

## 🔧 **Quick Integration Steps**

### **Step 1: Update API Base URL**
```dart
// lib/core/constants/api_constants.dart
static const String baseUrl = 'YOUR_DJANGO_URL/api';
```

### **Step 2: Test Authentication**
```dart
// Test login with real credentials
final authProvider = ref.read(authProvider.notifier);
final success = await authProvider.signIn(email, password);
```

### **Step 3: Add Error Handling**
```dart
// Update auth service to handle Django error responses
if (response.statusCode == 400) {
  return {
    'success': false,
    'error': data['message'] ?? 'Invalid credentials',
  };
}
```

### **Step 4: Update User Model**
Ensure the UserModel matches your Django user serializer:

```dart
// lib/features/auth/models/user_model.dart
factory UserModel.fromJson(Map<String, dynamic> json) {
  return UserModel(
    id: json['id']?.toString() ?? '',
    email: json['email'] ?? '',
    firstName: json['first_name'] ?? '',
    lastName: json['last_name'] ?? '',
    phoneNumber: json['phone_number'],
    kycStatus: json['kyc_status'] ?? 'pending',
    // Add other fields as needed
  );
}
```

## 🧪 **Testing Backend Integration**

### **1. Test Authentication Flow**
```bash
# Test login endpoint
curl -X POST http://your-backend/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

### **2. Test KYC Endpoints**
```bash
# Test KYC status
curl -X GET http://your-backend/api/kyc/status/ \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### **3. Test Investment Data**
```bash
# Test funds listing
curl -X GET http://your-backend/api/funds/ \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## 🔐 **Security Considerations**

### **1. JWT Token Management**
```dart
// Add token refresh logic in auth service
Future<void> _refreshTokenIfNeeded() async {
  // Check if token is expired
  // Refresh if needed
  // Update stored token
}
```

### **2. API Request Interceptors**
```dart
// Add HTTP interceptor for automatic token attachment
class ApiInterceptor {
  static Future<http.Response> authenticatedRequest(
    String url, {
    required String method,
    Map<String, dynamic>? body,
  }) async {
    final token = await StorageUtils.getAuthToken();
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    
    // Make request with headers
  }
}
```

### **3. Error Handling**
```dart
// Centralized error handling
class ApiErrorHandler {
  static String getErrorMessage(int statusCode, Map<String, dynamic> data) {
    switch (statusCode) {
      case 401:
        return 'Session expired. Please sign in again.';
      case 403:
        return 'Access denied.';
      case 404:
        return 'Resource not found.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return data['message'] ?? 'An error occurred.';
    }
  }
}
```

## 📱 **Production Deployment**

### **1. Environment Configuration**
```dart
// lib/core/config/environment.dart
class Environment {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.seedit.com',
  );
  
  static const bool isProduction = bool.fromEnvironment('PRODUCTION');
}
```

### **2. Build Commands**
```bash
# Development build
flutter build ios --dart-define=API_BASE_URL=http://localhost:8000/api

# Production build
flutter build ios --dart-define=API_BASE_URL=https://api.seedit.com --dart-define=PRODUCTION=true
```

### **3. App Store Preparation**
```bash
# Build for App Store
flutter build ios --release
```

## 🔄 **Next Steps After Integration**

1. **Test all user flows** with real backend data
2. **Add comprehensive error handling** for network issues
3. **Implement offline caching** for better UX
4. **Add push notifications** for real-time updates
5. **Performance testing** with real data loads
6. **Security audit** of API communications
7. **User acceptance testing** with stakeholders

## 📞 **Support**

For integration support:
- Check Django backend API documentation
- Test endpoints with Postman/curl first
- Verify JWT token format and expiration
- Ensure CORS is configured for mobile app domain
- Check Django settings for mobile app permissions

The Flutter app is **ready for backend integration** - all the necessary providers, services, and UI components are in place!
