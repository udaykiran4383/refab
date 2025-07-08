import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/pickup_request_model.dart';
import '../../providers/tailor_provider.dart';

class EnhancedPickupRequestCard extends ConsumerWidget {
  final PickupRequestModel request;
  final VoidCallback? onTap;
  final bool showActions;

  const EnhancedPickupRequestCard({
    super.key,
    required this.request,
    this.onTap,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status and ID
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Request #${request.id.substring(0, 8)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(request.createdAt),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(context),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Customer Information
              _buildCustomerSection(context),
              
              const SizedBox(height: 12),
              
              // Fabric Information
              _buildFabricSection(context),
              
              const SizedBox(height: 12),
              
              // Weight and Value
              _buildMetricsSection(context),
              
              if (request.notes != null && request.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildNotesSection(context),
              ],
              
              if (showActions) ...[
                const SizedBox(height: 16),
                _buildActionButtons(context, ref),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    final statusColor = _getStatusColor(request.status);
    final statusIcon = _getStatusIcon(request.status);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 16, color: statusColor),
          const SizedBox(width: 4),
          Text(
            request.statusDisplayName,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Customer Details',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildDetailRow('Name', request.customerName, Icons.person_outline),
          _buildDetailRow('Phone', request.customerPhone, Icons.phone),
          _buildDetailRow('Email', request.customerEmail, Icons.email),
          _buildDetailRow('Address', request.pickupAddress, Icons.location_on),
        ],
      ),
    );
  }

  Widget _buildFabricSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.category, size: 16, color: Colors.blue[600]),
              const SizedBox(width: 8),
              Text(
                'Fabric Details',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildDetailRow('Type', request.fabricTypeDisplayName, Icons.fabric),
          _buildDetailRow('Description', request.fabricDescription, Icons.description),
          if (request.fabricSamples != null && request.fabricSamples!.isNotEmpty)
            _buildDetailRow('Samples', '${request.fabricSamples!.length} photos', Icons.photo_library),
        ],
      ),
    );
  }

  Widget _buildMetricsSection(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            context,
            'Estimated Weight',
            '${request.estimatedWeight}kg',
            Icons.scale,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCard(
            context,
            'Actual Weight',
            '${request.actualWeight}kg',
            Icons.scale_outlined,
            Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCard(
            context,
            'Estimated Value',
            '₹${request.estimatedValue.toStringAsFixed(0)}',
            Icons.attach_money,
            Colors.purple,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCard(
            context,
            'Actual Value',
            '₹${request.actualValue.toStringAsFixed(0)}',
            Icons.monetization_on,
            Colors.teal,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 12,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note, size: 16, color: Colors.amber[700]),
              const SizedBox(width: 8),
              Text(
                'Notes',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            request.notes!,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showRequestDetails(context),
            icon: const Icon(Icons.visibility, size: 16),
            label: const Text('View Details'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showStatusUpdateDialog(context, ref),
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Update Status'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(PickupStatus status) {
    switch (status) {
      case PickupStatus.pending:
        return Colors.orange;
      case PickupStatus.scheduled:
        return Colors.blue;
      case PickupStatus.inProgress:
        return Colors.indigo;
      case PickupStatus.pickedUp:
        return Colors.cyan;
      case PickupStatus.inTransit:
        return Colors.deepPurple;
      case PickupStatus.delivered:
        return Colors.teal;
      case PickupStatus.completed:
        return Colors.green;
      case PickupStatus.cancelled:
        return Colors.red;
      case PickupStatus.rejected:
        return Colors.red[700]!;
    }
  }

  IconData _getStatusIcon(PickupStatus status) {
    switch (status) {
      case PickupStatus.pending:
        return Icons.schedule;
      case PickupStatus.scheduled:
        return Icons.calendar_today;
      case PickupStatus.inProgress:
        return Icons.work;
      case PickupStatus.pickedUp:
        return Icons.local_shipping;
      case PickupStatus.inTransit:
        return Icons.directions_car;
      case PickupStatus.delivered:
        return Icons.check_circle;
      case PickupStatus.completed:
        return Icons.done_all;
      case PickupStatus.cancelled:
        return Icons.cancel;
      case PickupStatus.rejected:
        return Icons.block;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showRequestDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Request Details',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailSection('Request Information', [
                      _buildDetailRow('Request ID', request.id, Icons.tag),
                      _buildDetailRow('Status', request.statusDisplayName, Icons.info),
                      _buildDetailRow('Created', _formatDate(request.createdAt), Icons.calendar_today),
                      if (request.updatedAt != null)
                        _buildDetailRow('Updated', _formatDate(request.updatedAt!), Icons.update),
                    ]),
                    const SizedBox(height: 16),
                    _buildDetailSection('Customer Information', [
                      _buildDetailRow('Name', request.customerName, Icons.person),
                      _buildDetailRow('Phone', request.customerPhone, Icons.phone),
                      _buildDetailRow('Email', request.customerEmail, Icons.email),
                      _buildDetailRow('Pickup Address', request.pickupAddress, Icons.location_on),
                      if (request.deliveryAddress != null)
                        _buildDetailRow('Delivery Address', request.deliveryAddress!, Icons.local_shipping),
                    ]),
                    const SizedBox(height: 16),
                    _buildDetailSection('Fabric Information', [
                      _buildDetailRow('Type', request.fabricTypeDisplayName, Icons.category),
                      _buildDetailRow('Description', request.fabricDescription, Icons.description),
                      _buildDetailRow('Estimated Weight', '${request.estimatedWeight}kg', Icons.scale),
                      _buildDetailRow('Actual Weight', '${request.actualWeight}kg', Icons.scale_outlined),
                      _buildDetailRow('Estimated Value', '₹${request.estimatedValue}', Icons.attach_money),
                      _buildDetailRow('Actual Value', '₹${request.actualValue}', Icons.monetization_on),
                    ]),
                    if (request.notes != null && request.notes!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildDetailSection('Notes', [
                        _buildDetailRow('Additional Notes', request.notes!, Icons.note),
                      ]),
                    ],
                    if (request.rejectionReason != null) ...[
                      const SizedBox(height: 16),
                      _buildDetailSection('Rejection Reason', [
                        _buildDetailRow('Reason', request.rejectionReason!, Icons.block),
                      ]),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  void _showStatusUpdateDialog(BuildContext context, WidgetRef ref) {
    final availableStatuses = _getAvailableStatuses(request.status);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select new status:'),
            const SizedBox(height: 16),
            ...availableStatuses.map((status) {
              return ListTile(
                title: Text(status.displayName),
                leading: Radio<PickupStatus>(
                  value: status,
                  groupValue: request.status,
                  onChanged: (value) {
                    Navigator.pop(context);
                    if (value != null) {
                      ref.read(tailorProvider.notifier).updatePickupStatus(request.id, value);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Status updated to ${status.displayName}')),
                      );
                    }
                  },
                ),
                trailing: Icon(_getStatusIcon(status), color: _getStatusColor(status)),
              );
            }).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  List<PickupStatus> _getAvailableStatuses(PickupStatus currentStatus) {
    switch (currentStatus) {
      case PickupStatus.pending:
        return [PickupStatus.scheduled, PickupStatus.inProgress, PickupStatus.cancelled, PickupStatus.rejected];
      case PickupStatus.scheduled:
        return [PickupStatus.inProgress, PickupStatus.pickedUp, PickupStatus.cancelled];
      case PickupStatus.inProgress:
        return [PickupStatus.pickedUp, PickupStatus.cancelled];
      case PickupStatus.pickedUp:
        return [PickupStatus.inTransit, PickupStatus.delivered];
      case PickupStatus.inTransit:
        return [PickupStatus.delivered];
      case PickupStatus.delivered:
        return [PickupStatus.completed];
      case PickupStatus.completed:
        return [];
      case PickupStatus.cancelled:
        return [];
      case PickupStatus.rejected:
        return [];
    }
  }
} 