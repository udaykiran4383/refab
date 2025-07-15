import 'package:flutter/material.dart';
import 'pickup_requests_page.dart';
import 'assignments_page.dart';
import 'user_management_page.dart';
// import 'products_page.dart'; // Commented out for future use
// import 'orders_page.dart'; // Commented out for future use
import 'warehouse_management_page.dart';
import 'system_health_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const PickupRequestsPage(),      // 0: Pickups
    const AssignmentsPage(),         // 1: Assignments
    const UserManagementPage(),      // 2: Users
    // const ProductsPage(),            // 3: Products - Commented out for future use
    // const OrdersPage(),              // 4: Orders - Commented out for future use
    const WarehouseManagementPage(), // 3: Warehouses (was 5)
    const SystemHealthPage(),        // 4: System (was 6)
  ];

  final List<String> _pageTitles = [
    'Pickup Requests',
    'Assignments',
    'User Management',
    // 'Products', // Commented out for future use
    // 'Orders', // Commented out for future use
    'Warehouse Management',
    'System Health',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_currentIndex]),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon!')),
              );
            },
            tooltip: 'Notifications',
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue[600],
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Pickups',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Assignments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.inventory),
          //   label: 'Products',
          // ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.shopping_cart),
          //   label: 'Orders',
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warehouse),
            label: 'Warehouses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety),
            label: 'System',
          ),
        ],
      ),
    );
  }
} 