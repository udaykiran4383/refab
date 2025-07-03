import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/pickup_list_item.dart';
import '../widgets/route_map_widget.dart';
import '../../../customer/presentation/pages/profile_page.dart';

class LogisticsDashboard extends ConsumerWidget {
  final UserModel user;

  const LogisticsDashboard({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logistics - ${user.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RouteMapWidget(),
                ),
              );
            },
          ),
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
                ref.read(loginProvider.notifier).signOut();
              } else if (value == 'profile') {
                print('🚚 [LOGISTICS_DASHBOARD] Navigating to ProfilePage');
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
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
                'Today\'s Pickups',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5, // Replace with actual data
                itemBuilder: (context, index) {
                  return PickupListItem(
                    id: 'PKP${index + 1}',
                    tailorName: 'Tailor ${index + 1}',
                    fabricType: 'Cotton',
                    weight: 5.0 + index,
                    address: '123 Main St, City',
                    distance: '${(index + 1) * 2.5}km',
                    onTap: () {},
                    onAccept: () {},
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Route Map',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: Text('Map Placeholder')),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RouteMapWidget(),
            ),
          );
        },
        icon: const Icon(Icons.navigation),
        label: const Text('Navigate'),
      ),
    );
  }
}
