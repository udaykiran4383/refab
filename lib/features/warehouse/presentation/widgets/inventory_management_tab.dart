import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../warehouse/data/models/inventory_model.dart';
import '../../../warehouse/providers/warehouse_provider.dart';

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
    const warehouseId = 'main_warehouse'; // TODO: Get from user context
    final inventoryAsync = ref.watch(inventoryItemsProvider(warehouseId));

    return Column(
      children: [
        // Enhanced Search and Filters
        Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Enhanced Search Bar
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.grey[50]!,
                        Colors.white,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '🔍 Search inventory...',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.search,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                
                // Enhanced Filters
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary.withOpacity(0.05),
                              Theme.of(context).colorScheme.primary.withOpacity(0.02),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedStatus,
                          decoration: InputDecoration(
                            labelText: 'Status',
                            labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            prefixIcon: Icon(
                              Icons.filter_list,
                              color: Theme.of(context).colorScheme.primary,
                              size: 18,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('All', style: TextStyle(fontSize: 12))),
                            DropdownMenuItem(value: 'processing', child: Text('Processing', style: TextStyle(fontSize: 12))),
                            DropdownMenuItem(value: 'graded', child: Text('Graded', style: TextStyle(fontSize: 12))),
                            DropdownMenuItem(value: 'ready', child: Text('Ready', style: TextStyle(fontSize: 12))),
                            DropdownMenuItem(value: 'lowStock', child: Text('Low Stock', style: TextStyle(fontSize: 12))),
                            DropdownMenuItem(value: 'damaged', child: Text('Damaged', style: TextStyle(fontSize: 12))),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedStatus = value!;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.secondary.withOpacity(0.05),
                              Theme.of(context).colorScheme.secondary.withOpacity(0.02),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: InputDecoration(
                            labelText: 'Category',
                            labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            prefixIcon: Icon(
                              Icons.category,
                              color: Theme.of(context).colorScheme.secondary,
                              size: 18,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('All', style: TextStyle(fontSize: 12))),
                            DropdownMenuItem(value: 'cotton', child: Text('Cotton', style: TextStyle(fontSize: 12))),
                            DropdownMenuItem(value: 'silk', child: Text('Silk', style: TextStyle(fontSize: 12))),
                            DropdownMenuItem(value: 'polyester', child: Text('Polyester', style: TextStyle(fontSize: 12))),
                            DropdownMenuItem(value: 'wool', child: Text('Wool', style: TextStyle(fontSize: 12))),
                            DropdownMenuItem(value: 'linen', child: Text('Linen', style: TextStyle(fontSize: 12))),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value!;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        // Inventory List
        Expanded(
          child: inventoryAsync.when(
            data: (inventory) {
              final filteredInventory = _filterInventory(inventory);
              
              if (filteredInventory.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.grey[100]!,
                              Colors.grey[50]!,
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No inventory items found',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your first inventory item to get started',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: filteredInventory.length,
                itemBuilder: (context, index) {
                  final item = filteredInventory[index];
                  return _buildInventoryCard(item);
                },
              );
            },
            loading: () => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading inventory...'),
                ],
              ),
            ),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading inventory',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryCard(InventoryModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey[50]!,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showInventoryDetails(item),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Enhanced Status indicator
                    Container(
                      width: 6,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getStatusColor(item.status),
                            _getStatusColor(item.status).withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: _getStatusColor(item.status).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Inventory details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.fabricCategory} - ${item.qualityGrade}',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                    fontSize: 18,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      _getStatusColor(item.status).withOpacity(0.1),
                                      _getStatusColor(item.status).withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _getStatusColor(item.status).withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  item.statusLabel.toUpperCase(),
                                  style: TextStyle(
                                    color: _getStatusColor(item.status),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // Enhanced info rows
                          _buildInventoryInfoRow(
                            Icons.scale,
                            item.formattedWeight,
                            Icons.location_on,
                            item.warehouseLocation ?? 'Not assigned',
                          ),
                          const SizedBox(height: 8),
                          _buildInventoryInfoRow(
                            Icons.attach_money,
                            item.formattedCost,
                            Icons.calendar_today,
                            _formatDate(item.createdAt),
                          ),
                          if (item.id != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.tag, size: 16, color: Colors.grey[600]),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'ID: ${item.id!.substring(0, 8)}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'monospace',
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Special indicators
                if (item.needsAttention) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange[50]!,
                          Colors.orange[100]!,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.orange[200]!,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning, color: Colors.orange[700], size: 16),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            item.isLowStock ? 'Low Stock' : 
                            item.isDamaged ? 'Damaged' : 
                            item.isExpired ? 'Expired' : 'Needs Attention',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInventoryInfoRow(IconData icon1, String text1, IconData icon2, String text2) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon1, size: 16, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text1,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon2, size: 16, color: Theme.of(context).colorScheme.secondary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text2,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(InventoryStatus status) {
    switch (status) {
      case InventoryStatus.processing:
        return Colors.orange;
      case InventoryStatus.graded:
        return Colors.blue;
      case InventoryStatus.ready:
        return Colors.green;
      case InventoryStatus.used:
        return Colors.grey;
      case InventoryStatus.lowStock:
        return Colors.red;
      case InventoryStatus.reserved:
        return Colors.purple;
      case InventoryStatus.damaged:
        return Colors.red;
    }
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
               (item.id?.toLowerCase().contains(query) ?? false) ||
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
        title: Text('Inventory Item: ${item.id ?? 'New Item'}'),
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
    return '${date.day}/${date.month}/${date.year}';
  }

  void _editInventoryItem(InventoryModel item) {
    // TODO: Implement edit functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit ${item.id ?? 'New Item'} - Coming soon!')),
    );
  }
} 