import 'package:flutter/material.dart';

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder orders
    final orders = [
      {
        'id': 'ORD1234',
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'status': 'Delivered',
        'total': 499.0,
      },
      {
        'id': 'ORD1235',
        'date': DateTime.now().subtract(const Duration(days: 7)),
        'status': 'Shipped',
        'total': 299.0,
      },
      {
        'id': 'ORD1236',
        'date': DateTime.now().subtract(const Duration(days: 14)),
        'status': 'Processing',
        'total': 799.0,
      },
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: orders.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                child: const Icon(Icons.receipt_long, color: Colors.green),
              ),
              title: Text('Order #${order['id']}'),
              subtitle: Text('${order['status']} • ${order['date'].toString().split(' ').first}'),
              trailing: Text('₹${order['total']}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              onTap: () {
                // TODO: Show order details
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Order details for #${order['id']} coming soon!')),
                );
              },
            ),
          );
        },
      ),
    );
  }
} 