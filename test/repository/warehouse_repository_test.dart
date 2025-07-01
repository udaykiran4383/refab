import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:refab_app/features/warehouse/data/repositories/warehouse_repository.dart';
import 'package:refab_app/features/warehouse/data/models/inventory_model.dart';
import 'package:refab_app/features/warehouse/data/models/processing_task_model.dart';
import 'package:refab_app/features/warehouse/data/models/warehouse_analytics_model.dart';

void main() {
  group('WarehouseRepository Tests', () {
    late WarehouseRepository repository;
    late String testWarehouseId;

    setUpAll(() async {
      print('🏭 [WAREHOUSE_TEST] Setting up Firebase for testing...');
      TestWidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
      print('🏭 [WAREHOUSE_TEST] ✅ Firebase initialized');
    });

    setUp(() {
      print('🏭 [WAREHOUSE_TEST] Setting up test environment...');
      repository = WarehouseRepository();
      testWarehouseId = 'test_warehouse_${DateTime.now().millisecondsSinceEpoch}';
      print('🏭 [WAREHOUSE_TEST] ✅ Test environment ready. Warehouse ID: $testWarehouseId');
    });

    tearDown(() async {
      print('🏭 [WAREHOUSE_TEST] Cleaning up test data...');
      try {
        // Clean up test data
        final inventory = await FirebaseFirestore.instance
            .collection('inventory')
            .where('warehouseId', isEqualTo: testWarehouseId)
            .get();
        
        final tasks = await FirebaseFirestore.instance
            .collection('processingTasks')
            .where('warehouseId', isEqualTo: testWarehouseId)
            .get();
        
        final batch = FirebaseFirestore.instance.batch();
        for (var doc in inventory.docs) {
          batch.delete(doc.reference);
        }
        for (var doc in tasks.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        print('🏭 [WAREHOUSE_TEST] ✅ Test data cleaned up');
      } catch (e) {
        print('🏭 [WAREHOUSE_TEST] ⚠️ Cleanup warning: $e');
      }
    });

    group('Inventory CRUD Operations', () {
      test('should create inventory item successfully', () async {
        print('🏭 [WAREHOUSE_TEST] Testing inventory item creation...');
        
        final inventoryItem = InventoryModel(
          id: '',
          warehouseId: testWarehouseId,
          productName: 'Test Fabric',
          category: 'Cotton',
          quantity: 100.5,
          unit: 'kg',
          location: 'A1-B2-C3',
          status: InventoryStatus.available,
          lastUpdated: DateTime.now(),
          createdAt: DateTime.now(),
        );

        print('🏭 [WAREHOUSE_TEST] Creating inventory item: ${inventoryItem.productName}');
        print('   - Quantity: ${inventoryItem.quantity} ${inventoryItem.unit}');
        print('   - Location: ${inventoryItem.location}');
        
        final itemId = await repository.createInventoryItem(inventoryItem);
        
        print('🏭 [WAREHOUSE_TEST] ✅ Inventory item created with ID: $itemId');
        expect(itemId, isNotEmpty);
        expect(itemId.length, greaterThan(0));
      });

      test('should get inventory items', () async {
        print('🏭 [WAREHOUSE_TEST] Testing inventory retrieval...');
        
        // Create test inventory items
        final item1 = InventoryModel(
          id: '',
          warehouseId: testWarehouseId,
          productName: 'Silk Fabric',
          category: 'Silk',
          quantity: 50.0,
          unit: 'kg',
          location: 'A1-B1-C1',
          status: InventoryStatus.available,
          lastUpdated: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final item2 = InventoryModel(
          id: '',
          warehouseId: testWarehouseId,
          productName: 'Wool Fabric',
          category: 'Wool',
          quantity: 75.0,
          unit: 'kg',
          location: 'A2-B2-C2',
          status: InventoryStatus.lowStock,
          lastUpdated: DateTime.now(),
          createdAt: DateTime.now(),
        );

        print('🏭 [WAREHOUSE_TEST] Creating test inventory items...');
        await repository.createInventoryItem(item1);
        await repository.createInventoryItem(item2);

        print('🏭 [WAREHOUSE_TEST] Fetching inventory items...');
        final items = await repository.getInventoryItems(testWarehouseId).first;
        
        print('🏭 [WAREHOUSE_TEST] ✅ Retrieved ${items.length} inventory items');
        expect(items.length, greaterThanOrEqualTo(2));
        
        final availableItems = items.where((i) => i.status == InventoryStatus.available).length;
        final lowStockItems = items.where((i) => i.status == InventoryStatus.lowStock).length;
        
        print('🏭 [WAREHOUSE_TEST] 📊 Available: $availableItems, Low Stock: $lowStockItems');
        expect(availableItems, greaterThanOrEqualTo(1));
        expect(lowStockItems, greaterThanOrEqualTo(1));
      });

      test('should update inventory quantity', () async {
        print('🏭 [WAREHOUSE_TEST] Testing inventory quantity update...');
        
        final inventoryItem = InventoryModel(
          id: '',
          warehouseId: testWarehouseId,
          productName: 'Linen Fabric',
          category: 'Linen',
          quantity: 200.0,
          unit: 'kg',
          location: 'A3-B3-C3',
          status: InventoryStatus.available,
          lastUpdated: DateTime.now(),
          createdAt: DateTime.now(),
        );

        print('🏭 [WAREHOUSE_TEST] Creating inventory item for quantity update...');
        final itemId = await repository.createInventoryItem(inventoryItem);
        
        print('🏭 [WAREHOUSE_TEST] Updating quantity to 150kg...');
        await repository.updateInventoryQuantity(itemId, 150.0);
        
        final items = await repository.getInventoryItems(testWarehouseId).first;
        final updatedItem = items.firstWhere((i) => i.id == itemId);
        
        print('🏭 [WAREHOUSE_TEST] ✅ Quantity updated successfully');
        print('   - New Quantity: ${updatedItem.quantity} ${updatedItem.unit}');
        expect(updatedItem.quantity, equals(150.0));
      });

      test('should update inventory status', () async {
        print('🏭 [WAREHOUSE_TEST] Testing inventory status update...');
        
        final inventoryItem = InventoryModel(
          id: '',
          warehouseId: testWarehouseId,
          productName: 'Denim Fabric',
          category: 'Denim',
          quantity: 10.0,
          unit: 'kg',
          location: 'A4-B4-C4',
          status: InventoryStatus.available,
          lastUpdated: DateTime.now(),
          createdAt: DateTime.now(),
        );

        print('🏭 [WAREHOUSE_TEST] Creating inventory item for status update...');
        final itemId = await repository.createInventoryItem(inventoryItem);
        
        print('🏭 [WAREHOUSE_TEST] Updating status to low stock...');
        await repository.updateInventoryStatus(itemId, InventoryStatus.lowStock);
        
        final items = await repository.getInventoryItems(testWarehouseId).first;
        final updatedItem = items.firstWhere((i) => i.id == itemId);
        
        print('🏭 [WAREHOUSE_TEST] ✅ Status updated successfully');
        print('   - New Status: ${updatedItem.status}');
        expect(updatedItem.status, equals(InventoryStatus.lowStock));
      });

      test('should delete inventory item', () async {
        print('🏭 [WAREHOUSE_TEST] Testing inventory item deletion...');
        
        final inventoryItem = InventoryModel(
          id: '',
          warehouseId: testWarehouseId,
          productName: 'Test Fabric for Deletion',
          category: 'Test',
          quantity: 25.0,
          unit: 'kg',
          location: 'A5-B5-C5',
          status: InventoryStatus.available,
          lastUpdated: DateTime.now(),
          createdAt: DateTime.now(),
        );

        print('🏭 [WAREHOUSE_TEST] Creating inventory item for deletion...');
        final itemId = await repository.createInventoryItem(inventoryItem);
        
        print('🏭 [WAREHOUSE_TEST] Deleting inventory item...');
        await repository.deleteInventoryItem(itemId);
        
        final items = await repository.getInventoryItems(testWarehouseId).first;
        final deletedItem = items.where((i) => i.id == itemId);
        
        print('🏭 [WAREHOUSE_TEST] ✅ Inventory item deleted successfully');
        expect(deletedItem.isEmpty, isTrue);
      });
    });

    group('Processing Task CRUD Operations', () {
      test('should create processing task successfully', () async {
        print('🏭 [WAREHOUSE_TEST] Testing processing task creation...');
        
        final task = ProcessingTaskModel(
          id: '',
          warehouseId: testWarehouseId,
          taskType: TaskType.sorting,
          description: 'Sort cotton fabrics by quality',
          assignedTo: 'worker_1',
          priority: TaskPriority.high,
          status: TaskStatus.pending,
          estimatedDuration: Duration(hours: 2),
          createdAt: DateTime.now(),
        );

        print('🏭 [WAREHOUSE_TEST] Creating processing task: ${task.description}');
        print('   - Type: ${task.taskType}');
        print('   - Priority: ${task.priority}');
        print('   - Estimated Duration: ${task.estimatedDuration.inHours} hours');
        
        final taskId = await repository.createProcessingTask(task);
        
        print('🏭 [WAREHOUSE_TEST] ✅ Processing task created with ID: $taskId');
        expect(taskId, isNotEmpty);
        expect(taskId.length, greaterThan(0));
      });

      test('should get processing tasks', () async {
        print('🏭 [WAREHOUSE_TEST] Testing processing tasks retrieval...');
        
        // Create test tasks
        final task1 = ProcessingTaskModel(
          id: '',
          warehouseId: testWarehouseId,
          taskType: TaskType.cleaning,
          description: 'Clean silk fabrics',
          assignedTo: 'worker_2',
          priority: TaskPriority.medium,
          status: TaskStatus.inProgress,
          estimatedDuration: Duration(hours: 1),
          createdAt: DateTime.now(),
        );

        final task2 = ProcessingTaskModel(
          id: '',
          warehouseId: testWarehouseId,
          taskType: TaskType.packaging,
          description: 'Package wool fabrics',
          assignedTo: 'worker_3',
          priority: TaskPriority.low,
          status: TaskStatus.completed,
          estimatedDuration: Duration(hours: 3),
          createdAt: DateTime.now(),
        );

        print('🏭 [WAREHOUSE_TEST] Creating test processing tasks...');
        await repository.createProcessingTask(task1);
        await repository.createProcessingTask(task2);

        print('🏭 [WAREHOUSE_TEST] Fetching processing tasks...');
        final tasks = await repository.getProcessingTasks(testWarehouseId).first;
        
        print('🏭 [WAREHOUSE_TEST] ✅ Retrieved ${tasks.length} processing tasks');
        expect(tasks.length, greaterThanOrEqualTo(2));
        
        final pendingTasks = tasks.where((t) => t.status == TaskStatus.pending).length;
        final inProgressTasks = tasks.where((t) => t.status == TaskStatus.inProgress).length;
        final completedTasks = tasks.where((t) => t.status == TaskStatus.completed).length;
        
        print('🏭 [WAREHOUSE_TEST] 📊 Pending: $pendingTasks, In Progress: $inProgressTasks, Completed: $completedTasks');
        expect(pendingTasks, greaterThanOrEqualTo(1));
        expect(inProgressTasks, greaterThanOrEqualTo(1));
        expect(completedTasks, greaterThanOrEqualTo(1));
      });

      test('should update task status', () async {
        print('🏭 [WAREHOUSE_TEST] Testing task status update...');
        
        final task = ProcessingTaskModel(
          id: '',
          warehouseId: testWarehouseId,
          taskType: TaskType.sorting,
          description: 'Sort fabrics by color',
          assignedTo: 'worker_4',
          priority: TaskPriority.medium,
          status: TaskStatus.pending,
          estimatedDuration: Duration(hours: 1),
          createdAt: DateTime.now(),
        );

        print('🏭 [WAREHOUSE_TEST] Creating task for status update...');
        final taskId = await repository.createProcessingTask(task);
        
        print('🏭 [WAREHOUSE_TEST] Updating status to in progress...');
        await repository.updateTaskStatus(taskId, TaskStatus.inProgress);
        
        final tasks = await repository.getProcessingTasks(testWarehouseId).first;
        final updatedTask = tasks.firstWhere((t) => t.id == taskId);
        
        print('🏭 [WAREHOUSE_TEST] ✅ Task status updated successfully');
        print('   - New Status: ${updatedTask.status}');
        expect(updatedTask.status, equals(TaskStatus.inProgress));
      });

      test('should assign task to worker', () async {
        print('🏭 [WAREHOUSE_TEST] Testing task assignment...');
        
        final task = ProcessingTaskModel(
          id: '',
          warehouseId: testWarehouseId,
          taskType: TaskType.cleaning,
          description: 'Clean cotton fabrics',
          assignedTo: '',
          priority: TaskPriority.low,
          status: TaskStatus.pending,
          estimatedDuration: Duration(hours: 2),
          createdAt: DateTime.now(),
        );

        print('🏭 [WAREHOUSE_TEST] Creating unassigned task...');
        final taskId = await repository.createProcessingTask(task);
        
        print('🏭 [WAREHOUSE_TEST] Assigning task to worker_5...');
        await repository.assignTaskToWorker(taskId, 'worker_5');
        
        final tasks = await repository.getProcessingTasks(testWarehouseId).first;
        final assignedTask = tasks.firstWhere((t) => t.id == taskId);
        
        print('🏭 [WAREHOUSE_TEST] ✅ Task assigned successfully');
        print('   - Assigned To: ${assignedTask.assignedTo}');
        expect(assignedTask.assignedTo, equals('worker_5'));
      });
    });

    group('Analytics Operations', () {
      test('should get warehouse analytics', () async {
        print('🏭 [WAREHOUSE_TEST] Testing warehouse analytics...');
        
        // Create test data for analytics
        final inventoryItem1 = InventoryModel(
          id: '',
          warehouseId: testWarehouseId,
          productName: 'Analytics Test Fabric 1',
          category: 'Cotton',
          quantity: 100.0,
          unit: 'kg',
          location: 'A1-B1-C1',
          status: InventoryStatus.available,
          lastUpdated: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final inventoryItem2 = InventoryModel(
          id: '',
          warehouseId: testWarehouseId,
          productName: 'Analytics Test Fabric 2',
          category: 'Silk',
          quantity: 50.0,
          unit: 'kg',
          location: 'A2-B2-C2',
          status: InventoryStatus.lowStock,
          lastUpdated: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final task1 = ProcessingTaskModel(
          id: '',
          warehouseId: testWarehouseId,
          taskType: TaskType.sorting,
          description: 'Analytics test task 1',
          assignedTo: 'worker_1',
          priority: TaskPriority.high,
          status: TaskStatus.completed,
          estimatedDuration: Duration(hours: 2),
          createdAt: DateTime.now(),
        );

        final task2 = ProcessingTaskModel(
          id: '',
          warehouseId: testWarehouseId,
          taskType: TaskType.cleaning,
          description: 'Analytics test task 2',
          assignedTo: 'worker_2',
          priority: TaskPriority.medium,
          status: TaskStatus.inProgress,
          estimatedDuration: Duration(hours: 1),
          createdAt: DateTime.now(),
        );

        print('🏭 [WAREHOUSE_TEST] Creating test data for analytics...');
        await repository.createInventoryItem(inventoryItem1);
        await repository.createInventoryItem(inventoryItem2);
        await repository.createProcessingTask(task1);
        await repository.createProcessingTask(task2);

        print('🏭 [WAREHOUSE_TEST] Fetching warehouse analytics...');
        final analytics = await repository.getWarehouseAnalytics(testWarehouseId);
        
        print('🏭 [WAREHOUSE_TEST] 📊 Warehouse Analytics:');
        print('   - Total Inventory Items: ${analytics['totalInventoryItems']}');
        print('   - Total Quantity: ${analytics['totalQuantity']}kg');
        print('   - Low Stock Items: ${analytics['lowStockItems']}');
        print('   - Total Tasks: ${analytics['totalTasks']}');
        print('   - Completed Tasks: ${analytics['completedTasks']}');
        print('   - Pending Tasks: ${analytics['pendingTasks']}');
        print('   - Task Completion Rate: ${analytics['taskCompletionRate']}%');
        
        expect(analytics['totalInventoryItems'], greaterThanOrEqualTo(2));
        expect(analytics['totalQuantity'], greaterThanOrEqualTo(100.0));
        expect(analytics['lowStockItems'], greaterThanOrEqualTo(1));
        expect(analytics['totalTasks'], greaterThanOrEqualTo(2));
        expect(analytics['completedTasks'], greaterThanOrEqualTo(1));
        expect(analytics['pendingTasks'], greaterThanOrEqualTo(1));
        expect(analytics['taskCompletionRate'], greaterThan(0));
        
        print('🏭 [WAREHOUSE_TEST] ✅ Warehouse analytics retrieved successfully');
      });
    });

    group('Inventory Management', () {
      test('should get low stock alerts', () async {
        print('🏭 [WAREHOUSE_TEST] Testing low stock alerts...');
        
        // Create low stock items
        final lowStockItem1 = InventoryModel(
          id: '',
          warehouseId: testWarehouseId,
          productName: 'Low Stock Fabric 1',
          category: 'Cotton',
          quantity: 5.0,
          unit: 'kg',
          location: 'A1-B1-C1',
          status: InventoryStatus.lowStock,
          lastUpdated: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final lowStockItem2 = InventoryModel(
          id: '',
          warehouseId: testWarehouseId,
          productName: 'Low Stock Fabric 2',
          category: 'Silk',
          quantity: 2.5,
          unit: 'kg',
          location: 'A2-B2-C2',
          status: InventoryStatus.lowStock,
          lastUpdated: DateTime.now(),
          createdAt: DateTime.now(),
        );

        print('🏭 [WAREHOUSE_TEST] Creating low stock items...');
        await repository.createInventoryItem(lowStockItem1);
        await repository.createInventoryItem(lowStockItem2);

        print('🏭 [WAREHOUSE_TEST] Fetching low stock alerts...');
        final alerts = await repository.getLowStockAlerts(testWarehouseId);
        
        print('🏭 [WAREHOUSE_TEST] ⚠️ Low Stock Alerts:');
        print('   - Total Alerts: ${alerts.length}');
        
        for (final alert in alerts) {
          print('   - ${alert.productName}: ${alert.quantity} ${alert.unit}');
          expect(alert.status, equals(InventoryStatus.lowStock));
          expect(alert.quantity, lessThan(10.0));
        }
        
        expect(alerts.length, greaterThanOrEqualTo(2));
        print('🏭 [WAREHOUSE_TEST] ✅ Low stock alerts retrieved successfully');
      });

      test('should get inventory by category', () async {
        print('🏭 [WAREHOUSE_TEST] Testing inventory filtering by category...');
        
        print('🏭 [WAREHOUSE_TEST] Fetching cotton inventory...');
        final cottonItems = await repository.getInventoryByCategory(testWarehouseId, 'Cotton');
        
        print('🏭 [WAREHOUSE_TEST] 📦 Cotton Inventory:');
        print('   - Total Items: ${cottonItems.length}');
        
        for (final item in cottonItems) {
          expect(item.category, equals('Cotton'));
          print('   - ${item.productName}: ${item.quantity} ${item.unit}');
        }
        
        print('🏭 [WAREHOUSE_TEST] ✅ Category-based inventory retrieval successful');
      });
    });

    group('Error Handling', () {
      test('should handle invalid inventory creation', () async {
        print('🏭 [WAREHOUSE_TEST] Testing error handling for invalid inventory...');
        
        try {
          await repository.createInventoryItem(InventoryModel(
            id: '',
            warehouseId: '', // Invalid empty warehouse ID
            productName: '',
            category: '',
            quantity: -1, // Invalid negative quantity
            unit: '',
            location: '',
            status: InventoryStatus.available,
            lastUpdated: DateTime.now(),
            createdAt: DateTime.now(),
          ));
          
          fail('Should have thrown an exception');
        } catch (e) {
          print('🏭 [WAREHOUSE_TEST] ✅ Error handled correctly: $e');
          expect(e, isA<Exception>());
        }
      });

      test('should handle non-existent task operations', () async {
        print('🏭 [WAREHOUSE_TEST] Testing error handling for non-existent tasks...');
        
        try {
          await repository.updateTaskStatus('non_existent_task_id', TaskStatus.completed);
          fail('Should have thrown an exception');
        } catch (e) {
          print('🏭 [WAREHOUSE_TEST] ✅ Error handled correctly: $e');
          expect(e, isA<Exception>());
        }
      });
    });

    group('Performance Tests', () {
      test('should handle large inventory dataset', () async {
        print('🏭 [WAREHOUSE_TEST] Testing performance with large inventory...');
        
        print('🏭 [WAREHOUSE_TEST] Fetching all inventory items (performance test)...');
        final startTime = DateTime.now();
        
        final items = await repository.getInventoryItems(testWarehouseId).first;
        
        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);
        
        print('🏭 [WAREHOUSE_TEST] ⚡ Performance Results:');
        print('   - Items Retrieved: ${items.length}');
        print('   - Duration: ${duration.inMilliseconds}ms');
        print('   - Average Time per Item: ${duration.inMilliseconds / items.length}ms');
        
        expect(duration.inMilliseconds, lessThan(3000)); // Should complete within 3 seconds
        print('🏭 [WAREHOUSE_TEST] ✅ Performance test passed');
      });

      test('should handle concurrent operations', () async {
        print('🏭 [WAREHOUSE_TEST] Testing concurrent operations...');
        
        final futures = <Future>[];
        
        for (int i = 0; i < 3; i++) {
          final inventoryItem = InventoryModel(
            id: '',
            warehouseId: testWarehouseId,
            productName: 'Concurrent Test Fabric $i',
            category: 'Test',
            quantity: 50.0 + i * 10,
            unit: 'kg',
            location: 'A$i-B$i-C$i',
            status: InventoryStatus.available,
            lastUpdated: DateTime.now(),
            createdAt: DateTime.now(),
          );
          
          futures.add(repository.createInventoryItem(inventoryItem));
        }

        print('🏭 [WAREHOUSE_TEST] Executing 3 concurrent inventory creations...');
        final results = await Future.wait(futures);
        
        print('🏭 [WAREHOUSE_TEST] ✅ All concurrent operations completed');
        expect(results.length, equals(3));
        
        for (int i = 0; i < results.length; i++) {
          expect(results[i], isNotEmpty);
          print('🏭 [WAREHOUSE_TEST]   - Inventory item $i created with ID: ${results[i]}');
        }
      });
    });
  });
} 