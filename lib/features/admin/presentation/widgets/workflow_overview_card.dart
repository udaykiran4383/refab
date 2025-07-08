import 'package:flutter/material.dart';

class WorkflowOverviewCard extends StatelessWidget {
  final int pendingCount;
  final int inProgressCount;
  final int completedCount;
  final int cancelledCount;
  final VoidCallback onTap;

  const WorkflowOverviewCard({
    super.key,
    required this.pendingCount,
    required this.inProgressCount,
    required this.completedCount,
    required this.cancelledCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final total = pendingCount + inProgressCount + completedCount + cancelledCount;
    final completionRate = total > 0 ? (completedCount / total * 100).round() : 0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  Expanded(
                    child: Text(
                      'Workflow Status',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$completionRate% Complete',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Progress Bar
              LinearProgressIndicator(
                value: total > 0 ? completedCount / total : 0,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600),
                minHeight: 8,
              ),
              const SizedBox(height: 16),

              // Status Grid
              Row(
                children: [
                  Expanded(
                    child: _buildStatusItem(
                      'Pending',
                      pendingCount,
                      Icons.schedule,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatusItem(
                      'In Progress',
                      inProgressCount,
                      Icons.pending_actions,
                      Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatusItem(
                      'Completed',
                      completedCount,
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatusItem(
                      'Cancelled',
                      cancelledCount,
                      Icons.cancel,
                      Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Workflow Stages
              Text(
                'Workflow Stages',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildWorkflowStages(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, int count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWorkflowStages() {
    return Column(
      children: [
        // Customer Request Stage
        _buildWorkflowStage(
          'Customer Request',
          'Pickup request submitted',
          Icons.shopping_bag,
          Colors.blue,
          true,
        ),
        
        // Tailor Work Stage
        _buildWorkflowStage(
          'Tailor Work',
          'Fabric processing and sewing',
          Icons.cut,
          Colors.orange,
          true,
        ),
        
        // Logistics Pickup Stage
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.local_shipping, color: Colors.blue, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Logistics Pickup (Tailor → Warehouse)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              _buildWorkflowStage(
                'Assignment Created',
                'Pickup assignment created',
                Icons.assignment,
                Colors.blue,
                true,
                isSubStage: true,
              ),
              _buildWorkflowStage(
                'In Progress',
                'Logistics en route to tailor',
                Icons.directions_car,
                Colors.orange,
                true,
                isSubStage: true,
              ),
              _buildWorkflowStage(
                'Completed',
                'Delivered to warehouse',
                Icons.warehouse,
                Colors.green,
                true,
                isSubStage: true,
              ),
            ],
          ),
        ),
        
        // Logistics Delivery Stage
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.delivery_dining, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Logistics Delivery (Warehouse → Customer)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              _buildWorkflowStage(
                'Assignment Created',
                'Delivery assignment created',
                Icons.assignment,
                Colors.green,
                true,
                isSubStage: true,
              ),
              _buildWorkflowStage(
                'In Progress',
                'Logistics en route to customer',
                Icons.directions_car,
                Colors.orange,
                true,
                isSubStage: true,
              ),
              _buildWorkflowStage(
                'Completed',
                'Delivered to customer',
                Icons.person,
                Colors.green,
                true,
                isSubStage: true,
              ),
            ],
          ),
        ),
        
        // Final Stage
        _buildWorkflowStage(
          'Order Complete',
          'Customer receives final product',
          Icons.check_circle,
          Colors.teal,
          true,
        ),
      ],
    );
  }

  Widget _buildWorkflowStage(String title, String description, IconData icon, Color color, bool isActive, {bool isSubStage = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: isSubStage ? 4 : 8),
      padding: EdgeInsets.all(isSubStage ? 6 : 8),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(isSubStage ? 6 : 8),
        border: Border.all(
          color: isActive ? color.withOpacity(0.3) : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isActive ? color : Colors.grey,
            size: isSubStage ? 14 : 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isSubStage ? 11 : 12,
                    fontWeight: FontWeight.w600,
                    color: isActive ? color : Colors.grey,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: isSubStage ? 9 : 10,
                    color: isActive ? color.withOpacity(0.7) : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (isActive && !isSubStage)
            Icon(
              Icons.check_circle,
              color: color,
              size: 16,
            ),
        ],
      ),
    );
  }
} 