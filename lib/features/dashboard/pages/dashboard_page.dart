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
        return RoleDashboard(user: user);
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
}
