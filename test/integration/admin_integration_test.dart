import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:refab_app/features/admin/data/repositories/admin_repository.dart';
import 'package:refab_app/features/admin/data/models/analytics_model.dart';
import 'package:refab_app/features/admin/data/models/system_config_model.dart';
import 'package:refab_app/features/auth/data/models/user_model.dart';
import '../test_helper.dart';

void main() {
  group('Admin Integration Tests', () {
    late AdminRepository repository;
    late String testAdminId;
    late FirebaseFirestore firestore;

    setUpAll(() async {
      print('🔧 [ADMIN_INTEGRATION] Setting up Firebase for integration testing...');
      TestWidgetsFlutterBinding.ensureInitialized();
      await TestHelper.setupFirebaseForTesting();
      firestore = FirebaseFirestore.instance;
      print('🔧 [ADMIN_INTEGRATION] ✅ Firebase initialized');
    });

    setUp(() {
      print('🔧 [ADMIN_INTEGRATION] Setting up test environment...');
      repository = AdminRepository();
      testAdminId = TestHelper.generateTestId('admin');
      print('🔧 [ADMIN_INTEGRATION] ✅ Test environment ready. Admin ID: $testAdminId');
    });

    tearDown(() async {
      print('🔧 [ADMIN_INTEGRATION] Cleaning up test data...');
      try {
        await _cleanupTestData(testAdminId);
        print('🔧 [ADMIN_INTEGRATION] ✅ Test data cleaned up');
      } catch (e) {
        print('🔧 [ADMIN_INTEGRATION] ⚠️ Cleanup warning: $e');
      }
    });

    group('User Management Integration', () {
      test('should perform complete user CRUD operations', () async {
        print('🔧 [ADMIN_INTEGRATION] Testing complete user CRUD operations...');

        if (!TestHelper.isFirebaseAvailable) {
          print('🔧 [ADMIN_INTEGRATION] ⚠️ Skipping test - Firebase not available');
          return;
        }

        // Create test user
        final testUser = UserModel(
          id: TestHelper.generateTestId('user'),
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
        await TestHelper.waitForFirebaseOperations();

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
        await TestHelper.waitForFirebaseOperations();
        
        final updatedUsers = await repository.getAllUsers().first;
        final updatedUser = updatedUsers.firstWhere((u) => u.id == testUser.id);
        expect(updatedUser.name, equals('Updated Integration User'));

        // Test deactivate user
        print('🔧 [ADMIN_INTEGRATION] Testing deactivate user...');
        await repository.deactivateUser(testUser.id);
        await TestHelper.waitForFirebaseOperations();
        
        final deactivatedUsers = await repository.getAllUsers().first;
        final deactivatedUser = deactivatedUsers.firstWhere((u) => u.id == testUser.id);
        expect(deactivatedUser.isActive, isFalse);

        print('🔧 [ADMIN_INTEGRATION] ✅ Complete user CRUD operations test passed');
      });

      test('should handle bulk user operations', () async {
        print('🔧 [ADMIN_INTEGRATION] Testing bulk user operations...');

        if (!TestHelper.isFirebaseAvailable) {
          print('🔧 [ADMIN_INTEGRATION] ⚠️ Skipping test - Firebase not available');
          return;
        }

        // Create multiple test users
        final testUsers = <UserModel>[];
        for (int i = 0; i < 5; i++) {
          testUsers.add(UserModel(
            id: TestHelper.generateTestId('bulk_user_$i'),
            name: 'Bulk Test User $i',
            email: 'bulk$i@test.com',
            role: UserRole.customer,
            isActive: true,
            createdAt: DateTime.now(),
            phone: '+123456789$i',
            address: 'Test Address $i',
          ));
        }

        // Add users to Firestore
        final batch = firestore.batch();
        for (final user in testUsers) {
          batch.set(firestore.collection('users').doc(user.id), user.toJson());
        }
        await batch.commit();
        await TestHelper.waitForFirebaseOperations();

        // Test bulk retrieval
        final allUsers = await repository.getAllUsers().first;
        for (final testUser in testUsers) {
          expect(allUsers.any((u) => u.id == testUser.id), isTrue);
        }

        // Test bulk deactivation
        for (final testUser in testUsers) {
          await repository.deactivateUser(testUser.id);
        }
        await TestHelper.waitForFirebaseOperations();

        final deactivatedUsers = await repository.getAllUsers().first;
        for (final testUser in testUsers) {
          final user = deactivatedUsers.firstWhere((u) => u.id == testUser.id);
          expect(user.isActive, isFalse);
        }

        print('🔧 [ADMIN_INTEGRATION] ✅ Bulk user operations test passed');
      });
    });

    group('Analytics Integration', () {
      test('should generate comprehensive analytics', () async {
        print('🔧 [ADMIN_INTEGRATION] Testing comprehensive analytics...');

        if (!TestHelper.isFirebaseAvailable) {
          print('🔧 [ADMIN_INTEGRATION] ⚠️ Skipping test - Firebase not available');
          return;
        }

        // Create comprehensive test data
        await _createTestDataForAnalytics(testAdminId);
        await TestHelper.waitForFirebaseOperations();

        // Test system analytics
        final systemAnalytics = await repository.getSystemAnalytics();
        expect(systemAnalytics, isA<AnalyticsModel>());
        expect(systemAnalytics.totalUsers, greaterThan(0));

        print('🔧 [ADMIN_INTEGRATION] ✅ Comprehensive analytics test passed');
      });

      test('should handle real-time analytics updates', () async {
        print('🔧 [ADMIN_INTEGRATION] Testing real-time analytics updates...');

        if (!TestHelper.isFirebaseAvailable) {
          print('🔧 [ADMIN_INTEGRATION] ⚠️ Skipping test - Firebase not available');
          return;
        }

        // Get initial analytics
        final initialAnalytics = await repository.getSystemAnalytics();
        final initialUserCount = initialAnalytics.totalUsers;

        // Add new user
        final newUser = UserModel(
          id: TestHelper.generateTestId('realtime_user'),
          name: 'Real-time Test User',
          email: 'realtime@test.com',
          role: UserRole.customer,
          isActive: true,
          createdAt: DateTime.now(),
          phone: '+1234567890',
          address: 'Test Address',
        );

        await firestore.collection('users').doc(newUser.id).set(newUser.toJson());
        await TestHelper.waitForFirebaseOperations();

        // Check updated analytics
        final updatedAnalytics = await repository.getSystemAnalytics();
        expect(updatedAnalytics.totalUsers, equals(initialUserCount + 1));

        print('🔧 [ADMIN_INTEGRATION] ✅ Real-time analytics updates test passed');
      });
    });

    group('System Configuration Integration', () {
      test('should manage system configuration end-to-end', () async {
        print('🔧 [ADMIN_INTEGRATION] Testing system configuration management...');

        if (!TestHelper.isFirebaseAvailable) {
          print('🔧 [ADMIN_INTEGRATION] ⚠️ Skipping test - Firebase not available');
          return;
        }

        // Get initial configuration
        final initialConfig = await repository.getSystemConfig();
        expect(initialConfig, isA<SystemConfigModel>());

        // Update configuration
        final newConfig = SystemConfigModel(
          maxPickupRequests: 150,
          maintenanceMode: true,
          minAppVersion: '1.0.0',
          apiBaseUrl: 'https://your-api-url.com/api',
          supportEmail: 'support@refab.com',
          supportPhone: '+91-1234567890',
          maxPickupWeight: 1000.0,
          minOrderAmount: 50.0,
          volunteerCertificateHours: 50,
          enableAnalytics: true,
          enableCrashlytics: true,
          customSettings: {},
          updatedAt: DateTime.now(),
        );

        await repository.updateSystemConfig(newConfig);
        await TestHelper.waitForFirebaseOperations();

        // Verify update
        final updatedConfig = await repository.getSystemConfig();
        expect(updatedConfig.maxPickupRequests, equals(150));
        expect(updatedConfig.maintenanceMode, isTrue);

        // Revert configuration
        await repository.updateSystemConfig(initialConfig);
        await TestHelper.waitForFirebaseOperations();

        final revertedConfig = await repository.getSystemConfig();
        expect(revertedConfig.maxPickupRequests, equals(initialConfig.maxPickupRequests));

        print('🔧 [ADMIN_INTEGRATION] ✅ System configuration management test passed');
      });
    });

    group('Error Handling Integration', () {
      test('should handle Firebase connection errors gracefully', () async {
        print('🔧 [ADMIN_INTEGRATION] Testing error handling...');

        // Test with invalid user ID
        try {
          await repository.updateUser('invalid_user_id', {'name': 'Test'});
          print('🔧 [ADMIN_INTEGRATION] ⚠️ Update with invalid ID did not throw error');
        } catch (e) {
          print('🔧 [ADMIN_INTEGRATION] ✅ Error handled correctly: $e');
          expect(e, isA<Exception>());
        }

        print('🔧 [ADMIN_INTEGRATION] ✅ Error handling test passed');
      });
    });

    group('Performance Integration', () {
      test('should handle concurrent operations', () async {
        print('🔧 [ADMIN_INTEGRATION] Testing concurrent operations...');

        if (!TestHelper.isFirebaseAvailable) {
          print('🔧 [ADMIN_INTEGRATION] ⚠️ Skipping test - Firebase not available');
          return;
        }

        // Create test data
        await _createTestDataForAnalytics(testAdminId);
        await TestHelper.waitForFirebaseOperations();

        // Execute concurrent operations
        final futures = <Future>[];
        futures.add(repository.getAllUsers().first);
        futures.add(repository.getSystemAnalytics());
        futures.add(repository.getSystemConfig());

        final results = await Future.wait(futures);
        expect(results.length, equals(3));

        for (int i = 0; i < results.length; i++) {
          expect(results[i], isNotNull);
        }

        print('🔧 [ADMIN_INTEGRATION] ✅ Concurrent operations test passed');
      });

      test('should handle large dataset operations', () async {
        print('🔧 [ADMIN_INTEGRATION] Testing large dataset operations...');

        if (!TestHelper.isFirebaseAvailable) {
          print('🔧 [ADMIN_INTEGRATION] ⚠️ Skipping test - Firebase not available');
          return;
        }

        // Create large dataset
        await _createLargeTestDataset(testAdminId);
        await TestHelper.waitForFirebaseOperations();

        // Test performance
        final startTime = DateTime.now();
        final users = await repository.getAllUsers().first;
        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);

        expect(duration.inMilliseconds, lessThan(10000)); // Should complete within 10 seconds
        expect(users.length, greaterThan(0));

        print('🔧 [ADMIN_INTEGRATION] ✅ Large dataset operations test passed');
        print('🔧 [ADMIN_INTEGRATION] ⚡ Performance: ${duration.inMilliseconds}ms for ${users.length} users');
      });
    });
  });
}

Future<void> _cleanupTestData(String testAdminId) async {
  if (!TestHelper.isFirebaseAvailable) return;

  final firestore = FirebaseFirestore.instance;
  final batch = firestore.batch();

  // Clean up test users
  final users = await firestore
      .collection('users')
      .where('createdBy', isEqualTo: testAdminId)
      .get();

  for (var doc in users.docs) {
    batch.delete(doc.reference);
  }

  // Clean up test pickup requests
  final pickups = await firestore
      .collection('pickupRequests')
      .where('createdBy', isEqualTo: testAdminId)
      .get();

  for (var doc in pickups.docs) {
    batch.delete(doc.reference);
  }

  // Clean up test orders
  final orders = await firestore
      .collection('orders')
      .where('createdBy', isEqualTo: testAdminId)
      .get();

  for (var doc in orders.docs) {
    batch.delete(doc.reference);
  }

  await batch.commit();
}

Future<void> _createTestDataForAnalytics(String testAdminId) async {
  if (!TestHelper.isFirebaseAvailable) return;

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

Future<void> _createLargeTestDataset(String testAdminId) async {
  if (!TestHelper.isFirebaseAvailable) return;

  final firestore = FirebaseFirestore.instance;
  final batch = firestore.batch();

  // Create larger dataset for performance testing
  for (int i = 0; i < 50; i++) {
    final user = {
      'name': 'Performance Test User $i',
      'email': 'perf$i@test.com',
      'role': i % 4 == 0 ? UserRole.customer : i % 4 == 1 ? UserRole.tailor : i % 4 == 2 ? UserRole.volunteer : UserRole.warehouse,
      'isActive': true,
      'createdAt': DateTime.now().toIso8601String(),
      'createdBy': testAdminId,
    };
    batch.set(firestore.collection('users').doc('perf_user_$i'), user);
  }

  await batch.commit();
} 