import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../widgets/analytics_card.dart';
import '../widgets/user_management_card.dart';
import '../../../customer/presentation/pages/profile_page.dart';

class AdminDashboard extends ConsumerWidget {
  final UserModel user;

  const AdminDashboard({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard - ${user.name}'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Text('Profile'),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Text('Settings'),
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
                print('👑 [ADMIN_DASHBOARD] Navigating to ProfilePage');
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              } else if (value == 'settings') {
                // TODO: Navigate to settings page
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings page coming soon!')),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Overview',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildOverviewCard(
                      'Total Users',
                      '1,234',
                      Icons.people,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildOverviewCard(
                      'Active Pickups',
                      '89',
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
                      '₹45,678',
                      Icons.currency_rupee,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildOverviewCard(
                      'Impact Score',
                      '92%',
                      Icons.eco,
                      Colors.teal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Analytics',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              AnalyticsCard(
                title: 'Pickup Trends',
                subtitle: 'Last 30 days',
                value: '+23%',
                trend: 'up',
                chartData: const [12, 19, 15, 25, 22, 30, 28],
              ),
              const SizedBox(height: 16),
              AnalyticsCard(
                title: 'Revenue Growth',
                subtitle: 'Monthly comparison',
                value: '+15%',
                trend: 'up',
                chartData: const [8, 12, 10, 18, 15, 22, 20],
              ),
              const SizedBox(height: 16),
              AnalyticsCard(
                title: 'User Engagement',
                subtitle: 'Active users',
                value: '+8%',
                trend: 'up',
                chartData: const [5, 8, 12, 15, 18, 20, 25],
              ),
              const SizedBox(height: 24),
              Text(
                'User Management',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              UserManagementCard(
                role: 'Tailor',
                count: 24,
                activeCount: 20,
                icon: Icons.cut,
                color: Colors.blue,
                onTap: () {},
              ),
              const SizedBox(height: 12),
              UserManagementCard(
                role: 'Customer',
                count: 120,
                activeCount: 110,
                icon: Icons.shopping_bag,
                color: Colors.green,
                onTap: () {},
              ),
              const SizedBox(height: 12),
              UserManagementCard(
                role: 'Admin',
                count: 3,
                activeCount: 3,
                icon: Icons.admin_panel_settings,
                color: Colors.orange,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
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
}
