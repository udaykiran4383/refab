import 'package:flutter/material.dart';

class RealTimeStatusCard extends StatelessWidget {
  final List<Map<String, dynamic>> activities;
  final VoidCallback onTap;

  const RealTimeStatusCard({
    super.key,
    required this.activities,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
                      'Real-Time Activities',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Live',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Activity Feed
              ...activities.take(5).map((activity) => _buildActivityItem(activity)),
              
              if (activities.length > 5)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Center(
                    child: Text(
                      '+${activities.length - 5} more activities',
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    final type = activity['type'] as String;
    final id = activity['id'] as String;
    final status = activity['status'] as String;
    final timestamp = activity['timestamp'] as DateTime;
    final priority = activity['priority'] as String;
    
    // Get role-specific data and assignment type
    final role = activity['tailor'] ?? activity['logistics'] ?? activity['warehouse'] ?? 'Unknown';
    final assignmentType = activity['assignmentType'] as String?; // 'pickup' or 'delivery'
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getStatusColor(status).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Activity Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getTypeColor(type, assignmentType),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getTypeIcon(type, assignmentType),
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          
          // Activity Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _getTypeLabel(type, assignmentType),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(priority).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          priority.toUpperCase(),
                          style: TextStyle(
                            color: _getPriorityColor(priority),
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$id - $role',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _getStatusColor(status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getStatusLabel(status),
                      style: TextStyle(
                        fontSize: 10,
                        color: _getStatusColor(status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatTimestamp(timestamp),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type, String? assignmentType) {
    switch (type) {
      case 'pickup_request':
        return Colors.blue;
      case 'logistics_assignment':
        // Different colors for pickup vs delivery assignments
        if (assignmentType == 'pickup') {
          return Colors.blue;
        } else if (assignmentType == 'delivery') {
          return Colors.green;
        }
        return Colors.orange;
      case 'warehouse_processing':
        return Colors.purple;
      case 'tailor_work':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type, String? assignmentType) {
    switch (type) {
      case 'pickup_request':
        return Icons.shopping_bag;
      case 'logistics_assignment':
        // Different icons for pickup vs delivery assignments
        if (assignmentType == 'pickup') {
          return Icons.local_shipping;
        } else if (assignmentType == 'delivery') {
          return Icons.delivery_dining;
        }
        return Icons.local_shipping;
      case 'warehouse_processing':
        return Icons.warehouse;
      case 'tailor_work':
        return Icons.cut;
      default:
        return Icons.info;
    }
  }

  String _getTypeLabel(String type, String? assignmentType) {
    switch (type) {
      case 'pickup_request':
        return 'Pickup Request';
      case 'logistics_assignment':
        // Different labels for pickup vs delivery assignments
        if (assignmentType == 'pickup') {
          return 'Pickup Assignment';
        } else if (assignmentType == 'delivery') {
          return 'Delivery Assignment';
        }
        return 'Logistics Assignment';
      case 'warehouse_processing':
        return 'Warehouse Processing';
      case 'tailor_work':
        return 'Tailor Work';
      default:
        return 'Activity';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'processing':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'in_progress':
        return 'In Progress';
      case 'processing':
        return 'Processing';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
} 