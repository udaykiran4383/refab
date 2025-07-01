import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/pages/login_page.dart';
import '../features/dashboard/pages/dashboard_page.dart';
import '../features/tailor/pages/pickup_request_page.dart';
import '../features/customer/pages/products_page.dart';
import '../features/admin/pages/admin_page.dart';
import 'theme.dart';

class ReFabApp extends ConsumerWidget {
  const ReFabApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('🏗️ [APP] Building ReFabApp...');
    final authState = ref.watch(authStateProvider);
    print('🏗️ [APP] Auth state: $authState');
    
    return MaterialApp.router(
      title: 'ReFab',
      theme: AppTheme.lightTheme,
      routerConfig: _createRouter(authState),
      debugShowCheckedModeBanner: false,
    );
  }

  GoRouter _createRouter(AsyncValue authState) {
    print('🛣️ [ROUTER] Creating GoRouter with auth state: $authState');
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        print('🛣️ [ROUTER] Redirect called for path: \\${state.uri.path}');
        return authState.when(
          data: (user) {
            print('🛣️ [ROUTER] Auth state data - User: \\${user?.name ?? 'null'} (\\${user?.email ?? 'null'})');
            if (user == null && state.uri.path != '/login') {
              print('🛣️ [ROUTER] ⚠️ No user, redirecting to /login');
              return '/login';
            }
            if (user != null && state.uri.path == '/login') {
              print('🛣️ [ROUTER] ✅ User authenticated, redirecting to /dashboard');
              return '/dashboard';
            }
            print('🛣️ [ROUTER] No redirect needed');
            return null;
          },
          loading: () {
            print('🛣️ [ROUTER] 🔄 Auth state loading, no redirect');
            return null;
          },
          error: (e, st) {
            print('🛣️ [ROUTER] ❌ Auth state error: $e');
            print('🛣️ [ROUTER] Redirecting to /login due to error');
            return '/login';
          },
        );
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) {
            print('🛣️ [ROUTER] Building LoginPage');
            return const LoginPage();
          },
        ),
        GoRoute(
          path: '/',
          redirect: (context, state) {
            print('🛣️ [ROUTER] Redirecting / to /dashboard');
            return '/dashboard';
          },
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) {
            print('🛣️ [ROUTER] Building DashboardPage');
            return const DashboardPage();
          },
        ),
        GoRoute(
          path: '/pickup-request',
          builder: (context, state) {
            print('🛣️ [ROUTER] Building PickupRequestPage');
            return const PickupRequestPage();
          },
        ),
        GoRoute(
          path: '/products',
          builder: (context, state) {
            print('🛣️ [ROUTER] Building ProductsPage');
            return const ProductsPage();
          },
        ),
        GoRoute(
          path: '/admin',
          builder: (context, state) {
            print('🛣️ [ROUTER] Building AdminPage');
            return const AdminPage();
          },
        ),
      ],
    );
  }
}
