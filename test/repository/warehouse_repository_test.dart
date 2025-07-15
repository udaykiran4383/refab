import 'package:flutter_test/flutter_test.dart';
import 'package:refab_app/features/warehouse/data/repositories/warehouse_repository.dart';
import 'package:refab_app/features/warehouse/data/models/inventory_model.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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
  });
} 