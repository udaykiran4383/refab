import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:refab_app/features/warehouse/data/repositories/warehouse_repository.dart';
import 'package:refab_app/features/warehouse/data/models/inventory_model.dart';
import 'package:refab_app/features/warehouse/data/models/warehouse_worker_model.dart';
import 'package:refab_app/features/warehouse/data/models/warehouse_assignment_model.dart';

// Repository Provider
final warehouseRepositoryProvider = Provider<WarehouseRepository>((ref) {
  return WarehouseRepository();
});

// Warehouse ID Provider (for multi-warehouse support)
final warehouseIdProvider = StateProvider<String>((ref) => 'main_warehouse');

// ==================== WAREHOUSE DETAIL PROVIDERS ====================

// Provider to get warehouse details by ID - THIS WAS MISSING!
final warehouseByIdProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, warehouseId) async {
  print('🏭 [WAREHOUSE_PROVIDER] Fetching warehouse details for ID: $warehouseId');
  try {
    final repository = ref.read(warehouseRepositoryProvider);
    final warehouseData = await repository.getWarehouseDetails(warehouseId);
    if (warehouseData != null) {
      print('🏭 [WAREHOUSE_PROVIDER] Found warehouse: ${warehouseData['name']}');
      return warehouseData;
    }
    print('🏭 [WAREHOUSE_PROVIDER] Warehouse not found: $warehouseId');
    return null;
  } catch (e) {
    print('🏭 [WAREHOUSE_PROVIDER] Error fetching warehouse: $e');
    return null;
  }
});

// Provider to get all available warehouses
final availableWarehousesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  print('🏭 [WAREHOUSE_PROVIDER] Fetching all available warehouses');
  try {
    final repository = ref.read(warehouseRepositoryProvider);
    final warehouses = await repository.getAvailableWarehouses();
    print('🏭 [WAREHOUSE_PROVIDER] Found ${warehouses.length} available warehouses');
    return warehouses;
  } catch (e) {
    print('🏭 [WAREHOUSE_PROVIDER] Error fetching available warehouses: $e');
    rethrow;
  }
});

// Real-time provider for logistics assignments with warehouse data
final logisticsAssignmentsWithWarehouseProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, warehouseId) {
  print('🏭 [WAREHOUSE_PROVIDER] Setting up real-time logistics assignments stream for warehouse: $warehouseId');
  try {
    final repository = ref.read(warehouseRepositoryProvider);
    return repository.getLogisticsAssignmentsStream(warehouseId);
  } catch (e) {
    print('🏭 [WAREHOUSE_PROVIDER] Error setting up logistics assignments stream: $e');
    rethrow;
  }
});

// ==================== INVENTORY PROVIDERS ====================

final inventoryItemsProvider = StreamProvider.family<List<InventoryModel>, String>((ref, warehouseId) {
  final repository = ref.watch(warehouseRepositoryProvider);
  return repository.getInventoryItems(warehouseId: warehouseId);
});

final inventoryItemProvider = FutureProvider.family<InventoryModel?, String>((ref, itemId) async {
  final repository = ref.watch(warehouseRepositoryProvider);
  return await repository.getInventoryItem(itemId);
});

final inventoryByStatusProvider = StreamProvider.family<List<InventoryModel>, Map<String, String>>((ref, filters) {
  final repository = ref.watch(warehouseRepositoryProvider);
  return repository.getInventoryItems(
    warehouseId: filters['warehouseId'],
    status: filters['status'],
    fabricCategory: filters['fabricCategory'],
    qualityGrade: filters['qualityGrade'],
  );
});

final lowStockAlertsProvider = FutureProvider.family<List<InventoryModel>, String>((ref, warehouseId) async {
  final repository = ref.watch(warehouseRepositoryProvider);
  return await repository.getLowStockAlerts(warehouseId);
});

final inventoryByCategoryProvider = FutureProvider.family<List<InventoryModel>, Map<String, String>>((ref, params) async {
  final repository = ref.watch(warehouseRepositoryProvider);
  return await repository.getInventoryByCategory(params['warehouseId']!, params['category']!);
});

// ==================== WORKER PROVIDERS ====================

final warehouseWorkersProvider = StreamProvider.family<List<WarehouseWorkerModel>, String>((ref, warehouseId) {
  final repository = ref.watch(warehouseRepositoryProvider);
  return repository.getWorkers(warehouseId: warehouseId);
});

final activeWorkersProvider = StreamProvider.family<List<WarehouseWorkerModel>, String>((ref, warehouseId) {
  final repository = ref.watch(warehouseRepositoryProvider);
  return repository.getWorkers(warehouseId: warehouseId, status: 'active')
      .map((workers) => workers.where((worker) => worker.isActive).toList());
});

final workersByRoleProvider = StreamProvider.family<List<WarehouseWorkerModel>, Map<String, dynamic>>((ref, filters) {
  final repository = ref.watch(warehouseRepositoryProvider);
  return repository.getWorkers(
    warehouseId: filters['warehouseId'],
    status: filters['status'],
    role: filters['role'],
  );
});

// ==================== WAREHOUSE NOTIFIER ====================

class WarehouseNotifier extends StateNotifier<AsyncValue<void>> {
  final WarehouseRepository _repository;
  final Ref _ref;

  WarehouseNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  // Inventory Operations
  Future<void> createInventoryItem(InventoryModel item) async {
    state = const AsyncValue.loading();
    try {
      await _repository.createInventoryItem(item);
      _ref.invalidate(inventoryItemsProvider(item.warehouseId));
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateInventoryItem(String itemId, Map<String, dynamic> updates) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateInventoryItem(itemId, updates);
      _ref.invalidate(inventoryItemProvider(itemId));
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateInventoryStatus(String itemId, InventoryStatus status) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateInventoryStatus(itemId, status);
      _ref.invalidate(inventoryItemProvider(itemId));
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateInventoryQuantity(String itemId, double newWeight) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateInventoryQuantity(itemId, newWeight);
      _ref.invalidate(inventoryItemProvider(itemId));
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteInventoryItem(String itemId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteInventoryItem(itemId);
      _ref.invalidate(inventoryItemProvider(itemId));
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Worker Operations
  Future<void> createWorker(WarehouseWorkerModel worker) async {
    state = const AsyncValue.loading();
    try {
      await _repository.createWorker(worker);
      _ref.invalidate(warehouseWorkersProvider(worker.warehouseId));
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateWorker(String workerId, Map<String, dynamic> updates) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateWorker(workerId, updates);
      _ref.invalidate(warehouseWorkersProvider('main_warehouse'));
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateWorkerPerformance(String workerId, Map<String, dynamic> metrics) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateWorkerPerformance(workerId, metrics);
      _ref.invalidate(warehouseWorkersProvider('main_warehouse'));
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Refresh Operations
  Future<void> refreshInventory(String warehouseId) async {
    _ref.invalidate(inventoryItemsProvider(warehouseId));
  }

  Future<void> refreshWorkers(String warehouseId) async {
    _ref.invalidate(warehouseWorkersProvider(warehouseId));
  }

  // ==================== WAREHOUSE ASSIGNMENT OPERATIONS ====================

  Future<String> createWarehouseAssignment(WarehouseAssignmentModel assignment) async {
    state = const AsyncValue.loading();
    try {
      final assignmentId = await _repository.createWarehouseAssignment(assignment);
      _ref.invalidate(warehouseAssignmentsProvider(assignment.warehouseId));
      state = const AsyncValue.data(null);
      return assignmentId;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> updateAssignmentStatus(String assignmentId, WarehouseAssignmentStatus status) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateAssignmentStatus(assignmentId, status);
      _ref.invalidate(warehouseAssignmentsProvider('main_warehouse'));
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> markAssignmentArrived(String assignmentId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.markAssignmentArrived(assignmentId, DateTime.now());
      _ref.invalidate(warehouseAssignmentsProvider('main_warehouse'));
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addAssignmentNotes(String assignmentId, String notes) async {
    state = const AsyncValue.loading();
    try {
      await _repository.addAssignmentNotes(assignmentId, notes);
      _ref.invalidate(warehouseAssignmentsProvider('main_warehouse'));
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateAssignmentSection(String assignmentId, WarehouseSection section) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateAssignmentSection(assignmentId, section);
      _ref.invalidate(warehouseAssignmentsProvider('main_warehouse'));
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refreshAssignments(String warehouseId) async {
    _ref.invalidate(warehouseAssignmentsProvider(warehouseId));
  }
}

// ==================== WAREHOUSE ASSIGNMENT PROVIDERS ====================

final warehouseAssignmentsProvider = StreamProvider.family<List<WarehouseAssignmentModel>, String>((ref, warehouseId) {
  final repository = ref.watch(warehouseRepositoryProvider);
  if (warehouseId == 'all') {
    return repository.getAllWarehouseAssignments();
  }
  return repository.getWarehouseAssignments(warehouseId);
});

final todayAssignmentsProvider = StreamProvider.family<List<WarehouseAssignmentModel>, String>((ref, warehouseId) {
  final repository = ref.watch(warehouseRepositoryProvider);
  return repository.getTodayAssignments(warehouseId);
});

final inTransitAssignmentsProvider = StreamProvider.family<List<WarehouseAssignmentModel>, String>((ref, warehouseId) {
  final repository = ref.watch(warehouseRepositoryProvider);
  return repository.getInTransitAssignments(warehouseId);
});

final warehouseAssignmentProvider = FutureProvider.family<WarehouseAssignmentModel?, String>((ref, assignmentId) async {
  final repository = ref.watch(warehouseRepositoryProvider);
  return await repository.getWarehouseAssignment(assignmentId);
});

final warehouseNotifierProvider = StateNotifierProvider<WarehouseNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(warehouseRepositoryProvider);
  return WarehouseNotifier(repository, ref);
}); 