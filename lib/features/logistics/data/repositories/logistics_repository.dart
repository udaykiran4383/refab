import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/route_model.dart';
import '../models/pickup_assignment_model.dart';
import '../models/logistics_assignment_model.dart';



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

      // If status is cancelled, also update the pickup request to remove logistics assignment
      if (status == LogisticsAssignmentStatus.cancelled) {
        await _handleCancelledAssignment(assignmentId, 'Assignment cancelled by logistics', 'logistics_user_id');
      }
    } catch (e) {
      print('🚚 [LOGISTICS_REPO] ❌ Error updating assignment status: $e');
      throw Exception('Failed to update assignment status: $e');
    }
  }

  // Dedicated method for cancelling logistics assignments
  Future<void> cancelLogisticsAssignment(String assignmentId, String reason, String cancelledByUserId) async {
    try {
      print('🚚 [LOGISTICS_REPO] Cancelling logistics assignment: $assignmentId');
      print('🚚 [LOGISTICS_REPO] Reason: $reason');
      print('🚚 [LOGISTICS_REPO] Cancelled by: $cancelledByUserId');
      
      final updates = {
        'status': 'cancelled',
        'updated_at': DateTime.now().toIso8601String(),
        'cancelled_at': DateTime.now().toIso8601String(),
        'cancellation_reason': reason,
        'cancelled_by': cancelledByUserId,
      };

      await _firestore.collection('logisticsAssignments').doc(assignmentId).update(updates);
      print('🚚 [LOGISTICS_REPO] ✅ Assignment cancelled successfully');

      // Handle the cancelled assignment - reset pickup request with cancellation details
      await _handleCancelledAssignment(assignmentId, reason, cancelledByUserId);
    } catch (e) {
      print('🚚 [LOGISTICS_REPO] ❌ Error cancelling assignment: $e');
      throw Exception('Failed to cancel logistics assignment: $e');
    }
  }

  Future<void> _handleCancelledAssignment(String assignmentId, String reason, String cancelledByUserId) async {
    try {
      print('🚚 [LOGISTICS_REPO] Handling cancelled assignment: $assignmentId');
      
      // Get the assignment to find the pickup request ID
      final assignmentDoc = await _firestore.collection('logisticsAssignments').doc(assignmentId).get();
      if (!assignmentDoc.exists) {
        print('🚚 [LOGISTICS_REPO] ❌ Assignment not found: $assignmentId');
        return;
      }

      final assignmentData = assignmentDoc.data() as Map<String, dynamic>;
      final pickupRequestId = assignmentData['pickup_request_id'];
      final tailorId = assignmentData['tailor_id'];
      final logisticsId = assignmentData['logistics_id'];
      
      if (pickupRequestId != null) {
        // Get the current pickup request to understand its state
        final pickupDoc = await _firestore.collection('pickupRequests').doc(pickupRequestId).get();
        if (!pickupDoc.exists) {
          print('🚚 [LOGISTICS_REPO] ❌ Pickup request not found: $pickupRequestId');
          return;
        }

        final pickupData = pickupDoc.data() as Map<String, dynamic>;
        final currentStatus = pickupData['status'];
        final workProgress = pickupData['work_progress'];
        
        // Determine the appropriate status based on current state
        String newStatus = 'cancelled'; // Changed from 'pending' to 'cancelled'
        String cancellationReason = 'Logistics assignment cancelled: $reason';
        
        // If fabric was already picked up, we need to handle this differently
        if (currentStatus == 'picked_up' || currentStatus == 'in_transit' || currentStatus == 'delivered') {
          newStatus = 'cancelled'; // Keep as cancelled but note fabric status
          cancellationReason = 'Logistics delivery assignment cancelled - fabric remains with tailor. Reason: $reason';
        }
        
        // Update pickup request to remove logistics assignment and set cancellation status
        final updates = {
          'logistics_id': null,
          'status': newStatus,
          'updated_at': DateTime.now().toIso8601String(),
          'cancellation_reason': cancellationReason,
          'cancelled_by': cancelledByUserId,
          'cancelled_at': DateTime.now().toIso8601String(),
        };

        // Reset work progress if it was in progress (fabric was picked up)
        if (workProgress != null && workProgress != 'notStarted') {
          updates['work_progress'] = 'notStarted';
          updates['progress'] = 'Work progress reset due to logistics cancellation';
        }

        await _firestore.collection('pickupRequests').doc(pickupRequestId).update(updates);
        print('🚚 [LOGISTICS_REPO] ✅ Updated pickup request $pickupRequestId to cancelled status');
        
        // Create notification for tailor with cancellation details
        if (tailorId != null) {
          await _createTailorNotification(
            tailorId, 
            pickupRequestId, 
            'Logistics Assignment Cancelled',
            'Your logistics assignment has been cancelled by logistics personnel. Reason: $reason. The pickup request is now available for reassignment.',
            'logistics_cancelled'
          );
        }
        
        // Create audit log entry
        await _createAuditLog(
          'logistics_assignment_cancelled',
          {
            'assignment_id': assignmentId,
            'pickup_request_id': pickupRequestId,
            'tailor_id': tailorId,
            'logistics_id': logisticsId,
            'previous_status': currentStatus,
            'new_status': newStatus,
            'cancellation_reason': reason,
            'cancelled_by': cancelledByUserId,
          }
        );
      }
    } catch (e) {
      print('🚚 [LOGISTICS_REPO] ❌ Error handling cancelled assignment: $e');
      // Don't throw here to avoid breaking the main status update
    }
  }

  // Helper method to create tailor notifications
  Future<void> _createTailorNotification(
    String tailorId, 
    String pickupRequestId, 
    String title, 
    String message, 
    String type
  ) async {
    try {
      await _firestore.collection('notifications').add({
        'tailor_id': tailorId,
        'pickup_request_id': pickupRequestId,
        'title': title,
        'message': message,
        'type': type,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
        'priority': 'high',
      });
      print('🚚 [LOGISTICS_REPO] ✅ Created notification for tailor: $tailorId');
    } catch (e) {
      print('🚚 [LOGISTICS_REPO] ❌ Error creating tailor notification: $e');
    }
  }

  // Helper method to create audit logs
  Future<void> _createAuditLog(String action, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('audit_logs').add({
        'action': action,
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
        'user_type': 'logistics',
      });
      print('🚚 [LOGISTICS_REPO] ✅ Created audit log for action: $action');
    } catch (e) {
      print('🚚 [LOGISTICS_REPO] ❌ Error creating audit log: $e');
    }
  }

  Future<void> assignWarehouse(String assignmentId, String warehouseId, String warehouseName, WarehouseType warehouseType, String warehouseAddress) async {
    try {
      print('🚚 [LOGISTICS_REPO] Assigning warehouse: $warehouseId to assignment: $assignmentId');
      
      // Get the assignment to find the pickup request ID
      final assignmentDoc = await _firestore.collection('logisticsAssignments').doc(assignmentId).get();
      if (!assignmentDoc.exists) {
        throw Exception('Assignment not found: $assignmentId');
      }
      
      final assignmentData = assignmentDoc.data() as Map<String, dynamic>;
      final pickupRequestId = assignmentData['pickup_request_id'];
      final currentLogisticsId = assignmentData['logistics_id'];
      
      // Check if this logistics personnel has already assigned themselves
      if (assignmentData['assigned_warehouse_id'] != null) {
        throw Exception('Assignment already has a warehouse assigned. Cannot assign multiple warehouses.');
      }
      
      print('🚚 [LOGISTICS_REPO] Updating logistics assignment document with warehouse assignment');
      print('🚚 [LOGISTICS_REPO] Assignment ID: $assignmentId');
      print('🚚 [LOGISTICS_REPO] Warehouse ID: $warehouseId');
      print('🚚 [LOGISTICS_REPO] Warehouse Name: $warehouseName');
      
      // Update the logistics assignment
      await _firestore.collection('logisticsAssignments').doc(assignmentId).update({
        'assigned_warehouse_id': warehouseId,
        'assigned_warehouse_name': warehouseName,
        'warehouse_type': warehouseType.toString().split('.').last,
        'warehouse_address': warehouseAddress,
        'status': 'assigned', // <-- Set status to assigned
        'scheduled_time': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'assigned_by_logistics_id': currentLogisticsId, // Track who assigned it
        'assigned_at': DateTime.now().toIso8601String(),
      });
      
      print('🚚 [LOGISTICS_REPO] ✅ Logistics assignment document updated successfully');
      
      // Update the pickup request status to show logistics assignment
      if (pickupRequestId != null) {
        await _firestore.collection('pickupRequests').doc(pickupRequestId).update({
          'status': 'scheduled', // Update pickup request status
          'logistics_id': assignmentData['logistics_id'], // Ensure logistics ID is set
          'updated_at': DateTime.now().toIso8601String(),
        });
        print('🚚 [LOGISTICS_REPO] ✅ Pickup request status updated to scheduled');
      }
      
      print('🚚 [LOGISTICS_REPO] ✅ Warehouse assigned and status updated to assigned');
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
      print('🚚 [LOGISTICS_REPO] Starting getAvailableWarehouses...');
      
      // First, let's try to get ALL warehouses to see what's in the collection
      print('🚚 [LOGISTICS_REPO] Checking all warehouses first...');
      final allSnapshot = await _firestore.collection('warehouses').get();
      print('🚚 [LOGISTICS_REPO] Total warehouses in collection: ${allSnapshot.docs.length}');
      
      for (final doc in allSnapshot.docs) {
        final data = doc.data();
        print('🚚 [LOGISTICS_REPO] Warehouse ${doc.id}: ${data['name']} - is_active: ${data['is_active']}');
      }
      
      // Now try the filtered query
      final snapshot = await _firestore
          .collection('warehouses')
          .where('is_active', isEqualTo: true)
          .get();
      
      print('🚚 [LOGISTICS_REPO] Filtered query completed. Found ${snapshot.docs.length} active warehouses');
      
      final warehouses = snapshot.docs.map((doc) {
        final data = {
          ...(doc.data() as Map<String, dynamic>),
          'id': doc.id,
        };
        print('🚚 [LOGISTICS_REPO] Active Warehouse: ${data['name']} (ID: ${data['id']}, Active: ${data['is_active']})');
        return data;
      }).toList();
      
      print('🚚 [LOGISTICS_REPO] ✅ Returning ${warehouses.length} warehouses');
      
      // If no warehouses found with filter, try without filter as fallback
      if (warehouses.isEmpty) {
        print('🚚 [LOGISTICS_REPO] ⚠️ No active warehouses found, trying without filter...');
        final fallbackSnapshot = await _firestore.collection('warehouses').get();
        final fallbackWarehouses = fallbackSnapshot.docs.map((doc) {
          final data = {
            ...(doc.data() as Map<String, dynamic>),
            'id': doc.id,
          };
          print('🚚 [LOGISTICS_REPO] Fallback Warehouse: ${data['name']} (ID: ${data['id']}, Active: ${data['is_active']})');
          return data;
        }).toList();
        
        print('🚚 [LOGISTICS_REPO] ✅ Fallback returning ${fallbackWarehouses.length} warehouses');
        return fallbackWarehouses;
      }
      
      return warehouses;
    } catch (e) {
      print('🚚 [LOGISTICS_REPO] ❌ Error getting available warehouses: $e');
      print('🚚 [LOGISTICS_REPO] Error type: ${e.runtimeType}');
      if (e is FirebaseException) {
        print('🚚 [LOGISTICS_REPO] Firebase error code: ${e.code}');
        print('🚚 [LOGISTICS_REPO] Firebase error message: ${e.message}');
      }
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
      
      // Check if this pickup request already has a logistics assignment
      final existingAssignment = await _firestore
          .collection('logisticsAssignments')
          .where('pickup_request_id', isEqualTo: pickupRequestId)
          .where('type', isEqualTo: 'pickup')
          .get();
      
      if (existingAssignment.docs.isNotEmpty) {
        final existingDoc = existingAssignment.docs.first;
        final existingLogisticsId = existingDoc.data()['logistics_id'];
        throw Exception('Pickup request $pickupRequestId is already assigned to logistics $existingLogisticsId. Only one logistics partner can be assigned per pickup request.');
      }
      
      // Get the pickup request details
      final pickupDoc = await _firestore.collection('pickupRequests').doc(pickupRequestId).get();
      if (!pickupDoc.exists) {
        throw Exception('Pickup request not found: $pickupRequestId');
      }
      
      final pickupData = pickupDoc.data() as Map<String, dynamic>;
      print('🚚 [LOGISTICS_REPO] Found pickup request: ${pickupData['customer_name']}');
      
      // Check if pickup request is already assigned to another logistics
      if (pickupData['logistics_id'] != null && pickupData['logistics_id'] != logisticsId) {
        throw Exception('Pickup request $pickupRequestId is already assigned to logistics ${pickupData['logistics_id']}. Only one logistics partner can be assigned per pickup request.');
      }
      
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
          final validRequests = <Map<String, dynamic>>[];
          
          for (final doc in snapshot.docs) {
            try {
              final data = doc.data() as Map<String, dynamic>;
              // Validate that the document has required fields
              if (data.containsKey('tailor_id') && 
                  data.containsKey('customer_name') && 
                  data.containsKey('pickup_address')) {
                validRequests.add({
                  ...data,
                  'id': doc.id,
                });
              } else {
                print('🚚 [LOGISTICS_REPO] ⚠️ Skipping invalid pickup request ${doc.id}: missing required fields');
              }
            } catch (e) {
              print('🚚 [LOGISTICS_REPO] ⚠️ Error processing pickup request ${doc.id}: $e');
            }
          }
          
          print('🚚 [LOGISTICS_REPO] Returning ${validRequests.length} valid pickup requests');
          return validRequests;
        });
  }

  // Method to assign logistics to a pickup request with single assignment validation
  Future<void> assignLogisticsToPickupRequest(String pickupRequestId, String logisticsId) async {
    try {
      print('🚚 [LOGISTICS_REPO] Assigning logistics $logisticsId to pickup request $pickupRequestId');
      
      // First, validate that the pickup request exists and is in the correct state
      final pickupDoc = await _firestore.collection('pickupRequests').doc(pickupRequestId).get();
      if (!pickupDoc.exists) {
        print('🚚 [LOGISTICS_REPO] ❌ Pickup request not found: $pickupRequestId');
        throw Exception('Pickup request not found: $pickupRequestId');
      }
      
      final pickupData = pickupDoc.data() as Map<String, dynamic>;
      
      // Check if pickup request is in pending status
      if (pickupData['status'] != 'pending') {
        print('🚚 [LOGISTICS_REPO] ❌ Pickup request $pickupRequestId is not in pending status: ${pickupData['status']}');
        throw Exception('Pickup request $pickupRequestId is not available for assignment (status: ${pickupData['status']})');
      }
      
      // Check if pickup request already has a logistics assignment
      if (pickupData['logistics_id'] != null && pickupData['logistics_id'] != logisticsId) {
        print('🚚 [LOGISTICS_REPO] ❌ Pickup request $pickupRequestId is already assigned to logistics ${pickupData['logistics_id']}');
        throw Exception('Pickup request $pickupRequestId is already assigned to logistics ${pickupData['logistics_id']}. Only one logistics partner can be assigned per pickup request.');
      }
      
      // Check if this pickup request already has a logistics assignment in the assignments collection
      final existingAssignment = await _firestore
          .collection('logisticsAssignments')
          .where('pickup_request_id', isEqualTo: pickupRequestId)
          .where('type', isEqualTo: 'pickup')
          .get();
      
      if (existingAssignment.docs.isNotEmpty) {
        final existingDoc = existingAssignment.docs.first;
        final existingLogisticsId = existingDoc.data()['logistics_id'];
        print('🚚 [LOGISTICS_REPO] ❌ Pickup request $pickupRequestId already has assignment to logistics $existingLogisticsId');
        throw Exception('Pickup request $pickupRequestId is already assigned to logistics $existingLogisticsId. Only one logistics partner can be assigned per pickup request.');
      }
      
      // Create the logistics assignment
      await createLogisticsAssignmentFromPickupRequest(pickupRequestId, logisticsId);
      
      print('🚚 [LOGISTICS_REPO] ✅ Successfully assigned logistics to pickup request');
    } catch (e) {
      print('🚚 [LOGISTICS_REPO] ❌ Error assigning logistics to pickup request: $e');
      throw Exception('Failed to assign logistics to pickup request: $e');
    }
  }

  // Method to check if a pickup request is already assigned
  Future<bool> isPickupRequestAssigned(String pickupRequestId) async {
    try {
      final existingAssignment = await _firestore
          .collection('logisticsAssignments')
          .where('pickup_request_id', isEqualTo: pickupRequestId)
          .where('type', isEqualTo: 'pickup')
          .get();
      
      return existingAssignment.docs.isNotEmpty;
    } catch (e) {
      print('🚚 [LOGISTICS_REPO] ❌ Error checking pickup request assignment: $e');
      return false;
    }
  }

  // Method to get the current logistics assignment for a pickup request
  Stream<LogisticsAssignmentModel?> getLogisticsAssignmentForPickupRequest(String pickupRequestId) {
    print('🚚 [LOGISTICS_REPO] Getting logistics assignment stream for pickup request: $pickupRequestId');
    return _firestore
        .collection('logisticsAssignments')
        .where('pickup_request_id', isEqualTo: pickupRequestId)
        .where('type', isEqualTo: 'pickup')
        .snapshots()
        .map((snapshot) {
          print('🚚 [LOGISTICS_REPO] Found ${snapshot.docs.length} logistics assignments for pickup request: $pickupRequestId');
          if (snapshot.docs.isNotEmpty) {
            final doc = snapshot.docs.first;
            try {
              final assignment = LogisticsAssignmentModel.fromJson({
                ...(doc.data() as Map<String, dynamic>),
                'id': doc.id,
              });
              print('🚚 [LOGISTICS_REPO] ✅ Returning logistics assignment: ${assignment.id} for pickup request: $pickupRequestId');
              return assignment;
            } catch (e) {
              print('🚚 [LOGISTICS_REPO] ❌ Error parsing logistics assignment ${doc.id}: $e');
              return null;
            }
          }
          print('🚚 [LOGISTICS_REPO] No logistics assignment found for pickup request: $pickupRequestId');
          return null;
        });
  }

  // Method to clean up invalid pickup requests
  Future<void> cleanupInvalidPickupRequests() async {
    try {
      print('🚚 [LOGISTICS_REPO] Starting cleanup of invalid pickup requests...');
      
      final pickupRequests = await _firestore.collection('pickupRequests').get();
      int cleanedCount = 0;
      
      for (final doc in pickupRequests.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          
          // Check if required fields are missing
          if (!data.containsKey('tailor_id') || 
              !data.containsKey('customer_name') || 
              !data.containsKey('pickup_address')) {
            
            print('🚚 [LOGISTICS_REPO] 🧹 Cleaning up invalid pickup request: ${doc.id}');
            await doc.reference.delete();
            cleanedCount++;
          }
        } catch (e) {
          print('🚚 [LOGISTICS_REPO] ⚠️ Error processing pickup request ${doc.id} during cleanup: $e');
        }
      }
      
      print('🚚 [LOGISTICS_REPO] ✅ Cleanup completed. Removed $cleanedCount invalid pickup requests');
    } catch (e) {
      print('🚚 [LOGISTICS_REPO] ❌ Error during cleanup: $e');
      throw Exception('Failed to cleanup invalid pickup requests: $e');
    }
  }

  // Method to validate pickup request before assignment
  Future<bool> validatePickupRequest(String pickupRequestId) async {
    try {
      final pickupDoc = await _firestore.collection('pickupRequests').doc(pickupRequestId).get();
      
      if (!pickupDoc.exists) {
        print('🚚 [LOGISTICS_REPO] ❌ Pickup request validation failed: $pickupRequestId does not exist');
        return false;
      }
      
      final data = pickupDoc.data() as Map<String, dynamic>;
      
      // Check required fields
      if (!data.containsKey('tailor_id') || 
          !data.containsKey('customer_name') || 
          !data.containsKey('pickup_address')) {
        print('🚚 [LOGISTICS_REPO] ❌ Pickup request validation failed: $pickupRequestId missing required fields');
        return false;
      }
      
      // Check status
      if (data['status'] != 'pending') {
        print('🚚 [LOGISTICS_REPO] ❌ Pickup request validation failed: $pickupRequestId not in pending status');
        return false;
      }
      
      print('🚚 [LOGISTICS_REPO] ✅ Pickup request validation passed: $pickupRequestId');
      return true;
    } catch (e) {
      print('🚚 [LOGISTICS_REPO] ❌ Error validating pickup request $pickupRequestId: $e');
      return false;
    }
  }
} 