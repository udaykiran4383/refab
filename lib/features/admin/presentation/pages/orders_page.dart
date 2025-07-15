import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';

class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({super.key});

  @override
  ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage> {
  String _selectedStatus = 'All';

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(allOrdersProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.shopping_cart,
                color: Theme.of(context).primaryColor,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Order Management',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Filters
          _buildFilters(),
          const SizedBox(height: 16),

          // Orders List
          Expanded(
            child: orders.when(
              data: (ordersList) {
                final filteredOrders = _filterOrders(ordersList);
                
                if (filteredOrders.isEmpty) {
                  return const Center(
                    child: Text('No orders found'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return _buildOrderCard(context, order);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error loading orders: $error'),
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
        child: SizedBox(
          width: 140,
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            ),
            value: _selectedStatus,
            items: ['All', 'pending', 'processing', 'shipped', 'delivered', 'cancelled'].map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(
                  status.toUpperCase(),
                  style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedStatus = value!;
              });
            },
            style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(order['status']),
          child: Icon(
            Icons.shopping_cart,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          'Order #${order['id']?.toString().substring(0, 8) ?? 'Unknown'}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${order['customer_name'] ?? 'Unknown'}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '₹${order['total_amount']?.toString() ?? '0'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order['status']?.toString().toUpperCase() ?? 'UNKNOWN',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.green,
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
              value: 'view',
              child: Text('View Details'),
            ),
            const PopupMenuItem(
              value: 'update_status',
              child: Text('Update Status'),
            ),
          ],
          onSelected: (value) => _handleOrderAction(context, order, value),
        ),
        onTap: () => _showOrderDetails(context, order),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  List<Map<String, dynamic>> _filterOrders(List<Map<String, dynamic>> orders) {
    return orders.where((order) {
      return _selectedStatus == 'All' || order['status'] == _selectedStatus;
    }).toList();
  }

  void _handleOrderAction(BuildContext context, Map<String, dynamic> order, String action) {
    switch (action) {
      case 'view':
        _showOrderDetails(context, order);
        break;
      case 'update_status':
        _showUpdateStatusDialog(context, order);
        break;
    }
  }

  void _showOrderDetails(BuildContext context, Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order Details - #${order['id']?.toString().substring(0, 8)}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Order ID: ${order['id']}'),
              const SizedBox(height: 8),
              Text('Customer: ${order['customer_name']}'),
              const SizedBox(height: 8),
              Text('Total Amount: ₹${order['total_amount']}'),
              const SizedBox(height: 8),
              Text('Status: ${order['status']}'),
              const SizedBox(height: 8),
              Text('Order Date: ${_formatDate(order['order_date'])}'),
              if (order['updatedAt'] != null) ...[
                const SizedBox(height: 8),
                Text('Updated: ${_formatDate(order['updatedAt'])}'),
              ],
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

  void _showUpdateStatusDialog(BuildContext context, Map<String, dynamic> order) {
    String selectedStatus = order['status'] ?? 'pending';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Order Status'),
        content: DropdownButtonFormField<String>(
          value: selectedStatus,
          items: ['pending', 'processing', 'shipped', 'delivered', 'cancelled'].map((status) {
            return DropdownMenuItem(
              value: status,
              child: Text(status.toUpperCase()),
            );
          }).toList(),
          onChanged: (value) {
            selectedStatus = value!;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(adminRepositoryProvider).updateOrderStatus(order['id'], selectedStatus);
              Navigator.of(context).pop();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }
}

// Provider for all orders
final allOrdersProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final repository = ref.read(adminRepositoryProvider);
  return repository.getAllOrders();
}); 