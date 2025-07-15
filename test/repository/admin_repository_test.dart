import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:refab_app/features/admin/data/repositories/admin_repository.dart';
import 'package:refab_app/features/admin/data/models/dashboard_model.dart';

void main() {
  group('AdminRepository Tests', () {
    late AdminRepository repository;
    late String testRequestId;
    late String testAssignmentId;

    setUpAll(() async {
      print('🔥 [ADMIN_TEST] Setting up Firebase for testing...');
      TestWidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
      print('🔥 [ADMIN_TEST] ✅ Firebase initialized');
    });

    setUp(() {
      print('🔥 [ADMIN_TEST] Setting up test environment...');
      repository = AdminRepository();
      testRequestId = 'test_request_${DateTime.now().millisecondsSinceEpoch}';
      testAssignmentId = 'test_assignment_${DateTime.now().millisecondsSinceEpoch}';
      print('🔥 [ADMIN_TEST] ✅ Test environment ready');
    });

    group('Pickup Requests', () {
      test('should get all pickup requests', () async {
        print('🔥 [ADMIN_TEST] Testing get all pickup requests...');
        
        if (!Firebase.apps.isNotEmpty) {
          print('🔥 [ADMIN_TEST] ⚠️ Skipping test - Firebase not available');
          return;
        }

        // Create test pickup request
        final testRequest = {
          'customerName': 'Test Customer',
          'fabricType': 'Cotton',
          'pickupAddress': 'Test Address',
          'status': 'pending',
          'createdAt': DateTime.now().toIso8601String(),
        };

        await FirebaseFirestore.instance
            .collection('pickup_requests')
            .doc(testRequestId)
            .set(testRequest);

        final requests = await repository.getAllPickupRequests();
        expect(requests, isNotEmpty);
        expect(requests.any((r) => r['id'] == testRequestId), isTrue);
      });

      test('should update pickup request status', () async {
        print('🔥 [ADMIN_TEST] Testing update pickup request status...');
        
        if (!Firebase.apps.isNotEmpty) {
          print('🔥 [ADMIN_TEST] ⚠️ Skipping test - Firebase not available');
          return;
        }

        // Create test pickup request
        final testRequest = {
          'customerName': 'Test Customer',
          'fabricType': 'Cotton',
          'pickupAddress': 'Test Address',
          'status': 'pending',
          'createdAt': DateTime.now().toIso8601String(),
        };

        await FirebaseFirestore.instance
            .collection('pickup_requests')
            .doc(testRequestId)
            .set(testRequest);

        final success = await repository.updatePickupRequestStatus(testRequestId, 'completed');
        expect(success, isTrue);

        final updatedRequest = await FirebaseFirestore.instance
            .collection('pickup_requests')
            .doc(testRequestId)
            .get();

        expect(updatedRequest.data()?['status'], equals('completed'));
      });

      test('should search pickup requests', () async {
        print('🔥 [ADMIN_TEST] Testing search pickup requests...');
        
        if (!Firebase.apps.isNotEmpty) {
          print('🔥 [ADMIN_TEST] ⚠️ Skipping test - Firebase not available');
          return;
        }

        // Create test pickup request
        final testRequest = {
          'customerName': 'Test Customer',
          'fabricType': 'Cotton',
          'pickupAddress': 'Test Address',
          'status': 'pending',
          'createdAt': DateTime.now().toIso8601String(),
        };

        await FirebaseFirestore.instance
            .collection('pickup_requests')
            .doc(testRequestId)
            .set(testRequest);

        final results = await repository.searchPickupRequests('Test Customer');
        expect(results, isNotEmpty);
        expect(results.any((r) => r['id'] == testRequestId), isTrue);
      });
    });

    group('Assignments', () {
      test('should get all assignments', () async {
        print('🔥 [ADMIN_TEST] Testing get all assignments...');
        
        if (!Firebase.apps.isNotEmpty) {
          print('🔥 [ADMIN_TEST] ⚠️ Skipping test - Firebase not available');
          return;
        }

        // Create test assignment
        final testAssignment = {
          'type': 'logistics',
          'status': 'pending',
          'description': 'Test assignment',
          'createdAt': DateTime.now().toIso8601String(),
        };

        await FirebaseFirestore.instance
            .collection('assignments')
            .doc(testAssignmentId)
            .set(testAssignment);

        final assignments = await repository.getAllAssignments();
        expect(assignments, isNotEmpty);
        expect(assignments.any((a) => a['id'] == testAssignmentId), isTrue);
      });

      test('should update assignment status', () async {
        print('🔥 [ADMIN_TEST] Testing update assignment status...');
        
        if (!Firebase.apps.isNotEmpty) {
          print('🔥 [ADMIN_TEST] ⚠️ Skipping test - Firebase not available');
          return;
        }

        // Create test assignment
        final testAssignment = {
          'type': 'logistics',
          'status': 'pending',
          'description': 'Test assignment',
          'createdAt': DateTime.now().toIso8601String(),
        };

        await FirebaseFirestore.instance
            .collection('assignments')
            .doc(testAssignmentId)
            .set(testAssignment);

        final success = await repository.updateAssignmentStatus(testAssignmentId, 'completed');
        expect(success, isTrue);

        final updatedAssignment = await FirebaseFirestore.instance
            .collection('assignments')
            .doc(testAssignmentId)
            .get();

        expect(updatedAssignment.data()?['status'], equals('completed'));
      });

      test('should search assignments', () async {
        print('🔥 [ADMIN_TEST] Testing search assignments...');
        
        if (!Firebase.apps.isNotEmpty) {
          print('🔥 [ADMIN_TEST] ⚠️ Skipping test - Firebase not available');
          return;
        }

        // Create test assignment
        final testAssignment = {
          'type': 'logistics',
          'status': 'pending',
          'description': 'Test assignment',
          'createdAt': DateTime.now().toIso8601String(),
        };

        await FirebaseFirestore.instance
            .collection('assignments')
            .doc(testAssignmentId)
            .set(testAssignment);

        final results = await repository.searchAssignments('logistics');
        expect(results, isNotEmpty);
        expect(results.any((a) => a['id'] == testAssignmentId), isTrue);
      });
    });

    group('Dashboard Data', () {
      test('should get dashboard data', () async {
        print('🔥 [ADMIN_TEST] Testing get dashboard data...');
        
        if (!Firebase.apps.isNotEmpty) {
          print('🔥 [ADMIN_TEST] ⚠️ Skipping test - Firebase not available');
          return;
        }

        // Create test data
        final testRequest = {
          'customerName': 'Test Customer',
          'fabricType': 'Cotton',
          'pickupAddress': 'Test Address',
          'status': 'pending',
          'createdAt': DateTime.now().toIso8601String(),
        };

        final testAssignment = {
          'type': 'logistics',
          'status': 'pending',
          'description': 'Test assignment',
          'createdAt': DateTime.now().toIso8601String(),
        };

        await FirebaseFirestore.instance
            .collection('pickup_requests')
            .doc(testRequestId)
            .set(testRequest);

        await FirebaseFirestore.instance
            .collection('assignments')
            .doc(testAssignmentId)
            .set(testAssignment);

        final dashboardData = await repository.getDashboardData();
        expect(dashboardData, isA<DashboardModel>());
        expect(dashboardData.totalPickupRequests, greaterThanOrEqualTo(1));
        expect(dashboardData.totalAssignments, greaterThanOrEqualTo(1));
      });
    });

    tearDown(() async {
      print('🔥 [ADMIN_TEST] Cleaning up test data...');
      
      if (Firebase.apps.isNotEmpty) {
        // Clean up test data
        try {
          await FirebaseFirestore.instance
              .collection('pickup_requests')
              .doc(testRequestId)
              .delete();
        } catch (e) {
          print('🔥 [ADMIN_TEST] ⚠️ Error cleaning up pickup request: $e');
        }

        try {
          await FirebaseFirestore.instance
              .collection('assignments')
              .doc(testAssignmentId)
              .delete();
        } catch (e) {
          print('🔥 [ADMIN_TEST] ⚠️ Error cleaning up assignment: $e');
        }
      }
      
      print('🔥 [ADMIN_TEST] ✅ Test cleanup completed');
    });
  });
} 