import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/warehouse_provider.dart';
import '../../data/models/warehouse_assignment_model.dart';
import '../../data/models/inventory_model.dart';

class AssignmentDetailsDialog extends ConsumerStatefulWidget {
  final WarehouseAssignmentModel assignment;

  const AssignmentDetailsDialog({
    super.key,
    required this.assignment,
  });

  @override
  ConsumerState<AssignmentDetailsDialog> createState() => _AssignmentDetailsDialogState();
}

class _AssignmentDetailsDialogState extends ConsumerState<AssignmentDetailsDialog> {
  String _newNotes = '';
  WarehouseSection? _selectedSection;
  InventoryModel? _existingInventory;
  bool _isCheckingInventory = false;

  @override
  void initState() {
    super.initState();
    _newNotes = widget.assignment.notes ?? '';
    _selectedSection = widget.assignment.warehouseSection;
    _checkExistingInventoryOnLoad();
  }

  Future<void> _checkExistingInventoryOnLoad() async {
    setState(() {
      _isCheckingInventory = true;
    });
    
    final existing = await _checkExistingInventory();
    setState(() {
      _existingInventory = existing;
      _isCheckingInventory = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Assignment Details',
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

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAssignmentHeader(),
                    const SizedBox(height: 20),
                    _buildLogisticsSection(),
                    const SizedBox(height: 20),
                    _buildTailorSection(),
                    const SizedBox(height: 20),
                    _buildProductSection(),
                    const SizedBox(height: 20),
                    _buildTimelineSection(),
                    const SizedBox(height: 20),
                    _buildActionsSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Assignment #${(widget.assignment.id ?? '').substring(0, 8)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                _buildStatusChip(widget.assignment),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Created: ${_formatDate(widget.assignment.createdAt)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            if (widget.assignment.isOverdue) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning, color: Colors.red[700], size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Overdue: ${widget.assignment.delayDisplay}',
                      style: TextStyle(
                        color: Colors.red[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            // Inventory Status
            const SizedBox(height: 8),
            Row(
              children: [
                if (_isCheckingInventory) ...[
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Checking inventory...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ] else if (_existingInventory != null) ...[
                  Icon(Icons.inventory_2, color: Colors.green[700], size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Inventory Created (ID: ${(_existingInventory!.id ?? '').substring(0, 8)})',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ] else ...[
                  Icon(Icons.inventory_2_outlined, color: Colors.grey[600], size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'No inventory created yet',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogisticsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_shipping, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Logistics Team',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Name', widget.assignment.logisticsName),
            _buildDetailRow('Phone', widget.assignment.logisticsPhone),
            _buildDetailRow('ID', widget.assignment.logisticsId),
          ],
        ),
      ),
    );
  }

  Widget _buildTailorSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Tailor Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Name', widget.assignment.tailorName),
            _buildDetailRow('Phone', widget.assignment.tailorPhone),
            _buildDetailRow('Address', widget.assignment.tailorAddress),
            _buildDetailRow('ID', widget.assignment.tailorId),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.inventory, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Product Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Fabric Type', widget.assignment.fabricType.toUpperCase()),
            _buildDetailRow('Description', widget.assignment.fabricDescription),
            _buildDetailRow('Estimated Weight', widget.assignment.formattedEstimatedWeight),
            _buildDetailRow('Actual Weight', widget.assignment.formattedActualWeight),
            _buildDetailRow('Estimated Value', widget.assignment.formattedEstimatedValue),
            _buildDetailRow('Actual Value', widget.assignment.formattedActualValue),
            _buildDetailRow('Pickup Request ID', widget.assignment.pickupRequestId),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Timeline',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Scheduled Arrival', widget.assignment.formattedScheduledTime),
            _buildDetailRow('Actual Arrival', widget.assignment.formattedActualTime),
            _buildDetailRow('Status', widget.assignment.statusDisplayName),
            if (widget.assignment.warehouseSection != null)
              _buildDetailRow('Warehouse Section', widget.assignment.warehouseSectionDisplayName),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.build, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Actions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Status Update Buttons
            if (widget.assignment.isScheduled || widget.assignment.isInTransit) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus(WarehouseAssignmentStatus.arrived),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Mark Arrived'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            if (widget.assignment.isArrived) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus(WarehouseAssignmentStatus.processing),
                      icon: const Icon(Icons.build),
                      label: const Text('Start Processing'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            if (widget.assignment.isProcessing) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus(WarehouseAssignmentStatus.completed),
                      icon: const Icon(Icons.done_all),
                      label: const Text('Mark Completed'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Warehouse Section Assignment
            const SizedBox(height: 12),
            Text(
              'Assign to Warehouse Section:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<WarehouseSection>(
              value: _selectedSection,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Warehouse Section',
              ),
              items: WarehouseSection.values.map((section) {
                return DropdownMenuItem(
                  value: section,
                  child: Text(_getSectionDisplayName(section)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSection = value;
                });
                if (value != null) {
                  _updateSection(value);
                }
              },
            ),

            // Notes Section
            const SizedBox(height: 16),
            Text(
              'Notes:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Add notes about this assignment...',
              ),
              controller: TextEditingController(text: _newNotes),
              onChanged: (value) {
                _newNotes = value;
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveNotes,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Notes'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(WarehouseAssignmentModel assignment) {
    Color chipColor;
    IconData chipIcon;
    
    switch (assignment.status) {
      case WarehouseAssignmentStatus.scheduled:
        chipColor = Colors.blue;
        chipIcon = Icons.schedule;
        break;
      case WarehouseAssignmentStatus.inTransit:
        chipColor = Colors.orange;
        chipIcon = Icons.local_shipping;
        break;
      case WarehouseAssignmentStatus.arrived:
        chipColor = Colors.green;
        chipIcon = Icons.check_circle;
        break;
      case WarehouseAssignmentStatus.processing:
        chipColor = Colors.purple;
        chipIcon = Icons.build;
        break;
      case WarehouseAssignmentStatus.completed:
        chipColor = Colors.grey;
        chipIcon = Icons.done_all;
        break;
      case WarehouseAssignmentStatus.cancelled:
        chipColor = Colors.red;
        chipIcon = Icons.cancel;
        break;
    }

    return Chip(
      avatar: Icon(chipIcon, color: Colors.white, size: 16),
      label: Text(
        assignment.statusDisplayName,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getSectionDisplayName(WarehouseSection section) {
    switch (section) {
      case WarehouseSection.receivingArea:
        return 'Receiving Area';
      case WarehouseSection.sortingArea:
        return 'Sorting Area';
      case WarehouseSection.processingArea:
        return 'Processing Area';
      case WarehouseSection.storageArea:
        return 'Storage Area';
      case WarehouseSection.qualityCheckArea:
        return 'Quality Check Area';
      case WarehouseSection.dispatchArea:
        return 'Dispatch Area';
    }
  }

  void _updateStatus(WarehouseAssignmentStatus status) async {
    try {
      await ref.read(warehouseNotifierProvider.notifier).updateAssignmentStatus(
        widget.assignment.id!,
        status,
      );
      
      // Automatically create inventory item when assignment is marked as arrived or processing
      if (status == WarehouseAssignmentStatus.arrived || status == WarehouseAssignmentStatus.processing) {
        await _createInventoryFromAssignment();
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to ${status.toString().split('.').last}'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createInventoryFromAssignment() async {
    try {
      print('🏭 [ASSIGNMENT_DIALOG] Creating inventory item from assignment: ${widget.assignment.id}');
      
      // Check if inventory item already exists for this assignment
      final existingInventory = await _checkExistingInventory();
      if (existingInventory != null) {
        print('🏭 [ASSIGNMENT_DIALOG] ⚠️ Inventory item already exists for assignment: ${existingInventory.id}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Inventory item already exists (ID: ${existingInventory.id})'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }
      
      // Create inventory item from assignment data
      final inventoryItem = InventoryModel(
        warehouseId: widget.assignment.warehouseId,
        pickupId: widget.assignment.pickupRequestId,
        fabricCategory: widget.assignment.fabricType,
        qualityGrade: 'pending', // Will be updated during processing
        actualWeight: widget.assignment.actualWeight,
        estimatedWeight: widget.assignment.estimatedWeight,
        warehouseLocation: _getSectionDisplayName(widget.assignment.warehouseSection ?? WarehouseSection.receivingArea),
        supplierName: widget.assignment.tailorName,
        batchNumber: 'BATCH-${DateTime.now().millisecondsSinceEpoch}',
        costPerKg: null, // Will be set during processing
        status: InventoryStatus.processing,
        processingData: {
          'assignmentId': widget.assignment.id,
          'logisticsId': widget.assignment.logisticsId,
          'logisticsName': widget.assignment.logisticsName,
          'tailorId': widget.assignment.tailorId,
          'tailorName': widget.assignment.tailorName,
          'fabricDescription': widget.assignment.fabricDescription,
          'estimatedValue': widget.assignment.estimatedValue,
          'actualValue': widget.assignment.actualValue,
        },
        qualityData: null,
        processedDate: null,
        expiryDate: null,
        notes: widget.assignment.notes ?? 'Created from assignment ${widget.assignment.id}',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Create the inventory item
      await ref.read(warehouseNotifierProvider.notifier).createInventoryItem(inventoryItem);
      
      print('🏭 [ASSIGNMENT_DIALOG] ✅ Inventory item created successfully from assignment');
      
      // Refresh inventory status
      await _checkExistingInventoryOnLoad();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inventory item created automatically'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('🏭 [ASSIGNMENT_DIALOG] ❌ Error creating inventory item: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating inventory item: $e'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<InventoryModel?> _checkExistingInventory() async {
    try {
      // Get all inventory items for this warehouse
      final inventoryItems = await ref.read(inventoryItemsProvider(widget.assignment.warehouseId).future);
      
      // Check if any inventory item has this assignment ID in its processing data
      for (final item in inventoryItems) {
        final assignmentId = item.processingData?['assignmentId'];
        if (assignmentId == widget.assignment.id) {
          return item;
        }
      }
      
      return null;
    } catch (e) {
      print('🏭 [ASSIGNMENT_DIALOG] ❌ Error checking existing inventory: $e');
      return null;
    }
  }

  void _updateSection(WarehouseSection section) async {
    try {
      await ref.read(warehouseNotifierProvider.notifier).updateAssignmentSection(
        widget.assignment.id!,
        section,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Section updated to ${_getSectionDisplayName(section)}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating section: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _saveNotes() async {
    try {
      await ref.read(warehouseNotifierProvider.notifier).addAssignmentNotes(
        widget.assignment.id!,
        _newNotes,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notes saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving notes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 