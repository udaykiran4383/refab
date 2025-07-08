import 'package:flutter/material.dart';

class TailorProgressCard extends StatelessWidget {
  final int totalTailors;
  final int activeTailors;
  final int averageWorkProgress;
  final int pendingRequests;
  final int completedRequests;
  final VoidCallback onTap;

  const TailorProgressCard({
    super.key,
    required this.totalTailors,
    required this.activeTailors,
    required this.averageWorkProgress,
    required this.pendingRequests,
    required this.completedRequests,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeRate = totalTailors > 0 ? (activeTailors / totalTailors * 100).round() : 0;
    final completionRate = (pendingRequests + completedRequests) > 0 
        ? (completedRequests / (pendingRequests + completedRequests) * 100).round() 
        : 0;

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
                      'Tailor Progress Tracking',
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
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$activeTailors Active',
                        style: TextStyle(
                          color: Colors.orange.shade700,
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

              // Tailor Metrics
              Row(
                children: [
                  Expanded(
                    child: _buildMetricItem(
                      'Total Tailors',
                      totalTailors.toString(),
                      Icons.people,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricItem(
                      'Active Tailors',
                      activeTailors.toString(),
                      Icons.person,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricItem(
                      'Avg Progress',
                      '$averageWorkProgress%',
                      Icons.trending_up,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Progress Indicators
              Row(
                children: [
                  Expanded(
                    child: _buildProgressIndicator(
                      'Active Rate',
                      activeRate,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildProgressIndicator(
                      'Completion Rate',
                      completionRate,
                      Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Request Metrics
              Row(
                children: [
                  Expanded(
                    child: _buildDetailMetric(
                      'Pending Requests',
                      pendingRequests.toString(),
                      Icons.schedule,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDetailMetric(
                      'Completed Requests',
                      completedRequests.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Work Progress Stages
              Text(
                'Work Progress Stages',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildWorkProgressStages(),
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

  Widget _buildWorkProgressStages() {
    return Column(
      children: [
        _buildWorkStage(
          'Request Received',
          'Pickup request assigned to tailor',
          Icons.assignment,
          Colors.blue,
          true,
          100,
        ),
        _buildWorkStage(
          'Fabric Assessment',
          'Fabric quality and quantity checked',
          Icons.visibility,
          Colors.orange,
          true,
          85,
        ),
        _buildWorkStage(
          'Cutting & Preparation',
          'Fabric cutting and preparation',
          Icons.content_cut,
          Colors.purple,
          true,
          70,
        ),
        _buildWorkStage(
          'Sewing & Assembly',
          'Main sewing and assembly work',
          Icons.build,
          Colors.green,
          true,
          50,
        ),
        _buildWorkStage(
          'Quality Check',
          'Final quality inspection',
          Icons.verified,
          Colors.teal,
          true,
          25,
        ),
        _buildWorkStage(
          'Ready for Pickup',
          'Work completed, ready for logistics',
          Icons.check_circle,
          Colors.indigo,
          false,
          0,
        ),
      ],
    );
  }

  Widget _buildWorkStage(String title, String description, IconData icon, Color color, bool isActive, int progress) {
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
      child: Column(
        children: [
          Row(
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
                Text(
                  '$progress%',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
            ],
          ),
          if (isActive) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ],
        ],
      ),
    );
  }
} 