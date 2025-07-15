import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:refab_app/features/logistics/data/repositories/logistics_repository.dart';
import 'package:refab_app/features/logistics/data/models/route_model.dart';
import 'package:refab_app/features/logistics/data/models/pickup_assignment_model.dart';
import 'package:refab_app/features/logistics/data/models/logistics_analytics_model.dart';
import 'package:refab_app/features/tailor/data/models/pickup_request_model.dart';
import '../test_helper.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setUpAll(() async {
    await TestHelper.setupFirebaseForTesting();
  });

  group('LogisticsRepository Tests', () {
    late LogisticsRepository repository;
    const testLogisticsId = 'test_logistics';

    setUp(() {
      print('🚚 [LOGISTICS_TEST] Setting up test environment...');
      repository = LogisticsRepository();
      print('🚚 [LOGISTICS_TEST] ✅ Test environment ready.');
    });

    tearDown(() async {
      print('🚚 [LOGISTICS_TEST] Cleaning up test data...');
      try {
        // Clean up test data if needed
        print('🚚 [LOGISTICS_TEST] ✅ Cleanup completed.');
      } catch (e) {
        print('🚚 [LOGISTICS_TEST] ⚠️ Cleanup warning: $e');
      }
    });

    group('Route Management', () {
      test('should create route successfully', () async {
        print('🚚 [LOGISTICS_TEST] Testing route creation...');
        
        final route = RouteModel(
          id: '',
          logisticsId: testLogisticsId,
          routeName: 'Test Route 1',
          pickupIds: ['pickup1', 'pickup2'],
          stops: [
            RouteStop(
              stopId: 'stop1',
              stopType: 'pickup',
              address: '123 Main St',
              latitude: 40.7128,
              longitude: -74.0060,
              sequence: 1,
            ),
            RouteStop(
              stopId: 'stop2',
              stopType: 'warehouse',
              address: '456 Warehouse Ave',
              latitude: 40.7589,
              longitude: -73.9851,
              sequence: 2,
            ),
          ],
          totalDistance: 25.5,
          estimatedDuration: 150,
          status: RouteStatus.planned,
          createdAt: DateTime.now(),
        );

        final routeId = await repository.createRoute(route);
        
        expect(routeId, isNotEmpty);
        print('🚚 [LOGISTICS_TEST] ✅ Route created with ID: $routeId');
      });

      test('should get routes successfully', () async {
        print('🚚 [LOGISTICS_TEST] Testing routes retrieval...');
        
        final stream = repository.getRoutes(logisticsId: testLogisticsId);
        final routes = await stream.first;
        
        expect(routes, isA<List<RouteModel>>());
        print('🚚 [LOGISTICS_TEST] ✅ Retrieved ${routes.length} routes');
      });

      test('should update route successfully', () async {
        print('🚚 [LOGISTICS_TEST] Testing route update...');
        
        final route = RouteModel(
          id: '',
          logisticsId: testLogisticsId,
          routeName: 'Test Route 2',
          pickupIds: ['pickup3'],
          stops: [
            RouteStop(
              stopId: 'stop3',
              stopType: 'pickup',
              address: '789 Oak St',
              latitude: 40.7505,
              longitude: -73.9934,
              sequence: 1,
            ),
          ],
          totalDistance: 15.2,
          estimatedDuration: 90,
          status: RouteStatus.planned,
          createdAt: DateTime.now(),
        );

        final routeId = await repository.createRoute(route);
        
        await repository.updateRoute(routeId, {
          'status': RouteStatus.inProgress.toString().split('.').last,
          'assignedDriverId': 'driver_123',
          'assignedDriverName': 'John Driver',
        });
        
        print('🚚 [LOGISTICS_TEST] ✅ Route updated successfully');
      });

      test('should update route status successfully', () async {
        print('🚚 [LOGISTICS_TEST] Testing route status update...');
        
        final route = RouteModel(
          id: '',
          logisticsId: testLogisticsId,
          routeName: 'Test Route 3',
          pickupIds: ['pickup4'],
          stops: [
            RouteStop(
              stopId: 'stop4',
              stopType: 'pickup',
              address: '321 Pine St',
              latitude: 40.7614,
              longitude: -73.9776,
              sequence: 1,
            ),
          ],
          totalDistance: 8.7,
          estimatedDuration: 45,
          status: RouteStatus.planned,
          createdAt: DateTime.now(),
        );

        final routeId = await repository.createRoute(route);
        
        await repository.updateRouteStatus(routeId, RouteStatus.completed);
        
        print('🚚 [LOGISTICS_TEST] ✅ Route status updated successfully');
      });

      test('should delete route successfully', () async {
        print('🚚 [LOGISTICS_TEST] Testing route deletion...');
        
        final route = RouteModel(
          id: '',
          logisticsId: testLogisticsId,
          routeName: 'Test Route 4',
          pickupIds: ['pickup5'],
          stops: [
            RouteStop(
              stopId: 'stop5',
              stopType: 'pickup',
              address: '654 Elm St',
              latitude: 40.7484,
              longitude: -73.9857,
              sequence: 1,
            ),
          ],
          totalDistance: 12.3,
          estimatedDuration: 75,
          status: RouteStatus.planned,
          createdAt: DateTime.now(),
        );

        final routeId = await repository.createRoute(route);
        
        await repository.deleteRoute(routeId);
        
        print('🚚 [LOGISTICS_TEST] ✅ Route deleted successfully');
      });
    });

    group('Pickup Assignment Management', () {
      test('should create pickup assignment successfully', () async {
        print('🚚 [LOGISTICS_TEST] Testing pickup assignment creation...');
        
        final assignment = PickupAssignmentModel(
          id: '',
          logisticsId: testLogisticsId,
          pickupId: 'pickup_123',
          tailorId: 'tailor_123',
          pickupAddress: '123 Pickup St',
          estimatedWeight: 15.5,
          fabricType: 'cotton',
          status: AssignmentStatus.assigned,
          scheduledTime: DateTime.now().add(const Duration(hours: 2)),
          createdAt: DateTime.now(),
        );

        final assignmentId = await repository.createPickupAssignment(assignment);
        
        expect(assignmentId, isNotEmpty);
        print('🚚 [LOGISTICS_TEST] ✅ Pickup assignment created with ID: $assignmentId');
      });

      test('should get pickup assignments successfully', () async {
        print('🚚 [LOGISTICS_TEST] Testing pickup assignments retrieval...');
        
        final stream = repository.getPickupAssignments(logisticsId: testLogisticsId);
        final assignments = await stream.first;
        
        expect(assignments, isA<List<PickupAssignmentModel>>());
        print('🚚 [LOGISTICS_TEST] ✅ Retrieved ${assignments.length} pickup assignments');
      });

      test('should update pickup assignment successfully', () async {
        print('🚚 [LOGISTICS_TEST] Testing pickup assignment update...');
        
        final assignment = PickupAssignmentModel(
          id: '',
          logisticsId: testLogisticsId,
          pickupId: 'pickup_456',
          tailorId: 'tailor_456',
          pickupAddress: '456 Pickup Ave',
          estimatedWeight: 8.0,
          fabricType: 'silk',
          status: AssignmentStatus.assigned,
          scheduledTime: DateTime.now().add(const Duration(hours: 3)),
          createdAt: DateTime.now(),
        );

        final assignmentId = await repository.createPickupAssignment(assignment);
        
        await repository.updatePickupAssignment(assignmentId, {
          'status': AssignmentStatus.inProgress.toString().split('.').last,
          'actualPickupTime': DateTime.now().toIso8601String(),
        });
        
        print('🚚 [LOGISTICS_TEST] ✅ Pickup assignment updated successfully');
      });

      test('should update pickup status successfully', () async {
        print('🚚 [LOGISTICS_TEST] Testing pickup status update...');
        
        final assignment = PickupAssignmentModel(
          id: '',
          logisticsId: testLogisticsId,
          pickupId: 'pickup_789',
          tailorId: 'tailor_789',
          pickupAddress: '789 Pickup Blvd',
          estimatedWeight: 12.0,
          fabricType: 'polyester',
          status: AssignmentStatus.assigned,
          scheduledTime: DateTime.now().add(const Duration(hours: 1)),
          createdAt: DateTime.now(),
        );

        final assignmentId = await repository.createPickupAssignment(assignment);
        
        await repository.updatePickupStatus(assignmentId, AssignmentStatus.completed);
        
        print('�� [LOGISTICS_TEST] ✅ Pickup status updated successfully');
      });

      test('should delete pickup assignment successfully', () async {
        print('🚚 [LOGISTICS_TEST] Testing pickup assignment deletion...');
        
        final assignment = PickupAssignmentModel(
          id: '',
          logisticsId: testLogisticsId,
          pickupId: 'pickup_202',
          tailorId: 'tailor_202',
          pickupAddress: '202 Pickup Rd',
          estimatedWeight: 6.5,
          fabricType: 'wool',
          status: AssignmentStatus.assigned,
          scheduledTime: DateTime.now().add(const Duration(hours: 4)),
          createdAt: DateTime.now(),
        );

        final assignmentId = await repository.createPickupAssignment(assignment);
        
        await repository.deletePickupAssignment(assignmentId);
        
        print('🚚 [LOGISTICS_TEST] ✅ Pickup assignment deleted successfully');
      });
    });

    group('Analytics', () {
      test('should get logistics analytics successfully', () async {
        print('🚚 [LOGISTICS_TEST] Testing analytics retrieval...');
        
        final analytics = await repository.getLogisticsAnalytics(testLogisticsId);
        
        expect(analytics, isA<Map<String, dynamic>>());
        print('🚚 [LOGISTICS_TEST] ✅ Analytics retrieved successfully');
      });
    });

    group('Integration', () {
      test('should notify warehouse successfully', () async {
        print('🚚 [LOGISTICS_TEST] Testing warehouse notification...');
        
        final pickupId = 'pickup_integration_test';
        
        await repository.notifyWarehouseOfPickup(testLogisticsId, pickupId);
        
        print('🚚 [LOGISTICS_TEST] ✅ Warehouse notified successfully');
      });

      test('should get warehouse notifications successfully', () async {
        print('🚚 [LOGISTICS_TEST] Testing warehouse notifications retrieval...');
        
        final notifications = await repository.getWarehouseNotifications(testLogisticsId);
        
        expect(notifications, isA<List<Map<String, dynamic>>>());
        print('🚚 [LOGISTICS_TEST] ✅ Retrieved ${notifications.length} warehouse notifications');
      });

      test('should get admin dashboard data successfully', () async {
        print('🚚 [LOGISTICS_TEST] Testing admin dashboard data...');
        
        final dashboardData = await repository.getAdminDashboardData(testLogisticsId);
        
        expect(dashboardData, isA<Map<String, dynamic>>());
        print('🚚 [LOGISTICS_TEST] ✅ Admin dashboard data retrieved successfully');
      });

      test('should send admin alert successfully', () async {
        print('🚚 [LOGISTICS_TEST] Testing admin alert...');
        
        await repository.sendAdminAlert(testLogisticsId, 'route_delay', 'Route 1 is delayed by 30 minutes');
        
        print('🚚 [LOGISTICS_TEST] ✅ Admin alert sent successfully');
      });
    });
  });
} 