import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../widgets/pickup_request_card.dart';
import '../widgets/stats_card.dart';
import 'new_pickup_request_page.dart';
import '../../../customer/presentation/pages/profile_page.dart';

class TailorDashboard extends ConsumerStatefulWidget {
  final UserModel user;

  const TailorDashboard({super.key, required this.user});

  @override
  ConsumerState<TailorDashboard> createState() => _TailorDashboardState();
}

class _TailorDashboardState extends ConsumerState<TailorDashboard> {
  String _selectedStatus = 'All';
  bool _showCompleted = true;

  final List<String> _statusFilters = ['All', 'Pending', 'In Progress', 'Completed', 'Cancelled'];

  // Mock data for demonstration
  final List<Map<String, dynamic>> _pickupRequests = [
    {
      'id': 'PR001',
      'fabricType': 'Cotton',
      'weight': 5.5,
      'status': 'Pending',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'address': '123 Main Street, Mumbai',
      'customerName': 'John Doe',
      'customerPhone': '+91 9876543210',
      'description': 'Old cotton shirts and pants',
      'estimatedValue': 250.0,
    },
    {
      'id': 'PR002',
      'fabricType': 'Silk',
      'weight': 2.0,
      'status': 'In Progress',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'address': '456 Park Avenue, Delhi',
      'customerName': 'Jane Smith',
      'customerPhone': '+91 9876543211',
      'description': 'Silk sarees and scarves',
      'estimatedValue': 500.0,
    },
    {
      'id': 'PR003',
      'fabricType': 'Wool',
      'weight': 3.5,
      'status': 'Completed',
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'address': '789 Lake Road, Bangalore',
      'customerName': 'Mike Johnson',
      'customerPhone': '+91 9876543212',
      'description': 'Woolen sweaters and coats',
      'estimatedValue': 400.0,
    },
    {
      'id': 'PR004',
      'fabricType': 'Polyester',
      'weight': 4.0,
      'status': 'Pending',
      'date': DateTime.now().subtract(const Duration(days: 4)),
      'address': '321 Beach Road, Chennai',
      'customerName': 'Sarah Wilson',
      'customerPhone': '+91 9876543213',
      'description': 'Polyester curtains and bedsheets',
      'estimatedValue': 300.0,
    },
  ];

  List<Map<String, dynamic>> get _filteredRequests {
    return _pickupRequests.where((request) {
      final statusMatch = _selectedStatus == 'All' || request['status'] == _selectedStatus;
      final showCompleted = _showCompleted || request['status'] != 'Completed';
      return statusMatch && showCompleted;
    }).toList();
  }

  Map<String, dynamic> get _analytics {
    final total = _pickupRequests.length;
    final pending = _pickupRequests.where((r) => r['status'] == 'Pending').length;
    final inProgress = _pickupRequests.where((r) => r['status'] == 'In Progress').length;
    final completed = _pickupRequests.where((r) => r['status'] == 'Completed').length;
    final totalWeight = _pickupRequests.fold<double>(0, (sum, r) => sum + (r['weight'] as double));
    final totalValue = _pickupRequests.fold<double>(0, (sum, r) => sum + (r['estimatedValue'] as double));
    
    return {
      'total': total,
      'pending': pending,
      'inProgress': inProgress,
      'completed': completed,
      'totalWeight': totalWeight,
      'totalValue': totalValue,
      'completionRate': total > 0 ? (completed / total * 100).round() : 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    final analytics = _analytics;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Tailor Dashboard - ${widget.user.name}'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              _showNotifications();
            },
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Text('Profile'),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Text('Settings'),
              ),
              const PopupMenuItem(
                value: 'help',
                child: Text('Help & Support'),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
            onSelected: (value) {
              _handleMenuSelection(value);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, ${widget.user.name}!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Here\'s your pickup activity overview',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            
            // Analytics Cards
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Performance',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: StatsCard(
                          title: 'Total Pickups',
                          value: '${analytics['total']}',
                          icon: Icons.local_shipping,
                          color: Colors.blue,
                          subtitle: 'All time',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatsCard(
                          title: 'Completed',
                          value: '${analytics['completed']}',
                          icon: Icons.check_circle,
                          color: Colors.green,
                          subtitle: '${analytics['completionRate']}% rate',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: StatsCard(
                          title: 'Total Weight',
                          value: '${analytics['totalWeight'].toStringAsFixed(1)}kg',
                          icon: Icons.scale,
                          color: Colors.orange,
                          subtitle: 'Fabric collected',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatsCard(
                          title: 'Total Value',
                          value: '₹${analytics['totalValue'].toStringAsFixed(0)}',
                          icon: Icons.attach_money,
                          color: Colors.purple,
                          subtitle: 'Estimated',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Quick Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionCard(
                          context,
                          'New Pickup Request',
                          'Schedule a new pickup',
                          Icons.add_circle,
                          Colors.green,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NewPickupRequestPage(user: widget.user),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickActionCard(
                          context,
                          'View Schedule',
                          'Check pickup schedule',
                          Icons.calendar_today,
                          Colors.blue,
                          () {
                            _showSchedule();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Pickup Requests Section
            Padding(
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
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: _showCompleted,
                            onChanged: (value) {
                              setState(() {
                                _showCompleted = value;
                              });
                            },
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Show Completed',
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Status Filter
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _statusFilters.length,
                      itemBuilder: (context, index) {
                        final status = _statusFilters[index];
                        final isSelected = status == _selectedStatus;
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(status),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedStatus = status;
                              });
                            },
                            backgroundColor: Colors.grey[200],
                            selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                            checkmarkColor: Theme.of(context).primaryColor,
                            labelStyle: TextStyle(
                              color: isSelected ? Theme.of(context).primaryColor : Colors.grey[700],
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Requests List
                  _filteredRequests.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _filteredRequests.length,
                          itemBuilder: (context, index) {
                            final request = _filteredRequests[index];
                            return _buildDetailedRequestCard(context, request);
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedRequestCard(BuildContext context, Map<String, dynamic> request) {
    final statusColor = _getStatusColor(request['status']);
    
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
                  'Request #${request['id']}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    request['status'],
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildRequestDetail('Fabric Type', request['fabricType'], Icons.category),
                ),
                Expanded(
                  child: _buildRequestDetail('Weight', '${request['weight']}kg', Icons.scale),
                ),
                Expanded(
                  child: _buildRequestDetail('Value', '₹${request['estimatedValue']}', Icons.attach_money),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            _buildRequestDetail('Customer', request['customerName'], Icons.person),
            _buildRequestDetail('Phone', request['customerPhone'], Icons.phone),
            _buildRequestDetail('Address', request['address'], Icons.location_on),
            _buildRequestDetail('Description', request['description'], Icons.description),
            _buildRequestDetail('Date', _formatDate(request['date']), Icons.calendar_today),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showRequestDetails(request);
                    },
                    icon: const Icon(Icons.visibility),
                    label: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _updateRequestStatus(request);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Update Status'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestDetail(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
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
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.inbox,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No pickup requests found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or create a new request',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'In Progress':
        return Colors.blue;
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'profile':
        print('🧵 [TAILOR_DASHBOARD] Navigating to ProfilePage');
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
        break;
      case 'settings':
        print('🧵 [TAILOR_DASHBOARD] Navigating to SettingsPage');
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const TailorSettingsPage()),
        );
        break;
      case 'help':
        print('🧵 [TAILOR_DASHBOARD] Navigating to HelpPage');
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const TailorHelpPage()),
        );
        break;
      case 'logout':
        ref.read(authServiceProvider).signOut();
        break;
    }
  }

  void _showNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: const Text('You have no new notifications.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSchedule() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pickup Schedule'),
        content: const Text('Your pickup schedule will be displayed here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showRequestDetails(Map<String, dynamic> request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Request Details',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Request ID', request['id']),
                    _buildDetailRow('Status', request['status']),
                    _buildDetailRow('Fabric Type', request['fabricType']),
                    _buildDetailRow('Weight', '${request['weight']}kg'),
                    _buildDetailRow('Estimated Value', '₹${request['estimatedValue']}'),
                    _buildDetailRow('Customer Name', request['customerName']),
                    _buildDetailRow('Phone', request['customerPhone']),
                    _buildDetailRow('Address', request['address']),
                    _buildDetailRow('Description', request['description']),
                    _buildDetailRow('Date', _formatDate(request['date'])),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _updateRequestStatus(Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select new status:'),
            const SizedBox(height: 16),
            ...['Pending', 'In Progress', 'Completed', 'Cancelled'].map((status) {
              return ListTile(
                title: Text(status),
                leading: Radio<String>(
                  value: status,
                  groupValue: request['status'],
                  onChanged: (value) {
                    Navigator.pop(context);
                    setState(() {
                      request['status'] = value;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Status updated to $value')),
                    );
                  },
                ),
              );
            }).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class TailorSettingsPage extends StatelessWidget {
  const TailorSettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings coming soon!')),
    );
  }
}

class TailorHelpPage extends StatelessWidget {
  const TailorHelpPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: const Center(child: Text('Help & Support coming soon!')),
    );
  }
}
