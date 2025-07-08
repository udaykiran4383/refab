import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:refab_app/features/warehouse/providers/warehouse_provider.dart';
import 'package:refab_app/features/warehouse/data/models/inventory_model.dart';
import 'package:refab_app/features/warehouse/presentation/widgets/inventory_card.dart';

class InventoryManagementTab extends ConsumerStatefulWidget {
  const InventoryManagementTab({super.key});

  @override
  ConsumerState<InventoryManagementTab> createState() => _InventoryManagementTabState();
}

class _InventoryManagementTabState extends ConsumerState<InventoryManagementTab> {
  String _selectedStatus = 'all';
  String _selectedCategory = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final warehouseId = ref.watch(warehouseIdProvider);
    final inventoryAsync = ref.watch(inventoryItemsProvider(warehouseId));

    return Column(
      children: [
        // Filters and Search
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search inventory...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              // Filter Row
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(value: 'all', child: Text('All Status')),
                        ...InventoryStatus.values.map((status) => DropdownMenuItem(
                          value: status.toString().split('.').last,
                          child: Text(status.toString().split('.').last),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(value: 'all', child: Text('All Categories')),
                        const DropdownMenuItem(value: 'cotton', child: Text('Cotton')),
                        const DropdownMenuItem(value: 'silk', child: Text('Silk')),
                        const DropdownMenuItem(value: 'polyester', child: Text('Polyester')),
                        const DropdownMenuItem(value: 'wool', child: Text('Wool')),
                        const DropdownMenuItem(value: 'linen', child: Text('Linen')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Quick Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showBatchProcessingDialog(),
                      icon: const Icon(Icons.batch_prediction),
                      label: const Text('Batch Process'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showMoveToReadyDialog(),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Move to Ready'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[800],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Inventory List
        Expanded(
          child: inventoryAsync.when(
            data: (inventory) {
              final filteredInventory = _filterInventory(inventory);
              
              if (filteredInventory.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No inventory items found'),
                      Text('Try adjusting your filters'),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredInventory.length,
                itemBuilder: (context, index) {
                  final item = filteredInventory[index];
                  return InventoryCard(
                    inventory: item,
                    onTap: () => _showInventoryDetails(item),
                    onStatusChange: (status) {
                      if (status != null) {
                        _updateItemStatus(item.id, status);
                      }
                    },
                    onEdit: () => _editInventoryItem(item),
                    onDelete: () => _deleteInventoryItem(item.id),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: $error'),
                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(inventoryItemsProvider(warehouseId));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<InventoryModel> _filterInventory(List<InventoryModel> inventory) {
    return inventory.where((item) {
      // Status filter
      if (_selectedStatus != 'all' && 
          item.status.toString().split('.').last != _selectedStatus) {
        return false;
      }
      
      // Category filter
      if (_selectedCategory != 'all' && 
          item.fabricCategory.toLowerCase() != _selectedCategory) {
        return false;
      }
      
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return item.fabricCategory.toLowerCase().contains(query) ||
               item.qualityGrade.toLowerCase().contains(query) ||
               item.id.toLowerCase().contains(query) ||
               (item.supplierName?.toLowerCase().contains(query) ?? false) ||
               (item.batchNumber?.toLowerCase().contains(query) ?? false);
      }
      
      return true;
    }).toList();
  }

  void _showInventoryDetails(InventoryModel item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Inventory Item: ${item.id}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Category', item.fabricCategory),
              _buildDetailRow('Quality Grade', item.qualityGrade),
              _buildDetailRow('Weight', item.formattedWeight),
              _buildDetailRow('Status', item.statusLabel),
              _buildDetailRow('Location', item.warehouseLocation ?? 'Not assigned'),
              _buildDetailRow('Supplier', item.supplierName ?? 'Not specified'),
              _buildDetailRow('Batch Number', item.batchNumber ?? 'Not specified'),
              _buildDetailRow('Cost', item.formattedCost),
              _buildDetailRow('Created', _formatDate(item.createdAt)),
              if (item.processedDate != null)
                _buildDetailRow('Processed', _formatDate(item.processedDate!)),
              if (item.notes != null)
                _buildDetailRow('Notes', item.notes!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _editInventoryItem(item);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  void _updateItemStatus(String itemId, InventoryStatus status) {
    ref.read(warehouseNotifierProvider.notifier).updateInventoryStatus(itemId, status);
  }

  void _editInventoryItem(InventoryModel item) {
    // TODO: Navigate to edit inventory item page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit functionality coming soon!')),
    );
  }

  void _deleteInventoryItem(String itemId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Inventory Item'),
        content: const Text('Are you sure you want to delete this inventory item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(warehouseNotifierProvider.notifier).deleteInventoryItem(itemId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showBatchProcessingDialog() {
    // TODO: Implement batch processing dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Batch processing coming soon!')),
    );
  }

  void _showMoveToReadyDialog() {
    // TODO: Implement move to ready dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Move to ready functionality coming soon!')),
    );
  }
} 