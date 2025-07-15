import 'package:flutter/material.dart';
import '../../../core/services/biometric_service.dart';

class BiometricSettingsCard extends StatelessWidget {
  final BiometricCapabilities capabilities;
  final bool isEnabled;
  final Function(bool) onToggle;

  const BiometricSettingsCard({
    super.key,
    required this.capabilities,
    required this.isEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: capabilities.isAvailable 
                        ? theme.primaryColor.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getBiometricIcon(),
                    color: capabilities.isAvailable 
                        ? theme.primaryColor 
                        : Colors.grey,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        capabilities.displayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getStatusText(),
                        style: TextStyle(
                          fontSize: 14,
                          color: _getStatusColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
                if (capabilities.isAvailable)
                  Switch(
                    value: isEnabled,
                    onChanged: onToggle,
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            if (!capabilities.isAvailable) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      color: Colors.orange.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Biometric authentication is not available on this device',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (isEnabled) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your account is protected with ${capabilities.displayName}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Enable ${capabilities.displayName} for quick and secure access',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            if (capabilities.hasAnyBiometric) ...[
              const SizedBox(height: 16),
              _buildBiometricTypes(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBiometricTypes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available biometric types:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            if (capabilities.hasFaceId)
              _buildBiometricChip('Face ID', Icons.face, Colors.blue),
            if (capabilities.hasTouchId)
              _buildBiometricChip('Touch ID', Icons.fingerprint, Colors.green),
            if (capabilities.hasIris)
              _buildBiometricChip('Iris', Icons.visibility, Colors.purple),
            if (capabilities.availableBiometrics.any((type) => 
                type.name == 'strong' || type.name == 'weak'))
              _buildBiometricChip('Device Lock', Icons.lock, Colors.orange),
          ],
        ),
      ],
    );
  }

  Widget _buildBiometricChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getBiometricIcon() {
    if (capabilities.hasFaceId) {
      return Icons.face;
    } else if (capabilities.hasTouchId) {
      return Icons.fingerprint;
    } else if (capabilities.hasIris) {
      return Icons.visibility;
    }
    return Icons.security;
  }

  String _getStatusText() {
    if (!capabilities.isAvailable) {
      return 'Not available on this device';
    } else if (isEnabled) {
      return 'Enabled and active';
    } else {
      return 'Available but not enabled';
    }
  }

  Color _getStatusColor(BuildContext context) {
    if (!capabilities.isAvailable) {
      return Colors.grey;
    } else if (isEnabled) {
      return Colors.green;
    } else {
      return Theme.of(context).primaryColor;
    }
  }
}

class BiometricQuickSetup extends StatelessWidget {
  final BiometricCapabilities capabilities;
  final VoidCallback onSetup;

  const BiometricQuickSetup({
    super.key,
    required this.capabilities,
    required this.onSetup,
  });

  @override
  Widget build(BuildContext context) {
    if (!capabilities.isAvailable) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getBiometricIcon(),
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Setup',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Text(
                  'Enable ${capabilities.displayName} in one tap',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onSetup,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Enable',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getBiometricIcon() {
    if (capabilities.hasFaceId) {
      return Icons.face;
    } else if (capabilities.hasTouchId) {
      return Icons.fingerprint;
    } else if (capabilities.hasIris) {
      return Icons.visibility;
    }
    return Icons.security;
  }
}

class BiometricStatusIndicator extends StatelessWidget {
  final bool isEnabled;
  final bool isAvailable;
  final String displayName;

  const BiometricStatusIndicator({
    super.key,
    required this.isEnabled,
    required this.isAvailable,
    required this.displayName,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String text;

    if (!isAvailable) {
      color = Colors.grey;
      icon = Icons.block;
      text = 'Not Available';
    } else if (isEnabled) {
      color = Colors.green;
      icon = Icons.check_circle;
      text = 'Enabled';
    } else {
      color = Colors.orange;
      icon = Icons.warning;
      text = 'Disabled';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
