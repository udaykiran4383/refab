import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/logistics_assignment_model.dart';
import '../../../tailor/data/models/pickup_request_model.dart';
import '../../../tailor/data/repositories/tailor_repository.dart';

// Provider for pickup request data
final pickupRequestProvider = FutureProvider.family<PickupRequestModel?, String>((ref, pickupRequestId) async {
  final repository = TailorRepository();
  return await repository.getPickupRequest(pickupRequestId);
});

class LogisticsAssignmentCard extends ConsumerWidget {
  final LogisticsAssignmentModel assignment;
  final VoidCallback? onStatusUpdate;
  final VoidCallback? onWarehouseAssign;
  final VoidCallback? onViewDetails;
  final bool isCompleted;
  final String? currentUserId; // Add current user ID for self-assignment check

  const LogisticsAssignmentCard({
    super.key,
    required this.assignment,
    this.onStatusUpdate,
    this.onWarehouseAssign,
    this.onViewDetails,
    this.isCompleted = false,
    this.currentUserId, // Add this parameter
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pickupRequestAsync = ref.watch(pickupRequestProvider(assignment.pickupRequestId));
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: isCompleted
            ? const BorderSide(color: Colors.green, width: 2)
            : BorderSide.none,
      ),
      color: isCompleted ? Colors.green.withOpacity(0.08) : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with Assignment Type, ID and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: assignment.type == LogisticsAssignmentType.pickup 
                                  ? Colors.blue.withOpacity(0.1) 
                                  : Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              assignment.assignmentTypeDisplayName,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: assignment.type == LogisticsAssignmentType.pickup 
                                    ? Colors.blue 
                                    : Colors.green,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Assignment #${assignment.id.substring(0, 8)}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${assignment.sourceName} → ${assignment.destinationName}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: _getStatusColor(assignment.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    assignment.statusDisplayName,
                    style: TextStyle(
                      color: _getStatusColor(assignment.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${assignment.progressPercentage.toInt()}%',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: assignment.progressPercentage / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getProgressColor(assignment.progressPercentage),
                  ),
                  minHeight: 6,
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Assignment Details - More compact
            _buildCompactDetails(),
            
            const SizedBox(height: 12),
            
            // Warehouse Assignment Status (if assigned)
            if (assignment.assignedWarehouseId != null)
              _buildWarehouseAssignmentStatus(),
            
            const SizedBox(height: 12),
            
            // Tailor Pickup Progress (for pickup assignments)
            if (assignment.type == LogisticsAssignmentType.pickup)
              _buildTailorPickupProgress(pickupRequestAsync),
            
            const SizedBox(height: 12),
            
            // Workflow Steps - More compact
            _buildCompactWorkflowSteps(context),
            
            const SizedBox(height: 12),
            
            // Action Buttons
            Row(
              children: [
                if (onViewDetails != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onViewDetails,
                      icon: const Icon(Icons.visibility, size: 14),
                      label: const Text('Details', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        foregroundColor: isCompleted ? Colors.green : null,
                        side: isCompleted
                            ? const BorderSide(color: Colors.green)
                            : null,
                      ),
                    ),
                  ),
                if (!isCompleted && onViewDetails != null && (onStatusUpdate != null || onWarehouseAssign != null))
                  const SizedBox(width: 6),
                if (!isCompleted && onStatusUpdate != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onStatusUpdate,
                      icon: const Icon(Icons.update, size: 14),
                      label: const Text('Update', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                if (!isCompleted && onStatusUpdate != null && onWarehouseAssign != null)
                  const SizedBox(width: 6),
                if (!isCompleted && onWarehouseAssign != null && assignment.assignedWarehouseId == null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onWarehouseAssign,
                      icon: const Icon(Icons.warehouse, size: 14),
                      label: const Text('Assign', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactDetails() {
    return Column(
      children: [
        // First row: Fabric Type and Weight
        Row(
          children: [
            Expanded(
              child: _buildCompactDetailItem('Fabric', assignment.fabricType, Icons.category),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCompactDetailItem('Weight', assignment.formattedWeight, Icons.scale),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Second row: Source Address (truncated)
        _buildCompactDetailItem(
          assignment.type == LogisticsAssignmentType.pickup ? 'From' : 'From Warehouse', 
          _truncateAddress(assignment.sourceAddress), 
          assignment.type == LogisticsAssignmentType.pickup ? Icons.person : Icons.warehouse
        ),
        const SizedBox(height: 6),
        // Third row: Destination Address (truncated)
        _buildCompactDetailItem(
          assignment.type == LogisticsAssignmentType.pickup ? 'To Warehouse' : 'To Customer', 
          _truncateAddress(assignment.destinationAddress), 
          assignment.type == LogisticsAssignmentType.pickup ? Icons.warehouse : Icons.person
        ),
      ],
    );
  }

  Widget _buildCompactDetailItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _truncateAddress(String address) {
    if (address.length <= 30) return address;
    return '${address.substring(0, 27)}...';
  }

  Widget _buildWarehouseAssignmentStatus() {
    // Check if this logistics personnel has assigned themselves
    final isSelfAssigned = currentUserId != null && 
                          assignment.logisticsId == currentUserId && 
                          assignment.assignedWarehouseId != null;
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelfAssigned ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isSelfAssigned ? Colors.green.withOpacity(0.3) : Colors.blue.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isSelfAssigned ? Icons.check_circle : Icons.warehouse, 
                size: 16, 
                color: isSelfAssigned ? Colors.green[700] : Colors.blue[700]
              ),
              const SizedBox(width: 8),
              Text(
                isSelfAssigned ? 'Self-Assigned to Warehouse' : 'Warehouse Assignment',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelfAssigned ? Colors.green[700] : Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Warehouse Details
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Warehouse: ${assignment.assignedWarehouseName ?? 'Unknown Warehouse'}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (assignment.warehouseType != null)
                      Text(
                        'Type: ${assignment.warehouseTypeDisplayName}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    if (assignment.warehouseAddress != null)
                      Text(
                        'Address: ${_truncateAddress(assignment.warehouseAddress!)}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelfAssigned ? Colors.green.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isSelfAssigned ? 'Self-Assigned' : assignment.statusDisplayName,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelfAssigned ? Colors.green[700] : Colors.blue[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Logistics Personnel Details
          Row(
            children: [
              Icon(Icons.person, size: 14, color: Colors.green[700]),
              const SizedBox(width: 6),
              Text(
                'Logistics Personnel',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'ID: ${assignment.logisticsId}',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
          if (isSelfAssigned)
            Text(
              '✓ You have assigned yourself to this warehouse',
              style: TextStyle(
                fontSize: 10,
                color: Colors.green[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          if (isSelfAssigned)
            Text(
              '⚠️ This assignment cannot be changed later',
              style: TextStyle(
                fontSize: 9,
                color: Colors.orange[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          const SizedBox(height: 6),
          // Tailor Details (for pickup assignments)
          if (assignment.type == LogisticsAssignmentType.pickup && assignment.tailorName != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.content_cut, size: 14, color: Colors.orange[700]),
                    const SizedBox(width: 6),
                    Text(
                      'Tailor Details',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Name: ${assignment.tailorName}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
                if (assignment.tailorPhone != null)
                  Text(
                    'Phone: ${assignment.tailorPhone}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                if (assignment.tailorAddress != null)
                  Text(
                    'Address: ${_truncateAddress(assignment.tailorAddress!)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTailorPickupProgress(AsyncValue<PickupRequestModel?> pickupRequestAsync) {
    return pickupRequestAsync.when(
      data: (pickupRequest) {
        if (pickupRequest == null) {
          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Pickup request not found',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.orange[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Tailor Pickup Progress',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status: ${pickupRequest.statusDisplayName}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (pickupRequest.workProgress != null)
                          Text(
                            'Work: ${pickupRequest.workProgressDisplayName}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (pickupRequest.estimatedWeight > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${pickupRequest.estimatedWeight}kg',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Text(
              'Loading pickup progress...',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
      error: (error, stack) => Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, size: 16, color: Colors.red[600]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Error loading pickup progress',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactWorkflowSteps(BuildContext context) {
    final steps = [
      {
        'title': 'Assigned',
        'status': assignment.isAssigned || assignment.isInProgress || assignment.isCompleted ? 'completed' : 'pending',
        'icon': Icons.assignment,
        'color': Colors.blue,
      },
      {
        'title': 'In Progress',
        'status': assignment.isInProgress || assignment.isCompleted ? 'completed' : 'pending',
        'icon': assignment.type == LogisticsAssignmentType.pickup ? Icons.local_shipping : Icons.delivery_dining,
        'color': Colors.green,
      },
      {
        'title': 'Completed',
        'status': assignment.isCompleted ? 'completed' : 'pending',
        'icon': Icons.check_circle,
        'color': Colors.green,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Workflow',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        // Display steps in a horizontal row with icons only
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: steps.map((step) {
            final isCompleted = step['status'] == 'completed';
            final isCurrent = _isCurrentStep(step['title'] as String);
            
            return Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted 
                        ? step['color'] as Color
                        : isCurrent
                            ? step['color'] as Color
                            : Colors.grey[300],
                    border: isCurrent 
                        ? Border.all(color: step['color'] as Color, width: 2)
                        : null,
                  ),
                  child: isCompleted
                      ? Icon(Icons.check, color: Colors.white, size: 12)
                      : isCurrent
                          ? Icon(Icons.radio_button_checked, color: Colors.white, size: 12)
                          : Icon(step['icon'] as IconData, color: Colors.grey[600], size: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  step['title'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCompleted 
                        ? step['color'] as Color
                        : isCurrent
                            ? step['color'] as Color
                            : Colors.grey[700],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  bool _isCurrentStep(String stepTitle) {
    switch (stepTitle) {
      case 'Assigned':
        return assignment.isAssigned;
      case 'In Progress':
        return assignment.isInProgress;
      case 'Completed':
        return assignment.isCompleted;
      default:
        return false;
    }
  }

  Color _getStatusColor(LogisticsAssignmentStatus status) {
    switch (status) {
      case LogisticsAssignmentStatus.pending:
        return Colors.grey;
      case LogisticsAssignmentStatus.assigned:
        return Colors.blue;
      case LogisticsAssignmentStatus.inProgress:
        return Colors.orange;
      case LogisticsAssignmentStatus.completed:
        return Colors.green;
      case LogisticsAssignmentStatus.cancelled:
        return Colors.red;
    }
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.blue;
    if (percentage >= 40) return Colors.orange;
    if (percentage >= 20) return Colors.yellow[700]!;
    return Colors.grey;
  }
} 