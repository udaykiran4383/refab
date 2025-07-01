import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
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
        final tailors = await repository.getUsersByRole(UserRole.tailor).first;
        
        print('👨‍💼 [ADMIN_TEST] ✅ Retrieved ${tailors.length} tailors');
        
        for (final tailor in tailors) {
          expect(tailor.role, equals(UserRole.tailor));
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
          await repository.updateUserStatus(user.id, newStatus);
          
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
        );

        print('👨‍💼 [ADMIN_TEST] Creating test user for deletion...');
        await FirebaseFirestore.instance
            .collection('users')
            .doc(testUser.id)
            .set(testUser.toMap());
        
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
        print('   - Total Users: ${analytics['totalUsers']}');
        print('   - Active Users: ${analytics['activeUsers']}');
        print('   - Total Orders: ${analytics['totalOrders']}');
        print('   - Total Revenue: ₹${analytics['totalRevenue']}');
        print('   - Pickup Requests: ${analytics['totalPickupRequests']}');
        print('   - Volunteer Hours: ${analytics['totalVolunteerHours']}');
        
        expect(analytics['totalUsers'], isA<int>());
        expect(analytics['activeUsers'], isA<int>());
        expect(analytics['totalOrders'], isA<int>());
        expect(analytics['totalRevenue'], isA<double>());
        expect(analytics['totalPickupRequests'], isA<int>());
        expect(analytics['totalVolunteerHours'], isA<double>());
        
        print('👨‍💼 [ADMIN_TEST] ✅ System analytics retrieved successfully');
      });

      test('should get role-based analytics', () async {
        print('👨‍💼 [ADMIN_TEST] Testing role-based analytics...');
        
        print('👨‍💼 [ADMIN_TEST] Fetching analytics by role...');
        final roleAnalytics = await repository.getAnalyticsByRole();
        
        print('👨‍💼 [ADMIN_TEST] 📊 Role-based Analytics:');
        for (final entry in roleAnalytics.entries) {
          print('   - ${entry.key}: ${entry.value} users');
        }
        
        expect(roleAnalytics, isA<Map<String, int>>());
        expect(roleAnalytics.isNotEmpty, isTrue);
        
        print('👨‍💼 [ADMIN_TEST] ✅ Role-based analytics retrieved successfully');
      });

      test('should get revenue analytics', () async {
        print('👨‍💼 [ADMIN_TEST] Testing revenue analytics...');
        
        print('👨‍💼 [ADMIN_TEST] Fetching revenue analytics...');
        final revenueAnalytics = await repository.getRevenueAnalytics();
        
        print('👨‍💼 [ADMIN_TEST] 💰 Revenue Analytics:');
        print('   - Total Revenue: ₹${revenueAnalytics['totalRevenue']}');
        print('   - Monthly Revenue: ₹${revenueAnalytics['monthlyRevenue']}');
        print('   - Average Order Value: ₹${revenueAnalytics['averageOrderValue']}');
        print('   - Top Products: ${revenueAnalytics['topProducts']}');
        
        expect(revenueAnalytics['totalRevenue'], isA<double>());
        expect(revenueAnalytics['monthlyRevenue'], isA<double>());
        expect(revenueAnalytics['averageOrderValue'], isA<double>());
        expect(revenueAnalytics['topProducts'], isA<List>());
        
        print('👨‍💼 [ADMIN_TEST] ✅ Revenue analytics retrieved successfully');
      });
    });

    group('System Configuration CRUD Operations', () {
      test('should get system configuration', () async {
        print('👨‍💼 [ADMIN_TEST] Testing system configuration retrieval...');
        
        print('👨‍💼 [ADMIN_TEST] Fetching system configuration...');
        final config = await repository.getSystemConfiguration();
        
        if (config != null) {
          print('👨‍💼 [ADMIN_TEST] ⚙️ System Configuration:');
          print('   - App Version: ${config.appVersion}');
          print('   - Maintenance Mode: ${config.maintenanceMode}');
          print('   - Max Pickup Weight: ${config.maxPickupWeight}kg');
          print('   - Pickup Radius: ${config.pickupRadius}km');
          print('   - Notification Settings: ${config.notificationSettings}');
          
          expect(config.appVersion, isNotEmpty);
          expect(config.maxPickupWeight, greaterThan(0));
          expect(config.pickupRadius, greaterThan(0));
        } else {
          print('👨‍💼 [ADMIN_TEST] ⚠️ No system configuration found');
        }
      });

      test('should update system configuration', () async {
        print('👨‍💼 [ADMIN_TEST] Testing system configuration update...');
        
        final updates = {
          'maintenanceMode': true,
          'maxPickupWeight': 25.0,
          'pickupRadius': 15.0,
          'notificationSettings': {
            'emailNotifications': true,
            'pushNotifications': true,
            'smsNotifications': false,
          },
        };

        print('👨‍💼 [ADMIN_TEST] Updating system configuration...');
        await repository.updateSystemConfiguration(updates);
        
        print('👨‍💼 [ADMIN_TEST] Fetching updated configuration...');
        final updatedConfig = await repository.getSystemConfiguration();
        
        if (updatedConfig != null) {
          print('👨‍💼 [ADMIN_TEST] ✅ System configuration updated successfully');
          print('   - Maintenance Mode: ${updatedConfig.maintenanceMode}');
          print('   - Max Pickup Weight: ${updatedConfig.maxPickupWeight}kg');
          print('   - Pickup Radius: ${updatedConfig.pickupRadius}km');
          
          expect(updatedConfig.maintenanceMode, isTrue);
          expect(updatedConfig.maxPickupWeight, equals(25.0));
          expect(updatedConfig.pickupRadius, equals(15.0));
        }
      });
    });

    group('Content Management', () {
      test('should manage product categories', () async {
        print('👨‍💼 [ADMIN_TEST] Testing product category management...');
        
        final newCategory = {
          'name': 'Test Category',
          'description': 'Test category for admin testing',
          'isActive': true,
        };

        print('👨‍💼 [ADMIN_TEST] Adding new product category...');
        await repository.addProductCategory(newCategory);
        
        print('👨‍💼 [ADMIN_TEST] Fetching product categories...');
        final categories = await repository.getProductCategories();
        
        print('👨‍💼 [ADMIN_TEST] ✅ Product category management successful');
        print('   - Total Categories: ${categories.length}');
        
        expect(categories, isA<List>());
        expect(categories.isNotEmpty, isTrue);
      });

      test('should manage promotional content', () async {
        print('👨‍💼 [ADMIN_TEST] Testing promotional content management...');
        
        final promotion = {
          'title': 'Test Promotion',
          'description': 'Test promotional content',
          'discount': 15.0,
          'validFrom': DateTime.now(),
          'validUntil': DateTime.now().add(Duration(days: 30)),
          'isActive': true,
        };

        print('👨‍💼 [ADMIN_TEST] Adding promotional content...');
        await repository.addPromotionalContent(promotion);
        
        print('👨‍💼 [ADMIN_TEST] Fetching active promotions...');
        final promotions = await repository.getActivePromotions();
        
        print('👨‍💼 [ADMIN_TEST] ✅ Promotional content management successful');
        print('   - Active Promotions: ${promotions.length}');
        
        expect(promotions, isA<List>());
      });
    });

    group('Reporting Operations', () {
      test('should generate user activity report', () async {
        print('👨‍💼 [ADMIN_TEST] Testing user activity report generation...');
        
        print('👨‍💼 [ADMIN_TEST] Generating user activity report...');
        final report = await repository.generateUserActivityReport();
        
        print('👨‍💼 [ADMIN_TEST] 📋 User Activity Report:');
        print('   - Report ID: ${report['reportId']}');
        print('   - Generated At: ${report['generatedAt']}');
        print('   - Total Users: ${report['totalUsers']}');
        print('   - Active Users: ${report['activeUsers']}');
        print('   - New Users This Month: ${report['newUsersThisMonth']}');
        
        expect(report['reportId'], isNotEmpty);
        expect(report['totalUsers'], isA<int>());
        expect(report['activeUsers'], isA<int>());
        expect(report['newUsersThisMonth'], isA<int>());
        
        print('👨‍💼 [ADMIN_TEST] ✅ User activity report generated successfully');
      });

      test('should generate financial report', () async {
        print('👨‍💼 [ADMIN_TEST] Testing financial report generation...');
        
        print('👨‍💼 [ADMIN_TEST] Generating financial report...');
        final report = await repository.generateFinancialReport();
        
        print('👨‍💼 [ADMIN_TEST] 💰 Financial Report:');
        print('   - Report ID: ${report['reportId']}');
        print('   - Total Revenue: ₹${report['totalRevenue']}');
        print('   - Monthly Revenue: ₹${report['monthlyRevenue']}');
        print('   - Total Orders: ${report['totalOrders']}');
        print('   - Average Order Value: ₹${report['averageOrderValue']}');
        
        expect(report['reportId'], isNotEmpty);
        expect(report['totalRevenue'], isA<double>());
        expect(report['monthlyRevenue'], isA<double>());
        expect(report['totalOrders'], isA<int>());
        expect(report['averageOrderValue'], isA<double>());
        
        print('👨‍💼 [ADMIN_TEST] ✅ Financial report generated successfully');
      });
    });

    group('Error Handling', () {
      test('should handle invalid user operations', () async {
        print('👨‍💼 [ADMIN_TEST] Testing error handling for invalid user operations...');
        
        try {
          await repository.updateUserStatus('non_existent_user_id', true);
          fail('Should have thrown an exception');
        } catch (e) {
          print('👨‍💼 [ADMIN_TEST] ✅ Error handled correctly: $e');
          expect(e, isA<Exception>());
        }
      });

      test('should handle invalid configuration updates', () async {
        print('👨‍💼 [ADMIN_TEST] Testing error handling for invalid configuration...');
        
        try {
          await repository.updateSystemConfiguration({
            'invalidField': 'invalidValue',
            'maxPickupWeight': -1, // Invalid negative weight
          });
          fail('Should have thrown an exception');
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
        futures.add(repository.getAnalyticsByRole());
        futures.add(repository.getRevenueAnalytics());
        futures.add(repository.generateUserActivityReport());
        futures.add(repository.generateFinancialReport());

        print('👨‍💼 [ADMIN_TEST] Executing 5 concurrent analytics requests...');
        final results = await Future.wait(futures);
        
        print('👨‍💼 [ADMIN_TEST] ✅ All concurrent analytics requests completed');
        expect(results.length, equals(5));
        
        for (int i = 0; i < results.length; i++) {
          expect(results[i], isNotNull);
          print('👨‍💼 [ADMIN_TEST]   - Analytics request $i completed successfully');
        }
      });
    });
  });
} 