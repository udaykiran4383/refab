import 'package:flutter/material.dart';
import '../../data/models/pickup_request_model.dart';

class PickupWorkflowDiagram extends StatelessWidget {
  final PickupRequestModel request;

  const PickupWorkflowDiagram({super.key, required this.request});

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
              'Pickup & Logistics Progress',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Workflow Steps
            _buildWorkflowSteps(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkflowSteps(BuildContext context) {
    final steps = [
      {
        'title': 'Logistics Assigned',
        'description': 'Logistics partner assigned for pickup',
        'status': request.logisticsId != null ? 'completed' : 'pending',
        'icon': Icons.local_shipping,
        'color': Colors.blue,
      },
      {
        'title': 'Picked Up by Logistics',
        'description': 'Logistics collects processed fabric from tailor',
        'status': request.isPickedUp || request.isInTransit || request.isDelivered || request.isCompleted ? 'completed' : 'pending',
        'icon': Icons.inventory,
        'color': Colors.orange,
      },
      {
        'title': 'In Transit',
        'description': 'Package is on the way to warehouse',
        'status': request.isInTransit || request.isDelivered || request.isCompleted ? 'completed' : 'pending',
        'icon': Icons.directions_bus,
        'color': Colors.purple,
      },
      {
        'title': 'Delivered to Warehouse',
        'description': 'Logistics delivers processed fabric to warehouse',
        'status': request.isDelivered || request.isCompleted ? 'completed' : 'pending',
        'icon': Icons.warehouse,
        'color': Colors.green,
      },
      {
        'title': 'Completed',
        'description': 'Logistics process completed',
        'status': request.isCompleted ? 'completed' : 'pending',
        'icon': Icons.check_circle,
        'color': Colors.teal,
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
} 