import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../presentation/pages/role_dashboard.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('🏠 [DASHBOARD] Building DashboardPage');
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          print('🏠 [DASHBOARD] ❌ No user found, showing login prompt');
          return const Scaffold(
            body: Center(child: Text('Please login')),
          );
        }
        print('🏠 [DASHBOARD] ✅ User found: ${user.name} (${user.email})');
        print('🏠 [DASHBOARD] 🎭 User role: ${user.role}');
        print('🏠 [DASHBOARD] 📋 User details: ${user.toJson()}');
        
        // Add a debug banner for development
        return Scaffold(
          appBar: AppBar(
            title: Text('Dashboard - ${user.role.toString().split('.').last}'),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.info),
                onPressed: () => _showDebugInfo(context, user),
              ),
            ],
          ),
          body: RoleDashboard(user: user),
        );
      },
      loading: () {
        print('🏠 [DASHBOARD] 🔄 Loading auth state...');
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
      error: (error, stack) {
        print('🏠 [DASHBOARD] ❌ Auth state error: $error');
        return Scaffold(
          body: Center(child: Text('Error: $error')),
        );
      },
    );
  }
  
  void _showDebugInfo(BuildContext context, user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug Information'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Name: ${user.name}'),
              Text('Email: ${user.email}'),
              Text('Role: ${user.role}'),
              Text('Phone: ${user.phone}'),
              Text('ID: ${user.id}'),
              const SizedBox(height: 16),
              const Text('User JSON:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(user.toJson().toString()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
