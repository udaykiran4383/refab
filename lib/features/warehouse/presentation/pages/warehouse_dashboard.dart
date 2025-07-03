import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../widgets/inventory_card.dart';
import '../widgets/worker_task_card.dart';
import '../../../customer/presentation/pages/profile_page.dart';

class WarehouseDashboard extends ConsumerWidget {
  final UserModel user;

  const WarehouseDashboard({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Warehouse - ${user.name}'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Text('Profile'),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                ref.read(authServiceProvider).signOut();
              } else if (value == 'profile') {
                print('📦 [WAREHOUSE_DASHBOARD] Navigating to ProfilePage');
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              }
            },
          ),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            // Stats Overview
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Pending Processing',
                      '12',
                      Icons.pending_actions,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Active Workers',
                      '8',
                      Icons.people,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Products Ready',
                      '24',
                      Icons.inventory,
                      Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            // Tab Bar
            const TabBar(
              tabs: [
                Tab(text: 'Inventory', icon: Icon(Icons.inventory_2)),
                Tab(text: 'Workers', icon: Icon(Icons.people)),
                Tab(text: 'Production', icon: Icon(Icons.factory)),
              ],
            ),
            // Tab Views
            Expanded(
              child: TabBarView(
                children: [
                  // Inventory Tab
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: 8,
                      itemBuilder: (context, index) {
                        return InventoryCard(
                          id: 'INV${1000 + index}',
                          fabricType: ['Cotton', 'Silk', 'Polyester', 'Wool', 'Linen', 'Denim', 'Chiffon', 'Velvet'][index],
                          weight: [15.5, 8.2, 22.1, 5.7, 12.3, 18.9, 6.4, 9.8][index],
                          grade: ['A', 'B', 'A', 'C', 'A', 'B', 'A', 'B'][index],
                          status: ['Processing', 'Graded', 'Ready', 'Processing', 'Graded', 'Ready', 'Processing', 'Graded'][index],
                          receivedDate: DateTime.now().subtract(Duration(days: index + 1)),
                          onTap: () {},
                        );
                      },
                    ),
                  ),
                  // Workers Tab
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        return WorkerTaskCard(
                          workerName: ['Priya Sharma', 'Meera Patel', 'Sunita Devi', 'Kavita Singh', 'Asha Kumari', 'Radha Rani'][index],
                          currentTask: ['Sorting Cotton', 'Stitching Bags', 'Quality Check', 'Cutting Fabric', 'Packaging', 'Design Review'][index],
                          tasksCompleted: [12, 8, 15, 6, 20, 10][index],
                          efficiency: [92, 88, 95, 85, 98, 90][index],
                          onTap: () {},
                          onAssignTask: () {},
                        );
                      },
                    ),
                  ),
                  // Production Tab
                  const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.factory, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Production Planning'),
                        Text('Coming Soon'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Add inventory item
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add item functionality coming soon!')),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
