import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:refab_app/features/warehouse/providers/warehouse_provider.dart';

class LocationManagementTab extends ConsumerWidget {
  const LocationManagementTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_on, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Location Management'),
          Text('Coming Soon'),
        ],
      ),
    );
  }
} 