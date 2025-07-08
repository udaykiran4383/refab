import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/inventory_model.dart';
import '../models/processing_task_model.dart';
import '../models/warehouse_analytics_model.dart';
import '../models/warehouse_worker_model.dart';
import '../models/warehouse_location_model.dart';

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
    String? category,
    String? qualityGrade,
  }) {
    Query query = _firestore.collection('inventory');
    
    if (warehouseId != null) {
      query = query.where('warehouseId', isEqualTo: warehouseId);
    }
    
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }
    
    if (category != null) {
      query = query.where('fabricCategory', isEqualTo: category);
    }
    
    if (qualityGrade != null) {
      query = query.where('qualityGrade', isEqualTo: qualityGrade);
    }
    
    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InventoryModel.fromJson({
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                }))
            .toList());
  }

  Future<InventoryModel?> getInventoryItem(String itemId) async {
    try {
      final doc = await _firestore.collection('inventory').doc(itemId).get();
      if (doc.exists) {
        return InventoryModel.fromJson({
          ...doc.data() as Map<String, dynamic>,
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

  // ==================== PROCESSING TASKS ====================

  Future<String> createProcessingTask(ProcessingTaskModel task) async {
    try {
      final docRef = await _firestore.collection('processingTasks').add(task.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create processing task: $e');
    }
  }

  Stream<List<ProcessingTaskModel>> getProcessingTasks({
    String? warehouseId,
    String? status,
    String? workerId,
    TaskType? taskType,
  }) {
    Query query = _firestore.collection('processingTasks');
    
    if (warehouseId != null) {
      query = query.where('warehouseId', isEqualTo: warehouseId);
    }
    
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }
    
    if (workerId != null) {
      query = query.where('assignedWorkerId', isEqualTo: workerId);
    }
    
    if (taskType != null) {
      query = query.where('taskType', isEqualTo: taskType.toString().split('.').last);
    }
    
    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProcessingTaskModel.fromJson({
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                }))
            .toList());
  }

  Future<void> updateProcessingTask(String taskId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('processingTasks').doc(taskId).update({
        ...updates,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update processing task: $e');
    }
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    try {
      final updates = {
        'status': status.toString().split('.').last,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      
      if (status == TaskStatus.inProgress) {
        updates['startDate'] = DateTime.now().toIso8601String();
      } else if (status == TaskStatus.completed) {
        updates['completedAt'] = DateTime.now().toIso8601String();
      }
      
      await _firestore.collection('processingTasks').doc(taskId).update(updates);
    } catch (e) {
      throw Exception('Failed to update task status: $e');
    }
  }

  Future<void> assignTaskToWorker(String taskId, String workerId, String workerName) async {
    try {
      await _firestore.collection('processingTasks').doc(taskId).update({
        'assignedWorkerId': workerId,
        'assignedTo': workerName,
        'status': TaskStatus.assigned.toString().split('.').last,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to assign task to worker: $e');
    }
  }

  Future<void> completeTask(String taskId, Map<String, dynamic> completionData) async {
    try {
      await _firestore.collection('processingTasks').doc(taskId).update({
        'status': TaskStatus.completed.toString().split('.').last,
        'completionData': completionData,
        'completedAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to complete task: $e');
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

  // ==================== LOCATION MANAGEMENT ====================

  Future<String> createLocation(WarehouseLocationModel location) async {
    try {
      final docRef = await _firestore.collection('warehouseLocations').add(location.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create location: $e');
    }
  }

  Stream<List<WarehouseLocationModel>> getLocations({
    String? warehouseId,
    String? status,
    LocationType? type,
  }) {
    Query query = _firestore.collection('warehouseLocations');
    
    if (warehouseId != null) {
      query = query.where('warehouseId', isEqualTo: warehouseId);
    }
    
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }
    
    if (type != null) {
      query = query.where('type', isEqualTo: type.toString().split('.').last);
    }
    
    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WarehouseLocationModel.fromJson({
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                }))
            .toList());
  }

  Future<void> updateLocation(String locationId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('warehouseLocations').doc(locationId).update({
        ...updates,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update location: $e');
    }
  }

  Future<void> updateLocationOccupancy(String locationId, double occupancy) async {
    try {
      await _firestore.collection('warehouseLocations').doc(locationId).update({
        'currentOccupancy': occupancy,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update location occupancy: $e');
    }
  }

  // ==================== ANALYTICS ====================

  Future<WarehouseAnalyticsModel> getWarehouseAnalytics(String warehouseId) async {
    try {
      final inventory = await _firestore
          .collection('inventory')
          .where('warehouseId', isEqualTo: warehouseId)
          .get();
      
      final processingTasks = await _firestore
          .collection('processingTasks')
          .where('warehouseId', isEqualTo: warehouseId)
          .get();

      final totalInventory = inventory.docs.length;
      final processingInventory = inventory.docs
          .where((doc) => doc.data()['status'] == InventoryStatus.processing.toString().split('.').last)
          .length;
      final readyInventory = inventory.docs
          .where((doc) => doc.data()['status'] == InventoryStatus.ready.toString().split('.').last)
          .length;
      final lowStockInventory = inventory.docs
          .where((doc) => doc.data()['status'] == InventoryStatus.lowStock.toString().split('.').last)
          .length;
      final totalWeight = inventory.docs
          .fold<double>(0, (sum, doc) => sum + (doc.data()['actualWeight'] ?? 0));

      final totalTasks = processingTasks.docs.length;
      final completedTasks = processingTasks.docs
          .where((doc) => doc.data()['status'] == TaskStatus.completed.toString().split('.').last)
          .length;
      final pendingTasks = processingTasks.docs
          .where((doc) => doc.data()['status'] == TaskStatus.pending.toString().split('.').last)
          .length;

      // Category distribution
      final categoryDistribution = <String, int>{};
      for (final doc in inventory.docs) {
        final category = doc.data()['fabricCategory'] ?? 'unknown';
        categoryDistribution[category] = (categoryDistribution[category] ?? 0) + 1;
      }

      // Quality grade distribution
      final qualityDistribution = <String, int>{};
      for (final doc in inventory.docs) {
        final grade = doc.data()['qualityGrade'] ?? 'unknown';
        qualityDistribution[grade] = (qualityDistribution[grade] ?? 0) + 1;
      }

      return WarehouseAnalyticsModel(
        totalInventory: totalInventory,
        processingInventory: processingInventory,
        readyInventory: readyInventory,
        totalWeight: totalWeight,
        totalTasks: totalTasks,
        completedTasks: completedTasks,
        pendingTasks: pendingTasks,
        categoryDistribution: categoryDistribution,
        qualityDistribution: qualityDistribution,
        taskCompletionRate: totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0,
      );
    } catch (e) {
      throw Exception('Failed to get warehouse analytics: $e');
    }
  }

  // ==================== BATCH OPERATIONS ====================

  Future<void> processBatch(List<String> itemIds, Map<String, dynamic> processingData) async {
    try {
      final batch = _firestore.batch();
      
      for (final itemId in itemIds) {
        final itemRef = _firestore.collection('inventory').doc(itemId);
        batch.update(itemRef, {
          'status': InventoryStatus.processing.toString().split('.').last,
          'processingData': processingData,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to process batch: $e');
    }
  }

  Future<void> moveToReady(List<String> itemIds) async {
    try {
      final batch = _firestore.batch();
      
      for (final itemId in itemIds) {
        final itemRef = _firestore.collection('inventory').doc(itemId);
        batch.update(itemRef, {
          'status': InventoryStatus.ready.toString().split('.').last,
          'processedDate': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to move items to ready: $e');
    }
  }

  // ==================== INTEGRATION WITH LOGISTICS ====================

  Future<void> notifyLogisticsOfReadyItems(String warehouseId, List<String> itemIds) async {
    try {
      final batch = _firestore.batch();
      
      for (final itemId in itemIds) {
        final notificationRef = _firestore.collection('logisticsNotifications').doc();
        batch.set(notificationRef, {
          'warehouseId': warehouseId,
          'itemId': itemId,
          'type': 'ready_for_pickup',
          'status': 'pending',
          'createdAt': DateTime.now().toIso8601String(),
        });
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to notify logistics: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getLogisticsNotifications(String warehouseId) async {
    try {
      final snapshot = await _firestore
          .collection('logisticsNotifications')
          .where('warehouseId', isEqualTo: warehouseId)
          .where('status', isEqualTo: 'pending')
          .get();
      
      return snapshot.docs
          .map((doc) => {
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              })
          .toList();
    } catch (e) {
      throw Exception('Failed to get logistics notifications: $e');
    }
  }

  // ==================== ADMIN INTEGRATION ====================

  Future<Map<String, dynamic>> getAdminDashboardData(String warehouseId) async {
    try {
      final analytics = await getWarehouseAnalytics(warehouseId);
      final workers = await getWorkers(warehouseId: warehouseId).first;
      final locations = await getLocations(warehouseId: warehouseId).first;
      final lowStockAlerts = await getLowStockAlerts(warehouseId);
      
      return {
        'analytics': analytics.toJson(),
        'workerCount': workers.length,
        'activeWorkers': workers.where((w) => w.isActive).length,
        'locationCount': locations.length,
        'availableLocations': locations.where((l) => l.isAvailable).length,
        'lowStockAlerts': lowStockAlerts.length,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to get admin dashboard data: $e');
    }
  }

  Future<void> sendAdminAlert(String warehouseId, String alertType, String message) async {
    try {
      await _firestore.collection('adminAlerts').add({
        'warehouseId': warehouseId,
        'alertType': alertType,
        'message': message,
        'status': 'unread',
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to send admin alert: $e');
    }
  }
} 