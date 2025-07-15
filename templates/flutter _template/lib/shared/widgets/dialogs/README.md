# Standardized Dialog Components

This directory contains a comprehensive set of reusable dialog components that provide consistent UI/UX across the SeedIt Mobile App. All dialogs follow the app's design system with AppTheme colors, Montserrat typography, and standardized spacing.

## 🎨 **Design Principles**

- **Consistency**: All dialogs use the same visual design language
- **Accessibility**: Proper contrast ratios and touch targets (minimum 44px)
- **Responsiveness**: Adapts to different screen sizes with max-width constraints
- **Theming**: Uses AppTheme.primaryColor (#08857C) and Montserrat font family
- **Usability**: Clear actions, intuitive interactions, and proper focus management

## 📦 **Available Components**

### **Base Components**
- `BaseDialog` - Foundation dialog with consistent styling and layout
- `DialogButton` - Standardized button component with multiple types

### **Specialized Dialogs**
- `ConfirmationDialog` - User confirmations and destructive actions
- `MessageDialog` - Success, error, warning, and info messages
- `SelectionDialog` - Choosing from a list of options
- `LoadingDialog` - Progress indication during async operations

### **Utility Classes**
- `AppDialogs` - Quick access to common dialog patterns
- `LoadingDialogManager` - Automatic loading dialog management

## 🚀 **Quick Start**

Import the dialogs library:
```dart
import 'package:seedit_mobile_app/shared/widgets/dialogs/dialogs.dart';
```

## 📋 **Usage Examples**

### **1. Error Messages**
```dart
// Simple error
await AppDialogs.showError(
  context: context,
  message: 'An account with this email already exists.',
);

// Detailed error with action items
await MessageDialog.showError(
  context: context,
  title: 'Registration Failed',
  message: 'Please fix the following issues:',
  actionItems: [
    'Email address is already in use',
    'Password must be at least 8 characters',
    'Phone number format is invalid',
  ],
);
```

### **2. Success Messages**
```dart
// Simple success
await AppDialogs.showSuccess(
  context: context,
  message: 'Group created successfully!',
);

// Success with details
await MessageDialog.showSuccess(
  context: context,
  title: 'Upload Complete',
  message: 'Your documents have been uploaded successfully.',
  details: 'Your KYC application will be reviewed within 2-3 business days.',
);
```

### **3. Confirmation Dialogs**
```dart
// Simple confirmation
final confirmed = await AppDialogs.confirm(
  context: context,
  title: 'Leave Group',
  message: 'Are you sure you want to leave this group?',
);

// Destructive confirmation
final confirmed = await AppDialogs.confirmDelete(
  context: context,
  itemName: 'investment group',
  details: 'All contributions and data will be permanently lost.',
);

// Custom confirmation
final confirmed = await ConfirmationDialog.show(
  context: context,
  title: 'Activate Group',
  message: 'Are you ready to activate this group?',
  confirmText: 'Activate',
  cancelText: 'Not Yet',
  details: 'Once activated, members can join and start contributing.',
);
```

### **4. Selection Dialogs**
```dart
// Image source selection
final source = await SelectionDialog.showImageSource(
  context: context,
);

// Custom selection
final selectedFund = await SelectionDialog.show<Fund>(
  context: context,
  title: 'Choose Investment Fund',
  subtitle: 'Select the fund for your group investment',
  options: funds.map((fund) => SelectionOption<Fund>(
    value: fund,
    title: fund.name,
    subtitle: 'Expected return: ${fund.expectedReturn}%',
    icon: Icons.trending_up,
  )).toList(),
);

// String options
final priority = await SelectionDialog.showStringOptions(
  context: context,
  title: 'Set Priority',
  options: ['High', 'Medium', 'Low'],
  selectedValue: currentPriority,
);
```

### **5. Loading Dialogs**
```dart
// Simple loading
LoadingDialogManager.show(
  context: context,
  title: 'Processing',
  message: 'Please wait while we process your request...',
);

// Later dismiss
LoadingDialogManager.dismiss();

// Upload with progress
await LoadingDialog.showUpload(
  context: context,
  fileName: 'passport.jpg',
  progress: 0.75, // 75% complete
  showCancel: true,
);

// Network request
await LoadingDialog.showNetworkRequest(
  context: context,
  title: 'Syncing Data',
  message: 'Downloading latest information...',
);
```

### **6. Warning Messages**
```dart
// Feature unavailable
await AppDialogs.showFeatureUnavailable(
  context: context,
  featureName: 'Investment Portfolio',
  customMessage: 'Complete your KYC verification to access this feature.',
);

// Custom warning
await MessageDialog.showWarning(
  context: context,
  title: 'Unsaved Changes',
  message: 'You have unsaved changes that will be lost.',
  actionItems: [
    'Save your changes before leaving',
    'Or discard changes to continue',
  ],
);
```

### **7. Info Messages**
```dart
// App maintenance
await AppDialogs.showMaintenance(
  context: context,
  estimatedTime: '2 hours',
);

// Custom info
await MessageDialog.showInfo(
  context: context,
  title: 'Group Activation Requirements',
  message: 'To activate your group, you need:',
  actionItems: [
    'Exactly 3 group admins',
    'At least one completed contribution',
    'Approved group profile',
  ],
);
```

## 🎯 **Button Types**

### **DialogButtonType.primary**
- Filled button with primary color
- Use for main actions (Save, Confirm, OK)

### **DialogButtonType.secondary** 
- Outlined button with primary color border
- Use for secondary actions (Edit, View Details)

### **DialogButtonType.text**
- Text-only button
- Use for cancel actions or less important options

### **DialogButtonType.destructive**
- Red filled button
- Use for dangerous actions (Delete, Remove)

## 🔧 **Customization**

### **Custom Dialog with BaseDialog**
```dart
await BaseDialog.show(
  context: context,
  dialog: BaseDialog(
    title: 'Custom Dialog',
    titleIcon: Icons.star,
    titleColor: Colors.purple,
    showCloseButton: true,
    content: YourCustomWidget(),
    actions: [
      DialogButton(
        text: 'Cancel',
        type: DialogButtonType.text,
        onPressed: () => Navigator.pop(context),
      ),
      DialogButton(
        text: 'Save',
        type: DialogButtonType.primary,
        icon: Icons.save,
        onPressed: () {
          // Handle save
          Navigator.pop(context, true);
        },
      ),
    ],
  ),
);
```

## 🎨 **Visual Specifications**

### **Colors**
- Primary: `AppTheme.primaryColor` (#08857C)
- Success: `Colors.green`
- Error: `Colors.red`
- Warning: `Colors.orange`
- Info: `AppTheme.primaryColor`

### **Typography**
- All text uses `Montserrat` font family
- Title: 18px, FontWeight.w600
- Body: 16px, FontWeight.normal
- Button: 14px, FontWeight.w600

### **Spacing**
- Dialog padding: 24px
- Content padding: 16px vertical
- Button spacing: 12px horizontal
- Section spacing: 16px vertical

### **Dimensions**
- Max dialog width: 400px
- Max dialog height: 80% of screen height
- Button minimum size: 80px × 40px
- Border radius: 16px (dialog), 8px (buttons)

## 🔍 **Best Practices**

1. **Use appropriate dialog types** for different scenarios
2. **Keep messages concise** and actionable
3. **Provide clear button labels** that describe the action
4. **Use destructive styling** only for irreversible actions
5. **Include helpful details** when users need more context
6. **Test on different screen sizes** to ensure responsiveness
7. **Follow accessibility guidelines** for contrast and touch targets

## 🚫 **Migration from Old Dialogs**

Replace old `showDialog` + `AlertDialog` patterns:

```dart
// ❌ Old way
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Error'),
    content: Text('Something went wrong'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text('OK'),
      ),
    ],
  ),
);

// ✅ New way
await AppDialogs.showError(
  context: context,
  message: 'Something went wrong',
);
```

This standardized approach ensures consistency, reduces code duplication, and provides a better user experience across the entire app.
