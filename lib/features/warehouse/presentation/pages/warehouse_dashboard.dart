import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../widgets/inventory_card.dart';
import '../widgets/worker_task_card.dart';
import '../../../customer/presentation/pages/profile_page.dart';
import 'package:refab_app/features/warehouse/providers/warehouse_provider.dart';
import 'package:refab_app/features/warehouse/presentation/widgets/inventory_management_tab.dart';
import 'package:refab_app/features/warehouse/presentation/widgets/task_management_tab.dart';
import 'package:refab_app/features/warehouse/presentation/widgets/worker_management_tab.dart';
import 'package:refab_app/features/warehouse/presentation/widgets/location_management_tab.dart';
import 'package:refab_app/features/warehouse/presentation/widgets/analytics_tab.dart';
import 'package:refab_app/features/warehouse/presentation/widgets/integrations_tab.dart';

class WarehouseDashboard extends ConsumerStatefulWidget {
  final UserModel user;
  
  const WarehouseDashboard({super.key, required this.user});

  @override
  ConsumerState<WarehouseDashboard> createState() => _WarehouseDashboardState();
}

class _WarehouseDashboardState extends ConsumerState<WarehouseDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final warehouseId = ref.watch(warehouseIdProvider);
    final analyticsAsync = ref.watch(warehouseAnalyticsProvider(warehouseId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Warehouse Management'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(warehouseNotifierProvider.notifier).refreshAnalytics(warehouseId);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to warehouse settings
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.inventory), text: 'Inventory'),
            Tab(icon: Icon(Icons.assignment), text: 'Tasks'),
            Tab(icon: Icon(Icons.people), text: 'Workers'),
            Tab(icon: Icon(Icons.location_on), text: 'Locations'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            Tab(icon: Icon(Icons.integration_instructions), text: 'Integrations'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Quick Stats Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: analyticsAsync.when(
              data: (analytics) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickStat('Total Items', '${analytics.totalInventory}', Icons.inventory),
                  _buildQuickStat('Processing', '${analytics.processingInventory}', Icons.sync),
                  _buildQuickStat('Ready', '${analytics.readyInventory}', Icons.check_circle),
                  _buildQuickStat('Tasks', '${analytics.totalTasks}', Icons.assignment),
                ],
              ),
              loading: () => const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CircularProgressIndicator(),
                  CircularProgressIndicator(),
                  CircularProgressIndicator(),
                  CircularProgressIndicator(),
                ],
              ),
              error: (error, stack) => Text('Error: $error'),
            ),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                const InventoryManagementTab(),
                const TaskManagementTab(),
                const WorkerManagementTab(),
                const LocationManagementTab(),
                const AnalyticsTab(),
                const IntegrationsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue[800], size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    switch (_currentIndex) {
      case 0: // Inventory
        return FloatingActionButton(
          onPressed: () {
            // TODO: Navigate to add inventory item
          },
          backgroundColor: Colors.blue[800],
          child: const Icon(Icons.add, color: Colors.white),
        );
      case 1: // Tasks
        return FloatingActionButton(
          onPressed: () {
            // TODO: Navigate to create task
          },
          backgroundColor: Colors.orange[800],
          child: const Icon(Icons.add_task, color: Colors.white),
        );
      case 2: // Workers
        return FloatingActionButton(
          onPressed: () {
            // TODO: Navigate to add worker
          },
          backgroundColor: Colors.green[800],
          child: const Icon(Icons.person_add, color: Colors.white),
        );
      case 3: // Locations
        return FloatingActionButton(
          onPressed: () {
            // TODO: Navigate to add location
          },
          backgroundColor: Colors.purple[800],
          child: const Icon(Icons.add_location, color: Colors.white),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
