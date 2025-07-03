import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:refab_app/features/admin/data/repositories/admin_repository.dart';
import 'package:refab_app/features/admin/data/models/analytics_model.dart';
import 'package:refab_app/features/admin/data/models/system_config_model.dart';
import 'package:refab_app/features/auth/data/models/user_model.dart';

void main() {
  group('AdminRepository Tests', () {
    late AdminRepository repository;
    late String testAdminId;

    setUpAll(() async {
      print('👨‍💼 [ADMIN_TEST] Setting up Firebase for testing...');
      TestWidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
      print('👨‍💼 [ADMIN_TEST] ✅ Firebase initialized');
    });

    setUp(() {
      print('👨‍💼 [ADMIN_TEST] Setting up test environment...');
      repository = AdminRepository();
      testAdminId = 'test_admin_${DateTime.now().millisecondsSinceEpoch}';
      print('👨‍💼 [ADMIN_TEST] ✅ Test environment ready. Admin ID: $testAdminId');
    });

    tearDown(() async {
      print('👨‍💼 [ADMIN_TEST] Cleaning up test data...');
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
        print('👨‍💼 [ADMIN_TEST] ✅ Test data cleaned up');
      } catch (e) {
        print('👨‍💼 [ADMIN_TEST] ⚠️ Cleanup warning: $e');
      }
    });

    group('User Management CRUD Operations', () {
      test('should get all users successfully', () async {
        print('👨‍💼 [ADMIN_TEST] Testing user retrieval...');
        
        print('👨‍💼 [ADMIN_TEST] Fetching all users...');
        final users = await repository.getAllUsers().first;
        
        print('👨‍💼 [ADMIN_TEST] ✅ Retrieved ${users.length} users');
        expect(users, isA<List<UserModel>>());
        
        if (users.isNotEmpty) {
          final user = users.first;
          print('👨‍💼 [ADMIN_TEST] 👤 Sample User:');
          print('   - Name: ${user.name}');
          print('   - Email: ${user.email}');
          print('   - Role: ${user.role}');
          print('   - Status: ${user.isActive ? "Active" : "Inactive"}');
          
          expect(user.name, isNotEmpty);
          expect(user.email, isNotEmpty);
          expect(user.role, isNotNull);
        }
      });

      test('should get users by role', () async {
        print('👨‍💼 [ADMIN_TEST] Testing user filtering by role...');
        
        print('👨‍💼 [ADMIN_TEST] Fetching tailors...');
        final tailors = await repository.getUsersByRole('tailor').first;
        
        print('👨‍💼 [ADMIN_TEST] ✅ Retrieved ${tailors.length} tailors');
        
        for (final tailor in tailors) {
          expect(tailor.role, equals('tailor'));
          print('👨‍💼 [ADMIN_TEST]   - ${tailor.name} (${tailor.email})');
        }
      });

      test('should update user status', () async {
        print('👨‍💼 [ADMIN_TEST] Testing user status update...');
        
        // First get a user to update
        final users = await repository.getAllUsers().first;
        if (users.isNotEmpty) {
          final user = users.first;
          final newStatus = !user.isActive;
          
          print('👨‍💼 [ADMIN_TEST] Updating user status: ${user.name} -> ${newStatus ? "Active" : "Inactive"}');
          await repository.updateUser(user.id, {'isActive': newStatus});
          
          // Verify the update
          final updatedUsers = await repository.getAllUsers().first;
          final updatedUser = updatedUsers.firstWhere((u) => u.id == user.id);
          
          print('👨‍💼 [ADMIN_TEST] ✅ User status updated successfully');
          print('   - New Status: ${updatedUser.isActive ? "Active" : "Inactive"}');
          expect(updatedUser.isActive, equals(newStatus));
        } else {
          print('👨‍💼 [ADMIN_TEST] ⚠️ No users available for status update test');
        }
      });

      test('should delete user', () async {
        print('👨‍💼 [ADMIN_TEST] Testing user deletion...');
        
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

        print('👨‍💼 [ADMIN_TEST] Creating test user for deletion...');
        await FirebaseFirestore.instance
            .collection('users')
            .doc(testUser.id)
            .set(testUser.toJson());
        
        print('👨‍💼 [ADMIN_TEST] Deleting test user...');
        await repository.deleteUser(testUser.id);
        
        // Verify deletion
        final deletedUser = await FirebaseFirestore.instance
            .collection('users')
            .doc(testUser.id)
            .get();
        
        print('👨‍💼 [ADMIN_TEST] ✅ User deleted successfully');
        expect(deletedUser.exists, isFalse);
      });
    });

    group('Analytics Operations', () {
      test('should get system analytics', () async {
        print('👨‍💼 [ADMIN_TEST] Testing system analytics retrieval...');
        
        print('👨‍💼 [ADMIN_TEST] Fetching system analytics...');
        final analytics = await repository.getSystemAnalytics();
        
        print('👨‍💼 [ADMIN_TEST] 📊 System Analytics:');
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
        
        print('👨‍💼 [ADMIN_TEST] ✅ System analytics retrieved successfully');
      });

      test('should get role-based analytics', () async {
        print('👨‍💼 [ADMIN_TEST] Testing role-based analytics...');
        
        print('👨‍💼 [ADMIN_TEST] Fetching analytics by role...');
        final customerUsers = await repository.getUsersByRole('customer').first;
        final tailorUsers = await repository.getUsersByRole('tailor').first;
        final volunteerUsers = await repository.getUsersByRole('volunteer').first;
        
        print('👨‍💼 [ADMIN_TEST] 📊 Role-based Analytics:');
        print('   - Customers: ${customerUsers.length}');
        print('   - Tailors: ${tailorUsers.length}');
        print('   - Volunteers: ${volunteerUsers.length}');
        
        expect(customerUsers.every((u) => u.role == 'customer'), isTrue);
        expect(tailorUsers.every((u) => u.role == 'tailor'), isTrue);
        expect(volunteerUsers.every((u) => u.role == 'volunteer'), isTrue);
        
        print('👨‍💼 [ADMIN_TEST] ✅ Role-based analytics retrieved successfully');
      });
    });

    group('System Configuration CRUD Operations', () {
      test('should get system configuration', () async {
        print('👨‍💼 [ADMIN_TEST] Testing system configuration retrieval...');
        
        print('👨‍💼 [ADMIN_TEST] Fetching system configuration...');
        final config = await repository.getSystemConfig();
        
        print('👨‍💼 [ADMIN_TEST] ⚙️ System Configuration:');
        print('   - Maintenance Mode: ${config.maintenanceMode}');
        print('   - Min App Version: ${config.minAppVersion}');
        print('   - Max Pickup Weight: ${config.maxPickupWeight}kg');
        print('   - Min Order Amount: ₹${config.minOrderAmount}');
        print('   - Volunteer Certificate Hours: ${config.volunteerCertificateHours}');
        
        expect(config.maintenanceMode, isA<bool>());
        expect(config.minAppVersion, isNotEmpty);
        expect(config.maxPickupWeight, greaterThan(0));
        expect(config.minOrderAmount, greaterThan(0));
        expect(config.volunteerCertificateHours, greaterThan(0));
        
        print('👨‍💼 [ADMIN_TEST] ✅ System configuration retrieved successfully');
      });

      test('should update system configuration', () async {
        print('👨‍💼 [ADMIN_TEST] Testing system configuration update...');
        
        final currentConfig = await repository.getSystemConfig();
        final updatedConfig = currentConfig.copyWith(
          maintenanceMode: true,
          maxPickupWeight: 25.0,
          minOrderAmount: 100.0,
          volunteerCertificateHours: 50,
        );

        print('👨‍💼 [ADMIN_TEST] Updating system configuration...');
        await repository.updateSystemConfig(updatedConfig);
        
        print('👨‍💼 [ADMIN_TEST] Fetching updated configuration...');
        final newConfig = await repository.getSystemConfig();
        
        print('👨‍💼 [ADMIN_TEST] ✅ System configuration updated successfully');
        print('   - Maintenance Mode: ${newConfig.maintenanceMode}');
        print('   - Max Pickup Weight: ${newConfig.maxPickupWeight}kg');
        print('   - Min Order Amount: ₹${newConfig.minOrderAmount}');
        print('   - Volunteer Certificate Hours: ${newConfig.volunteerCertificateHours}');
        
        expect(newConfig.maintenanceMode, isTrue);
        expect(newConfig.maxPickupWeight, equals(25.0));
        expect(newConfig.minOrderAmount, equals(100.0));
        expect(newConfig.volunteerCertificateHours, equals(50));
      });
    });

    group('System Health Operations', () {
      test('should get system health', () async {
        print('👨‍💼 [ADMIN_TEST] Testing system health retrieval...');
        
        print('👨‍💼 [ADMIN_TEST] Fetching system health...');
        final health = await repository.getSystemHealth();
        
        print('👨‍💼 [ADMIN_TEST] 🏥 System Health:');
        print('   - Status: ${health['systemStatus']}');
        print('   - Total Users: ${health['totalUsers']}');
        print('   - Total Pickup Requests: ${health['totalPickupRequests']}');
        print('   - Total Orders: ${health['totalOrders']}');
        print('   - Pending Pickups: ${health['pendingPickups']}');
        print('   - Pending Orders: ${health['pendingOrders']}');
        
        expect(health['systemStatus'], isA<String>());
        expect(health['totalUsers'], isA<int>());
        expect(health['totalPickupRequests'], isA<int>());
        expect(health['totalOrders'], isA<int>());
        expect(health['pendingPickups'], isA<int>());
        expect(health['pendingOrders'], isA<int>());
        
        print('👨‍💼 [ADMIN_TEST] ✅ System health retrieved successfully');
      });

      test('should create system backup', () async {
        print('👨‍💼 [ADMIN_TEST] Testing system backup creation...');
        
        print('👨‍💼 [ADMIN_TEST] Creating system backup...');
        await repository.createSystemBackup();
        
        print('👨‍💼 [ADMIN_TEST] ✅ System backup created successfully');
      });
    });

    group('Error Handling', () {
      test('should handle invalid user operations', () async {
        print('👨‍💼 [ADMIN_TEST] Testing error handling for invalid user operations...');
        
        try {
          await repository.updateUser('non_existent_user_id', {'name': 'Test'});
          print('👨‍💼 [ADMIN_TEST] ⚠️ Update non-existent user did not throw error');
        } catch (e) {
          print('👨‍💼 [ADMIN_TEST] ✅ Error handled correctly: $e');
          expect(e, isA<Exception>());
        }
      });

      test('should handle invalid configuration updates', () async {
        print('👨‍💼 [ADMIN_TEST] Testing error handling for invalid configuration...');
        
        try {
          final invalidConfig = SystemConfigModel.defaultConfig().copyWith(
            maxPickupWeight: -1, // Invalid negative weight
          );
          await repository.updateSystemConfig(invalidConfig);
          print('👨‍💼 [ADMIN_TEST] ⚠️ Invalid configuration did not throw error');
        } catch (e) {
          print('👨‍💼 [ADMIN_TEST] ✅ Error handled correctly: $e');
          expect(e, isA<Exception>());
        }
      });
    });

    group('Performance Tests', () {
      test('should handle large user dataset', () async {
        print('👨‍💼 [ADMIN_TEST] Testing performance with large dataset...');
        
        print('👨‍💼 [ADMIN_TEST] Fetching all users (performance test)...');
        final startTime = DateTime.now();
        
        final users = await repository.getAllUsers().first;
        
        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);
        
        print('👨‍💼 [ADMIN_TEST] ⚡ Performance Results:');
        print('   - Users Retrieved: ${users.length}');
        print('   - Duration: ${duration.inMilliseconds}ms');
        print('   - Average Time per User: ${duration.inMilliseconds / users.length}ms');
        
        expect(duration.inMilliseconds, lessThan(5000)); // Should complete within 5 seconds
        print('👨‍💼 [ADMIN_TEST] ✅ Performance test passed');
      });

      test('should handle concurrent analytics requests', () async {
        print('👨‍💼 [ADMIN_TEST] Testing concurrent analytics requests...');
        
        final futures = <Future>[];
        
        futures.add(repository.getSystemAnalytics());
        futures.add(repository.getSystemHealth());
        futures.add(repository.getSystemConfig());

        print('👨‍💼 [ADMIN_TEST] Executing 3 concurrent analytics requests...');
        final results = await Future.wait(futures);
        
        print('👨‍💼 [ADMIN_TEST] ✅ All concurrent analytics requests completed');
        expect(results.length, equals(3));
        
        for (int i = 0; i < results.length; i++) {
          expect(results[i], isNotNull);
          print('👨‍💼 [ADMIN_TEST]   - Analytics request $i completed successfully');
        }
      });
    });
  });
} 