import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';

class WarehouseManagementPage extends ConsumerStatefulWidget {
  const WarehouseManagementPage({super.key});

  @override
  ConsumerState<WarehouseManagementPage> createState() => _WarehouseManagementPageState();
}

class _WarehouseManagementPageState extends ConsumerState<WarehouseManagementPage> {
  String _searchQuery = '';
  String _selectedStatus = 'All';

  @override
  Widget build(BuildContext context) {
    final warehouses = ref.watch(allWarehousesProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.warehouse,
                color: Theme.of(context).primaryColor,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Warehouse Management',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddWarehouseDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Warehouse'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Filters
          _buildFilters(),
          const SizedBox(height: 16),

          // Warehouses List
          Expanded(
            child: warehouses.when(
              data: (warehousesList) {
                final filteredWarehouses = _filterWarehouses(warehousesList);
                
                if (filteredWarehouses.isEmpty) {
                  return const Center(
                    child: Text('No warehouses found'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredWarehouses.length,
                  itemBuilder: (context, index) {
                    final warehouse = filteredWarehouses[index];
                    return _buildWarehouseCard(context, warehouse);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error loading warehouses: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 160,
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search warehouses...',
                  prefixIcon: Icon(Icons.search, size: 18),
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                ),
                style: const TextStyle(fontSize: 13),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            SizedBox(
              width: 80,
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                ),
                value: _selectedStatus,
                items: ['All', 'active', 'inactive', 'maintenance'].map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(
                      status.toUpperCase(),
                      style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
                style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarehouseCard(BuildContext context, Map<String, dynamic> warehouse) {
    final status = warehouse['status'] ?? 'unknown';
    final capacity = warehouse['capacity'] ?? 0;
    final location = warehouse['location'] ?? 'Unknown';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(status),
          child: const Icon(
            Icons.warehouse,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          warehouse['name'] ?? 'Unknown Warehouse',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Location: $location'),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Capacity: $capacity',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Text('Edit'),
            ),
            const PopupMenuItem(
              value: 'view',
              child: Text('View Details'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
          onSelected: (value) => _handleWarehouseAction(context, warehouse, value),
        ),
        onTap: () => _showWarehouseDetails(context, warehouse),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.red;
      case 'maintenance':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  List<Map<String, dynamic>> _filterWarehouses(List<Map<String, dynamic>> warehouses) {
    return warehouses.where((warehouse) {
      // Search filter
      final name = (warehouse['name'] ?? '').toString().toLowerCase();
      final location = (warehouse['location'] ?? '').toString().toLowerCase();
      final matchesSearch = name.contains(_searchQuery.toLowerCase()) ||
          location.contains(_searchQuery.toLowerCase());

      // Status filter
      final matchesStatus = _selectedStatus == 'All' || 
          (warehouse['status'] ?? '').toString().toLowerCase() == _selectedStatus.toLowerCase();

      return matchesSearch && matchesStatus;
    }).toList();
  }

  void _handleWarehouseAction(BuildContext context, Map<String, dynamic> warehouse, String action) {
    switch (action) {
      case 'edit':
        _showEditWarehouseDialog(context, warehouse);
        break;
      case 'view':
        _showWarehouseDetails(context, warehouse);
        break;
      case 'delete':
        _showDeleteWarehouseDialog(context, warehouse);
        break;
    }
  }

  void _showWarehouseDetails(BuildContext context, Map<String, dynamic> warehouse) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Warehouse Details - ${warehouse['name']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Name: ${warehouse['name']}'),
              const SizedBox(height: 8),
              Text('Location: ${warehouse['location']}'),
              const SizedBox(height: 8),
              Text('Capacity: ${warehouse['capacity']}'),
              const SizedBox(height: 8),
              Text('Status: ${warehouse['status']}'),
              const SizedBox(height: 8),
              Text('Manager: ${warehouse['manager_name'] ?? 'Not assigned'}'),
              const SizedBox(height: 8),
              Text('Manager Email: ${warehouse['manager_email'] ?? 'Not provided'}'),
              const SizedBox(height: 8),
              Text('Manager Phone: ${warehouse['manager_phone'] ?? 'Not provided'}'),
              const SizedBox(height: 8),
              Text('Created: ${_formatDate(warehouse['created_at'])}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAddWarehouseDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _locationController = TextEditingController();
    final _capacityController = TextEditingController();
    final _managerNameController = TextEditingController();
    final _managerEmailController = TextEditingController();
    final _managerPhoneController = TextEditingController();
    final _passwordController = TextEditingController();
    String _selectedStatus = 'active';
    bool _isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Warehouse'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Warehouse Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter warehouse name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter location';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _capacityController,
                    decoration: const InputDecoration(
                      labelText: 'Capacity',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter capacity';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _managerNameController,
                    decoration: const InputDecoration(
                      labelText: 'Manager Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _managerEmailController,
                    decoration: const InputDecoration(
                      labelText: 'Manager Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _managerPhoneController,
                    decoration: const InputDecoration(
                      labelText: 'Manager Phone',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedStatus,
                    items: ['active', 'inactive', 'maintenance'].map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _isLoading = true;
                        });

                        try {
                          final warehouseData = {
                            'name': _nameController.text,
                            'location': _locationController.text,
                            'capacity': int.tryParse(_capacityController.text) ?? 1000,
                            'manager_name': _managerNameController.text,
                            'manager_email': _managerEmailController.text,
                            'manager_phone': _managerPhoneController.text,
                            'password': _passwordController.text,
                            'status': _selectedStatus,
                          };

                          final success = await ref.read(createWarehouseProvider(warehouseData).future);
                          
                          if (success) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Warehouse created successfully! Manager can login with:\nEmail: ${_managerEmailController.text}\nPassword: ${_passwordController.text}'),
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 5),
                              ),
                            );
                            ref.invalidate(allWarehousesProvider);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to create warehouse. Please try again.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } finally {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
                    },
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create Warehouse'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditWarehouseDialog(BuildContext context, Map<String, dynamic> warehouse) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Warehouse - ${warehouse['name']}'),
        content: const Text('Warehouse editing functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteWarehouseDialog(BuildContext context, Map<String, dynamic> warehouse) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Warehouse'),
        content: Text('Are you sure you want to delete ${warehouse['name']}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final success = await ref.read(deleteWarehouseProvider(warehouse['id']).future);
              Navigator.of(context).pop();
              if (success) {
                ref.invalidate(allWarehousesProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Warehouse deleted successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to delete warehouse. Please try again.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Unknown';
    if (date is DateTime) {
      return '${date.day}/${date.month}/${date.year}';
    }
    if (date is String) {
      try {
        final dateTime = DateTime.parse(date);
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      } catch (e) {
        return date;
      }
    }
    return 'Unknown';
  }
} 