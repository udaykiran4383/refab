import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:refab_app/features/logistics/data/repositories/logistics_repository.dart';
import 'package:refab_app/features/logistics/data/models/route_model.dart';
import 'package:refab_app/features/logistics/data/models/pickup_assignment_model.dart';
import 'package:refab_app/features/logistics/data/models/logistics_analytics_model.dart';

void main() {
  group('LogisticsRepository Tests', () {
    late LogisticsRepository repository;
    late String testLogisticsId;

    setUpAll(() async {
      print('🚚 [LOGISTICS_TEST] Setting up Firebase for testing...');
      TestWidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
      print('🚚 [LOGISTICS_TEST] ✅ Firebase initialized');
    });

    setUp(() {
      print('🚚 [LOGISTICS_TEST] Setting up test environment...');
      repository = LogisticsRepository();
      testLogisticsId = 'test_logistics_${DateTime.now().millisecondsSinceEpoch}';
      print('🚚 [LOGISTICS_TEST] ✅ Test environment ready. Logistics ID: $testLogisticsId');
    });

    tearDown(() async {
      print('🚚 [LOGISTICS_TEST] Cleaning up test data...');
      try {
        // Clean up test data
        final routes = await FirebaseFirestore.instance
            .collection('routes')
            .where('logisticsId', isEqualTo: testLogisticsId)
            .get();
        
        final assignments = await FirebaseFirestore.instance
            .collection('pickupAssignments')
            .where('logisticsId', isEqualTo: testLogisticsId)
            .get();
        
        final batch = FirebaseFirestore.instance.batch();
        for (var doc in routes.docs) {
          batch.delete(doc.reference);
        }
        for (var doc in assignments.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        print('🚚 [LOGISTICS_TEST] ✅ Test data cleaned up');
      } catch (e) {
        print('🚚 [LOGISTICS_TEST] ⚠️ Cleanup warning: $e');
      }
    });

    group('Route CRUD Operations', () {
      test('should create route successfully', () async {
        print('🚚 [LOGISTICS_TEST] Testing route creation...');
        
        final route = RouteModel(
          id: '',
          logisticsId: testLogisticsId,
          routeName: 'Test Route 1',
          startLocation: 'Warehouse A',
          endLocation: 'Tailor Shop B',
          waypoints: ['Point 1', 'Point 2', 'Point 3'],
          estimatedDistance: 25.5,
          estimatedDuration: Duration(hours: 2, minutes: 30),
          status: RouteStatus.active,
          assignedDriver: 'driver_1',
          createdAt: DateTime.now(),
        );

        print('🚚 [LOGISTICS_TEST] Creating route: ${route.routeName}');
        print('   - Distance: ${route.estimatedDistance}km');
        print('   - Duration: ${route.estimatedDuration.inHours}h ${route.estimatedDuration.inMinutes % 60}m');
        print('   - Waypoints: ${route.waypoints.length}');
        
        final routeId = await repository.createRoute(route);
        
        print('🚚 [LOGISTICS_TEST] ✅ Route created with ID: $routeId');
        expect(routeId, isNotEmpty);
        expect(routeId.length, greaterThan(0));
      });

      test('should get routes', () async {
        print('🚚 [LOGISTICS_TEST] Testing routes retrieval...');
        
        // Create test routes
        final route1 = RouteModel(
          id: '',
          logisticsId: testLogisticsId,
          routeName: 'Morning Route',
          startLocation: 'Warehouse A',
          endLocation: 'Tailor Shop C',
          waypoints: ['Point A', 'Point B'],
          estimatedDistance: 15.0,
          estimatedDuration: Duration(hours: 1, minutes: 30),
          status: RouteStatus.active,
          assignedDriver: 'driver_2',
          createdAt: DateTime.now(),
        );

        final route2 = RouteModel(
          id: '',
          logisticsId: testLogisticsId,
          routeName: 'Afternoon Route',
          startLocation: 'Warehouse B',
          endLocation: 'Tailor Shop D',
          waypoints: ['Point C', 'Point D', 'Point E'],
          estimatedDistance: 30.0,
          estimatedDuration: Duration(hours: 3),
          status: RouteStatus.completed,
          assignedDriver: 'driver_3',
          createdAt: DateTime.now(),
        );

        print('🚚 [LOGISTICS_TEST] Creating test routes...');
        await repository.createRoute(route1);
        await repository.createRoute(route2);

        print('🚚 [LOGISTICS_TEST] Fetching routes...');
        final routes = await repository.getRoutes(testLogisticsId).first;
        
        print('🚚 [LOGISTICS_TEST] ✅ Retrieved ${routes.length} routes');
        expect(routes.length, greaterThanOrEqualTo(2));
        
        final activeRoutes = routes.where((r) => r.status == RouteStatus.active).length;
        final completedRoutes = routes.where((r) => r.status == RouteStatus.completed).length;
        
        print('🚚 [LOGISTICS_TEST] 📊 Active: $activeRoutes, Completed: $completedRoutes');
        expect(activeRoutes, greaterThanOrEqualTo(1));
        expect(completedRoutes, greaterThanOrEqualTo(1));
      });

      test('should update route status', () async {
        print('🚚 [LOGISTICS_TEST] Testing route status update...');
        
        final route = RouteModel(
          id: '',
          logisticsId: testLogisticsId,
          routeName: 'Status Test Route',
          startLocation: 'Warehouse C',
          endLocation: 'Tailor Shop E',
          waypoints: ['Point F'],
          estimatedDistance: 20.0,
          estimatedDuration: Duration(hours: 2),
          status: RouteStatus.active,
          assignedDriver: 'driver_4',
          createdAt: DateTime.now(),
        );

        print('🚚 [LOGISTICS_TEST] Creating route for status update...');
        final routeId = await repository.createRoute(route);
        
        print('🚚 [LOGISTICS_TEST] Updating status to completed...');
        await repository.updateRouteStatus(routeId, RouteStatus.completed);
        
        final routes = await repository.getRoutes(testLogisticsId).first;
        final updatedRoute = routes.firstWhere((r) => r.id == routeId);
        
        print('🚚 [LOGISTICS_TEST] ✅ Route status updated successfully');
        print('   - New Status: ${updatedRoute.status}');
        expect(updatedRoute.status, equals(RouteStatus.completed));
      });

      test('should assign driver to route', () async {
        print('🚚 [LOGISTICS_TEST] Testing driver assignment...');
        
        final route = RouteModel(
          id: '',
          logisticsId: testLogisticsId,
          routeName: 'Driver Assignment Route',
          startLocation: 'Warehouse D',
          endLocation: 'Tailor Shop F',
          waypoints: ['Point G', 'Point H'],
          estimatedDistance: 18.0,
          estimatedDuration: Duration(hours: 1, minutes: 45),
          status: RouteStatus.pending,
          assignedDriver: '',
          createdAt: DateTime.now(),
        );

        print('🚚 [LOGISTICS_TEST] Creating unassigned route...');
        final routeId = await repository.createRoute(route);
        
        print('🚚 [LOGISTICS_TEST] Assigning driver_5 to route...');
        await repository.assignDriverToRoute(routeId, 'driver_5');
        
        final routes = await repository.getRoutes(testLogisticsId).first;
        final assignedRoute = routes.firstWhere((r) => r.id == routeId);
        
        print('🚚 [LOGISTICS_TEST] ✅ Driver assigned successfully');
        print('   - Assigned Driver: ${assignedRoute.assignedDriver}');
        expect(assignedRoute.assignedDriver, equals('driver_5'));
      });
    });

    group('Pickup Assignment CRUD Operations', () {
      test('should create pickup assignment successfully', () async {
        print('🚚 [LOGISTICS_TEST] Testing pickup assignment creation...');
        
        final assignment = PickupAssignmentModel(
          id: '',
          logisticsId: testLogisticsId,
          pickupRequestId: 'test_pickup_request_1',
          assignedDriver: 'driver_6',
          pickupLocation: '123 Test Street, Mumbai',
          pickupTime: DateTime.now().add(Duration(hours: 2)),
          estimatedWeight: 15.5,
          status: AssignmentStatus.pending,
          notes: 'Handle with care - fragile fabrics',
          createdAt: DateTime.now(),
        );

        print('🚚 [LOGISTICS_TEST] Creating pickup assignment...');
        print('   - Pickup Location: ${assignment.pickupLocation}');
        print('   - Estimated Weight: ${assignment.estimatedWeight}kg');
        print('   - Pickup Time: ${assignment.pickupTime}');
        
        final assignmentId = await repository.createPickupAssignment(assignment);
        
        print('🚚 [LOGISTICS_TEST] ✅ Pickup assignment created with ID: $assignmentId');
        expect(assignmentId, isNotEmpty);
        expect(assignmentId.length, greaterThan(0));
      });

      test('should get pickup assignments', () async {
        print('🚚 [LOGISTICS_TEST] Testing pickup assignments retrieval...');
        
        // Create test assignments
        final assignment1 = PickupAssignmentModel(
          id: '',
          logisticsId: testLogisticsId,
          pickupRequestId: 'test_pickup_request_2',
          assignedDriver: 'driver_7',
          pickupLocation: '456 Test Avenue, Mumbai',
          pickupTime: DateTime.now().add(Duration(hours: 1)),
          estimatedWeight: 8.0,
          status: AssignmentStatus.inProgress,
          notes: 'Morning pickup',
          createdAt: DateTime.now(),
        );

        final assignment2 = PickupAssignmentModel(
          id: '',
          logisticsId: testLogisticsId,
          pickupRequestId: 'test_pickup_request_3',
          assignedDriver: 'driver_8',
          pickupLocation: '789 Test Road, Mumbai',
          pickupTime: DateTime.now().add(Duration(hours: 3)),
          estimatedWeight: 22.0,
          status: AssignmentStatus.completed,
          notes: 'Afternoon pickup',
          createdAt: DateTime.now(),
        );

        print('🚚 [LOGISTICS_TEST] Creating test pickup assignments...');
        await repository.createPickupAssignment(assignment1);
        await repository.createPickupAssignment(assignment2);

        print('🚚 [LOGISTICS_TEST] Fetching pickup assignments...');
        final assignments = await repository.getPickupAssignments(testLogisticsId).first;
        
        print('🚚 [LOGISTICS_TEST] ✅ Retrieved ${assignments.length} pickup assignments');
        expect(assignments.length, greaterThanOrEqualTo(2));
        
        final pendingAssignments = assignments.where((a) => a.status == AssignmentStatus.pending).length;
        final inProgressAssignments = assignments.where((a) => a.status == AssignmentStatus.inProgress).length;
        final completedAssignments = assignments.where((a) => a.status == AssignmentStatus.completed).length;
        
        print('🚚 [LOGISTICS_TEST] 📊 Pending: $pendingAssignments, In Progress: $inProgressAssignments, Completed: $completedAssignments');
        expect(pendingAssignments, greaterThanOrEqualTo(1));
        expect(inProgressAssignments, greaterThanOrEqualTo(1));
        expect(completedAssignments, greaterThanOrEqualTo(1));
      });

      test('should update assignment status', () async {
        print('🚚 [LOGISTICS_TEST] Testing assignment status update...');
        
        final assignment = PickupAssignmentModel(
          id: '',
          logisticsId: testLogisticsId,
          pickupRequestId: 'test_pickup_request_4',
          assignedDriver: 'driver_9',
          pickupLocation: '321 Test Lane, Mumbai',
          pickupTime: DateTime.now().add(Duration(hours: 1)),
          estimatedWeight: 12.0,
          status: AssignmentStatus.pending,
          notes: 'Status update test',
          createdAt: DateTime.now(),
        );

        print('🚚 [LOGISTICS_TEST] Creating assignment for status update...');
        final assignmentId = await repository.createPickupAssignment(assignment);
        
        print('🚚 [LOGISTICS_TEST] Updating status to in progress...');
        await repository.updateAssignmentStatus(assignmentId, AssignmentStatus.inProgress);
        
        final assignments = await repository.getPickupAssignments(testLogisticsId).first;
        final updatedAssignment = assignments.firstWhere((a) => a.id == assignmentId);
        
        print('🚚 [LOGISTICS_TEST] ✅ Assignment status updated successfully');
        print('   - New Status: ${updatedAssignment.status}');
        expect(updatedAssignment.status, equals(AssignmentStatus.inProgress));
      });

      test('should reassign pickup to different driver', () async {
        print('🚚 [LOGISTICS_TEST] Testing pickup reassignment...');
        
        final assignment = PickupAssignmentModel(
          id: '',
          logisticsId: testLogisticsId,
          pickupRequestId: 'test_pickup_request_5',
          assignedDriver: 'driver_10',
          pickupLocation: '654 Test Boulevard, Mumbai',
          pickupTime: DateTime.now().add(Duration(hours: 2)),
          estimatedWeight: 18.0,
          status: AssignmentStatus.pending,
          notes: 'Reassignment test',
          createdAt: DateTime.now(),
        );

        print('🚚 [LOGISTICS_TEST] Creating assignment for reassignment...');
        final assignmentId = await repository.createPickupAssignment(assignment);
        
        print('🚚 [LOGISTICS_TEST] Reassigning to driver_11...');
        await repository.reassignPickup(assignmentId, 'driver_11');
        
        final assignments = await repository.getPickupAssignments(testLogisticsId).first;
        final reassignedAssignment = assignments.firstWhere((a) => a.id == assignmentId);
        
        print('🚚 [LOGISTICS_TEST] ✅ Pickup reassigned successfully');
        print('   - New Driver: ${reassignedAssignment.assignedDriver}');
        expect(reassignedAssignment.assignedDriver, equals('driver_11'));
      });
    });

    group('Route Optimization', () {
      test('should optimize routes', () async {
        print('🚚 [LOGISTICS_TEST] Testing route optimization...');
        
        print('🚚 [LOGISTICS_TEST] Optimizing routes for today...');
        final optimizedRoutes = await repository.optimizeRoutes(testLogisticsId);
        
        print('🚚 [LOGISTICS_TEST] 🧮 Route Optimization Results:');
        print('   - Optimized Routes: ${optimizedRoutes.length}');
        
        for (int i = 0; i < optimizedRoutes.length; i++) {
          final route = optimizedRoutes[i];
          print('   - Route ${i + 1}: ${route.routeName}');
          print('     Distance: ${route.estimatedDistance}km');
          print('     Duration: ${route.estimatedDuration.inHours}h ${route.estimatedDuration.inMinutes % 60}m');
          print('     Driver: ${route.assignedDriver}');
        }
        
        expect(optimizedRoutes, isA<List<RouteModel>>());
        print('🚚 [LOGISTICS_TEST] ✅ Route optimization completed successfully');
      });

      test('should calculate optimal pickup sequence', () async {
        print('🚚 [LOGISTICS_TEST] Testing pickup sequence optimization...');
        
        final pickupLocations = [
          'Location A - 10kg',
          'Location B - 15kg',
          'Location C - 8kg',
          'Location D - 20kg',
        ];

        print('🚚 [LOGISTICS_TEST] Calculating optimal pickup sequence...');
        final optimalSequence = await repository.calculateOptimalPickupSequence(
          testLogisticsId,
          pickupLocations,
        );
        
        print('🚚 [LOGISTICS_TEST] 📍 Optimal Pickup Sequence:');
        for (int i = 0; i < optimalSequence.length; i++) {
          print('   ${i + 1}. ${optimalSequence[i]}');
        }
        
        expect(optimalSequence, isA<List<String>>());
        expect(optimalSequence.length, equals(pickupLocations.length));
        print('🚚 [LOGISTICS_TEST] ✅ Pickup sequence optimization completed');
      });
    });

    group('Analytics Operations', () {
      test('should get logistics analytics', async () {
        print('🚚 [LOGISTICS_TEST] Testing logistics analytics...');
        
        // Create test data for analytics
        final route1 = RouteModel(
          id: '',
          logisticsId: testLogisticsId,
          routeName: 'Analytics Test Route 1',
          startLocation: 'Warehouse A',
          endLocation: 'Tailor Shop A',
          waypoints: ['Point 1'],
          estimatedDistance: 20.0,
          estimatedDuration: Duration(hours: 2),
          status: RouteStatus.completed,
          assignedDriver: 'driver_1',
          createdAt: DateTime.now(),
        );

        final route2 = RouteModel(
          id: '',
          logisticsId: testLogisticsId,
          routeName: 'Analytics Test Route 2',
          startLocation: 'Warehouse B',
          endLocation: 'Tailor Shop B',
          waypoints: ['Point 2', 'Point 3'],
          estimatedDistance: 30.0,
          estimatedDuration: Duration(hours: 3),
          status: RouteStatus.active,
          assignedDriver: 'driver_2',
          createdAt: DateTime.now(),
        );

        final assignment1 = PickupAssignmentModel(
          id: '',
          logisticsId: testLogisticsId,
          pickupRequestId: 'analytics_pickup_1',
          assignedDriver: 'driver_3',
          pickupLocation: 'Analytics Location 1',
          pickupTime: DateTime.now().add(Duration(hours: 1)),
          estimatedWeight: 15.0,
          status: AssignmentStatus.completed,
          notes: 'Analytics test',
          createdAt: DateTime.now(),
        );

        final assignment2 = PickupAssignmentModel(
          id: '',
          logisticsId: testLogisticsId,
          pickupRequestId: 'analytics_pickup_2',
          assignedDriver: 'driver_4',
          pickupLocation: 'Analytics Location 2',
          pickupTime: DateTime.now().add(Duration(hours: 2)),
          estimatedWeight: 25.0,
          status: AssignmentStatus.inProgress,
          notes: 'Analytics test',
          createdAt: DateTime.now(),
        );

        print('🚚 [LOGISTICS_TEST] Creating test data for analytics...');
        await repository.createRoute(route1);
        await repository.createRoute(route2);
        await repository.createPickupAssignment(assignment1);
        await repository.createPickupAssignment(assignment2);

        print('🚚 [LOGISTICS_TEST] Fetching logistics analytics...');
        final analytics = await repository.getLogisticsAnalytics(testLogisticsId);
        
        print('🚚 [LOGISTICS_TEST] 📊 Logistics Analytics:');
        print('   - Total Routes: ${analytics['totalRoutes']}');
        print('   - Active Routes: ${analytics['activeRoutes']}');
        print('   - Completed Routes: ${analytics['completedRoutes']}');
        print('   - Total Distance: ${analytics['totalDistance']}km');
        print('   - Total Pickup Assignments: ${analytics['totalPickupAssignments']}');
        print('   - Completed Pickups: ${analytics['completedPickups']}');
        print('   - Total Weight Picked Up: ${analytics['totalWeightPickedUp']}kg');
        print('   - Average Route Efficiency: ${analytics['averageRouteEfficiency']}%');
        
        expect(analytics['totalRoutes'], greaterThanOrEqualTo(2));
        expect(analytics['activeRoutes'], greaterThanOrEqualTo(1));
        expect(analytics['completedRoutes'], greaterThanOrEqualTo(1));
        expect(analytics['totalDistance'], greaterThanOrEqualTo(20.0));
        expect(analytics['totalPickupAssignments'], greaterThanOrEqualTo(2));
        expect(analytics['completedPickups'], greaterThanOrEqualTo(1));
        expect(analytics['totalWeightPickedUp'], greaterThanOrEqualTo(15.0));
        expect(analytics['averageRouteEfficiency'], greaterThan(0));
        
        print('🚚 [LOGISTICS_TEST] ✅ Logistics analytics retrieved successfully');
      });
    });

    group('Driver Management', () {
      test('should get driver assignments', () async {
        print('🚚 [LOGISTICS_TEST] Testing driver assignment retrieval...');
        
        print('🚚 [LOGISTICS_TEST] Fetching driver assignments...');
        final driverAssignments = await repository.getDriverAssignments(testLogisticsId);
        
        print('🚚 [LOGISTICS_TEST] 👨‍💼 Driver Assignments:');
        for (final assignment in driverAssignments) {
          print('   - Driver: ${assignment['driverId']}');
          print('     Routes: ${assignment['routes']}');
          print('     Pickups: ${assignment['pickups']}');
          print('     Total Distance: ${assignment['totalDistance']}km');
        }
        
        expect(driverAssignments, isA<List>());
        print('🚚 [LOGISTICS_TEST] ✅ Driver assignments retrieved successfully');
      });

      test('should get driver performance', () async {
        print('🚚 [LOGISTICS_TEST] Testing driver performance metrics...');
        
        print('🚚 [LOGISTICS_TEST] Fetching driver performance...');
        final performance = await repository.getDriverPerformance(testLogisticsId);
        
        print('🚚 [LOGISTICS_TEST] 📈 Driver Performance:');
        for (final driver in performance) {
          print('   - Driver: ${driver['driverId']}');
          print('     Routes Completed: ${driver['routesCompleted']}');
          print('     Pickups Completed: ${driver['pickupsCompleted']}');
          print('     Total Distance: ${driver['totalDistance']}km');
          print('     Efficiency Score: ${driver['efficiencyScore']}%');
        }
        
        expect(performance, isA<List>());
        print('🚚 [LOGISTICS_TEST] ✅ Driver performance retrieved successfully');
      });
    });

    group('Error Handling', () {
      test('should handle invalid route creation', () async {
        print('🚚 [LOGISTICS_TEST] Testing error handling for invalid route...');
        
        try {
          await repository.createRoute(RouteModel(
            id: '',
            logisticsId: '', // Invalid empty logistics ID
            routeName: '',
            startLocation: '',
            endLocation: '',
            waypoints: [],
            estimatedDistance: -1, // Invalid negative distance
            estimatedDuration: Duration.zero,
            status: RouteStatus.active,
            assignedDriver: '',
            createdAt: DateTime.now(),
          ));
          
          fail('Should have thrown an exception');
        } catch (e) {
          print('🚚 [LOGISTICS_TEST] ✅ Error handled correctly: $e');
          expect(e, isA<Exception>());
        }
      });

      test('should handle non-existent assignment operations', () async {
        print('🚚 [LOGISTICS_TEST] Testing error handling for non-existent assignments...');
        
        try {
          await repository.updateAssignmentStatus('non_existent_assignment_id', AssignmentStatus.completed);
          fail('Should have thrown an exception');
        } catch (e) {
          print('🚚 [LOGISTICS_TEST] ✅ Error handled correctly: $e');
          expect(e, isA<Exception>());
        }
      });
    });

    group('Performance Tests', () {
      test('should handle large route dataset', () async {
        print('🚚 [LOGISTICS_TEST] Testing performance with large route dataset...');
        
        print('🚚 [LOGISTICS_TEST] Fetching all routes (performance test)...');
        final startTime = DateTime.now();
        
        final routes = await repository.getRoutes(testLogisticsId).first;
        
        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);
        
        print('🚚 [LOGISTICS_TEST] ⚡ Performance Results:');
        print('   - Routes Retrieved: ${routes.length}');
        print('   - Duration: ${duration.inMilliseconds}ms');
        print('   - Average Time per Route: ${duration.inMilliseconds / routes.length}ms');
        
        expect(duration.inMilliseconds, lessThan(3000)); // Should complete within 3 seconds
        print('🚚 [LOGISTICS_TEST] ✅ Performance test passed');
      });

      test('should handle concurrent route operations', () async {
        print('🚚 [LOGISTICS_TEST] Testing concurrent route operations...');
        
        final futures = <Future>[];
        
        for (int i = 0; i < 3; i++) {
          final route = RouteModel(
            id: '',
            logisticsId: testLogisticsId,
            routeName: 'Concurrent Test Route $i',
            startLocation: 'Warehouse $i',
            endLocation: 'Tailor Shop $i',
            waypoints: ['Point $i'],
            estimatedDistance: 20.0 + i * 5,
            estimatedDuration: Duration(hours: 2 + i),
            status: RouteStatus.active,
            assignedDriver: 'driver_$i',
            createdAt: DateTime.now(),
          );
          
          futures.add(repository.createRoute(route));
        }

        print('🚚 [LOGISTICS_TEST] Executing 3 concurrent route creations...');
        final results = await Future.wait(futures);
        
        print('🚚 [LOGISTICS_TEST] ✅ All concurrent operations completed');
        expect(results.length, equals(3));
        
        for (int i = 0; i < results.length; i++) {
          expect(results[i], isNotEmpty);
          print('🚚 [LOGISTICS_TEST]   - Route $i created with ID: ${results[i]}');
        }
      });
    });
  });
} 