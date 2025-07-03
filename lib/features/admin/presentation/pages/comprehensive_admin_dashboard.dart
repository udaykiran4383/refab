import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../providers/admin_provider.dart';
import '../widgets/analytics_card.dart';
import '../widgets/user_management_card.dart';
import '../widgets/system_health_card.dart';
import '../widgets/notification_card.dart';
import '../widgets/report_card.dart';
import '../widgets/quick_actions_card.dart';
import '../../../customer/presentation/pages/profile_page.dart';
import 'user_management_page.dart';
import 'system_config_page.dart';
import 'notifications_page.dart';
import 'reports_page.dart';
import 'products_page.dart';
import 'orders_page.dart';
import 'pickup_requests_page.dart';
import 'system_health_page.dart';

class ComprehensiveAdminDashboard extends ConsumerStatefulWidget {
  final UserModel user;

  const ComprehensiveAdminDashboard({super.key, required this.user});

  @override
  ConsumerState<ComprehensiveAdminDashboard> createState() => _ComprehensiveAdminDashboardState();
}

class _ComprehensiveAdminDashboardState extends ConsumerState<ComprehensiveAdminDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminProvider.notifier).loadAnalytics();
      ref.read(adminProvider.notifier).loadSystemConfig();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final analytics = ref.watch(systemAnalyticsProvider);
    final allUsers = ref.watch(allUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard - ${widget.user.name}'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => _showNotificationsDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(adminProvider.notifier).loadAnalytics();
              ref.read(adminProvider.notifier).loadSystemConfig();
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Text('Profile'),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Text('System Settings'),
              ),
              const PopupMenuItem(
                value: 'backup',
                child: Text('Create Backup'),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
            onSelected: (value) => _handleMenuSelection(value),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Users', icon: Icon(Icons.people)),
            Tab(text: 'Products', icon: Icon(Icons.inventory)),
            Tab(text: 'Orders', icon: Icon(Icons.shopping_cart)),
            Tab(text: 'Pickups', icon: Icon(Icons.local_shipping)),
            Tab(text: 'Reports', icon: Icon(Icons.assessment)),
            Tab(text: 'Notifications', icon: Icon(Icons.notifications)),
            Tab(text: 'System', icon: Icon(Icons.settings)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(analytics, allUsers),
          _buildUsersTab(),
          _buildProductsTab(),
          _buildOrdersTab(),
          _buildPickupsTab(),
          _buildReportsTab(),
          _buildNotificationsTab(),
          _buildSystemTab(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildOverviewTab(AsyncValue<AnalyticsModel> analytics, AsyncValue<List<UserModel>> allUsers) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Actions
          QuickActionsCard(
            onUserManagement: () => _navigateToPage(const UserManagementPage()),
            onSystemConfig: () => _navigateToPage(const SystemConfigPage()),
            onReports: () => _navigateToPage(const ReportsPage()),
            onNotifications: () => _navigateToPage(const NotificationsPage()),
          ),
          const SizedBox(height: 24),

          // System Health
          SystemHealthCard(
            onViewDetails: () => _navigateToPage(const SystemHealthPage()),
          ),
          const SizedBox(height: 24),

          // Analytics Overview
          Text(
            'Analytics Overview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          analytics.when(
            data: (analyticsData) => Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildOverviewCard(
                        'Total Users',
                        analyticsData.totalUsers.toString(),
                        Icons.people,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildOverviewCard(
                        'Active Pickups',
                        analyticsData.totalPickupRequests.toString(),
                        Icons.local_shipping,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildOverviewCard(
                        'Revenue',
                        analyticsData.formattedRevenue,
                        Icons.currency_rupee,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildOverviewCard(
                        'Growth Rate',
                        '${analyticsData.pickupGrowthRate.toStringAsFixed(1)}%',
                        Icons.trending_up,
                        analyticsData.isPickupGrowthPositive ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Analytics Charts
                AnalyticsCard(
                  title: 'Pickup Trends',
                  subtitle: 'Last 30 days',
                  value: '${analyticsData.pickupGrowthRate.toStringAsFixed(1)}%',
                  trend: analyticsData.isPickupGrowthPositive ? 'up' : 'down',
                  chartData: [12, 19, 15, 25, 22, 30, 28],
                ),
                const SizedBox(height: 16),
                AnalyticsCard(
                  title: 'User Engagement',
                  subtitle: 'Active users',
                  value: '${analyticsData.userActivationRate.toStringAsFixed(1)}%',
                  trend: 'up',
                  chartData: [5, 8, 12, 15, 18, 20, 25],
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Error loading analytics: $error'),
            ),
          ),

          const SizedBox(height: 24),

          // User Management Overview
          Text(
            'User Management',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          allUsers.when(
            data: (users) {
              final roleCounts = <String, int>{};
              final activeCounts = <String, int>{};

              for (final user in users) {
                roleCounts[user.role] = (roleCounts[user.role] ?? 0) + 1;
                if (user.isActive) {
                  activeCounts[user.role] = (activeCounts[user.role] ?? 0) + 1;
                }
              }

              return Column(
                children: [
                  if (roleCounts.containsKey('tailor'))
                    UserManagementCard(
                      role: 'Tailor',
                      count: roleCounts['tailor']!,
                      activeCount: activeCounts['tailor'] ?? 0,
                      icon: Icons.cut,
                      color: Colors.blue,
                      onTap: () => _navigateToPage(const UserManagementPage()),
                    ),
                  if (roleCounts.containsKey('customer'))
                    UserManagementCard(
                      role: 'Customer',
                      count: roleCounts['customer']!,
                      activeCount: activeCounts['customer'] ?? 0,
                      icon: Icons.shopping_bag,
                      color: Colors.green,
                      onTap: () => _navigateToPage(const UserManagementPage()),
                    ),
                  if (roleCounts.containsKey('volunteer'))
                    UserManagementCard(
                      role: 'Volunteer',
                      count: roleCounts['volunteer']!,
                      activeCount: activeCounts['volunteer'] ?? 0,
                      icon: Icons.volunteer_activism,
                      color: Colors.purple,
                      onTap: () => _navigateToPage(const UserManagementPage()),
                    ),
                  if (roleCounts.containsKey('admin'))
                    UserManagementCard(
                      role: 'Admin',
                      count: roleCounts['admin']!,
                      activeCount: activeCounts['admin'] ?? 0,
                      icon: Icons.admin_panel_settings,
                      color: Colors.orange,
                      onTap: () => _navigateToPage(const UserManagementPage()),
                    ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Error loading users: $error'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return const UserManagementPage();
  }

  Widget _buildProductsTab() {
    return const ProductsPage();
  }

  Widget _buildOrdersTab() {
    return const OrdersPage();
  }

  Widget _buildPickupsTab() {
    return const PickupRequestsPage();
  }

  Widget _buildReportsTab() {
    return const ReportsPage();
  }

  Widget _buildNotificationsTab() {
    return const NotificationsPage();
  }

  Widget _buildSystemTab() {
    return const SystemConfigPage();
  }

  Widget _buildOverviewCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    switch (_selectedIndex) {
      case 1: // Users
        return FloatingActionButton(
          onPressed: () => _showAddUserDialog(context),
          child: const Icon(Icons.person_add),
        );
      case 2: // Products
        return FloatingActionButton(
          onPressed: () => _showAddProductDialog(context),
          child: const Icon(Icons.add),
        );
      case 5: // Reports
        return FloatingActionButton(
          onPressed: () => _showGenerateReportDialog(context),
          child: const Icon(Icons.assessment),
        );
      case 6: // Notifications
        return FloatingActionButton(
          onPressed: () => _showSendNotificationDialog(context),
          child: const Icon(Icons.send),
        );
      default:
        return null;
    }
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'profile':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
        break;
      case 'settings':
        _navigateToPage(const SystemConfigPage());
        break;
      case 'backup':
        _createSystemBackup();
        break;
      case 'logout':
        ref.read(authServiceProvider).signOut();
        break;
    }
  }

  void _navigateToPage(Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void _createSystemBackup() async {
    try {
      await ref.read(adminRepositoryProvider).createSystemBackup();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('System backup created successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create backup: $e')),
        );
      }
    }
  }

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const NotificationCard(),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    // Implementation for adding user
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add User'),
        content: const Text('User management functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    // Implementation for adding product
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Product'),
        content: const Text('Product management functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showGenerateReportDialog(BuildContext context) {
    // Implementation for generating report
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Report'),
        content: const Text('Report generation functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSendNotificationDialog(BuildContext context) {
    // Implementation for sending notification
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Notification'),
        content: const Text('Notification sending functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
} 