import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:refab_app/features/admin/data/repositories/admin_repository.dart';
import 'package:refab_app/features/admin/data/models/analytics_model.dart';
import 'package:refab_app/features/admin/data/models/system_config_model.dart';
import 'package:refab_app/features/admin/data/models/notification_model.dart';
import 'package:refab_app/features/admin/data/models/report_model.dart';
import 'package:refab_app/features/auth/data/models/user_model.dart';

void main() {
  group('Admin Integration Tests', () {
    late AdminRepository repository;
    late String testAdminId;
    late FirebaseFirestore firestore;

    setUpAll(() async {
      print('🔧 [ADMIN_INTEGRATION] Setting up Firebase for integration testing...');
      TestWidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
      firestore = FirebaseFirestore.instance;
      print('🔧 [ADMIN_INTEGRATION] ✅ Firebase initialized');
    });

    setUp(() {
      print('🔧 [ADMIN_INTEGRATION] Setting up test environment...');
      repository = AdminRepository();
      testAdminId = 'test_admin_${DateTime.now().millisecondsSinceEpoch}';
      print('🔧 [ADMIN_INTEGRATION] ✅ Test environment ready. Admin ID: $testAdminId');
    });

    tearDown(() async {
      print('🔧 [ADMIN_INTEGRATION] Cleaning up test data...');
      try {
        // Clean up test data
        await _cleanupTestData(testAdminId);
        print('🔧 [ADMIN_INTEGRATION] ✅ Test data cleaned up');
      } catch (e) {
        print('🔧 [ADMIN_INTEGRATION] ⚠️ Cleanup warning: $e');
      }
    });

    group('User Management Integration', () {
      test('should perform complete user CRUD operations', () async {
        print('🔧 [ADMIN_INTEGRATION] Testing complete user CRUD operations...');

        // Create test user
        final testUser = UserModel(
          id: 'test_user_${DateTime.now().millisecondsSinceEpoch}',
          name: 'Integration Test User',
          email: 'integration@test.com',
          role: UserRole.customer,
          isActive: true,
          createdAt: DateTime.now(),
          phone: '+1234567890',
          address: 'Test Address',
        );

        print('🔧 [ADMIN_INTEGRATION] Creating test user...');
        await firestore.collection('users').doc(testUser.id).set(testUser.toJson());

        // Test get all users
        print('🔧 [ADMIN_INTEGRATION] Testing get all users...');
        final users = await repository.getAllUsers().first;
        expect(users.any((u) => u.id == testUser.id), isTrue);

        // Test get users by role
        print('🔧 [ADMIN_INTEGRATION] Testing get users by role...');
        final customers = await repository.getUsersByRole('customer').first;
        expect(customers.any((u) => u.id == testUser.id), isTrue);

        // Test update user
        print('🔧 [ADMIN_INTEGRATION] Testing update user...');
        await repository.updateUser(testUser.id, {'name': 'Updated Integration User'});
        
        final updatedUsers = await repository.getAllUsers().first;
        final updatedUser = updatedUsers.firstWhere((u) => u.id == testUser.id);
        expect(updatedUser.name, equals('Updated Integration User'));

        // Test deactivate user
        print('🔧 [ADMIN_INTEGRATION] Testing deactivate user...');
        await repository.deactivateUser(testUser.id);
        
        final deactivatedUsers = await repository.getAllUsers().first;
        final deactivatedUser = deactivatedUsers.firstWhere((u) => u.id == testUser.id);
        expect(deactivatedUser.isActive, isFalse);

        // Test activate user
        print('🔧 [ADMIN_INTEGRATION] Testing activate user...');
        await repository.activateUser(testUser.id);
        
        final activatedUsers = await repository.getAllUsers().first;
        final activatedUser = activatedUsers.firstWhere((u) => u.id == testUser.id);
        expect(activatedUser.isActive, isTrue);

        // Test delete user
        print('🔧 [ADMIN_INTEGRATION] Testing delete user...');
        await repository.deleteUser(testUser.id);
        
        final remainingUsers = await repository.getAllUsers().first;
        expect(remainingUsers.any((u) => u.id == testUser.id), isFalse);

        print('🔧 [ADMIN_INTEGRATION] ✅ Complete user CRUD operations successful');
      });

      test('should handle bulk user operations', () async {
        print('🔧 [ADMIN_INTEGRATION] Testing bulk user operations...');

        // Create multiple test users
        final testUsers = List.generate(5, (index) => UserModel(
          id: 'bulk_test_user_${index}_${DateTime.now().millisecondsSinceEpoch}',
          name: 'Bulk Test User $index',
          email: 'bulk$index@test.com',
          role: index % 2 == 0 ? UserRole.customer : UserRole.tailor,
          isActive: true,
          createdAt: DateTime.now(),
          phone: '+1234567890',
          address: 'Test Address',
        ));

        print('🔧 [ADMIN_INTEGRATION] Creating ${testUsers.length} test users...');
        final batch = firestore.batch();
        for (final user in testUsers) {
          batch.set(firestore.collection('users').doc(user.id), user.toJson());
        }
        await batch.commit();

        // Test bulk operations
        print('🔧 [ADMIN_INTEGRATION] Testing bulk deactivation...');
        for (final user in testUsers) {
          await repository.deactivateUser(user.id);
        }

        final allUsers = await repository.getAllUsers().first;
        final deactivatedUsers = allUsers.where((u) => 
          testUsers.any((tu) => tu.id == u.id)
        ).toList();

        expect(deactivatedUsers.every((u) => !u.isActive), isTrue);

        print('🔧 [ADMIN_INTEGRATION] Testing bulk activation...');
        for (final user in testUsers) {
          await repository.activateUser(user.id);
        }

        final reactivatedUsers = await repository.getAllUsers().first;
        final activeUsers = reactivatedUsers.where((u) => 
          testUsers.any((tu) => tu.id == u.id)
        ).toList();

        expect(activeUsers.every((u) => u.isActive), isTrue);

        print('🔧 [ADMIN_INTEGRATION] ✅ Bulk user operations successful');
      });
    });

    group('Analytics Integration', () {
      test('should generate comprehensive analytics', () async {
        print('🔧 [ADMIN_INTEGRATION] Testing comprehensive analytics generation...');

        // Create test data for analytics
        await _createTestDataForAnalytics(testAdminId);

        // Test system analytics
        print('🔧 [ADMIN_INTEGRATION] Testing system analytics...');
        final analytics = await repository.getSystemAnalytics();
        
        expect(analytics, isA<AnalyticsModel>());
        expect(analytics.totalUsers, greaterThan(0));
        expect(analytics.activeUsers, greaterThan(0));
        expect(analytics.totalPickupRequests, greaterThan(0));
        expect(analytics.totalOrders, greaterThan(0));

        print('🔧 [ADMIN_INTEGRATION] 📊 Analytics Results:');
        print('   - Total Users: ${analytics.totalUsers}');
        print('   - Active Users: ${analytics.activeUsers}');
        print('   - Total Pickup Requests: ${analytics.totalPickupRequests}');
        print('   - Total Orders: ${analytics.totalOrders}');
        print('   - Total Revenue: ${analytics.formattedRevenue}');
        print('   - Pickup Growth Rate: ${analytics.pickupGrowthRate}%');

        print('🔧 [ADMIN_INTEGRATION] ✅ Comprehensive analytics successful');
      });

      test('should generate role-based analytics', () async {
        print('🔧 [ADMIN_INTEGRATION] Testing role-based analytics...');

        // Test analytics by role
        final customerUsers = await repository.getUsersByRole('customer').first;
        final tailorUsers = await repository.getUsersByRole('tailor').first;
        final volunteerUsers = await repository.getUsersByRole('volunteer').first;

        print('🔧 [ADMIN_INTEGRATION] 📊 Role-based Analytics:');
        print('   - Customers: ${customerUsers.length}');
        print('   - Tailors: ${tailorUsers.length}');
        print('   - Volunteers: ${volunteerUsers.length}');

        expect(customerUsers.every((u) => u.role == UserRole.customer), isTrue);
        expect(tailorUsers.every((u) => u.role == UserRole.tailor), isTrue);
        expect(volunteerUsers.every((u) => u.role == UserRole.volunteer), isTrue);

        print('🔧 [ADMIN_INTEGRATION] ✅ Role-based analytics successful');
      });
    });

    group('System Configuration Integration', () {
      test('should manage system configuration', () async {
        print('🔧 [ADMIN_INTEGRATION] Testing system configuration management...');

        // Test get system config
        print('🔧 [ADMIN_INTEGRATION] Testing get system config...');
        final config = await repository.getSystemConfig();
        expect(config, isA<SystemConfigModel>());

        // Test update system config
        print('🔧 [ADMIN_INTEGRATION] Testing update system config...');
        final updatedConfig = config.copyWith(
          maintenanceMode: true,
          maxPickupWeight: 25.0,
          minOrderAmount: 100.0,
          volunteerCertificateHours: 50,
        );

        await repository.updateSystemConfig(updatedConfig);

        // Verify update
        final newConfig = await repository.getSystemConfig();
        expect(newConfig.maintenanceMode, isTrue);
        expect(newConfig.maxPickupWeight, equals(25.0));
        expect(newConfig.minOrderAmount, equals(100.0));
        expect(newConfig.volunteerCertificateHours, equals(50));

        print('🔧 [ADMIN_INTEGRATION] ⚙️ System Configuration:');
        print('   - Maintenance Mode: ${newConfig.maintenanceMode}');
        print('   - Max Pickup Weight: ${newConfig.maxPickupWeight}kg');
        print('   - Min Order Amount: ₹${newConfig.minOrderAmount}');
        print('   - Volunteer Certificate Hours: ${newConfig.volunteerCertificateHours}');

        print('🔧 [ADMIN_INTEGRATION] ✅ System configuration management successful');
      });
    });

    group('Notifications Integration', () {
      test('should manage notifications', () async {
        print('🔧 [ADMIN_INTEGRATION] Testing notification management...');

        // Create test notification
        final testNotification = NotificationModel(
          id: 'test_notification_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Integration Test Notification',
          message: 'This is a test notification for integration testing',
          type: 'system',
          targetRoles: ['admin'],
          createdAt: DateTime.now(),
        );

        print('🔧 [ADMIN_INTEGRATION] Creating test notification...');
        await firestore.collection('notifications').doc(testNotification.id).set(testNotification.toJson());

        // Test get all notifications
        print('🔧 [ADMIN_INTEGRATION] Testing get all notifications...');
        final notifications = await repository.getAllNotifications().first;
        expect(notifications.any((n) => n.id == testNotification.id), isTrue);

        // Test mark as read
        print('🔧 [ADMIN_INTEGRATION] Testing mark as read...');
        await repository.markNotificationAsRead(testNotification.id);

        final updatedNotifications = await repository.getAllNotifications().first;
        final updatedNotification = updatedNotifications.firstWhere((n) => n.id == testNotification.id);
        expect(updatedNotification.isRead, isTrue);

        // Test delete notification
        print('🔧 [ADMIN_INTEGRATION] Testing delete notification...');
        await repository.deleteNotification(testNotification.id);

        final remainingNotifications = await repository.getAllNotifications().first;
        expect(remainingNotifications.any((n) => n.id == testNotification.id), isFalse);

        print('🔧 [ADMIN_INTEGRATION] ✅ Notification management successful');
      });
    });

    group('Reports Integration', () {
      test('should generate and manage reports', () async {
        print('🔧 [ADMIN_INTEGRATION] Testing report generation and management...');

        // Create test report
        final testReport = ReportModel(
          id: 'test_report_${DateTime.now().millisecondsSinceEpoch}',
          reportType: 'pickup_requests',
          title: 'Integration Test Report',
          description: 'Test report for integration testing',
          startDate: DateTime.now().subtract(Duration(days: 30)),
          endDate: DateTime.now(),
          generatedAt: DateTime.now(),
          generatedBy: 'admin',
          data: {
            'totalRequests': 100,
            'completedRequests': 85,
            'pendingRequests': 15,
            'successRate': 85.0,
          },
        );

        print('🔧 [ADMIN_INTEGRATION] Creating test report...');
        await firestore.collection('reports').doc(testReport.id).set(testReport.toJson());

        // Test get all reports
        print('🔧 [ADMIN_INTEGRATION] Testing get all reports...');
        final reports = await repository.getAllReports();
        expect(reports.any((r) => r.id == testReport.id), isTrue);

        // Test delete report
        print('🔧 [ADMIN_INTEGRATION] Testing delete report...');
        await repository.deleteReport(testReport.id);

        final remainingReports = await repository.getAllReports();
        expect(remainingReports.any((r) => r.id == testReport.id), isFalse);

        print('🔧 [ADMIN_INTEGRATION] ✅ Report management successful');
      });
    });

    group('System Health Integration', () {
      test('should monitor system health', () async {
        print('🔧 [ADMIN_INTEGRATION] Testing system health monitoring...');

        // Test get system health
        print('🔧 [ADMIN_INTEGRATION] Testing get system health...');
        final health = await repository.getSystemHealth();

        expect(health, isA<Map<String, dynamic>>());
        expect(health['systemStatus'], isA<String>());
        expect(health['totalUsers'], isA<int>());
        expect(health['totalPickupRequests'], isA<int>());
        expect(health['totalOrders'], isA<int>());

        print('🔧 [ADMIN_INTEGRATION] 🏥 System Health:');
        print('   - Status: ${health['systemStatus']}');
        print('   - Total Users: ${health['totalUsers']}');
        print('   - Total Pickup Requests: ${health['totalPickupRequests']}');
        print('   - Total Orders: ${health['totalOrders']}');
        print('   - Pending Pickups: ${health['pendingPickups']}');
        print('   - Pending Orders: ${health['pendingOrders']}');

        print('🔧 [ADMIN_INTEGRATION] ✅ System health monitoring successful');
      });

      test('should create system backup', () async {
        print('🔧 [ADMIN_INTEGRATION] Testing system backup creation...');

        // Test create backup
        print('🔧 [ADMIN_INTEGRATION] Creating system backup...');
        await repository.createSystemBackup();

        print('🔧 [ADMIN_INTEGRATION] ✅ System backup creation successful');
      });
    });

    group('Error Handling Integration', () {
      test('should handle invalid operations gracefully', () async {
        print('🔧 [ADMIN_INTEGRATION] Testing error handling...');

        // Test invalid user operations
        try {
          await repository.updateUser('non_existent_user', {'name': 'Test'});
          print('🔧 [ADMIN_INTEGRATION] ⚠️ Update non-existent user did not throw error');
        } catch (e) {
          print('🔧 [ADMIN_INTEGRATION] ✅ Error handled for non-existent user update: $e');
        }

        try {
          await repository.deleteUser('non_existent_user');
          print('🔧 [ADMIN_INTEGRATION] ⚠️ Delete non-existent user did not throw error');
        } catch (e) {
          print('🔧 [ADMIN_INTEGRATION] ✅ Error handled for non-existent user deletion: $e');
        }

        print('🔧 [ADMIN_INTEGRATION] ✅ Error handling tests completed');
      });
    });

    group('Performance Integration', () {
      test('should handle large datasets efficiently', () async {
        print('🔧 [ADMIN_INTEGRATION] Testing performance with large datasets...');

        // Create large dataset
        print('🔧 [ADMIN_INTEGRATION] Creating large dataset...');
        await _createLargeDataset(testAdminId);

        // Test performance
        print('🔧 [ADMIN_INTEGRATION] Testing analytics performance...');
        final startTime = DateTime.now();
        
        final analytics = await repository.getSystemAnalytics();
        
        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);

        print('🔧 [ADMIN_INTEGRATION] ⚡ Performance Results:');
        print('   - Analytics Generation Time: ${duration.inMilliseconds}ms');
        print('   - Total Users: ${analytics.totalUsers}');
        print('   - Total Pickup Requests: ${analytics.totalPickupRequests}');

        expect(duration.inMilliseconds, lessThan(10000)); // Should complete within 10 seconds

        print('🔧 [ADMIN_INTEGRATION] ✅ Performance test passed');
      });
    });
  });
}

// Helper functions
Future<void> _cleanupTestData(String testAdminId) async {
  final firestore = FirebaseFirestore.instance;
  
  // Clean up users
  final users = await firestore.collection('users')
      .where('createdBy', isEqualTo: testAdminId)
      .get();
  
  final batch = firestore.batch();
  for (var doc in users.docs) {
    batch.delete(doc.reference);
  }
  
  // Clean up other test data
  final collections = ['notifications', 'reports', 'pickupRequests', 'orders', 'products'];
  for (final collection in collections) {
    final docs = await firestore.collection(collection)
        .where('createdBy', isEqualTo: testAdminId)
        .get();
    
    for (var doc in docs.docs) {
      batch.delete(doc.reference);
    }
  }
  
  await batch.commit();
}

Future<void> _createTestDataForAnalytics(String testAdminId) async {
  final firestore = FirebaseFirestore.instance;
  final batch = firestore.batch();

  // Create test users
  for (int i = 0; i < 10; i++) {
    final user = {
      'name': 'Test User $i',
      'email': 'test$i@example.com',
      'role': i % 3 == 0 ? UserRole.customer : i % 3 == 1 ? UserRole.tailor : UserRole.volunteer,
      'isActive': true,
      'createdAt': DateTime.now().toIso8601String(),
      'createdBy': testAdminId,
    };
    batch.set(firestore.collection('users').doc('test_user_$i'), user);
  }

  // Create test pickup requests
  for (int i = 0; i < 15; i++) {
    final pickup = {
      'customerId': 'test_user_${i % 10}',
      'status': i % 4 == 0 ? 'pending' : i % 4 == 1 ? 'assigned' : i % 4 == 2 ? 'completed' : 'cancelled',
      'createdAt': DateTime.now().toIso8601String(),
      'createdBy': testAdminId,
    };
    batch.set(firestore.collection('pickupRequests').doc('test_pickup_$i'), pickup);
  }

  // Create test orders
  for (int i = 0; i < 20; i++) {
    final order = {
      'customerId': 'test_user_${i % 10}',
      'totalAmount': 100.0 + (i * 10),
      'status': i % 3 == 0 ? 'pending' : i % 3 == 1 ? 'processing' : 'completed',
      'createdAt': DateTime.now().toIso8601String(),
      'createdBy': testAdminId,
    };
    batch.set(firestore.collection('orders').doc('test_order_$i'), order);
  }

  await batch.commit();
}

Future<void> _createLargeDataset(String testAdminId) async {
  final firestore = FirebaseFirestore.instance;
  final batch = firestore.batch();

  // Create 100 test users
  for (int i = 0; i < 100; i++) {
    final user = {
      'name': 'Large Test User $i',
      'email': 'large$i@example.com',
      'role': i % 4 == 0 ? UserRole.customer : i % 4 == 1 ? UserRole.tailor : i % 4 == 2 ? UserRole.volunteer : UserRole.admin,
      'isActive': true,
      'createdAt': DateTime.now().toIso8601String(),
      'createdBy': testAdminId,
    };
    batch.set(firestore.collection('users').doc('large_user_$i'), user);
  }

  // Create 200 test pickup requests
  for (int i = 0; i < 200; i++) {
    final pickup = {
      'customerId': 'large_user_${i % 100}',
      'status': i % 5 == 0 ? 'pending' : i % 5 == 1 ? 'assigned' : i % 5 == 2 ? 'completed' : i % 5 == 3 ? 'cancelled' : 'processing',
      'createdAt': DateTime.now().toIso8601String(),
      'createdBy': testAdminId,
    };
    batch.set(firestore.collection('pickupRequests').doc('large_pickup_$i'), pickup);
  }

  await batch.commit();
} 