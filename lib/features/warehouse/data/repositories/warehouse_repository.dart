import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/inventory_model.dart';
import '../models/processing_task_model.dart';
import '../models/warehouse_analytics_model.dart';

class WarehouseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Inventory Management
  Future<String> createInventoryItem(InventoryModel item) async {
    try {
      final docRef = await _firestore.collection('inventory').add(item.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create inventory item: $e');
    }
  }

  Stream<List<InventoryModel>> getInventoryItems({String? status, String? category}) {
    Query query = _firestore.collection('inventory');
    
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }
    
    if (category != null) {
      query = query.where('fabricCategory', isEqualTo: category);
    }
    
    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InventoryModel.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }

  Future<InventoryModel?> getInventoryItem(String itemId) async {
    try {
      final doc = await _firestore.collection('inventory').doc(itemId).get();
      if (doc.exists) {
        return InventoryModel.fromJson({
          ...doc.data()!,
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

  // Processing Tasks
  Future<String> createProcessingTask(ProcessingTaskModel task) async {
    try {
      final docRef = await _firestore.collection('processingTasks').add(task.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create processing task: $e');
    }
  }

  Stream<List<ProcessingTaskModel>> getProcessingTasks({String? status, String? workerId}) {
    Query query = _firestore.collection('processingTasks');
    
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }
    
    if (workerId != null) {
      query = query.where('assignedWorkerId', isEqualTo: workerId);
    }
    
    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProcessingTaskModel.fromJson({
                  ...doc.data(),
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

  Future<void> assignTaskToWorker(String taskId, String workerId) async {
    try {
      await _firestore.collection('processingTasks').doc(taskId).update({
        'assignedWorkerId': workerId,
        'status': 'assigned',
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to assign task to worker: $e');
    }
  }

  Future<void> completeTask(String taskId, Map<String, dynamic> completionData) async {
    try {
      await _firestore.collection('processingTasks').doc(taskId).update({
        'status': 'completed',
        'completionData': completionData,
        'completedAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to complete task: $e');
    }
  }

  // Analytics
  Future<WarehouseAnalyticsModel> getWarehouseAnalytics() async {
    try {
      final inventory = await _firestore.collection('inventory').get();
      final processingTasks = await _firestore.collection('processingTasks').get();

      final totalInventory = inventory.docs.length;
      final processingInventory = inventory.docs
          .where((doc) => doc.data()['status'] == 'processing')
          .length;
      final readyInventory = inventory.docs
          .where((doc) => doc.data()['status'] == 'ready')
          .length;
      final totalWeight = inventory.docs
          .fold<double>(0, (sum, doc) => sum + (doc.data()['actualWeight'] ?? 0));

      final totalTasks = processingTasks.docs.length;
      final completedTasks = processingTasks.docs
          .where((doc) => doc.data()['status'] == 'completed')
          .length;
      final pendingTasks = processingTasks.docs
          .where((doc) => doc.data()['status'] == 'pending')
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

  // Location Management
  Future<void> updateWarehouseLocation(String itemId, String location) async {
    try {
      await _firestore.collection('inventory').doc(itemId).update({
        'warehouseLocation': location,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update warehouse location: $e');
    }
  }

  Stream<List<String>> getWarehouseLocations() {
    return _firestore
        .collection('inventory')
        .snapshots()
        .map((snapshot) {
          final locations = <String>{};
          for (final doc in snapshot.docs) {
            final location = doc.data()['warehouseLocation'];
            if (location != null && location.isNotEmpty) {
              locations.add(location);
            }
          }
          return locations.toList()..sort();
        });
  }

  // Quality Control
  Future<void> updateQualityGrade(String itemId, String grade) async {
    try {
      await _firestore.collection('inventory').doc(itemId).update({
        'qualityGrade': grade,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update quality grade: $e');
    }
  }

  // Batch Operations
  Future<void> processBatch(List<String> itemIds, Map<String, dynamic> processingData) async {
    try {
      final batch = _firestore.batch();
      
      for (final itemId in itemIds) {
        final itemRef = _firestore.collection('inventory').doc(itemId);
        batch.update(itemRef, {
          'status': 'processing',
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
          'status': 'ready',
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to move items to ready: $e');
    }
  }
} 