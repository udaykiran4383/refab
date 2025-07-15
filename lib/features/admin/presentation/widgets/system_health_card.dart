import 'package:flutter/material.dart';

class SystemHealthCard extends StatelessWidget {
  final Map<String, dynamic> healthData;

  const SystemHealthCard({
    super.key,
    required this.healthData,
  });

  @override
  Widget build(BuildContext context) {
    final status = healthData['status'] ?? 'unknown';
    final uptime = healthData['uptime'] ?? '0%';
    final activeUsers = healthData['activeUsers'] ?? 0;
    final pendingPickups = healthData['pendingPickups'] ?? 0;
    final pendingOrders = healthData['pendingOrders'] ?? 0;

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status.toLowerCase()) {
      case 'healthy':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'System Healthy';
        break;
      case 'warning':
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        statusText = 'System Warning';
        break;
      case 'error':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        statusText = 'System Error';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusText = 'System Unknown';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  statusIcon,
                  color: statusColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Uptime
                _buildMetricRow(
                  icon: Icons.timer,
                  label: 'System Uptime',
                  value: uptime,
                  color: Colors.blue,
                ),
                const SizedBox(height: 12),

                // Active Users
                _buildMetricRow(
                  icon: Icons.people,
                  label: 'Active Users',
                  value: activeUsers.toString(),
                  color: Colors.green,
                ),
                const SizedBox(height: 12),

                // Pending Items
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricRow(
                        icon: Icons.local_shipping,
                        label: 'Pending Pickups',
                        value: pendingPickups.toString(),
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMetricRow(
                        icon: Icons.shopping_cart,
                        label: 'Pending Orders',
                        value: pendingOrders.toString(),
                        color: Colors.purple,
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

  Widget _buildMetricRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 