import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/pages/login_page.dart';
import '../features/dashboard/pages/dashboard_page.dart';
import '../features/tailor/pages/pickup_request_page.dart';
import '../features/customer/pages/products_page.dart';
import '../features/admin/presentation/pages/admin_page.dart';
import '../features/customer/presentation/pages/profile_page.dart';
import '../features/customer/presentation/pages/my_orders_page.dart';
import '../features/customer/presentation/pages/cart_page.dart';
import '../test_single_assignment_in_app.dart';
import '../test_all_changes_in_app.dart';
import '../test_registration_routing.dart';
import '../core/services/remote_config_service.dart';
import '../shared/widgets/kill_switch_widget.dart';
import 'theme.dart';
import '../features/auth/data/models/user_model.dart';

class ReFabApp extends ConsumerWidget {
  ReFabApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    
    // Check if app is disabled via remote config
    if (RemoteConfigService.appDisabled) {
      return MaterialApp(
        title: 'ReFab',
        theme: AppTheme.lightTheme,
        home: KillSwitchWidget(
          message: RemoteConfigService.killSwitchMessage,
          onRetry: () {
            // Refresh remote config and rebuild
            RemoteConfigService.refresh().then((_) {
              // Force rebuild
              ref.invalidate(authStateProvider);
            });
          },
        ),
        debugShowCheckedModeBanner: false,
      );
    }
    
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
      initialLocation: '/dashboard',
      redirect: (context, state) {
        print('🛣️ [ROUTER] Redirect called for path: ${state.uri.path}');
        return authState.when(
          data: (user) {
            print('🛣️ [ROUTER] Auth state data - User: ${user?.name ?? 'null'} (${user?.email ?? 'null'})');
            print('🛣️ [ROUTER] User role: ${user?.role ?? 'null'}');
            
            // If no user and not on login page, redirect to login
            if (user == null && state.uri.path != '/login') {
              print('🛣️ [ROUTER] ⚠️ No user, redirecting to /login');
              return '/login';
            }
            
            // If user is authenticated and on login page, redirect to dashboard
            if (user != null && state.uri.path == '/login') {
              print('🛣️ [ROUTER] ✅ User authenticated, redirecting to /dashboard');
              return '/dashboard';
            }
            
            // Role-based access control for admin routes
            if (user != null && state.uri.path == '/admin') {
              if (user.role != UserRole.admin) {
                print('🛣️ [ROUTER] ⚠️ Non-admin user attempting to access admin page, redirecting to /dashboard');
                return '/dashboard';
              }
              print('🛣️ [ROUTER] ✅ Admin user accessing admin page');
            }
            
            // Role-based access control for other specific routes
            if (user != null) {
              // Check if user is trying to access routes they shouldn't
              final currentPath = state.uri.path;
              
              // Admin-only routes
              if (currentPath.startsWith('/admin') && user.role != UserRole.admin) {
                print('🛣️ [ROUTER] ⚠️ User ${user.role} cannot access admin routes, redirecting to /dashboard');
                return '/dashboard';
              }
              
              // Test routes - only allow for development
              if ((currentPath == '/test-single-assignment' || currentPath == '/test-all-changes')) {
                // Allow access for now, but log it
                print('🛣️ [ROUTER] ⚠️ User accessing test route: $currentPath');
              }
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
          path: '/dashboard',
          builder: (context, state) {
            print('🛣️ [ROUTER] Building DashboardPage');
            return const DashboardPage();
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
          path: '/profile',
          builder: (context, state) {
            print('🛣️ [ROUTER] Building ProfilePage');
            return const ProfilePage();
          },
        ),
        GoRoute(
          path: '/orders',
          builder: (context, state) {
            print('🛣️ [ROUTER] Building MyOrdersPage');
            return const MyOrdersPage();
          },
        ),
        GoRoute(
          path: '/cart',
          builder: (context, state) {
            print('🛣️ [ROUTER] Building CartPage');
            return const CartPage();
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
          path: '/admin',
          builder: (context, state) {
            print('🛣️ [ROUTER] Building AdminPage');
            return const AdminPage();
          },
        ),
        GoRoute(
          path: '/test-single-assignment',
          builder: (context, state) {
            print('🛣️ [ROUTER] Building SingleAssignmentTestWidget');
            return const SingleAssignmentTestWidget();
          },
        ),
        GoRoute(
          path: '/test-all-changes',
          builder: (context, state) {
            print('🛣️ [ROUTER] Building AllChangesTestWidget');
            return const AllChangesTestWidget();
          },
        ),
        GoRoute(
          path: '/test-registration-routing',
          builder: (context, state) {
            print('🛣️ [ROUTER] Building RegistrationRoutingTest');
            return const RegistrationRoutingTest();
          },
        ),
      ],
    );
  }
}
