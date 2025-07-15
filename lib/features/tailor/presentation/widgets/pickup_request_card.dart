import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../logistics/data/models/logistics_assignment_model.dart';
import '../pages/tailor_dashboard.dart';

class PickupRequestCard extends ConsumerWidget {
  final String fabricType;
  final double weight;
  final String status;
  final DateTime date;
  final String pickupRequestId;
  final VoidCallback onTap;

  const PickupRequestCard({
    super.key,
    required this.fabricType,
    required this.weight,
    required this.status,
    required this.date,
    required this.pickupRequestId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color statusColor = _getStatusColor(status);
    
    // Get logistics assignment details
    final logisticsAssignmentAsync = ref.watch(logisticsAssignmentForPickupProvider(pickupRequestId));
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    fabricType,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.scale, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${weight}kg',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${date.day}/${date.month}/${date.year}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              
              // Logistics Assignment Details
              logisticsAssignmentAsync.when(
                data: (assignment) {
                  if (assignment != null) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.local_shipping, size: 16, color: Colors.blue[700]),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Logistics Assigned',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Status: ${assignment.statusDisplayName}',
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                              if (assignment.assignedWarehouseName != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'Warehouse: ${assignment.assignedWarehouseName}',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.schedule, size: 16, color: Colors.orange[700]),
                              const SizedBox(width: 4),
                              Text(
                                'Awaiting Logistics Assignment',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                },
                loading: () => const SizedBox(height: 12),
                error: (error, stack) => const SizedBox(height: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'scheduled':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
