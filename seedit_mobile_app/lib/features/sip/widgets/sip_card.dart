import 'package:flutter/material.dart';
import '../../../shared/models/sip_model.dart';

class SIPCard extends StatelessWidget {
  final SIPPlan sip;
  final VoidCallback? onTap;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onCancel;
  final bool isCompact;

  const SIPCard({
    super.key,
    required this.sip,
    this.onTap,
    this.onPause,
    this.onResume,
    this.onCancel,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with SIP name and status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      sip.planName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: isCompact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusBadge(),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Fund name
              Text(
                sip.fundName,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // SIP details
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      'Amount',
                      sip.formattedAmount,
                      Icons.currency_rupee,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      'Frequency',
                      sip.frequencyText,
                      Icons.schedule,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      'Invested',
                      sip.formattedTotalInvested,
                      Icons.trending_up,
                    ),
                  ),
                ],
              ),
              
              if (!isCompact) ...[
                const SizedBox(height: 12),
                
                // Progress bar (if has max installments)
                if (sip.hasMaxInstallments) _buildProgressBar(),
                
                const SizedBox(height: 12),
                
                // Next execution date
                if (sip.nextExecutionDate != null)
                  Row(
                    children: [
                      Icon(
                        Icons.event,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Next: ${_formatDate(sip.nextExecutionDate!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${sip.completedInstallments} installments',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                
                const SizedBox(height: 12),
                
                // Action buttons
                Row(
                  children: [
                    if (sip.isActive && onPause != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onPause,
                          icon: const Icon(Icons.pause, size: 16),
                          label: const Text('Pause'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    
                    if (sip.isPaused && onResume != null)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onResume,
                          icon: const Icon(Icons.play_arrow, size: 16),
                          label: const Text('Resume'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    
                    if ((sip.isActive || sip.isPaused) && onCancel != null) ...[
                      if (onPause != null || onResume != null) const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onCancel,
                          icon: const Icon(Icons.stop, size: 16),
                          label: const Text('Cancel'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String label;
    
    switch (sip.status) {
      case SIPStatus.active:
        color = Colors.green;
        label = 'Active';
        break;
      case SIPStatus.paused:
        color = Colors.orange;
        label = 'Paused';
        break;
      case SIPStatus.completed:
        color = Colors.blue;
        label = 'Completed';
        break;
      case SIPStatus.cancelled:
        color = Colors.red;
        label = 'Cancelled';
        break;
      case SIPStatus.draft:
        color = Colors.grey;
        label = 'Draft';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${sip.progressPercentage.toStringAsFixed(1)}% completed',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${sip.remainingInstallments} remaining',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: sip.progressPercentage / 100,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            sip.isCompleted ? Colors.green : Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class SIPListTile extends StatelessWidget {
  final SIPPlan sip;
  final VoidCallback? onTap;

  const SIPListTile({
    super.key,
    required this.sip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: _getStatusColor(sip.status).withOpacity(0.1),
        child: Icon(
          Icons.schedule,
          color: _getStatusColor(sip.status),
          size: 20,
        ),
      ),
      title: Text(
        sip.planName,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sip.fundName,
            style: const TextStyle(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '${sip.formattedAmount} • ${sip.frequencyText}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            sip.formattedTotalInvested,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          Text(
            '${sip.completedInstallments} installments',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(SIPStatus status) {
    switch (status) {
      case SIPStatus.active:
        return Colors.green;
      case SIPStatus.paused:
        return Colors.orange;
      case SIPStatus.completed:
        return Colors.blue;
      case SIPStatus.cancelled:
        return Colors.red;
      case SIPStatus.draft:
        return Colors.grey;
    }
  }
}

class SIPSummaryTile extends StatelessWidget {
  final SIPPlan sip;
  final VoidCallback? onTap;

  const SIPSummaryTile({
    super.key,
    required this.sip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getStatusColor(sip.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.schedule,
                  color: _getStatusColor(sip.status),
                  size: 20,
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sip.planName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${sip.formattedAmount} • ${sip.frequencyText}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    sip.formattedTotalInvested,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getStatusColor(sip.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getStatusText(sip.status),
                      style: TextStyle(
                        color: _getStatusColor(sip.status),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(SIPStatus status) {
    switch (status) {
      case SIPStatus.active:
        return Colors.green;
      case SIPStatus.paused:
        return Colors.orange;
      case SIPStatus.completed:
        return Colors.blue;
      case SIPStatus.cancelled:
        return Colors.red;
      case SIPStatus.draft:
        return Colors.grey;
    }
  }

  String _getStatusText(SIPStatus status) {
    switch (status) {
      case SIPStatus.active:
        return 'Active';
      case SIPStatus.paused:
        return 'Paused';
      case SIPStatus.completed:
        return 'Done';
      case SIPStatus.cancelled:
        return 'Cancelled';
      case SIPStatus.draft:
        return 'Draft';
    }
  }
}
