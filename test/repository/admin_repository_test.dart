import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:refab_app/features/admin/data/repositories/admin_repository.dart';
import 'package:refab_app/features/admin/data/models/analytics_model.dart';
import 'package:refab_app/features/admin/data/models/system_config_model.dart';
import 'package:refab_app/features/auth/data/models/user_model.dart';
import '../test_helper.dart';

void main() {
  group('AdminRepository Tests', () {
    late AdminRepository repository;
    late String testAdminId;

    setUpAll(() async {
      print('👨‍💼 [ADMIN_TEST] Setting up Firebase for testing...');
      TestWidgetsFlutterBinding.ensureInitialized();
      await TestHelper.setupFirebaseForTesting();
      print('👨‍💼 [ADMIN_TEST] ✅ Firebase initialized');
    });

    setUp(() {
      print('👨‍💼 [ADMIN_TEST] Setting up test environment...');
      repository = AdminRepository();
      testAdminId = TestHelper.generateTestId('admin');
      print('👨‍💼 [ADMIN_TEST] ✅ Test environment ready. Admin ID: $testAdminId');
    });

    tearDown(() async {
      print('👨‍💼 [ADMIN_TEST] Cleaning up test data...');
      await TestHelper.cleanupTestData('users', 'createdBy', testAdminId);
      print('👨‍💼 [ADMIN_TEST] ✅ Test data cleaned up');
    });

    group('User Management', () {
      test('should get all users', () async {
        print('👨‍💼 [ADMIN_TEST] Testing get all users...');
        
        if (!TestHelper.isFirebaseAvailable) {
          print('👨‍💼 [ADMIN_TEST] ⚠️ Skipping test - Firebase not available');
          return;
        }

        // Create test user
        final testUser = UserModel(
          id: TestHelper.generateTestId('user'),
          name: 'Test User',
          email: 'test@example.com',
          role: UserRole.customer,
          isActive: true,
          createdAt: DateTime.now(),
          phone: '+1234567890',
          address: 'Test Address',
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(testUser.id)
            .set(testUser.toJson());

        await TestHelper.waitForFirebaseOperations();

        final users = await repository.getAllUsers().first;
        expect(users, isNotEmpty);
        expect(users.any((u) => u.id == testUser.id), isTrue);
        
        TestHelper.logTestSuccess('Get All Users');
      });

      test('should get users by role', () async {
        print('👨‍💼 [ADMIN_TEST] Testing get users by role...');
        
        if (!TestHelper.isFirebaseAvailable) {
          print('👨‍💼 [ADMIN_TEST] ⚠️ Skipping test - Firebase not available');
          return;
        }

        // Create test customer
        final testCustomer = UserModel(
          id: TestHelper.generateTestId('customer'),
          name: 'Test Customer',
          email: 'customer@test.com',
          role: UserRole.customer,
          isActive: true,
          createdAt: DateTime.now(),
          phone: '+1234567890',
          address: 'Test Address',
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(testCustomer.id)
            .set(testCustomer.toJson());

        await TestHelper.waitForFirebaseOperations();

        final customers = await repository.getUsersByRole('customer').first;
        expect(customers.any((u) => u.id == testCustomer.id), isTrue);
        
        TestHelper.logTestSuccess('Get Users By Role');
      });

      test('should update user', () async {
        print('👨‍💼 [ADMIN_TEST] Testing user update...');
        
        if (!TestHelper.isFirebaseAvailable) {
          print('👨‍💼 [ADMIN_TEST] ⚠️ Skipping test - Firebase not available');
          return;
        }

        // Create test user
        final testUser = UserModel(
          id: TestHelper.generateTestId('user'),
          name: 'Original Name',
          email: 'update@test.com',
          role: UserRole.customer,
          isActive: true,
          createdAt: DateTime.now(),
          phone: '+1234567890',
          address: 'Test Address',
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(testUser.id)
            .set(testUser.toJson());

        await TestHelper.waitForFirebaseOperations();

        // Update user
        await repository.updateUser(testUser.id, {'name': 'Updated Name'});
        
        await TestHelper.waitForFirebaseOperations();

        final updatedUsers = await repository.getAllUsers().first;
        final updatedUser = updatedUsers.firstWhere((u) => u.id == testUser.id);
        expect(updatedUser.name, equals('Updated Name'));
        
        TestHelper.logTestSuccess('Update User');
      });

      test('should deactivate user', () async {
        print('👨‍💼 [ADMIN_TEST] Testing user deactivation...');
        
        if (!TestHelper.isFirebaseAvailable) {
          print('👨‍💼 [ADMIN_TEST] ⚠️ Skipping test - Firebase not available');
          return;
        }

        // Create test user
        final testUser = UserModel(
          id: TestHelper.generateTestId('user'),
          name: 'Active User',
          email: 'active@test.com',
          role: UserRole.customer,
          isActive: true,
          createdAt: DateTime.now(),
          phone: '+1234567890',
          address: 'Test Address',
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(testUser.id)
            .set(testUser.toJson());

        await TestHelper.waitForFirebaseOperations();

        // Deactivate user
        await repository.deactivateUser(testUser.id);
        
        await TestHelper.waitForFirebaseOperations();

        final deactivatedUsers = await repository.getAllUsers().first;
        final deactivatedUser = deactivatedUsers.firstWhere((u) => u.id == testUser.id);
        expect(deactivatedUser.isActive, isFalse);
        
        TestHelper.logTestSuccess('Deactivate User');
      });

      test('should delete user', () async {
        print('👨‍💼 [ADMIN_TEST] Testing user deletion...');
        
        if (!TestHelper.isFirebaseAvailable) {
          print('👨‍💼 [ADMIN_TEST] ⚠️ Skipping test - Firebase not available');
          return;
        }

        // Create a test user first
        final testUser = UserModel(
          id: TestHelper.generateTestId('user'),
          name: 'Test User for Deletion',
          email: 'testdelete@example.com',
          role: UserRole.customer,
          isActive: true,
          createdAt: DateTime.now(),
          phone: '+1234567890',
          address: 'Test Address',
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(testUser.id)
            .set(testUser.toJson());
        
        await TestHelper.waitForFirebaseOperations();

        // Delete user
        await repository.deleteUser(testUser.id);
        
        await TestHelper.waitForFirebaseOperations();

        // Verify deletion
        final deletedUser = await FirebaseFirestore.instance
            .collection('users')
            .doc(testUser.id)
            .get();
        
        expect(deletedUser.exists, isFalse);
        TestHelper.logTestSuccess('Delete User');
      });
    });

    group('Analytics', () {
      test('should get system analytics', () async {
        print('👨‍💼 [ADMIN_TEST] Testing system analytics...');
        
        if (!TestHelper.isFirebaseAvailable) {
          print('👨‍💼 [ADMIN_TEST] ⚠️ Skipping test - Firebase not available');
          return;
        }

        // Create test data for analytics
        await _createTestDataForAnalytics(testAdminId);
        
        await TestHelper.waitForFirebaseOperations();

        final analytics = await repository.getSystemAnalytics().first;
        expect(analytics, isA<AnalyticsModel>());
        expect(analytics.totalUsers, greaterThan(0));
        
        TestHelper.logTestSuccess('System Analytics');
      });

      test('should get user analytics', () async {
        print('👨‍💼 [ADMIN_TEST] Testing user analytics...');
        
        if (!TestHelper.isFirebaseAvailable) {
          print('👨‍💼 [ADMIN_TEST] ⚠️ Skipping test - Firebase not available');
          return;
        }

        // Create test user
        final testUser = UserModel(
          id: TestHelper.generateTestId('user'),
          name: 'Analytics User',
          email: 'analytics@test.com',
          role: UserRole.customer,
          isActive: true,
          createdAt: DateTime.now(),
          phone: '+1234567890',
          address: 'Test Address',
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(testUser.id)
            .set(testUser.toJson());

        await TestHelper.waitForFirebaseOperations();

        final analytics = await repository.getUserAnalytics(testUser.id).first;
        expect(analytics, isA<AnalyticsModel>());
        
        TestHelper.logTestSuccess('User Analytics');
      });
    });

    group('System Configuration', () {
      test('should get system configuration', () async {
        print('👨‍💼 [ADMIN_TEST] Testing system configuration...');
        
        if (!TestHelper.isFirebaseAvailable) {
          print('👨‍💼 [ADMIN_TEST] ⚠️ Skipping test - Firebase not available');
          return;
        }

        final config = await repository.getSystemConfiguration().first;
        expect(config, isA<SystemConfigModel>());
        
        TestHelper.logTestSuccess('System Configuration');
      });

      test('should update system configuration', () async {
        print('👨‍💼 [ADMIN_TEST] Testing system configuration update...');
        
        if (!TestHelper.isFirebaseAvailable) {
          print('👨‍💼 [ADMIN_TEST] ⚠️ Skipping test - Firebase not available');
          return;
        }

        final newConfig = SystemConfigModel(
          maxPickupRequests: 100,
          pickupTimeWindow: Duration(hours: 2),
          notificationEnabled: true,
          maintenanceMode: false,
        );

        await repository.updateSystemConfiguration(newConfig);
        
        await TestHelper.waitForFirebaseOperations();

        final updatedConfig = await repository.getSystemConfiguration().first;
        expect(updatedConfig.maxPickupRequests, equals(100));
        
        TestHelper.logTestSuccess('Update System Configuration');
      });
    });
  });
}

Future<void> _createTestDataForAnalytics(String testAdminId) async {
  if (!TestHelper.isFirebaseAvailable) return;

  final firestore = FirebaseFirestore.instance;
  final batch = firestore.batch();

  // Create test users
  for (int i = 0; i < 5; i++) {
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
  for (int i = 0; i < 10; i++) {
    final pickup = {
      'customerId': 'test_user_${i % 5}',
      'status': i % 4 == 0 ? 'pending' : i % 4 == 1 ? 'assigned' : i % 4 == 2 ? 'completed' : 'cancelled',
      'createdAt': DateTime.now().toIso8601String(),
      'createdBy': testAdminId,
    };
    batch.set(firestore.collection('pickupRequests').doc('test_pickup_$i'), pickup);
  }

  await batch.commit();
} 