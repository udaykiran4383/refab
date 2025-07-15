import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../widgets/stats_card.dart';
import '../widgets/pickup_workflow_diagram.dart';
import 'new_pickup_request_page.dart';
import '../../../customer/presentation/pages/profile_page.dart';
import '../../providers/tailor_provider.dart';
import '../../data/models/pickup_request_model.dart';
import '../../../logistics/data/repositories/logistics_repository.dart';
import '../../../logistics/data/models/logistics_assignment_model.dart';
import '../../../admin/data/repositories/admin_repository.dart';
import '../../../warehouse/providers/warehouse_provider.dart';

// Provider for logistics repository
final logisticsRepositoryProvider = Provider<LogisticsRepository>((ref) {
  return LogisticsRepository();
});

// Provider for admin repository
final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository();
});

// Provider to get logistics assignment for a pickup request
final logisticsAssignmentForPickupProvider = StreamProvider.family<LogisticsAssignmentModel?, String>((ref, pickupRequestId) {
  print('📦 [TAILOR_DASHBOARD] Setting up logistics assignment provider for pickup request: $pickupRequestId');
  final repository = ref.watch(logisticsRepositoryProvider);
  return repository.getLogisticsAssignmentForPickupRequest(pickupRequestId);
});

// Provider to get user details by user ID
final userByIdProvider = FutureProvider.family<UserModel?, String>((ref, userId) async {
  try {
    final repository = ref.read(adminRepositoryProvider);
    final userData = await repository.getUser(userId);
    if (userData != null) {
      return UserModel.fromJson(userData);
    }
    return null;
  } catch (e) {
    print('❌ Error fetching user $userId: $e');
    return null;
  }
});

class TailorDashboard extends ConsumerStatefulWidget {
  final UserModel user;

  const TailorDashboard({super.key, required this.user});

  @override
  ConsumerState<TailorDashboard> createState() => _TailorDashboardState();
}

class _TailorDashboardState extends ConsumerState<TailorDashboard> {
  String _selectedStatus = 'All';
  bool _showCompleted = true;

  // Simplified status filters for tailor workflow
  final List<String> _statusFilters = ['All', 'Pending', 'In Progress', 'Completed', 'Cancelled'];

  // Use real data from Firestore instead of mock data
  List<PickupRequestModel> get _pickupRequests {
    final requestsAsync = ref.watch(pickupRequestsProvider(widget.user.id));
    return requestsAsync.when(
      data: (requests) => requests,
      loading: () => [],
      error: (error, stack) => [],
    );
  }

  List<PickupRequestModel> get _filteredRequests {
    return _pickupRequests.where((request) {
      final statusMatch = _selectedStatus == 'All' || request.statusDisplayName == _selectedStatus;
      final showCompleted = _showCompleted || request.status != PickupStatus.completed;
      return statusMatch && showCompleted;
    }).toList();
  }

  Map<String, dynamic> get _analytics {
    final total = _pickupRequests.length;
    final pending = _pickupRequests.where((r) => r.status == PickupStatus.pending).length;
    final inProgress = _pickupRequests.where((r) => r.status == PickupStatus.inProgress).length;
    final completed = _pickupRequests.where((r) => r.status == PickupStatus.completed).length;
    final totalWeight = _pickupRequests.fold<double>(0, (sum, r) => sum + r.estimatedWeight);
    final totalValue = _pickupRequests.fold<double>(0, (sum, r) => sum + r.estimatedValue);
    
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
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Text('Profile'),
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

  Widget _buildDetailedRequestCard(BuildContext context, PickupRequestModel request) {
    final statusColor = _getStatusColor(request.statusDisplayName);
    
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
                Expanded(
                  child: Text(
                    'Request #${request.id.substring(0, request.id.length > 8 ? 8 : request.id.length)}...',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      request.statusDisplayName,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildRequestDetail('Fabric Type', request.fabricType.toString().split('.').last.toUpperCase(), Icons.category),
                ),
                Expanded(
                  child: _buildRequestDetail('Weight', '${request.estimatedWeight}kg', Icons.scale),
                ),
                Expanded(
                  child: _buildRequestDetail('Value', '₹${request.estimatedValue}', Icons.attach_money),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            _buildRequestDetail('Customer', request.customerName, Icons.person),
            _buildRequestDetail('Phone', request.customerPhone, Icons.phone),
            _buildRequestDetail('Address', request.pickupAddress, Icons.location_on),
            _buildRequestDetail('Description', request.fabricDescription, Icons.description),
            _buildRequestDetail('Date', _formatDate(request.createdAt), Icons.calendar_today),
            
            const SizedBox(height: 16),
            
            // Logistics Assignment Details
            _buildLogisticsAssignmentDetails(request.id),
            
            const SizedBox(height: 16),
            
            // Workflow Diagram
            PickupWorkflowDiagram(request: request),
            
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogisticsAssignmentDetails(String pickupRequestId) {
    print('📦 [TAILOR_DASHBOARD] Building logistics assignment details for pickup request: $pickupRequestId');
    final logisticsAssignmentAsync = ref.watch(logisticsAssignmentForPickupProvider(pickupRequestId));
    final pickupRequestsAsync = ref.watch(pickupRequestsProvider(widget.user.id));
    
    return logisticsAssignmentAsync.when(
      data: (assignment) {
        print('📦 [TAILOR_DASHBOARD] Logistics assignment data received for pickup request: $pickupRequestId');
        print('📦 [TAILOR_DASHBOARD] Assignment: ${assignment?.id} - Status: ${assignment?.statusDisplayName}');
        print('📦 [TAILOR_DASHBOARD] Warehouse Info - ID: ${assignment?.assignedWarehouseId}, Name: ${assignment?.assignedWarehouseName}, Address: ${assignment?.warehouseAddress}');
        if (assignment != null) {
          // Get logistics user details
          final logisticsUserAsync = ref.watch(userByIdProvider(assignment.logisticsId));
          
          return logisticsUserAsync.when(
            data: (logisticsUser) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.local_shipping, size: 20, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Logistics Assignment',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildRequestDetail('Assignment Status', assignment.statusDisplayName, Icons.info),
                    if (logisticsUser != null) ...[
                      _buildRequestDetail('Assigned To', logisticsUser.name, Icons.person),
                      _buildRequestDetail('Logistics Phone', logisticsUser.phone, Icons.phone),
                      if (logisticsUser.email.isNotEmpty)
                        _buildRequestDetail('Logistics Email', logisticsUser.email, Icons.email),
                    ] else
                      _buildRequestDetail('Assigned To', 'Logistics Personnel (ID: ${assignment.logisticsId})', Icons.person),
                    if (assignment.assignedWarehouseName != null)
                      _buildRequestDetail('Warehouse', assignment.assignedWarehouseName!, Icons.warehouse),
                    if (assignment.warehouseAddress != null)
                      _buildRequestDetail('Warehouse Address', assignment.warehouseAddress!, Icons.location_on),
                    if (assignment.warehouseType != null)
                      _buildRequestDetail('Warehouse Type', assignment.warehouseTypeDisplayName, Icons.category),
                    if (assignment.assignedWarehouseId != null && assignment.assignedWarehouseName == null) ...[
                      // Fetch warehouse details if name is not available
                      Consumer(
                        builder: (context, ref, child) {
                          final warehouseAsync = ref.watch(warehouseByIdProvider(assignment.assignedWarehouseId!));
                          return warehouseAsync.when(
                            data: (warehouse) {
                              if (warehouse != null) {
                                return Column(
                                  children: [
                                    _buildRequestDetail('Warehouse', warehouse['name'], Icons.warehouse),
                                    if (warehouse['address'] != null)
                                      _buildRequestDetail('Warehouse Address', warehouse['address'], Icons.location_on),
                                  ],
                                );
                              } else {
                                return _buildRequestDetail('Warehouse', 'Warehouse (ID: ${assignment.assignedWarehouseId})', Icons.warehouse);
                              }
                            },
                            loading: () => _buildRequestDetail('Warehouse', 'Loading warehouse details...', Icons.warehouse),
                            error: (error, stack) => _buildRequestDetail('Warehouse', 'Warehouse (ID: ${assignment.assignedWarehouseId})', Icons.warehouse),
                          );
                        },
                      ),
                    ],
                    _buildRequestDetail('Assignment Date', _formatDate(assignment.createdAt), Icons.calendar_today),
                  ],
                ),
              );
            },
            loading: () => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_shipping, size: 20, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Logistics Assignment',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildRequestDetail('Assignment Status', assignment.statusDisplayName, Icons.info),
                  Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Loading logistics personnel details...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  if (assignment.assignedWarehouseName != null)
                    _buildRequestDetail('Warehouse', assignment.assignedWarehouseName!, Icons.warehouse),
                  if (assignment.warehouseAddress != null)
                    _buildRequestDetail('Warehouse Address', assignment.warehouseAddress!, Icons.location_on),
                  _buildRequestDetail('Assignment Date', _formatDate(assignment.createdAt), Icons.calendar_today),
                ],
              ),
            ),
            error: (error, stack) => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_shipping, size: 20, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Logistics Assignment',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildRequestDetail('Assignment Status', assignment.statusDisplayName, Icons.info),
                  _buildRequestDetail('Assigned To', 'Logistics Personnel (ID: ${assignment.logisticsId})', Icons.person),
                  if (assignment.assignedWarehouseName != null)
                    _buildRequestDetail('Warehouse', assignment.assignedWarehouseName!, Icons.warehouse),
                  if (assignment.warehouseAddress != null)
                    _buildRequestDetail('Warehouse Address', assignment.warehouseAddress!, Icons.location_on),
                  if (assignment.warehouseType != null)
                    _buildRequestDetail('Warehouse Type', assignment.warehouseTypeDisplayName, Icons.category),
                  if (assignment.assignedWarehouseId != null && assignment.assignedWarehouseName == null)
                    _buildRequestDetail('Warehouse', 'Warehouse (ID: ${assignment.assignedWarehouseId})', Icons.warehouse),
                  _buildRequestDetail('Assignment Date', _formatDate(assignment.createdAt), Icons.calendar_today),
                ],
              ),
            ),
          );
        } else {
          // Check if the pickup request is cancelled or has logistics assigned
          return pickupRequestsAsync.when(
            data: (requests) {
              final request = requests.where((r) => r.id == pickupRequestId).firstOrNull;
              
              if (request != null && request.status == PickupStatus.cancelled) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.cancel, size: 20, color: Colors.red[700]),
                          const SizedBox(width: 8),
                          Text(
                            'Assignment Cancelled',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (request.cancellationReason != null)
                        _buildRequestDetail('Cancellation Reason', request.cancellationReason!, Icons.info),
                      if (request.cancelledBy != null) ...[
                        // Get details of who cancelled it
                        Consumer(
                          builder: (context, ref, child) {
                            final cancelledByUserAsync = ref.watch(userByIdProvider(request.cancelledBy!));
                            return cancelledByUserAsync.when(
                              data: (cancelledByUser) {
                                if (cancelledByUser != null) {
                                  return Column(
                                    children: [
                                      _buildRequestDetail('Cancelled By', cancelledByUser.name, Icons.person),
                                      _buildRequestDetail('Cancelled By Phone', cancelledByUser.phone, Icons.phone),
                                    ],
                                  );
                                } else {
                                  return _buildRequestDetail('Cancelled By', 'Logistics Personnel (ID: ${request.cancelledBy})', Icons.person);
                                }
                              },
                              loading: () => _buildRequestDetail('Cancelled By', 'Loading...', Icons.person),
                              error: (error, stack) => _buildRequestDetail('Cancelled By', 'Logistics Personnel (ID: ${request.cancelledBy})', Icons.person),
                            );
                          },
                        ),
                      ],
                      if (request.cancelledAt != null)
                        _buildRequestDetail('Cancelled On', _formatDate(request.cancelledAt!), Icons.calendar_today),
                    ],
                  ),
                );
              } else {
                // Check if pickup request has logistics_id but no assignment found yet
                if (request != null && request.logisticsId != null) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.local_shipping, size: 20, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            Text(
                              'Logistics Assignment Processing',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Logistics has been assigned (ID: ${request.logisticsId}) and assignment details are being processed...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Loading assignment details...',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blue[500],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                } else {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.schedule, size: 20, color: Colors.orange[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Awaiting Logistics Assignment',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                  );
                }
              }
            },
            loading: () => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Loading pickup request details...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            error: (error, stack) => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, size: 20, color: Colors.red[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Error loading pickup request details',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red[700],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
      loading: () => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Text(
              'Loading logistics details...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
      error: (error, stack) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.error, size: 20, color: Colors.red[700]),
            const SizedBox(width: 8),
            Text(
              'Error loading logistics details',
              style: TextStyle(
                fontSize: 14,
                color: Colors.red[700],
              ),
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

  void _showRequestDetails(PickupRequestModel request) {
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
                    _buildDetailRow('Request ID', request.id),
                    _buildDetailRow('Status', request.statusDisplayName),
                    _buildDetailRow('Fabric Type', request.fabricType.toString().split('.').last.toUpperCase().toString().split('.').last),
                    _buildDetailRow('Weight', '${request.estimatedWeight}kg'),
                    _buildDetailRow('Estimated Value', '₹${request.estimatedValue}'),
                    _buildDetailRow('Customer Name', request.customerName),
                    _buildDetailRow('Phone', request.customerPhone),
                    _buildDetailRow('Address', request.pickupAddress),
                    _buildDetailRow('Description', request.fabricDescription),
                    _buildDetailRow('Date', _formatDate(request.createdAt)),
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

  void _updateWorkProgress(PickupRequestModel request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Work Progress'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Status: ${request.statusDisplayName}', 
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 8),
            Text('Current Work Progress: ${request.workProgressDisplayName}', 
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 16),
            const Text('Select your current work stage:'),
            const SizedBox(height: 8),
            ...TailorWorkProgress.values.map((progress) {
              final isCurrent = request.workProgress == progress;
              final isCompleted = request.workProgress != null && 
                  request.workProgress!.index >= progress.index;
              
              return ListTile(
                title: Text(_getWorkProgressDisplayName(progress)),
                subtitle: isCurrent ? const Text('Current Stage', style: TextStyle(color: Colors.blue)) : null,
                leading: Radio<TailorWorkProgress>(
                  value: progress,
                  groupValue: request.workProgress ?? TailorWorkProgress.notStarted,
                  onChanged: (value) {
                    Navigator.pop(context);
                    // Update the work progress using the provider
                    ref.read(tailorProvider.notifier).updateWorkProgress(request.id, value!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Work progress updated to ${_getWorkProgressDisplayName(value)}'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
                trailing: isCompleted && !isCurrent 
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
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

  String _getWorkProgressDisplayName(TailorWorkProgress progress) {
    switch (progress) {
      case TailorWorkProgress.notStarted:
        return 'Not Started';
      case TailorWorkProgress.workStarted:
        return 'Work Started';
      case TailorWorkProgress.workInProgress:
        return 'Work In Progress';
      case TailorWorkProgress.workCompleted:
        return 'Work Completed';
      case TailorWorkProgress.qualityCheck:
        return 'Quality Check';
      case TailorWorkProgress.readyForPickup:
        return 'Ready for Pickup';
      case TailorWorkProgress.completed:
        return 'Completed';
    }
  }


}

// Provider for pickup requests
final pickupRequestsProvider = StreamProvider.family<List<PickupRequestModel>, String>((ref, tailorId) {
  final repository = ref.read(tailorRepositoryProvider);
  return repository.getPickupRequests(tailorId);
});

class TailorHelpPage extends StatelessWidget {
  const TailorHelpPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'Please contact re fab gmail.com',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
