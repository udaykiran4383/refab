import 'package:flutter/material.dart';
import '../../data/models/pickup_request_model.dart';

class PickupProgressCard extends StatelessWidget {
  final PickupRequestModel request;
  final String? logisticsName;
  final String? warehouseName;

  const PickupProgressCard({
    super.key,
    required this.request,
    this.logisticsName,
    this.warehouseName,
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
              'Pickup & Logistics Progress',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildProgressSteps(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSteps(BuildContext context) {
    final steps = [
      {
        'title': 'Logistics Assigned',
        'description': logisticsName != null && logisticsName!.isNotEmpty
            ? 'Assigned to $logisticsName'
            : 'Waiting for logistics assignment',
        'active': request.logisticsId != null,
        'icon': Icons.local_shipping,
        'color': Colors.blue,
      },
      {
        'title': 'Picked Up by Logistics',
        'description': 'Logistics partner has picked up the package',
        'active': request.isPickedUp || request.isInTransit || request.isDelivered || request.isCompleted,
        'icon': Icons.inventory,
        'color': Colors.orange,
      },
      {
        'title': 'In Transit',
        'description': 'Package is on the way to warehouse',
        'active': request.isInTransit || request.isDelivered || request.isCompleted,
        'icon': Icons.directions_bus,
        'color': Colors.purple,
      },
      {
        'title': 'Delivered to Warehouse',
        'description': warehouseName != null && warehouseName!.isNotEmpty
            ? 'Delivered to $warehouseName'
            : 'Delivered to warehouse',
        'active': request.isDelivered || request.isCompleted,
        'icon': Icons.warehouse,
        'color': Colors.green,
      },
      {
        'title': 'Completed',
        'description': 'Logistics process completed',
        'active': request.isCompleted,
        'icon': Icons.check_circle,
        'color': Colors.teal,
      },
    ];

    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isActive = step['active'] as bool;
        final isLast = index == steps.length - 1;

        return Column(
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? step['color'] as Color : Colors.grey[300],
                  ),
                  child: Icon(
                    step['icon'] as IconData,
                    color: isActive ? Colors.white : Colors.grey[600],
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step['title'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isActive ? step['color'] as Color : Colors.grey[700],
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
                Icon(
                  isActive ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isActive ? step['color'] as Color : Colors.grey[400],
                  size: 18,
                ),
              ],
            ),
            if (!isLast)
              Container(
                margin: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
                width: 2,
                height: 18,
                color: isActive ? step['color'] as Color : Colors.grey[300],
              ),
          ],
        );
      }).toList(),
    );
  }
} 