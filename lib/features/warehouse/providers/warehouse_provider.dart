import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:refab_app/features/warehouse/data/repositories/warehouse_repository.dart';
import 'package:refab_app/features/warehouse/data/models/inventory_model.dart';
import 'package:refab_app/features/warehouse/data/models/processing_task_model.dart';
import 'package:refab_app/features/warehouse/data/models/warehouse_analytics_model.dart';
import 'package:refab_app/features/warehouse/data/models/warehouse_worker_model.dart';
import 'package:refab_app/features/warehouse/data/models/warehouse_location_model.dart';

// Repository Provider
final warehouseRepositoryProvider = Provider<WarehouseRepository>((ref) {
  return WarehouseRepository();
});

// Warehouse ID Provider (for multi-warehouse support)
final warehouseIdProvider = StateProvider<String>((ref) => 'main_warehouse');

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
    category: filters['category'],
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

// ==================== TASK PROVIDERS ====================

final processingTasksProvider = StreamProvider.family<List<ProcessingTaskModel>, String>((ref, warehouseId) {
  final repository = ref.watch(warehouseRepositoryProvider);
  return repository.getProcessingTasks(warehouseId: warehouseId);
});

final tasksByStatusProvider = StreamProvider.family<List<ProcessingTaskModel>, Map<String, dynamic>>((ref, filters) {
  final repository = ref.watch(warehouseRepositoryProvider);
  return repository.getProcessingTasks(
    warehouseId: filters['warehouseId'],
    status: filters['status'],
    workerId: filters['workerId'],
    taskType: filters['taskType'],
  );
});

final urgentTasksProvider = StreamProvider.family<List<ProcessingTaskModel>, String>((ref, warehouseId) {
  final repository = ref.watch(warehouseRepositoryProvider);
  return repository.getProcessingTasks(warehouseId: warehouseId)
      .map((tasks) => tasks.where((task) => task.isUrgent || task.isOverdue).toList());
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

// ==================== LOCATION PROVIDERS ====================

final warehouseLocationsProvider = StreamProvider.family<List<WarehouseLocationModel>, String>((ref, warehouseId) {
  final repository = ref.watch(warehouseRepositoryProvider);
  return repository.getLocations(warehouseId: warehouseId);
});

final availableLocationsProvider = StreamProvider.family<List<WarehouseLocationModel>, String>((ref, warehouseId) {
  final repository = ref.watch(warehouseRepositoryProvider);
  return repository.getLocations(warehouseId: warehouseId, status: 'available')
      .map((locations) => locations.where((location) => location.isAvailable).toList());
});

final locationsByTypeProvider = StreamProvider.family<List<WarehouseLocationModel>, Map<String, dynamic>>((ref, filters) {
  final repository = ref.watch(warehouseRepositoryProvider);
  return repository.getLocations(
    warehouseId: filters['warehouseId'],
    status: filters['status'],
    type: filters['type'],
  );
});

// ==================== ANALYTICS PROVIDERS ====================

final warehouseAnalyticsProvider = FutureProvider.family<WarehouseAnalyticsModel, String>((ref, warehouseId) async {
  final repository = ref.watch(warehouseRepositoryProvider);
  return await repository.getWarehouseAnalytics(warehouseId);
});

final adminDashboardDataProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, warehouseId) async {
  final repository = ref.watch(warehouseRepositoryProvider);
  return await repository.getAdminDashboardData(warehouseId);
});

// ==================== INTEGRATION PROVIDERS ====================

final logisticsNotificationsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, warehouseId) async {
  final repository = ref.watch(warehouseRepositoryProvider);
  return await repository.getLogisticsNotifications(warehouseId);
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

  // Task Operations
  Future<void> createProcessingTask(ProcessingTaskModel task) async {
    state = const AsyncValue.loading();
    try {
      await _repository.createProcessingTask(task);
      _ref.invalidate(processingTasksProvider(task.warehouseId));
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateTaskStatus(taskId, status);
      _ref.invalidate(processingTasksProvider('main_warehouse')); // TODO: Get actual warehouse ID
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> assignTaskToWorker(String taskId, String workerId, String workerName) async {
    state = const AsyncValue.loading();
    try {
      await _repository.assignTaskToWorker(taskId, workerId, workerName);
      _ref.invalidate(processingTasksProvider('main_warehouse')); // TODO: Get actual warehouse ID
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> completeTask(String taskId, Map<String, dynamic> completionData) async {
    state = const AsyncValue.loading();
    try {
      await _repository.completeTask(taskId, completionData);
      _ref.invalidate(processingTasksProvider('main_warehouse')); // TODO: Get actual warehouse ID
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
      _ref.invalidate(warehouseWorkersProvider('main_warehouse')); // TODO: Get actual warehouse ID
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateWorkerPerformance(String workerId, Map<String, dynamic> metrics) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateWorkerPerformance(workerId, metrics);
      _ref.invalidate(warehouseWorkersProvider('main_warehouse')); // TODO: Get actual warehouse ID
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Location Operations
  Future<void> createLocation(WarehouseLocationModel location) async {
    state = const AsyncValue.loading();
    try {
      await _repository.createLocation(location);
      _ref.invalidate(warehouseLocationsProvider(location.warehouseId));
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateLocation(String locationId, Map<String, dynamic> updates) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateLocation(locationId, updates);
      _ref.invalidate(warehouseLocationsProvider('main_warehouse')); // TODO: Get actual warehouse ID
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateLocationOccupancy(String locationId, double occupancy) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateLocationOccupancy(locationId, occupancy);
      _ref.invalidate(warehouseLocationsProvider('main_warehouse')); // TODO: Get actual warehouse ID
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Batch Operations
  Future<void> processBatch(List<String> itemIds, Map<String, dynamic> processingData) async {
    state = const AsyncValue.loading();
    try {
      await _repository.processBatch(itemIds, processingData);
      _ref.invalidate(inventoryItemsProvider('main_warehouse')); // TODO: Get actual warehouse ID
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> moveToReady(List<String> itemIds) async {
    state = const AsyncValue.loading();
    try {
      await _repository.moveToReady(itemIds);
      _ref.invalidate(inventoryItemsProvider('main_warehouse')); // TODO: Get actual warehouse ID
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Integration Operations
  Future<void> notifyLogisticsOfReadyItems(String warehouseId, List<String> itemIds) async {
    state = const AsyncValue.loading();
    try {
      await _repository.notifyLogisticsOfReadyItems(warehouseId, itemIds);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> sendAdminAlert(String warehouseId, String alertType, String message) async {
    state = const AsyncValue.loading();
    try {
      await _repository.sendAdminAlert(warehouseId, alertType, message);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Refresh Operations
  Future<void> refreshInventory(String warehouseId) async {
    _ref.invalidate(inventoryItemsProvider(warehouseId));
  }

  Future<void> refreshTasks(String warehouseId) async {
    _ref.invalidate(processingTasksProvider(warehouseId));
  }

  Future<void> refreshWorkers(String warehouseId) async {
    _ref.invalidate(warehouseWorkersProvider(warehouseId));
  }

  Future<void> refreshLocations(String warehouseId) async {
    _ref.invalidate(warehouseLocationsProvider(warehouseId));
  }

  Future<void> refreshAnalytics(String warehouseId) async {
    _ref.invalidate(warehouseAnalyticsProvider(warehouseId));
  }
}

final warehouseNotifierProvider = StateNotifierProvider<WarehouseNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(warehouseRepositoryProvider);
  return WarehouseNotifier(repository, ref);
}); 