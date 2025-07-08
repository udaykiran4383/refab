import 'package:flutter/material.dart';
import '../../../tailor/data/models/pickup_request_model.dart';

class PickupRequestsCard extends StatelessWidget {
  final int totalRequests;
  final int pendingRequests;
  final int scheduledRequests;
  final int completedRequests;
  final List<PickupRequestModel> recentRequests;
  final VoidCallback onTap;

  const PickupRequestsCard({
    super.key,
    required this.totalRequests,
    required this.pendingRequests,
    required this.scheduledRequests,
    required this.completedRequests,
    required this.recentRequests,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final completionRate = totalRequests > 0 ? (completedRequests / totalRequests * 100).round() : 0;
    final assignmentRate = totalRequests > 0 ? ((scheduledRequests + completedRequests) / totalRequests * 100).round() : 0;

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
                      'Pickup Requests',
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
                        '$pendingRequests Pending',
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

              // Key Metrics
              Row(
                children: [
                  Expanded(
                    child: _buildMetricItem(
                      'Total',
                      totalRequests.toString(),
                      Icons.shopping_bag,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricItem(
                      'Pending',
                      pendingRequests.toString(),
                      Icons.pending,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricItem(
                      'Completed',
                      completedRequests.toString(),
                      Icons.check_circle,
                      Colors.green,
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
                      'Completion Rate',
                      completionRate,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildProgressIndicator(
                      'Assignment Rate',
                      assignmentRate,
                      Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Recent Requests
              Text(
                'Recent Requests',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildRecentRequests(),
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

  Widget _buildRecentRequests() {
    if (recentRequests.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'No recent requests',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    return Column(
      children: recentRequests.take(3).map((request) => _buildRequestItem(request)).toList(),
    );
  }

  Widget _buildRequestItem(PickupRequestModel request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getStatusColor(request.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getStatusColor(request.status).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(request.status),
            color: _getStatusColor(request.status),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.customerName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${request.fabricTypeDisplayName} - ${request.estimatedWeight.toStringAsFixed(1)}kg',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _getStatusColor(request.status),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              request.statusDisplayName,
              style: const TextStyle(
                fontSize: 8,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
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
        return Colors.purple;
      case PickupStatus.pickedUp:
        return Colors.indigo;
      case PickupStatus.inTransit:
        return Colors.teal;
      case PickupStatus.delivered:
        return Colors.green;
      case PickupStatus.completed:
        return Colors.green;
      case PickupStatus.cancelled:
        return Colors.red;
      case PickupStatus.rejected:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(PickupStatus status) {
    switch (status) {
      case PickupStatus.pending:
        return Icons.pending;
      case PickupStatus.scheduled:
        return Icons.schedule;
      case PickupStatus.inProgress:
        return Icons.work;
      case PickupStatus.pickedUp:
        return Icons.local_shipping;
      case PickupStatus.inTransit:
        return Icons.directions_car;
      case PickupStatus.delivered:
        return Icons.delivery_dining;
      case PickupStatus.completed:
        return Icons.check_circle;
      case PickupStatus.cancelled:
        return Icons.cancel;
      case PickupStatus.rejected:
        return Icons.block;
    }
  }
} 