import 'package:flutter_test/flutter_test.dart';
import 'package:refab_app/features/warehouse/data/repositories/warehouse_repository.dart';
import 'package:refab_app/features/warehouse/data/models/inventory_model.dart';
import 'package:refab_app/features/warehouse/data/models/processing_task_model.dart';
import 'package:refab_app/features/warehouse/data/models/warehouse_analytics_model.dart';
import '../../test_helper.dart';

void main() {
  setUpAll(() async {
    await TestHelper.setupFirebaseForTesting();
  });

  group('WarehouseRepository Tests', () {
    late WarehouseRepository repository;
    const testWarehouseId = 'test_warehouse';

    setUp(() {
      print('🏭 [WAREHOUSE_TEST] Setting up test environment...');
      repository = WarehouseRepository();
      print('🏭 [WAREHOUSE_TEST] ✅ Test environment ready.');
    });

    tearDown(() async {
      print('🏭 [WAREHOUSE_TEST] Cleaning up test data...');
      try {
        // Clean up test data if needed
        print('🏭 [WAREHOUSE_TEST] ✅ Cleanup completed.');
      } catch (e) {
        print('🏭 [WAREHOUSE_TEST] ⚠️ Cleanup warning: $e');
      }
    });

    group('Inventory Management', () {
      test('should create inventory item successfully', () async {
        print('🏭 [WAREHOUSE_TEST] Testing inventory item creation...');
        
        final inventoryItem = InventoryModel(
          id: '',
          warehouseId: testWarehouseId,
          pickupId: 'pickup_123',
          fabricCategory: 'cotton',
          qualityGrade: 'A',
          actualWeight: 15.5,
          estimatedWeight: 15.5,
          status: InventoryStatus.processing,
          createdAt: DateTime.now(),
        );

        final itemId = await repository.createInventoryItem(inventoryItem);
        
        expect(itemId, isNotEmpty);
        print('🏭 [WAREHOUSE_TEST] ✅ Inventory item created with ID: $itemId');
      });

      test('should get inventory items successfully', () async {
        print('🏭 [WAREHOUSE_TEST] Testing inventory items retrieval...');
        
        final stream = repository.getInventoryItems(warehouseId: testWarehouseId);
        final items = await stream.first;
        
        expect(items, isA<List<InventoryModel>>());
        print('🏭 [WAREHOUSE_TEST] ✅ Retrieved ${items.length} inventory items');
      });

      test('should update inventory item successfully', () async {
        print('🏭 [WAREHOUSE_TEST] Testing inventory item update...');
        
        // First create an item
        final inventoryItem = InventoryModel(
          id: '',
          warehouseId: testWarehouseId,
          pickupId: 'pickup_456',
          fabricCategory: 'silk',
          qualityGrade: 'B',
          actualWeight: 8.2,
          estimatedWeight: 8.2,
          status: InventoryStatus.processing,
          createdAt: DateTime.now(),
        );

        final itemId = await repository.createInventoryItem(inventoryItem);
        
        // Update the item
        await repository.updateInventoryItem(itemId, {
          'qualityGrade': 'A',
          'status': InventoryStatus.graded.toString().split('.').last,
        });
        
        print('🏭 [WAREHOUSE_TEST] ✅ Inventory item updated successfully');
      });

      test('should update inventory status successfully', () async {
        print('🏭 [WAREHOUSE_TEST] Testing inventory status update...');
        
        final inventoryItem = InventoryModel(
          id: '',
          warehouseId: testWarehouseId,
          pickupId: 'pickup_789',
          fabricCategory: 'polyester',
          qualityGrade: 'C',
          actualWeight: 22.1,
          estimatedWeight: 22.1,
          status: InventoryStatus.processing,
          createdAt: DateTime.now(),
        );

        final itemId = await repository.createInventoryItem(inventoryItem);
        
        await repository.updateInventoryStatus(itemId, InventoryStatus.ready);
        
        print('🏭 [WAREHOUSE_TEST] ✅ Inventory status updated successfully');
      });

      test('should update inventory quantity successfully', () async {
        print('🏭 [WAREHOUSE_TEST] Testing inventory quantity update...');
        
        final inventoryItem = InventoryModel(
          id: '',
          warehouseId: testWarehouseId,
          pickupId: 'pickup_101',
          fabricCategory: 'wool',
          qualityGrade: 'A',
          actualWeight: 5.7,
          estimatedWeight: 5.7,
          status: InventoryStatus.processing,
          createdAt: DateTime.now(),
        );

        final itemId = await repository.createInventoryItem(inventoryItem);
        
        await repository.updateInventoryQuantity(itemId, 6.2);
        
        print('🏭 [WAREHOUSE_TEST] ✅ Inventory quantity updated successfully');
      });

      test('should delete inventory item successfully', () async {
        print('🏭 [WAREHOUSE_TEST] Testing inventory item deletion...');
        
        final inventoryItem = InventoryModel(
          id: '',
          warehouseId: testWarehouseId,
          pickupId: 'pickup_202',
          fabricCategory: 'linen',
          qualityGrade: 'B',
          actualWeight: 12.3,
          estimatedWeight: 12.3,
          status: InventoryStatus.processing,
          createdAt: DateTime.now(),
        );

        final itemId = await repository.createInventoryItem(inventoryItem);
        
        await repository.deleteInventoryItem(itemId);
        
        print('🏭 [WAREHOUSE_TEST] ✅ Inventory item deleted successfully');
      });

      test('should get low stock alerts successfully', () async {
        print('🏭 [WAREHOUSE_TEST] Testing low stock alerts...');
        
        final alerts = await repository.getLowStockAlerts(testWarehouseId);
        
        expect(alerts, isA<List<InventoryModel>>());
        print('🏭 [WAREHOUSE_TEST] ✅ Retrieved ${alerts.length} low stock alerts');
      });

      test('should get inventory by category successfully', () async {
        print('🏭 [WAREHOUSE_TEST] Testing inventory by category...');
        
        final items = await repository.getInventoryByCategory(testWarehouseId, 'cotton');
        
        expect(items, isA<List<InventoryModel>>());
        print('🏭 [WAREHOUSE_TEST] ✅ Retrieved ${items.length} cotton items');
      });
    });

    group('Processing Tasks', () {
      test('should create processing task successfully', () async {
        print('🏭 [WAREHOUSE_TEST] Testing processing task creation...');
        
        final task = ProcessingTaskModel(
          id: '',
          warehouseId: testWarehouseId,
          taskType: TaskType.sorting,
          description: 'Sort cotton fabric by quality',
          inventoryItemIds: ['item1', 'item2'],
          status: TaskStatus.pending,
          priority: TaskPriority.medium,
          createdAt: DateTime.now(),
        );

        final taskId = await repository.createProcessingTask(task);
        
        expect(taskId, isNotEmpty);
        print('🏭 [WAREHOUSE_TEST] ✅ Processing task created with ID: $taskId');
      });

      test('should get processing tasks successfully', () async {
        print('🏭 [WAREHOUSE_TEST] Testing processing tasks retrieval...');
        
        final stream = repository.getProcessingTasks(warehouseId: testWarehouseId);
        final tasks = await stream.first;
        
        expect(tasks, isA<List<ProcessingTaskModel>>());
        print('🏭 [WAREHOUSE_TEST] ✅ Retrieved ${tasks.length} processing tasks');
      });

      test('should update task status successfully', () async {
        print('🏭 [WAREHOUSE_TEST] Testing task status update...');
        
        final task = ProcessingTaskModel(
          id: '',
          warehouseId: testWarehouseId,
          taskType: TaskType.cleaning,
          description: 'Clean silk fabric',
          inventoryItemIds: ['item3'],
          status: TaskStatus.pending,
          priority: TaskPriority.high,
          createdAt: DateTime.now(),
        );

        final taskId = await repository.createProcessingTask(task);
        
        await repository.updateTaskStatus(taskId, TaskStatus.inProgress);
        
        print('🏭 [WAREHOUSE_TEST] ✅ Task status updated successfully');
      });

      test('should assign task to worker successfully', () async {
        print('🏭 [WAREHOUSE_TEST] Testing task assignment...');
        
        final task = ProcessingTaskModel(
          id: '',
          warehouseId: testWarehouseId,
          taskType: TaskType.grading,
          description: 'Grade polyester fabric',
          inventoryItemIds: ['item4'],
          status: TaskStatus.pending,
          priority: TaskPriority.low,
          createdAt: DateTime.now(),
        );

        final taskId = await repository.createProcessingTask(task);
        
        await repository.assignTaskToWorker(taskId, 'worker_123', 'John Doe');
        
        print('🏭 [WAREHOUSE_TEST] ✅ Task assigned successfully');
      });

      test('should complete task successfully', () async {
        print('🏭 [WAREHOUSE_TEST] Testing task completion...');
        
        final task = ProcessingTaskModel(
          id: '',
          warehouseId: testWarehouseId,
          taskType: TaskType.packaging,
          description: 'Package wool fabric',
          inventoryItemIds: ['item5'],
          status: TaskStatus.inProgress,
          priority: TaskPriority.medium,
          createdAt: DateTime.now(),
        );

        final taskId = await repository.createProcessingTask(task);
        
        await repository.completeTask(taskId, {
          'completionNotes': 'Task completed successfully',
          'qualityScore': 95,
        });
        
        print('🏭 [WAREHOUSE_TEST] ✅ Task completed successfully');
      });
    });

    group('Analytics', () {
      test('should get warehouse analytics successfully', () async {
        print('🏭 [WAREHOUSE_TEST] Testing analytics retrieval...');
        
        final analytics = await repository.getWarehouseAnalytics(testWarehouseId);
        
        expect(analytics, isA<WarehouseAnalyticsModel>());
        expect(analytics.totalInventory, isA<int>());
        expect(analytics.totalTasks, isA<int>());
        print('🏭 [WAREHOUSE_TEST] ✅ Analytics retrieved successfully');
      });
    });

    group('Batch Operations', () {
      test('should process batch successfully', () async {
        print('🏭 [WAREHOUSE_TEST] Testing batch processing...');
        
        final itemIds = ['item1', 'item2', 'item3'];
        final processingData = {
          'method': 'standard',
          'temperature': 25,
          'duration': 30,
        };
        
        await repository.processBatch(itemIds, processingData);
        
        print('🏭 [WAREHOUSE_TEST] ✅ Batch processing completed');
      });

      test('should move items to ready successfully', () async {
        print('🏭 [WAREHOUSE_TEST] Testing move to ready...');
        
        final itemIds = ['item4', 'item5'];
        
        await repository.moveToReady(itemIds);
        
        print('🏭 [WAREHOUSE_TEST] ✅ Items moved to ready successfully');
      });
    });

    group('Integration', () {
      test('should notify logistics successfully', () async {
        print('🏭 [WAREHOUSE_TEST] Testing logistics notification...');
        
        final itemIds = ['item6', 'item7'];
        
        await repository.notifyLogisticsOfReadyItems(testWarehouseId, itemIds);
        
        print('🏭 [WAREHOUSE_TEST] ✅ Logistics notified successfully');
      });

      test('should get logistics notifications successfully', () async {
        print('🏭 [WAREHOUSE_TEST] Testing logistics notifications retrieval...');
        
        final notifications = await repository.getLogisticsNotifications(testWarehouseId);
        
        expect(notifications, isA<List<Map<String, dynamic>>>());
        print('🏭 [WAREHOUSE_TEST] ✅ Retrieved ${notifications.length} logistics notifications');
      });

      test('should get admin dashboard data successfully', () async {
        print('🏭 [WAREHOUSE_TEST] Testing admin dashboard data...');
        
        final dashboardData = await repository.getAdminDashboardData(testWarehouseId);
        
        expect(dashboardData, isA<Map<String, dynamic>>());
        expect(dashboardData['analytics'], isA<Map<String, dynamic>>());
        print('🏭 [WAREHOUSE_TEST] ✅ Admin dashboard data retrieved successfully');
      });

      test('should send admin alert successfully', () async {
        print('🏭 [WAREHOUSE_TEST] Testing admin alert...');
        
        await repository.sendAdminAlert(testWarehouseId, 'low_stock', 'Cotton fabric running low');
        
        print('🏭 [WAREHOUSE_TEST] ✅ Admin alert sent successfully');
      });
    });
  });
} 