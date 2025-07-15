import 'package:flutter/material.dart';

class LogisticsOverviewCard extends StatelessWidget {
  final int totalAssignments;
  final int activeAssignments;
  final int completedAssignments;
  final double totalWeight;
  final double averageDeliveryTime;
  final VoidCallback onTap;

  const LogisticsOverviewCard({
    super.key,
    required this.totalAssignments,
    required this.activeAssignments,
    required this.completedAssignments,
    required this.totalWeight,
    required this.averageDeliveryTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final completionRate = totalAssignments > 0 ? (completedAssignments / totalAssignments * 100).round() : 0;
    final activeRate = totalAssignments > 0 ? (activeAssignments / totalAssignments * 100).round() : 0;

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
                      'Logistics Operations',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$activeAssignments Active',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Key Metrics
              LayoutBuilder(
                builder: (context, constraints) {
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: constraints.maxWidth > 600 ? (constraints.maxWidth - 24) / 3 : constraints.maxWidth,
                        child: _buildMetricItem(
                          'Total',
                          totalAssignments.toString(),
                          Icons.assignment,
                          Colors.blue,
                        ),
                      ),
                      SizedBox(
                        width: constraints.maxWidth > 600 ? (constraints.maxWidth - 24) / 3 : constraints.maxWidth,
                        child: _buildMetricItem(
                          'Active',
                          activeAssignments.toString(),
                          Icons.pending_actions,
                          Colors.orange,
                        ),
                      ),
                      SizedBox(
                        width: constraints.maxWidth > 600 ? (constraints.maxWidth - 24) / 3 : constraints.maxWidth,
                        child: _buildMetricItem(
                          'Completed',
                          completedAssignments.toString(),
                          Icons.check_circle,
                          Colors.green,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // Progress Indicators
              LayoutBuilder(
                builder: (context, constraints) {
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: constraints.maxWidth > 600 ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth,
                        child: _buildProgressIndicator(
                          'Completion Rate',
                          completionRate,
                          Colors.green,
                        ),
                      ),
                      SizedBox(
                        width: constraints.maxWidth > 600 ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth,
                        child: _buildProgressIndicator(
                          'Active Rate',
                          activeRate,
                          Colors.blue,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // Additional Metrics
              LayoutBuilder(
                builder: (context, constraints) {
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: constraints.maxWidth > 600 ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth,
                        child: _buildMetricItem(
                          'Total Weight',
                          '${totalWeight.toStringAsFixed(1)} kg',
                          Icons.scale,
                          Colors.purple,
                        ),
                      ),
                      SizedBox(
                        width: constraints.maxWidth > 600 ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth,
                        child: _buildMetricItem(
                          'Avg Delivery',
                          '${averageDeliveryTime.toStringAsFixed(1)} days',
                          Icons.schedule,
                          Colors.indigo,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // Single Assignment Rule Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.security,
                      color: Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Single Assignment Rule',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Only one logistics partner can be assigned per pickup request',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Logistics Workflow
              Text(
                'Logistics Workflow',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildLogisticsWorkflow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon, Color color) {
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
            value,
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

  Widget _buildProgressIndicator(String label, int percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _buildDetailMetric(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: color.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogisticsWorkflow() {
    return Column(
      children: [
        // Pickup Workflow Section
        Container(
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
                    'Pickup Workflow (Tailor → Warehouse)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildWorkflowStep(
                'Assignment Created',
                'Pickup assignment created',
                Icons.assignment,
                Colors.blue,
                true,
              ),
              _buildWorkflowStep(
                'In Progress',
                'Logistics en route to tailor',
                Icons.directions_car,
                Colors.orange,
                true,
              ),
              _buildWorkflowStep(
                'Completed',
                'Delivered to warehouse',
                Icons.warehouse,
                Colors.green,
                true,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Delivery Workflow Section
        Container(
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
                    'Delivery Workflow (Warehouse → Customer)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildWorkflowStep(
                'Assignment Created',
                'Delivery assignment created',
                Icons.assignment,
                Colors.green,
                true,
              ),
              _buildWorkflowStep(
                'In Progress',
                'Logistics en route to customer',
                Icons.directions_car,
                Colors.orange,
                true,
              ),
              _buildWorkflowStep(
                'Completed',
                'Delivered to customer',
                Icons.person,
                Colors.green,
                true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWorkflowStep(String title, String description, IconData icon, Color color, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? color.withOpacity(0.3) : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isActive ? color : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActive ? color : Colors.grey,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 10,
                    color: isActive ? color.withOpacity(0.7) : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (isActive)
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