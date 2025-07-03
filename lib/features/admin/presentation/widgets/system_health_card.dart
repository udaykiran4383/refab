import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';

class SystemHealthCard extends ConsumerWidget {
  final VoidCallback? onViewDetails;

  const SystemHealthCard({super.key, this.onViewDetails});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final systemHealth = ref.watch(systemHealthProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.health_and_safety,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'System Health',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (onViewDetails != null)
                  TextButton(
                    onPressed: onViewDetails,
                    child: const Text('View Details'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            systemHealth.when(
              data: (health) => Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildHealthMetric(
                          'Status',
                          health['systemStatus'] ?? 'Unknown',
                          _getStatusColor(health['systemStatus']),
                          Icons.circle,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildHealthMetric(
                          'Last Updated',
                          _formatTimeAgo(health['lastUpdated']),
                          Colors.grey,
                          Icons.access_time,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildHealthMetric(
                          'Recent Users',
                          '${health['recentUsers'] ?? 0}',
                          Colors.blue,
                          Icons.person_add,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildHealthMetric(
                          'Recent Pickups',
                          '${health['recentPickups'] ?? 0}',
                          Colors.orange,
                          Icons.local_shipping,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildHealthMetric(
                          'Pending Pickups',
                          '${health['pendingPickups'] ?? 0}',
                          health['pendingPickups'] > 0 ? Colors.red : Colors.green,
                          Icons.pending,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildHealthMetric(
                          'Pending Orders',
                          '${health['pendingOrders'] ?? 0}',
                          health['pendingOrders'] > 0 ? Colors.red : Colors.green,
                          Icons.shopping_cart,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error loading system health: $error'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthMetric(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'healthy':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatTimeAgo(String? timestamp) {
    if (timestamp == null) return 'Unknown';
    
    try {
      final time = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(time);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inDays}d ago';
      }
    } catch (e) {
      return 'Invalid';
    }
  }
}

// Provider for system health
final systemHealthProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.read(adminRepositoryProvider);
  return await repository.getSystemHealth();
}); 