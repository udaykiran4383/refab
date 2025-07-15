import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../warehouse/data/models/warehouse_assignment_model.dart';
import '../../../warehouse/providers/warehouse_provider.dart';
import '../../data/models/logistics_assignment_model.dart';
import '../../../tailor/data/models/pickup_request_model.dart';
import '../../data/repositories/logistics_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// Provider for logistics repository
final logisticsRepositoryProvider = Provider<LogisticsRepository>((ref) {
  return LogisticsRepository();
});

// Using the availableWarehousesProvider from warehouse_provider.dart

class WarehouseAssignmentDialog extends ConsumerStatefulWidget {
  final LogisticsAssignmentModel logisticsAssignment;
  final PickupRequestModel pickupRequest;

  const WarehouseAssignmentDialog({
    super.key,
    required this.logisticsAssignment,
    required this.pickupRequest,
  });

  @override
  ConsumerState<WarehouseAssignmentDialog> createState() => _WarehouseAssignmentDialogState();
}

class _WarehouseAssignmentDialogState extends ConsumerState<WarehouseAssignmentDialog> {
  String? _selectedWarehouseId;
  Map<String, dynamic>? _selectedWarehouse;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final warehousesAsync = ref.watch(availableWarehousesProvider);
    final userAsync = ref.watch(authProvider);
    final currentUser = userAsync.asData?.value;

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Select Warehouse',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Assignment Info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assignment: ${widget.pickupRequest.customerName}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Fabric: ${widget.pickupRequest.fabricType.toString().split('.').last}'),
                      Text('Weight: ${widget.pickupRequest.estimatedWeight} kg'),
                      const SizedBox(height: 12),
                      // Warning about one-time assignment
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber, size: 20, color: Colors.orange[700]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Important Warning',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange[700],
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'You can assign yourself to a warehouse only ONCE. '
                                    'Once assigned, you cannot change the warehouse later.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.orange[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Warehouse Selection
              SizedBox(
                height: 220, // or another reasonable value for mobile
                child: warehousesAsync.when(
                  data: (warehouses) {
                    if (warehouses.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.warehouse_outlined, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No warehouses available',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Please contact admin to add warehouses',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available Warehouses',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView.builder(
                            itemCount: warehouses.length,
                            itemBuilder: (context, index) {
                              final warehouse = warehouses[index];
                              final isSelected = _selectedWarehouseId == warehouse['id'];
                              
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedWarehouseId = warehouse['id'];
                                      _selectedWarehouse = warehouse;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Radio<String>(
                                          value: warehouse['id'],
                                          groupValue: _selectedWarehouseId,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedWarehouseId = value;
                                              _selectedWarehouse = warehouse;
                                            });
                                          },
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                warehouse['name'] ?? 'Unknown Warehouse',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: isSelected ? Theme.of(context).colorScheme.onPrimaryContainer : null,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                warehouse['address'] ?? 'No address',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: isSelected ? Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8) : Colors.grey[600],
                                                ),
                                              ),
                                              if (warehouse['type'] != null) ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Type: ${warehouse['type']}',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: isSelected ? Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7) : Colors.grey[500],
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.warehouse,
                                          color: isSelected ? Theme.of(context).colorScheme.onPrimaryContainer : Colors.grey[400],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading warehouses...'),
                      ],
                    ),
                  ),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading warehouses',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.red[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.red[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Action Buttons
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading || _selectedWarehouseId == null
                          ? null
                          : () => _assignWarehouse(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Assign'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _assignWarehouse() async {
    if (_selectedWarehouseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a warehouse'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show confirmation dialog about one-time assignment
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange[700]),
            const SizedBox(width: 8),
            const Text('Confirm Assignment'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to assign yourself to:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _selectedWarehouse?['name'] ?? 'Selected Warehouse',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.orange[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This is a ONE-TIME assignment. You cannot change the warehouse later.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm Assignment'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return; // User cancelled
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('🏭 [WAREHOUSE_DIALOG] Starting assignment process...');
      
      final userAsync = ref.read(authProvider);
      final currentUser = userAsync.asData?.value;
      
      print('🏭 [WAREHOUSE_DIALOG] Current user: ${currentUser?.name}');

      print('🏭 [WAREHOUSE_DIALOG] About to update logistics assignment ${widget.logisticsAssignment.id}');
      print('🏭 [WAREHOUSE_DIALOG] Selected warehouse ID: $_selectedWarehouseId');
      print('🏭 [WAREHOUSE_DIALOG] Selected warehouse name: ${_selectedWarehouse?['name']}');
      
      // Update the logistics assignment to mark it as assigned to warehouse
      await ref.read(logisticsRepositoryProvider).assignWarehouse(
        widget.logisticsAssignment.id,
        _selectedWarehouseId!,
        _selectedWarehouse?['name'] ?? 'Unknown Warehouse',
        _parseWarehouseType(_selectedWarehouse?['type'] ?? 'mainWarehouse'),
        _selectedWarehouse?['address'] ?? 'No address',
      );
      
      print('🏭 [WAREHOUSE_DIALOG] ✅ Logistics assignment updated successfully');

      // Create a new warehouse assignment document
      final warehouseAssignment = WarehouseAssignmentModel(
        logisticsAssignmentId: widget.logisticsAssignment.id,
        warehouseId: _selectedWarehouseId!,
        logisticsId: widget.logisticsAssignment.logisticsId,
        logisticsName: currentUser?.name ?? 'Logistics User',
        logisticsPhone: currentUser?.phone ?? '+91-9876543210',
        pickupRequestId: widget.pickupRequest.id,
        tailorId: widget.pickupRequest.tailorId,
        tailorName: widget.pickupRequest.customerName,
        tailorAddress: widget.pickupRequest.pickupAddress,
        tailorPhone: widget.pickupRequest.customerPhone,
        fabricType: widget.pickupRequest.fabricType.toString().split('.').last,
        fabricDescription: widget.pickupRequest.fabricDescription,
        estimatedWeight: widget.pickupRequest.estimatedWeight,
        actualWeight: widget.pickupRequest.actualWeight,
        estimatedValue: widget.pickupRequest.estimatedValue,
        actualValue: widget.pickupRequest.actualValue,
        status: WarehouseAssignmentStatus.scheduled,
        scheduledArrivalTime: DateTime.now().add(const Duration(hours: 1)), // Default to 1 hour from now
        warehouseSection: WarehouseSection.receivingArea, // Default section
        notes: null,
        specialInstructions: null,
        photos: null,
        metadata: null,
        createdAt: DateTime.now(),
      );

      print('🏭 [WAREHOUSE_DIALOG] About to create new warehouse assignment document');
      final assignmentId = await ref.read(warehouseNotifierProvider.notifier).createWarehouseAssignment(warehouseAssignment);
      print('🏭 [WAREHOUSE_DIALOG] ✅ New warehouse assignment document created with ID: $assignmentId');

      // Invalidate warehouse and logistics providers to refresh data
      ref.invalidate(availableWarehousesProvider);
      if (_selectedWarehouseId != null) {
        ref.invalidate(warehouseByIdProvider(_selectedWarehouseId!));
      }

      // Notify the warehouse of the new assignment
      try {
        await ref.read(logisticsRepositoryProvider).notifyWarehouseOfAssignment(
          _selectedWarehouseId!,
          assignmentId,
          warehouseAssignment.toJson(),
        );
        print('🏭 [WAREHOUSE_DIALOG] ✅ Warehouse notified of new assignment');
      } catch (e) {
        print('🏭 [WAREHOUSE_DIALOG] ⚠️ Failed to notify warehouse: $e');
        // Don't fail the assignment if notification fails
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully assigned to ${_selectedWarehouse?['name'] ?? 'selected warehouse'}'),
            backgroundColor: Colors.green,
          ),
        );
        print('🏭 [WAREHOUSE_DIALOG] ✅ Assignment completed, closing dialog with result: true');
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      print('🏭 [WAREHOUSE_DIALOG] ❌ Error in assignment process: $e');
      print('🏭 [WAREHOUSE_DIALOG] ❌ Error type: ${e.runtimeType}');
      if (e is FirebaseException) {
        print('🏭 [WAREHOUSE_DIALOG] ❌ Firebase error code: ${e.code}');
        print('🏭 [WAREHOUSE_DIALOG] ❌ Firebase error message: ${e.message}');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error assigning warehouse: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      print('🏭 [WAREHOUSE_DIALOG] Setting loading to false');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
} 