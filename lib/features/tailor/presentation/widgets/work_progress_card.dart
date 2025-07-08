import 'package:flutter/material.dart';
import '../../data/models/pickup_request_model.dart';

class WorkProgressCard extends StatelessWidget {
  final PickupRequestModel request;
  final VoidCallback? onProgressUpdate;

  const WorkProgressCard({
    super.key,
    required this.request,
    this.onProgressUpdate,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Work Progress',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (request.canUpdateWorkProgress)
                  TextButton.icon(
                    onPressed: onProgressUpdate,
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Update'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                      request.workProgressDisplayName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Text(
                      '${request.workProgressPercentage.toInt()}%',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: request.workProgressPercentage / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getProgressColor(request.workProgressPercentage),
                  ),
                  minHeight: 8,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Progress Steps
            _buildProgressSteps(context),
            
            // Status Information
            if (!request.canStartWork)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange[700], size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Waiting for fabric to be picked up by logistics',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSteps(BuildContext context) {
    final steps = [
      {'name': 'Fabric Received', 'progress': TailorWorkProgress.fabricReceived},
      {'name': 'Fabric Inspected', 'progress': TailorWorkProgress.fabricInspected},
      {'name': 'Cutting Started', 'progress': TailorWorkProgress.cuttingStarted},
      {'name': 'Cutting Complete', 'progress': TailorWorkProgress.cuttingComplete},
      {'name': 'Sewing Started', 'progress': TailorWorkProgress.sewingStarted},
      {'name': 'Sewing Complete', 'progress': TailorWorkProgress.sewingComplete},
      {'name': 'Quality Check', 'progress': TailorWorkProgress.qualityCheck},
      {'name': 'Ready for Pickup', 'progress': TailorWorkProgress.readyForDelivery},
    ];

    return Column(
      children: [
        ...steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final progress = step['progress'] as TailorWorkProgress;
          final isCompleted = request.workProgress != null && 
              request.workProgress!.index >= progress.index;
          final isCurrent = request.workProgress == progress;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted 
                        ? Theme.of(context).primaryColor
                        : isCurrent
                            ? Theme.of(context).primaryColor.withOpacity(0.3)
                            : Colors.grey[300],
                    border: isCurrent 
                        ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                        : null,
                  ),
                  child: isCompleted
                      ? Icon(Icons.check, color: Colors.white, size: 16)
                      : isCurrent
                          ? Icon(Icons.radio_button_checked, color: Theme.of(context).primaryColor, size: 16)
                          : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    step['name'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: isCompleted 
                          ? Theme.of(context).primaryColor
                          : isCurrent
                              ? Theme.of(context).primaryColor
                              : Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        
        // Warehouse Information Section
        if (request.isReadyForDelivery || request.isWorkCompleted) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warehouse, color: Colors.blue[700], size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Warehouse Assignment',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildWarehouseInfo(),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildWarehouseInfo() {
    // This would need to be connected to the logistics assignment data
    // For now, showing a placeholder
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status: Ready for Logistics Pickup',
          style: TextStyle(
            color: Colors.blue[700],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Logistics will pick up the completed work and deliver it to the assigned warehouse.',
          style: TextStyle(
            color: Colors.blue[600],
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'Work completed and ready for pickup',
            style: TextStyle(
              color: Colors.green[700],
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.blue;
    if (percentage >= 40) return Colors.orange;
    if (percentage >= 20) return Colors.yellow[700]!;
    return Colors.grey;
  }
} 