import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:refab_app/features/admin/data/repositories/admin_repository.dart';
import 'package:refab_app/features/admin/data/models/analytics_model.dart';
import 'package:refab_app/features/admin/data/models/system_config_model.dart';
import 'package:refab_app/features/admin/data/models/notification_model.dart';
import 'package:refab_app/features/admin/data/models/report_model.dart';
import 'package:refab_app/features/auth/data/models/user_model.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Admin Comprehensive Integration Tests', () {
    late AdminRepository repository;
    late String testAdminId;
    late FirebaseFirestore firestore;

    setUpAll(() async {
      print('🔧 [ADMIN_COMPREHENSIVE] Setting up Firebase for integration testing...');
      await Firebase.initializeApp();
      firestore = FirebaseFirestore.instance;
      print('🔧 [ADMIN_COMPREHENSIVE] ✅ Firebase initialized');
    });

    setUp(() {
      print('🔧 [ADMIN_COMPREHENSIVE] Setting up test environment...');
      repository = AdminRepository();
      testAdminId = 'test_admin_${DateTime.now().millisecondsSinceEpoch}';
      print('🔧 [ADMIN_COMPREHENSIVE] ✅ Test environment ready. Admin ID: $testAdminId');
    });

    tearDown(() async {
      print('🔧 [ADMIN_COMPREHENSIVE] Cleaning up test data...');
      try {
        await _cleanupTestData(testAdminId);
        print('🔧 [ADMIN_COMPREHENSIVE] ✅ Test data cleaned up');
      } catch (e) {
        print('🔧 [ADMIN_COMPREHENSIVE] ⚠️ Cleanup warning: $e');
      }
    });

    group('User Management Integration', () {
      testWidgets('should perform complete user CRUD operations', (WidgetTester tester) async {
        print('🔧 [ADMIN_COMPREHENSIVE] Testing complete user CRUD operations...');

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

        print('🔧 [ADMIN_COMPREHENSIVE] Creating test user...');
        await firestore.collection('users').doc(testUser.id).set(testUser.toJson());

        // Test get all users
        print('🔧 [ADMIN_COMPREHENSIVE] Testing get all users...');
        final users = await repository.getAllUsers().first;
        expect(users.any((u) => u.id == testUser.id), isTrue);

        // Test get users by role
        print('🔧 [ADMIN_COMPREHENSIVE] Testing get users by role...');
        final customers = await repository.getUsersByRole('customer').first;
        expect(customers.any((u) => u.id == testUser.id), isTrue);

        // Test update user
        print('🔧 [ADMIN_COMPREHENSIVE] Testing update user...');
        await repository.updateUser(testUser.id, {'name': 'Updated Integration User'});
        
        final updatedUsers = await repository.getAllUsers().first;
        final updatedUser = updatedUsers.firstWhere((u) => u.id == testUser.id);
        expect(updatedUser.name, equals('Updated Integration User'));

        // Test deactivate user
        print('🔧 [ADMIN_COMPREHENSIVE] Testing deactivate user...');
        await repository.deactivateUser(testUser.id);
        
        final deactivatedUsers = await repository.getAllUsers().first;
        final deactivatedUser = deactivatedUsers.firstWhere((u) => u.id == testUser.id);
        expect(deactivatedUser.isActive, isFalse);

        // Test activate user
        print('🔧 [ADMIN_COMPREHENSIVE] Testing activate user...');
        await repository.activateUser(testUser.id);
        
        final activatedUsers = await repository.getAllUsers().first;
        final activatedUser = activatedUsers.firstWhere((u) => u.id == testUser.id);
        expect(activatedUser.isActive, isTrue);

        // Test delete user
        print('🔧 [ADMIN_COMPREHENSIVE] Testing delete user...');
        await repository.deleteUser(testUser.id);
        
        final remainingUsers = await repository.getAllUsers().first;
        expect(remainingUsers.any((u) => u.id == testUser.id), isFalse);

        print('🔧 [ADMIN_COMPREHENSIVE] ✅ Complete user CRUD operations successful');
      });

      testWidgets('should handle bulk user operations', (WidgetTester tester) async {
        print('🔧 [ADMIN_COMPREHENSIVE] Testing bulk user operations...');

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

        print('🔧 [ADMIN_COMPREHENSIVE] Creating ${testUsers.length} test users...');
        final batch = firestore.batch();
        for (final user in testUsers) {
          batch.set(firestore.collection('users').doc(user.id), user.toJson());
        }
        await batch.commit();

        // Test bulk operations
        print('🔧 [ADMIN_COMPREHENSIVE] Testing bulk deactivation...');
        for (final user in testUsers) {
          await repository.deactivateUser(user.id);
        }

        final allUsers = await repository.getAllUsers().first;
        final deactivatedUsers = allUsers.where((u) => 
          testUsers.any((tu) => tu.id == u.id)
        ).toList();

        expect(deactivatedUsers.every((u) => !u.isActive), isTrue);

        print('🔧 [ADMIN_COMPREHENSIVE] Testing bulk activation...');
        for (final user in testUsers) {
          await repository.activateUser(user.id);
        }

        final reactivatedUsers = await repository.getAllUsers().first;
        final activeUsers = reactivatedUsers.where((u) => 
          testUsers.any((tu) => tu.id == u.id)
        ).toList();

        expect(activeUsers.every((u) => u.isActive), isTrue);

        print('🔧 [ADMIN_COMPREHENSIVE] ✅ Bulk user operations successful');
      });
    });

    group('Analytics Integration', () {
      testWidgets('should generate comprehensive analytics', (WidgetTester tester) async {
        print('🔧 [ADMIN_COMPREHENSIVE] Testing comprehensive analytics generation...');

        // Create test data for analytics
        await _createTestDataForAnalytics(testAdminId);

        // Test system analytics
        print('🔧 [ADMIN_COMPREHENSIVE] Testing system analytics...');
        final analytics = await repository.getSystemAnalytics();
        
        expect(analytics, isA<AnalyticsModel>());
        expect(analytics.totalUsers, greaterThan(0));
        expect(analytics.activeUsers, greaterThan(0));
        expect(analytics.totalPickupRequests, greaterThan(0));
        expect(analytics.totalOrders, greaterThan(0));

        print('🔧 [ADMIN_COMPREHENSIVE] 📊 Analytics Results:');
        print('   - Total Users: ${analytics.totalUsers}');
        print('   - Active Users: ${analytics.activeUsers}');
        print('   - Total Pickup Requests: ${analytics.totalPickupRequests}');
        print('   - Total Orders: ${analytics.totalOrders}');
        print('   - Total Revenue: ${analytics.formattedRevenue}');
        print('   - Pickup Growth Rate: ${analytics.pickupGrowthRate}%');

        print('🔧 [ADMIN_COMPREHENSIVE] ✅ Comprehensive analytics successful');
      });

      testWidgets('should generate role-based analytics', (WidgetTester tester) async {
        print('🔧 [ADMIN_COMPREHENSIVE] Testing role-based analytics...');

        // Test analytics by role
        final customerUsers = await repository.getUsersByRole('customer').first;
        final tailorUsers = await repository.getUsersByRole('tailor').first;
        final volunteerUsers = await repository.getUsersByRole('volunteer').first;

        print('🔧 [ADMIN_COMPREHENSIVE] 📊 Role-based Analytics:');
        print('   - Customers: ${customerUsers.length}');
        print('   - Tailors: ${tailorUsers.length}');
        print('   - Volunteers: ${volunteerUsers.length}');

        expect(customerUsers.every((u) => u.role == UserRole.customer), isTrue);
        expect(tailorUsers.every((u) => u.role == UserRole.tailor), isTrue);
        expect(volunteerUsers.every((u) => u.role == UserRole.volunteer), isTrue);

        print('🔧 [ADMIN_COMPREHENSIVE] ✅ Role-based analytics successful');
      });
    });

    group('System Configuration Integration', () {
      testWidgets('should manage system configuration', (WidgetTester tester) async {
        print('🔧 [ADMIN_COMPREHENSIVE] Testing system configuration management...');

        // Test get system config
        print('🔧 [ADMIN_COMPREHENSIVE] Testing get system configuration...');
        final config = await repository.getSystemConfig();
        expect(config, isA<SystemConfigModel>());

        // Test update system config
        print('🔧 [ADMIN_COMPREHENSIVE] Testing update system configuration...');
        final newConfig = {
          'maintenanceMode': !config.maintenanceMode,
          'minAppVersion': '2.0.0',
          'maxPickupWeight': 25.0,
          'minOrderAmount': 100.0,
        };

        await repository.updateSystemConfig(newConfig);

        // Verify the update
        final updatedConfig = await repository.getSystemConfig();
        expect(updatedConfig.maintenanceMode, equals(newConfig['maintenanceMode']));
        expect(updatedConfig.minAppVersion, equals(newConfig['minAppVersion']));
        expect(updatedConfig.maxPickupWeight, equals(newConfig['maxPickupWeight']));
        expect(updatedConfig.minOrderAmount, equals(newConfig['minOrderAmount']));

        print('🔧 [ADMIN_COMPREHENSIVE] ✅ System configuration management successful');
      });
    });

    group('Notification Integration', () {
      testWidgets('should manage notifications', (WidgetTester tester) async {
        print('🔧 [ADMIN_COMPREHENSIVE] Testing notification management...');

        // Create test notification
        final testNotification = NotificationModel(
          id: 'test_notification_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Test Notification',
          message: 'This is a test notification',
          type: NotificationType.info,
          recipients: ['all'],
          createdAt: DateTime.now(),
          isRead: false,
        );

        print('🔧 [ADMIN_COMPREHENSIVE] Creating test notification...');
        await firestore.collection('notifications').doc(testNotification.id).set(testNotification.toJson());

        // Test get notifications
        print('🔧 [ADMIN_COMPREHENSIVE] Testing get notifications...');
        final notifications = await repository.getNotifications().first;
        expect(notifications.any((n) => n['id'] == testNotification.id), isTrue);

        // Test mark as read
        print('🔧 [ADMIN_COMPREHENSIVE] Testing mark as read...');
        await repository.markNotificationAsRead(testNotification.id);

        // Verify the update
        final updatedNotifications = await repository.getNotifications().first;
        final updatedNotification = updatedNotifications.firstWhere((n) => n['id'] == testNotification.id);
        expect(updatedNotification['isRead'], isTrue);

        print('🔧 [ADMIN_COMPREHENSIVE] ✅ Notification management successful');
      });
    });

    group('Report Integration', () {
      testWidgets('should manage reports', (WidgetTester tester) async {
        print('🔧 [ADMIN_COMPREHENSIVE] Testing report management...');

        // Create test report
        final testReport = ReportModel(
          id: 'test_report_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Test Report',
          description: 'This is a test report',
          type: ReportType.analytics,
          data: {'key': 'value'},
          createdAt: DateTime.now(),
          status: ReportStatus.pending,
        );

        print('🔧 [ADMIN_COMPREHENSIVE] Creating test report...');
        await firestore.collection('reports').doc(testReport.id).set(testReport.toJson());

        // Test get reports
        print('🔧 [ADMIN_COMPREHENSIVE] Testing get reports...');
        final reports = await repository.getReports().first;
        expect(reports.any((r) => r['id'] == testReport.id), isTrue);

        // Test update report status
        print('🔧 [ADMIN_COMPREHENSIVE] Testing update report status...');
        await repository.updateReportStatus(testReport.id, ReportStatus.completed);

        // Verify the update
        final updatedReports = await repository.getReports().first;
        final updatedReport = updatedReports.firstWhere((r) => r['id'] == testReport.id);
        expect(updatedReport['status'], equals(ReportStatus.completed.name));

        print('🔧 [ADMIN_COMPREHENSIVE] ✅ Report management successful');
      });
    });

    group('System Health Integration', () {
      testWidgets('should check system health', (WidgetTester tester) async {
        print('🔧 [ADMIN_COMPREHENSIVE] Testing system health check...');

        // Test system health
        final health = await repository.getSystemHealth();
        
        expect(health, isA<Map<String, dynamic>>());
        expect(health['status'], isA<String>());
        expect(health['timestamp'], isA<String>());

        print('🔧 [ADMIN_COMPREHENSIVE] 🏥 System Health:');
        print('   - Status: ${health['status']}');
        print('   - Database: ${health['database'] ?? 'N/A'}');
        print('   - Storage: ${health['storage'] ?? 'N/A'}');
        print('   - Auth: ${health['auth'] ?? 'N/A'}');

        print('🔧 [ADMIN_COMPREHENSIVE] ✅ System health check successful');
      });
    });

    group('Error Handling Integration', () {
      testWidgets('should handle errors gracefully', (WidgetTester tester) async {
        print('🔧 [ADMIN_COMPREHENSIVE] Testing error handling...');

        // Test invalid user ID
        try {
          await repository.updateUser('invalid_id', {'name': 'Test'});
        } catch (e) {
          print('🔧 [ADMIN_COMPREHENSIVE] ✅ Expected error for invalid user ID: $e');
        }

        // Test invalid notification ID
        try {
          await repository.markNotificationAsRead('invalid_id');
        } catch (e) {
          print('🔧 [ADMIN_COMPREHENSIVE] ✅ Expected error for invalid notification ID: $e');
        }

        // Test invalid report ID
        try {
          await repository.updateReportStatus('invalid_id', ReportStatus.completed);
        } catch (e) {
          print('🔧 [ADMIN_COMPREHENSIVE] ✅ Expected error for invalid report ID: $e');
        }

        print('🔧 [ADMIN_COMPREHENSIVE] ✅ Error handling successful');
      });
    });
  });
}

Future<void> _cleanupTestData(String testAdminId) async {
  try {
    final firestore = FirebaseFirestore.instance;
    
    // Clean up users
    final users = await firestore.collection('users')
        .where('createdBy', isEqualTo: testAdminId)
        .get();
    
    // Clean up notifications
    final notifications = await firestore.collection('notifications')
        .where('createdBy', isEqualTo: testAdminId)
        .get();
    
    // Clean up reports
    final reports = await firestore.collection('reports')
        .where('createdBy', isEqualTo: testAdminId)
        .get();
    
    final batch = firestore.batch();
    
    for (var doc in users.docs) {
      batch.delete(doc.reference);
    }
    
    for (var doc in notifications.docs) {
      batch.delete(doc.reference);
    }
    
    for (var doc in reports.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
  } catch (e) {
    print('⚠️ [ADMIN_COMPREHENSIVE] Cleanup error: $e');
  }
}

Future<void> _createTestDataForAnalytics(String testAdminId) async {
  try {
    final firestore = FirebaseFirestore.instance;
    
    // Create test users
    for (int i = 0; i < 10; i++) {
      final userData = {
        'id': 'test_user_$i',
        'name': 'Test User $i',
        'email': 'test$i@example.com',
        'role': i % 3 == 0 ? UserRole.customer : i % 3 == 1 ? UserRole.tailor : UserRole.volunteer,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'createdBy': testAdminId,
      };
      
      await firestore.collection('users').doc('test_user_$i').set(userData);
    }
    
    // Create test pickup requests
    for (int i = 0; i < 5; i++) {
      final pickupData = {
        'id': 'test_pickup_$i',
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
        'createdBy': testAdminId,
      };
      
      await firestore.collection('pickup_requests').doc('test_pickup_$i').set(pickupData);
    }
    
    // Create test orders
    for (int i = 0; i < 3; i++) {
      final orderData = {
        'id': 'test_order_$i',
        'status': 'completed',
        'amount': 100.0 + (i * 50.0),
        'createdAt': DateTime.now().toIso8601String(),
        'createdBy': testAdminId,
      };
      
      await firestore.collection('orders').doc('test_order_$i').set(orderData);
    }
  } catch (e) {
    print('⚠️ [ADMIN_COMPREHENSIVE] Test data creation error: $e');
  }
} 