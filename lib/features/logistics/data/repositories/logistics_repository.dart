import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/route_model.dart';
import '../models/pickup_assignment_model.dart';
import '../models/logistics_assignment_model.dart';
import '../models/logistics_analytics_model.dart';
import '../../../tailor/data/models/pickup_request_model.dart';

class LogisticsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== LOGISTICS ASSIGNMENTS ====================

  // Get all logistics assignments (for admin dashboard)
  Future<List<LogisticsAssignmentModel>> getAllLogisticsAssignments() async {
    try {
      print('🚚 [LOGISTICS_REPO] Getting all logistics assignments for admin dashboard');
      final snapshot = await _firestore
          .collection('logisticsAssignments')
          .orderBy('created_at', descending: true)
          .get();
      
      final assignments = snapshot.docs.map((doc) {
        try {
          return LogisticsAssignmentModel.fromJson({
            ...(doc.data() as Map<String, dynamic>),
            'id': doc.id,
          });
        } catch (e) {
          print('🚚 [LOGISTICS_REPO] ❌ Error parsing assignment ${doc.id}: $e');
          return null;
        }
      }).where((assignment) => assignment != null).cast<LogisticsAssignmentModel>().toList();
      
      print('🚚 [LOGISTICS_REPO] ✅ Found ${assignments.length} logistics assignments');
      return assignments;
    } catch (e) {
      print('🚚 [LOGISTICS_REPO] ❌ Error getting all logistics assignments: $e');
      throw Exception('Failed to get all logistics assignments: $e');
    }
  }

  Future<String> createLogisticsAssignment(LogisticsAssignmentModel assignment) async {
    try {
      print('🚚 [LOGISTICS_REPO] Creating logistics assignment: ${assignment.id}');
      final docRef = await _firestore.collection('logisticsAssignments').add(assignment.toJson());
      print('🚚 [LOGISTICS_REPO] ✅ Assignment created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('🚚 [LOGISTICS_REPO] ❌ Error creating assignment: $e');
      throw Exception('Failed to create logistics assignment: $e');
    }
  }

  Stream<List<LogisticsAssignmentModel>> getLogisticsAssignments(String logisticsId) {
    print('🚚 [LOGISTICS_REPO] Getting assignments for logistics: $logisticsId');
    return _firestore
        .collection('logisticsAssignments')
        .where('logistics_id', isEqualTo: logisticsId)
        .snapshots()
        .map((snapshot) {
          print('🚚 [LOGISTICS_REPO] Found ${snapshot.docs.length} assignments');
          final assignments = snapshot.docs.map((doc) {
            try {
              return LogisticsAssignmentModel.fromJson({
                ...(doc.data() as Map<String, dynamic>),
                'id': doc.id,
              });
            } catch (e) {
              print('🚚 [LOGISTICS_REPO] ❌ Error parsing assignment ${doc.id}: $e');
              return null;
            }
          }).where((assignment) => assignment != null).cast<LogisticsAssignmentModel>().toList();
          
          // Sort in memory to avoid composite index requirement
          assignments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return assignments;
        });
  }

  Future<LogisticsAssignmentModel?> getLogisticsAssignment(String assignmentId) async {
    try {
      final doc = await _firestore.collection('logisticsAssignments').doc(assignmentId).get();
      if (doc.exists) {
        return LogisticsAssignmentModel.fromJson({
          ...(doc.data()! as Map<String, dynamic>),
          'id': doc.id,
        });
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get logistics assignment: $e');
    }
  }

  Future<void> updateLogisticsAssignmentStatus(String assignmentId, LogisticsAssignmentStatus status) async {
    try {
      print('🚚 [LOGISTICS_REPO] Updating assignment status: $assignmentId to ${status.toString().split('.').last}');
      
      final updates = {
        'status': status.toString().split('.').last,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Add specific date fields based on status
      switch (status) {
        case LogisticsAssignmentStatus.assigned:
          updates['scheduled_time'] = DateTime.now().toIso8601String();
          break;
        case LogisticsAssignmentStatus.inProgress:
          updates['start_time'] = DateTime.now().toIso8601String();
          break;
        case LogisticsAssignmentStatus.completed:
          updates['completed_time'] = DateTime.now().toIso8601String();
          break;
        case LogisticsAssignmentStatus.cancelled:
          // No specific time field for cancelled
          break;
        case LogisticsAssignmentStatus.pending:
          // No specific time field for pending
          break;
      }

      await _firestore.collection('logisticsAssignments').doc(assignmentId).update(updates);
      print('🚚 [LOGISTICS_REPO] ✅ Assignment status updated successfully');
    } catch (e) {
      print('🚚 [LOGISTICS_REPO] ❌ Error updating assignment status: $e');
      throw Exception('Failed to update assignment status: $e');
    }
  }

  Future<void> assignWarehouse(String assignmentId, String warehouseId, String warehouseName, WarehouseType warehouseType, String warehouseAddress) async {
    try {
      print('🚚 [LOGISTICS_REPO] Assigning warehouse: $warehouseId to assignment: $assignmentId');
      await _firestore.collection('logisticsAssignments').doc(assignmentId).update({
        'assigned_warehouse_id': warehouseId,
        'assigned_warehouse_name': warehouseName,
        'warehouse_type': warehouseType.toString().split('.').last,
        'warehouse_address': warehouseAddress,
        'updated_at': DateTime.now().toIso8601String(),
      });
      print('🚚 [LOGISTICS_REPO] ✅ Warehouse assigned successfully');
    } catch (e) {
      print('🚚 [LOGISTICS_REPO] ❌ Error assigning warehouse: $e');
      throw Exception('Failed to assign warehouse: $e');
    }
  }

  Future<void> updateAssignmentData(String assignmentId, Map<String, dynamic> data, String dataType) async {
    try {
      final fieldName = '${dataType}_data';
      await _firestore.collection('logisticsAssignments').doc(assignmentId).update({
        fieldName: data,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update assignment data: $e');
    }
  }

  // ==================== WAREHOUSE INTEGRATION ====================

  Future<List<Map<String, dynamic>>> getAvailableWarehouses() async {
    try {
      final snapshot = await _firestore
          .collection('warehouses')
          .where('is_active', isEqualTo: true)
          .get();
      
      return snapshot.docs.map((doc) => {
        ...(doc.data() as Map<String, dynamic>),
        'id': doc.id,
      }).toList();
    } catch (e) {
      throw Exception('Failed to get available warehouses: $e');
    }
  }

  Future<Map<String, dynamic>?> getWarehouseDetails(String warehouseId) async {
    try {
      final doc = await _firestore.collection('warehouses').doc(warehouseId).get();
      if (doc.exists) {
        return {
          ...(doc.data()! as Map<String, dynamic>),
          'id': doc.id,
        };
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get warehouse details: $e');
    }
  }

  Future<void> notifyWarehouseOfAssignment(String warehouseId, String assignmentId, Map<String, dynamic> assignmentData) async {
    try {
      await _firestore.collection('warehouseNotifications').add({
        'warehouse_id': warehouseId,
        'assignment_id': assignmentId,
        'type': 'new_assignment',
        'data': assignmentData,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to notify warehouse: $e');
    }
  }

  // ==================== LEGACY METHODS (for backward compatibility) ====================

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
                  ...(doc.data() as Map<String, dynamic>),
                  'id': doc.id,
                }))
            .toList());
  }

  Future<RouteModel?> getRoute(String routeId) async {
    try {
      final doc = await _firestore.collection('routes').doc(routeId).get();
      if (doc.exists) {
        return RouteModel.fromJson({
          ...(doc.data()! as Map<String, dynamic>),
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

  Future<void> deleteRoute(String routeId) async {
    try {
      await _firestore.collection('routes').doc(routeId).delete();
    } catch (e) {
      throw Exception('Failed to delete route: $e');
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
                  ...(doc.data() as Map<String, dynamic>),
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

  Future<void> updatePickupStatus(String assignmentId, AssignmentStatus status) async {
    try {
      await _firestore.collection('pickupAssignments').doc(assignmentId).update({
        'status': status.toString().split('.').last,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update pickup status: $e');
    }
  }

  Future<void> updatePickupRequestStatus(String pickupId, String status) async {
    try {
      print('🚚 [LOGISTICS_REPO] Updating pickup request status: $pickupId to $status');
      
      final updates = {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Add specific date fields based on status
      switch (status) {
        case 'scheduled':
          updates['scheduled_date'] = DateTime.now().toIso8601String();
          break;
        case 'picked_up':
          updates['pickup_date'] = DateTime.now().toIso8601String();
          break;
        case 'delivered':
          updates['delivery_date'] = DateTime.now().toIso8601String();
          break;
        case 'completed':
          updates['completed_date'] = DateTime.now().toIso8601String();
          break;
        default:
          break;
      }

      await _firestore.collection('pickupRequests').doc(pickupId).update(updates);
      print('🚚 [LOGISTICS_REPO] ✅ Pickup request status updated successfully');
    } catch (e) {
      print('🚚 [LOGISTICS_REPO] ❌ Error updating pickup request status: $e');
      throw Exception('Failed to update pickup request status: $e');
    }
  }

  Future<void> deletePickupAssignment(String assignmentId) async {
    try {
      await _firestore.collection('pickupAssignments').doc(assignmentId).delete();
    } catch (e) {
      throw Exception('Failed to delete pickup assignment: $e');
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
    print('🚚 [LOGISTICS_REPO] Getting available pickups for area: $area');
    return _firestore
        .collection('pickupRequests')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
          print('🚚 [LOGISTICS_REPO] Found ${snapshot.docs.length} pickup requests total');
          final allRequests = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            print('🚚 [LOGISTICS_REPO] Checking request ${doc.id}:');
            print('🚚 [LOGISTICS_REPO]   - Status: ${data['status']}');
            print('🚚 [LOGISTICS_REPO]   - Address: ${data['pickup_address']}');
            print('🚚 [LOGISTICS_REPO]   - Customer: ${data['customer_name']}');
            print('🚚 [LOGISTICS_REPO]   - Tailor ID: ${data['tailor_id']}');
            return {'doc': doc, 'data': data};
          }).toList();
          
          // More flexible area matching - check for common variations
          final availableRequests = allRequests.where((item) {
            final data = item['data'] as Map<String, dynamic>;
            final doc = item['doc'] as DocumentSnapshot;
            final status = data['status'] ?? '';
            final address = (data['pickup_address'] ?? '').toLowerCase();
            final isAvailable = status == 'pending' || status == 'scheduled';
            
            // More flexible area matching
            final matchesArea = address.contains(area.toLowerCase()) || 
                               address.contains('mumbai') ||
                               address.contains('maharashtra') ||
                               area.toLowerCase() == 'all'; // Show all if area is 'all'
            
            print('🚚 [LOGISTICS_REPO] Request ${doc.id}: status=$status, address=$address, isAvailable=$isAvailable, matchesArea=$matchesArea');
            return isAvailable && matchesArea;
          }).toList();
          
          print('🚚 [LOGISTICS_REPO] Found ${availableRequests.length} available pickups for area $area');
          
          return availableRequests.map((item) {
            try {
              final data = item['data'] as Map<String, dynamic>;
              final doc = item['doc'] as DocumentSnapshot;
              final result = {
                ...data,
                'id': doc.id,
              };
              print('🚚 [LOGISTICS_REPO] ✅ Processing available pickup: ${doc.id}');
              return result;
            } catch (e) {
              final doc = item['doc'] as DocumentSnapshot;
              print('🚚 [LOGISTICS_REPO] ❌ Error processing pickup ${doc.id}: $e');
              return {
                'id': doc.id,
                'error': 'Failed to parse data',
                'status': 'error',
              };
            }
          }).toList();
        });
  }

  // Analytics
  Future<Map<String, dynamic>> getLogisticsAnalytics(String logisticsId) async {
    try {
      final routes = await _firestore
          .collection('routes')
          .where('logisticsId', isEqualTo: logisticsId)
          .get();
      
      final logisticsAssignments = await _firestore
          .collection('logisticsAssignments')
          .where('logistics_id', isEqualTo: logisticsId)
          .get();

      final totalRoutes = routes.docs.length;
      final completedRoutes = routes.docs
          .where((doc) => doc.data()['status'] == 'completed')
          .length;
      
      // Separate pickup and delivery assignments
      final pickupAssignments = logisticsAssignments.docs
          .where((doc) => doc.data()['type'] == 'pickup')
          .toList();
      final deliveryAssignments = logisticsAssignments.docs
          .where((doc) => doc.data()['type'] == 'delivery')
          .toList();
      
      final totalPickups = pickupAssignments.length;
      final completedPickups = pickupAssignments
          .where((doc) => doc.data()['status'] == 'completed')
          .length;
      final totalDeliveries = deliveryAssignments.length;
      final completedDeliveries = deliveryAssignments
          .where((doc) => doc.data()['status'] == 'completed')
          .length;
      
      final totalDistance = routes.docs
          .where((doc) => doc.data()['status'] == 'completed')
          .fold<double>(0, (sum, doc) => sum + (doc.data()['totalDistance'] ?? 0));

      // Weekly performance
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));

      final thisWeekPickups = pickupAssignments
          .where((doc) {
            final createdAt = DateTime.parse(doc.data()['created_at']);
            return createdAt.isAfter(weekStart) && createdAt.isBefore(weekEnd);
          })
          .length;

      final lastWeekPickups = pickupAssignments
          .where((doc) {
            final createdAt = DateTime.parse(doc.data()['created_at']);
            final lastWeekStart = weekStart.subtract(const Duration(days: 7));
            final lastWeekEnd = weekStart.subtract(const Duration(days: 1));
            return createdAt.isAfter(lastWeekStart) && createdAt.isBefore(lastWeekEnd);
          })
          .length;

      return {
        'totalRoutes': totalRoutes,
        'completedRoutes': completedRoutes,
        'totalPickups': totalPickups,
        'completedPickups': completedPickups,
        'totalDeliveries': totalDeliveries,
        'completedDeliveries': completedDeliveries,
        'totalDistance': totalDistance,
        'thisWeekPickups': thisWeekPickups,
        'lastWeekPickups': lastWeekPickups,
        'routeCompletionRate': totalRoutes > 0 ? (completedRoutes / totalRoutes) * 100 : 0,
        'pickupCompletionRate': totalPickups > 0 ? (completedPickups / totalPickups) * 100 : 0,
        'deliveryCompletionRate': totalDeliveries > 0 ? (completedDeliveries / totalDeliveries) * 100 : 0,
        'weeklyGrowthRate': lastWeekPickups > 0 
            ? ((thisWeekPickups - lastWeekPickups) / lastWeekPickups) * 100 
            : 0,
      };
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

  Future<void> notifyWarehouseOfPickup(String logisticsId, String pickupId) async {
    try {
      await _firestore.collection('warehouseNotifications').add({
        'logisticsId': logisticsId,
        'pickupId': pickupId,
        'type': 'pickup_notification',
        'message': 'New pickup assignment available',
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to notify warehouse: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getWarehouseNotifications(String logisticsId) async {
    try {
      final snapshot = await _firestore
          .collection('warehouseNotifications')
          .where('logisticsId', isEqualTo: logisticsId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {
                ...(doc.data() as Map<String, dynamic>),
                'id': doc.id,
              })
          .toList();
    } catch (e) {
      throw Exception('Failed to get warehouse notifications: $e');
    }
  }

  Future<Map<String, dynamic>> getAdminDashboardData(String logisticsId) async {
    try {
      final routes = await _firestore
          .collection('routes')
          .where('logisticsId', isEqualTo: logisticsId)
          .get();
      
      final logisticsAssignments = await _firestore
          .collection('logisticsAssignments')
          .where('logistics_id', isEqualTo: logisticsId)
          .get();

      // Separate pickup and delivery assignments
      final pickupAssignments = logisticsAssignments.docs
          .where((doc) => doc.data()['type'] == 'pickup')
          .toList();
      final deliveryAssignments = logisticsAssignments.docs
          .where((doc) => doc.data()['type'] == 'delivery')
          .toList();

      return {
        'totalRoutes': routes.docs.length,
        'activeRoutes': routes.docs.where((doc) => doc.data()['status'] == 'inProgress').length,
        'totalPickups': pickupAssignments.length,
        'pendingPickups': pickupAssignments.where((doc) => doc.data()['status'] == 'pending').length,
        'completedPickups': pickupAssignments.where((doc) => doc.data()['status'] == 'completed').length,
        'totalDeliveries': deliveryAssignments.length,
        'pendingDeliveries': deliveryAssignments.where((doc) => doc.data()['status'] == 'pending').length,
        'completedDeliveries': deliveryAssignments.where((doc) => doc.data()['status'] == 'completed').length,
      };
    } catch (e) {
      throw Exception('Failed to get admin dashboard data: $e');
    }
  }

  Future<void> sendAdminAlert(String logisticsId, String alertType, String message) async {
    try {
      await _firestore.collection('adminAlerts').add({
        'logisticsId': logisticsId,
        'alertType': alertType,
        'message': message,
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to send admin alert: $e');
    }
  }

  // ==================== PICKUP REQUEST TO LOGISTICS ASSIGNMENT CONVERSION ====================

  Future<String> createLogisticsAssignmentFromPickupRequest(String pickupRequestId, String logisticsId) async {
    try {
      print('🚚 [LOGISTICS_REPO] Creating logistics assignment from pickup request: $pickupRequestId');
      
      // Get the pickup request details
      final pickupDoc = await _firestore.collection('pickupRequests').doc(pickupRequestId).get();
      if (!pickupDoc.exists) {
        throw Exception('Pickup request not found: $pickupRequestId');
      }
      
      final pickupData = pickupDoc.data() as Map<String, dynamic>;
      print('🚚 [LOGISTICS_REPO] Found pickup request: ${pickupData['customer_name']}');
      
      // Create a pickup logistics assignment (tailor to warehouse)
      final pickupAssignment = LogisticsAssignmentModel(
        id: 'pickup-${DateTime.now().millisecondsSinceEpoch}',
        logisticsId: logisticsId,
        pickupRequestId: pickupRequestId,
        type: LogisticsAssignmentType.pickup,
        tailorId: pickupData['tailor_id'],
        tailorName: pickupData['customer_name'], // Using customer name as tailor name for now
        tailorAddress: pickupData['pickup_address'],
        tailorPhone: pickupData['customer_phone'],
        fabricType: pickupData['fabric_type'] ?? 'unknown',
        fabricDescription: pickupData['fabric_description'] ?? 'No description',
        estimatedWeight: (pickupData['estimated_weight'] ?? 0.0).toDouble(),
        status: LogisticsAssignmentStatus.pending,
        createdAt: DateTime.now(),
        notes: 'Auto-generated from pickup request',
      );
      
      // Create the pickup assignment
      final assignmentId = await createLogisticsAssignment(pickupAssignment);
      print('🚚 [LOGISTICS_REPO] ✅ Created pickup logistics assignment: $assignmentId');
      
      // Update the pickup request to mark it as assigned to logistics
      await _firestore.collection('pickupRequests').doc(pickupRequestId).update({
        'logistics_id': logisticsId,
        'status': 'scheduled',
        'updated_at': DateTime.now().toIso8601String(),
      });
      
      print('🚚 [LOGISTICS_REPO] ✅ Updated pickup request with logistics assignment');
      
      return assignmentId;
    } catch (e) {
      print('🚚 [LOGISTICS_REPO] ❌ Error creating logistics assignment from pickup request: $e');
      throw Exception('Failed to create logistics assignment from pickup request: $e');
    }
  }

  // Method to get available pickup requests that need logistics assignments
  Stream<List<Map<String, dynamic>>> getAvailablePickupRequests() {
    print('🚚 [LOGISTICS_REPO] Getting available pickup requests for logistics assignment');
    return _firestore
        .collection('pickupRequests')
        .where('status', isEqualTo: 'pending')
        .where('logistics_id', isNull: true)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
          print('🚚 [LOGISTICS_REPO] Found ${snapshot.docs.length} available pickup requests');
          return snapshot.docs.map((doc) => {
            ...(doc.data() as Map<String, dynamic>),
            'id': doc.id,
          }).toList();
        });
  }

  // Method to assign logistics to a pickup request
  Future<void> assignLogisticsToPickupRequest(String pickupRequestId, String logisticsId) async {
    try {
      print('🚚 [LOGISTICS_REPO] Assigning logistics $logisticsId to pickup request $pickupRequestId');
      
      // Create the logistics assignment
      await createLogisticsAssignmentFromPickupRequest(pickupRequestId, logisticsId);
      
      print('🚚 [LOGISTICS_REPO] ✅ Successfully assigned logistics to pickup request');
    } catch (e) {
      print('🚚 [LOGISTICS_REPO] ❌ Error assigning logistics to pickup request: $e');
      throw Exception('Failed to assign logistics to pickup request: $e');
    }
  }
} 