import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/route_model.dart';
import '../models/pickup_assignment_model.dart';
import '../models/logistics_analytics_model.dart';

class LogisticsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Route Management
  Future<String> createRoute(RouteModel route) async {
    try {
      final docRef = await _firestore.collection('routes').add(route.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create route: $e');
    }
  }

  Stream<List<RouteModel>> getRoutes({String? status, String? logisticsId}) {
    Query query = _firestore.collection('routes');
    
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }
    
    if (logisticsId != null) {
      query = query.where('logisticsId', isEqualTo: logisticsId);
    }
    
    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RouteModel.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }

  Future<RouteModel?> getRoute(String routeId) async {
    try {
      final doc = await _firestore.collection('routes').doc(routeId).get();
      if (doc.exists) {
        return RouteModel.fromJson({
          ...doc.data()!,
          'id': doc.id,
        });
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get route: $e');
    }
  }

  Future<void> updateRoute(String routeId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('routes').doc(routeId).update({
        ...updates,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update route: $e');
    }
  }

  Future<void> updateRouteStatus(String routeId, RouteStatus status) async {
    try {
      await _firestore.collection('routes').doc(routeId).update({
        'status': status.toString().split('.').last,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update route status: $e');
    }
  }

  // Pickup Assignments
  Future<String> createPickupAssignment(PickupAssignmentModel assignment) async {
    try {
      final docRef = await _firestore.collection('pickupAssignments').add(assignment.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create pickup assignment: $e');
    }
  }

  Stream<List<PickupAssignmentModel>> getPickupAssignments({String? status, String? logisticsId}) {
    Query query = _firestore.collection('pickupAssignments');
    
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }
    
    if (logisticsId != null) {
      query = query.where('logisticsId', isEqualTo: logisticsId);
    }
    
    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PickupAssignmentModel.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }

  Future<void> updatePickupAssignment(String assignmentId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('pickupAssignments').doc(assignmentId).update({
        ...updates,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update pickup assignment: $e');
    }
  }

  Future<void> completePickup(String assignmentId, Map<String, dynamic> completionData) async {
    try {
      await _firestore.collection('pickupAssignments').doc(assignmentId).update({
        'status': 'completed',
        'completionData': completionData,
        'completedAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to complete pickup: $e');
    }
  }

  // Available Pickups
  Stream<List<Map<String, dynamic>>> getAvailablePickups(String area) {
    return _firestore
        .collection('pickupRequests')
        .where('status', whereIn: ['pending', 'scheduled'])
        .orderBy('createdAt', ascending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .where((doc) {
                final address = doc.data()['pickupAddress'] ?? '';
                return address.toLowerCase().contains(area.toLowerCase());
              })
              .map((doc) => {
                    ...doc.data(),
                    'id': doc.id,
                  })
              .toList();
        });
  }

  // Analytics
  Future<LogisticsAnalyticsModel> getLogisticsAnalytics(String logisticsId) async {
    try {
      final routes = await _firestore
          .collection('routes')
          .where('logisticsId', isEqualTo: logisticsId)
          .get();
      
      final pickupAssignments = await _firestore
          .collection('pickupAssignments')
          .where('logisticsId', isEqualTo: logisticsId)
          .get();

      final totalRoutes = routes.docs.length;
      final completedRoutes = routes.docs
          .where((doc) => doc.data()['status'] == 'completed')
          .length;
      final totalPickups = pickupAssignments.docs.length;
      final completedPickups = pickupAssignments.docs
          .where((doc) => doc.data()['status'] == 'completed')
          .length;
      final totalDistance = routes.docs
          .where((doc) => doc.data()['status'] == 'completed')
          .fold<double>(0, (sum, doc) => sum + (doc.data()['totalDistance'] ?? 0));

      // Weekly performance
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));

      final thisWeekPickups = pickupAssignments.docs
          .where((doc) {
            final createdAt = DateTime.parse(doc.data()['createdAt']);
            return createdAt.isAfter(weekStart) && createdAt.isBefore(weekEnd);
          })
          .length;

      final lastWeekPickups = pickupAssignments.docs
          .where((doc) {
            final createdAt = DateTime.parse(doc.data()['createdAt']);
            final lastWeekStart = weekStart.subtract(const Duration(days: 7));
            final lastWeekEnd = weekStart.subtract(const Duration(days: 1));
            return createdAt.isAfter(lastWeekStart) && createdAt.isBefore(lastWeekEnd);
          })
          .length;

      return LogisticsAnalyticsModel(
        totalRoutes: totalRoutes,
        completedRoutes: completedRoutes,
        totalPickups: totalPickups,
        completedPickups: completedPickups,
        totalDistance: totalDistance,
        thisWeekPickups: thisWeekPickups,
        lastWeekPickups: lastWeekPickups,
        routeCompletionRate: totalRoutes > 0 ? (completedRoutes / totalRoutes) * 100 : 0,
        pickupCompletionRate: totalPickups > 0 ? (completedPickups / totalPickups) * 100 : 0,
        weeklyGrowthRate: lastWeekPickups > 0 
            ? ((thisWeekPickups - lastWeekPickups) / lastWeekPickups) * 100 
            : 0,
      );
    } catch (e) {
      throw Exception('Failed to get logistics analytics: $e');
    }
  }

  // Route Optimization
  Future<List<Map<String, dynamic>>> optimizeRoute(List<String> pickupIds) async {
    try {
      // Get pickup details
      final pickupDocs = await Future.wait(
        pickupIds.map((id) => _firestore.collection('pickupRequests').doc(id).get())
      );

      final pickups = pickupDocs
          .where((doc) => doc.exists)
          .map((doc) => doc.data()!)
          .toList();

      // Simple optimization: sort by distance from current location
      // In a real app, you'd use a proper routing algorithm
      pickups.sort((a, b) {
        final aAddress = a['pickupAddress'] ?? '';
        final bAddress = b['pickupAddress'] ?? '';
        return aAddress.compareTo(bAddress);
      });

      return pickups;
    } catch (e) {
      throw Exception('Failed to optimize route: $e');
    }
  }

  // Real-time Location Updates
  Future<void> updateLocation(String logisticsId, double latitude, double longitude) async {
    try {
      await _firestore.collection('logisticsLocations').doc(logisticsId).set({
        'logisticsId': logisticsId,
        'latitude': latitude,
        'longitude': longitude,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update location: $e');
    }
  }

  Stream<Map<String, dynamic>?> getLogisticsLocation(String logisticsId) {
    return _firestore
        .collection('logisticsLocations')
        .doc(logisticsId)
        .snapshots()
        .map((doc) => doc.exists ? doc.data() : null);
  }

  // Notifications
  Future<void> sendPickupNotification(String pickupId, String message) async {
    try {
      await _firestore.collection('notifications').add({
        'pickupId': pickupId,
        'message': message,
        'type': 'pickup_update',
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to send pickup notification: $e');
    }
  }
} 