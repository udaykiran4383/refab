import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/admin_repository.dart';
import '../../auth/data/models/user_model.dart';
import '../../auth/data/repositories/auth_repository.dart';

import '../data/models/notification_model.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository();
});

final pickupRequestsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.read(adminRepositoryProvider);
  return await repository.getAllPickupRequests();
});

final assignmentsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.read(adminRepositoryProvider);
  return await repository.getAllAssignments();
});

// Stream providers for real-time updates
final pickupRequestsStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final repository = ref.read(adminRepositoryProvider);
  return repository.getAllPickupRequestsStream();
});

final assignmentsStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final repository = ref.read(adminRepositoryProvider);
  return repository.getAllAssignmentsStream();
});

// Status update providers
final updatePickupStatusProvider = FutureProvider.family<bool, Map<String, String>>((ref, params) async {
  final repository = ref.read(adminRepositoryProvider);
  final requestId = params['requestId']!;
  final status = params['status']!;
  return await repository.updatePickupRequestStatus(requestId, status);
});

final updateAssignmentStatusProvider = FutureProvider.family<bool, Map<String, String>>((ref, params) async {
  final repository = ref.read(adminRepositoryProvider);
  final assignmentId = params['assignmentId']!;
  final status = params['status']!;
  return await repository.updateAssignmentStatus(assignmentId, status);
});

// User provider
final userProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, userId) async {
  final repository = ref.read(adminRepositoryProvider);
  return await repository.getUser(userId);
});

final searchPickupRequestsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, query) async {
  final repository = ref.read(adminRepositoryProvider);
  return await repository.searchPickupRequests(query);
});

final searchAssignmentsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, query) async {
  final repository = ref.read(adminRepositoryProvider);
  return await repository.searchAssignments(query);
});

// Warehouse user management providers
final warehouseUsersProvider = StreamProvider<List<UserModel>>((ref) {
  final repository = ref.read(adminRepositoryProvider);
  return repository.getWarehouseUsers();
});

final createWarehouseUserProvider = FutureProvider.family<bool, Map<String, dynamic>>((ref, userData) async {
  final repository = ref.read(adminRepositoryProvider);
  return await repository.createWarehouseUser(userData);
});

final updateWarehouseUserProvider = FutureProvider.family<bool, Map<String, dynamic>>((ref, userData) async {
  final repository = ref.read(adminRepositoryProvider);
  return await repository.updateWarehouseUser(userData['id'], userData);
});

final activateWarehouseUserProvider = FutureProvider.family<bool, String>((ref, userId) async {
  final repository = ref.read(adminRepositoryProvider);
  return await repository.activateWarehouseUser(userId);
});

final deactivateWarehouseUserProvider = FutureProvider.family<bool, String>((ref, userId) async {
  final repository = ref.read(adminRepositoryProvider);
  return await repository.deactivateWarehouseUser(userId);
});

// Warehouse management providers
final allWarehousesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.read(adminRepositoryProvider);
  return await repository.getAllWarehouses();
});

final createWarehouseProvider = FutureProvider.family<bool, Map<String, dynamic>>((ref, warehouseData) async {
  final repository = ref.read(adminRepositoryProvider);
  return await repository.createWarehouse(warehouseData);
});

final updateWarehouseProvider = FutureProvider.family<bool, Map<String, dynamic>>((ref, warehouseData) async {
  final repository = ref.read(adminRepositoryProvider);
  return await repository.updateWarehouse(warehouseData['id'], warehouseData);
});

final deleteWarehouseProvider = FutureProvider.family<bool, String>((ref, warehouseId) async {
  final repository = ref.read(adminRepositoryProvider);
  return await repository.deleteWarehouse(warehouseId);
});

// Notifications providers
final allNotificationsProvider = FutureProvider<List<NotificationModel>>((ref) async {
  final repository = ref.read(adminRepositoryProvider);
  return await repository.getAllNotifications();
});

final markNotificationAsReadProvider = FutureProvider.family<bool, String>((ref, notificationId) async {
  final repository = ref.read(adminRepositoryProvider);
  return await repository.markNotificationAsRead(notificationId);
});

final deleteNotificationProvider = FutureProvider.family<bool, String>((ref, notificationId) async {
  final repository = ref.read(adminRepositoryProvider);
  return await repository.deleteNotification(notificationId);
});

// System health provider
final systemHealthProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.read(adminRepositoryProvider);
  return await repository.getSystemHealth();
});

// Products providers
final allProductsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final repository = ref.read(adminRepositoryProvider);
  return repository.getAllProducts();
});

// Orders providers
final allOrdersProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final repository = ref.read(adminRepositoryProvider);
  return repository.getAllOrders();
});

class AdminNotifier extends StateNotifier<AsyncValue<void>> {
  final AdminRepository _repository;

  AdminNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<bool> updatePickupRequestStatus(String requestId, String status) async {
    state = const AsyncValue.loading();
    try {
      final success = await _repository.updatePickupRequestStatus(requestId, status);
      if (success) {
        state = const AsyncValue.data(null);
      } else {
        state = const AsyncValue.error('Failed to update pickup request status', StackTrace.empty);
      }
      return success;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }

  Future<bool> updateAssignmentStatus(String assignmentId, String status) async {
    state = const AsyncValue.loading();
    try {
      final success = await _repository.updateAssignmentStatus(assignmentId, status);
      if (success) {
        state = const AsyncValue.data(null);
      } else {
        state = const AsyncValue.error('Failed to update assignment status', StackTrace.empty);
      }
      return success;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }
}

final adminNotifierProvider = StateNotifierProvider<AdminNotifier, AsyncValue<void>>((ref) {
  final repository = ref.read(adminRepositoryProvider);
  return AdminNotifier(repository);
}); 