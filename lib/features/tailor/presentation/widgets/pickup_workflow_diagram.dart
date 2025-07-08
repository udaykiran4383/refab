import 'package:flutter/material.dart';
import '../../data/models/pickup_request_model.dart';

class PickupWorkflowDiagram extends StatelessWidget {
  final PickupRequestModel request;

  const PickupWorkflowDiagram({
    super.key,
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pickup Workflow',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Workflow Steps
            _buildWorkflowSteps(context),
            
            const SizedBox(height: 16),
            
            // Legend
            _buildLegend(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkflowSteps(BuildContext context) {
    final steps = [
      {
        'title': 'Request Created',
        'description': 'Tailor creates pickup request',
        'status': 'completed', // Always completed
        'icon': Icons.add_circle,
        'color': Colors.green,
      },
      {
        'title': 'Logistics Assigned',
        'description': 'Logistics partner assigned',
        'status': request.isScheduled || request.isInProgress || request.isPickedUp || request.isInTransit || request.isDelivered || request.isCompleted ? 'completed' : 'pending',
        'icon': Icons.local_shipping,
        'color': Colors.blue,
      },
      {
        'title': 'Fabric Picked Up',
        'description': 'Logistics picks up fabric',
        'status': request.isPickedUp || request.isInTransit || request.isDelivered || request.isCompleted ? 'completed' : 'pending',
        'icon': Icons.inventory,
        'color': Colors.orange,
      },
      {
        'title': 'Work in Progress',
        'description': 'Tailor processes fabric',
        'status': request.isPickedUp || request.isInTransit || request.isDelivered || request.isCompleted ? 'completed' : 'pending',
        'icon': Icons.work,
        'color': Colors.purple,
      },
      {
        'title': 'Ready for Delivery',
        'description': 'Work completed, ready for delivery',
        'status': request.isReadyForDelivery ? 'completed' : 'pending',
        'icon': Icons.check_circle,
        'color': Colors.teal,
      },
      {
        'title': 'Delivered',
        'description': 'Logistics delivers to customer',
        'status': request.isDelivered || request.isCompleted ? 'completed' : 'pending',
        'icon': Icons.delivery_dining,
        'color': Colors.indigo,
      },
      {
        'title': 'Completed',
        'description': 'Pickup request completed',
        'status': request.isCompleted ? 'completed' : 'pending',
        'icon': Icons.done_all,
        'color': Colors.green,
      },
    ];

    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isCompleted = step['status'] == 'completed';
        final isLast = index == steps.length - 1;

        return Column(
          children: [
            Row(
              children: [
                // Step Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted 
                        ? step['color'] as Color
                        : Colors.grey[300],
                    border: isCompleted 
                        ? null
                        : Border.all(color: Colors.grey[400]!, width: 2),
                  ),
                  child: Icon(
                    step['icon'] as IconData,
                    color: isCompleted ? Colors.white : Colors.grey[600],
                    size: 20,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Step Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step['title'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isCompleted ? step['color'] as Color : Colors.grey[700],
                        ),
                      ),
                      Text(
                        step['description'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Status Icon
                Icon(
                  isCompleted ? Icons.check_circle : Icons.schedule,
                  color: isCompleted ? step['color'] as Color : Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
            
            // Connecting Line (except for last step)
            if (!isLast)
              Container(
                margin: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
                width: 2,
                height: 20,
                color: isCompleted ? step['color'] as Color : Colors.grey[300],
              ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Legend',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 12),
              ),
              const SizedBox(width: 8),
              const Text('Completed', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 16),
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                  border: Border.all(color: Colors.grey[400]!),
                ),
              ),
              const SizedBox(width: 8),
              const Text('Pending', style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
} 