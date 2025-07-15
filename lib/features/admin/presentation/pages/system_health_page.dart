import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';
import '../../../auth/providers/auth_provider.dart';

class SystemHealthPage extends ConsumerStatefulWidget {
  const SystemHealthPage({super.key});

  @override
  ConsumerState<SystemHealthPage> createState() => _SystemHealthPageState();
}

class _SystemHealthPageState extends ConsumerState<SystemHealthPage> {
  @override
  Widget build(BuildContext context) {
    final systemHealth = ref.watch(systemHealthProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.health_and_safety, color: Theme.of(context).primaryColor, size: 32),
              const SizedBox(width: 12),
              Text('System Health', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                onPressed: () => setState(() {}),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: systemHealth.when(
              data: (health) => _buildHealthOverview(context, health),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthOverview(BuildContext context, Map<String, dynamic> health) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // System Status Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.circle,
                        color: _getStatusColor(health['systemStatus']),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'System Status: ${health['status']?.toString().toUpperCase() ?? 'UNKNOWN'}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Last Updated: ${_formatTimeAgo(health['lastBackup'])}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Overall Statistics
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Overall Statistics', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('Active Users', health['activeUsers'].toString(), Icons.people, Colors.blue)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('Database Size', health['databaseSize'] ?? '0 GB', Icons.storage, Colors.orange)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('Uptime', health['uptime'] ?? '0%', Icons.timer, Colors.green)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('Last Backup', _formatTimeAgo(health['lastBackup']), Icons.backup, Colors.purple)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Recent Activity
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recent Activity (Last 24 Hours)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('New Users', health['recentUsers'].toString(), Icons.person_add, Colors.blue)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('New Pickups', health['recentPickups'].toString(), Icons.local_shipping, Colors.orange)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('New Orders', health['recentOrders'].toString(), Icons.shopping_cart, Colors.green)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('', '', Icons.space_bar, Colors.transparent)), // Empty space
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Pending Items
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pending Items', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Pending Pickups',
                          health['pendingPickups'].toString(),
                          Icons.pending,
                          health['pendingPickups'] > 0 ? Colors.red : Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Pending Orders',
                          health['pendingOrders'].toString(),
                          Icons.shopping_cart,
                          health['pendingOrders'] > 0 ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _createBackup(),
                  icon: const Icon(Icons.backup),
                  label: const Text('Create Backup'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showSystemLogs(),
                  icon: const Icon(Icons.list),
                  label: const Text('View Logs'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Logout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _logout(),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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

  void _createBackup() async {
    try {
      await ref.read(adminRepositoryProvider).createSystemBackup();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('System backup created successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create backup: $e')),
        );
      }
    }
  }

  void _showSystemLogs() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('System Logs'),
        content: const Text('System logs functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _logout() async {
    try {
      await ref.read(authServiceProvider).signOut();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 