import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:refab_app/features/admin/data/repositories/admin_repository.dart';
import 'package:refab_app/features/admin/data/models/analytics_model.dart';
import 'package:refab_app/features/admin/data/models/system_config_model.dart';
import 'package:refab_app/features/auth/data/models/user_model.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('AdminRepository Integration Tests', () {
    late AdminRepository repository;
    late String testAdminId;

    setUpAll(() async {
      print('👨‍💼 [ADMIN_INTEGRATION] Setting up Firebase for testing...');
      await Firebase.initializeApp();
      print('👨‍💼 [ADMIN_INTEGRATION] ✅ Firebase initialized');
    });

    setUp(() {
      print('👨‍💼 [ADMIN_INTEGRATION] Setting up test environment...');
      repository = AdminRepository();
      testAdminId = 'test_admin_${DateTime.now().millisecondsSinceEpoch}';
      print('👨‍💼 [ADMIN_INTEGRATION] ✅ Test environment ready. Admin ID: $testAdminId');
    });

    tearDown(() async {
      print('👨‍💼 [ADMIN_INTEGRATION] Cleaning up test data...');
      try {
        // Clean up test data
        final users = await FirebaseFirestore.instance
            .collection('users')
            .where('createdBy', isEqualTo: testAdminId)
            .get();
        
        final batch = FirebaseFirestore.instance.batch();
        for (var doc in users.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        print('👨‍💼 [ADMIN_INTEGRATION] ✅ Test data cleaned up');
      } catch (e) {
        print('👨‍💼 [ADMIN_INTEGRATION] ⚠️ Cleanup warning: $e');
      }
    });

    group('User Management CRUD Operations', () {
      testWidgets('should get all users successfully', (WidgetTester tester) async {
        print('👨‍💼 [ADMIN_INTEGRATION] Testing user retrieval...');
        
        print('👨‍💼 [ADMIN_INTEGRATION] Fetching all users...');
        final users = await repository.getAllUsers().first;
        
        print('👨‍💼 [ADMIN_INTEGRATION] ✅ Retrieved ${users.length} users');
        expect(users, isA<List<UserModel>>());
        
        if (users.isNotEmpty) {
          final user = users.first;
          print('👨‍💼 [ADMIN_INTEGRATION] 👤 Sample User:');
          print('   - Name: ${user.name}');
          print('   - Email: ${user.email}');
          print('   - Role: ${user.role}');
          print('   - Status: ${user.isActive ? "Active" : "Inactive"}');
          
          expect(user.name, isNotEmpty);
          expect(user.email, isNotEmpty);
          expect(user.role, isNotNull);
        }
      });

      testWidgets('should get users by role', (WidgetTester tester) async {
        print('👨‍💼 [ADMIN_INTEGRATION] Testing user filtering by role...');
        
        print('👨‍💼 [ADMIN_INTEGRATION] Fetching tailors...');
        final tailors = await repository.getUsersByRole('tailor').first;
        
        print('👨‍💼 [ADMIN_INTEGRATION] ✅ Retrieved ${tailors.length} tailors');
        
        for (final tailor in tailors) {
          expect(tailor.role, equals(UserRole.tailor));
          print('👨‍💼 [ADMIN_INTEGRATION]   - ${tailor.name} (${tailor.email})');
        }
      });

      testWidgets('should update user status', (WidgetTester tester) async {
        print('👨‍💼 [ADMIN_INTEGRATION] Testing user status update...');
        
        // First get a user to update
        final users = await repository.getAllUsers().first;
        if (users.isNotEmpty) {
          final user = users.first;
          final newStatus = !user.isActive;
          
          print('👨‍💼 [ADMIN_INTEGRATION] Updating user status: ${user.name} -> ${newStatus ? "Active" : "Inactive"}');
          await repository.updateUser(user.id, {'isActive': newStatus});
          
          // Verify the update
          final updatedUsers = await repository.getAllUsers().first;
          final updatedUser = updatedUsers.firstWhere((u) => u.id == user.id);
          
          print('👨‍💼 [ADMIN_INTEGRATION] ✅ User status updated successfully');
          print('   - New Status: ${updatedUser.isActive ? "Active" : "Inactive"}');
          expect(updatedUser.isActive, equals(newStatus));
        } else {
          print('👨‍💼 [ADMIN_INTEGRATION] ⚠️ No users available for status update test');
        }
      });

      testWidgets('should delete user', (WidgetTester tester) async {
        print('👨‍💼 [ADMIN_INTEGRATION] Testing user deletion...');
        
        // Create a test user first
        final testUser = UserModel(
          id: 'test_user_${DateTime.now().millisecondsSinceEpoch}',
          name: 'Test User for Deletion',
          email: 'testdelete@example.com',
          role: UserRole.customer,
          isActive: true,
          createdAt: DateTime.now(),
          phone: '+1234567890',
          address: 'Test Address',
        );

        print('👨‍💼 [ADMIN_INTEGRATION] Creating test user for deletion...');
        await FirebaseFirestore.instance
            .collection('users')
            .doc(testUser.id)
            .set(testUser.toJson());
        
        print('👨‍💼 [ADMIN_INTEGRATION] Deleting test user...');
        await repository.deleteUser(testUser.id);
        
        // Verify deletion
        final deletedUser = await FirebaseFirestore.instance
            .collection('users')
            .doc(testUser.id)
            .get();
        
        print('👨‍💼 [ADMIN_INTEGRATION] ✅ User deleted successfully');
        expect(deletedUser.exists, isFalse);
      });
    });

    group('Analytics Operations', () {
      testWidgets('should get system analytics', (WidgetTester tester) async {
        print('👨‍💼 [ADMIN_INTEGRATION] Testing system analytics retrieval...');
        
        print('👨‍💼 [ADMIN_INTEGRATION] Fetching system analytics...');
        final analytics = await repository.getSystemAnalytics();
        
        print('👨‍💼 [ADMIN_INTEGRATION] 📊 System Analytics:');
        print('   - Total Users: ${analytics.totalUsers}');
        print('   - Active Users: ${analytics.activeUsers}');
        print('   - Total Orders: ${analytics.totalOrders}');
        print('   - Total Revenue: ${analytics.formattedRevenue}');
        print('   - Pickup Requests: ${analytics.totalPickupRequests}');
        
        expect(analytics.totalUsers, isA<int>());
        expect(analytics.activeUsers, isA<int>());
        expect(analytics.totalOrders, isA<int>());
        expect(analytics.formattedRevenue, isA<String>());
        expect(analytics.totalPickupRequests, isA<int>());
        
        print('👨‍💼 [ADMIN_INTEGRATION] ✅ System analytics retrieved successfully');
      });

      testWidgets('should get role-based analytics', (WidgetTester tester) async {
        print('👨‍💼 [ADMIN_INTEGRATION] Testing role-based analytics...');
        
        print('👨‍💼 [ADMIN_INTEGRATION] Fetching analytics by role...');
        final customerUsers = await repository.getUsersByRole('customer').first;
        final tailorUsers = await repository.getUsersByRole('tailor').first;
        final volunteerUsers = await repository.getUsersByRole('volunteer').first;
        
        print('👨‍💼 [ADMIN_INTEGRATION] 📊 Role-based Analytics:');
        print('   - Customers: ${customerUsers.length}');
        print('   - Tailors: ${tailorUsers.length}');
        print('   - Volunteers: ${volunteerUsers.length}');
        
        expect(customerUsers.every((u) => u.role == UserRole.customer), isTrue);
        expect(tailorUsers.every((u) => u.role == UserRole.tailor), isTrue);
        expect(volunteerUsers.every((u) => u.role == UserRole.volunteer), isTrue);
        
        print('👨‍💼 [ADMIN_INTEGRATION] ✅ Role-based analytics retrieved successfully');
      });
    });

    group('System Configuration CRUD Operations', () {
      testWidgets('should get system configuration', (WidgetTester tester) async {
        print('👨‍💼 [ADMIN_INTEGRATION] Testing system configuration retrieval...');
        
        print('👨‍💼 [ADMIN_INTEGRATION] Fetching system configuration...');
        final config = await repository.getSystemConfig();
        
        print('👨‍💼 [ADMIN_INTEGRATION] ⚙️ System Configuration:');
        print('   - Maintenance Mode: ${config.maintenanceMode}');
        print('   - Min App Version: ${config.minAppVersion}');
        print('   - Max Pickup Weight: ${config.maxPickupWeight}kg');
        print('   - Min Order Amount: ₹${config.minOrderAmount}');
        
        expect(config, isA<SystemConfigModel>());
        expect(config.maintenanceMode, isA<bool>());
        expect(config.minAppVersion, isA<String>());
        expect(config.maxPickupWeight, isA<double>());
        expect(config.minOrderAmount, isA<double>());
        
        print('👨‍💼 [ADMIN_INTEGRATION] ✅ System configuration retrieved successfully');
      });

      testWidgets('should update system configuration', (WidgetTester tester) async {
        print('👨‍💼 [ADMIN_INTEGRATION] Testing system configuration update...');
        
        // Get current config
        final currentConfig = await repository.getSystemConfig();
        final newMaintenanceMode = !currentConfig.maintenanceMode;
        
        print('👨‍💼 [ADMIN_INTEGRATION] Updating maintenance mode: $newMaintenanceMode');
        await repository.updateSystemConfig({'maintenanceMode': newMaintenanceMode});
        
        // Verify the update
        final updatedConfig = await repository.getSystemConfig();
        
        print('👨‍💼 [ADMIN_INTEGRATION] ✅ System configuration updated successfully');
        print('   - New Maintenance Mode: ${updatedConfig.maintenanceMode}');
        expect(updatedConfig.maintenanceMode, equals(newMaintenanceMode));
      });
    });

    group('Notification Operations', () {
      testWidgets('should create and get notifications', (WidgetTester tester) async {
        print('👨‍💼 [ADMIN_INTEGRATION] Testing notification operations...');
        
        // Create a test notification
        final testNotification = {
          'title': 'Test Notification',
          'message': 'This is a test notification',
          'type': 'info',
          'recipients': ['all'],
          'createdAt': DateTime.now().toIso8601String(),
        };
        
        print('👨‍💼 [ADMIN_INTEGRATION] Creating test notification...');
        await FirebaseFirestore.instance
            .collection('notifications')
            .add(testNotification);
        
        // Get notifications
        final notifications = await repository.getNotifications().first;
        
        print('👨‍💼 [ADMIN_INTEGRATION] ✅ Retrieved ${notifications.length} notifications');
        expect(notifications, isA<List>());
        
        if (notifications.isNotEmpty) {
          final notification = notifications.first;
          print('👨‍💼 [ADMIN_INTEGRATION] 📢 Sample Notification:');
          print('   - Title: ${notification['title']}');
          print('   - Type: ${notification['type']}');
        }
      });
    });

    group('Report Operations', () {
      testWidgets('should create and get reports', (WidgetTester tester) async {
        print('👨‍💼 [ADMIN_INTEGRATION] Testing report operations...');
        
        // Create a test report
        final testReport = {
          'title': 'Test Report',
          'description': 'This is a test report',
          'type': 'analytics',
          'data': {'key': 'value'},
          'createdAt': DateTime.now().toIso8601String(),
        };
        
        print('👨‍💼 [ADMIN_INTEGRATION] Creating test report...');
        await FirebaseFirestore.instance
            .collection('reports')
            .add(testReport);
        
        // Get reports
        final reports = await repository.getReports().first;
        
        print('👨‍💼 [ADMIN_INTEGRATION] ✅ Retrieved ${reports.length} reports');
        expect(reports, isA<List>());
        
        if (reports.isNotEmpty) {
          final report = reports.first;
          print('👨‍💼 [ADMIN_INTEGRATION] 📊 Sample Report:');
          print('   - Title: ${report['title']}');
          print('   - Type: ${report['type']}');
        }
      });
    });
  });
} 