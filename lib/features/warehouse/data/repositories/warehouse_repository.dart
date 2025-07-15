import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/inventory_model.dart';
import '../models/warehouse_worker_model.dart';
import '../models/warehouse_assignment_model.dart';

class WarehouseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== INVENTORY MANAGEMENT ====================

  Future<String> createInventoryItem(InventoryModel item) async {
    try {
      final docRef = await _firestore.collection('inventory').add(item.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create inventory item: $e');
    }
  }

  Stream<List<InventoryModel>> getInventoryItems({
    String? warehouseId,
    String? status,
    String? fabricCategory,
    String? qualityGrade,
  }) {
    Query query = _firestore.collection('inventory');
    
    if (warehouseId != null) {
      query = query.where('warehouseId', isEqualTo: warehouseId);
    }
    
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }
    
    if (fabricCategory != null) {
      query = query.where('fabricCategory', isEqualTo: fabricCategory);
    }
    
    if (qualityGrade != null) {
      query = query.where('qualityGrade', isEqualTo: qualityGrade);
    }
    
    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InventoryModel.fromJson({
                  ...(doc.data() as Map<String, dynamic>),
                  'id': doc.id,
                }))
            .toList());
  }

  Future<InventoryModel?> getInventoryItem(String itemId) async {
    try {
      final doc = await _firestore.collection('inventory').doc(itemId).get();
      if (doc.exists) {
        return InventoryModel.fromJson({
          ...(doc.data()! as Map<String, dynamic>),
          'id': doc.id,
        });
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get inventory item: $e');
    }
  }

  Future<void> updateInventoryItem(String itemId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('inventory').doc(itemId).update({
        ...updates,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update inventory item: $e');
    }
  }

  Future<void> updateInventoryStatus(String itemId, InventoryStatus status) async {
    try {
      await _firestore.collection('inventory').doc(itemId).update({
        'status': status.toString().split('.').last,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update inventory status: $e');
    }
  }

  Future<void> updateInventoryQuantity(String itemId, double newWeight) async {
    try {
      await _firestore.collection('inventory').doc(itemId).update({
        'actualWeight': newWeight,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update inventory quantity: $e');
    }
  }

  Future<void> deleteInventoryItem(String itemId) async {
    try {
      await _firestore.collection('inventory').doc(itemId).delete();
    } catch (e) {
      throw Exception('Failed to delete inventory item: $e');
    }
  }

  Future<List<InventoryModel>> getLowStockAlerts(String warehouseId) async {
    try {
      final snapshot = await _firestore
          .collection('inventory')
          .where('warehouseId', isEqualTo: warehouseId)
          .where('status', isEqualTo: InventoryStatus.lowStock.toString().split('.').last)
          .get();
      return snapshot.docs
          .map((doc) => InventoryModel.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to get low stock alerts: $e');
    }
  }

  Future<List<InventoryModel>> getInventoryByCategory(String warehouseId, String category) async {
    try {
      final snapshot = await _firestore
          .collection('inventory')
          .where('warehouseId', isEqualTo: warehouseId)
          .where('fabricCategory', isEqualTo: category)
          .get();
      return snapshot.docs
          .map((doc) => InventoryModel.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to get inventory by category: $e');
    }
  }

  // ==================== WORKER MANAGEMENT ====================

  Future<String> createWorker(WarehouseWorkerModel worker) async {
    try {
      final docRef = await _firestore.collection('warehouseWorkers').add(worker.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create worker: $e');
    }
  }

  Stream<List<WarehouseWorkerModel>> getWorkers({
    String? warehouseId,
    String? status,
    WorkerRole? role,
  }) {
    Query query = _firestore.collection('warehouseWorkers');
    if (warehouseId != null) {
      query = query.where('warehouseId', isEqualTo: warehouseId);
    }
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }
    if (role != null) {
      query = query.where('role', isEqualTo: role.toString().split('.').last);
    }
    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WarehouseWorkerModel.fromJson({
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                }))
            .toList());
  }

  Future<void> updateWorker(String workerId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('warehouseWorkers').doc(workerId).update({
        ...updates,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update worker: $e');
    }
  }

  Future<void> updateWorkerPerformance(String workerId, Map<String, dynamic> metrics) async {
    try {
      await _firestore.collection('warehouseWorkers').doc(workerId).update({
        'performanceMetrics': metrics,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update worker performance: $e');
    }
  }

  // ==================== WAREHOUSE ASSIGNMENTS ====================

  Future<String> createWarehouseAssignment(WarehouseAssignmentModel assignment) async {
    try {
      print('🏭 [WAREHOUSE_REPO] Creating warehouse assignment for warehouse: ${assignment.warehouseId}');
      print('🏭 [WAREHOUSE_REPO] Assignment data: ${assignment.toJson()}');
      final docRef = await _firestore.collection('warehouseAssignments').add(assignment.toJson());
      print('🏭 [WAREHOUSE_REPO] ✅ Assignment created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('🏭 [WAREHOUSE_REPO] ❌ Error creating warehouse assignment: $e');
      throw Exception('Failed to create warehouse assignment: $e');
    }
  }

  Stream<List<WarehouseAssignmentModel>> getWarehouseAssignments(String warehouseId) {
    print('🏭 [WAREHOUSE_REPO] Getting assignments for warehouse: $warehouseId');
    return _firestore
        .collection('warehouseAssignments')
        .where('warehouseId', isEqualTo: warehouseId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          print('🏭 [WAREHOUSE_REPO] Found ${snapshot.docs.length} assignments for warehouse: $warehouseId');
          final assignments = snapshot.docs.map((doc) {
            try {
              final data = doc.data() as Map<String, dynamic>;
              print('🏭 [WAREHOUSE_REPO] Assignment ${doc.id}: warehouseId=${data['warehouseId']}, status=${data['status']}');
              return WarehouseAssignmentModel.fromJson({
                ...data,
                'id': doc.id,
              });
            } catch (e) {
              print('🏭 [WAREHOUSE_REPO] ❌ Error parsing assignment ${doc.id}: $e');
              return null;
            }
          }).where((assignment) => assignment != null).cast<WarehouseAssignmentModel>().toList();
          
          print('🏭 [WAREHOUSE_REPO] ✅ Returning ${assignments.length} valid assignments');
          return assignments;
        });
  }

  Stream<List<WarehouseAssignmentModel>> getAllWarehouseAssignments() {
    print('🏭 [WAREHOUSE_REPO] Getting all assignments for all warehouses');
    return _firestore
        .collection('warehouseAssignments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          print('🏭 [WAREHOUSE_REPO] Found ${snapshot.docs.length} assignments for all warehouses');
          final assignments = snapshot.docs.map((doc) {
            try {
              final data = doc.data() as Map<String, dynamic>;
              print('🏭 [WAREHOUSE_REPO] Assignment ${doc.id}: warehouseId=${data['warehouseId']}, status=${data['status']}');
              return WarehouseAssignmentModel.fromJson({
                ...data,
                'id': doc.id,
              });
            } catch (e) {
              print('🏭 [WAREHOUSE_REPO] ❌ Error parsing assignment ${doc.id}: $e');
              return null;
            }
          }).where((assignment) => assignment != null).cast<WarehouseAssignmentModel>().toList();
          
          print('🏭 [WAREHOUSE_REPO] ✅ Returning ${assignments.length} valid assignments for all warehouses');
          return assignments;
        });
  }

  Stream<List<WarehouseAssignmentModel>> getTodayAssignments(String warehouseId) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection('warehouseAssignments')
        .where('warehouseId', isEqualTo: warehouseId)
        .where('scheduledArrivalTime', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
        .where('scheduledArrivalTime', isLessThan: endOfDay.toIso8601String())
        .orderBy('scheduledArrivalTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WarehouseAssignmentModel.fromJson({
                  ...(doc.data() as Map<String, dynamic>),
                  'id': doc.id,
                }))
            .toList());
  }

  Stream<List<WarehouseAssignmentModel>> getInTransitAssignments(String warehouseId) {
    return _firestore
        .collection('warehouseAssignments')
        .where('warehouseId', isEqualTo: warehouseId)
        .where('status', isEqualTo: WarehouseAssignmentStatus.inTransit.toString().split('.').last)
        .orderBy('scheduledArrivalTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WarehouseAssignmentModel.fromJson({
                  ...(doc.data() as Map<String, dynamic>),
                  'id': doc.id,
                }))
            .toList());
  }

  Future<WarehouseAssignmentModel?> getWarehouseAssignment(String assignmentId) async {
    try {
      final doc = await _firestore.collection('warehouseAssignments').doc(assignmentId).get();
      if (doc.exists) {
        return WarehouseAssignmentModel.fromJson({
          ...(doc.data()! as Map<String, dynamic>),
          'id': doc.id,
        });
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get warehouse assignment: $e');
    }
  }

  Future<void> updateAssignmentStatus(String assignmentId, WarehouseAssignmentStatus status) async {
    try {
      final updates = {
        'status': status.toString().split('.').last,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // Add specific time fields based on status
      switch (status) {
        case WarehouseAssignmentStatus.arrived:
          updates['actualArrivalTime'] = DateTime.now().toIso8601String();
          break;
        case WarehouseAssignmentStatus.processing:
          // No specific time field for processing
          break;
        case WarehouseAssignmentStatus.completed:
          // No specific time field for completed
          break;
        case WarehouseAssignmentStatus.cancelled:
          // No specific time field for cancelled
          break;
        case WarehouseAssignmentStatus.scheduled:
          // No specific time field for scheduled
          break;
        case WarehouseAssignmentStatus.inTransit:
          // No specific time field for inTransit
          break;
      }

      await _firestore.collection('warehouseAssignments').doc(assignmentId).update(updates);
    } catch (e) {
      throw Exception('Failed to update assignment status: $e');
    }
  }

  Future<void> markAssignmentArrived(String assignmentId, DateTime arrivalTime) async {
    try {
      await _firestore.collection('warehouseAssignments').doc(assignmentId).update({
        'status': WarehouseAssignmentStatus.arrived.toString().split('.').last,
        'actualArrivalTime': arrivalTime.toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to mark assignment as arrived: $e');
    }
  }

  Future<void> addAssignmentNotes(String assignmentId, String notes) async {
    try {
      await _firestore.collection('warehouseAssignments').doc(assignmentId).update({
        'notes': notes,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to add assignment notes: $e');
    }
  }

  Future<void> updateAssignmentSection(String assignmentId, WarehouseSection section) async {
    try {
      await _firestore.collection('warehouseAssignments').doc(assignmentId).update({
        'warehouseSection': section.toString().split('.').last,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update assignment section: $e');
    }
  }

  // ==================== WAREHOUSE DETAILS ====================

  Future<Map<String, dynamic>?> getWarehouseDetails(String warehouseId) async {
    try {
      print('🏭 [WAREHOUSE_REPO] Fetching warehouse details for ID: $warehouseId');
      final doc = await _firestore.collection('warehouses').doc(warehouseId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        print('🏭 [WAREHOUSE_REPO] Found warehouse: ${data['name']}');
        return {
          ...data,
          'id': doc.id,
        };
      }
      print('🏭 [WAREHOUSE_REPO] Warehouse not found: $warehouseId');
      return null;
    } catch (e) {
      print('🏭 [WAREHOUSE_REPO] Error fetching warehouse details: $e');
      throw Exception('Failed to get warehouse details: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAvailableWarehouses() async {
    try {
      print('🏭 [WAREHOUSE_REPO] Fetching available warehouses');
      
      // Try to get active warehouses first
      final snapshot = await _firestore
          .collection('warehouses')
          .where('is_active', isEqualTo: true)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        print('🏭 [WAREHOUSE_REPO] Found ${snapshot.docs.length} active warehouses');
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            ...data,
            'id': doc.id,
          };
        }).toList();
      }
      
      // Fallback: get all warehouses if no active ones found
      print('🏭 [WAREHOUSE_REPO] No active warehouses found, fetching all warehouses');
      final allSnapshot = await _firestore.collection('warehouses').get();
      print('🏭 [WAREHOUSE_REPO] Found ${allSnapshot.docs.length} total warehouses');
      
      return allSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          ...data,
          'id': doc.id,
        };
      }).toList();
    } catch (e) {
      print('🏭 [WAREHOUSE_REPO] Error fetching available warehouses: $e');
      throw Exception('Failed to get available warehouses: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getLogisticsAssignmentsStream(String warehouseId) {
    print('🏭 [WAREHOUSE_REPO] Setting up logistics assignments stream for warehouse: $warehouseId');
    
    return _firestore
        .collection('logisticsAssignments')
        .where('assigned_warehouse_id', isEqualTo: warehouseId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
          print('🏭 [WAREHOUSE_REPO] Found ${snapshot.docs.length} logistics assignments for warehouse: $warehouseId');
          
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              ...data,
              'id': doc.id,
            };
          }).toList();
        });
  }
} 