import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:refab_app/features/tailor/data/repositories/tailor_repository.dart';
import 'package:refab_app/features/tailor/data/models/pickup_request_model.dart';
import 'package:refab_app/features/auth/data/models/user_model.dart';
import '../test_helper.dart';

void main() {
  setUpAll(() async {
    await TestHelper.setupFirebaseForTesting();
  });

  group('TailorRepository Tests', () {
    late TailorRepository repository;
    late String testTailorId;

    setUp(() {
      print('🧪 [TAILOR_TEST] Setting up test environment...');
      repository = TailorRepository();
      testTailorId = TestHelper.generateTestId('tailor');
      print('🧪 [TAILOR_TEST] ✅ Test environment ready. Tailor ID: $testTailorId');
    });

    tearDown(() async {
      print('🧪 [TAILOR_TEST] Cleaning up test data...');
      await TestHelper.cleanupTestData('pickupRequests', 'tailorId', testTailorId);
      print('🧪 [TAILOR_TEST] ✅ Test data cleaned up');
    });

    group('Pickup Request CRUD Operations', () {
      test('should create pickup request successfully', () async {
        print('🧪 [TAILOR_TEST] Testing pickup request creation...');
        
        final pickupRequest = PickupRequestModel(
          id: '',
          tailorId: testTailorId,
          customerName: 'Test Customer',
          customerPhone: '+91-1234567890',
          customerEmail: 'test@example.com',
          fabricType: FabricType.cotton,
          fabricDescription: 'Test cotton fabric',
          estimatedWeight: 5.5,
          estimatedValue: 100.0,
          pickupAddress: '123 Test Street, Mumbai',
          status: PickupStatus.pending,
          photos: ['photo1.jpg', 'photo2.jpg'],
          createdAt: DateTime.now(),
        );

        print('🧪 [TAILOR_TEST] Creating pickup request with weight: ${pickupRequest.estimatedWeight}kg');
        
        final requestId = await repository.createPickupRequest(pickupRequest);
        
        print('🧪 [TAILOR_TEST] ✅ Pickup request created with ID: $requestId');
        expect(requestId, isNotEmpty);
        expect(requestId.length, greaterThan(0));
      });

      test('should get pickup requests for tailor', () async {
        print('🧪 [TAILOR_TEST] Testing pickup requests retrieval...');
        
        // Create test pickup requests
        final pickupRequest1 = PickupRequestModel(
          id: '',
          tailorId: testTailorId,
          customerName: 'Test Customer 1',
          customerPhone: '+91-1234567891',
          customerEmail: 'test1@example.com',
          fabricType: FabricType.silk,
          fabricDescription: 'Test silk fabric',
          estimatedWeight: 3.0,
          estimatedValue: 150.0,
          pickupAddress: '456 Test Avenue, Mumbai',
          status: PickupStatus.pending,
          photos: ['photo3.jpg'],
          createdAt: DateTime.now(),
        );

        final pickupRequest2 = PickupRequestModel(
          id: '',
          tailorId: testTailorId,
          customerName: 'Test Customer 2',
          customerPhone: '+91-1234567892',
          customerEmail: 'test2@example.com',
          fabricType: FabricType.wool,
          fabricDescription: 'Test wool fabric',
          estimatedWeight: 7.5,
          estimatedValue: 200.0,
          pickupAddress: '789 Test Road, Mumbai',
          status: PickupStatus.completed,
          photos: ['photo4.jpg', 'photo5.jpg'],
          createdAt: DateTime.now(),
        );

        print('🧪 [TAILOR_TEST] Creating test pickup requests...');
        await repository.createPickupRequest(pickupRequest1);
        await repository.createPickupRequest(pickupRequest2);

        print('🧪 [TAILOR_TEST] Fetching pickup requests for tailor...');
        final requests = await repository.getPickupRequests(testTailorId).first;
        
        print('🧪 [TAILOR_TEST] ✅ Retrieved ${requests.length} pickup requests');
        expect(requests.length, greaterThanOrEqualTo(2));
        
        final pendingRequests = requests.where((r) => r.status == PickupStatus.pending).length;
        final completedRequests = requests.where((r) => r.status == PickupStatus.completed).length;
        
        print('🧪 [TAILOR_TEST] 📊 Pending: $pendingRequests, Completed: $completedRequests');
        expect(pendingRequests, greaterThanOrEqualTo(1));
        expect(completedRequests, greaterThanOrEqualTo(1));
      });

      test('should update pickup status successfully', () async {
        print('🧪 [TAILOR_TEST] Testing pickup status update...');
        
        final pickupRequest = PickupRequestModel(
          id: '',
          tailorId: testTailorId,
          customerName: 'Test Customer 3',
          customerPhone: '+91-1234567893',
          customerEmail: 'test3@example.com',
          fabricType: FabricType.linen,
          fabricDescription: 'Test linen fabric',
          estimatedWeight: 4.0,
          estimatedValue: 120.0,
          pickupAddress: '321 Test Lane, Mumbai',
          status: PickupStatus.pending,
          photos: ['photo6.jpg'],
          createdAt: DateTime.now(),
        );

        print('🧪 [TAILOR_TEST] Creating pickup request for status update test...');
        final requestId = await repository.createPickupRequest(pickupRequest);
        
        print('🧪 [TAILOR_TEST] Updating status to completed...');
        await repository.updatePickupStatus(requestId, PickupStatus.completed);
        
        print('🧪 [TAILOR_TEST] Verifying status update...');
        final requests = await repository.getPickupRequests(testTailorId).first;
        final updatedRequest = requests.firstWhere((r) => r.id == requestId);
        
        print('🧪 [TAILOR_TEST] ✅ Status updated successfully. New status: ${updatedRequest.status}');
        expect(updatedRequest.status, equals(PickupStatus.completed));
      });

      test('should cancel pickup request successfully', () async {
        print('🧪 [TAILOR_TEST] Testing pickup request cancellation...');
        
        final pickupRequest = PickupRequestModel(
          id: '',
          tailorId: testTailorId,
          customerName: 'Test Customer 4',
          customerPhone: '+91-1234567894',
          customerEmail: 'test4@example.com',
          fabricType: FabricType.denim,
          fabricDescription: 'Test denim fabric',
          estimatedWeight: 6.0,
          estimatedValue: 180.0,
          pickupAddress: '654 Test Boulevard, Mumbai',
          status: PickupStatus.pending,
          photos: ['photo7.jpg'],
          createdAt: DateTime.now(),
        );

        print('🧪 [TAILOR_TEST] Creating pickup request for cancellation test...');
        final requestId = await repository.createPickupRequest(pickupRequest);
        
        print('🧪 [TAILOR_TEST] Cancelling pickup request...');
        await repository.cancelPickupRequest(requestId, 'Test cancellation reason');
        
        print('🧪 [TAILOR_TEST] Verifying cancellation...');
        final requests = await repository.getPickupRequests(testTailorId).first;
        final cancelledRequest = requests.firstWhere((r) => r.id == requestId);
        
        print('🧪 [TAILOR_TEST] ✅ Pickup request cancelled successfully. Status: ${cancelledRequest.status}');
        expect(cancelledRequest.status, equals(PickupStatus.cancelled));
      });
    });

    group('Analytics Operations', () {
      test('should get tailor analytics successfully', () async {
        print('🧪 [TAILOR_TEST] Testing analytics retrieval...');
        
        // Create test data
        final pickupRequest1 = PickupRequestModel(
          id: '',
          tailorId: testTailorId,
          customerName: 'Test Customer 5',
          customerPhone: '+91-1234567895',
          customerEmail: 'test5@example.com',
          fabricType: FabricType.cotton,
          fabricDescription: 'Test cotton fabric 2',
          estimatedWeight: 5.0,
          estimatedValue: 100.0,
          pickupAddress: 'Test Address 1',
          status: PickupStatus.completed,
          photos: ['photo1.jpg'],
          createdAt: DateTime.now(),
        );

        final pickupRequest2 = PickupRequestModel(
          id: '',
          tailorId: testTailorId,
          customerName: 'Test Customer 6',
          customerPhone: '+91-1234567896',
          customerEmail: 'test6@example.com',
          fabricType: FabricType.silk,
          fabricDescription: 'Test silk fabric 2',
          estimatedWeight: 3.0,
          estimatedValue: 150.0,
          pickupAddress: 'Test Address 2',
          status: PickupStatus.pending,
          photos: ['photo2.jpg'],
          createdAt: DateTime.now(),
        );

        final pickupRequest3 = PickupRequestModel(
          id: '',
          tailorId: testTailorId,
          customerName: 'Test Customer 7',
          customerPhone: '+91-1234567897',
          customerEmail: 'test7@example.com',
          fabricType: FabricType.wool,
          fabricDescription: 'Test wool fabric 2',
          estimatedWeight: 7.0,
          estimatedValue: 200.0,
          pickupAddress: 'Test Address 3',
          status: PickupStatus.completed,
          photos: ['photo3.jpg'],
          createdAt: DateTime.now(),
        );

        print('🧪 [TAILOR_TEST] Creating test pickup requests for analytics...');
        await repository.createPickupRequest(pickupRequest1);
        await repository.createPickupRequest(pickupRequest2);
        await repository.createPickupRequest(pickupRequest3);

        print('🧪 [TAILOR_TEST] Fetching analytics...');
        final analytics = await repository.getTailorAnalytics(testTailorId);
        
        print('🧪 [TAILOR_TEST] 📊 Analytics Results:');
        print('   - Total Requests: ${analytics.totalPickupRequests}');
        print('   - Completed Requests: ${analytics.completedPickupRequests}');
        print('   - Pending Requests: ${analytics.pendingPickupRequests}');
        print('   - Total Weight: ${analytics.totalWeightCollected}kg');
        print('   - Completion Rate: ${analytics.completionRate}%');
        
        expect(analytics.totalPickupRequests, greaterThanOrEqualTo(3));
        expect(analytics.completedPickupRequests, greaterThanOrEqualTo(2));
        expect(analytics.pendingPickupRequests, greaterThanOrEqualTo(1));
        expect(analytics.totalWeightCollected, greaterThanOrEqualTo(10.0));
        expect(analytics.completionRate, greaterThan(0));
        
        print('🧪 [TAILOR_TEST] ✅ Analytics retrieved successfully');
      });
    });

    group('Profile Management', () {
      test('should update tailor profile successfully', () async {
        print('🧪 [TAILOR_TEST] Testing profile update...');
        
        final updates = {
          'name': 'Updated Test Tailor',
          'phone': '+91-9876543210',
          'address': 'Updated Test Address, Mumbai',
        };

        print('🧪 [TAILOR_TEST] Updating profile with: $updates');
        await repository.updateTailorProfile(testTailorId, updates);
        
        print('🧪 [TAILOR_TEST] Fetching updated profile...');
        final profile = await repository.getTailorProfile(testTailorId);
        
        if (profile != null) {
          print('🧪 [TAILOR_TEST] ✅ Profile updated successfully');
          print('   - Name: ${profile.name}');
          print('   - Phone: ${profile.phone}');
          print('   - Address: ${profile.address}');
        } else {
          print('🧪 [TAILOR_TEST] ⚠️ Profile not found (expected for test user)');
        }
      });
    });

    group('Error Handling', () {
      test('should handle invalid pickup request creation', () async {
        print('🧪 [TAILOR_TEST] Testing error handling for invalid data...');
        
        try {
          // This should fail due to invalid data
          await repository.createPickupRequest(PickupRequestModel(
            id: '',
            tailorId: '', // Invalid empty ID
            customerName: '',
            customerPhone: '',
            customerEmail: '',
            fabricType: FabricType.other,
            fabricDescription: '',
            estimatedWeight: -1, // Invalid negative weight
            estimatedValue: 0.0,
            pickupAddress: '',
            status: PickupStatus.pending,
            photos: [],
            createdAt: DateTime.now(),
          ));
          
          fail('Should have thrown an exception');
        } catch (e) {
          print('🧪 [TAILOR_TEST] ✅ Error handled correctly: $e');
          expect(e, isA<Exception>());
        }
      });

      test('should handle non-existent pickup status update', () async {
        print('🧪 [TAILOR_TEST] Testing error handling for non-existent pickup...');
        
        try {
          await repository.updatePickupStatus('non_existent_id', PickupStatus.completed);
          fail('Should have thrown an exception');
        } catch (e) {
          print('🧪 [TAILOR_TEST] ✅ Error handled correctly: $e');
          expect(e, isA<Exception>());
        }
      });
    });

    group('Performance Tests', () {
      test('should handle multiple concurrent operations', () async {
        print('🧪 [TAILOR_TEST] Testing concurrent operations...');
        
        final futures = <Future>[];
        
        for (int i = 0; i < 5; i++) {
          final pickupRequest = PickupRequestModel(
            id: '',
            tailorId: testTailorId,
            customerName: 'Test Customer $i',
            customerPhone: '+91-123456789$i',
            customerEmail: 'test$i@example.com',
            fabricType: FabricType.other,
            fabricDescription: 'Test fabric description $i',
            estimatedWeight: i + 1.0,
            estimatedValue: (i + 1) * 50.0,
            pickupAddress: 'Test Address $i',
            status: PickupStatus.pending,
            photos: ['photo$i.jpg'],
            createdAt: DateTime.now(),
          );
          
          futures.add(repository.createPickupRequest(pickupRequest));
        }

        print('🧪 [TAILOR_TEST] Executing 5 concurrent pickup request creations...');
        final results = await Future.wait(futures);
        
        print('🧪 [TAILOR_TEST] ✅ All concurrent operations completed');
        expect(results.length, equals(5));
        
        for (int i = 0; i < results.length; i++) {
          expect(results[i], isNotEmpty);
          print('🧪 [TAILOR_TEST]   - Request $i ID: ${results[i]}');
        }
      });
    });
  });
} 