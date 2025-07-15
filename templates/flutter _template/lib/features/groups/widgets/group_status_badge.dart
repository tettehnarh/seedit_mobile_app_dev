import 'package:flutter/material.dart';

class GroupStatusBadge extends StatelessWidget {
  final String status;
  final String statusDisplay;
  final bool isActive;

  const GroupStatusBadge({
    super.key,
    required this.status,
    required this.statusDisplay,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show badge for active groups
    if (isActive) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusBorderColor(status), width: 1),
      ),
      child: Text(
        statusDisplay,
        style: TextStyle(
          color: _getStatusTextColor(status),
          fontSize: 10,
          fontWeight: FontWeight.w600,
          fontFamily: 'Montserrat',
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending_activation':
        return Colors.orange.shade50;
      case 'suspended':
        return Colors.red.shade50;
      case 'dissolved':
        return Colors.grey.shade100;
      default:
        return Colors.grey.shade50;
    }
  }

  Color _getStatusBorderColor(String status) {
    switch (status) {
      case 'pending_activation':
        return Colors.orange.shade200;
      case 'suspended':
        return Colors.red.shade200;
      case 'dissolved':
        return Colors.grey.shade300;
      default:
        return Colors.grey.shade200;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'pending_activation':
        return Colors.orange.shade700;
      case 'suspended':
        return Colors.red.shade700;
      case 'dissolved':
        return Colors.grey.shade600;
      default:
        return Colors.grey.shade600;
    }
  }
}
