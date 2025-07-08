import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/logistics_repository.dart';
import '../../data/models/logistics_assignment_model.dart';
import '../widgets/logistics_assignment_card.dart';
import '../widgets/route_map_widget.dart';
import '../../../customer/presentation/pages/profile_page.dart';
import 'package:flutter/foundation.dart';

// Provider for logistics repository
final logisticsRepositoryProvider = Provider<LogisticsRepository>((ref) {
  return LogisticsRepository();
});

// Provider for logistics assignments
final logisticsAssignmentsProvider = StreamProvider.family<List<LogisticsAssignmentModel>, String>((ref, logisticsId) {
  print('🚚 [LOGISTICS_ASSIGNMENT_PROVIDER] Setting up assignments stream for logistics: $logisticsId');
  final repository = ref.read(logisticsRepositoryProvider);
  return repository.getLogisticsAssignments(logisticsId);
});

// Provider for available warehouses
final availableWarehousesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.read(logisticsRepositoryProvider);
  return await repository.getAvailableWarehouses();
});

class LogisticsDashboard extends ConsumerStatefulWidget {
  final UserModel user;

  const LogisticsDashboard({super.key, required this.user});

  @override
  ConsumerState<LogisticsDashboard> createState() => _LogisticsDashboardState();
}

class _LogisticsDashboardState extends ConsumerState<LogisticsDashboard> {
  String _selectedStatus = 'All';
  final List<String> _statusFilters = [
    'All', 'Pending', 'Assigned', 'Pickup Scheduled', 'Pickup In Progress', 
    'Picked Up', 'In Transit to Warehouse', 'Delivered to Warehouse', 
    'Warehouse Processing', 'Ready for Delivery', 'Delivery Scheduled', 
    'Delivery In Progress', 'Delivered to Customer', 'Completed', 'Cancelled'
  ];

  @override
  Widget build(BuildContext context) {
    final assignmentsAsync = ref.watch(logisticsAssignmentsProvider(widget.user.id));
    final warehousesAsync = ref.watch(availableWarehousesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Logistics Dashboard - ${widget.user.name}'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RouteMapWidget(),
                ),
              );
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
                value: 'analytics',
                child: Text('Analytics'),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Text('Settings'),
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
                    'Manage your logistics assignments and track deliveries',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            
            // Analytics Cards
            assignmentsAsync.when(
              data: (assignments) => _buildAnalyticsCards(assignments),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
            
            // Status Filter
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Assignments',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                ),
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
                ],
              ),
            ),
            
            // Assignments List
            assignmentsAsync.when(
              data: (assignments) {
                print('🚚 [LOGISTICS_DASHBOARD] Received ${assignments.length} assignments');
                print('🚚 [LOGISTICS_DASHBOARD] Selected status filter: $_selectedStatus');
                
                final filteredAssignments = _filterAssignments(assignments);
                print('🚚 [LOGISTICS_DASHBOARD] After filtering: ${filteredAssignments.length} assignments');
                
                // Debug: Print all assignment statuses
                for (var assignment in assignments) {
                  print('🚚 [LOGISTICS_DASHBOARD] Assignment ${assignment.id}: ${assignment.statusDisplayName}');
                }
                
                if (filteredAssignments.isEmpty) {
                  return Column(
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 48,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No assignments found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'There are no logistics assignments for your account yet.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 16),
                                        // Debug button to create test data
            if (kDebugMode)
              ElevatedButton.icon(
                onPressed: () => _createTestData(),
                icon: const Icon(Icons.add),
                label: const Text('Create Test Data (Debug)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            const SizedBox(height: 8),
            // Button to assign available pickup requests
            ElevatedButton.icon(
              onPressed: () => _assignAvailablePickupRequests(),
              icon: const Icon(Icons.assignment),
              label: const Text('Assign Available Pickup Requests'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                  
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredAssignments.length,
                    itemBuilder: (context, index) {
                      final assignment = filteredAssignments[index];
                      return LogisticsAssignmentCard(
                        assignment: assignment,
                        onStatusUpdate: () => _updateAssignmentStatus(assignment),
                        onWarehouseAssign: assignment.assignedWarehouseId == null 
                            ? () => _assignWarehouse(assignment, warehousesAsync)
                            : null,
                        onViewDetails: () => _showAssignmentDetails(assignment),
                      );
                    },
                  ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                    Text('Error loading assignments: $error'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RouteMapWidget(),
            ),
          );
        },
        icon: const Icon(Icons.navigation),
        label: const Text('Navigate'),
      ),
    );
  }

  Widget _buildAnalyticsCards(List<LogisticsAssignmentModel> assignments) {
    final total = assignments.length;
    final pending = assignments.where((a) => a.isPending).length;
    final inProgress = assignments.where((a) => a.isInProgress).length;
    final completed = assignments.where((a) => a.isCompleted).length;
    final totalWeight = assignments.fold<double>(0, (sum, a) => sum + a.estimatedWeight);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
            'Overview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildAnalyticsCard(
                  'Total Assignments',
                  '$total',
                  Icons.assignment,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnalyticsCard(
                  'In Progress',
                  '$inProgress',
                  Icons.pending,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildAnalyticsCard(
                  'Completed',
                  '$completed',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnalyticsCard(
                  'Total Weight',
                  '${totalWeight.toStringAsFixed(1)}kg',
                  Icons.scale,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<LogisticsAssignmentModel> _filterAssignments(List<LogisticsAssignmentModel> assignments) {
    print('🚚 [LOGISTICS_DASHBOARD] Filtering assignments with status: $_selectedStatus');
    print('🚚 [LOGISTICS_DASHBOARD] Available statuses: ${assignments.map((a) => a.statusDisplayName).toSet().toList()}');
    
    if (_selectedStatus == 'All') {
      print('🚚 [LOGISTICS_DASHBOARD] Showing all assignments (${assignments.length})');
      return assignments;
    }
    
    final filtered = assignments.where((assignment) {
      final matches = assignment.statusDisplayName == _selectedStatus;
      print('🚚 [LOGISTICS_DASHBOARD] Assignment ${assignment.id}: ${assignment.statusDisplayName} matches $_selectedStatus? $matches');
      return matches;
    }).toList();
    
    print('🚚 [LOGISTICS_DASHBOARD] Filtered to ${filtered.length} assignments');
    return filtered;
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'profile':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
        break;
      case 'analytics':
        // TODO: Navigate to analytics page
        break;
      case 'settings':
        // TODO: Navigate to settings page
        break;
      case 'logout':
        ref.read(loginProvider.notifier).signOut();
        break;
    }
  }

  void _updateAssignmentStatus(LogisticsAssignmentModel assignment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Assignment Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Status: ${assignment.statusDisplayName}', 
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 16),
            const Text('Select new status:'),
            const SizedBox(height: 8),
            ...LogisticsAssignmentStatus.values.map((status) {
              final isCurrent = assignment.status == status;
              final isCompleted = assignment.status.index >= status.index;
              
              return ListTile(
                title: Text(_getStatusDisplayName(status)),
                subtitle: isCurrent ? const Text('Current Status', style: TextStyle(color: Colors.blue)) : null,
                leading: Radio<LogisticsAssignmentStatus>(
                  value: status,
                  groupValue: assignment.status,
                  onChanged: (value) {
                    Navigator.pop(context);
                    _performStatusUpdate(assignment.id, value!);
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

  void _assignWarehouse(LogisticsAssignmentModel assignment, AsyncValue<List<Map<String, dynamic>>> warehousesAsync) {
    warehousesAsync.when(
      data: (warehouses) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Assign Warehouse'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select warehouse for this assignment:'),
                const SizedBox(height: 16),
                ...warehouses.map((warehouse) {
                  return ListTile(
                    title: Text(warehouse['name'] ?? 'Unknown Warehouse'),
                    subtitle: Text(warehouse['address'] ?? 'No address'),
                    leading: const Icon(Icons.warehouse),
                    onTap: () {
                      Navigator.pop(context);
                      _performWarehouseAssignment(
                        assignment.id,
                        warehouse['id'],
                        warehouse['name'],
                        warehouse['type'] ?? 'mainWarehouse',
                        warehouse['address'],
                      );
                    },
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
      },
      loading: () => showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          content: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to load warehouses: $error'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignmentDetails(LogisticsAssignmentModel assignment) {
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
                  'Assignment Details',
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
                    _buildDetailRow('Assignment ID', assignment.id),
                    _buildDetailRow('Type', assignment.assignmentTypeDisplayName),
                    _buildDetailRow('Status', assignment.statusDisplayName),
                    if (assignment.type == LogisticsAssignmentType.pickup) ...[
                      _buildDetailRow('Tailor', assignment.tailorName ?? 'Unknown'),
                      _buildDetailRow('Tailor Phone', assignment.tailorPhone ?? 'N/A'),
                      _buildDetailRow('From Address', assignment.sourceAddress),
                    ] else ...[
                      _buildDetailRow('Customer', assignment.customerName ?? 'Unknown'),
                      _buildDetailRow('Customer Phone', assignment.customerPhone ?? 'N/A'),
                      _buildDetailRow('Customer Email', assignment.customerEmail ?? 'N/A'),
                      _buildDetailRow('To Address', assignment.destinationAddress),
                    ],
                    _buildDetailRow('Fabric Type', assignment.fabricType),
                    _buildDetailRow('Description', assignment.fabricDescription),
                    _buildDetailRow('Weight', assignment.formattedWeight),
                    if (assignment.assignedWarehouseName != null)
                      _buildDetailRow('Warehouse', assignment.assignedWarehouseName!),
                    if (assignment.warehouseAddress != null)
                      _buildDetailRow('Warehouse Address', assignment.warehouseAddress!),
                    _buildDetailRow('Created', _formatDate(assignment.createdAt)),
                    if (assignment.notes != null && assignment.notes!.isNotEmpty)
                      _buildDetailRow('Notes', assignment.notes!),
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

  String _getStatusDisplayName(LogisticsAssignmentStatus status) {
    switch (status) {
      case LogisticsAssignmentStatus.pending:
        return 'Pending';
      case LogisticsAssignmentStatus.assigned:
        return 'Assigned';
      case LogisticsAssignmentStatus.inProgress:
        return 'In Progress';
      case LogisticsAssignmentStatus.completed:
        return 'Completed';
      case LogisticsAssignmentStatus.cancelled:
        return 'Cancelled';
    }
  }

  void _performStatusUpdate(String assignmentId, LogisticsAssignmentStatus status) {
    final repository = ref.read(logisticsRepositoryProvider);
    repository.updateLogisticsAssignmentStatus(assignmentId, status).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status updated to ${_getStatusDisplayName(status)}'),
          backgroundColor: Colors.green,
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating status: $error'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  void _performWarehouseAssignment(String assignmentId, String warehouseId, String warehouseName, String warehouseType, String warehouseAddress) {
    final repository = ref.read(logisticsRepositoryProvider);
    final warehouseTypeEnum = _parseWarehouseType(warehouseType);
    
    repository.assignWarehouse(assignmentId, warehouseId, warehouseName, warehouseTypeEnum, warehouseAddress).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Warehouse assigned: $warehouseName'),
          backgroundColor: Colors.green,
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error assigning warehouse: $error'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  WarehouseType _parseWarehouseType(String type) {
    switch (type.toLowerCase()) {
      case 'mainwarehouse':
        return WarehouseType.mainWarehouse;
      case 'processingwarehouse':
        return WarehouseType.processingWarehouse;
      case 'distributionwarehouse':
        return WarehouseType.distributionWarehouse;
      case 'regionalwarehouse':
        return WarehouseType.regionalWarehouse;
      default:
        return WarehouseType.mainWarehouse;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _createTestData() {
    final repository = ref.read(logisticsRepositoryProvider);
    final user = widget.user;

    // Create a pickup assignment (tailor to warehouse)
    final pickupAssignment = LogisticsAssignmentModel(
      id: 'pickup-${DateTime.now().millisecondsSinceEpoch}',
      logisticsId: user.id,
      pickupRequestId: 'test-pickup-${DateTime.now().millisecondsSinceEpoch}',
      type: LogisticsAssignmentType.pickup,
      tailorId: 'test-tailor-${DateTime.now().millisecondsSinceEpoch}',
      tailorName: 'Test Tailor ${DateTime.now().millisecondsSinceEpoch}',
      tailorAddress: '123 Tailor St, Test City',
      tailorPhone: '123-456-7890',
      fabricType: 'Test Fabric',
      fabricDescription: 'A description for a test pickup assignment',
      estimatedWeight: 100.0,
      status: LogisticsAssignmentStatus.pending,
      assignedWarehouseId: 'test-warehouse-${DateTime.now().millisecondsSinceEpoch}',
      assignedWarehouseName: 'Test Warehouse ${DateTime.now().millisecondsSinceEpoch}',
      warehouseAddress: '101 Warehouse Lane, Test City',
      warehouseType: WarehouseType.mainWarehouse,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      notes: 'This is a test pickup assignment created for debugging.',
    );

    // Create a delivery assignment (warehouse to customer)
    final deliveryAssignment = LogisticsAssignmentModel(
      id: 'delivery-${DateTime.now().millisecondsSinceEpoch}',
      logisticsId: user.id,
      pickupRequestId: 'test-pickup-${DateTime.now().millisecondsSinceEpoch}',
      type: LogisticsAssignmentType.delivery,
      customerName: 'Test Customer ${DateTime.now().millisecondsSinceEpoch}',
      customerPhone: '987-654-3210',
      customerEmail: 'customer.test@example.com',
      customerAddress: '456 Customer Ave, Test Town',
      fabricType: 'Test Fabric',
      fabricDescription: 'A description for a test delivery assignment',
      estimatedWeight: 100.0,
      status: LogisticsAssignmentStatus.pending,
      assignedWarehouseId: 'test-warehouse-${DateTime.now().millisecondsSinceEpoch}',
      assignedWarehouseName: 'Test Warehouse ${DateTime.now().millisecondsSinceEpoch}',
      warehouseAddress: '101 Warehouse Lane, Test City',
      warehouseType: WarehouseType.mainWarehouse,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      notes: 'This is a test delivery assignment created for debugging.',
    );

    // Create pickup assignment
    repository.createLogisticsAssignment(pickupAssignment).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Test pickup assignment created successfully!'),
          backgroundColor: Colors.blue,
        ),
      );
      // Refresh assignments to show the new one
      ref.invalidate(logisticsAssignmentsProvider(user.id));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating test pickup assignment: $error'),
          backgroundColor: Colors.red,
        ),
      );
    });

    // Create delivery assignment
    repository.createLogisticsAssignment(deliveryAssignment).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Test delivery assignment created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      // Refresh assignments to show the new one
      ref.invalidate(logisticsAssignmentsProvider(user.id));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating test delivery assignment: $error'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  void _assignAvailablePickupRequests() async {
    final repository = ref.read(logisticsRepositoryProvider);
    final user = widget.user;

    try {
      print('🚚 [LOGISTICS_DASHBOARD] Assigning available pickup requests to logistics: ${user.id}');
      
      // Get available pickup requests
      final availableRequests = await repository.getAvailablePickupRequests().first;
      
      if (availableRequests.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No available pickup requests to assign'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      print('🚚 [LOGISTICS_DASHBOARD] Found ${availableRequests.length} available pickup requests');
      
      // Assign each available request to this logistics user
      int assignedCount = 0;
      for (final request in availableRequests) {
        try {
          await repository.assignLogisticsToPickupRequest(request['id'], user.id);
          assignedCount++;
          print('🚚 [LOGISTICS_DASHBOARD] ✅ Assigned pickup request: ${request['id']}');
        } catch (e) {
          print('🚚 [LOGISTICS_DASHBOARD] ❌ Error assigning pickup request ${request['id']}: $e');
        }
      }

      // Refresh assignments to show the new ones
      ref.invalidate(logisticsAssignmentsProvider(user.id));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully assigned $assignedCount pickup requests!'),
          backgroundColor: Colors.green,
        ),
      );
      
      print('🚚 [LOGISTICS_DASHBOARD] ✅ Completed assigning pickup requests');
    } catch (e) {
      print('🚚 [LOGISTICS_DASHBOARD] ❌ Error in _assignAvailablePickupRequests: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error assigning pickup requests: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
