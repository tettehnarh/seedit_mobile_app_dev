import 'package:flutter/material.dart';
import '../../../core/services/session_service.dart';

class SessionSettingsCard extends StatelessWidget {
  final SessionInfo sessionInfo;
  final Function(int) onTimeoutChanged;
  final Function(bool) onAutoLockChanged;
  final Function(bool) onLockOnBackgroundChanged;

  const SessionSettingsCard({
    super.key,
    required this.sessionInfo,
    required this.onTimeoutChanged,
    required this.onAutoLockChanged,
    required this.onLockOnBackgroundChanged,
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
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.timer,
                    color: theme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Session Management',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Current status: ${sessionInfo.statusText}',
                        style: TextStyle(
                          fontSize: 14,
                          color: _getStatusColor(sessionInfo.statusText),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Session timeout setting
            _buildTimeoutSetting(context),
            
            const SizedBox(height: 16),
            
            // Auto-lock setting
            _buildSwitchSetting(
              context,
              'Auto-lock',
              'Automatically lock the app after inactivity',
              sessionInfo.autoLockEnabled,
              onAutoLockChanged,
              Icons.lock_clock,
            ),
            
            const SizedBox(height: 16),
            
            // Lock on background setting
            _buildSwitchSetting(
              context,
              'Lock on background',
              'Lock the app when it goes to background',
              sessionInfo.lockOnBackgroundEnabled,
              onLockOnBackgroundChanged,
              Icons.visibility_off,
            ),
            
            if (sessionInfo.isActive) ...[
              const SizedBox(height: 16),
              _buildSessionStatus(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeoutSetting(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.schedule,
              size: 20,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
            const Text(
              'Session timeout',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'App will lock after ${sessionInfo.timeoutMinutes} minutes of inactivity',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [5, 10, 15, 30, 60].map((minutes) {
              final isSelected = sessionInfo.timeoutMinutes == minutes;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text('${minutes}m'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      onTimeoutChanged(minutes);
                    }
                  },
                  selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  checkmarkColor: Theme.of(context).primaryColor,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchSetting(
    BuildContext context,
    String title,
    String description,
    bool value,
    Function(bool) onChanged,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSessionStatus() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getSessionStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getSessionStatusColor().withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            _getSessionStatusIcon(),
            color: _getSessionStatusColor(),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Session',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getSessionStatusColor(),
                  ),
                ),
                Text(
                  sessionInfo.remainingTimeText,
                  style: TextStyle(
                    fontSize: 11,
                    color: _getSessionStatusColor(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'expiring soon':
        return Colors.orange;
      case 'expired':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getSessionStatusColor() {
    if (sessionInfo.remainingTimeMinutes <= 2) {
      return Colors.orange;
    } else if (sessionInfo.remainingTimeMinutes <= 0) {
      return Colors.red;
    }
    return Colors.green;
  }

  IconData _getSessionStatusIcon() {
    if (sessionInfo.remainingTimeMinutes <= 2) {
      return Icons.warning;
    } else if (sessionInfo.remainingTimeMinutes <= 0) {
      return Icons.error;
    }
    return Icons.check_circle;
  }
}

class SessionStatusIndicator extends StatelessWidget {
  final SessionInfo sessionInfo;
  final bool showDetails;

  const SessionStatusIndicator({
    super.key,
    required this.sessionInfo,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String text;

    if (!sessionInfo.isActive) {
      color = Colors.grey;
      icon = Icons.lock;
      text = 'Locked';
    } else if (sessionInfo.isExpired) {
      color = Colors.red;
      icon = Icons.error;
      text = 'Expired';
    } else if (sessionInfo.remainingTimeMinutes <= 2) {
      color = Colors.orange;
      icon = Icons.warning;
      text = 'Expiring';
    } else {
      color = Colors.green;
      icon = Icons.check_circle;
      text = 'Active';
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
          if (showDetails && sessionInfo.isActive) ...[
            const SizedBox(width: 4),
            Text(
              '(${sessionInfo.remainingTimeMinutes}m)',
              style: TextStyle(
                fontSize: 10,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class SessionTimeoutSelector extends StatelessWidget {
  final int currentTimeout;
  final Function(int) onTimeoutChanged;
  final List<int> timeoutOptions;

  const SessionTimeoutSelector({
    super.key,
    required this.currentTimeout,
    required this.onTimeoutChanged,
    this.timeoutOptions = const [5, 10, 15, 30, 60],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Session Timeout',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose how long the app stays unlocked when inactive',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: timeoutOptions.map((minutes) {
            final isSelected = currentTimeout == minutes;
            return ChoiceChip(
              label: Text('${minutes}m'),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onTimeoutChanged(minutes);
                }
              },
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected 
                    ? Theme.of(context).primaryColor 
                    : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class SessionQuickActions extends StatelessWidget {
  final SessionInfo sessionInfo;
  final VoidCallback? onExtendSession;
  final VoidCallback? onLockNow;

  const SessionQuickActions({
    super.key,
    required this.sessionInfo,
    this.onExtendSession,
    this.onLockNow,
  });

  @override
  Widget build(BuildContext context) {
    if (!sessionInfo.isActive) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        if (sessionInfo.remainingTimeMinutes <= 5 && onExtendSession != null)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onExtendSession,
              icon: const Icon(Icons.access_time, size: 16),
              label: const Text('Extend'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: const BorderSide(color: Colors.orange),
              ),
            ),
          ),
        if (sessionInfo.remainingTimeMinutes <= 5 && onExtendSession != null && onLockNow != null)
          const SizedBox(width: 8),
        if (onLockNow != null)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onLockNow,
              icon: const Icon(Icons.lock, size: 16),
              label: const Text('Lock Now'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
      ],
    );
  }
}
