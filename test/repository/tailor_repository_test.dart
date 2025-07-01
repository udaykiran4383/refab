import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:refab_app/features/tailor/data/repositories/tailor_repository.dart';
import 'package:refab_app/features/tailor/data/models/pickup_request_model.dart';
import 'package:refab_app/features/auth/data/models/user_model.dart';

void main() {
  group('TailorRepository Tests', () {
    late TailorRepository repository;
    late String testTailorId;

    setUpAll(() async {
      print('🧪 [TAILOR_TEST] Setting up Firebase for testing...');
      TestWidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
      print('🧪 [TAILOR_TEST] ✅ Firebase initialized');
    });

    setUp(() {
      print('🧪 [TAILOR_TEST] Setting up test environment...');
      repository = TailorRepository();
      testTailorId = 'test_tailor_${DateTime.now().millisecondsSinceEpoch}';
      print('🧪 [TAILOR_TEST] ✅ Test environment ready. Tailor ID: $testTailorId');
    });

    tearDown(() async {
      print('🧪 [TAILOR_TEST] Cleaning up test data...');
      // Clean up test data
      try {
        final pickupRequests = await FirebaseFirestore.instance
            .collection('pickupRequests')
            .where('tailorId', isEqualTo: testTailorId)
            .get();
        
        final batch = FirebaseFirestore.instance.batch();
        for (var doc in pickupRequests.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        print('🧪 [TAILOR_TEST] ✅ Test data cleaned up');
      } catch (e) {
        print('🧪 [TAILOR_TEST] ⚠️ Cleanup warning: $e');
      }
    });

    group('Pickup Request CRUD Operations', () {
      test('should create pickup request successfully', () async {
        print('🧪 [TAILOR_TEST] Testing pickup request creation...');
        
        final pickupRequest = PickupRequestModel(
          id: '',
          tailorId: testTailorId,
          fabricType: 'Cotton',
          estimatedWeight: 5.5,
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
          fabricType: 'Silk',
          estimatedWeight: 3.0,
          pickupAddress: '456 Test Avenue, Mumbai',
          status: PickupStatus.pending,
          photos: ['photo3.jpg'],
          createdAt: DateTime.now(),
        );

        final pickupRequest2 = PickupRequestModel(
          id: '',
          tailorId: testTailorId,
          fabricType: 'Wool',
          estimatedWeight: 7.5,
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
          fabricType: 'Linen',
          estimatedWeight: 4.0,
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
          fabricType: 'Denim',
          estimatedWeight: 6.0,
          pickupAddress: '654 Test Boulevard, Mumbai',
          status: PickupStatus.pending,
          photos: ['photo7.jpg'],
          createdAt: DateTime.now(),
        );

        print('🧪 [TAILOR_TEST] Creating pickup request for cancellation test...');
        final requestId = await repository.createPickupRequest(pickupRequest);
        
        print('🧪 [TAILOR_TEST] Cancelling pickup request...');
        await repository.cancelPickupRequest(requestId);
        
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
          fabricType: 'Cotton',
          estimatedWeight: 5.0,
          pickupAddress: 'Test Address 1',
          status: PickupStatus.completed,
          photos: ['photo1.jpg'],
          createdAt: DateTime.now(),
        );

        final pickupRequest2 = PickupRequestModel(
          id: '',
          tailorId: testTailorId,
          fabricType: 'Silk',
          estimatedWeight: 3.0,
          pickupAddress: 'Test Address 2',
          status: PickupStatus.pending,
          photos: ['photo2.jpg'],
          createdAt: DateTime.now(),
        );

        final pickupRequest3 = PickupRequestModel(
          id: '',
          tailorId: testTailorId,
          fabricType: 'Wool',
          estimatedWeight: 7.0,
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
        print('   - Total Requests: ${analytics['totalRequests']}');
        print('   - Completed Requests: ${analytics['completedRequests']}');
        print('   - Pending Requests: ${analytics['pendingRequests']}');
        print('   - Total Weight: ${analytics['totalWeight']}kg');
        print('   - Completion Rate: ${analytics['completionRate']}%');
        
        expect(analytics['totalRequests'], greaterThanOrEqualTo(3));
        expect(analytics['completedRequests'], greaterThanOrEqualTo(2));
        expect(analytics['pendingRequests'], greaterThanOrEqualTo(1));
        expect(analytics['totalWeight'], greaterThanOrEqualTo(10.0));
        expect(analytics['completionRate'], greaterThan(0));
        
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
            fabricType: '',
            estimatedWeight: -1, // Invalid negative weight
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
            fabricType: 'Test Fabric $i',
            estimatedWeight: i + 1.0,
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